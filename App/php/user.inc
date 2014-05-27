<?php
	/*
	@author: Grant McKenzie (gmckenzie@spatialdev.com)
	@client: World Bank
	@project: OpenAid Map
	@date: November 2013
	@description: user object
	*/
	
	class OAMuser {
		
		public $username;
		public $user_id;
		public $first_name;
		public $last_name;
		public $email;
		public $organization;
		public $organization_id;
		public $data_group;
		public $response;
			
		public function parseresponse() {
		  $u = json_decode($this->response);
		  $this->username = $u->username;
		  $this->user_id = $u->user_id;
		  $this->first_name = $u->first_name;
		  $this->last_name = $u->last_name;
		  $this->email = $u->email;
		  $this->organization = $u->organization;
		  $this->organization_id = $u->organization_id;
		  $this->data_group = $u->data_group;
		  unset($this->response);
		}
		
	}	
?>