_SPDEV.FrontMap = {};

_SPDEV.FrontMap.init = function(){
	
	// GET MAP SIZE DEPENDING ON SCREEN SIZE ONLOAD:

	var margin = {top: 0, left: 0, bottom: 0, right: 0},
	   width = parseInt(d3.select('#mmmap').style('width')),
	   width = width - margin.left - margin.right,
	   mapRatio = .448,
	   height = width * mapRatio;

	var projection = d3.geo.equirectangular()
    	.scale(width / 6.2)
    	.translate([ width / 2, width / 3.7]);

	var path = d3.geo.path()
	    .projection(projection);

	var svg = d3.select("#mmmap").append("svg")
	    .attr("width", width)
	    .attr("height", height);

	// CONSTRUCT THE STATIC COUNTRY INFOBOXES
  var tt_Bolivia = d3.select("#mmmap").append("div").attr("class", "mminfo right").attr("id","tt_Bolivia").attr("title", "Bolivia");
	//remove Kenya for now
	var tt_Haiti = d3.select("#mmmap").append("div").attr("class", "mminfo bottom").attr("id","tt_Haiti").attr("title", "Haiti");
	var tt_Honduras= d3.select("#mmmap").append("div").attr("class", "mminfo right").attr("id","tt_Honduras").attr("title", "Honduras");
	//var tt_Colombia= d3.select("#mmmap").append("div").attr("class", "mminfo left").attr("id","tt_Colombia").attr("title", "Colombia");
	//var tt_Kenya = d3.select("#mmmap").append("div").attr("class", "mminfo top").attr("id","tt_Kenya").attr("title", "Kenya");
	var tt_Nepal = d3.select("#mmmap").append("div").attr("class", "mminfo top").attr("id","tt_Nepal").attr("title", "Nepal");
	var tt_Malawi = d3.select("#mmmap").append("div").attr("class", "mminfo bottom").attr("id","tt_Malawi").attr("title", "Malawi");

	// PLACE THEM ON THE MAP RELATIVE TO THE MAP SIZE, THEN POPULATE THEM
    tt_Bolivia.attr("style", "left:" + width/5.05 + "px;top:" + height/1.52 + "px").html("<div class='mmtitle'><a href='application.php?dg=Bolivia'>BOLIVIA<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>6,568 Activities</div>");
	tt_Haiti.attr("style", "left:" + width/4.05 + "px;top:" + height/2.68 + "px").html("<div class='mmtitle'><a href='application.php?dg=Haiti'>HAITI<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>811 Activities</div>");
	tt_Honduras.attr("style", "left:" + width/7 + "px;top:" + height/2.15 + "px").html("<div class='mmtitle'><a href='application.php?dg=Honduras'>HONDURAS<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>3,238 Activities</div>");
	//tt_Colombia.attr("style", "left:" + width/3.2 + "px;top:" + height/1.9 + "px").html("<div class='mmtitle'><a href='application.php?dg=Coloumbia'>COLOMBIA<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>x,xxx  Activities</div>");
	//Remove Kenya For now
	//tt_Kenya.attr("style", "left:" + width/2 + "px;top:" + height/2.75 + "px").html("<div class='mmtitle'><a href='application.php?dg=Kenya'>KENYA<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>2,243  Activities</div>");
	tt_Nepal.attr("style", "left:" + width/1.44 + "px;top:" + height/2.26 + "px").html("<div class='mmtitle'><a href='application.php?dg=Nepal'>NEPAL<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>17,318  Activities</div>");
	tt_Malawi.attr("style", "left:" + width/1.84 + "px;top:" + height/1.8 + "px").html("<div class='mmtitle'><a href='application.php?dg=Malawi'>MALAWI<img src='img/mmLogo.png'/></a></div><div class='mmactivities'>2,069  Activities</div>");
	
  // HOLD RENDERING UNTIL THE DATA LOADS
	queue()
	    .defer(d3.json, "js/data/d3-world.json")
	    .defer(d3.tsv, "js/data/world-country-names.tsv")
	    .await(ready);

function ready(error, world, names) {
	   // TRANSLATE FROM TOPOJSON, ADD TITLE AND GEOMETRY
	   var countries = topojson.feature(world, world.objects.countries).features;
	   countries.forEach(function(d) {
	      d.name = names.filter(function(n) { return d.id == n.id; })[0].name;
	   });
	   var country = svg.selectAll(".mmcountry").data(countries);
	   country.enter().insert("path").attr("class", function(d, i) {
	     return countrySpecific(d, i);
	   }).attr("title", function(d, i) {
	     return d.name;
	   }).attr("d", path);
	   
	   // LINK THE HOVER STATE TRIGGERS:
	   a = d3.selectAll(".countrySelected");
	   b = d3.selectAll(".mminfo");
	   
	   a.on("mouseover", function(d) {
	     d3.selectAll("[title=" + d.name + "]").classed("mminfoActive",true);
	   });
	   
	   a.on("mouseout", function(d) {
	     d3.selectAll("[title=" + d.name + "]").classed("mminfoActive",false);
	   });
	   
	   b.on("mouseover", function(d) {
	     d3.selectAll("[title=" + this.title + "]").classed("countryActive",true);
	   });
	   
	   b.on("mouseout", function(d) {
	     d3.selectAll("[title=" + this.title + "]").classed("countryActive",false);
	   });

 }
 
 // IDENTIFY THE FOCUS COUNTRIES
 function countrySpecific(d, i) {
   //if (d.name == 'Bolivia' || d.name == 'Kenya' || d.name == 'Malawi' || d.name == 'Nepal') return 'mmcountry countrySelected'
   if (d.name == 'Bolivia' || d.name == 'Malawi' || d.name == 'Haiti' ||d.name == 'Honduras' ||d.name == 'Nepal') return 'mmcountry countrySelected';
   else return 'mmcountry';
 }

	
};

 