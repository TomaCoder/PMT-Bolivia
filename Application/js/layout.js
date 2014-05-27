_SPDEV.Layout = {};

_SPDEV.Layout.init = function(){

	
	_SPDEV.LayoutStretches = [];
	
	var mapViewWidth = new _SPDEV.Utilities.StretchMe($('#mapDiv'), $('#mapView'), 'height');
	var mapViewHeight = new _SPDEV.Utilities.StretchMe($('#mapDiv'),$('#mapView'), 'width');
	
		
	// Build tabs
	_SPDEV.Utilities.Tabs('#mapListTabs > ul', '#viewContent', function(){
		
		if($('#listView').is(":visible")){
			amplify.publish('listViewVisible');
		} else {
			amplify.publish('mapViewVisible');
		}
		
		mapViewHeight.stretch();
		mapViewWidth.stretch();
		
		// TODO: remove global
		_SPDEV.map.invalidateSize();
		
	});	
	

	_SPDEV.Config.APP_LOADER = $('#appBlocker');
	_SPDEV.Config.CONTROL_PANEL = $('#controlPanel');
	_SPDEV.Config.CONTROLS = $('#controls');
	
	_SPDEV.Layout.controlPanelResize();
	
	$(window).resize(function(){
		
		_SPDEV.Layout.controlPanelResize();
	});
	
	$('#controlPanel > header').on('click', function(){
		var self = this;
		$('#controls').slideToggle(function(){
			$(self).toggleClass('opened');
		});
	});
	
//	$('#uxLogin_submit').on('click', _SPDEV.Login.authenticate);
	
	/*
	if(typeof _oamuser != 'undefined') {
	    _oamuser = jQuery.parseJSON(_oamuser);
	    $('#login').html("LOGOUT");
	    $('#uploadIATI').fadeIn();
	    $('#edit_sector').fadeIn();
	    $('#login').unbind('click');
	    $('#login').on('click', _SPDEV.Login.logout);
	} else {
	    $('#login').html("LOGIN");
	    $('#login').unbind('click');
	    $('#login').on('click', _SPDEV.Login.loginToggle);
	}
	*/

    $('#logout').on('click', _SPDEV.Login.logout);
    $('#login').on('click', _SPDEV.Login.loginToggle);

	$('#viewHelpClose').on('click', function(){
    
        $('#wrapperViewHelp').hide();
    
    });
	
    $('#viewHelpTrigger').on('click', function(){
    
        $('#wrapperViewHelp').show();
    
    });
	
	$('#viewHelpClusterLabel').html(_lang.helper_cluster_label);
	$('#viewHelpClusterText').html(_lang.helper_clusters);
	$('#viewHelpViewLabel').html(_lang.helper_view_label);
	$('#viewHelpViewText').html(_lang.helper_views);
	
};

_SPDEV.Layout.controlPanelResize = function(){
	
	var controlP = _SPDEV.Config.CONTROL_PANEL;
	var controls = _SPDEV.Config.CONTROLS;
	
	var cpMaxHeight = $(controlP).offsetParent().height() - $(controlP).position().top - parseInt($(controlP).css('margin-bottom'), 10);
	
	$(controls).css('max-height', cpMaxHeight - $(controls).position().top);
	
	var h = parseInt($(controls).css('max-height'),10) - $(controlP).find('div.section-header:visible').length * ($(controlP).find('.section-header:visible').outerHeight(true)+10);

	$(controlP).find('ul.selection-list').css({'max-height': h});
	$(controlP).find('div.contents-wrapper').css({'max-height': h});
};

_SPDEV.Layout.setLanguage = function() {
 
  $('#menu_associations').html(_lang.header_associations);
  $('#menu_news').html(_lang.header_news);
  $('#header_country').html(_lang.country_boliva);
  $('#mapViewTab').html(_lang.mapViewTab);
  $('#listViewTab').html(_lang.listViewTab);
  $('#controlPanelCollapser').html(_lang.hide);
  $('.data-control-section > .clearfix.section-header > .label')[1].innerHTML = _lang.fundor;
  $('#chartsControl > .clearfix.section-header > .label').html(_lang.main_chart_title);
  $('#mapsControl > .clearfix.section-header > .label').html(_lang.mapViewTab);
  $('#legend_label').html(_lang.legend);
  $('#wms_name_label').html(_lang.wms_name);
  $('#wms_url_label').html(_lang.wms_url);
  $('#wms_layer_label').html(_lang.wms_layer);
  $('#wms_submit').html(_lang.wms_submit);
  $('#wms_dialog_title').html(_lang.wms_dialog_title);
  $('#footercopyright').html(_lang.copyright);
  $('#infoBoxPanelCollapser').html(_lang.hide);
  $('.allNone > a').each(function() {
      $(this).text(_lang.allnone);
  });
  $('#downloadBTN > span').html(_lang.download);
  $('#viewControl_donor').html(_lang.main_chart_dropdown1);
  $('#viewControl_gov').html(_lang.government);
  $('.listviewheadertitle')[0].innerHTML = _lang.name;
  $('.listviewheadertitle')[1].innerHTML = _lang.implementor;
  //$('.listviewheadertitle')[3].innerHTML = _lang.name;
  //$('.listviewheadertitle')[4].innerHTML = _lang.fundor;
  $('#controlPanel > header > span').text(_lang.hide);
  $('#uploadIATI').html(_lang.upload);
  $('#edit_sector').html(_lang.se_editsector_button);
};
