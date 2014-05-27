// Use this in conjunction with qCluster.js to create a cluster layer on a Leaflet Map; requires Leaflet JS lib
// the 'makeDonuts' function (not mandatory to use) requires D3 and jQuery
var QClusterLeafletLayer = {};

QClusterLeafletLayer.Manager =  function(pointArr, id, map, opts){
	
	this.layer;
	this.layerId = id;
	this.pointData = pointArr;
	this.map = map;
	this.clusters = {};
	this.activeCluster = null;
	  
	var self,
		options,
		clusters,
		cnt,
		divHtml,
		divClass,
		myIcon,
		latlon,
		points,
		clusterMarker,
		classificationId,
		clusterMarkers = [];
	
	self = this;
		
	options = opts || {};
	
	this.displayState =  this.setBoolOption(options.displayState, true);
	this.mapOrder = options.mapOrder;
	this.useClassificationColors = this.setBoolOption(options.useClassificationColors, false);
	this.hasClusterClick = this.setBoolOption(options.hasClusterClick, true);
	this.hasSingleClick = this.setBoolOption(options.hasSingleClick, false);
	this.clusterClassificationChart = options.clusterClassificationChart || 'none';
	this.dataDictionary = options.dataDictionary || null;
	this.summarizationProperty = options.summarizationProperty || null;
	this.mapEdgeBuffer = options.mapEdgeBuffer || 100;
	this.clusterTolerance = options.clusterTolerance || 100;
	this.clusterCssClass = options.clusterCssClass || '';
	this.clusterClickHandler = options.clusterClickHandler || null;
	this.clickHandler = options.clickHandler || null;
	this.otherClassificationColor = options.otherClassificationColor || '#666666';
	this.donutInnerRadiusProportion =  options.donutInnerRadiusProportion || 0.4;
	
	// Do the clustering
	this.clusterPoints();
	
	//  When the map pans or zooms
	this.map.on('moveend', this.mapMove, this);
	
	// When map is clicked, we clear the active marker
	this.map.on('click', function(){
		// Remove the active marker and publish notification
		this.removeActiveCluster(true);
	}, this);
	
	// Listen for removeActiveCluster notifications
	amplify.subscribe('removeActiveCluster', this, function(){
		// Remove the active marker
		this.removeActiveCluster(false);

	});
		
	return this;
};

QClusterLeafletLayer.Manager.prototype.mapMove = function(){
	
	if(!$(this.map._container).is(":visible")) {
		return;
	}
		
		this.map.removeLayer(this.layer);
		
	    this.clusterPoints();

};

