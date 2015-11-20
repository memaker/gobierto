'use strict';

var VisDispersion = Class.extend({
  init: function(divId, measure) {
    this.container = divId;
    
    // Chart dimensions
    this.containerWidth = null;
    this.margin = {top: 20, right: 20, bottom: 40, left: 40};
    this.width = null;
    this.height = null;
    
    // Variable 
    this.measure = measure;

    // Scales
    this.xScale = d3.scale.linear();
    this.yScale = d3.scale.linear();
    this.xScaleSecondary = d3.scale.ordinal();
    this.colorScale = d3.scale.ordinal().range(['#00909E', '#F69C95', '#F1B41B', '#B3CC57', '#32C192', '#F657D8', '#A984FF']);

    // Axis
    this.xAxis = d3.svg.axis();
    this.yAxis = d3.svg.axis();

    // Data
    this.data = null;
    this.dataChart = null;
    this.dataMeans = null;
    this.dataFreq = null; 
    this.dataDomain = null;
    this.kind = null;
    this.meanCut = null;

    // Objects
    this.tooltip = null;
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".2f");

    // Chart objects
    this.svgDispersion = null;
    this.chart = null;

    // Constant values
    this.radius = 5;
    this.opacity = .7;
    this.opacityLow = .4;
    this.duration = 1500;
    this.mainColor = '#F69C95';
    this.darkColor = '#B87570';
    this.niceCategory = null;
  },

  render: function(urlData) {

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.container).style('width'), 10);
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / 1.9) - this.margin.top - this.margin.bottom;

    // Append tooltip
    this.tooltip = d3.select('body').append('div')
      .attr('class', 'vis_distribution_tooltip')
      .style('opacity', 0);


    // Append svg
    this.svgDispersion = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_distribution')
      .append('g')
        .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    // Set nice category
    this.niceCategory = {
      "Actuaciones de carácter general": "Actuaciones Generales",
      "Actuaciones de carácter económico": "Actuaciones Económicas",
      "Producción de bienes públicos de carácter preferente": "Bienes Públicos",
      "Actuaciones de protección y promoción social": "Protección Social",
      "Servicios públicos básicos": "Servicios Públicos",
      "Deuda pública": "Deuda Pública",
      "mean_national": "Media Nacional",
      "mean_autonomy": "Media Autonómica",
      "mean_province": "Media Provincial",
      "G": "Gasto/habitante",
      "I": "Ingreso/habitante",
      "percentage": "% sobre el total"
    }

    // Load the data
    d3.csv(urlData, function(error, csvData){
      if (error) throw error;
      
      this.data = csvData;
      this.data.forEach(function(d) { 
        d.per_person = +d.per_person;
        d.population = +d.population;
      });

      // Sort by population, to get the right order of the cuts.  
      this.data.sort(function(a, b) { return a.population - b.population; }) 

      // Set the scales
      this.xScale
        .domain(d3.extent(this.data, function(d) { return Math.log(d.population); }))
        .range([this.margin.left + this.radius, this.width]);

      this.yScale
        .domain([0, d3.max(this.data, function(d) { return d.per_person; })]) 
        .range([this.height, this.margin.top]);

      this.colorScale
        .domain(this.data.map(function(d) { return d.cut; }));

      // Define the axis 
      this.yAxis
          .scale(this.yScale)
          .tickValues(this._tickValues(this.yScale))
          .orient("left");
      
      // --> DRAW THE AXIS
      // -> Draw yAxis

      this.svgDispersion.append("g")
          .attr("class", "y axis")
          .attr("transform", "translate(" + this.margin.left + ",0)")
          .call(this.yAxis);

      // Change ticks color
      d3.selectAll('.axis').selectAll('text')
        .attr('fill', this.darkColor);

      d3.selectAll('.axis').selectAll('path')
        .attr('stroke', this.darkColor);


      // --> DRAW THE BAR CHART 
      this.chart = this.svgDispersion.append('g')
          .attr('class', 'dispersion_chart');

      this.chart.append('g')
        .selectAll('cricle')
          .data(this.data)
          .enter()
        .append('circle')
          // .attr('class', function(d) { return 'bar_distribution x' + d.key; })
          .attr('cx', function(d) { return this.xScale(Math.log(d.population)); }.bind(this))
          .attr('cy', function(d) { return this.yScale(d.per_person); }.bind(this))
          .attr('r', this.radius)
          .attr('fill', function(d) { return this.colorScale(d.cut); }.bind(this))
          .attr('opacity', this.opacity);

      // --> DRAW THE Legend 
      var svg = d3.select("svg");

      svg.append("g")
        .attr("class", "legend_dispersion")
        .attr("transform", "translate(" + (this.width - (this.margin.right * 3)) + ",20)");

      var legendDispersion = d3.legend.color()
        .shape('path', d3.svg.symbol().type('circle').size(80)())
        .shapeWidth(14)
        .shapePadding(this.radius)
        .scale(this.colorScale)
        .title('Tamaño de municipio')

      svg.select(".legend_dispersion")
        .call(legendDispersion);


    }.bind(this)); // end load data
  }, // end render

  // updateRender: function () {

  //   // re-map the data
  //   this.dataChart = this.data.budgets[this.measure].filter(function(d) { return d.name.match(/^(?!^mean)/) ; });
  //   this.dataMeans = this.data.budgets[this.measure].filter(function(d) { return d.name.match(/^mean/) ; });
  //   this.kind = this.data.kind;

  //   // dataDomain, to plot the min & max labels    
  //     this.dataDomain = ([
  //       d3.min(this.dataChart, function(d) { return d.value; }),
  //       d3.max(this.dataChart, function(d) { return d.value; })
  //           ]);
    
  //   // Update the frequencies for every cut
  //   this.dataFreq = d3.nest()
  //         .key(function(d) { return d.cut; }).sortKeys(function(a,b) { return a - b; })
  //         .rollup(function(v) { return v.length; })
  //         .entries(this.dataChart);

  //   // Update the scales
  //   this.xScale.domain(this.dataFreq.map(function(d) { return d.key; }));
  //   this.xMinMaxScale.domain(this.dataDomain);
  //   this.yScale.domain([0, d3.max(this.dataFreq, function(d) { return d.values; })]);

  //   // Update the axis
  //   this.xMinMaxAxis 
  //         .scale(this.xMinMaxScale)
  //         .tickValues(this.dataDomain);

  //   if (this.measure != 'percentage') {
  //     this.xMinMaxAxis
  //       .tickFormat(d3.format('.f'));
  //   } else {
  //     this.xMinMaxAxis
  //       .tickFormat(d3.format('%'));
  //   }

  //   this.svgDispersion.select(".x.axis")
  //     .transition()
  //     .duration(this.duration)
  //     .delay(this.duration/2)
  //     .ease("sin-in-out") 
  //     .call(this.xMinMaxAxis);

  //   // Change ticks color
  //   d3.selectAll('.x.axis').selectAll('text')
  //     .attr('fill', this.mainColor);

  //   this.svgDispersion.selectAll('.bar_distribution')
  //     .data(this.dataChart)
  //     .transition()
  //     .duration(this.duration)
  //     .attr('y', function(d) { return this.yScale(d.values); }.bind(this))
  //     .attr('height', function(d) { return this.height - this.yScale(d.values); }.bind(this))


  //   // --> HIGHLIGHT THE MEAN CUT 

  //   var prevMeanCut = this.meanCut;
  //   this.meanCut = this.dataMeans
  //                   .filter(function(d) { return d.name == this.mean; }.bind(this))
  //                   .map(function(d) { return d.cut; });

  //   if (this.meanCut != prevMeanCut) {
  //     this.svgDispersion.selectAll('.bar_distribution')
  //       .transition()
  //       .duration(this.duration / 2)
  //       .attr('fill', this.mainColor);

  //     this.svgDispersion.selectAll('.bar_distribution.x' + this.meanCut[0])
  //       .transition()
  //       .duration(this.duration)
  //       .attr('fill', d3.rgb(this.mainColor).darker(1));
  //   }
  // },
  //PRIVATE
  _tickValues:  function (scale) {
    var range = scale.domain()[1] - scale.domain()[0];
    var a = range/4;
    return [scale.domain()[0], scale.domain()[0] + a, scale.domain()[0] + (a * 2), scale.domain()[1] - a, scale.domain()[1]];
  },

  _mouseover: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList,
        selectedData = d3.select(selected).data()[0],
        selectedCx = d3.select(selected).attr('cx'),
        selectedCy = d3.select(selected).attr('cy'),
        labelsOn = d3.select('#myonoffswitch-labels').property('checked');
  
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


    this.svgDispersion.selectAll('.barLine')
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








