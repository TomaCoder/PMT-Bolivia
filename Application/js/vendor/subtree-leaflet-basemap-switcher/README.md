leaflet-basemap-switcher
========================

Switch among a collection of basemaps.  Uses a Backbone collection to store basemaps, and Backbone views to determine how to display the list of basemaps to choose from.  Override the Model and Collection view html templates and CSS to alter the look/styling of the basemap selection list. 


Note: if u want to add a Bing basemap, you will need to extend your Leaflet codebase with this https://github.com/spatialdev/leaflet-bing-layer.

Usage:

	// Create a Backbone collection ohbject
	var coll = new _SPDEV.LBasemapSwitcher.Collection({'map': map});
	
	// Fill the collection with the data array
	coll.initialize(_SPDEV.Basemaps.data);
	
	// Create a Backbone Collection View that serves as the WMS checkbox list
	var collView = new _SPDEV.LBasemapSwitcher.SelectionListCollectionView({'collection': coll});
	
	// Set the default basemap as the active basemap
	coll.setDefault();
	
	// render that collection view
	collView.render();
	
	// Append the view to the DOM
	$('#basemapsList').append(collView.el);
		
	
	
	_SPDEV.Basemaps.data = [
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
