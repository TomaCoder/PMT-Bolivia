_SPDEV = _SPDEV || {};

_SPDEV.FacetFilter = {};

_SPDEV.FacetFilter.init = function(facet, facetType, filterStore, appendToEl, opts){
	
	var facet,
		facetFilterCollection,
		view,
		options,
		topN,
		active,
		showColors;
	
	options = opts || {};
	
	topN = options.topN || 999;
	
	if(typeof options.active === 'boolean') {
		active = options.active;
	} else {
		active = false;
	}

	if(typeof options.showColors === 'boolean') {
		showColors = options.showColors;
	} else {
		showColors = false;
	}
		
	facetFilterCollection = new _SPDEV.FacetFilter.Collection({selectionStore: filterStore});
	
	facetFilterCollection.reInitialize(facet, facetType);
	
	view = new _SPDEV.FacetFilter.CollectionView({collection: facetFilterCollection, options: {topN: topN}});
	
	view.render();
	
	if(active) {
		view.open(facet.id);
	}
	
	if(showColors) {
		view.$el.find('.swatch').show();
	}
							
							
	$(appendToEl).append(view.el);
						
						
};
	
_SPDEV.FacetFilter.Model = Backbone.Model.extend({
		defaults : {'state': true, 'color': null}
});

_SPDEV.FacetFilter.Collection = Backbone.Collection.extend({
	
		constructor: function (options) {
	    				
	    	Backbone.Collection.apply( this, {model: _SPDEV.FacetFilter.Model} );
	    	
	    	this.selectionStore = options.selectionStore;
						
		},
		
		reInitialize: function(facet, facetType) {
			
			
			this.facetId = facet['id'];
			this.facetName = facet['name'];
			
			// Reference the property in the filter selection store that stores the currently selected filter values
			switch(facetType) {
				case 'taxonomy':
					this.selectedFacetValues = this.selectionStore['classifications'][this.facetId];
					break;
				case 'organization':
					this.selectedFacetValues = this.selectionStore['organizations'];
				default:
			}
			
			var self = this;
			
			// Use the data to create models that get added to the collection
			_.each(facet['values_arr'], function(classification, i){
				
				// Use this record to creata a Backbone model, add the model to the collection 
				var model = new  _SPDEV.FacetFilter.Model(classification);
				
				self.add(model);
			});
			
		},
		
		getStateTrue: function(){
			
			var self = this;
			
			this.selectedFacetValues.length = 0;
			
			this.each(function(model){
				if(model.get('state') ===  true) {
					self.selectedFacetValues.push(model.get('id'));
				}
			});
			
			if(this.selectedFacetValues.length === 0) {
					this.selectedFacetValues.push('-999999');
			}
			
			// Fire the 'scrape up' function of the filter
			this.selectionStore.scrapeUpFilters();
		},
		
		
});
	
