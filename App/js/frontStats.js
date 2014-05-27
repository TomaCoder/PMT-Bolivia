_SPDEV.FrontStats = {};

_SPDEV.FrontStats.init = function(){
	
	var quickStats = null;
	var statsURL = "php/getQuickStats.php";
	$.ajax({
	  url: statsURL,
	  dataType: 'JSON',
	  type: 'GET',
	  async: false,
	  success: function(data) {

	    $('#qsSector1Cnt').html(data[0].cnt);
	    $('#qsSector1Name').html(data[0].name);
	    
	    $('#qsSector2Cnt').html(data[1].cnt);
	    $('#qsSector2Name').html(data[1].name);
	    
	    $('#qsSector3Cnt').html(data[2].cnt);
	    $('#qsSector3Name').html(data[2].name);
	    
	    $('#qsSector4Cnt').html(data[3].cnt);
	    $('#qsSector4Name').html(data[3].name);

	  },
	  error: function(jqXHR, errorThrown) {
	    console.log('error...');
	    console.log(jqXHR);
	    console.log(errorThrown);
	  }
	});
	
};
