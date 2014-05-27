<?php

        // Turn on the PHP debugger for Chrome

        $IS_PROD_DEPLOY=FALSE; // Prod v. Dev
        $IS_STAGE_DEPLOY=FALSE; // Prod v. Dev
        $IS_LOCAL_DEPLOY=TRUE; //Local v. Server

        $host = null;
        $serverSubstring = null;
        
        if($IS_PROD_DEPLOY) {
                

                #VIPFE IP server
                $host = "172.16.13.34";

                $serverSubstring = 'oam.vipfe.gob.bo';
                $IS_LOCAL_DEPLOY=FALSE;
                ini_set('display_errors', 'Off');
                error_reporting(0);
        } else if ($IS_STAGE_DEPLOY) {
               

                #VIPFE IP server
                $host = "172.16.13.33";

                $serverSubstring = '10.211.55.18';
                ini_set('display_errors', 'On');
                error_reporting(E_ALL);
        } else if($IS_LOCAL_DEPLOY) {

                #VIPFE IP server
                $host = "172.16.13.33";

                $serverSubstring = 'localhost';
                ini_set('display_errors', 'On');
                error_reporting(E_ALL);
        }

        //Database Server
        $dbserver = $host;

        #VIPFE Database name
        $database = "PMT";


        $username = "pmt_read";
        $username_write = "pmt_write";
        $password = "password";

        $dbPostgres = null;
        $dbPostgresWrite = null;
        // DB connection string - read
        try {
            $dbPostgres = pg_connect("host=$host port=5432 dbname=$database user=$username password=$password");
            $dbPostgresWrite = pg_connect("sslmode=disable host=$host port=5432 dbname=$database user=$username_write password=$password");
        } catch (Exception $e) {
            die("Could not connect");  
        }

?>
