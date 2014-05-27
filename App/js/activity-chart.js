_SPDEV.ActivityChart = {};

// Set up the control panel control that will hold all the charts
_SPDEV.ActivityChart.chartControl = function(appendToEl, headerHTML){
	
	var coll,
		collView,
		chartsControl,
		header,
		contentsWrpper;
	
	// Create the wrapper for the "MAPS control"
	chartsControl = $('<div id="chartsControl" class="data-control-section"></div>');
	
	// Create header
	header = $(headerHTML);
	
	// Append header
	$(chartsControl).append(header);
	
	// Create wrapper for control contents
	contentsWrapper = $('<div class="contents-wrapper"></div>');
	
	// Append 
	$(chartsControl).append(contentsWrapper);
	
	// Append this to the control panel
	$(appendToEl).append(chartsControl);
	
	//////////////////////
	// Add click events //
	//////////////////////
	
	// Click the control header
	$(header).on('click', function(){
		
		// if the maps control is already open, exit
		if($(header).hasClass('opened')){
			return;
		}
		
		// Send a message to close other control panel items
		amplify.publish('closeControlPanelItems', chartsControl);

		// Slide open the contents wrapper of this control
		$(contentsWrapper).slideToggle();
		
		// Give the header the 'opened' class
		$(header).toggleClass('opened');

	});
	
	// Subscribe to a 'close control' notification
	amplify.subscribe('closeControlPanelItems', this, function(elementBeingOpened){
			
		// Check if the 'closeControlPanelItems' publish came from this control item;
		// if so, exit, else we would be closing the item we just opened
		if(elementBeingOpened === mapsControl) {
			return;
		}
		
		// if this control is open, close it and adjust CSS.
		if($(header).hasClass('opened')) {
			
			// Slide contents of this control shut
			$(contentsWrapper).slideToggle();
			
			// Add closed styling to header
			$(header).toggleClass('opened');
		}
			
	});
	
	// Return the contents wrapper so we can append charts to it.	
	return contentsWrapper;
	
};

