// Namespace
_SPDEV.ContextualLayers = {};

_SPDEV.ContextualLayers.data = [
	
	{
		alias: 'SERVIR TRMM 7 Day',
		serviceURL: 'http://ags.servirlabs.net/ArcGIS/services/ReferenceNode/TRMM_7DAY/MapServer/WMSServer',
		layers: '0',
	    format: 'img/png',
    	transparent: true,
		state: false,
		mapLayer : null,
		type: "WMS",
		mapServer: 'ArcGIS',
		showLegend: false
	},
	{
		alias: 'SRTM_90',
		serviceURL: 'http://ags.servirlabs.net/ArcGIS/services/ReferenceNode/Basemaps_SRTM_90/MapServer/WMSServer',
		layers: '0',
	    format: 'img/png',
    	transparent: true,
		state: false,
		mapLayer : null,
		type: "WMS",
		mapServer: 'ArcGIS',
		showLegend: true
	},
	{
		alias: 'MODIS Landcover Type1 2009',
		serviceURL: 'http://ags.servirlabs.net/ArcGIS/services/ReferenceNode/MODIS_Landcover_Type1_2009/MapServer/WMSServer',
		layers: '0',
	    format: 'img/png',
    	transparent: true,
		state: false,
		mapLayer : null,
		type: "WMS",
		mapServer: 'ArcGIS',
		showLegend: true
	}
	
];

// Initialization
_SPDEV.ContextualLayers.init = function(map) {
	
	// Create a Backbone collection ohbject
	var coll = new _SPDEV.LeafletOverlays.Collection();
	
	// Fill the collection with the data array
	coll.init(map, _SPDEV.ContextualLayers.data);
	
	// Create a Backbone Collection View that serves as the WMS checkbox list
	var collView = new _SPDEV.LeafletOverlays.SelectionListCollectionView({'collection': coll});
	
	// render that collection view
	collView.render();
	
	// Append the view to the DOM
	$('#ataContextLayerItem').append(collView.el);
	
	
	// Hide the WMS list (optional)
	//collView.$el.addClass('cloak');
	
	// Create a Backbone Collection View that holds all the legends for the WMS in the collection (all legends hidden on load) 
	var legCollView = new _SPDEV.LeafletWMSLayers.LegendCollectionView({'collection': coll});
	
	// render the collection view
	legCollView.render();
	
	// Append the legend collection view to the DOM
	$('#mapView').append(legCollView.el);

	
	
};

