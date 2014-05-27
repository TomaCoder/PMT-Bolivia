_SPDEV.Infobox = {};
Number.prototype.formatMoney = function(c, d, t){
 var n = this, 
    c = isNaN(c = Math.abs(c)) ? 2 : c, 
    d = d == undefined ? "." : d, 
    t = t == undefined ? "," : t, 
    s = n < 0 ? "-" : "", 
    i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", 
    j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 }; 
_SPDEV.Infobox.Manager = function(appendToEl){
	
	var self,
		closer,
		prevActivity,
		nextActivity;
	
	// HTML shell/wrapper of infobox	
	this.shell = $('<div id="infoBox"><header class="clearfix"><span id="infoBoxPage">x '+_lang.of+' N</span><div class="right close icon-close-01"></div></header>'
				+ '<footer id="infoBoxFooter"><div id="prevActivity"></div><div id="nextActivity"></div></footer></div>').appendTo(appendToEl);
	
	// Store the reference to the page number wrapper
	this.infoBoxPage = $(this.shell).find('#infoBoxPage');
	
	// Reference the close button
	closer = $(this.shell).find('.close');
	
	// Reference the Previous button
	prevActivity = $(this.shell).find('#prevActivity');
	
	// Reference the next button
	nextActivity = $(this.shell).find('#nextActivity');
	
	// Property to store the activity ids represented by points in a given cluster
	this.activityIds = null;
	
	// Create an empty collection
	this.activityCollection = new Backbone.Collection();
	
	// Array for storing the collection model indices for the current collection
	this.collIndices = [];
	
	//  Collection view for the activity detail views for each activity in cluster
	this.activityViews = new _SPDEV.Infobox.CollectionView({collection: this.activityCollection});
	
	//  Append the collection view after the header tag in the infobox shell
	$(this.shell).children('header').after(this.activityViews.el);
	
	//  Currently active activity index;  First activity in a cluster will have index 0
	this.currentActivityIndex = null;
	
	// Subscribe to showInfobox notification
	amplify.subscribe('showInfobox', this, this.updateContent);
	
	self = this;
	
	//  Set event on close button
	$(closer).on('click', function(){
		
		$(self.shell).hide();
		amplify.publish('removeActiveCluster');
	});
	
	// Set event on next button
	$(nextActivity).on('click', $.proxy(this.next, this));
	
	// Set event on previous button
	$(prevActivity).on('click', $.proxy(this.prev, this));
	
};

//  What happens when previous button is clicked
_SPDEV.Infobox.Manager.prototype.prev = function() {
	
	
	var prevIndex,x,n, collModel;
	
	// Set the prev index
	prevIndex = this.currentActivityIndex - 1;
	
	// Can't be less than zero
	if(prevIndex < 0) {
		return;
	} else {
		
            this.activityCollection.forEach(function(collModel){ collModel.set({active: false})});
        
		// Get the model at this index	
		collModel = this.activityCollection.at(prevIndex);
		
		// Set the current activity to inactive
		this.activityCollection.at(this.currentActivityIndex).set({active: false});
		
		// make the previous activity active
		collModel.set({active: true})
	}
	
	// Update the page counter
	x = prevIndex + 1;
	
	n = this.activityIds.length;
	
	$(this.infoBoxPage).html(x + ' of ' + n);
	
	// Update the current activity index
	this.currentActivityIndex = this.currentActivityIndex - 1;
};

// Next button functionality
_SPDEV.Infobox.Manager.prototype.next = function() {
	
	var nextIndex,
		a_id,
		x, n;
	
	nextIndex = this.currentActivityIndex + 1;
	
	if(nextIndex >= this.activityIds.length) {
		return;
	}
	
    this.activityCollection.forEach(function(collModel){ collModel.set({active: false})});
	var modelMatches = this.activityCollection.where({'activity_id': this.activityIds[nextIndex]});
	
	// if a model with this activity id already exists
	if(modelMatches.length > 0) {
		
		this.activityCollection.at(this.currentActivityIndex).set({active: false});
		
		modelMatches[0].set({active: true});
		
	} else {
		
		a_id = this.activityIds[nextIndex];
		
		this.getDetails(a_id);
		
	}
	
	x = nextIndex + 1;
	n = this.activityIds.length;
	
	$(this.infoBoxPage).html(x + ' '+_lang.of+' ' + n);
	
	this.currentActivityIndex = this.currentActivityIndex + 1;
};


