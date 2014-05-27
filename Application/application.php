
 <?php 
    session_start();

    //check to make sure the session variable is registered
    if (!isset($_SESSION['oamuser'])) {

       // Unset all of the session variables.
        $_SESSION = array();

        // If it's desired to kill the session, also delete the session cookie.
        // Note: This will destroy the session, and not just the session data!
        if (ini_get("session.use_cookies")) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000,
                $params["path"], $params["domain"],
                $params["secure"], $params["httponly"]
            );
        }

        // Finally, destroy the session.
        session_destroy();
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
        <title>Open Aid Map</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <link href="oamfavicon32.ico" rel="shortcut icon" type="image/x-icon">
             	<link rel="stylesheet" href="css/vendor/leaflet.css" />
     	<!--[if lte IE 8]><link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.4.5/leaflet.ie.css" /><![endif]-->
     	
     	<!--CSSMIN-BEGIN-->
        <link rel="stylesheet" href="css/main.css">
        <link rel="stylesheet" href="css/login.css">
        <!--CSSMIN-END-->
       
        <script src="js/vendor/modernizr-2.6.2.min.js"></script>

        <script>
        	var _SPDEV = {};
        </script>
    </head>
    <body>
        <!--[if lt IE 7]>
            <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
        <![endif]-->

        <!-- Add your site or application content here -->
		<header id="appHeader" class="clearfix">
			<div id="logo" class="">
				<a href="http://www.vipfe.gob.bo/" target="_blank"><img src="img/banner_blanco_VIPFE.png" alt="Open Aid Partnership" /></a>
			</div>
			
			<!-- Application navigation-->

		</header>
        
        <div id="wrapper0">
        	<nav id="mapListTabs">
        		<ul>
	        		<li id="mapViewTab" href="#mapView" class="active">MAP</li>
	        		<li id="listViewTab" href="#listView">LIST</li>
        		</ul>
        		<div id="downloadBTN" title="Download IATI"><span>DOWNLOAD</span><div class="downloadElement" id="downloadSpacer"></div></div>
        		<?php 
                    if (isset($_SESSION['oamuser'])) {
                        echo '<div id="uploadIATI" title="Replace existing data with new IATI File">UPLOAD IATI</div>
                        <a id="edit_sector" href="sector_editor.php" target="_self" title="Edit the Sector Values" >SECTOR EDITOR</a>';

                    }
                ?>
                <div  class="downloadElement" id="downloadFORM">
        		
                <div id="downloadFORM">
                    <div id="formElements">
                        <p>Enter e-mail address for IATI data delivery of current filters.</p>
                        <span id="emailError"></span>
                        <input id="download_email" type="text"/><br/>
                        <div class="downloadActions">
                            <div id="download_submit">SUBMIT</div>
                            <div id="download_cancel">CANCEL</div>
                        </div>
                    </div>
                    <div id="dataProcessing">
                        <h4>Processing<span class="ellipsis">...</span></h4>
                    </div>
                    <div id="downloadText">
                        <div id="exportMessage"></div>
                        <div id="download_ok">OK</div>
                    </div>
                    
                </div>
        		<div id="tabFoot"></div>
    		</nav>
        	<div id="viewContent">
        		<div id="mapView" class='tab-content'>
        			<div id="mapDiv"></div>
        			<div id="appBlocker" class="blocker wall-to-wall">
						<div id="onLoadSpinner" class="absolute-center" >
							<p>Loading...</p>
							<div><img src="img/loading.gif"></div>
						</div>
					</div>
        		</div>
        		<div id="listView" class='tab-content cloak'>
        			<div id="listViewloading"></div>
        		</div>
        		<div id="controlPanel">
	          		<header class="opened">
	            		<span></span>
	          		</header>
	          		<div id="viewControl">
					      <div class="viewControl_text" id="viewControl_donor"></div>
					      <div id="viewControl_toggle"></div>
					      <div class="viewControl_text VCactive" id="viewControl_gov"></div>
                        <div id="viewHelpTrigger"><img src="img/icon_info.png" /></div>
            		</div>
	          		<div id="controls">
	          			
	          		</div>
	        	</div>
        	</div>
        </div>
        
		<footer id="footerContainer" class="clearfix">
                <!-- <?php 
                    if (!isset($_SESSION['oamuser'])) {
                        echo '<div id="login" class="dropdown login">LOGIN</div>';
                    } else {
                        echo '<form action="php/logout.php" method="post"><input id="uxLogout_country" type="hidden" name="country" value="">
          <input type="submit"  id="logout" class="dropdown login" value="LOGOUT" /></form>';
                    }
                ?> -->
            
            <div id="footercopyright"></div>

            
        </footer>
		
		
		<form id="wrapperLogin" action="php/login_salted.php"  method="post">
		  <div class="user"></div><input class="txtfield" id="uxLogin_email" name="email" type="text" value="" />
		  <div class="pass"></div><input class="txtfield" id="uxLogin_pass" name="password" type="password" value="" AUTOCOMPLETE="off"/>
		  <input type="submit" class="submit" id="uxLogin_submit" value="LOG IN"/>
          <input id="uxLogin_country" type="hidden" name="country" value="">
		  <div class="sub_notes" id="uxLoginForgot">Forgot password?</div>
		  <!-- <div class="sub_notes right" id="uxLoginRegistration">Registration</div> -->
		</form>
		
            <div id="wrapperViewHelp" class="blocker wall-to-wall">
						<div id="viewHelp" class="absolute-center" >
                            <div id="viewHelpClose" class="icon-close-01"></div>
                            <h3 id="viewHelpViewLabel">Views</h3>
                            <p id="viewHelpViewText">Switching between 'Country System' and 'Donor System' allows you to view development assistance data as                                  reported in country systems/databases (in terms of what they receive) and in donor systems/databases (in                                terms of what they give). While these data should match in theory, significant discrepancies currently                                  exist due to lack of reporting or differences in reporting practices.</p>
                            <div class="clearfix">
                                <h3 id="viewHelpClusterLabel">Map CLusters</h3>
                                <div id="viewHelpCluster">
                                    <img alt="Map cluster" title="Map cluster" src="img/clusterHelp.png"/>    
                                </div>
                                <div id="viewHelpClusterText">
                                    <p>Map clusters represent groups of points that are close together with respect to the current zoom level of the map. The number in the center indicates the number of point locations clustered. Note that activites are composed of one or more locations.  Thus a cluster number may not be equal to the number of activites linked to a given cluster.</p>
