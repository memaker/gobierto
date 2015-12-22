'use strict';

var VisLineasJ = Class.extend({
  init: function(divId, tableID, measure) {
    this.container = divId;
    this.tableContainer = tableID;
    
    // Chart dimensions
    this.containerWidth = null;
    this.tableWidth = null;
    this.margin = {top: 40, right: 20, bottom: 40, left: 70};
    this.width = null;
    this.height = null;
    
    // Variable: valid values are total_budget and total_budget_per_inhabitant
    // TODO: check what to do with percentage
    this.measure = measure;

    // Scales
    this.xScale = d3.time.scale();
    this.yScale = d3.scale.linear();
    this.colorScale = d3.scale.ordinal().range(['#F4D06F', '#F8B419', '#DA980A', '#2A8998']);
    this.yScaleTable = d3.scale.ordinal();
    this.xScaleTable = d3.scale.linear();

    // Axis
    this.xAxis = d3.svg.axis();
    this.yAxis = d3.svg.axis();

    // Data
    this.data = null;
    this.dataChart = null;
    this.dataDomain = null;
    this.kind = null;
    this.dataYear = null;
    this.dataTitle = null;

    // Legend
    this.legendEvolution = d3.legend.color();

    // Objects
    this.tooltip = null;
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".0f");
    this.parseDate = d3.time.format("%Y").parse;
    this.line = d3.svg.line();

    // Chart objects
    this.svgLines = null;
    this.svgTable = null;
    this.chart = null;
    this.focus = null;

    // Constant values
    this.radius = 6;
    this.opacity = .7;
    this.opacityLow = .4;
    this.duration = 1500;
    this.mainColor = '#F69C95';
    this.darkColor = '#B87570';
    this.darkGrey = '#949494';
    this.blue = '#2A8998';
    this.heavyLine = 5;
    this.lightLine = 2;
    this.niceCategory = null;
  },

  render: function(urlData) {
    $(this.container).html('');
    $(this.tableContainer).html('');

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.container).style('width'), 10);
    this.tableWidth = parseInt(d3.select(this.tableContainer).style('width'), 10)
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / 1.9) - this.margin.top - this.margin.bottom;

    // Append svg
    this.svgLines = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_lines')
      .append('g')
        .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    this.svgTable = d3.select(this.tableContainer).append('svg')
        .attr('width', this.tableWidth)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_table')
      .append('g')
        .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

     // Append tooltip
    this.tooltip = this.svgTable.append('div')
      .attr('class', 'vis_lineas_j_tooltip')
      .style('opacity', 1);

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

      this.data.budgets[this.measure].forEach(function(d) { 
        d.values.forEach(function(v) {
          v.date = this.parseDate(v.date);
          v.name = d.name;
        }.bind(this));
      }.bind(this));

      // TODO
      //this.data.budgets.percentage.forEach(function(d) { 
        //d.values.forEach(function(v) {
          //v.date = this.parseDate(v.date);
          //v.name = d.name;
        //}.bind(this));
      //}.bind(this));

      this.dataChart = this.data.budgets[this.measure];
      this.kind = this.data.kind;
      this.dataYear = this.parseDate(this.data.year);
      this.dataTitle = this.data.title;

      this.dataDomain = [d3.min(this.dataChart.map(function(d) { return d3.min(d.values.map(function(v) { return v.value; })); })), 
              d3.max(this.dataChart.map(function(d) { return d3.max(d.values.map(function(v) { return v.value; })); }))];


      // Set the scales
      this.xScale
        .domain(d3.extent(this.dataChart[0].values, function(d) { return d.date; }))
        .range([this.margin.left, this.width - (this.margin.right)]);

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
          .tickFormat(this.formatPercent)
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
        .attr('fill', this.darkGrey);

      d3.selectAll('.axis').selectAll('path')
        .attr('stroke', this.darkGrey);


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
          .style('stroke-width', function(d, i) { return i == 3 ? this.heavyLine : this.lightLine; }.bind(this))


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
      
      
      // --> ADD THE CHART TITLE
      this.svgLines.append('text')
          .attr('class', 'chart_title')
          .attr('x', this.margin.left)
          .attr('y', this.margin.top)
          .attr('dx', 0)
          .attr('dy', -20)
          .attr('text-anchor', 'start')
          .text(this.dataTitle)
          .style('fill', d3.rgb(this.darkGrey).darker(2));
      
      // --> DRAW THE 'TABLE'

      // Set columns and rows
      var columns = {
        "color": 0,
        "name": 0.05,
        "value": 0.6,
        "dif": 0.8
      }

      var rows = this.colorScale.domain();
      rows.push('header')

      // Set scales

      this.yScaleTable.domain(rows).rangeRoundBands([this.height, 0]);
      this.xScaleTable.domain([0,1]).range([0, this.tableWidth]);

      // Draw elemnts
      this.svgTable.selectAll('.legend_header')
          .data(this.dataChart)
          .enter().append("foreignObject")
              .attr('class', function(d) { return 'legend_header ' + d.name; })
              .attr('width',this.yScaleTable.rangeBand())
              .attr('height', this.yScaleTable.rangeBand())
              .attr('dx', 0)
              .attr('dy', 0)
              .attr('transform', 'translate(' + this.xScaleTable(.62) + ',' + 0 + ')')
              .style('fill', this.darkGrey)
              .style('text-align', 'right')
              .style('color', this.darkGrey)
              .html('CAMBIO SOBRE EL AÑO ANTERIOR');

      this.svgTable.selectAll('.legend_bullet')
        .data(this.dataChart)
        .enter().append('circle')
            .attr('class', function(d) { return 'legend_bullet ' + d.name; })
            .attr('cx', this.xScaleTable(columns['color']))
            .attr('cy', function(d) { return this.yScaleTable(d.name) - (this.radius / 2); }.bind(this))
            .attr('r', this.radius)
            .style('fill',function(d) { return this.colorScale(d.name); }.bind(this));

      this.svgTable.selectAll('.legend_name')
          .data(this.dataChart)
          .enter().append('text')
              .attr('class', function(d) { return 'legend_name ' + d.name; })
              .attr('x', this.xScaleTable(columns['name']))
              .attr('y', function(d) { return this.yScaleTable(d.name); }.bind(this))
              .attr('dx', 0)
              .attr('dy', 0)
              .attr('text-anchor', 'start')
              .style('fill', this.darkGrey)
              .text(function(d) { return d.name.match(/^mean_/) != null ? this.niceCategory[d.name] : d.name; }.bind(this));

      this.svgTable.selectAll('.legend_value')
          .data(this.dataChart)
          .enter().append('text')
              .attr('class', function(d) { return 'legend_value ' + d.name; })
              .attr('x', this.xScaleTable(columns['value']))
              .attr('y', function(d) { return this.yScaleTable(d.name); }.bind(this))
              .attr('dx', 0)
              .attr('dy', 0)
              .attr('text-anchor', 'end')
              .style('fill', this.darkGrey)
              .text(function(d) { 
                var filterValues = d.values.filter(function(v) { 
                  return v.date.getFullYear() == this.dataYear.getFullYear();
                }.bind(this));
                return this.formatPercent(filterValues[0].value) + this._units(); 
              }.bind(this));

       this.svgTable.selectAll('.legend_dif')
          .data(this.dataChart)
          .enter().append('text')
              .attr('class', function(d) { return 'legend_dif ' + d.name; })
              .attr('x', this.xScaleTable(columns['dif']))
              .attr('y', function(d) { return this.yScaleTable(d.name); }.bind(this))
              .attr('dx', 0)
              .attr('dy', 0)
              .attr('text-anchor', 'end')
              .style('fill', this.darkGrey)
              .text(function(d) { 
                var filterValues = d.values.filter(function(v) { 
                  return v.date.getFullYear() == this.dataYear.getFullYear();
                }.bind(this));
                return filterValues[0].dif > 0 ? '+' + this.formatPercent(filterValues[0].dif) + this._units() : this.formatPercent(filterValues[0].dif) + this._units(); 
              }.bind(this));


    }.bind(this)); // end load data
  }, // end render

  updateRender: function () {
    // re-define format percent
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".0f");

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
        .tickFormat(this.formatPercent)

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
      .attr('fill', this.darkGrey);

    d3.selectAll('.axis').selectAll('path')
      .attr('stroke', this.darkGrey);

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
        .attr('cy', function(d) { return this.yScale(d.value); }.bind(this));
    
    // Update table figures
    this.svgTable.selectAll('.legend_value')
        .data(this.dataChart)
        .text(function(d) { 
          var filterValues = d.values.filter(function(v) { 
            return v.date.getFullYear() == this.dataYear.getFullYear();
          }.bind(this));
          return this.formatPercent(filterValues[0].value) + this._units(); 
        }.bind(this))
        .transition()
          .duration(this.duration/4)
          .style('font-size', '12px')
          .style('font-weight', '600')
        .transition()
          .duration(this.duration/4)
          .style('font-size', '10px')
          .style('font-weight', '300');


     this.svgTable.selectAll('.legend_dif')
        .data(this.dataChart)
        .text(function(d) { 
          var filterValues = d.values.filter(function(v) { 
            return v.date.getFullYear() == this.dataYear.getFullYear();
          }.bind(this));
          return filterValues[0].dif > 0 ? '+' + this.formatPercent(filterValues[0].dif) + this._units() : this.formatPercent(filterValues[0].dif) + this._units(); 
        }.bind(this))
        .transition()
          .duration(this.duration/4)
          .style('font-size', '12px')
          .style('font-weight', '600')
        .transition()
          .duration(this.duration/4)
          .style('font-size', '10px')
          .style('font-weight', '300');
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
          if (i != 3) {
            tooltipData[v.name] = v.value
          } else {
            tooltipData['municipio'] = v.name;
            tooltipData['municipio_value'] = v.value;
          } 
        }
      }); 
    });

    // Update table figures
    this.svgTable.selectAll('.legend_value')
            .text(function(d) { 
              var filterValues = d.values.filter(function(v) { 
                return v.date.getFullYear() == selectedData.date.getFullYear();
              }.bind(this));
              return this.formatPercent(filterValues[0].value) + this._units(); 
            }.bind(this))
            .transition()
              .duration(this.duration/4)
              .style('font-size', '12px')
              .style('font-weight', '600')
            .transition()
              .duration(this.duration/4)
              .style('font-size', '10px')
              .style('font-weight', '300');

     this.svgTable.selectAll('.legend_dif')
            .text(function(d) { 
              var filterValues = d.values.filter(function(v) { 
                return v.date.getFullYear() == selectedData.date.getFullYear();
              }.bind(this));
              return filterValues[0].dif > 0 ? '+' + this.formatPercent(filterValues[0].dif) + this._units() : this.formatPercent(filterValues[0].dif) + this._units(); 
            }.bind(this))
            .transition()
              .duration(this.duration/4)
              .style('font-size', '12px')
              .style('font-weight', '600')
            .transition()
              .duration(this.duration/4)
              .style('font-size', '10px')
              .style('font-weight', '300');


    // Append vertical line
    this.svgLines.selectAll('.v_line')
        .data([selectedCx, selectedCy])
        .enter().append('line')
        .attr('class', 'v_line')
            .attr('x1', selectedCx)
            .attr('y1', selectedCy)
            .attr('x2', selectedCx)
            .attr('y2', selectedCy)
            .style('stroke', this.blue);

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
        .duration(this.duration / 10)
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
  },

  _units: function(){
    if(this.measure == 'total_budget'){
      return ' €';
    } else {
      return ' €/hab';
    }
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








