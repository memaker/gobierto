'use strict';

var VisLineasJ = Class.extend({
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
    this.xScale = d3.time.scale();
    this.yScale = d3.scale.linear();
    this.colorScale = d3.scale.ordinal().range(['#F69C95', '#00646E', '#00909E', '#99BFBE']);

    // Axis
    this.xAxis = d3.svg.axis();
    this.yAxis = d3.svg.axis();

    // Data
    this.data = null;
    this.dataChart = null;
    this.dataDomain = null;
    this.kind = null;
    this.dataYear = null;

    // Legend
    this.legendEvolution = d3.legend.color();

    // Objects
    this.tooltip = null;
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".2f");
    this.parseDate = d3.time.format("%Y").parse;
    this.bisectDate = d3.bisector(function(d) { return d.date; }).left;
    this.line = d3.svg.line();

    // Chart objects
    this.svgLines = null;
    this.chart = null;
    this.focus = null;

    // Constant values
    this.radius = 6;
    this.opacity = .7;
    this.opacityLow = .4;
    this.duration = 1500;
    this.mainColor = '#F69C95';
    this.darkColor = '#B87570';
    this.niceCategory = null;
    this.heavyLine = 5;
    this.lightLine = 2;
  },

  render: function(urlData) {

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.container).style('width'), 10);
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / 1.9) - this.margin.top - this.margin.bottom;

    // Append tooltip
    this.tooltip = d3.select('body').append('div')
      .attr('class', 'vis_lineas_j_tooltip')
      .style('opacity', 0);


    // Append svg
    this.svgLines = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_lines')
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
    d3.json(urlData, function(error, jsonData){
      if (error) throw error;
      
      this.data = jsonData;

      this.data.budgets.per_person.forEach(function(d) { 
        d.values.forEach(function(v) {
          v.date = this.parseDate(v.date);
          v.name = d.name;
        }.bind(this));
      }.bind(this));

      this.data.budgets.percentage.forEach(function(d) { 
        d.values.forEach(function(v) {
          v.date = this.parseDate(v.date);
          v.name = d.name;
        }.bind(this));
      }.bind(this));

      this.dataChart = this.data.budgets[this.measure];
      this.kind = this.data.kind;
      this.dataYear = this.parseDate(this.data.year);

      this.dataDomain = [d3.min(this.dataChart.map(function(d) { return d3.min(d.values.map(function(v) { return v.value; })); })), 
              d3.max(this.dataChart.map(function(d) { return d3.max(d.values.map(function(v) { return v.value; })); }))];


      // Set the scales
      this.xScale
        .domain(d3.extent(this.dataChart[0].values, function(d) { return d.date; }))
        .range([this.margin.left, this.width]);

      this.yScale
        .domain([this.dataDomain[0] * .3, this.dataDomain[1] * 1.2])
        .range([this.height, this.margin.top]);
      
      this.colorScale
        .domain(this.dataChart.map(function(d) { return d.name; }));
      
      // Define the axis 
      this.xAxis
          .scale(this.xScale)
          .orient("bottom");  

      this.yAxis
          .scale(this.yScale)
          .tickValues(this._tickValues(this.yScale))
          .tickFormat(function(d) { return this.measure != 'percentage' ? d3.round(d, 2) : d3.format('%'); }.bind(this))
          .orient("left");

      // Define the line
      this.line
        .interpolate("cardinal")
        .x(function(d) { return this.xScale(d.date); }.bind(this))
        .y(function(d) { return this.yScale(d.value); }.bind(this));

      
      // --> DRAW THE AXIS
      this.svgLines.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(" + 0 + "," + this.height + ")")
          .call(this.xAxis);

      this.svgLines.append("g")
          .attr("class", "y axis")
          .attr("transform", "translate(" + (this.margin.left - 10) + ",0)")
          .call(this.yAxis);

      // Change ticks color
      d3.selectAll('.axis').selectAll('text')
        .attr('fill', this.darkColor);

      d3.selectAll('.axis').selectAll('path')
        .attr('stroke', this.darkColor);


      // --> DRAW THE LINES  
      this.chart = this.svgLines.append('g')
          .attr('class', 'evolution_chart');

      this.chart.append('g')
          .attr('class', 'lines')
        .selectAll('path')
          .data(this.dataChart)
          .enter()
        .append('path')
          .attr('class', function(d) { return 'evolution_line ' + this._normalize(d.name); }.bind(this))
          .attr('d', function(d) { return this.line(d.values); }.bind(this))
          .style('stroke', function(d) { return this.colorScale(d.name); }.bind(this))
          .style('stroke-width', function(d, i) { return i == 0 ? this.heavyLine : this.lightLine; }.bind(this))


      // Add dot to lines
      this.chart.selectAll('g.dots')
          .data(this.dataChart)
          .enter()
        .append('g')
          .attr('class', 'dots')
        .selectAll('circle')
          .data(function(d) { return d.values; })
          .enter()
        .append('circle')
          .attr('class', function(d) { return 'dot_line ' + this._normalize(d.name) + ' x' + d.date.getFullYear(); }.bind(this))
          .attr('cx', function(d) { return this.xScale(d.date); }.bind(this))
          .attr('cy', function(d) { return this.yScale(d.value); }.bind(this))
          .attr('r', this.radius)
          .style('fill', function(d) { return this.colorScale(d.name); }.bind(this))
        .on('mouseover', this._mouseover.bind(this))
        .on('mouseout', this._mouseout.bind(this)); 
      

      // --> DRAW THE Legend 
      var svgLegend = d3.select('.svg_lines');
      
      var series = this.colorScale.domain();
      
      var labels = [];
      for (var i = 0; i < series.length; i++) {
        if (this.niceCategory[series[i]] != undefined) {
          labels.push(this.niceCategory[series[i]])
        } else {
          labels.push(series[i])
        }
      }
    
      svgLegend.append("g")
        .attr("class", "legend_evolution")
        .attr("transform", "translate(" + (this.width - (this.margin.right * 6)) + ",20)");

      this.legendEvolution
        .shape('path', d3.svg.symbol().type('circle').size(80)())
        .shapeWidth(14)
        .shapePadding(10)
        .scale(this.colorScale)
        .labels(labels);

      d3.select(".legend_evolution")
        .call(this.legendEvolution);

      svgLegend.selectAll('.label')
        .attr('fill', this.darkColor)
        .attr('font-size', '14px')


    }.bind(this)); // end load data
  }, // end render

  updateRender: function () {

    // re-map the data
    this.dataChart = this.data.budgets[this.measure];
    this.kind = this.data.kind;
    this.dataYear = this.parseDate(this.data.year);

    this.dataDomain = [d3.min(this.dataChart.map(function(d) { return d3.min(d.values.map(function(v) { return v.value; })); })), 
              d3.max(this.dataChart.map(function(d) { return d3.max(d.values.map(function(v) { return v.value; })); }))];

    // Update the scales
    this.xScale
      .domain(d3.extent(this.dataChart[0].values, function(d) { return d.date; }));

    this.yScale
      .domain([this.dataDomain[0] * .3, this.dataDomain[1] * 1.2]);

    this.colorScale
      .domain(this.dataChart.map(function(d) { return d.name; }));

    // Update the axis
    this.xAxis.scale(this.xScale);
 
    this.yAxis
        .scale(this.yScale)
        .tickValues(this._tickValues(this.yScale))
        .tickFormat(function(d) { return this.measure != 'percentage' ? d3.round(d, 2) : d3.round(d * 100, 2) + '%'; }.bind(this));

    this.svgLines.select(".x.axis")
      .transition()
      .duration(this.duration)
      .delay(this.duration/2)
      .ease("sin-in-out") 
      .call(this.xAxis);

    this.svgLines.select(".y.axis")
      .transition()
      .duration(this.duration)
      .delay(this.duration/2)
      .ease("sin-in-out") 
      .call(this.yAxis);

    // Change ticks color
    d3.selectAll('.axis').selectAll('text')
      .attr('fill', this.darkColor);

    d3.selectAll('.axis').selectAll('path')
      .attr('stroke', this.darkColor);

    // Update lines
    this.svgLines.selectAll('.evolution_line')
      .data(this.dataChart)
      .transition()
      .duration(this.duration)
      .attr('d', function(d) { return this.line(d.values); }.bind(this))
      .style('stroke', function(d) { return this.colorScale(d.name); }.bind(this));

    // Update the points
    this.svgLines.selectAll(".dots")
        .data(this.dataChart)
      .selectAll(".dot_line")
        .data(function(d) { return d.values; })
        .transition()
        .duration(this.duration)
        .attr('cx', function(d) { return this.xScale(d.date); }.bind(this))
        .attr('cy', function(d) { return this.yScale(d.value); }.bind(this))
        // .style('fill', function(v) { return this.colorScale(d3.select('.dot_line.x'+v.value).node().parentNode.__data__.name); }.bind(this)); 
        //
    var series = this.colorScale.domain();

    var labels = [];
    for (var i = 0; i < series.length; i++) {
      if (this.niceCategory[series[i]] != undefined) {
        labels.push(this.niceCategory[series[i]])
      } else {
        labels.push(series[i])
      }
    }

    // Update legends
    this.legendEvolution
        .labels(labels)
        .scale(this.colorScale);

    d3.select(".legend_evolution")
        .call(this.legendEvolution);
  },

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
        selectedCy = d3.select(selected).attr('cy');

    var tooltipData = {};

    this.dataChart.map(function(d, i) { 
      d.values.map(function(v) { 
        if ('x' + v.date.getFullYear() == selectedClass[2]) {
          if (i != 0) {
            tooltipData[v.name] = v.value
          } else {
            tooltipData['municipio'] = v.name;
            tooltipData['municipio_value'] = v.value;
          } 
        }
      }); 
    });
    console.log(selectedClass)
    console.log(tooltipData);
    
    var text = tooltipData.municipio + ':<strong> ' + d3.round(tooltipData.municipio_value) +
              '</strong>€/hab<br>Media Nacional: <strong>' + d3.round(tooltipData.mean_national)+ 
              '</strong>€/hab<br>Media Autonómica: <strong>' + d3.round(tooltipData.mean_autonomy) +
              '</strong>€/hab<br>Media Provincial: <strong>' + d3.round(tooltipData.mean_province) + '</strong>€/hab';

    // Append vertical line
    this.svgLines.selectAll('.v_line')
        .data([selectedCx, selectedCy])
        .enter().append('line')
        .attr('class', 'v_line')
            .attr('x1', selectedCx)
            .attr('y1', selectedCy)
            .attr('x2', selectedCx)
            .attr('y2', selectedCy)
            .style('stroke', this.mainColor);

    this.svgLines.selectAll('.v_line')
        .transition()
        .duration(this.duration)
        .attr('y1', function(d, i) { return i == 0 ? this.margin.top : selectedCy; }.bind(this))
        .attr('y2', function(d, i) { return i == 0 ? selectedCy : this.height; }.bind(this));

    d3.select(selected).transition()
      .duration(this.duration / 4)
      .attr('r', this.radius * 1.5);

    this.svgLines.selectAll('.dot_line')
      .filter(function(d) { return d.name != selectedClass[1] && 'x' + d.date.getFullYear() != selectedClass[2]; })
      .transition()
      .duration(this.duration / 4)
      .style('opacity', this.opacityLow);

    this.svgLines.selectAll('.evolution_line')
      .filter(function(d) { return d.name != selectedClass[1]; })
      .transition()
      .duration(this.duration / 4)
      .style('opacity', this.opacityLow);
    
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
        selectedCx = d3.select(selected).attr('cx'),
        selectedCy = d3.select(selected).attr('cy');

    var text = 'pepe fúe a la playa'

    this.svgLines.selectAll('.v_line')
        .transition()
        .duration(this.duration / 4)
        .attr('y1', selectedCy)
        .attr('y2', selectedCy)
        .remove();


    this.svgLines.selectAll('.dot_line')
      .transition()
      .duration(this.duration / 4)
      .attr('r', this.radius)
      .style('opacity', 1);

    this.svgLines.selectAll('.evolution_line')
      .transition()
      .duration(this.duration / 4)
      .style('opacity', 1);
    
    this.tooltip
        .transition()
        .duration(this.duration / 4)
        .style('opacity', 0);
  },

  _normalize: (function() {
    var from = "ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ", 
        to   = "AAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_",
        mapping = {};
   
    for(var i = 0, j = from.length; i < j; i++ )
        mapping[ from.charAt( i ) ] = to.charAt( i );
   
    return function( str ) {
        var ret = [];
        for( var i = 0, j = str.length; i < j; i++ ) {
            var c = str.charAt( i );
            if( mapping.hasOwnProperty( str.charAt( i ) ) )
                ret.push( mapping[ c ] );
            else
                ret.push( c );
        }      
        return ret.join( '' ).toLowerCase();
    }
 
  })()

}); // End object








