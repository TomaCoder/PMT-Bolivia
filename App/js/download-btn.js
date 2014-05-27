_SPDEV.DownloadBtn = {};

_SPDEV.DownloadBtn.init = function(){
	$('#downloadBTN').on('click', function() {
		$('#emailError').empty();
		$('.downloadElement').slideDown("fast");
	});
	$('#download_submit').on('click', function() {
		var filters = _SPDEV.DownloadBtn.getFilters();
		filters.unassignedTaxIds = "";
		var email = $('#download_email').val();
		// regular expression to validate the email address
        var reg = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;
        // try to validate the email
        if (reg.test(email) == false) {
          $('#emailError').html('Email address is invalid.');
          return;
        }
        filters.email = email;
		_SPDEV.DownloadBtn.SendExportRequest(filters);
	});
	$('#download_cancel').on('click', function(){
		$('.downloadElement').slideUp("fast");
		$('#formElements').show();
		$('#dataProcessing').hide();
	});
	$('#download_ok').on('click', function(){
		$('.downloadElement').slideUp("fast", function(){
    		$('#downloadText').hide();
    		$('#formElements').show();
    	});
	});
};

_SPDEV.DownloadBtn.getFilters = function(){
	var scrape_filters;
	_.each(['Donor','Gov'], function(source){
		if (this[source].isActive) {
			scrape_filters = this[source].filterStore.scrapeUpFilters(true);
		};
	}, _SPDEV.DataSources.Data);
    return scrape_filters;
}

_SPDEV.DownloadBtn.SendExportRequest = function(exportFilters){        
    $('#formElements').hide();
	$('#dataProcessing').show();        
    //console.log(exportFilters);
    $.ajax({
        type: 'POST',
        data: exportFilters,
        dataType: 'json',
        url: 'php/dataDownload.php',
        success: function(data, textResponse, jqXHR){
            $('#dataProcessing').hide();
            if (data.pmt_filter_iati== 't') {
            	var exportMessage = $('<h2>DATA HAS BEEN EMAILED</h2><p>Email may take several minutes to arrive</p>');
                $('#exportMessage').html(exportMessage);
            	$('#downloadText').show();
            } else {
            	var exportMessage = $('<h2>NO DATA TO EXPORT</h2><p>Make sure there are data on the map prior to export</p>');
                $('#exportMessage').html(exportMessage);
                $('#downloadText').show();
            }
            
        },
        error: function(jqXHR, textStatus, errorThrown){
        	$('#dataProcessing').hide();
        	var exportMessage = $('<h2>DATA EXPORT FAILED</h2><p>Site admin has been notified</p>');
            $('#exportMessage').html(exportMessage);
            $('#downloadText').show();
            //console.log(jqXHR);
        }
        
    });
    return false;
}