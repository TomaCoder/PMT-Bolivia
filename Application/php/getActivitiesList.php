<?php

	require('db.inc');
	require('utils.inc');
	require('translate.inc');
	


	$sectorcode = null;
	$src = null;
	$country = null;
	$offset = null;
	$orderby = null;
	$escapedOrderBy = null;
	$order = null;
	$sectors = null;
	$orgs = null;
	$language = null;
	$impossibleId = "-999999";
	$classificationsArr = null;
	$sectorArr = null;
	$orgArr = null;


	try {

		//echo "Ref: " . $_SERVER['HTTP_REFERER'];

//		if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === false) {
//			throw new Exception('Bad Request', 400);
//		}

		if (isset($_POST['sectorcode'])) {
	    	
	    	$sectorcode = intval($_POST['sectorcode']);
	    	
	    	// Validate that this is an integer
			if(is_int($sectorcode) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}

		if (isset($_POST['src'])) {
	    	
	    	$src = intval($_POST['src']);
	    	
	    	// Validate that this is an integer
			if(is_int($src) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request', 400);
		}
/*
		if (isset($_POST['country'])) {
	    	
	    	$country = intval($_POST['country']);
	    	
	    	// Validate that this is an integer
			if(is_int($country) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request ', 400);
		}
*/
		if (isset($_POST['offset'])) {
	    	
	    	$offset = intval($_POST['offset']);
	    	
	    	// Validate that this is an integer
			if(is_int($offset) == false) {
				throw new Exception('Bad Request', 400);
			}
		} else {
			throw new Exception('Bad Request ', 400);
		}

		if (isset($_POST['orderby'])) {
	    	
	    	$orderBy = $_POST['orderby'];

	    	$escapedOrderBy = pg_escape_string($orderBy);
	  
		} else {
			
			throw new Exception('Bad Request ', 400);
		
		}


		if (isset($_POST['order'])) {
	    	
	    	$order = strtolower($_POST['order']);

	    	if(!($order == 'asc' || $order == 'desc')) {
	    		throw new Exception('Bad Request ', 400);
	    	}
		} else {
			throw new Exception('Bad Request', 400);
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

		if (isset($_POST['sectors'])) {

	    	$sectors = $_POST['sectors'];
	    	
	    	if(validateCommaDelimitedIntString($sectors) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		}

		if (isset($_POST['orgs'])) {

	    	$orgs = $_POST['orgs'];
	    	
	    	if(validateCommaDelimitedIntString($orgs) == false) {
	    		throw new Exception('Bad Request ', 400);
	    	}

		} 


		if($sectors == '') {
			$sectorArr = array();
		} else {
			$sectorArr = explode(",", $sectors);
			
		}
		
		$formattedSectors = null;

		if(count($sectors)  && trim($sectors)==='') {
			$formattedSectors = $sectors;
		} else {
			$formattedSectors = ',' . $sectors;
		}
		
		$orgArr = explode(",", $orgs);
		
		if($country == null) {
			$classificationsArr = array_merge(array($src), $sectorArr);
		} else {
			$classificationsArr = array_merge(array($src), $sectorArr, array($country));
		}

		// client wants no selection === no data returned; but our db function thinks no classification or org ids mean 'all data'; so this is a work around
		if(in_array ( $impossibleId, $classificationsArr ) || in_array($impossibleId, $orgArr)) {
		  
			echo json_encode(null, JSON_NUMERIC_CHECK);
			pg_close($dbPostgres);
			return;	
		}
		


		$records = getRecords($sectorcode, implode(",", $classificationsArr), $orgs, $escapedOrderBy, $order, $offset, $language);
		
		$cnt = getCount(implode(",", $classificationsArr), $orgs, $orderby, $order, $offset);
		
		$page = $offset/100 + 1;
		$totalpages = ceil($cnt/100)+1;
		$a = array('rows'=>$records,'count'=>$cnt, 'page'=>$page, 'tot'=>$totalpages);
		echo json_encode($a, JSON_NUMERIC_CHECK);
	
	} catch(Exception $e) {  
   	    header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
 	    die();
	}
	
	function getRecords($sectorcode, $classifications, $orgs, $orderby, $order, $offset, $lang) {
	      global $dbPostgres, $sectorDictionary;
	      // Get the data
	      try {
		    //INPUT: taxid (15 = sector), datagroup followed by sector ids, org ides, unassigned tax ids, order by, limit, offset.
		    $sql = "SELECT * FROM pmt_activity_listview('". $classifications."','".$orgs."',null, null, null, '".$sectorcode."','".$orderby." ".$order."', 100, ".$offset.")";

		    $result = pg_query($dbPostgres, $sql) or die(pg_last_error());
		    $r = array();
		    while($rows = pg_fetch_object($result)) {
		      $r2 = array();
		      
		      foreach(json_decode($rows->response) as $key=>$val) {
			  if($key == "taxonomy") {
			    foreach($val as $k=>$v) {
			      if($v->t == 'Sector' && $lang == 'spanish') {
				  $tmpString = translateSector($sectorDictionary, $v->c);
			      }
			    } 
			    $key = 'r_name';
			    $val = $tmpString;
			  } else if($key == "orgs") {
			    $tmpString = combineOrgs($val);
			    $key = 'o_name';
			    $val = $tmpString;
			  }
			  $r2[$key] = ucwords(strtolower($val)); 
		      }
		      $r[] = (Object)$r2;
		    }
		    
		    pg_free_result($result);
		    return $r;
			      
	      } catch(Exception $e) {  
		    die( /*print_r( $e->getMessage() ) */);  
	      }
		  
		  pg_close($dbPostgres);
	}
	
	function translateSector($sectorDictionary, $v) {
	  $sectors = explode(",", $v);
	  $tmpString = '';
	  for($i=0;$i<count($sectors);$i++) {
	      $tmpString .= $sectorDictionary[$sectors[$i]];
	      if ($i < count($sectors)-1)
		$tmpString .= ", ";
	  }
	  return $tmpString;
	}
	
	function combineOrgs($orgs) {
	  $tmpString = '';
	  for($i=0;$i<count($orgs);$i++) {
	      $tmpString .= $orgs[$i]->name;
	      if ($i < count($orgs)-1)
		$tmpString .= ", ";
	  }
	  return $tmpString;
	}
	
	function getCount($classifications, $orgs) {
	    global $dbPostgres;

	    $rows = null;
		
		try {
		    $sql = "SELECT * FROM pmt_activity_listview_ct('".$classifications."','".$orgs."','', null, null)";
		    $result = pg_query($dbPostgres, $sql);
		    $rows = pg_fetch_object($result);
		    pg_free_result($result);
		} catch(Exception $e) {  
			die( /*print_r( $e->getMessage() ) */);  
		}
		if($rows != null)  {
		    return $rows->pmt_activity_listview_ct;
		}

	}
	
	function buildFilters($sector, $orgs) {
		$filters = "";
		// Restrict records to organizations.
		if (count($sector) > 0 && $sector[0] != "") {
		  $filters .= " AND (";
		  foreach($sector as $s) {
		    $filters .= "aa.classification_id = " . $s . " OR ";
		  }
		  
		  $filters = substr($filters, 0, -4);
		  $filters .= ")";
		}
		
		if (count($orgs) > 0 && $orgs[0] != "") {
		  $filters .= " AND (";
		  foreach($orgs as $s) {
		    $filters .= "cc.organization_id = " . $s . " OR ";
		  }
		  $filters = substr($filters, 0, -4);
		  $filters .= ")";
		}
		return $filters;
	}
	
	
?>