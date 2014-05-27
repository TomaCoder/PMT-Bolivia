_SPDEV.FrontBuilder = {};

_SPDEV.FrontBuilder.init = function(){
	
	var pathArray = window.location.pathname.split( '/' );
	var thisPage = pathArray[pathArray.length-1];
	
	$.get("partials/header.html", function(data){ 
		var theHeader = $(data);
		//if (thisPage == "news.html"||thisPage == "partnership.html"){
			//theHeader.find('#locationMenu').remove();
		//}
		$('body').prepend(theHeader);
		
		
	});
	
	$.get("partials/footer.html", function(data){ 
		$('body').append(data);
	});
};


