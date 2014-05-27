<?php

	require('../../php/session_handlers.inc');
	require('../../php/db.inc');

	try {	
	      $sql = "select * from refresh_taxonomy_lookup();";

	      // Prepare a query for execution
	      $result = pg_prepare($dbPostgresWrite, "refresh", $sql);
	      
	      // Execute the prepared query.
	      $result = pg_execute($dbPostgresWrite, "refresh", array());
			  
			
	} catch(Exception $e) {  
	      die( );  
	}
	pg_close($dbPostgresWrite);
	
?>