QClusterLeafletLayer.Manager.prototype.clusterPoints = function() {
	
		var clusters,
		cnt,
		divHtml,
		divClass,
		myIcon,
		latlon,
		points,
		clusterMarker,
		classificationId,
		clusterMarkers = [],
		lat, lng, lats = [], lngs = [],
		self = this;
	
	if(!$(this.map._container).is(":visible")) {
		return;
	}
	
	if(typeof this.layer !== 'undefined') {
		this.map.removeLayer(this.layer);
	}
	
	// Use qCluster library to cluster points
	clusters = QCluster.makeClusters(this.pointData, this.getResolution(), this.clusterTolerance, this.mapBounds());
	this.clusters = {};
	
	// Now create the cluster markers for the clusters qCluster returned
	for(var i = 0, iMax = clusters.length; i < iMax; i++) {
		
		// Test to see if this cluster is in the defined rendering extent
		if(this.isInBounds(clusters[i].cX, clusters[i].cY)) {
			
			// Add this cluster to an object, with a key that matches a css class name that will be added to the leaflet map marker
			this.clusters['cId_' + clusters[i].id] = clusters[i];
			
			points = clusters[i].points;
			
			// Number of points in each cluster
			cnt = points.length;
			
			// Custom HTML inside of each leaflet marker div
			divHtml = '<div><span>' + cnt +'</span></div>';
			
			// create the class name(s) for the leaflet marker div; the layer id added as the first additional class
			divClass = this.layerId + ' leaflet-marker-icon q-marker-cluster ' + this.clusterCssClass;
			
			// differeniate class names based on cluster point count; clusters greater than one get a 'cluster id' class that matches a key in the this.clusters object
			if (cnt === 1) {
				divHtml = '<div><div class="q-marker-single-default"><span>' + cnt +'</span></div></div></div>';
				divClass = divClass + 'q-marker-cluster-single';
				
				// Use color of first reporting id
				classificationIds = points[0][this.summarizationProperty].toString().split(',');
				
				// Color single points by classification color?
				if(this.useClassificationColors) {
					
					if (typeof this.dataDictionary[classificationIds[0]] !== 'undefined') {

						divHtml = '<div style="background-color: ' + this.dataDictionary[classificationIds[0]].color + '"><div class="q-marker-single-default"><span>' + cnt +'</span></div></div></div>';
					}
				}		
			}
			else if (cnt < 100){
				divClass =  divClass + 'q-marker-cluster-small cId_' + clusters[i].id;
			} else if (cnt < 1000){
				divClass = divClass + 'q-marker-cluster-medium cId_' + clusters[i].id;
			} 
			else {
				divClass = divClass + 'q-marker-cluster-large cId_' + clusters[i].id;
			}
			
			// set up the custom leaflet marker icon
			myIcon = L.divIcon({'className':divClass , 'html': divHtml });
			
			// Convert web mercator coordinates to lat/lon as required by leaflet
			latlon =  this.webMercatorToGeographic(clusters[i].cX, clusters[i].cY);
			
			// instaniate the leaflet marker
			clusterMarker = L.marker(latlon, {icon:myIcon});
			
			// Determine if all points within a cluster have the approximately same coordinates
			clusterMarker['stacked'] = true;
			
			lats[0] = Math.round(points[0].lat*10000)/10000;
			lngs[0] = Math.round(points[0].lng*10000)/10000;
			
			for (var n = 1, nMax = points.length; n < nMax; n++) {
				
				lats[n] = 	Math.round(points[n].lat * 10000)/10000;
				lngs[n] = Math.round(points[n].lng * 10000)/10000;
				if( lats[n] !== lats[0] 
					|| lngs[n] !== lngs[0]){
				
					clusterMarker['stacked'] = false;
					break;
				}
			}

			// Deal with cluster click event
			if(this.hasClusterClick) {
				
				clusterMarker['l_ids'] = [];
			
				for (var j = 0, jMax = cnt; j < jMax; j ++) {
					clusterMarker['l_ids'].push(points[j].l_id);
				}
				
				if(this.clickHandler){
					clusterMarker.on('click', this.clickHandler, this);
				}
			}
			
			// Store it in an array
			clusterMarkers.push(clusterMarker);	
		}
	}
	
	// instaniate a leaflet feature group that contains our clusters
	this.layer = L.featureGroup(clusterMarkers);
	
	// Add layer to map if displayState is true
	if(this.displayState){
		this.map.addLayer(this.layer);

		$('.' + this.layerId).css('z-index', this.mapOrder);
		switch (this.clusterClassificationChart) {
			
			case 'donut':
				this.makeDonuts();
				break;
			case 'none':
				break;
			default:
		}	
		
	}
	
	if(this.activeCluster) {
		this.markActiveCluster();
	}
	//amplify.publish('clusteringFinished');
};

QClusterLeafletLayer.Manager.prototype.findMaxMarkerZ = function(){

	var children = $(this.map._mapPane).find('.leaflet-marker-pane').children();

	var maxZ = 0;

	for(var i = children.length-1; i >= 0; i--) {
		
		
		var zIndex = parseInt($(children[i]).css('zIndex'),10);

		if(zIndex > maxZ) {
			maxZ = zIndex;
		}

	}

	return maxZ;
}

