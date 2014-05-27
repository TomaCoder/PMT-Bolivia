<?php
	/*
	@author: Grant McKenzie (gmckenzie@spatialdev.com)
	@client: World Bank
	@project: Open Aid Map
	@date: January 2014
	@description: makes sure user is authorized
	*/
	session_set_cookie_params ( 1800, null, null, null, true);
	session_start();
	if (isset($_SESSION['oamuser'])) {
	    require_once 'user.inc';
	    $oamuser = unserialize($_SESSION['oamuser']);
	    $d = array("response"=>200, "message"=>$oamuser);
	    echo json_encode($d);
	} else {
	    $d = array("response"=>403, "message"=>"Permission denied");
	    echo json_encode($d);
	    exit();
	}
	
?>	