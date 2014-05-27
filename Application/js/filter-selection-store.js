/**
 * @author Rich Gwozdz
 */

_SPDEV = _SPDEV || {};

_SPDEV.FilterSelectionStore = function(taxonomyId, readyToFilterChannel, opts){
	
	this.classifications = {};
	this.classificationPrefilters = null;
	this.organizations = [''];
	this.startDate = null;
	this.endDate = null;
	this.reportByTaxonomyId = taxonomyId;
	this.readyTofilterChannel = readyToFilterChannel;
	
	this.options = opts || {};
	
	var preFilterArrayOfArrays = this.options.classificationPrefilters || [];
	this.prefilters = '';
	
	var self = this;
	var cpf = '';
	
	_.each(preFilterArrayOfArrays, function(prefilter, i){
		
		if(prefilter.length === 0 && cpf.charAt(cpf.length - 1) === ',') {
			cpf = cpf.substring(0, cpf.length - 1);
		} else {
			var str = prefilter.toString() + ","
			cpf = cpf + prefilter.toString() + ","
		};
		
	});
	
	if(cpf.charAt(cpf.length - 1) === ',') {
		cpf = cpf.substring(0, cpf.length - 1);
	}
	
	this.classificationPrefilters = cpf;
};

_SPDEV.FilterSelectionStore.prototype.scrapeUpFilters = function(returnFilters){
	
	var self = this;
	
	var post = {'summaryTaxId' : this.reportByTaxonomyId, 'classificationIds': null, 'organizationIds': this.organizations.toString(), 'startDate': this.startDate, 'endDate': this.endDate };
	
	if(this.classificationPrefilters !== '') {
		var hasPrefilters;
	}
	
	// Classifications
	var clsStr = '';
	
	_.each(this.classifications, function(clsArr){
		
		if(clsArr.length > 0){
			
			if(clsStr === ''){
				clsStr = clsArr.toString();
			}
			else {
				clsStr = clsStr  + "," + clsArr.toString();
			}
		}
	});
	
	if(clsStr === ''){
		clsStr = this.classificationPrefilters;
	} else if (clsStr.charAt(clsStr.length - 1) === ',' ) {
		clsStr = clsStr.substring(0, clsStr.length-1);
		clsStr = clsStr + ',' + this.classificationPrefilters;
	}else {
		clsStr = clsStr + ',' + this.classificationPrefilters;
	}
	post.classificationIds = clsStr;
	
	if(returnFilters === true) {
		return post;
	} else {
		amplify.publish(this.readyTofilterChannel, post);
	}
		
};
