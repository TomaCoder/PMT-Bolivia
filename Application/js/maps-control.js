// Namespace
_SPDEV.MapsControl = {};

_SPDEV.MapsControl.Basemaps = {};

// Extend Basemaps view class for this specialized instance of the basemaps viewer
_SPDEV.MapsControl.Basemaps.ThumbnailModelView = _SPDEV.LBasemapSwitcher.ModelView.extend({
	
	className : 'basemap-thumbnail',
	
	template : _.template('<div class="<%= thumbnailClass %>" title="<%= alias %>"></div>')
		
});

// Initialization

_SPDEV.MapsControl.init = function(map, appendToEl, headerHTML, appendLegendToEl, dg) {
	
	var coll,
		collView,
		mapsControl,
		header,
		contentsWrpper;
	
	// Create the wrapper for the "MAPS control"
	mapsControl = $('<div id="mapsControl" class="data-control-section"></div>');
	
	// Create header
	this.header = $(headerHTML);
	
	// Append header
	$(mapsControl).append(this.header);
	
	// Create wrapper for control contents
	this.contentsWrapper = $('<div class="contents-wrapper"></div>');
	
	// Append
	$(mapsControl).append(this.contentsWrapper);
	
	$(this.contentsWrapper).append('<header>'+_lang.controlDialog_indicators+'</header>');
	
	this.contextLayersMenu = _SPDEV.MapsControl.ContextualLayers.init(map, this.contentsWrapper, appendLegendToEl, dg);
	
	$(this.contentsWrapper).append('<header>'+_lang.controlDialog_basemaps+'</header>');
	
	
	// Create a Backbone collection ohbject
	coll = new _SPDEV.LBasemapSwitcher.Collection({'map': map});
	
	// Fill the collection with the data array
	coll.initialize(_SPDEV.MapsControl.Basemaps.data);
	
	// Create a Backbone Collection View that serves as the WMS checkbox list
	collView = new _SPDEV.LBasemapSwitcher.SelectionListCollectionView({'collection': coll, modelViewClass: _SPDEV.MapsControl.Basemaps.ThumbnailModelView});
	
	// render that collection view
	collView.render();
	
	// Add the default basemap to map
	coll.setDefault();
	
	// Append the basemaps collection
	$(this.contentsWrapper).append(collView.el);
	
	// Append the maps control to the control panel
	$(appendToEl).append(mapsControl);
	
	// Handle header click events
	$(this.header).on('click', $.proxy(function(){
		var self = this;
		
		// if the maps control is already open, exit
		if($(self.header).hasClass('opened')){
			return;
		}
		
		// Send a message to close other control panel items
		amplify.publish('closeControlPanelItems', mapsControl);

		// Slide open the contents wrapper of this control
		$(self.contentsWrapper).slideToggle();
		
		// Give the header the 'opened' class
		$(self.header).toggleClass('opened');

	}, this));
	// Append the view to the DOM
	//$('#basemapList').append(collView.el);
	
	amplify.subscribe('closeControlPanelItems', this, function(elementBeingOpened){
		var self = this;	
		// Check if the 'closeControlPanelItems' publish came from this control item;
		// if so, exit, else we would be closing the item we just opened
		if(elementBeingOpened === mapsControl) {
			return;
		}
		
		// if this control is open, close it and adjust CSS.
		if($(self.header).hasClass('opened')) {
			$(self.contentsWrapper).slideToggle();
			$(self.header).toggleClass('opened');
		}
			
		});
	
	return this;
};


_SPDEV.MapsControl.Basemaps.data = [
	{
		alias: 'Imagery',
		basemapURL: 'http://{s}.tiles.mapbox.com/v3/spatialdev.map-hozgh18d/{z}/{x}/{y}.png',
		state: false,
		defaultMap: true,
		mapLayer : null,
		vendor: 'MapBox',
		
		// Added for this specific instance
		thumbnailClass: 'basemap-imagery'
	},
	{
		alias: 'Streets',
		basemapURL: 'http://{s}.tiles.mapbox.com/v3/spatialdev.map-rpljvvub/{z}/{x}/{y}.png',
		state: false,
		defaultMap: false,
		mapLayer : null,
		vendor: 'MapBox',
		thumbnailClass: 'basemap-streets'
	},
	{
		alias: 'Terrain',
		basemapURL: 'http://{s}.tiles.mapbox.com/v3/spatialdev.map-4o51gab2/{z}/{x}/{y}.png',
		state: false,
		defaultMap: false,
		mapLayer : null,
		vendor: 'MapBox',
		thumbnailClass: 'basemap-terrain'
	},
	{
		alias: 'Night',
		basemapURL: 'http://{s}.tiles.mapbox.com/v3/spatialdev.map-c9z2cyef/{z}/{x}/{y}.png',
		state: false,
		defaultMap: false,
		mapLayer : null,
		vendor: 'MapBox',
		thumbnailClass: 'basemap-night'
	},
	];


_SPDEV.MapsControl.ContextualLayers = {};

//_SPDEV.MapsControl.ContextualLayers.data = [
//	
//	{
//		alias: 'Total Poblacion 2001',
//		serviceURL: 'http://54.227.245.32:8080/geoserver/oam/wms',
//		layers: 'oam:Total_Poblacion_2001',
//		state: false,
//		mapLayer : null,
//		format: 'img/png',
//   	transparent: true,
//		type: "WMS",
//		mapServer: 'GeoServer',
//		showLegend: true,
//		
///	},
//		{
//		alias: 'Total Poblacion 2010',
//		serviceURL: 'http://54.227.245.32:8080/geoserver/oam/wms',
//		layers: 'oam:Total_Poblacion_2010',
//		state: false,
//		mapLayer : null,
//		format: 'img/png',
 //   	transparent: true,
//		type: "WMS",
//		mapServer: 'GeoServer',
//		showLegend: true,
//	},
//		{
//		alias: 'Percent Extreme Pobreza',
//		serviceURL: 'http://54.227.245.32:8080/geoserver/oam/wms',
//		layers: 'oam:Percent_Extreme_Pobreza',
//		state: false,
//		mapLayer : null,
//		format: 'img/png',
 //   	transparent: true,
//		type: "WMS",
//		mapServer: 'GeoServer',
//		showLegend: true,
//	},


//];



// Initialization
_SPDEV.MapsControl.ContextualLayers.init = function(map, appendToEl, appendLegendTo, dg) {
	
	// Create a Backbone collection ohbject
	var coll = new _SPDEV.LeafletOverlays.Collection();
		//var coll = new _SPDEV.LBasemapSwitcher.Collection({'map': map});
	
	// Fill the collection with the data array
	coll.init(map, _SPDEV.DataSources.ContextualLayers[dg]);
	
	// Create a Backbone Collection View that serves as the WMS checkbox list
	var collView = new _SPDEV.LeafletOverlays.SelectionListCollectionView({'collection': coll});
	
	// render that collection view
	collView.render();
	
	// Append the view to the DOM
	$(appendToEl).append(collView.el);
	
	// Create a Backbone Collection View that holds all the legends for the WMS in the collection (all legends hidden on load) 
	legCollView = new _SPDEV.LeafletOverlays.LegendCollectionView({'collection': coll});
	
	// render the collection view
	legCollView.render();
	
	legCollView.$el.prepend('<header><div class="collapser opend" id="legend_label">LEYENDA</div></header>');
	
	// Append the legend collection view to the DOM
	$(appendLegendTo).append(legCollView.el);
	
	return collView.el;

};