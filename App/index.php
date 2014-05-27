 <?php 
    session_start();

        
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
 ?>
 <!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]> <html class="no-js"> <!==<![endif]-->

<html>
<head>
	<meta charset="utf-8">
	<meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
	<title>Open Aid Partnership - Open Aid Map</title>
	<meta name="description" content="Open Aid Map - Visualizing the Geography of Aid. The Open Aid Partnership (OAP) brings together development partners, governments, civil society organizations, foundations, and the private sector to improve aid transparency and effectiveness. The OAP's goal is to collect and open up local development data to engage citizens and other stakeholders in evidence-based conversations on development.">
	<meta content="width=device-width" name="viewport">

	<!-- CSSMIN-BEGIN -->
	<link href="css/bootstrap-oam.css" rel="stylesheet">
	<link href="css/sprites.css" rel="stylesheet">
	<link href="css/front.css" rel="stylesheet">
	<link href="oamfavicon32.ico" rel="shortcut icon" type="image/x-icon">
	<!-- CSSMIN-END -->
	
	<script>
		var _SPDEV = {};
	</script>
	    
</head>
 
<body>
  <!--[if lt IE 7]>
            <p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
        <![endif]-->

<!-- HEADER INSERTS HERE -->
<!--<a href="https://github.com/spatialdev/OAM-PUBLIC"><img style="position: absolute; z-index:300; top: 50px; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png" alt="Fork me on GitHub"></a>-->
<div class="container">

<!-- title and search -->
     
<div class="centered" id="introSearch">

<div class="row">
	
    <div class="col-6">
        <div id="introTitle">
        	
 
          <span class="toptitle">OPEN AID MAP</span><br>
          <span class="bottomtitle">VISUALIZING THE GEOGRAPHY OF AID</span>
       </div>
    </div>
    <!-- <div class="col-6">
        <div id="searchBox">
          <input id="uxSearch" placeHolder='Search...'>
            <div class="searchButton" title='Search'></div>
          </input>
        </div>
    </div     -->
  </div>   
</div>
      
<img src="img/heroline.png" style="width:100%">      

<!-- Map -->

<div class="centered" id="mmmap"></div>
  
  
<!-- quickstats -->

<div class="centered" id='frontQuickStats'>
        <div id='qslead' class='row centered'>
          <div class='col-md-4'>
            <div class='hr'><img src='img/quickstats-hr.png' width='270px'></div>
          </div>
          <div class='col-md-4'>
            <div class='qsHeader'>QUICK STATS</div>
          </div>
          <div class='col-md-4'>
            <div class='hr'><img src='img/quickstats-hr.png' width='270px'></div>
          </div>
        </div>

        <div id='qsStats' class='row'>
          <div class='qsContent' class='col-md-6'>
            <!--<div class="qstatsTopic">
              ACTIVITIES WITH IMPACT
            </div>-->

            <table class="qsTable">
              <tr>
                <td class='qstd'><span class='qsTitle' id='qsSector1Cnt' style='color:#00aced'></span></td>

                <td class='qstd'><!-- <img class='qsicon' src='img/water.png'> --></td>

                <td class='qstd'>
                  <div id='qsSector1Name'>
                  </div>
                </td>
              </tr>

              <tr>
                <td class='qstd'><span class='qsTitle' id='qsSector2Cnt' style='color:#ae7d08'></span></td>

                <td class='qstd'><!-- <img class='qsicon' src='img/auto.png'> --></td>

                <td class='qstd'>
                  <div id='qsSector2Name'>
                  </div>
                </td>
              </tr>
            </table>
          </div>

          <div class='qsContent' class='col-md-6'>
            <!--<div class="qstatsTopic">
              BUILDING HUMAN CAPACITY
            </div>-->

            <table class="qsTable">
              <tr>
                <td class='qstd'><span class='qsTitle' id='qsSector3Cnt' style='color:#8ac53e'></span></td>

                <td class='qstd'><!-- <img class='qsicon' src='img/book.png'> --></td>

                <td class='qstd'>
                  <div id='qsSector3Name'>
                  </div>
                </td>
              </tr>

              <tr>
                <td class='qstd'><span class='qsTitle' id="qsSector4Cnt" style='color:#824638'></span></td>

                <td class='qstd'><!-- <img class='qsicon' src='img/health.png'> --></td>

                <td class='qstd'>
                  <div id='qsSector4Name'>
                  </div>
                </td>
              </tr>
            </table>
          </div>
        </div>
      </div>

