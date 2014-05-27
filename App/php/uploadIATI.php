<?php

  ini_set("session.cookie_httponly", 1);
  session_start();
  //The IATI upload through the UI overwrites the existing data for a specific data group with new data.
  include('db.inc');

  try {
    if (isset($_SESSION['oamuser'])) {
        require_once 'user.inc';
        $oamuser = unserialize($_SESSION['oamuser']);
        $country = $oamuser->data_group;
    } else {
        throw new Exception('Access Denied', 403);
    }

    if(stristr($_SERVER['HTTP_REFERER'], $serverSubstring) === FALSE) {
      throw new Exception('Bad Request', 400);
    }

    // Change the uploaded file name to reflect the country as well as the current timestamp
    $filename = $country."-".time().".xml";
//    move_uploaded_file( $_FILES["iati"]["tmp_name"], "/usr/local/pmt_iati/" . $filename);

    if (!is_readable($_FILES["iati"]["tmp_name"])) { // Test if the file is writable 
        header('HTTP/1.1 ' . '500' . " Cannot read uploaded file.");
        die();
        //throw new Exception("Cannot read uploaded file.", 400);
    }

    $f = fopen($_FILES["iati"]["tmp_name"], 'r');
    $line = fgets($f);
 //   fclose($f);



    $fout = fopen("/usr/local/pmt_iati/" . $filename,'w');

    $writePath = "/usr/local/pmt_iati/" . $filename;
    $errMsg = "Cannot write to file" . $writePath;
    if (!is_writable($writePath)) { // Test if the file is writable
        header('HTTP/1.1 ' . '500' . " Cannot write to " . $writePath);
        die();//throw new Exception("Cannot write to file");
    }
    
    if (!strpos($line,"xml")) {
        fwrite($fout, $line);
    }
    while (($buffer = fgets($f, 4096)) !== false) {
          fwrite($fout, $buffer);
    }
    if (!feof($f)) {
        echo "Error: unexpected fgets() fail\n";
    }
    fclose($f);
    fclose($fout);

    // Execute the upload.  Database server name comes from the db.inc file
    
    // Execute the PostGres data load query
    $resp = loadFile($country, $filename);
    
    if ($resp == "t")
      echo true;
    else
      echo false;

  } catch(Exception $e) { 
      echo  
      header('HTTP/1.1 ' . $e->getCode() . ' ' . $e->getMessage());
      die();
  }

  // Only necessary if DB is on another server
  function sendFile($dbserver, $filename) {
      set_include_path(get_include_path() . PATH_SEPARATOR . 'phpseclib');

      // Secure FTP for file transfer and RSA Crypt for access key encryption
      include('Net/SFTP.php');
      include('Crypt/RSA.php');

      $key = new Crypt_RSA();
      $key->loadKey(file_get_contents('spatialdev.pem'));

      $sftp = new Net_SFTP($dbserver);
      if (!$sftp->login('ubuntu', $key)) {
          exit('Login Failed');
      }

      // Set appropriate directories (from & to respectively)
      $ap_directory = "/var/www/oam-iati/";
      $db_directory = "/usr/local/pmt_iati/";

      // SFTP transfer the file from the APPLICATION SERVER to the DATABASE SERVER
      $r = $sftp->put($db_directory.$filename, $ap_directory.$filename, NET_SFTP_LOCAL_FILE);
  }
  
  function loadFile($country, $filename) {
    // Purge the existing data and load the new file with the appropriate country name.
    global $dbPostgresWrite;

    // Execute the query
    $query = "SELECT * FROM pmt_iati_import('/usr/local/pmt_iati/".$filename."', '".$country."', true);";
    $result = pg_query($dbPostgresWrite, $query) or die(pg_last_error());

    // Make sure the query returns true
    $r = false;
    while ($row = pg_fetch_row($result)) {
      $r = $row[0];
    }
    return $r;
 }
?>
