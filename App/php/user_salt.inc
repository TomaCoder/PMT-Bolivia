<?php
	/*
	@author: Grant McKenzie (gmckenzie@spatialdev.com)
	@client: World Bank
	@project: OpenAid Map
	@date: November 2013
	@description: user object
	*/
	
	class OAMuser {
		
		public $email;
		public $id;
		public $name_first;
		public $name_last;
		public $lang;
		public $role;
		public $organisation;
		
		public function __construct() {
			/*
			$this->id=$row->user_id;
			$this->email=$row->email;
			$this->first=$row->name_first;
			$this->last=$row->name_last;
			$this->lang=$row->lang;
			$this->role=$row->role;
			$this->org=$row->organisation; */
		}	
	}	
?>