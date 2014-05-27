## Feature Overview

The OAM front-page site is dynamically building the news article previews from content located in the site's github repo.
This allows non-developer users to add and remove previews to the 'IN THE NEWS' section of the front-page site.

## Process Overview

There are two participants in this process: the _**content creator**_ (adds the previews) and the _**developer**_ (pulls new content into the app.)
The _**content creator**_ is responsible for adding the news preview image, creating the preview content based off a provided template, and notifying the developer of the addition.
The _**developer**_ is responsible for getting the content from github into the web-facing app.

## Process - Content Creator

1. Add image file to img directory
2. Copy the contents of news/template.html 
3. Create new file in news directory, titled YYYY-MM-DD-filename.html
4. Paste contents of news/template.html into new file
5. Update relevant portions of new file:
	- alt="IMAGE HOVER TEXT" (the alternate name/title of the image)
    - src="img/IMAGE_NAME.jpg" (the filename of the image added in stem)
    - href="article_url" (replace article_url with the link to the main news article)
    - ARTICLE TITLE (replace this text with the desired title)
	- Month DD, YYYY (replace this with the publish date of the article)
    - ARTICLE OVERVIEW TEXT HERE... (replace with the overview text for the preview)
6. Notify Developer of pending changes

