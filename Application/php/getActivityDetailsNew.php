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
		      
		while($rows = pg_fetch_object($result)) {
			
			$r2 = array();
			
			foreach(json_decode($rows->response) as $key=>$val) {
			  if (is_array($val))
			    $r2[$key] = $val;
			  else if ($key == "title")
			    $r2[$key] = ucwords(strtolower($val));
			  else
			    $r2[$key] = ucfirst(strtolower($val));
			    
			}
			
			(Object)$r2;

	    }	
		
		echo json_encode($r2);
		  
		} catch(Exception $e) {  
			header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
		}

?>