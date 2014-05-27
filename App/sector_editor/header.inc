  <!-- =================================
  @author = Grant McKenzie (gmckenzie@spatialdev.com
  @date = January 2014
  @client = World Bank Open Aid Partnership
  @functionality = Header file (HTML/PHP)
  ====================================== -->

  <header id="appHeader" class="clearfix" style="padding-bottom:5px">
	  <div id="logo" class="left">
		  <a href="index.php"><img src="img/oamLogo.png" alt="Open Aid Partnership" class="lb" /></a>
	  </div>
	  <nav class="header-nav" style="cursor:auto;">
		  <ul class="clearfix pt">
			  <li><span id="dg"><?php echo strtoupper($oamuser->data_group); ?></span> <span id="se_h_title">SECTOR ASSIGNOR</span></li>
			  <li style="float:right;"><div class="se_logout" id="se_logout">Logout</div></li>
			  <li style="float:right;"><?php echo strtoupper($oamuser->username); ?></li>
		  </ul>
		  
	  </nav>
  </header>