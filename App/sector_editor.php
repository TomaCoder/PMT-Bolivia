  <!-- =====================================================
  @author = Grant McKenzie (gmckenzie@spatialdev.com
  @date = January 2014
  @client = World Bank Open Aid Partnership
  @functionality = Main file for the Sector Editor (HTML/PHP)
  =========================================================== -->
 <?php 

	ini_set("session.cookie_httponly", 1);
	session_start();
	
	if (isset($_SESSION['oamuser'])) {
		require_once 'php/user.inc';
		$oamuser = unserialize($_SESSION['oamuser']);
		echo "<script>var _oamuser='".json_encode($oamuser)."';</script>";
	} else {
	    //if(strpos($_SERVER['PHP_SELF'], "application.php") == 0)
		header('Location: index.php', true, 302);
	}

 ?>
  <!DOCTYPE html>
  <!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
  <!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
  <!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
  <!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
      <head>
	  <meta charset="utf-8">
	  <meta http-equiv="X-UA-Compatible" content="IE=edge">
	  <title>World Bank - Open Aid Map</title>
	  <meta name="description" content="">
	  <meta name="viewport" content="width=device-width, initial-scale=1">
	  <link href="oamfavicon32.ico" rel="shortcut icon" type="image/x-icon">
	  
	  <!--CSSMIN-BEGIN-->
	  <link rel="stylesheet" href="css/main.css">
	  <!--CSSMIN-END-->
	  <link rel="stylesheet" href="sector_editor/css/sector_editor.css">
	  
	  <script src="js/vendor/modernizr-2.6.2.min.js"></script>
	  <script>
		  var _SPDEV = {};
	  </script>
      </head>
      <body>
	<div id="loading_bg"></div>
	<div id="loading_main"><p>Loading...</p><div><img src="img/loading.gif"></div></div>
	<?php include_once('sector_editor/header.inc'); ?>
	<!-- Main Body -->
	<div class="tabhead"><span class="titles" id="se_tab_head"></span></div>
	<div class="tabwrapper">
	    <div class="se_col head"><span class="titles" id="se_col_head1"></span></div>
	    <div class="se_col head"><span class="titles" id="se_col_head2"></span></div>
	    <div id="se_sectors"></div>
	</div>
	<div class="se_wrapper_chooser">
	  <div class="head" id="se_chooser_head"></div>
	  <div class="content inactive" id="se_chooser_content"></div>
	  <div id="assign">ASSIGN THIS IATI SECTOR</div>
	  <div id="alldone">SUBMIT CHANGES</div>
	</div>
	<!-- End Main Mody -->
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
	<script src="js/utilities.js"></script>
	<script src="sector_editor/js/main.js"></script>
      </body>
  </html>