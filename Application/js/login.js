_SPDEV.Login = {};
_SPDEV.Login.user = {};

// function is called on "LOG IN" button click
/*
_SPDEV.Login.authenticate = function () {
    $('#uxLogin_submit').html('<img src="img/loading-mini.gif"/>');	
    var postData = {'email': $('#uxLogin_email').val(), 'password': $('#uxLogin_pass').val()};
    $.ajax({
	    'type': 'POST',
	    'data': postData,
	    'dataType': "json",
	    'url': 'php/login_salted.php',
	    'success': function(data){
		if (data.status != 200) {
		    $('#uxLogin_submit').html('LOG IN');
		} else {
		   _SPDEV.Login.user = data.data;
		   $('#login').unbind('click');
		   $('#login').html("LOGOUT");
		   $('#login').on('click', _SPDEV.Login.logout);
		   $('#wrapperLogin').toggle();
		   $('#uploadIATI').fadeIn();
		   $('#edit_sector').fadeIn();
		   $('#uxLogin_submit').html('LOG IN');
		}
	    },		  
	    'error': function(response) {
		  $('#uxLogin_submit').html('LOG IN');
		  console.error(response);
		  
	    }
    });

  };
  */
// Toggle the login drop down
_SPDEV.Login.loginToggle = function() {
    $('#wrapperLogin').toggle();
};

_SPDEV.Login.forgotPassword = function() {
    // Dynamically generate the content for the "upload form"
    var content = '<div id="wrapperLoginForgot" class="upload_form" style="text-align:justify;height:170px">'+_lang.login_forgot+'<br/><br/>' +
	'<input class="login_forgot" id="uxLogin_forgot_email" type="text" value="" />' +
	'<div class="login_forgot_submit" id="uxLogin_forgot_submit">SUBMIT</div>' +
	'<br/><div class="sub_notes">'+_lang.login_needhelp+' <a href="mailto:info@spatialdev.com">'+_lang.login_mailto+'</a></div>' +
	'<div id="wrapperLoginForgot_close" class="upload_close"></div></div>';
    $('#viewContent').append(content);
    $('#uxLogin_forgot_email').focus();
    // Add "close button"
    $('#wrapperLoginForgot_close').on('click', function() { 
      $('#wrapperLoginForgot').fadeOut(); 
    });
    $('#uxLogin_forgot_submit').on('click', function() { 
      $('#wrapperLoginForgot').html(_lang.login_forgot_thankyou + '<div id="wrapperLoginForgot_close" class="upload_close">'); 
          $('#wrapperLoginForgot_close').on('click', function() { $('#wrapperLoginForgot').fadeOut(); });
    });
    
};

_SPDEV.Login.registration = function() {
    // Dynamically generate the content for the "upload form"
    var content = '<div id="wrapperLoginRegistration" class="upload_form">'+_lang.login_register+'<br/><br/>' +
	'<input class="long login_forgot" id="uxLogin_forgot_email" type="text" value="First Name" />' +
	'<input class="long login_forgot" id="uxLogin_forgot_email" type="text" value="Last Name" />' +
	'<input class="long login_forgot" id="uxLogin_forgot_email" type="text" value="Username" />' +
	'<input class="long login_forgot" id="uxLogin_forgot_email" type="text" value="Email Address" />' +
	'<input class="long login_forgot" id="uxLogin_forgot_email" type="text" value="Organisation" />' +
	'<div class="login_forgot_submit" id="uxLogin_forgot_submit" style="float:right">REGISTER</div>' +
	'<br/><div class="sub_notes" style="clear:both;">'+_lang.login_needhelp+' <a href="mailto:info@spatialdev.com">'+_lang.login_mailto+'</a></div>' +
	'<div id="wrapperLoginForgot_close" class="upload_close"></div></div>';
    $('#viewContent').append(content);
    
    $('.login_forgot').on('focus', function() { $(this).val(""); });
    
    // Add "close button"
    $('#wrapperLoginRegistration_close').on('click', function() { $('#wrapperLoginRegistration').fadeOut(); });
    
    $('#uxLogin_forgot_submit').on('click', function() { 
      $('#wrapperLoginRegistration').html("todo" + '<div id="wrapperLoginRegistration_close" class="upload_close">'); 
      $('#wrapperLoginRegistration_close').on('click', function() { $('#wrapperLoginRegistration').fadeOut(); });
    });  
};

/*
_SPDEV.Login.logout = function() {
    $.ajax({
	    'type': 'POST',
	    'dataType': "json",
	    'url': 'php/logout.php',
	    'success': function(data){
		if (data.response == "t") {
		     $('#login').html("LOGIN");
		     $('#login').unbind('click');
		     $('#uploadIATI').hide();
		     $('#edit_sector').hide();
		     $('#upload_form').hide();
		     $('#uxLogin_email').val('username').css('font-style','italic');
		     $('#uxLogin_pass').val('password');
		     $('#login').on('click', _SPDEV.Login.loginToggle);
		} 
	    },		  
	    'error': function(response) {
		  console.error(response);
	    }
    });
}; */