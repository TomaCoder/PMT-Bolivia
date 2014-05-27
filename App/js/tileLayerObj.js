/*
 * @author = Grant McKenzie
 * @description = Tile Layer Object
 * @date = 08/2013
 * Use this file add in additional WMS contextual layers
*/

// _SPDEV.Map.map should be replaced with whatever var contains your map object.

  var _tileLayers = {};
  _tileLayers.layers = {};
  _tileLayers.legendOn = false;

  // Add new layer to layers array of object.
  _tileLayers.createLayer = function(url, layer, name) {
      var l = {};
      l.name = name;
      l.click = "_tileLayers.oneAtATime('"+layer+"');";
      l.url = layer
      l.layer = new L.TileLayer.WMS(url, { layers: layer, format: 'image/png', transparent: true, attribution: ""});
      l.legend = url+"?request=GetLegendGraphic&Version=1.0.0&format=image/png&layer="+layer;
      this.layers[layer] = l;
  }

  // Fully delete layer from the layers array
  _tileLayers.deleteLayer = function(id) {
      delete _tileLayers.layers[id];
  }

  // Add the selected layer to the map
  _tileLayers.showLayer = function(id) {
      _SPDEV.Map.map.addLayer(_tileLayers.layers[id].layer);
      
  }

  // Remove the selected layer from the map
  // Called from line 107 of controlDialog.js
  _tileLayers.hideLayer = function(id) {
      _SPDEV.Map.map.removeLayer(_tileLayers.layers[id].layer);
      this.legendOn = false;
  }

  // Turn off all layers excepted the selected one.
  // Called from line 114 of controlDialog.js
  _tileLayers.oneAtATime = function(id) {
      $.each(_tileLayers.layers, function(key, val) {
	  if (key == id) {
	      _SPDEV.Map.map.addLayer(_tileLayers.layers[id].layer);
	      _tileLayers.updateLegendUX(val.legend);
	  } else {
	    _SPDEV.Map.map.removeLayer(_tileLayers.layers[key].layer);
	  }
      });
      this.legendOn = true;
  }

  // Dynamically generate the checkboxes for turning the layers on and off.  This is called from controlDialog.js
  // Input: id of container DIV.
  _tileLayers.generateTC = function(divid) {
      var h = '<ul>';
      $.each(_tileLayers.layers, function(key, val) {
	h += "<li class='indicator chkbx unchecked' id='"+key+"'>"+val.name+"</li>";
      });
      h += '</ul>';
      $('#'+divid).html(h);
  }

  _tileLayers.updateLegendUX = function(legend) {
      var img = "<img src='"+legend+"' alt='Legend' title='Map Legend' />";
      $('#legendContent').html(img);
  }

  // The basic input layers.
  function newTileLayers() {
    
    //Input: Server URL (excluding endpoint), layer name, human readable name
    _tileLayers.createLayer("http://54.227.245.32:8080/geoserver/oam/wms","oam:Total_Poblacion_2001","Total Poblacion 2001");
    _tileLayers.createLayer("http://54.227.245.32:8080/geoserver/oam/wms","oam:Total_Poblacion_2010","Total Poblacion 2010");
    _tileLayers.createLayer("http://54.227.245.32:8080/geoserver/oam/wms","oam:Percent_Extreme_Pobreza","Percent Extreme Pobreza");

    
  }
  
  function toggleWMS() {
      $('#wms_name').val("");
      $('#wms_url').val("http://");
      $('#wms_layer').val("");
      $('#wmsDialog').show();
  }
  
  function addWMSLayer() {
      var name = $('#wms_name').val();
      var url = $('#wms_url').val();
      var layer = $('#wms_layer').val();
      if (name.length < 1) {
	  alert(_lang.wms_alert_name);
      } else if (url.length < 9) {
	  alert(_lang.wms_alert_url);
      } else if (layer.length < 1) {
	  alert(_lang.wms_alert_layer);
      } else {
	_tileLayers.createLayer(url,layer,name);
	_tileLayers.generateTC("contextualLayers");
      }
  }

  _tileLayers.checkLegend = function() {
    if(!$('#listViewContainer').hasClass('cloak') && this.legendOn)
	 $('#legend').hide();
    else if ($('#listViewContainer').hasClass('cloak') && this.legendOn)
	 $('#legend').show();
  }
  
  
  
  
  
