'use strict';

var TreemapVis = Class.extend({
  init: function(divId, size, clickable){
    this.containerId = divId;
    window.treemaps[this.containerId] = this;

    // Chart dimensions
    this.containerWidth = null;
    this.margin = {top: 0, right: 0, bottom: 0, left: 0};
    this.width = null;
    this.height = null;

    this.sizeFactor = size == 'big' ? 5.5 : 2.5;
    this.clickable = clickable;

    this.treemap = null;
    this.container = null;

    var colors = ['#FFD100', '#FE7000', '#ED2F00', '#940099', '#487304', '#4A73B0', '#1B4145', '#444300', '#24190E'];
    this.colorScale = d3.scale.ordinal().range(colors);
  },

  render: function(urlData) {
    $(this.containerId).html('');

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.containerId).style('width'), 10);
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / this.sizeFactor) - this.margin.top - this.margin.bottom;

    this.container = d3.select(this.containerId)
      .style("position", "relative")
      .style("width", (this.width + this.margin.left + this.margin.right) + "px")
      .style("height", (this.height + this.margin.top + this.margin.bottom) + "px")
      .style("left", this.margin.left + "px")
      .style("top", this.margin.top + "px");

    this.treemap = d3.layout.treemap()
      .size([this.width, this.height])
      .sticky(true)
      .value(function(d) { return d.budget; });

    d3.json(urlData)
      .mimeType('application/json')
      .get(function(error, root){
      if (error) throw error;

      this.colorScale
        .domain(root.children.map(function(d) { return d.name; }));

      var node = this.container.datum(root).selectAll(".treemap_node")
        .data(this.treemap.nodes)
        .enter().append("div")
        .attr("class", function(d){
          if(this.clickable){
            return "treemap_node clickable";
          } else {
            return "treemap_node";
          }
        }.bind(this))
        .attr("data-url", function(d){ 
          if(this.clickable){
            return d.children ? null : urlData.split('?')[0] + "?code=" + d.code;
          }
        }.bind(this))
        .call(this._position)
        .style("background", function(d) { return this.colorScale(d.name); }.bind(this))
        .html(function(d) {
          if(d.children) {
            return null;
          } else {
            // If the square is small, don't add the text
            if(d.dx > 50 && d.dy > 50) {
              return "<p><strong>" + d.name + "</strong></p><p>" + d.budget_per_inhabitant + "€/habitante</p>";
            }
          }
        });
    }.bind(this));
  },

  _position: function() {
    this.style("left", function(d) { return d.x + "px"; })
      .style("top", function(d) { return d.y + "px"; })
      .style("width", function(d) { return Math.max(0, d.dx - 1) + "px"; })
      .style("height", function(d) { return Math.max(0, d.dy - 1) + "px"; });
  }
});
