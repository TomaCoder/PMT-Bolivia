<?php

        // Turn on the PHP debugger for Chrome

        $IS_PROD_DEPLOY=FALSE; // Prod v. Dev
        $IS_STAGE_DEPLOY=FALSE; // Prod v. Dev
        $IS_LOCAL_DEPLOY=FALSE; //Local v. Server

        $host = null;
        $serverSubstring;
        
        if($IS_PROD_DEPLOY) {
                $host = "<IP ADDRESS>";
                $serverSubstring = "<URL SUB STRING>";
                $IS_LOCAL_DEPLOY=FALSE;
                ini_set('display_errors', 'Off');
                error_reporting(0);
        } else if ($IS_STAGE_DEPLOY) {
                $host = "<IP ADDRESS>";
                $serverSubstring = '<URL SUB STRING>';
                ini_set('display_errors', 'Off');
                error_reporting(E_ALL);
        } else if($IS_LOCAL_DEPLOY) {
                require_once('PhpConsole.php');
                PhpConsole::start();
                $host = "<IP ADDRESS>";
                $serverSubstring = 'localhost';
                ini_set('display_errors', 'On');
                error_reporting(E_ALL);
        }

        //Database Server
        $dbserver = $host;

        //Data Model DB
        $database = "<DATABASE NAME>";
        $username = "<DB READ USER>";
        $username_write = "<DB WRITE USER>";
        $password = "<DB PASSWORD>";

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
