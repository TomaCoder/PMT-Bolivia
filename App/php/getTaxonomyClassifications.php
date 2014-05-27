<?php

	require('db.inc');
	require('utils.inc');

	require('translate.inc');

	$taxonomies = null;
	$dataGroup = null;
	$countryIds = null;
	$language =  null;

	// Get the data
	try {
	
	    if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
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

		if (isset($_POST['language'])) {
	    	
	    	$language = strtolower($_POST['language']);

	    	if($language == 'spanish' || $language == 'english') {}
	    	else{
	    		throw new Exception('Bad Request', 400);
	    	}
		} else {
			throw new Exception('Bad Request ', 400);
		}

		if (isset($_POST['taxonomyIds'])) {

	    	$taxonomies = $_POST['taxonomyIds'];
	    	
	    	if(validateCommaDelimitedIntString($taxonomies) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		}


		$sql = "select * from pmt_tax_inuse(". $dataGroup .", '". $taxonomies ."', '" . $countryIds . "');";

		// Prepare a query for execution
		$result = pg_prepare($dbPostgres, "my_query", $sql);
		
		// Execute the prepared query.
		$result = pg_execute($dbPostgres, "my_query", array());
		
		$rows = pg_fetch_all($result);
		
		$data = array();

        foreach($rows as $row) {

            $data[] =  json_decode($row["response"]);
        }
		
		/*
		if($language == 'spanish'){
				
			$rec = json_decode($rows[0]['response']);
			
			$name  = $rec->name;

			$classifications = array();
			

			foreach ($rec->classifications as $c) {

				$c->name = $sectorDictionary[$c->name];
				
			}
			
			$data[] = $rec;
			
		} else if($language == 'english') {
			
			foreach($rows as $row) {
				
				$data[] =  json_decode($row["response"]);
			}
			
		} else {
			 throw new Exception('Unsupported language translation requested.');
		}
		*/
		echo json_encode($data, JSON_NUMERIC_CHECK);	
			
	} catch(Exception $e) {  
 	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die(); 
	}
	
	pg_close($dbPostgres);
?>

