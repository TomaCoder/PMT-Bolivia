<?php

	ini_set('display_errors', 'On');
	error_reporting(E_ALL);
	require('db.inc');
	require('utils.inc');

	$dataGroup = null;
	$countryIds = null;
	$orgRole = null;

	try {

	    if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
	      throw new Exception('Bad Request', 400);
	    }
	    
		if (isset($_POST['orgRole'])) {
	    	
	    	$orgRole = intval($_POST['orgRole']);
	    	
	    	// Validate that this is an integer
			if(is_int($orgRole) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}
		
		if (isset($_POST['dataGroupId'])) {
	    	
	    	$dataGroup = intval($_POST['dataGroupId']);
	    	
	    	// Validate that this is an integer
			if(is_int($dataGroup) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}

		if (isset($_POST['countryIds'])) {

	    	$countryIds = $_POST['countryIds'];
	    	
	    	if(validateCommaDelimitedIntString($countryIds) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		}
	
		$tmpFilters = $dataGroup ."," . $countryIds;

		$preFilters = null;
		$lastChar = substr($tmpFilters, -1);
		
		if($lastChar == ','){
			
			$preFilters = substr($tmpFilters, 0, -1);
			
		}
		else {
			$preFilters = $tmpFilters;
		}

		$sql = "select * from pmt_org_inuse('" . $orgRole . "," . $preFilters . "');";
		
		// Prepare a query for execution
		$result = pg_prepare($dbPostgres, "my_query", $sql);
		
		// Execute the prepared query.
		$result = pg_execute($dbPostgres, "my_query", array());
		
		$rows = pg_fetch_all($result);
        		
		$data = array();
		foreach($rows as $row) {
			$data[] =  json_decode($row["response"]);
		}
		
		$json = json_encode($data, JSON_NUMERIC_CHECK);
        echo $json;
			
	} catch(Exception $e) {  
  	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die(); 
	}
	
	pg_close($dbPostgres);
?>

