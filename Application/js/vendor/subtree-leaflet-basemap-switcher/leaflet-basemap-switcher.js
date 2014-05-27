// Namespace
_SPDEV = _SPDEV || {};
_SPDEV.LBasemapSwitcher = {};


_SPDEV.LBasemapSwitcher.EXAMPLE_DATA = [
	{
		alias: 'Terrain',
		basemapURL: 'http://{s}.tiles.mapbox.com/v3/spatialdev.map-hozgh18d/{z}/{x}/{y}.png',
		state: false,
		defaultMap: false,
		mapLayer : null,
		vendor: 'MapBox'
	},
	{
		alias: 'Bing Aerial',
		basemapURL: '',
		state: false,
		defaultMap: true,
		mapLayer : null,
		vendor: 'Bing'
		
	}];




_SPDEV.LBasemapSwitcher.ModelView =  Backbone.View.extend({
		
		initialize: function(){
			
			// Listen for changes on the model's "state" attribute; true means the WMS layer should be 'on'
			this.model.bind('change:state', this.onStateChange, this);
		},
		
		
		tagName: 'li',
		
		// When this view is click, fire the onClick function
		events: {'click': 'onClick'},
		
		className: 'checkbox-list-item',
		
		// The view's html template
		template: _.template('<div class="label"><%= alias %></div>'),
		
		// Render this view
		render: function(){
			
			this.$el.append(this.template(this.model.attributes));
		},
		
		// Function for view click event
		onClick: function(e){
 			
 			if(this.model.get('state') === true) {
 				return;
 			}
 			
 			var self = this;
 			
 			// Loop through all models in the parent collection
 			this.model.collection.each(function(colModel, i){
 				
 				// For all model's except the one linked to this view
 				if(colModel !== self.model){
 					
 					//Reset state to false
 					colModel.set({'state': false});
 				}
 			});
 			
 			// Set the new model 'state' value
 			this.model.set({'state': true});
 			
	 	},
	 	
	 	// When the model's state attribute changes, this function fires;  this will add/remove map layer, check uncheck checkboxes
		onStateChange: function(){
			// Get the model's 'state' attribute
			var state = this.model.get('state');
			
			// state == true
 			if(state) {
 				// Set the view css class appropriately
 				this.$el.addClass('selected');
 				
 				// Add the wms layer to the map
 				this.model.collection.map.addLayer(this.model.get('mapLayer'));	
 				this.model.get('mapLayer').bringToBack();			
 			}
 			else {
 				this.$el.removeClass('selected');
 				this.model.collection.map.removeLayer(this.model.get('mapLayer'));
 			}
		}
		
	});

// The collection view that serves as the checkbox list to turn on/off wms layers
_SPDEV.LBasemapSwitcher.SelectionListCollectionView = Backbone.View.extend({
	
	initialize: function (options) {
		
		var self = this;
		
		var opts = options || {};
                
        var modelViewClass = opts.modelViewClass || _SPDEV.LBasemapSwitcher.ModelView;
                
    	// Create an array property that will store model views contained in this collection view
    	this.componentViews = [];
    	
    	// Loop thru the collection
    	this.collection.forEach( function(colModel, index) {
    		
    		// Create a view for each model contained in this view's referenced collection - each view is a WMS list-item			
		    var modelView = new  modelViewClass({model:colModel});
		    
		    //modelView.setElement();
		    
		    // Store this in the collection view's componentView array
		    self.componentViews.push(modelView);
		});
	},
	
	// This view's wrapper tag is a ul
	tagName: 'ul',
	
	// This view's wrapper css class
	className: 'basemap-list',
	
	// rendering function for this view
	render: function(){
		
		var self = this;
		
		// Render and append each model view of collection (table rows)
		_.each(this.componentViews, function(view){
			
			// Render the component view
			view.render();
			
			// Append the view to this collection view element
			self.$el.append(view.el);
			
		});	
	    
	},
	
});

// Backbone collection to hold the WMS-layer models
_SPDEV.LBasemapSwitcher.Collection = Backbone.Collection.extend({
	
	constructor: function (options) {
    				
    	Backbone.Collection.apply( this, {model: Backbone.Model.extend()} );
    	
    	this.bind( 'add', this.onModelAdded, this );
		
		//This will be set to Leaflet map
		this.map = options.map;			
	},
	
	// Initialize the collection
	initialize: function(data) {
		
		// Loop through the incoming object array	
		_.each(data, function(rec){
			
			if(rec['vendor'] === 'Bing') {

				rec['mapLayer'] = new L.BingLayer("Asl6WbC1b-Sc6aaKKreVYS0db5tovKsUgwQyMxHyveAadYDUIxhv9_fQq44iBTlL", {'type': rec['bingType']});
			}
			else {
			rec['mapLayer'] = L.tileLayer(rec['basemapURL'], {});
			}
			// Use this record to creata a Backbone model, add the model to the collection 			
			this.add(new  Backbone.Model(rec));
			
	  	}, this);	
	},
	
	setDefault: function(model) {
		
		var self = this;
		
		this.each(function(model){
			
			if(model.get('defaultMap')) {
				
				self.map.addLayer( model.get('mapLayer'));
				model.set({'state': true});
			}
			
		});

		
	}
		
});