// Add D3 donut charts to leaflet cluster icons
QClusterLeafletLayer.Manager.prototype.makeDonuts = function() {
	
	var points,
		data,
		tmpDataset,
		dataset,
		width,
	    height,
	    radius,
	    wrapper,
	    color,
	    pie,
	    arc,
	    svg,
	    path,
	    rIdArr,
	    rId;
		
	// Loop thru the this.clusters object    
	for (var i in this.clusters){
		
		data = {};
		
		points = this.clusters[i].points;
		
		// Loop through the clusters points and summarize the points by counts per unique attribute (stored in the 's' property)
		for (var j = 0, jMax = points.length; j < jMax; j ++) {
			
			// Split the comma delimited string of reporting ids
			rIdArr = points[j][this.summarizationProperty].toString().split(',');
			
			// Loop
			for (var k = 0, kMax = rIdArr.length; k < kMax; k++) {
				
				// this iteration's reporting id	
				rId = rIdArr[k];	
				
				// If we have already come across this id before (and started a count of its frequency), increment the count
				if(data.hasOwnProperty(rId)) {
					data[rId]['count']++; 
				}
				else if (rId === ''){
					// Null report id's come through as an empty string because this starts as a comma delimited string
					//  We're assigning null ids to a pseudo-id of -9999
					
					// Increment the count of -9999 
					if(data.hasOwnProperty('-9999')) {
						data['-9999']['count']++; 
					}
					else {
						// if this is the first null id, create an object property and start the counter
						data['-9999'] = {
						'count': 1,
						'color': this.otherClassificationColor,
						'alias': 'Not assigned'
						};
					}
				}
				else {
					// if this is the first time we see this id, create an object property and start the counter
					data[rId] = {
						'count': 1,
						'color': this.dataDictionary[rId].color,
						'alias': this.dataDictionary[rId].alias
						};
				}

			}
	
		}

		// prep dataset for D3; need a temp dataset to deal with merging of data counts for 'other' category
		tmpDataset = [];
		dataset = [];
		
		// Push properties from object holding the category counts/colors categories into an object array
		for (var j in data) {
			tmpDataset.push(data[j]);	
		}
		
		// Create an object that will merge the count from all classification catergories that we've deemed as 'other''
		var mergedOther = {
						'count': 0,
						'color': this.otherClassificationColor,
						'alias': 'other'
					};
		
		// Merge all 'other' objects; we determine which are 'other' by testing to see if its been assigned the 'other' color		
		for (var k = 0, kMax = tmpDataset.length; k < kMax; k++) {
			
			if(tmpDataset[k].color === this.otherClassificationColor) {
				mergedOther.count = mergedOther.count + tmpDataset[k].count;
			} else {
				dataset.push(tmpDataset[k]);
			}
		}
		
		// Add the merge objedt to the dataset we will use in donut chart
		dataset.push(mergedOther);

		// Use jQuery to get this cluster markers height and width (set in the CSS)
		wrapper = $('.'+ this.layerId + '.' + i);
		width = $(wrapper).width();
		height = $(wrapper).height();
		radius =  Math.min(width, height) / 2;
		
		
		// D3 donut chart boilerplate
		
		pie = d3.layout.pie()
		    	.sort(null);
		
		arc = d3.svg.arc()
		    .innerRadius(radius-radius * this.donutInnerRadiusProportion)
		    .outerRadius(radius);
		
		// Note that we add 'clusterDonut' as a selector
		svg = d3.select('.'+ this.layerId + '.' + i).append("svg")
			.attr("class", "clusterDonut")
		    .attr("width", width)
		    .attr("height", height)
		    //.style('display', 'none')
		    .append("g")
		    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
		
			path = svg.selectAll("path")
					.data(function(){
						    	var dataObjArr,
						    		dataArr,
						    		pieData;
						    		
						    	dataObjArr = dataset;
						    	
						    	dataArr = [];
						    	
						    	for (var i = 0, iMax = dataObjArr.length; i < iMax; i++) {
						    		dataArr.push(dataObjArr[i]['count']);	
						    	}
						    	
						    	pieData = pie(dataArr);
						    	
						    	for (var i = 0, iMax = pieData.length; i < iMax; i++) {
						    		pieData[i].data = dataObjArr[i];	
						    	}
						    	
						    	return pieData;
		    				})
		  				.enter().append("path")
		    			.attr("fill", function(d, j) { 
								    	return d.data.color; 
								    	})
		    			.attr("d", arc);

	}
	

};

