$(document).ready(function(){
	
	_SPDEV.FrontBuilder.init();
	function getUrlVar(key){
		var result = new RegExp(key + "=([^&]*)", "i").exec(window.location.search); 
		return result && unescape(result[1]) || ""; 
	}
	var article = getUrlVar("article");	
	_SPDEV.FrontNews.init(true,article);
});

