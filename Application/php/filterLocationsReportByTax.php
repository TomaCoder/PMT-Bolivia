<?php


	require('db.inc');
	require('utils.inc');

    $classifications = '';
	$organizations = '';
	$startDate = null;
	$endDate = null;
	$classificationsArr = null;
	$orgArr = null;
	$impossibleId = "-999999";
	$summaryTax = null;

	try{

		if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
			throw new Exception('Bad Request', 400);
		}


		if (isset($_POST['summaryTaxId'])) {
	    	
	    	$summaryTax = intval($_POST['summaryTaxId']);
	    	
	    	// Validate that this is an integer
			if(is_int($summaryTax) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}

		// classification id array from POST 
		if (isset($_POST['classificationIds'])) {

	    	$classifications = $_POST['classificationIds'];
	    	
	    	if(validateCommaDelimitedIntString($classifications) == false) {
	    		throw new Exception('Bad Request', 400);
	    	}

		} 
		
		if (isset($_POST['organizationIds'])) {

	    	$organizations = $_POST['organizationIds'];
	    	
	    	if(validateCommaDelimitedIntString($organizations) == false) {
	    		throw new Exception('Bad Request', 400);
	    	}
		} 

		if (isset($_POST['startDate'])) {
	    	$startDate = $_POST['startDate'];
	    	
	    	if(validatePostgresDateString($startDate) == false) {
	    		throw new Exception('Bad Request', 400);
	    	}
		} 
		
		if($startDate != null) {
			$startDate = "'". $startDate . "'";
		} else {
			$startDate = "null";
		}

		if (isset($_POST['endDate'])) {
	    	$endDate = $_POST['endDate'];
	    	if(validatePostgresDateString($endDate) == false) {
	    		throw new Exception('Bad Request', 400);
	    	}
		}
		
		if($endDate != null) {
			$endDate = "'". $endDate . "'";
		} else {
			$endDate = "null";
		}
		
		$classificationsArr = explode(",", $classifications);
		
		$orgArr = explode(",", $organizations);
		
		// client wants no selection === no data returned; but our db function thinks no classification or org ids mean 'all data'; so this is a work around
		if(in_array ( $impossibleId, $classificationsArr ) || in_array($impossibleId, $orgArr)) {
			echo json_encode(null, JSON_NUMERIC_CHECK);
			pg_close($dbPostgres);
			return;	
		}

			
			$sql = "SELECT * FROM pmt_filter_locations(" . $summaryTax. ", '". $classifications ."', '" . $organizations ."', '', ". $startDate .", ".$endDate.")";
			
			

			$result = pg_query($dbPostgres, $sql);
			
			$rows = pg_fetch_all($result);
	        
			echo json_encode($rows, JSON_NUMERIC_CHECK);	
				
	} catch(Exception $e) {  
   	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die();
	}
	
	pg_close($dbPostgres);
?>

