_SPDEV.Config = {};
_SPDEV.Config.ControlPanel = {};
_SPDEV.Config.ControlPanel.SECTION_HEADER = '<div class="clearfix section-header"><div class="label">###label###</div></div>';

_SPDEV.loadApp = function(dg){
	
	// Do layout stuff for main page
	_SPDEV.Layout.init();
	_SPDEV.DownloadBtn.init();
	
	_SPDEV.DataSources.Data.Gov = _SPDEV.DataSources.DataGroups[dg];
	//_SPDEV.DataSources.Data.Donor.COUNTRY_IDS = _SPDEV.DataSources.Data.Gov.COUNTRY_IDS;
	$('#locationButton').html(dg.toString().toUpperCase());

	
	_SPDEV.subscribeOnLoad();
	
	//Build map
	_SPDEV.map = new L.Map("mapDiv", {
								'scrollWheelZoom': false,
								'attributionControl': true
								});
	// Set map view
	_SPDEV.map.setView(new L.LatLng(_SPDEV.DataSources.Data.Gov.initialMapView.lat, _SPDEV.DataSources.Data.Gov.initialMapView.lng), _SPDEV.DataSources.Data.Gov.initialMapView.zoom);
	
	
	
	// Add Basemaps
	var mapsControl = _SPDEV.MapsControl.init(_SPDEV.map, '#controls', _SPDEV.Config.ControlPanel.SECTION_HEADER.replace('###label###', 'MAPS'), '#mapView', dg.toString());
	
	/* if(dg == 'Malawi') {
		
		$(mapsControl.contextLayersMenu).prev().hide();
		$(mapsControl.contextLayersMenu).hide();
	} */
	// Add DataSources
	_SPDEV.DataSources.init(_SPDEV.map, '#controls');
	
	_SPDEV.infobox = new _SPDEV.Infobox.Manager('#mapView');
	
	// Grant ADD ... not really sure where this should go
	
	    $('#uploadIATI').on('click', function() { _SPDEV.Upload.createForm(); });
	    $('#uxLogin_email').val('username').css('font-style','italic');
	    $('#uxLogin_pass').val('password');
	    $('#uxLogin_email').on('focus', function() { $(this).val("").css('font-style','normal').css('color','#666666'); });
	    $('#uxLogin_pass').on('focus', function() { $(this).val(""); });
	    $('#uxLogin_pass').on('keypress', function(e) {
		if (e.keyCode == 13) {
			    $('#uxLogin_submit').click();
		}
	    });
	    $('#uxLogin_email').on('keypress', function(e) {
		if (e.keyCode == 13) {
			    $('#uxLogin_submit').click();
		}
	    });
	    $('#uxLoginForgot').on('click', _SPDEV.Login.forgotPassword);
	  //  $('#edit_sector').on('click', function() {
		//var win=window.open("sector_editor.php", '_blank');
		//win.focus();
	//    });
	    
	// $('#uxLoginRegistration').on('click', _SPDEV.Login.registration);
	
};

$(document).ready(function(){
	
	var langFile;
	
	//parse querystring if any
	var url = document.URL;
	var queryPars = $.parseParams( url.split('?')[1] || '' );
	
	queryPars.dg = 'Bolivia';

	if(typeof queryPars.dg === 'undefined') {
		window.location = './index.php';
		return;
	} else if (typeof _SPDEV.DataSources.DataGroups[queryPars.dg] === 'undefined') {
		window.location = './index.php';
		return;
	}
	
	$('#uxLogin_country').val(queryPars.dg);
	$('#uxLogout_country').val(queryPars.dg);

	if(queryPars.dg === 'Bolivia') {
		langFile = "js/lang/es.json";
	} else {
		langFile =  "js/lang/en.json";
	}
	
	$.getJSON( langFile, function( data ) {
		_lang = data;
		
		_SPDEV.loadApp(queryPars.dg);
	});
	
});

