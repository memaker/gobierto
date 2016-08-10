'use strict';

var VisEvoLine = Class.extend({
  init: function(divId, series) {
    this.container = divId;
    this.data = series;
    //this.data = [{"year":2010,"deviation":0},{"year":2011,"deviation":-3.19},{"year":2012,"deviation":-6.37},{"year":2013,"deviation":-10},{"year":2014,"deviation":10},{"year":2015,"deviation":-7.87}];
    // this.dataUrl = null;
    this.classed = "evoline"

    // Chart dimensions
    this.margin = {top: 5, right: 40, bottom: 25, left: 0};
    this.width = parseInt(d3.select(this.container).style('width'));
    this.height = 60 + this.margin.top + this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scale.linear();
    this.yScale = d3.scale.linear();

    this.defaultYDomain = [10,-10];

    // Axis
    this.xAxis = d3.svg.axis().orient('bottom');
    this.yAxis = d3.svg.axis().orient('right');

    // Chart objects
    this.svg = null;
    this.chart = null;

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .classed(this.classed,true)
      .attr('width',this.width)
      .attr('height',this.height);
  },
  getData: function() {
    d3.json(this.dataUrl, function(error, jsonData) {
      if (error) throw error;

      this.data = jsonData;
      this.updateRender();
    }.bind(this));
  },
  render: function() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  },
  updateRender: function(callback) {
    if (!this._axisRendered())
      this._renderAxis();

    var line = d3.svg.line()
    .x(function(d) { return this.xScale(d.year); }.bind(this))
    .y(function(d) { return this.yScale(d.deviation); }.bind(this));

    this.svg.append("path")
      .datum(this.data)
      .attr("class", "line")
      .attr("d", line);
  },
  _renderAxis: function() {
    this.xScale.domain(d3.extent(this.data.map(function(e) {
      return e.year;
    }))).range([this.margin.left, this.width - this.margin.left - this.margin.right]);

    this.yScale.domain(d3.extent(this.data.map(function(e) {
        return e.deviation;
      }).concat(this.defaultYDomain)))
      .range([this.height - this.margin.bottom, this.margin.top]);

    //xAxis
    this.svg.append('g')
      .attr('class','x axis')
      .attr("transform", "translate("+ this.margin.left + "," + this.yScale(0) + ")");

    //yAxis
    this.svg.append('g')
      .attr('class','y axis')
      .attr("transform", "translate(" + (this.width - this.margin.right + 10) + "," + 0 + ")");

    this.xAxis.tickValues(this.data.filter(function(d) {
      return d.year % 2 !== 0;
    }).map(function(d) {
      return d.year;
    }));
    this.xAxis.tickSize(0,0);
    this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.xAxis.scale(this.xScale);
    this.svg.select(".x.axis").call(this.xAxis);

    //moving ticks down
    this.svg.selectAll(".x.axis text")
      .attr('transform','translate(0,'+ ((this.height/2) - this.margin.bottom) +')')

    this.yAxis.tickSize(-this.width,0);
    this.yAxis.tickValues(this.defaultYDomain.concat([0]));
    this.yAxis.tickFormat(this._formatNumberY.bind(this));
    this.yAxis.scale(this.yScale);
    this.svg.select(".y.axis").call(this.yAxis);
  },
  _axisRendered: function() {
    return this.svg.selectAll('.axis').size() > 0;
  },
  _formatNumberX: function(d) {
    //replace with whatever format you want
    //examples here: http://koaning.s3-website-us-west-2.amazonaws.com/html/d3format.html
    return d3.format()(d)
  },
  _formatNumberY: function(d) {
    //replace with whatever format you want
    //examples here: http://koaning.s3-website-us-west-2.amazonaws.com/html/d3format.html
    return d3.format('%')(d/100)
  }
});