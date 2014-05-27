_SPDEV.ListView = {};

_SPDEV.ListView.Manager = function(updateChannel, dataGroupId, countryIds, sectorLanguage){
	var self = this;
	this.el =  $('<div class="list-view-wrapper"> \
					   <div class="list-view-content"></div> \
					    <div class="list-view-footer"> \
					    	<div> \
						      <div class="list-view-prev">< Previous</div> \
						      <div class="list-view-row-count"></div> \
						      <div class="list-view-next">Next ></div> \
					     	</div> \
					    </div> \
					  </div>');
				  
	this.rowCount = $(this.el).find('.list-view-row-count');
	this.contentWrapper = $(this.el).find('.list-view-content');		  
	this.footerControls = $(this.el).find('.list-view-footer > div > div');
	//_ListView.numrows = null;
	
	// Default params for querying the data
	this.params = {};
	this.params.offset = 0;
	this.params.orderby = "a_name";
	this.params.order = "ASC";
	this.params.filterSector = "";
	this.params.filterOrg= "";
	this.params.src = dataGroupId;
	this.params.country = countryIds;
	this.params.sectorcode = 3;
	this.params.sector = 3; // Sector taxonomy ID
	this.params.donor = 2; // Organisation taxonomy ID
	this.params.sectorLanguage = sectorLanguage;
	// Create the header
	 this.header = this.createHeader();
	 
	 $(this.header).find('.name').on('click', $.proxy(function(){
	 	this.sortByHeader('a_name');
	 }, this));
	 $(this.header).find('.org').on('click', $.proxy(function(){
	 	this.sortByHeader('f_orgs');
	 }, this));
	 $(this.header).find('.sector').on('click', $.proxy(function(){
	 	this.sortByHeader('tax1');
	 }, this));
	 
      $('<div class="list-view-header"></div>').append(this.header).prependTo(this.el);
      

      // Load the data from an AJAX call.
      this.loadData();

      // set onclick events for the next and prev buttons (pagination)
      $(this.el).find('.list-view-next').on('click', $.proxy(function() {
		  
		  // this.params.page is the current page and is about to be incremented;
		  if (this.params.page === this.totalpages) {
		  	return;
		  }
		  
		  if (this.params.page + 1 === this.totalpages) {
	    	 $(this.el).find('.list-view-next').invisible();
	      }
		    
	      if (this.params.page + 1 > 1) {
	    	 $(this.el).find('.list-view-prev').visible();
	      }
	    
	      this.params.offset += 100;
	      $('#listViewloading').show();
	      this.loadData();
  
      }, this));
      
      $(this.el).find('.list-view-prev').on('click', $.proxy(function() {
		  
		  // this.params.page is the current page and is about to be decremented;
		  if (this.params.page === 1) {
		  	return;
		  }
		  	
	  	  if (this.params.page - 1 === 1) {
	    	 $(this.el).find('.list-view-prev').invisible();
	      } 
	      
	      if (this.params.page - 1 < this.totalpages) {
	    	 $(this.el).find('.list-view-next').visible();
	      }
		     
		    this.params.offset -= 100;
		    
		    $('#listViewloading').show();
		    this.loadData();
		  
      }, this));  
      
      // subscribe to when the sector and/or donors are filtered.
      amplify.subscribe(updateChannel, this, this.filterRows);
      
      amplify.subscribe('listViewVisible', this, function(){
      	
      	this.resizeListView();
      	
      });
        
      $(window).resize(function(){
      	
      	if($(self.el).is(":visible")){ 
      		self.resizeListView();	
      	}
      	
      });
};

_SPDEV.ListView.Manager.prototype.loadData = function(offset, orderby, order) {
	var self = this;
	
	var params = {
		'offset' : this.params.offset,
		'orderby' : this.params.orderby,
		'order' : this.params.order,
		'sectors' : this.params.filterSector,
		'orgs' : this.params.filterOrg,
		'src' : this.params.src,
		'country': this.params.country,
		'sectorcode' : this.params.sectorcode,
		'language' : this.params.sectorLanguage
	}; 
    
    $('#listViewloading').show();
    
    $.ajax({
      type: 'POST',
	  'dataType': "json",
	  'data': params,
	  'url': 'php/getActivitiesList.php',
	  'success': function(data){
		
		if(data === null) {
			$(self.contentWrapper).html('');
			$(self.footerControls).hide();
			$('#listViewloading').hide();
			return;
		}
		
		$(self.footerControls).show();
		self.render(data.rows);
		self.params.numrows = data.count;
		self.params.page = data.page;
		self.params.totalpages = data.tot;
		
		// Set the content of the footer (number of pages, etc)
		var content = "";
		if (data.count != ""){
		   content = "Page " + data.page +" of " + data.tot + " | Total Records: "+data.count;
		   $(self.rowCount).html(content);
		}
		
		$('#listViewloading').hide();
	  },
	  'error': function(response) {
	  	console.error(response);
	  	$('#listViewloading').hide();
	  }
	});
 };
