<?php

	require('db.inc');
	
	// Get the data
	try {

		$sql = "select * from pmt_data_groups();";

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

