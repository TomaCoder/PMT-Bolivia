  var _lang = {};
  _lang.urlParams = null;
  (window.onpopstate = function () {
      var match,
	  pl     = /\+/g,  // Regex for replacing addition symbol with a space
	  search = /([^&=]+)=?([^&]*)/g,
	  decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
	  query  = window.location.search.substring(1);

      _lang.urlParams = {};
      while (match = search.exec(query))
	_lang.urlParams[decode(match[1])] = decode(match[2]);
      
      
  })();
  
  // Add the appropriate language file based on the country.

  _lang.fileref=document.createElement('script');
  _lang.fileref.setAttribute("type","text/javascript");
  
  if (_lang.urlParams['dg'] == "Bolivia")
    _lang.fileref.setAttribute("src", "js/lang/es.js");
  else
    _lang.fileref.setAttribute("src", "js/lang/en.js");
    
  document.getElementsByTagName("head")[0].appendChild(_lang.fileref)