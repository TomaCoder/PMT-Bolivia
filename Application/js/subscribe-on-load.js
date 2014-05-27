/**
 * @author Rich Gwozdz
 */


_SPDEV.subscribeOnLoad = function(){
		
	amplify.subscribe('waitingForData', function(){
		// Show the loading div
		$(_SPDEV.Config.APP_LOADER).show();
	});
	
	amplify.subscribe('dataRetrieved', function(){

	    
	    _SPDEV.Layout.setLanguage();	// Change text based on language.
	    // Hide the loading div
	    $(_SPDEV.Config.APP_LOADER).hide();
		
	});
	
	
};

	