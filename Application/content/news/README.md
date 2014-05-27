## 'In the News' articles

Process for adding new article previews to the 'In the News' section of the OAM site.

Within the news directory (where we are currently...)
we need to do perform a few tasks:
* [content team] add article's thumbnail image file to the 'img/' directory in the root of the project
* [content team] create a new file, titled with the following format: 'YYYY-MM-DD-titleofarticle.html' in the 'news/' directory _(this directory)_
* [content team] copy the contents of the file: 'template.html' into the newly created file
* [content team] update the elements in the newly created file
* [content team] commit the changes
* [technical team] re-deploy changes to the site

News article previews consist of several small pieces of information:
* line 5: replace 'IMAGE HOVER TEXT' with the desired caption
* line 9: replace 'IMAGE_NAME' with the name of the thumbnail image file added above
* line 16: replace 'article_url' with the link to the source article
* line 20: replace 'ARTICLE TITLE' with the desired title
* line 24: replace 'Month DD, YYYY' with the actual article date
* line 29: replace 'ARTICLE OVERVIEW TEXT HERE...' with the text for the overview of the news article



