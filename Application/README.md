Open Aid Map
============

Public Repo for the Open Aid Map application. 

This application is tightly coupled with its companion database which can be found here:
https://github.com/spatialdev/PMT

You are welcome to download, fork, change and re-publish this application as your own. 
The OAM applicaiton itself is highly dependent on the underlying data model and its associated
functions. A correctly installed and configured database is required as are IATI formatted 
data which can be generated here: http://csv2iati.iatistandard.org/


In order for data to show up on the map, you must have the mininium data fields including:
Project Title,
5-Digit IATI Sector codes for each activity,
Funding Organiation for each activity

_Instalation Requirements_
--------------------------
sudo apt-get install apache2

sudo apt-get install php5

sudo apt-get install libapache2-mod-php5

sudo apt-get install php5-pgsql

sudo apt-get install php5-curl

sudo /etc/init.d/apache2 restart


_Change on the server to meet security requirements_

sudo pico /etc/php5/apache2/php.ini

Set "session.cookie_httponly"  option to "True"

session.cookie_httponly = True;


_Uploading Data_
----------------
The OAM application supports uploading new IATI files but does have the following limitations:

1) If the location element is missing or is 0,0 the activity record is skipped.

  _The applicaiton needs a coordinate location for each activity to show up on the map. Without that,
  the application doesn't know where to place the activity or which country the activity belongs to._

2) The OAM supports valid DAC-3 sector categories and DAC 5 digit sector codes. 

  _Custom sector vocabularies do not have valid IATI code lists associated with them_ 
  
3) For the upload to work the XML must be well structured and valid.

4) The OAM does support well structured XML that doesn't validate against the IATI schema, but unexpected behavior may occur.
  
Legal stuff: http://go.worldbank.org/OS6V7NIUD0
