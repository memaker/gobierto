'use strict';

var BarsVis = Class.extend({
  init: function(divId, measure, context) {
    this.container = divId;
    
    // Chart dimensions
    this.containerWidth = null;
    this.margin = {top: 80, right: 100, bottom: 60, left: 100};
    this.width = null;
    this.height = null;
    
    // Variable 
    this.measure = measure;
    this.context = context;

    // Scales
    this.xScale = d3.scale.linear();
    this.yScale = d3.scale.ordinal();
    this.colorScale = d3.scale.ordinal();

    // Axis
    this.xAxis = d3.svg.axis();
    this.yAxis = d3.svg.axis();

    // Data
    this.data = null;
    this.dataChart = null;
    this.chartTitle = null;

    // Objects
    this.tooltip = null;
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".f");

    // Chart objects
    this.svgBars = null;
    this.chart = null;

    // Constant values
    this.opacity = .7;
    this.opacityLow = .4;
    this.duration = 1500;
    this.mainColor = '#E6A39A';
  },

  render: function(urlData) {
    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.container).style('width'), 10);
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / 1.9) - this.margin.top - this.margin.bottom;

    // Append tooltip
    this.tooltip = d3.select('body').append('div')
      .attr('class', 'vis_tooltip')
      .style('opacity', 0);

    // Append svg
    this.svgBars = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_chart')
        .style('background-color', d3.rgb(this.mainColor).brighter(1))
      .append('g')
        .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');


    // Load the data
    d3.json(urlData, function(error, jsonData){
      if (error) throw error;
      
      // Map the data
      this.data = jsonData;
      this.dataChart = this.data.budgets[this.measure];
      this.chartTitle = this.data.title;
      // Get the values array to take the max
      var values = [];
      this.dataChart.forEach(function(d) {
        values.push(d.value, d.mean_national, d.mean_autonomy, d.mean_province)
      });

      // Set the scales
      this.xScale
        .domain([0, d3.max(values)])
        .range([0, this.width - this.margin.right]);


      this.yScale
        .domain(this.dataChart.map(function(d) { return d.name; })) 
        .rangeRoundBands([this.height, 0], .05);


      // Define the axis 

      this.xAxis
          .scale(this.xScale)
          .tickValues(this._tickValues(this.xScale))
          .tickFormat(this.formatPercent)
          .orient("bottom");

      this.yAxis
          .scale(this.yScale)       
          .orient("left");

      // --> DRAW THE AXIS
      // -> Draw xAxis (just draw the xMeanAxis)
      this.svgBars.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(' + this.margin.left + ',' + this.height + ')')
          .call(this.xAxis);

      // -> Draw yAxis
      this.svgBars.append('g')
          .attr('class', 'y axis')
          .attr('transform', 'translate(' + this.margin.left + ',0)')
          .call(this.yAxis);

      // Change ticks color
      d3.selectAll('.axis').selectAll('text')
        .attr('fill', this.mainColor);
      
      

      // --> DRAW BARS CHART 
      this.chart = this.svgBars.append('g')
          .attr('class', 'chart');

      this.chart.append('g')
          .attr('class', 'bars')
        .selectAll('rect')
          .data(this.dataChart)
          .enter()
        .append('rect')
          .attr('class', 'bar')
          .attr('x', this.margin.left)
          .attr('width', function(d) { return this.xScale(d.value); }.bind(this))
          .attr('y', function(d) { return this.yScale(d.name); }.bind(this))
          .attr('height', this.yScale.rangeBand())
          .attr('fill', this.mainColor)
          .on('mouseover', this._mouseover.bind(this))


      // --> DRAW THE MEAN LINE 
      var meanGroup = this.chart.append('g')
          .attr('class', 'mean_lines')
          .attr('transform', 'translate(' + this.margin.left + ',0)');
          

      meanGroup.selectAll('.mean_line')
          .data(this.dataChart)
          .enter()
        .append('line')
          .attr('class', 'mean_line')
          .attr('x1', function(d) { return this.xScale(d[this.context]); }.bind(this))
          .attr('y1', function(d) { return this.yScale(d.name); }.bind(this))
          .attr('x2', function(d) { return this.xScale(d[this.context]); }.bind(this))
          .attr('y2', function(d) { return this.yScale(d.name) + this.yScale.rangeBand(); }.bind(this))
          .attr('stroke', 'black');
      
      // Append title
      this.chart
        .append('text')
        .attr('class', 'chartTitle')
        .attr('x', 0)
        .attr('y', - (this.margin.top/2))
        .attr('fill', d3.rgb(this.mainColor).darker(1))
        .text(this.chartTitle)

    }.bind(this)); // end load data
  }, // end render

  updateRender: function () {
    
    this.dataChart = this.data.budgets[this.measure]
    console.log(this.xScale.domain())

    var values = [];
      this.dataChart.forEach(function(d) {
        values.push(d.value, d.mean_national, d.mean_autonomy, d.mean_province)
      });

    // Update the scales
    this.xScale
      .domain([0, d3.max(values)])

    // Update the axis
    this.xAxis
        .scale(this.xScale)
        .tickValues(this._tickValues(this.xScale));

    if (this.measure != 'percentage') {
      this.xAxis
        .tickFormat(d3.format('.f'));
    } else {
      this.xAxis
        .tickFormat(d3.format('%'));
    }

    this.svgBars.select(".x.axis")
      .transition()
      .duration(this.duration)
      .delay(this.duration/2)
      .ease("sin-in-out") 
      .call(this.xAxis);

     // Change ticks color
      d3.selectAll('.axis').selectAll('text')
        .attr('fill', this.mainColor);

    this.svgBars.selectAll('.bar')
      .data(this.dataChart)
      .transition()
      .duration(this.duration)
      .attr('width', function(d) { return this.xScale(d.value); }.bind(this))

    this.svgBars.selectAll('.mean_line')
      .data(this.dataChart)
      .transition()
      .duration(this.duration)
      .attr('x1', function(d) { return this.xScale(d[this.context]); }.bind(this))
      .attr('x2', function(d) { return this.xScale(d[this.context]); }.bind(this))

  }, // end updateRender

  //PRIVATE
  _tickValues:  function (scale) {
    // var range = scale.domain()[1] - scale.domain()[0];
    // var a = range/4;
    return [scale.domain()[0], scale.domain()[1]]
    // return [scale.domain()[0], scale.domain()[0] + a, scale.domain()[0] + (a * 2), scale.domain()[1] - a, scale.domain()[1]];
  },

  _mouseover: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList,
        selectedData = d3.select(selected).data();
    console.log(selectedData)
    if (selectedData.name == 'influence') {
      var text = '<strong>' + formatPercent(selectedData.percentage) + '</strong> of respondents<br> are influenced<br>by <strong> ' + selectedData.tpClass + ' media</strong>'
    } else {
      var text = '<strong>' + formatPercent(selectedData.percentage) + '</strong> of respondents<br>associates<strong> ' + selectedData.tpClass + ' media</strong> to <strong>' + this.subindustry + '</strong>'
    }
    
    d3.selectAll('.marker.' + selectedClass[1])
      .filter(function(d) { return d.represent == selectedClass[2]; })
      .transition()
      .duration(this.duration / 4)
      .attr('markerWidth', this.markerSize * 2)
      .attr('markerHeight', this.markerSize * 2)
      .style('fill', customGrey)
      .attr('stroke-width', .3);

    var xMouseoverLine = this.xScale(selectedData.percentage),
        yMouseoverLine = this.yScale(selectedData.tpClass) + this.ySecondaryScale(selectedData.name);
  
     d3.select(selected.parentNode).selectAll('mouseover_line')
        .data([xMouseoverLine, yMouseoverLine])
        .enter()
        .append('line')
        .attr('class', 'mouseover_line')
        .attr('x1', xMouseoverLine)
        .attr('y1', yMouseoverLine)
        .attr('x2', xMouseoverLine)
        .attr('y2', yMouseoverLine)
        .attr('stroke-width', 1)
        .style('stroke', this.colorScale(selectedData.tpClass))
        .transition()
        .duration(this.duration)
        .attr('y1', function(d, i) { return i == 0 ? this.margin.top : yMouseoverLine; }.bind(this))
        .attr('y2', function(d, i) { return i == 1 ? (this.height - this.margin.top) : yMouseoverLine; }.bind(this));

   
    d3.selectAll('.legend_line').selectAll('text.' + selectedData.name)
      .attr('font-size', '1.5em');


    this.svgBars.selectAll('.barLine')
      .filter(function(d) { return d.name != selectedClass[2]; })
      .transition()
      .duration(this.duration / 4)
      .style('stroke', function(d) { return this.brighterColorScale(d.tpClass); }.bind(this));

    var toBright = this.ySecondaryScale.domain().filter(function(d) { return d != selectedClass[2]; })  
    this.chart.selectAll('.' + toBright)
      .transition()
      .duration(this.duration / 4)
      .style('stroke', function(d) { return this.brighterColorScale(d.tpClass); }.bind(this))
      .attr('fill', function(d) { return this.brighterColorScale(d.tpClass); }.bind(this));
    
    this.tooltip
        .transition()
        .duration(this.duration / 4)
        .style('opacity', this.opacity);

    this.tooltip
        .html(text)
        .style('left', (d3.event.pageX + 50) + 'px')
        .style('top', (d3.event.pageY - 25) + 'px');

  },

  _mouseout: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList,
        selectedData = d3.select(selected).data()[0],
        labelsOn = d3.select('#myonoffswitch-labels').property('checked');

    d3.selectAll('.marker.' + selectedClass[1])
      .filter(function(d) { return d.represent == selectedClass[2]; })
      .transition()
      .duration(this.duration / 4)
      .attr('markerWidth', this.markerSize)
      .attr('markerHeight', this.markerSize)
      .style('fill', this.colorScale(selectedClass[1]))
      .attr('stroke-width', 0);

    var yMouseoverLine = this.yScale(selectedData.tpClass) + this.ySecondaryScale(selectedData.name);

    d3.selectAll('.mouseover_line')
      .transition()
      .duration(this.duration / 2)
      .attr('y2', yMouseoverLine)
      .attr('y1', yMouseoverLine)
      .remove();
    
    var toBright = this.ySecondaryScale.domain().filter(function(d) { return d != selectedClass[2]; })  
    this.chart.selectAll('.' + toBright)
      .transition()
      .duration(this.duration / 4)
      .style('stroke', function(d) { return this.colorScale(d.tpClass); }.bind(this))
      .attr('fill', function(d) { return this.colorScale(d.tpClass); }.bind(this));

    d3.selectAll('.legend_line').selectAll('text.' + selectedData.name)
      .attr('font-size', '1.1em');

    this.tooltip.transition()
        .duration(this.duration / 4)
        .style("opacity", 0);
  }

}); // End object








