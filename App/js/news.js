_SPDEV.FrontNews = {};

_SPDEV.FrontNews.init = function(allstories,filter){
	allstories = allstories||false;
	var newsContent = null;
	var newsURL = "php/getNewsFiles.php";
	// go get array of the articles
	$.ajax({
	  url: newsURL,
	  dataType: 'JSON',
	  type: 'GET',
	  async: false,
	  success: function(data) {
	  	// sort desc by name (date in name)
	    newsContent = data.sort().reverse();
		for (i in newsContent) {
			// if the allstories flag is set, return all stories, as opposed to the top 3
			if ( allstories ) {
				// remove the leading '../'
				var storyi = newsContent[i].slice(3);
				// ignore the template
				if (storyi.slice(-13) != "template.html"){
					// if a filter is set, and the filter is contained in the list of all articles
					if ($.inArray('../content/news/'+filter,data) != -1){
						// only grab the filtered story
						if ('content/news/'+filter == storyi) {
							(function(){
								var thestory = storyi;
								$.get(thestory, function(story){
									var linkedStory = $(story);
									// set article source to an url query
									$(linkedStory.find('.article_source')[0]).attr('href','news.html?article='+thestory.slice(13));
									// append the story
									$('#qsnewsStories').append(linkedStory);
									// hide the overview snippet
									$($('#qsnewsStories').find('.snippet')[0]).hide();
									// show the full story
									$($('#qsnewsStories').find('.fulltext')[0]).show();
								});
							}());
						}
					} else {
						(function(){
							var thestory = storyi;
							$.get(thestory, function(story){ 
								var linkedStory = $(story);
								// set article source to an url query
								$(linkedStory.find('.article_source')[0]).attr('href','news.html?article='+thestory.slice(13));
								// append the story
								$('#qsnewsStories').append(linkedStory);
							});
						}());
					}
					
				}
			} else {
				// only grab the 3 most recent articles
				if ( i <=3 ){
					// remove the leading '../'
					var storyi = newsContent[i].slice(3);
					// ignore the template
					if (storyi.slice(-13) != "template.html"){
						(function(){
							var thestory = storyi;
							$.get(thestory, function(story){ 
								var linkedStory = $(story);
								// set article source to an url query
								$(linkedStory.find('.article_source')[0]).attr('href','news.html?article='+thestory.slice(13));
								// append the story
								$('#qsnewsStories').append(linkedStory);
							});
						}());
					}
				}
			}
		}
	  },
	  error: function(jqXHR, errorThrown) {
	    console.log('error...');
	    console.log(jqXHR);
	    console.log(errorThrown);
	  }
	});
	
};

