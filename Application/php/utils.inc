<?php 



	function validateCommaDelimitedIntString($commaDelimitedIntString) {


		// Convert comma delimited string to array so we can validate
			$ints = array_map("intval", explode(",", $commaDelimitedIntString));

			foreach ($ints as &$value) {
				
				// Validate that these are integers
				if(is_numeric($value) == false) {
					return false;
				}
			}

			return true;
			
	}


	function validatePostgresDateString($dateString) {

		// Convert comma delimited string to array so we can validate
			$ints = array_map("intval", explode("-", $dateString));

			foreach ($ints as &$value) {
				
				// Validate that these are integers
				if(is_numeric($value) == false) {
					return false;
				}
			}

			return true;
	}

?>