/*
  _ListView.toggleDataSet = function() {
      if (_SPDEV.DataSources.Data.Gov.isActive) {
	  _ListView.params.src = 769;
	  var d = _SPDEV.DataSources.Data.Gov;
      } else {
	  _ListView.params.src = 772;
	  var d = _SPDEV.DataSources.Data.Donor;
      }
      _ListView.params.sectorcode = d.FILTER_TAXONOMY_IDS;
      _ListView.params.filterSector = '';
      _ListView.params.filterOrg = '';
      _ListView.params.offset = 0;
      _ListView.loadData(_ListView.params.offset, _ListView.params.orderby, _ListView.params.order);
  }
  */

 
_SPDEV.ListView.Manager.prototype.render = function(data) {
  	  var self = this;
      $(this.contentWrapper).html('');
      var tmp = $('<div></div>');
      
      $.each(data, function(i,row) {
      	 var tableRow = self.createRow(row);
      	
      	 var details = _.template('<div class="listViewDetails"><img src="img/loading.gif" style="margin-left:40%;padding-bottom:20px"></div>');			// Don't shoot me for this Rich.
      							
      	 $(tableRow).append(details(row))
	 $(tmp).append(tableRow);
      });
      
      $(self.contentWrapper).append($(tmp).html());
      
      $(self.contentWrapper).find('.data-row').on('click', function(){
	if(!$(this).find('.listViewDetails').is(':visible')) {
	  $(this).find('.listViewDetails').show();
	  var params = {'id': $(this).attr('data-a_id')};
	  $.ajax({
	    type: 'GET',
		'dataType': "json",
		'data': params,
		'url': 'php/getActivityDetailsNew.php',
		'success': function(data){
		      var content = "";
		    

		      _.each(data, function(value, label){

		      if (label != "a_id"){

		      content += label ? '<div class="listview_details"><div class="listview_lbl">' + label + ': </div>'+value+'</div>' : '';

		  		}

		      });

		      var el = $('div[data-a_id='+data.a_id+']').find('.listViewDetails').html(content);
		},
		'error': function(response) {
		      console.error(response);
		}
	  });
	} else {
	  $(this).find('.listViewDetails').hide();
	}
      });
 };


    
  // Create a row in the list view
_SPDEV.ListView.Manager.prototype.createRow = function(row) {
      var record = "<div class='row data-row' data-a_id="+row.a_id+">";
      record += "<div class='cell' >"+row.a_name+"</div>";
      record += "<div class='cell'>"+row.i_orgs+"</div>";
      record += "<div class='cell'>"+row.tax1+"</div>";
      record += "</div>";
      return $(record);
 };
  
  // Create the header row.  This doesn't really need to be JS, but it is simpler.
_SPDEV.ListView.Manager.prototype.createHeader = function() {
      var record = "<div class='row rowheader' id='listview_header'>";
      record += "<div class='cell header name active'><div class='listviewheadertitle'>Nombre</div><div class='arrow'></div></div>";
      record += "<div class='cell header org' id='listview_header_o'><div class='listviewheadertitle'>Implementador</div><div class='arrow'></div></div>";
      record += "<div class='cell header sector' id='listview_header_s'><div class='listviewheadertitle'>Sector</div><div class='arrow'></div></div>";
      record += "</div>";
      return $(record);
 };
  
  // Sort the data by the header that is clicked.
_SPDEV.ListView.Manager.prototype.sortByHeader = function(orderby) {
    this.changeActiveHeader(orderby);
    if (orderby == this.params.orderby) 
      

	  if(this.params.order == "ASC") {
		 this.params.order = "DESC";
		 $(this.header).find('.active .arrow').css('background-image', 'url(img/listView_up.png)');
	  } else {
		 this.params.order = "ASC";
		 $(this.header).find('.active .arrow').css('background-image', 'url(img/listView_down.png)');
	  }


    else
      this.params.order = "ASC";
    
    this.params.orderby = orderby;
    this.params.offset = 0;	// if we are resorting by a header, return to first page
    this.loadData();
  };

_SPDEV.ListView.Manager.prototype.changeActiveHeader = function(orderByProp) {
    // this is a hack to get the correct header to show up. JQuery/CSS nightmare.
      $(this.header).find('.cell.header').removeClass('active');
      $(this.header).find('.cell.header').css('background-image','none');
      
      switch(orderByProp) {
      	case 'a_name':
      		$(this.header).find('.cell.header.name').addClass('active');
      		break;
      	case 'i_orgs':
      		$(this.header).find('.cell.header.org').addClass('active');
      		break;
      	case 'tax1':
      		$(this.header).find('.cell.header.sector').addClass('active');
      		break;

      	default:
      		return;
      }

 };
 

  


  


  // Changes when you click on a specific header
 
 
  
 // Filter for sector and/or donor
_SPDEV.ListView.Manager.prototype.filterRows = function(data) {
     
     this.params.sectorcode = data.summaryTaxId;
      this.params.filterSector = data.classificationIds;
      this.params.filterOrg = data.organizationIds;
      this.params.offset = 0;
      this.loadData();

 };

 

  // Basic resize function
_SPDEV.ListView.Manager.prototype.resizeListView = function() {
	var contentHeight = $(this.el).parent().innerHeight();
	var contentWidth = $(this.el).parent().innerWidth();
	$(this.el).height(contentHeight -35);
	$(this.el).width(contentWidth);
	$(this.contentWrapper).height(contentHeight - 115);
	$(this.el).find('.cell').width(((contentWidth)/3) - 25);
  }

  
  
  
  
  
  
  
  
  
  
  