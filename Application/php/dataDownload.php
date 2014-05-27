<?php

	require('db.inc');
	require('utils.inc');

	// Get the data
	try {

		if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
			throw new Exception('Bad Request', 400);
		}
		
			// classification id array from POST
		$email =  null;

		$classifications =  '';
		
		$organizations =  '';
		
		$unassignedTax = '';
		
		$startDate = 'null';
		
		$endDate = 'null';

		$impossibleId = "-999999";

		if (isset($_POST['email'])) {
	    	
	    	$email = pg_escape_string($_POST['email']);
	    	
		} else {
			throw new Exception('Bad Request', 400);
		}

		if (isset($_POST['classificationIds'])) {

	    	$classifications = $_POST['classificationIds'];
	    	
	    	if(validateCommaDelimitedIntString($classifications) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		}

		if (isset($_POST['organizationIds'])) {

	    	$organizations = $_POST['organizationIds'];
	    	
	    	if(validateCommaDelimitedIntString($organizations) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		}	
		
		if (isset($_POST['unassignedTaxIds'])) {

	    	$unassignedTax = $_POST['unassignedTaxIds'];
	    	
	    	if(validateCommaDelimitedIntString($unassignedTax) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		}

		$classificationsArr = explode(",", $classifications);
		
		$orgArr = explode(",", $organizations);
		
		// client wants no selection === no data returned; but our db function thinks no classification or org ids mean 'all data'; so this is a work around
		if(in_array ( $impossibleId, $classificationsArr ) || in_array($impossibleId, $orgArr)) {
			echo json_encode('f', JSON_NUMERIC_CHECK);	
			
			return;
		}

		$sql = "SELECT * FROM pmt_filter_iati('".$classifications."','".$organizations."','".$unassignedTax."',".$startDate.",".$endDate.",'".$email."');";

		$result = pg_query($dbPostgresWrite, $sql);
		
		$response = pg_fetch_all($result);

		echo json_encode($response[0]);
			
	} catch(Exception $e) {  
 	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die();  
	}
	
	pg_close($dbPostgresWrite);
?>