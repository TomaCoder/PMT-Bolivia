<?php

ini_set('display_errors', 'On');
  error_reporting(E_ALL);
  
set_include_path(get_include_path() . PATH_SEPARATOR . 'phpseclib');

include('Net/SFTP.php');
include('Crypt/RSA.php');
// include('Crypt/RSA.php');

$key = new Crypt_RSA();

//$key->setPassword('whatever');
$key->loadKey(file_get_contents('spatialdev.pem'));

$ssh = new Net_SFTP('ec2-54-243-220-251.compute-1.amazonaws.com');
if (!$ssh->login('ubuntu', $key)) {
    exit('Login Failed');
}
$ssh->put('/usr/local/pmt_iati/filename.remote', 'xxx');
// echo $ssh->exec('sudo vim /usr/local/pmt_iati/test.txt');
// echo $ssh->exec('ls');
?>