QClusterLeafletLayer.Manager.prototype.removeLayer = function(){
	
	this.map.off('moveend', this.mapMove, this);
	this.map.off('click', this.removeActiveCluster, this);
    this.map.removeLayer(this.layer);

};

QClusterLeafletLayer.Manager.prototype.replaceLayer = function(){
	
	this.map.on('moveend', this.mapMove, this);
	this.map.on('click', function(){
		// Remove the active marker and publish notification
		this.removeActiveCluster(true);
	}, this);
	
    this.clusterPoints();

};

// Check whether an x,y (web mercator is within the buffered extent of the passed Leaflet map)
QClusterLeafletLayer.Manager.prototype.isInBounds = function(x, y) {
	var xmin,
		xmax,
		ymin,
		ymax,
		bounds,
		resolution;
	
	bounds = this.map.getBounds();
	resolution = this.getResolution();
	
	xmin = L.CRS.EPSG3857.project(bounds._southWest).x - this.mapEdgeBuffer * resolution;
	xmax = L.CRS.EPSG3857.project(bounds._northEast).x + this.mapEdgeBuffer * resolution;
	ymin = L.CRS.EPSG3857.project(bounds._southWest).y - this.mapEdgeBuffer * resolution;
	ymax = L.CRS.EPSG3857.project(bounds._northEast).y + this.mapEdgeBuffer * resolution;
	
	if(x < xmin || x > xmax || y < ymin || y > ymax) {
		return false
	}
	else {
		return true;
	}
	
};

QClusterLeafletLayer.Manager.prototype.mapBounds = function(x, y) {
	var xmin,
		xmax,
		ymin,
		ymax,
		bounds,
		resolution;
	
	bounds = this.map.getBounds();
	resolution = this.getResolution();
	xmin = L.CRS.EPSG3857.project(bounds._southWest).x - this.mapEdgeBuffer * resolution;
	xmax = L.CRS.EPSG3857.project(bounds._northEast).x + this.mapEdgeBuffer * resolution;
	ymin = L.CRS.EPSG3857.project(bounds._southWest).y - this.mapEdgeBuffer * resolution;
	ymax = L.CRS.EPSG3857.project(bounds._northEast).y + this.mapEdgeBuffer * resolution;
	
	return {'xmin': xmin, 'xmax': xmax, 'ymin': ymin, 'ymax': ymax };
	
};

QClusterLeafletLayer.Manager.prototype.getResolution = function() {
	
	var xmin,
		xmax,
		bounds,
		mapWidth;
				
	bounds = this.map.getBounds();
	mapWidth = this.map.getSize().x;

	xmin = L.CRS.EPSG3857.project(bounds._southWest).x;
	xmax = L.CRS.EPSG3857.project(bounds._northEast).x;
		
	return (xmax - xmin)/mapWidth; // meters/pixel
};

QClusterLeafletLayer.Manager.prototype.markActiveCluster = function() {
		
		if(this.activeCluster === null) {
			return;
		}
		// When the user click on a cluster that can be made active (i.e., less than 20 points), the map centers on that cluster
		// Of course, when that happens, the old clusters/layer gets destoyed and remade.  Thus we lose reference to the cluster
		// that we clicked to make active.  However, the lat/lng of the orginally clicked cluster, will be identical to the new
		// cluster that should be made active
		
		// Loop thru all the 'markers' (aka _layers) in the map layer 
		for(var i in this.layer._layers) {
			
			var latlng = this.layer._layers[i]._latlng;
			
			// If this marker's latlng & point count === the clicked cluster's properties, add active-marker class to the divIcon
			if(latlng.lat === this.activeCluster._latlng.lat && latlng.lng === this.activeCluster._latlng.lng ) {
				$(this.layer._layers[i]._icon).toggleClass('active-marker', true);
			}
		}

};

