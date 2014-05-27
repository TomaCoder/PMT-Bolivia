<?php


	require('db.inc');

	# Build SQL SELECT statement and return the geometry as a GeoJSON element
	$sql = "SELECT COUNT(activity_id) AS cnt, classification AS name FROM activity_taxonomies WHERE taxonomy = 'Sector' GROUP BY classification ORDER BY cnt DESC LIMIT 4";

	$result = pg_query($dbPostgres, $sql);

	$rows = pg_fetch_all($result);

	echo json_encode($rows);

	pg_close($dbPostgres);
	
?>
