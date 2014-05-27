<?php

	require('db.inc');
	require('utils.inc');
	
	$l_ids = null;

	try{
		
	    if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
      		throw new Exception('Bad Request', 400);
    	}
    	
		if (isset($_POST['l_ids'])) {
	    	
	    	$l_ids = $_POST['l_ids'];
	    	
	    	if(validateCommaDelimitedIntString($l_ids) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		} else {
			throw new Exception('Bad Request', 400);
		}
		

		$sql="select * from pmt_infobox_menu('" . $l_ids . "')";

		$result = pg_query($dbPostgres, $sql);
		
		$rows = pg_fetch_all($result);
		
		$project = json_decode($rows[0]['response']);
		
		$activities = $project->activities;
		
		//array($a_ids =  => , );
		$a_ids = array();
		
		foreach ($activities as $act) {
		   array_push($a_ids, $act->a_id);
		}
		echo json_encode($a_ids, JSON_NUMERIC_CHECK);	
			
	} catch(Exception $e) {  
   	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die(); 
	}
	
	pg_close($dbPostgres);
?>