QClusterLeafletLayer.Manager.prototype.removeActiveCluster = function(publishRemovalNotice) {
	
		this.activeCluster = null;
		
		$('.leaflet-marker-pane .active-marker').toggleClass('active-marker', false);
		
		if(publishRemovalNotice === true){
			// Send a message that the active cluster has been removed
			amplify.publish('activeClusterRemoved');
		}
};

QClusterLeafletLayer.Manager.prototype.webMercatorToGeographic = function(mercatorX, mercatorY) {
	
	var x,
		y,
		lon,
		lat;
	
    if ((Math.abs(mercatorX) > 20037508.3427892) || (Math.abs(mercatorY) > 20037508.3427892)){
        return;
	}
	
    lon = ((mercatorX / 6378137.0) * 57.295779513082323) - (Math.floor( ( (((mercatorX / 6378137.0) * 57.295779513082323) + 180.0) / 360.0)) * 360.0);
    lat = (1.5707963267948966 - (2.0 * Math.atan(Math.exp((-1.0 * mercatorY) / 6378137.0)))) * 57.295779513082323;
	
    return [lat, lon];
};

QClusterLeafletLayer.Manager.prototype.setBoolOption = function(option, defaultBool){
	
		if(typeof option === 'undefined' ) {
			return defaultBool;
		} else if(option !== true && option !== false ) {
			return defaultBool;
		} else {
			return option;
		}
	
	
};

QClusterLeafletLayer.FacetColorLibrary = function(facetId, facetName, facetValues, propMap, opts) {
	
	var color,
		options,
		index,
		colorPalette,
		maxColors,
		otherColor,
		facet;
	
	options = opts || {};
			
	colorPalette = options.colorPalette || ['#8b722c','#e7dfc7','#040707','#c96228','#80adc0','#a19788','#ddecf2','#9e0000','#03671f','#8e2b5c','#e13066','#5c8276','#efa0cb','#62517b','#2c688b','#56c2a7','#e1df2f','#ed3333','#e69890','#545454'];	
	
	maxColors = options.maxColors || 50;
	
	otherColor = options.otherColor || '#666666';
	
		facet = {
			
			'id': facetId,
		 	'name': facetName,
		 	'values_keyVal' : {},
		 	'values_arr': [],
		 	'otherColor': otherColor
		 	
		};	
		
		// Loop thru each classification
		_.each(facetValues, function(fVal, i){
			
			var facetValue = {
				'id': fVal[propMap.id],
				'name': fVal[propMap.name], 
				'color': fVal[propMap.color], 
			};
			
			if(typeof facetValue.color === 'undefined' || facetValue.color === null) {
				
				if (i > maxColors - 1) {
					facetValue.color = otherColor;
				
				} else if (i > colorPalette.length - 1) {
					
					index = (i % colorPalette.length) - 1;
					facetValue.color = colorPalette[index];
				
				} else {
					
					facetValue.color = colorPalette[i];					
				}				
			}
			
			facet.values_keyVal[facetValue.id] = facetValue;
			
			facet.values_arr.push(facetValue);
		});

	return facet;
};

QClusterLeafletLayer.webMercatorToGeographic = function(mercatorX, mercatorY) {
	
	var x,
		y,
		lon,
		lat;
	
    if ((Math.abs(mercatorX) > 20037508.3427892) || (Math.abs(mercatorY) > 20037508.3427892)){
        return;
	}
	
    lon = ((mercatorX / 6378137.0) * 57.295779513082323) - (Math.floor( ( (((mercatorX / 6378137.0) * 57.295779513082323) + 180.0) / 360.0)) * 360.0);
    lat = (1.5707963267948966 - (2.0 * Math.atan(Math.exp((-1.0 * mercatorY) / 6378137.0)))) * 57.295779513082323;
	
    return [lat, lon];
};