<?php

	require('db.inc');
	require('utils.inc');

	$dataGroup = null;
	$countryIds = null;
	$summaryTax = null;

	try {

	    if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
	      throw new Exception('Bad Request', 400);
	    }
	    
		if (isset($_POST['summaryTaxonomyId'])) {
	    	
	    	$summaryTax = intval($_POST['summaryTaxonomyId']);
	    	
	    	// Validate that this is an integer
			if(is_int($summaryTax) == false) {
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
		
       	$sql= "SELECT l_id, x, y, r_ids FROM pmt_locations_by_tax(" . $summaryTax .", " . $dataGroup . ", '" . $countryIds . "');";
		
		// Prepare a query for execution
		$result = pg_prepare($dbPostgres, "my_query", $sql);
		
		// Execute the prepared query.
		$result = pg_execute($dbPostgres, "my_query", array());
		
		$rows = pg_fetch_all($result);
        
		
		echo json_encode($rows, JSON_NUMERIC_CHECK);	
		
		
	} catch(Exception $e) {  
   	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die(); 
	}
	
	pg_close($dbPostgres);
	
?>