<!-- news -->

<div id='frontInTheNews'>
        <div id='itnlead' class='row'>
          <div class='col-md-4'>
            <div class='hr'><img src='img/quickstats-hr.png' width='270px'></div>
          </div>
          <div class='col-md-4'>
            <div class='qsHeader'>IN THE NEWS</div>
          </div>
          <div class='col-md-4'>
            <div class='hr'><img src='img/quickstats-hr.png' width='270px'></div>
          </div>
        </div>

        <div class="qsnewsContainer">
          <table border="0" cellpadding="5px" cellspacing="5px" style="padding-left:20px; font-size:14px; font-family: 'Gotham-Book';" width="108%">
            <tbody id="qsnewsStories">
              
            </tbody>
          </table>

          <div class="qsnewsAll">
            <a href="news.html">All News <img src='img/flyoutRight_D76C26_8x16.png'></a>
          </div>
        </div>
      </div>

<!-- FOOTER INSERTS HERE -->
   
</div> <!-- end container -->


<!-- Avast, the bootstrap be over -->

  <script src="js/vendor/jquery-1.9.1.min.js"></script>
  <script src="js/vendor/bootstrap-oam.min.js"></script>
  <script src="js/vendor/d3.v3.min.js"></script> 
  <script src="js/vendor/queue.v1.min.js"></script> 
  <script src="js/vendor/topojson.v1.min.js"></script>
  <script src="js/layout-builder.js"></script> 
  <script src="js/frontMap.js"></script> 
  <script src="js/frontStats.js"></script> 
  <script src="js/news.js"></script>
   <script src="js/front-main.js"></script> 
  <script src="js/goto.js"></script>
    <!-- SiteCatalyst code version: G.6. Copyright 1997-2004 Omniture, Inc. More info available at http://www.omniture.com -->

   <script language="JavaScript"
src="http://siteresources.worldbank.org/SITEMGR/Resources/WebStatsUtil.js"
   type="text/javascript">
   </script><script language="JavaScript"
   type="text/javascript">
   //<![CDATA[
   <!--

   var s_pageName="";
   var s_channel="WBI Open Aid Partnership EXT";
   var s_hier1 = "WBI,WBI Open Aid Partnership EXT";
   var s_prop1 = "";
   var s_prop2 = "Not Available"; /* Author */
   var s_prop3 = "Not Available"; /* Date */
   var s_prop4 = "Not Available"; /* Topic */
   var s_prop5 = "Not Available"; /* Sub Topic */

   var s_prop6 = "Not Available"; /* Region */

   var s_prop7 = "Not Available"; /* Country */

   var s_prop8 = "Not Available"; /* DocType */

   var s_prop9 = "Not Available"; /* MDK or unique identifier */

   var s_prop10 = "Live"; /* Site Status */


   var s_prop11 = "Not Available"; /* Data Source */

   var s_prop13 = "WBI"; /* VPU */

   var s_prop16="English"; /* doc language */

   var s_prop17="English"; /* site language */

   var sTitle = document.title;

   var asTitleParts = sTitle.split("-");

   while (sTitle.indexOf(",") > -1)

   sTitle = sTitle.replace(",", "");

   s_pageName = sTitle;

   s_prop1 = sTitle;

   s_hier1 += ", " + sTitle;

   var s_account="wbnispwbiextoap,wbglobalext";

   //-->

   //]]>

   </script><script language="JavaScript"

src="http://siteresources.worldbank.org/scripts/s_code_remote.js"


   type="text/javascript">

   </script><!-- End SiteCatalyst code version: G.6. -->

   <script type="text/javascript">


   //<![CDATA[


   var _gaq = _gaq || [];

   _gaq.push(['_setAccount', 'UA-18962568-3']);

   _gaq.push(['_trackPageview']);


   (function() {

   var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;

   ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';

   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);

   })();


   //]]>

   </script>
</body>
</html>
