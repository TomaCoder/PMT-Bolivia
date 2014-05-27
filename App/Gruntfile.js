module.exports = function(grunt) {

    // 1. All configuration goes here 
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

		uglify: {
			options: {
		        report: 'min',
		        sourceMap: 'js/js-min.map.js',
		        sourceMapPrefix: 1,
		        sourceMappingURL: 'js-min.map.js'
		     },
		    build: {
		        src: [
		            'js/vendor/amplify.min.js',
					'js/vendor/leaflet.js',
					'js/vendor/underscore-min.js',
					'js/vendor/backbone-min.js',
					'js/vendor/json2.js',
					'js/vendor/d3.min.js',
					'js/vendor/subtree-leaflet-overlays/leaflet-overlays.js',
					'js/vendor/subtree-leaflet-bing-layer/leaflet-bing-layer.js',
					'js/vendor/subtree-leaflet-basemap-switcher/leaflet-basemap-switcher.js',
					'js/vendor/subtree-quick-cluster/q-cluster.js',        
					'js/vendor/subtree-quick-cluster/q-cluster-leaflet-layer.js',
					'js/login.js',
					'js/iati-upload.js',
					'js/utilities.js',
					'js/layout.js',
					'js/subscribe-on-load.js',
					'js/filter-selection-store.js',
					'js/facet-filter.js',
					'js/list-view.js',
					'js/locations.js',
					'js/data-sources.js',
					'js/activity-chart.js',
					'js/maps-control.js',
					'js/infobox.js',
					'js/download-btn.js',
					'js/main.js'
		        ],
		        dest: 'js/js-min.js'
		    }
		},
		
		cssmin: {
		  combine: {
		    files: {
		      'css/css-min.css': ['css/main.css', 'css/login.css']
		    }
		  }
		},
		
		includeUpdater : {
			inputFile: 'application.php',
			output: {
				css: 'css/css-min.css',
				js: 'js/js-min.js'
			}
		}
    });

    
    // 3. Where we tell Grunt we plan to use this plug-in.
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-cssmin');

    
    // 4. Where we tell Grunt what to do when we type "grunt" into the terminal.
    grunt.registerTask('default', ['includeUpdater', 'uglify', 'cssmin']);
	
	grunt.registerTask('includeUpdater', 'Remove dev include tags and replace with minified JS file script tag.', function(){
		
		var cssOutfile, jsOutfile, iU, fileWithIncludes;
		
		// Get config parameters
		iU = grunt.config.get(this.name);
		
		if(typeof iU.inputFile === 'undefined'){
			grunt.log.error('No input file provided for "includeUpdater" task.');
			return;
		};
		
		if(typeof iU.output.css !== 'undefined') {
			cssOutfile = iU.output.css;
			updateMyIncludes('css', cssOutfile, iU.inputFile);
		}
		
		if(typeof iU.output.js !== 'undefined') {
			jsOutfile = iU.output.js;
			updateMyIncludes('javascript', jsOutfile, iU.inputFile);
		}
		
	});
	
	
	function updateMyIncludes(type, outfile, fileWithIncludes){
	
		var type, htmlWithIncludes,replaceTag, beginString,endString,beginIndex,endIndex, minifyTagsString;
		
		// HTML comment tags that wrap script tags that should be compressed
		if(type === 'javascript') {
			replaceTag = '<script src="' + outfile + '?' + Date.now() + '" ></script>';
			beginString = '<!--JSMIN-BEGIN-->';
	   		endString = '<!--JSMIN-END-->';
		} else if (type === 'css') {
			replaceTag = '<link rel="stylesheet" href="' + outfile + '?' + Date.now() + '" ></script>';;
			beginString = '<!--CSSMIN-BEGIN-->';
	   		endString = '<!--CSSMIN-END-->';
		}
		
		if (!grunt.file.exists(fileWithIncludes)) {
	      grunt.log.warn('Source file "' + fileWithIncludes + '" not found.');	
	    } else {
	      htmlWithIncludes = grunt.file.read(fileWithIncludes);
	    }
	    
	    // Get the character index that is the start of <!--JSMIN-BEGIN-->
	    beginIndex = htmlWithIncludes.indexOf(beginString);
	 
	    // Get the character index that is the end of <!--JSMIN-END-->
	    endIndex = htmlWithIncludes.indexOf(endString) + endString.length;
	 

	    if(beginIndex === -1) {
	        grunt.log.warn(beginString + ' was not found.\n');
	        return;
	    }
	
	    if(endIndex === -1) {
	        grunt.log.warn(endString + ' was not found.\n');
	        return;
	    }
		
	    // Get text string 
	    minifyTagsString = htmlWithIncludes.substring(beginIndex, endIndex);
	    
	    htmlWithIncludes = htmlWithIncludes.replace(minifyTagsString, replaceTag);
	    
	    // Re-write page html
	    grunt.file.write(fileWithIncludes, htmlWithIncludes);
	    
	}
	
};