_SPDEV.Infobox.Manager.prototype.updateContent = function(locationIds){
	var self = this;
	
	// Reset
	this.activityIds= null;
	
	// Destroy views
	if(this.activityViews !== null) {
		this.activityViews.destroy();
	}
	
	// Destroy models
	while (model = this.activityCollection.first()) {
	  model.destroy();
	}
	
	// Get cluster's activity ids
	$.ajax({
		type: 'POST',
		data: {l_ids : locationIds},
		dataType: 'json',
		url: 'php/getProjectsActivitiesBrief.php',
			  	success: function (data, textStatus, jqXHR) {
		    	
			    	self.activityIds = data;
			    	
			    	self.getDetails(self.activityIds[0]);
			    	
			    	self.currentActivityIndex = 0;
			    	
			    	$(self.infoBoxPage).html('1 '+_lang.of+' ' + self.activityIds.length);
			    },
	    
			    error: function (jqXHR, textStatus, errorThrown) {

			    	console.error(jqXHR.responseText);

			    }
				

	});
	
	// Show the infobox
	$(this.shell).show();
	
	this.currentActivityIndex = 0;
	
};

// get activity details
_SPDEV.Infobox.Manager.prototype.getDetails = function(a_id) {
	
	var self = this;
	
	// Temporaily remove click events so users can't keep clicking during server call
	$(nextActivity).off('click');
	
	$(prevActivity).off('click');
	
	$.ajax({
		type: 'GET',
		data: {id : a_id},
		dataType: 'json',
		url: 'php/getActivityDetailsNew.php',
			  	success: function (data, textStatus, jqXHR) {
		    	
		    		//  Make a new model and add to collection
			    	var model = new Backbone.Model(data);
			    	
			    	self.activityCollection.add(model);
			    	
			    	// Add back the click events
			    	$(nextActivity).on('click', $.proxy(self.next, self));
	
					$(prevActivity).on('click', $.proxy(self.prev, self));
	
			    },
	    
			    error: function (jqXHR, textStatus, errorThrown) {
			    }
				

	});
	
	
};

_SPDEV.Infobox.Model = Backbone.Model.extend({defaults: {active: false}});

_SPDEV.Infobox.ModelView = Backbone.View.extend({
	
	initialize: function(){
		
		this.model.bind('change:active', this.onStateChange, this);
	},
	
	onStateChange: function(model, collection, options){
		
		if(model.get('active') === true) {
			
			this.$el.show();
			
		} else {
			this.$el.hide();
		}
		
	},
	
	className: 'infobox-content',
	
	template: _.template("<img src='img/loading.gif'/>"),
			/* '<div class="infoBoxName"><%= title %></div>'
			+ '<div class="infoBoxDesc"><span class="infoBoxDescTitle">Description: </span><%= desc %></div>'
			+ '<div class="infoBoxDesc"><span class="infoBoxDescTitle">Sector: </span><%= sectors %></div>'
			+ '<div class="infoBoxDesc"><span class="infoBoxDescTitle">Financiador(s): </span><%= orgs %></div>'
			+ '<div class="infoBoxDesc"><span class="infoBoxDescTitle">Costa Total: </span><%= amount %></div>'
			+ '<div class="infoBoxDesc"><span class="infoBoxDescTitle">Fechas: </span><%= start_date %> - <%= end_date %></div>'
	), */
	
	render: function(){
		
		var data = this.model.attributes;
		
		
		var c = data.length -1;
 

		var content = "";

         _.each(data, function(value, label){

		      if (label != "a_id"){

		      content += label ? '<div class="infoBoxDesc"><div class="infoBoxDescTitle">' + label + ': </div>'+value+'</div>' : '';

		  		}

		      });


		var el = $('div[data-a_id='+data.a_id+']').find('.listViewDetails').html(content);
		
		// this.$el.html(this.template(attributes));
		this.$el.html(content);
	}
	
});

_SPDEV.Infobox.Collection = Backbone.Collection.extend({
	

});
_SPDEV.Infobox.CollectionView = Backbone.View.extend({
	
	initialize: function (options) {
		
		var self = this;
		
    	// Create an array property that will store model views contained in this collection view
    	this.componentViews = [];

		this.collection.bind('add', this.onAdd, this);
	},
	
	onAdd: function(model, collection, options){
		
		var view = new _SPDEV.Infobox.ModelView({model:model});
		
		view.render();
		
		this.$el.append(view.el);
		
		this.componentViews.push(view);
		
		collection.forEach(function(collModel){
			
			if(collModel.get('active') === true) {
				collModel.set({active: false});
			}
			
		});
		
		model.set({active: true});
		
	},
	
	// This view's wrapper css class
	className: 'infobox-content-wrapper',
	
	// rendering function for this view
	destroy: function(){
		
		_.each(this.componentViews, function(view){
			view.remove();
			view.unbind();
		});
		
	    
	}
});