_SPDEV.FacetFilter.CollectionView = Backbone.View.extend({
		
		initialize: function (args) {
		
			var self = this;
			var modelView;
			
			this.active = false;
			
			this.topN = args.options.topN || 999;
			
	    	// Create an array property that will store model views contained in this collection view
	    	this.allViews = []
	    	this.topNViews = [];
	    	this.bottomNViews = [];
	    	
	    	// Loop thru the collection
	    	this.collection.forEach( function(colModel, index) {
	    		
	    		// Model view for top 15
	    		if (index < self.topN) {
		    		// Create a view for each model contained in this view's referenced collection - each view is a WMS list-item			
				    modelView = new  _SPDEV.FacetFilter.ModelViewTopN({model:colModel, 'subclass': '_SPDEV.FacetFilter.ModelViewTopN'});
				    
				    // Store this in the collection view's componentView array
				    self.topNViews.push(modelView);
				    self.allViews.push(modelView);
			    }
			    else {
			    	
			    	modelView = new  _SPDEV.FacetFilter.ModelViewBottomN({model:colModel, 'subclass': '_SPDEV.FacetFilter.ModelViewBottomN'});
				    
				    // Store this in the collection view's componentView array
				    self.bottomNViews.push(modelView);
				    self.allViews.push(modelView);
			    }
			});
			
			amplify.subscribe('updateColorSwatches', this, this.updateColorSwatches);
			amplify.subscribe('closeControlPanelItems', this, this.close);
			amplify.subscribe('openControlPanelItems', this, this.open);
			
		},
		
		events : {
			'click .section-header' : 'onHeaderClick',
			'click .other-item' : 'otherClick',
			'click .slide-toggle' : 'otherSlideToggle',
			'click .allNone' : 'allNoneClick'
		},
		
		updateColorSwatches: function(publishedData){
			
			if(publishedData.facetId == this.collection.facetId) {
				this.$el.find('.swatch').show();//show
			} else {
				this.$el.find('.swatch').hide();//hide
			}
		},
		
		onHeaderClick: function(e){
			
			if(!this.$el.find('.section-header').hasClass('opened')) {
				
				amplify.publish('closeControlPanelItems', this.el);
				amplify.publish('openControlPanelItems', this.collection.facetId);
				//this.$el.parent('.data-source-control-wrapper').find('div.selection-list-wrapper:visible').slideToggle();
				//this.$el.parent('.data-source-control-wrapper').find('.section-header').toggleClass('opened', false);
				//$(this.selectListWrapper).slideToggle();
				//this.$el.find('.section-header').toggleClass('opened');
			}

		},
		
		close: function(elementBeingOpened){
			
			if(this.el === elementBeingOpened) {
				return;
			}

			if(this.$el.find('.section-header').hasClass('opened')) {
				$(this.selectListWrapper).slideToggle();
				this.$el.find('.section-header').toggleClass('opened');
			}
			
		},
		
		open: function(facetId){
			
			if(this.collection.facetId === facetId) {
				$(this.selectListWrapper).slideToggle();
				this.$el.find('.section-header').toggleClass('opened', true);
			}
			
			
		},
		
		
		allNoneClick: function(e){
			var self = this;
			var itemsNotSelected = this.collection.where({state: false});
			var allState;
			if(itemsNotSelected.length > 0) {
				allState = true;
			}
			else {
				allState = false;
			}
				
			var num = this.allViews.length;
			
			 _.each(this.allViews, function(view, index){
				
				if(index < num - 1){
					// Render the component view
					view.model.set({state: allState}, {fireFilterSequence: false});
				} else {
					view.model.set({state: allState}, {fireFilterSequence: true});
					self.$el.find('.other-selection-item').toggleClass('selected', allState);
					self.$el.find('.selection-item').toggleClass('selected', allState);
				}
			});
			

			
		},
		
		// This view's wrapper css class
		className: 'data-control-section',
		
		// rendering function for this view
		render: function(){
			
			var self = this;
			
			this.$el.append($('<div class="clearfix section-header"><div class="label">'+ this.collection.facetName + '</div></div>'));
			
			this.selectAllNone = $('<p class="allNone"><a>All/None</a></p>');
			
			this.selectListWrapper = $('<div class="selection-list-wrapper"></div>');
			
			$(this.selectListWrapper).append(this.selectAllNone);
			
			var ul = $('<ul class="selection-list"></ul>');
			
			// Render and append each model view of collection (table rows)
			_.each(this.topNViews, function(view){
				
				// Render the component view
				view.render();
				
				// Append the view to this collection view element
				$(ul).append(view.el);
			
			});	
		    
		    if(this.bottomNViews.length > 0 ) {
			    this.otherLi = $('<li class="clearfix selection-item selected other-item"><div class="left swatch" style="background-color: #666"></div><div class="label">Other</div><div class="slide-toggle"></div></li>');
			    
			    this.otherUl = $('<ul></ul>');
			    
			    _.each(this.bottomNViews, function(view, index){
					
					if(index === 0) {
						$(self.otherLi).find('.swatch').css({'background-color': view.model.get('color')});
					}
					// Render the component view
					view.render();
					
					// Append the view to this collection view element
					$(self.otherUl).append(view.el);
				
				});	
				
				
				$(ul).append(this.otherLi);
				$(ul).append($('<li  class="other-items-list"></li>').append(this.otherUl));
			}
			
			$(this.selectListWrapper).append(ul);
			this.$el.append(this.selectListWrapper);
			
		},
		
		otherClick: function(){
			
			var self = this;
			$(this.otherLi).toggleClass('selected');
			
			var otherState = $(this.otherLi).hasClass('selected');
			
			var numOthers = this.bottomNViews.length;
			
			 _.each(this.bottomNViews, function(view, index){
				
				if(index < numOthers - 1){
					// Render the component view
					view.model.set({state: otherState}, {fireFilterSequence: false});
				} else {
					view.model.set({state: otherState}, {fireFilterSequence: true});
					self.$el.find('.other-selection-item').toggleClass('selected', otherState);
				}
			});
			
		},
		
		otherSlideToggle :function(e){
			
			var self = this;
			
			var toggle = e.target;
			
	    	$(toggle).toggleClass('opened');
	    	
	    	$(this.otherUl).slideToggle(function(){
	    		var opened = $(toggle).hasClass('opened');
	    		if(opened){
	    			self.otherLi[0].scrollIntoView(true);
	    		}	
	    	});

	    	e.stopPropagation();
		}
	});

_SPDEV.FacetFilter.ModelView = Backbone.View.extend({
		
		initialize: function(options){
			
			// Listen for changes on the model's "state" attribute; true means the WMS layer should be 'on'
			this.model.bind('change:state', this.onStateChange, this);
			
			this.subclass = options.subclass;
		},
			
		tagName: 'li',
		
		// When this view is click, fire the onClick function
		events: {'click': 'onClick'},
		
		className: 'clearfix selection-item selected',
		
		// Render this view
		render: function(){
			
			this.$el.append(this.template(this.model.attributes));
		},
		
		// Function for view click event
		onClick: function(e){
 			
 			// Whatever the state was before the user click, make it opposite.  (If it was checked, uncheck it). 
 			var state = !this.model.get('state');
 			
 			// Set the new model 'state' value
 			this.model.set({'state': state});
 			
	 	},
	 	
	 	// When the model's state attribute changes, this function fires;  this will add/remove map layer, check uncheck checkboxes
		onStateChange: function(model, collection, options){
			// Get the model's 'state' attribute
			var state = model.get('state');
			var fireFilterSequence;
			
			if( typeof options.fireFilterSequence === 'boolean') {
				
				fireFilterSequence = options.fireFilterSequence;
				
			} else {
				
				fireFilterSequence = true;
			
			}
			
			// state == true
 			if(state) {
 				// Set the view css class appropriately
 				this.$el.addClass('selected');
 							
 			}
 			else {
 				this.$el.removeClass('selected');
 			}
 			
 			if(fireFilterSequence) {
 				this.model.collection.getStateTrue();
 			}
		}
		
});

_SPDEV.FacetFilter.ModelViewTopN = _SPDEV.FacetFilter.ModelView.extend({
		
		// The view's html template
		template: _.template('<div class="left swatch" style="background-color: <%= color %>"></div><div class="label"><%= name %></div>'),
		
		
});

_SPDEV.FacetFilter.ModelViewBottomN = _SPDEV.FacetFilter.ModelView.extend({
		
		className: 'other-selection-item selected',
		
		// The view's html template
		template: _.template('<div class="label"><%= name %></div>'),
				
});
	
