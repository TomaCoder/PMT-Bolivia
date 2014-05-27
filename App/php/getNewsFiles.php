<?php

    //The directory (relative to this file) that holds the html files
    $dir = "../content/news";


    //This array will hold all the file addresses
    $result = array();

    //Get all the files in the specified directory
    $files = scandir($dir);


    foreach($files as $file) {

        switch(ltrim(strstr($file, '.'), '.')) {

            //If the file is an html, add it to the array
            case "html":

                $result[] = $dir . "/" . $file;

        }
    }

    //Convert the array into JSON
    $resultJson = json_encode($result);

    //Output the JSON object
    echo($resultJson);

?>
