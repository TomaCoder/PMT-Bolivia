  /* ================================================
  @author = Grant McKenzie (gmckenzie@spatialdev.com)
  @date = January 2014
  @client = World Bank Open Aid Partnership
  @functionality = Sector Editor Main JS File
  =================================================== */
  
  _SPDEV.SectorEditor = {};
  var _lang = null;
  _SPDEV.SectorEditor.prevSelect = null;
  _SPDEV.SectorEditor.prevChooserSelect = null;
  _SPDEV.SectorEditor.data_compare = null;
  _SPDEV.SectorEditor.data_sector = null;
  _SPDEV.SectorEditor.compare_selected = null;
  _SPDEV.SectorEditor.sector_selected = null;
  _SPDEV.SectorEditor.dg = null;
  
  $(function() {
    
    var langFile;
    //parse querystring if any
    _SPDEV.SectorEditor.dg = $('#dg').html();

    if(_SPDEV.SectorEditor.dg === 'BOLIVIA') {
	    langFile = "js/lang/es.json";
    } else {
	    langFile =  "js/lang/en.json"
    }
    
    $.getJSON( langFile, function( data ) {
	    _lang = data;
	    _SPDEV.SectorEditor.loadApp(_SPDEV.SectorEditor.dg);
    });
  });

  // Load the Application
  _SPDEV.SectorEditor.loadApp = function(dg) {
    
    // Load Language
    $('#se_h_title').html(_lang.se_h_title);
    $('#se_tab_head').html(_lang.se_tab_head);
    $('#se_col_head1').html(_lang.se_col_head1);
    $('#se_col_head2').html(_lang.se_col_head2);
    $('#se_chooser_head').html(_lang.se_chooser_head);
    $('#assign').html(_lang.se_assign_button);
    $("#se_logout").on('click',function() { 
	_SPDEV.SectorEditor.logout();
     });
    
    this.loadStandardSectors($('#se_chooser_content'));
    this.readIATI();
  };
  _SPDEV.SectorEditor.logout = function() {
      $.ajax({
	  type: 'POST',
	    'dataType': "json",
	    'url': 'php/logout.php',
	    'success': function(data){
		  window.location = "index.php";
	    },
	    'error': function(response) {
		  console.error(response);
		  location.reload();
	    }
	});
  };
  
  _SPDEV.SectorEditor.loadStandardSectors = function(parent) {
      var cell, c, content = "";
      $.ajax({
	  type: 'POST',
	    'dataType': "json",
	    'url': 'sector_editor/php/getSectors.php',
	    'success': function(data){
		_SPDEV.SectorEditor.data_sector = data;
		data.sort(_SPDEV.SectorEditor.compare);
		var i = 0;
		while(i<data.length) {
		  cell = "<div class='se_col chooser' id='c_chooser_"+i+"'>"+data[i].name+"</div>";
		  content += cell;
		  i++;
		}
		parent.html(content);
	    },
	    'error': function(response) {
		  console.error(response);
	    }
	});

  };
  
  // AJAX Call to read in DATA from FILE and DB
  _SPDEV.SectorEditor.readIATI = function() {
      var params = {'dg': _SPDEV.SectorEditor.dg};
      $.ajax({
        type: 'POST',
	  'dataType': "json",
	  'data': params,
	  'url': 'sector_editor/php/getComparison.php',
	  'success': function(data){
		_SPDEV.SectorEditor.data_compare = data;
		$('#se_sectors').html(_SPDEV.SectorEditor.generateCells(data));
		_SPDEV.SectorEditor.afterload();
	  },
	  'error': function(response) {
	  	console.error(response);
	  }
      });
  };
  
  _SPDEV.SectorEditor.generateCells = function(data) {
      var cell1, cell2, c, content = "";
      var row = "";
      var i = 0;
      while(i<data.length) {
	c = i%2 == 0 ? 'odd' : 'even';
	row = "<div class='se_row "+c+"' id='row_"+i+"'>";
	cell1 = "<div class='cellwrapper'><div class='se_col tab' id='col_import_"+i+"'>"+data[i].import+"</div></div>";
	cell2 = "<div class='cellwrapper'><div class='se_col tab' id='col_sector_"+i+"'>"+data[i].sector+"</div></div>";
	row += cell1+cell2+"</div>";
	content += row;
	i++;
      }
      return content;
  };
  
  _SPDEV.SectorEditor.afterload = function() {
      $('div.se_row').on('click',function() { 
	_SPDEV.SectorEditor.rowClick(this.id);
      });
      
      _SPDEV.SectorEditor.loadingOff();
  };
  
  
  _SPDEV.SectorEditor.rowClick = function(id) {
	var d = $('div.se_wrapper_chooser > .head').css('color');
	if (d != "rgb(255, 255, 255)") {
	  $('div.se_wrapper_chooser > .head').css('color','#ffffff');
	  $('div.se_col.chooser').css('color','#666666');
	}
	if (this.prevSelect) {
	    var c = this.prevSelect.split("_");
	    var d = c[1]%2 == 0 ? '#f9f9fc' : '#eceef5';
	    $('#'+this.prevSelect).css("background","none");
	    $('#'+this.prevSelect).css("backgroundColor",d);
	}
	$('#'+id).css("background"," url('sector_editor/img/h2_sel.png')");
	this.prevSelect = id;
	var x = id.split("_");
	this.compare_selected = x[1];
	$('div.se_col.chooser').on('click',function() { 
	  _SPDEV.SectorEditor.chooseClick(this.id);
	});
  };

  _SPDEV.SectorEditor.chooseClick = function(id) {
	if (this.prevChooserSelect) {
	    var c = this.prevChooserSelect.split("_");
	    $('#'+this.prevChooserSelect).css("color","#666666");
	    $('#'+this.prevChooserSelect).css("backgroundColor","#ffffff");
	}
	$('#'+id).css("backgroundColor","#333333");
	$('#'+id).css("color","#ffffff");
	this.prevChooserSelect = id;
	var x = id.split("_");
	this.sector_selected = x[2];
	$('#assign').on('click',function() { 
	  _SPDEV.SectorEditor.updateSector();
	});
  };
  
  _SPDEV.SectorEditor.updateSector = function() {
	_SPDEV.SectorEditor.loadingOn();
	var p = {};
	p.a_id = this.data_compare[this.compare_selected].a_id;
	p.c_id = this.data_sector[this.sector_selected].c_id;
	p.method = "replace";
	$.ajax({
	  type: 'POST',
	    'dataType': "json",
	    'data': p,
	    'url': 'sector_editor/php/updateSector.php',
	    'success': function(data){
		if(data == "t") {
		  $('#col_sector_'+_SPDEV.SectorEditor.compare_selected).html(_SPDEV.SectorEditor.data_sector[_SPDEV.SectorEditor.sector_selected].name);
		  $('#alldone').on('click', function() {
		       _SPDEV.SectorEditor.submitChanges();
		  });
		  _SPDEV.SectorEditor.loadingOff();
		}
	    },
	    'error': function(response) {
		  _SPDEV.SectorEditor.loadingOff();
	    }
	});  
  };
  _SPDEV.SectorEditor.submitChanges = function() {
	_SPDEV.SectorEditor.loadingOn();
	$.ajax({
	  type: 'POST',
	    'dataType': "json",
	    'url': 'sector_editor/php/submitChanges.php',
	    'success': function(data){
		if(data.response == 200) {
		    alert("Sectors successfully changed");
		}
		_SPDEV.SectorEditor.loadingOff();
	    },
	    'error': function(response) {
		  _SPDEV.SectorEditor.loadingOff();
	    }
	});  
  };
  _SPDEV.SectorEditor.loadingOff = function() {
      $('#loading_bg').hide();
      $('#loading_main').hide();
  };
  _SPDEV.SectorEditor.loadingOn = function() {
      $('#loading_bg').show();
      $('#loading_main').show();
  };
  _SPDEV.SectorEditor.compare = function(a,b) {
    if (a.name < b.name)
      return -1;
    if (a.name > b.name)
      return 1;
    return 0;
  };