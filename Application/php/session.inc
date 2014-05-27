<?php
	/*
	@author: Grant McKenzie (gmckenzie@spatialdev.com)
	@client: World Bank
	@project: Open Aid Map
	@date: January 2014
	@description: makes sure user is authorized
	*/
	ini_set("session.cookie_httponly", 1);
	session_start();
	if (isset($_SESSION['oamuser'])) {
		require_once 'php/user.inc';
		$oamuser = unserialize($_SESSION['oamuser']);
		echo "<script>var _oamuser='".json_encode($oamuser)."';</script>";
	} else {
	    if(strpos($_SERVER['PHP_SELF'], "application.php") == 0)
		header('Location: index.php', true, 302);
	}
?>