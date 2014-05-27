/* ============================================
 * @author = gmckenzie@spatialdev.com
 * @date = January 2013
 * @client = World Bank / Open Aid Partnership
 * @functionality = IATI Upload Javascript
 * ========================================= */

_SPDEV.Upload = {};

_SPDEV.Upload.createForm = function() {
  
    // Dynamically generate the content for the "upload form"
    var content = '<div id="upload_form" class="upload_form" style="text-align:justify">'+_lang.uploadtext+'<br/><br/>' +
	'<form method="post" enctype="multipart/form-data"  action="php/uploadIATI.php">' +
	'<input type="file" name="upload_iati_file" id="upload_iati_file" multiple />' +
        '<button type="submit" id="upload_btn">Upload</button>' +
	'</form><div id="upload_response" style="text-align:center;width:100%;margin-top:5px">' +
	'</div><div id="upload_close" class="upload_close"></div></div>';
    $('#viewContent').append(content);
    
    // Add "close button"
    $('#upload_close').on('click', function() { $('#upload_form').fadeOut(); });
    
    // Make sure we aren't dealing with an old (unsupported) browser
    var formdata = false;
    if (window.FormData) {
      formdata = new FormData(); 
      $('#upload_btn').hide();
    } 
   
    // Once the user chooses a FILE for data upload do the following
    $('#upload_iati_file').change(function (evt) {
	    // Add loading GIF
	    $("#upload_response").html("<img src='img/loading.gif'/>");
	    var img, reader, file;
    
	    // We only want the first file (if multiple files are added)
	    file = this.files[0];

	    // Check the file time.  Only XML
	    if (file.type = "text/xml") {
		if ( window.FileReader ) {
			reader = new FileReader();
			reader.onloadend = function (e) { 
				// showUploadedItem(e.target.result, file.fileName);
			};
			reader.readAsDataURL(file);
		}
		if (formdata) {
			formdata.append("iati", file);
		}
	    } else {
		// Tell the users if the file is not in XML format
		$("#upload_response").html(_lang.upload_notiati); 
	    }
    
	    // Make sure we have form data.
	    if (formdata) {
	      // Hide the upload button and file input
	      $('#upload_iati_file').hide();
	      
	      // The url requires you submit a country via REST.
	      var url = "php/uploadIATI.php";
	      $.ajax({
			  url: url,
			  type: "POST",
			  data: formdata,
			  processData: false,
			  contentType: false,
			  success: function (res, textStatus, jqXHR) {
			      if (res == "1" || res == 1) {
				  $("#upload_response").html(_lang.upload_success); 
			      } else {
				  $("#upload_response").html(_lang.upload_error);
			      }
			      // Ask the user to refresh the page one data is finished loading
			      var btn = "<button id='btn_reload' onclick='location.reload();'>"+_lang.refresh_page+"</button>";
			      $("#upload_response").append("<br/>"+btn); 
			  },
			  error: function(jqXHR, textStatus, errorThrown){

			  }
	      });
	    }
    });
 
}
