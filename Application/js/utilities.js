_SPDEV.Utilities = {};


_SPDEV.Utilities.Tabs = function(navUl, tabWrapper, callback){

        $(navUl).children('li').on('click', function(e){
                
                var clickedTab,
                        linkedDivSelector;

                clickedTab = e.target;

                if(!$(clickedTab).hasClass('active')) {

                        $(tabWrapper).children('.tab-content').toggleClass('cloak', true);

                        linkedDivSelector = $(clickedTab).attr('href');

                        $(linkedDivSelector).removeClass('cloak', false);

                        $(navUl).children('li').toggleClass('active', false);

                        $(clickedTab).toggleClass('active', true);

                }
                
                if(typeof callback === 'function') {
                        callback();
                }
        });
};


_SPDEV.Utilities.StretchMe = function(elToStretch, container, dimension, reductionEls){
	var i,
		iMax,
		padding,
		margin,
		self = this;

	this.container = $(container);
	this.dimension = dimension;
	this.elToStretch = {};
	this.trim = 0;
	this.elToStretch.el = $(elToStretch);
	
	if(typeof reductionEls === 'undefined') {
			this.reductionEls = [];
	}
	else {
			this.reductionEls = reductionEls;
	}

	// Determine the padding and margin applied to the dimension of concern
	if(dimension === 'height'){
		padding = parseInt($(elToStretch).css('padding-top')) + parseInt($(elToStretch).css('padding-bottom'));
		margin = parseInt($(elToStretch).css('margin-top')) + parseInt($(elToStretch).css('margin-bottom'));

	}
	else if (dimension === 'width') {
		padding = parseInt($(elToStretch).css('padding-left'))+ parseInt($(elToStretch).css('padding-right'));
		margin = parseInt($(elToStretch).css('margin-left')) + parseInt($(elToStretch).css('margin-right'));
	}

	this.elToStretch.dimMarginPadding = padding + margin;

	//  The "trim" is the sum of all of the outer heights or widths of the non-stretched elements in the container
	for(i = 0, iMax = this.reductionEls.length; i < iMax; i++){

		if(dimension === 'height'){
			this.trim = this.trim + $(reductionEls[i]).outerHeight();
		}
		else if (dimension === 'width') {
			this.trim = this.trim + $(reductionEls[i]).outerWidth();
		}
	}

	// Stretch it now
	this.stretch();

	// Stretch it on window resize
	$(window).resize(function(){
		self.stretch();
		//resizeListView();
	});

	return this;
};


_SPDEV.Utilities.StretchMe.prototype.stretch = function(){

	var i,
		iMax;

	// Now that the container size has changed, we need change the dimension of our stretchy element 
	if(this.dimension === 'height'){
		var height = $(this.container).height() - this.trim - this.elToStretch.dimMarginPadding;
		$(this.elToStretch.el).height(height);
	}
	else if (this.dimension === 'width') {
		var height = $(this.container).width() - this.trim - this.elToStretch.dimMarginPadding;
		$(this.elToStretch.el).width(height);
	}
};


/**
 * $.parseParams - parse query string paramaters into an object.
 */
(function($) {
var re = /([^&=]+)=?([^&]*)/g;
var decodeRE = /\+/g;  // Regex for replacing addition symbol with a space
var decode = function (str) {return decodeURIComponent( str.replace(decodeRE, " ") );};
$.parseParams = function(query) {
    var params = {}, e;
    while ( e = re.exec(query) ) { 
        var k = decode( e[1] ), v = decode( e[2] );
        if (k.substring(k.length - 2) === '[]') {
            k = k.substring(0, k.length - 2);
            (params[k] || (params[k] = [])).push(v);
        }
        else params[k] = v;
    }
    return params;
};
})(jQuery);

jQuery.fn.visible = function() {
    return this.css('visibility', 'visible');
};

jQuery.fn.invisible = function() {
    return this.css('visibility', 'hidden');
};

jQuery.fn.visibilityToggle = function() {
    return this.css('visibility', function(i, visibility) {
        return (visibility == 'visible') ? 'hidden' : 'visible';
    });
};

