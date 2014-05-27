<?php

    
    require('../../php/db.inc');
	
	ini_set("session.cookie_httponly", 1);
	session_start();

	// Get the data
	try {

		if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
			throw new Exception('Bad Request', 400);
		}

    	if (!isset($_SESSION['oamuser'])) {
	   		throw new Exception('Access Denied ', 403);
	    } 

		$a_id = null;// pg_escape_string($_POST['a_id']);
		$c_id = null; //pg_escape_string($_POST['c_id']);
		$method = null; //pg_escape_string($_POST['method']);

		if (isset($_POST['a_id'])) {
	    	
	    	$a_id = intval($_POST['a_id']);
	    	
	    	// Validate that this is an integer
			if(is_int($a_id) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}

		if (isset($_POST['c_id'])) {
	    	
	    	$c_id = intval($_POST['c_id']);
	    	
	    	// Validate that this is an integer
			if(is_int($c_id) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}

		if (isset($_POST['method'])) {
	    	
	    	$method = pg_escape_string($_POST['method']);
	    	
		} else {
			throw new Exception('Bad Request', 400);
		}


		$sql = "select * from pmt_edit_activity_taxonomy('".$a_id."', ".$c_id.", '".$method."');";
		
		// Prepare a query for execution
		$result = pg_prepare($dbPostgresWrite, "my_query", $sql);
		
		// Execute the prepared query.
		$result = pg_execute($dbPostgresWrite, "my_query", array());
		
		$rows = pg_fetch_all($result);
		
		echo json_encode($rows[0]['pmt_edit_activity_taxonomy']);	 
			
	} catch(Exception $e) {  
	         	    
	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
    	die();
	}
	pg_close($dbPostgresWrite);
		
?>

