// Initialize locations

_SPDEV.Locations = {};


_SPDEV.Locations.Collection = Backbone.Collection.extend({

	// Constructor for collection; invoked on intial load AND if user elects to summarize data by an attribute that is not the default 
	constructor: function (options) {
    			
    	Backbone.Collection.apply( this);
		
	},
	
	init: function(points, map, opts) {
		
		var self = this;
		
		this.map = map; 
		
		// Object to store all locations (whether currently visible on map/list or not); 
		// key = locaiton id and value = {} containing location data 
		this.allLocs = {};
		
		// Array to store filtered location objects (only those visible in map or list view)
		this.filteredLocs = [];
		
		// Map layer id
		this.layerId = opts.layerId || 'clusterLayer_' + Math.floor( Math.random() * 100);
		
		// Using classification colors?
		this.useClassificationColors = opts.useClassificationColors || false;
		
		// The taxonomy Id currently being used to summarize clusters
		this.reportByTaxonomyId = opts.reportByTaxonomyId || null;
		
		// The currently active taxonomy-classification colors
		this.pointTaxonomyClassifications = opts.pointTaxonomyClassifications || null;
		
		this.otherClassificationColor = opts.otherClassificationColor || null;
		
		this.clusterChartType = opts.clusterChartType || 'none';
		
		this.updateChannel = opts.updateChannel || null;
		
		if(typeof opts.displayOnLoad === 'undefined' ) {
			this.displayState =  true;
		} else if(opts.displayOnLoad !== true && opts.displayOnLoad !== false ) {
			this.displayState =  true;
		} else {
			this.displayState =  opts.displayOnLoad;
		}
		
		if(typeof opts.useClassificationColors === 'undefined' ) {
			this.useClassificationColors =  false;
		} else if(opts.useClassificationColors !== true && opts.useClassificationColors !== false ) {
			this.useClassificationColors =  false;
		} else {
			this.useClassificationColors =  opts.useClassificationColors;
		}

		_.each(points, function(loc){
	 		self.allLocs[loc['l_id']] = loc;

	 		var dd = QClusterLeafletLayer.webMercatorToGeographic(loc.x, loc.y);
	 		loc.lat = dd[0];
	 		loc.lng = dd[1];

	  	}, this);	  	
		
		this.layerOptions = {
						'useClassificationColors': this.useClassificationColors, 
						'dataDictionary': this.pointTaxonomyClassifications[this.reportByTaxonomyId].values_keyVal,
						'clickHandler': this.clusterClickHandler,
						'layerDataLoadedPublish': this.layerDataLoadedPublish,
						'clusterClassificationChart': this.clusterChartType,
						'displayState': this.displayState,
						summarizationProperty: 'r_ids'
						};
								
		// Perform initial point clustering
		this.clusterLayerManager = new QClusterLeafletLayer.Manager(points, this.layerId, this.map, this.layerOptions);
		
		//amplify.publish('dataRetrieved');
		
		if(this.updateChannel){
			amplify.subscribe(this.updateChannel, this, this.updateLocations);
		}
		// Subscribe to channel that pusblishes filter location ids (SQL executed by php, returns list of location IDs that should remain on the map)
		amplify.subscribe('coreDataFiltered', this, this.narrow);
		
		amplify.subscribe('activeClusterRemoved', function(){
			
			//TODO: remove hardwiring
			$('#mapInfobox').hide();
		});
	},
	
	updateLocations: function(postData) {
		
		var self = this;
		
		// Show loading div
		amplify.publish('waitingForData');
		
		$.ajax({
			'type': 'POST',
			'data': postData,
		  	'dataType': "json",
		  	'url': 'php/filterLocationsReportByTax.php',
		  	'success': function(data){
		  		
		 		self.narrow({'reportByTaxonomyId': postData.summaryTaxId, 'points': data});
		 		amplify.publish('dataRetrieved');
		 	
		  	},		  
		  'error': function(response) {
		  	
		  	// TODO: error handling
		  	console.error(response);
		  	amplify.publish('dataRetrieved');
		  }
		});
	
	},
	
	// filter the locations shown on map and in list
	////////////////////////
	narrow: function(data) {
		
		var points,
			p_locId,
			p_reportingIds,
			loc;
		
		// Remove the old cluster layer
		this.map.removeLayer(this.clusterLayerManager.layer);
		
		points = data.points;
		
		// if no points returned
		if(points === null) {
			
			// turn off the spinner
			amplify.publish('dataRetrieved');
			
			// send empty point array
			this.clusterLayerManager.pointData = [];
			
			//this.clusterLayerManager.pointClassifications = this.pointTaxonomyClassifications[data.reportByTaxonomyId].classifications;
			return;
		} else {
		
		// Reset the report by Attribute ID
		this.reportByTaxonomyId = data.reportByTaxonomyId;
		
		// Clear filtered locations array
		this.filteredLocs.length = 0;
		
		// Load the filtered locations array
		for (var j = 0, jMax = points.length; j <  jMax; j ++) {
			
			p_locId = points[j]['l_id'];
			p_reportingIds = points[j]['r_ids'];
			loc = this.allLocs[p_locId];
			
			try {
				if(this.allLocs.hasOwnProperty(p_locId)) {
					
					// Is the location id returned found in the dataset created when the app loaded?
					loc = this.allLocs[p_locId];
					
					// Are there any reporting ids for this location?  Empty's appear to get set as undefined
					if(typeof p_reportingIds === 'undefined') {
						// Set reporting ids as empty string
						loc['r_ids'] = '';
					}
					else {
						// reassign reporting ids for the location with the new data
						loc['r_ids'] = p_reportingIds;
					}
					
					// Add to the filtered location array
					this.filteredLocs.push(loc);
					
				} else {
					throw 'Location with id: ' + p_locId + ' is not found in the ' + this.layerId + ' data set.';
				}
			}
			catch (err) {
				console.error(err);
			}
			
			
		}
		
		// Do the clustering
		this.clusterLayerManager.pointData = this.filteredLocs;
		this.clusterLayerManager.pointClassifications = this.pointTaxonomyClassifications[data.reportByTaxonomyId].values_keyVal;
		this.clusterLayerManager.clusterPoints();
		
		amplify.publish('dataRetrieved');
		}
	},
	
	
	// Define the click hanler when a location cluster get's clicked
	//////////////////////////////
	clusterClickHandler: function(e) {
		var clusterLayerManager,
			cluster,
			priorActiveCluster;
			
		clusterLayerManager = this;
		cluster = e.target;
		
		//amplify.publish('hideAndClearMapInfobox');
		//amplify.publish('hideExpandedInfobox');
		//clusterLayerManager.map._SPDEV_infobox_.hide();
		//clusterLayerManager.map._SPDEV_infobox_.clearContent();

		if(cluster.l_ids.length < 40 
			||  clusterLayerManager.map.getMaxZoom() === clusterLayerManager.map.getZoom()
				|| cluster.stacked === true){
			
			if(clusterLayerManager.activeCluster) {
				priorActiveCluster = true;
			} else {
				priorActiveCluster = false;
			}
			
			// Store the lat lng of this cluster in the cluster layer manager; when the layer is reclustered (as after the pan event below) we will use it
			// to ensure the marker we originally clicked gets 'highlighted'
			clusterLayerManager.activeCluster = cluster;
			
			// Center the map on this cluster; panning the map, however, re-clusters the layer...which kills this cluster we just clicked!!! 
			// Which means it is useless to add the active-marker CSS to the cluster div we just clicked.  Look at clusterPoints() and markActiveCluster to
			// see the work around.
			clusterLayerManager.map.panTo(new L.LatLng(cluster._latlng.lat, cluster._latlng.lng));
			clusterLayerManager.markActiveCluster();
			

			amplify.publish('showInfobox', cluster.l_ids.toString());

			
	    }
	    else {
	    	clusterLayerManager.removeActiveCluster(false);
	    	clusterLayerManager.map.setView(new L.LatLng(cluster._latlng.lat, cluster._latlng.lng), this.map.getZoom()+1);
	    }
	    
	}

});

