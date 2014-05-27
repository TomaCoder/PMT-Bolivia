<?php

	require('../../php/db.inc');
	
	// Get the data
	try {

		$sql = "select * from pmt_taxonomies('15');";

		// Prepare a query for execution
		$result = pg_prepare($dbPostgres, "my_query", $sql);
		
		// Execute the prepared query.
		$result = pg_execute($dbPostgres, "my_query", array());
		
		$rows = pg_fetch_all($result);

		$r = json_decode($rows[0]['response'])->classifications;
		echo json_encode($r, JSON_NUMERIC_CHECK);	
			
	} catch(Exception $e) {  
	      die( );  
	}
	pg_close($dbPostgres);
?>