<p>The color wheel on the around the border of the cluster is visual summary of the sectors assigned to the point locations within a cluster.</p>
                                </div>
                            </div>
                        </div>
                </div>
		
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.10.2.min.js"><\/script>')</script>
        <!--<script src="js/lang/lang.js"></script>-->
        <!--JSMIN-BEGIN-->
        <script src="js/vendor/amplify.min.js"></script>
	    <script src="js/vendor/leaflet.js"></script>
	    <script src="js/vendor/underscore-min.js"></script>
	    <script src="js/vendor/backbone-min.js"></script>
	    <script src="js/vendor/json2.js"></script>
	    <script src="js/vendor/d3.min.js"></script>
	    <script src="js/vendor/subtree-leaflet-overlays/leaflet-overlays.js"></script>
	    <script src="js/vendor/subtree-leaflet-bing-layer/leaflet-bing-layer.js"></script>
	    <script src="js/vendor/subtree-leaflet-basemap-switcher/leaflet-basemap-switcher.js"></script>
	    <script src="js/vendor/subtree-quick-cluster/q-cluster.js"></script>        
	    <script src="js/vendor/subtree-quick-cluster/q-cluster-leaflet-layer.js"></script>
	    <script src="js/login.js"></script>
	    <script src="js/iati-upload.js"></script>
	    <script src="js/utilities.js"></script>
	    <script src="js/layout.js"></script>
	    <script src="js/subscribe-on-load.js"></script>
	    <script src="js/filter-selection-store.js"></script>
	    <script src="js/facet-filter.js"></script>
	    <script src="js/list-view.js"></script>
	    <script src="js/login.js"></script>
	    <script src="js/locations.js"></script>
	    <script src="js/data-sources.js"></script>
	    <script src="js/activity-chart.js"></script>
	    <script src="js/maps-control.js"></script>
	    <script src="js/infobox.js"></script>
	    <script src="js/download-btn.js"></script>
	    <script src="js/main.js"></script>
		<!--JSMIN-END-->
    </body>
</html>
