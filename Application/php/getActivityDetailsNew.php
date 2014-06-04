<?php

	require('db.inc');
	
	$activity_id = null;

	try{
		
		if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
			throw new Exception('Bad Request', 400);
		}


		if (isset($_GET['id'])) {
	    	
	    	$activity_id = intval($_GET['id']);
	    	
	    	// Validate that this is an integer
			if(is_int($activity_id) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}

		$sql="SELECT * FROM bolivia_activity(".$activity_id.");";

		$result = pg_query($dbPostgres, $sql) or die("error");
		      
		$rows = pg_fetch_object($result);
		echo json_encode(json_decode($rows->response));
		  
		} catch(Exception $e) {  
			header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
		}

?>