// A constructor function for creating charts
_SPDEV.ActivityChart.Chart = function(points, pointsSourceUrl, postData, pointUpdateUrl, facet, appendToEl, updateChannel) {
		
		var self = this;
		
		// Keep track of what facet this chart summarizes points for
		this.facet = facet;
		
		// The url that handles updates when user filters by one or more facets
		this.pointUpdateUrl = pointUpdateUrl;
		
		// This div will hold the chart SVG
		this.wrapper = $('<div class="chart-wrapper"></div>').appendTo(appendToEl);
		
		// A loading spinner we see while waitin for chart data
		this.loadingSpinner = $('<div class="wall-to-wall"><div class="absolute-center loading-spinner"><img src="img/loading.gif" /></div></div>').appendTo(this.wrapper);
		
		// Label in the center of the chart that displays facet name
		this.label = $('<div class="absolute-center label">'+_lang.activitiesby+' ' + facet.name + '</div>').appendTo(this.wrapper);
		
		// Caption under chart that display data highlighted from chart
		this.caption = $('<div class="clearfix chart-caption"></div>').appendTo(appendToEl);
		
		// Little colored circle that matches mouseover chart wedge
		this.sectorHighlightSwatch = $('<div class="left swatch"></div>').appendTo(this.caption);
		
		// Label for the mouseover chart wedge
		this.sectorHighlightLabel = $('<p class="left"></p>').appendTo(this.caption);
		
		this.currentXHR = null;
		this.path = null;
		// Subscribe to notices that the data set has been filterd by one or more facets
		amplify.subscribe(updateChannel, this, this.update);
		
		
		// Get data; make charts if a set of points has already been acquired, else do ajax to get the required data
		if(points !== null) {
			this.makeChart(points);
		} else {
			
			// Show the loading spinner
			$(this.loadingSpinner).show();
			
			this.currentXHR = $.ajax({
				type: 'POST',
				data: postData,
				dataType: "json",
			  	url: pointsSourceUrl,
			  	success: function (data, textStatus, jqXHR) {
		    		
		    		if(data !== null) {
			    		self.makeChart(data);
			    	} else {
			    		$(self.wrapper).html('');
			    		$(self.caption).hide();
			    	}
			    	
			    	// Hide the loading spinner
					$(self.loadingSpinner).hide();
			    },
	    
			    error: function (jqXHR, textStatus, errorThrown) {
				  // Hide the loading spinner
				  $(self.loadingSpinner).hide();
				 
			      console.log(jqXHR);
			      console.log(textStatus);
			      console.log(errorThrown);
			      
			    }
			});	
		}
		

};
_SPDEV.ActivityChart.Chart.prototype.update = function(postData){
		var self = this;
		
		if(this.currentXHR){
			this.currentXHR.abort();
		}
		if(this.path){
			this.path.remove();
		}
		
		$(this.wrapper).find('svg').remove();
		
		$(this.loadingSpinner).show();
			$.ajax({
				type: 'POST',
				data: postData,
				dataType: "json",
			  	url: this.pointUpdateUrl,
			  	success: function (data, textStatus, jqXHR) {
		    		
		    		if(data !== null) {
			    		self.makeChart(data);
			    		$(self.caption).show();
			    	} else {
			    		$(self.wrapper).html('');
			    		$(self.caption).hide();
			    	}
			    	// Hide the loading spinner
					$(self.loadingSpinner).hide();
			    },
	    
			    error: function (jqXHR, textStatus, errorThrown) {
				  // Hide the loading spinner
				  $(self.loadingSpinner).hide();
				 
			      console.log(jqXHR);
			      console.log(textStatus);
			      console.log(errorThrown);
			      
			    }
			});	
};
_SPDEV.ActivityChart.Chart.prototype.makeChart = function(points){
	

	var facetValues,
		facetOtherColor,
		data,
		tmpDataset,
		dataset,
		width,
	    height,
	    radius,
	    wrapper,
	    color,
	    pie,
	    arc,
	    svg,
	    path,
	    rIdArr,
	    rId,
	    self = this;
		
		data = {};	
		
		facetValues = this.facet.values_keyVal;
		facetOtherColor = this.facet.otherColor;
		
		// Loop through the clusters points and summarize the points by counts per unique attribute (stored in the 's' property)
		for (var j = 0, jMax = points.length; j < jMax; j ++) {
			
			// Split the comma delimited string of reporting ids
			rIdArr = points[j]['r_ids'].toString().split(',');
			
			// Loop
			for (var k = 0, kMax = rIdArr.length; k < kMax; k++) {
				
				// this iteration's reporting id	
				rId = rIdArr[k];	
				
				// If we have already come across this id before (and started a count of its frequency), increment the count
				if(data.hasOwnProperty(rId)) {
					data[rId]['count']++; 
				}
				else if (rId === ''){
					// Null report id's come through as an empty string because this starts as a comma delimited string
					//  We're assigning null ids to a pseudo-id of -9999
					
					// Increment the count of -9999 
					if(data.hasOwnProperty('-9999')) {
						data['-9999']['count']++; 
					}
					else {
						// if this is the first null id, create an object property and start the counter
						data['-9999'] = {
						'count': 1,
						'color': facetOtherColor,
						'alias': 'Not assigned'
						};
					}
				} 
				else if(typeof facetValues[rId] === 'undefined') {
					
				}
				else {
					
					// if this is the first time we see this id, create an object property and start the counter
					data[rId] = {
						'count': 1,
						'color': facetValues[rId].color,
						'alias': facetValues[rId].name
						};
				}

			}
	
		}

		// prep dataset for D3; need a temp dataset to deal with merging of data counts for 'other' category
		tmpDataset = [];
		dataset = [];
		
		// Push properties from object holding the category counts/colors categories into an object array
		for (var j in data) {
			tmpDataset.push(data[j]);	
		}
		
		// Create an object that will merge the count from all classification catergories that we've deemed as 'other''
		var mergedOther = {
						'count': 0,
						'color': facetOtherColor,
						'alias': 'other'
					};
		
		// Merge all 'other' objects; we determine which are 'other' by testing to see if its been assigned the 'other' color		
		for (var k = 0, kMax = tmpDataset.length; k < kMax; k++) {
			
			if(tmpDataset[k].color === facetOtherColor) {
				mergedOther.count = mergedOther.count + tmpDataset[k].count;
			} else {
				dataset.push(tmpDataset[k]);
			}
		}
		
		// Add the merge objedt to the dataset we will use in donut chart
		dataset.push(mergedOther);
		
		// Order the data set by activity count Descending
		dataset = _.sortBy(dataset, function(obj){return obj.count}).reverse(); 
		
		// Use jQuery to get this cluster markers height and width (set in the CSS)
		width = $(this.wrapper).width();
		height = $(this.wrapper).height();
		radius =  (Math.min(width, height) / 2) - 10;
		
		
		// D3 donut chart boilerplate
		
		pie = d3.layout.pie()
		    	.sort(null);
		
		arc = d3.svg.arc()
		    .innerRadius(radius-radius * 0.4)
		    .outerRadius(radius);
		
		var arcOver = d3.svg.arc()
        	.outerRadius(radius + 10)
        	.innerRadius((radius-radius * 0.4) + 10);
        	
		// Note that we add 'clusterDonut' as a selector
		svg = d3.select(this.wrapper[0]).append("svg")
		    .attr("width", width)
		    .attr("height", height)
		    .append("g")
		    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
		
			this.path = svg.selectAll("path")
					.data(function(){
						    	var dataObjArr,
						    		dataArr,
						    		pieData;
						    		
						    	dataObjArr = dataset;
						    	
						    	dataArr = [];
						    	
						    	for (var i = 0, iMax = dataObjArr.length; i < iMax; i++) {
						    		dataArr.push(dataObjArr[i]['count']);	
						    	}
						    	
						    	pieData = pie(dataArr);
						    	
						    	for (var i = 0, iMax = pieData.length; i < iMax; i++) {
						    		pieData[i].data = dataObjArr[i];	
						    	}
						    	
						    	return pieData;
		    				})
		  				.enter().append("path")
		    			.attr("fill", function(d, j) { 
								    	return d.data.color; 
								    	})
		    			.attr("d", arc)
		    			.attr("cursor","pointer")
	      				.attr("cursor","pointer")
				      .on("mouseover", function(d, i) {
				      		
				      		// clear previously active chart wedge
				      		d3.select(self.wrapper[0]).selectAll('path').transition()
					      		.duration(100)
					      		.attr("d", arc)
					      		.attr('opacity',1)
					      		.attr('stroke-width',1)
					      		.attr('stroke','rgb(255,255,255)');
				      		
				      		// Make the mouseover wedge active
				      		d3.select(this)
					      		.transition()
					      		.duration(100)
					      		.attr("d", arcOver)
					      		.attr('opacity',0.8)
					      		.attr('stroke-width',2)
					      		.attr('stroke','rgb(255,255,255)');
					      	
					      	// Make apprpriate label	
				      		$(self.sectorHighlightSwatch).css('background-color', d.data.color);
				      		$(self.sectorHighlightLabel).html(d.data.alias);
				      		
				      		// Show the label if currently hidden
				      		if($(self.caption).css('display') === 'none') {
				      			$(self.caption).slideToggle();
				      		}
				      	})
				      //.on("mouseout", function(d,i) {})
				      	.each(function(d, i) {
				      		
				      		// on load, we want the largest chart wedge to be activew
				      		if(i !== 0  ){
				      			return;
				      		}
				      		
				      		d3.select(this)
					      		.transition()
					      		.duration(100)
					      		.attr("d", arcOver)
					      		.attr('opacity',0.8)
					      		.attr('stroke-width',2)
					      		.attr('stroke','rgb(255,255,255)');
					      	
					      	// make the label	
				      		$(self.sectorHighlightSwatch).css('background-color', d.data.color);
				      		$(self.sectorHighlightLabel).html(d.data.alias);
					      		
				      		if($(self.caption).css('display') === 'none') {
				      			$(self.caption).slideToggle();
				      		}
				      	});

};
