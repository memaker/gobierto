'use strict';

var VisLineasJ = Class.extend({
  init: function(divId, tableID, measure, series) {
    this.container = divId;
    this.tableContainer = tableID;

    // Chart dimensions
    this.containerWidth = null;
    this.tableWidth = null;
    this.margin = {top: 30, right: 60, bottom: 20, left: 20};
    this.width = null;
    this.height = null;

    // Variable: valid values are total_budget and total_budget_per_inhabitant
    // TODO: check what to do with percentage
    this.measure = measure;
    this.series = series;

    // Scales
    this.xScale = d3.time.scale();
    this.yScale = d3.scale.linear();
    this.colorScale = d3.scale.ordinal();
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
    this.lastYear = null;

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
    this.radius = 4;
    this.heavyLine = 3;
    this.mediumLine = 2;
    this.lightLine = 1;
    this.opacity = .7;
    this.opacityLow = .4;
    this.duration = 400;
    this.mainColor = '#F69C95';
    this.darkColor = '#B87570';
    this.softGrey = '#d6d5d1';
    this.darkGrey = '#554E41';
    this.blue = '#2A8998';
    this.meanColorRange = ['#F4D06F', '#F8B419', '#DA980A', '#2A8998'];
    this.comparatorColorRange = ['#2A8998', '#F8B419', '#b82e2e', '#66aa00', '#dd4477',
                                  '#636363', '#273F8E', '#e6550d', '#990099', '#06670C'];
                                    // azul main, amarillo main, rojo g scale, verde g, verde, violeta,
                                    // gris

    this.niceCategory = null;
  },

  render: function(urlData) {
    $(this.container).html('');
    $(this.tableContainer).html('');

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.container).style('width'), 10);
    this.tableWidth = parseInt(d3.select(this.tableContainer).style('width'), 10);
    this.margin.right = this.measure == 'per_person' ? this.containerWidth * .07 : this.containerWidth * .15;

    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / 2.6) - this.margin.top - this.margin.bottom;

    if (this.height < 230) {
      this.height = 230;
    }

    // Append svg
    this.svgLines = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom + 10)
        .attr('class', 'svg_lines')
      .append('g')
        .attr('transform', 'translate(' + 0 + ',' + this.margin.top + ')');

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
      this.lastYear = this.parseDate(this.data.year).getFullYear(); // For the mouseover interaction
      this.dataTitle = this.data.title;



      ////// Complete the dataTable.
      // Get all the years
      var years = [];

      this.dataChart.map(function(d) {
        d.values.map(function(v) {
          if (years.map(Number).indexOf(+v.date) == -1) {
            years.push(v.date)
          }
        });
      });

      // Sort them
      years = years.sort(d3.ascending)

      // Create a values object for every municipality for every year
      this.dataChart.map(function(d) {

        if (d.values.length != years.length) {
          years.forEach(function(year) {

            // If the year does not exist
            // Push a new object
            var aux = d.values.filter(function(v) {
              return v.date == year;
            });

            if (aux.length == 0) {
              var obj = {
                date: year,
                dif: null,
                name: d.name,
                value: null
              }
              d.values.push(obj)
            }
          });
        }
      });


      this.dataDomain = [d3.min(this.dataChart.map(function(d) { return d3.min(d.values.map(function(v) { return v.value; })); })),
              d3.max(this.dataChart.map(function(d) { return d3.max(d.values.map(function(v) { return v.value; })); }))];

      if (this.dataDomain[0] > 100000) {
        var min = Math.floor((this.dataDomain[0] * .1)/10000.0) * 10000;
      } else {
        var min = Math.floor((this.dataDomain[0] * .1)/100.0) * 100;
      }

      if (this.dataDomain[1] > 100000) {
        var max = Math.floor((this.dataDomain[1] * 1.2)/10000.0) * 10000;
      } else {
        var max = Math.ceil(this.dataDomain[1] * 1.2);
      }

      // Set the scales
      this.xScale
        .domain(d3.extent(years))
        .range([this.margin.left, this.width - (this.margin.right)]);

      this.yScale
        // .domain([this.dataDomain[0] * .3, this.dataDomain[1] * 1.2])
        .domain([min, max])
        .range([this.height, this.margin.top]);

      this.colorScale
        .range(this.series == 'means' ? this.meanColorRange : this.comparatorColorRange)
        .domain(this.dataChart.map(function(d) { return d.name; }));


      // Define the axis
      this.xAxis
          .scale(this.xScale)
          .orient("bottom");

      this.yAxis
          .scale(this.yScale)
          .tickValues(this._tickValues(this.yScale))
          .tickFormat(function(d) { return accounting.formatMoney(d, "€", 0, ".", ","); })
          .tickSize(-(this.width - (this.margin.right + this.margin.left - 20)))
          .orient("right");


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
          .attr("transform", "translate(" + (this.width - this.margin.right) + ",0)")
          .call(this.yAxis);

      // Change ticks color
      d3.selectAll('.axis').selectAll('text')
        .attr('fill', this.darkGrey)
        .style('font-size', '12px');

      d3.selectAll('.y.axis').selectAll('text')
        .attr("transform", "translate(10,0)");

      d3.selectAll('.x.axis').selectAll('text')
        .attr("transform", "translate(0,10)");

      d3.selectAll('.y.axis').selectAll('path')
        .attr('stroke', 'none');

       d3.selectAll('.axis').selectAll('line')
        .attr('stroke', this.softGrey);

      // --> DRAW VERTICAL LINE
      this.svgLines.selectAll('.v_line')
            .data([this.dataYear])
            .enter()
          .append('line')
            .attr('class', 'v_line')
            .attr('x1', function(d) { return this.xScale(d); }.bind(this))
            .attr('y1', this.margin.top)
            .attr('x2', function(d) { return this.xScale(d); }.bind(this))
            .attr('y2', this.height)
            .style('stroke', this.darkGrey);


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
          .attr('d', function(d) { return this.line(d.values.filter(function(v) { return v.value != null; })); }.bind(this))
          .style('stroke', function(d) { return this.colorScale(d.name); }.bind(this))
          .style('stroke-width', function(d, i) {
            if (this.series == 'means') {
              return i == 3 ? this.heavyLine : this.lightLine;
            } else {
              return this.mediumLine;
            }
          }.bind(this))


      // Add dot to lines
      this.chart.selectAll('g.dots')
          .data(this.dataChart)
          .enter()
        .append('g')
          .attr('class', 'dots')
        .selectAll('circle')
          .data(function(d) { return d.values.filter(function(v) { return v.value != null; }); })
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
          .attr('dx', -this.margin.left)

          .attr('dy', -this.margin.top * 1.3)
          .attr('text-anchor', 'start')
          .text(this.dataTitle)
          .style('fill', this.darkGrey)
          .style('font-size', '1.2em');



      // --> DRAW THE 'TABLE'

      // Set columns and rows
      var columns = ['color', 'name', 'value', 'dif']

      var rows = this.colorScale.domain();
      rows.push('header')

      var colors = {
        'mean_province': 'province',
        'mean_autonomy': 'com',
        'mean_national': 'country'

      }
      // Set scales

      this.yScaleTable.domain(rows).rangeRoundBands([this.height, 0]);
      this.xScaleTable.domain([0,1]).range([0, this.tableWidth]);

      var table = d3.select(this.tableContainer).append('table'),
        thead = table.append('thead'),
        tbody = table.append('tbody');


      // append the header row
      thead.append("tr")
          .selectAll("th")
          .data(columns)
          .enter()
        .append("th")
          .attr('title', function(column) { return column; })
          .attr('class', function(column) {
            if (column == 'dif') {
              return 'right per_change'
            } else if (column == 'value') {
              return 'right year_header'
            }
          }.bind(this))
          .text(function(column) {
            if (column == 'dif') {
              return 'Cambio sobre año anterior'
            } else if (column == 'value') {
              return this.dataYear.getFullYear();
            } else {
              return '';
            }
          }.bind(this));

      thead.select('.year_header')
          .style('font-size', '14px')


      // create a row for each object in the data
      var rows = tbody.selectAll("tr")
          .data(this.series == 'means' ? this.dataChart.reverse() : this.dataChart)
          // .data(this.dataChart)
          .enter()
        .append("tr")
          .attr('class', function(d) { return this._normalize(d.name); }.bind(this))
        .on('mouseover', this._mouseoverTable.bind(this))
        .on('mouseout', this._mouseoutTable.bind(this));

      // create a cell in each row for each column
      var cells = rows.selectAll("td")
          .data(function(row) {

            var dataChartFiltered = row.values.filter(function(v) {
                    return v.date.getFullYear() == this.dataYear.getFullYear();
                  }.bind(this))

            dataChartFiltered.map(function(d) { return colors[d.name] != undefined ? d['color']= 'le le-' + colors[d.name] : d['color'] = 'le le-place'; });

            return columns.map(function(column) {
                if (column == 'name') {
                  var value = this.niceCategory[dataChartFiltered[0][column]] != undefined ? this.niceCategory[dataChartFiltered[0][column]] : dataChartFiltered[0][column];
                  var classed = this._normalize(dataChartFiltered[0].name)

                } else if (column == 'value') {
                  var value = dataChartFiltered[0][column] != null ? accounting.formatMoney(dataChartFiltered[0][column]) : '-- €'
                  var classed = 'value right ' + this._normalize(dataChartFiltered[0].name)
                } else if (column == 'dif') {
                  if (dataChartFiltered[0][column] != null) {
                    var value = dataChartFiltered[0][column] > 0 ? '+' +dataChartFiltered[0][column] + '%' : dataChartFiltered[0][column] + '%'
                  } else {
                    var value = '--%'
                  }
                  var classed = 'dif right ' + this._normalize(dataChartFiltered[0].name)
                } else {
                  var value = dataChartFiltered[0][column]
                  var classed = this._normalize(dataChartFiltered[0].name)
                }
                return {column: column,
                        value: value,
                        name: dataChartFiltered[0].name,
                        classed: classed
                      };
            }.bind(this));

          }.bind(this))
          .enter()
        .append("td")
          .attr('class', function(d) { return d.classed ; })
          .html(function(d, i) {return i != 0 ? d.value : '<i class="' + d.value + '"></i>'; }.bind(this));



          // Replace bullets colors

          var bulletsColors = this.colorScale.range();

          d3.selectAll('.le').forEach(function(v) {
            v.forEach(function(d,i) {
              d3.select(v[i])
                .style('background', this.series == 'means' ? bulletsColors[(bulletsColors.length - 1) - i] : bulletsColors[i])
            }.bind(this));
          }.bind(this));

    }.bind(this)); // end load data
  }, // end render

  // updateRender: function () {
  //   // re-define format percent
  //   this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".0f");

  //   // re-map the data
  //   this.dataChart = this.data.budgets[this.measure];
  //   this.kind = this.data.kind;
  //   this.dataYear = this.parseDate(this.data.year);

  //   this.dataDomain = [d3.min(this.dataChart.map(function(d) { return d3.min(d.values.map(function(v) { return v.value; })); })),
  //             d3.max(this.dataChart.map(function(d) { return d3.max(d.values.map(function(v) { return v.value; })); }))];

  //   // Update the scales
  //   this.xScale
  //     .domain(d3.extent(this.dataChart[0].values, function(d) { return d.date; }));

  //   this.yScale
  //     .domain([this.dataDomain[0] * .3, this.dataDomain[1] * 1.2]);

  //   this.colorScale
  //     .domain(this.dataChart.map(function(d) { return d.name; }));

  //   // Update the axis
  //   this.xAxis.scale(this.xScale);

  //   this.yAxis
  //       .scale(this.yScale)
  //       .tickValues(this._tickValues(this.yScale))
  //       .tickFormat(this.formatPercent)

  //   this.svgLines.select(".x.axis")
  //     .transition()
  //     .duration(this.duration)
  //     .delay(this.duration/2)
  //     .ease("sin-in-out")
  //     .call(this.xAxis);

  //   this.svgLines.select(".y.axis")
  //     .transition()
  //     .duration(this.duration)
  //     .delay(this.duration/2)
  //     .ease("sin-in-out")
  //     .call(this.yAxis);

  //   // Change ticks color
  //   d3.selectAll('.axis').selectAll('text')
  //     .attr('fill', this.darkGrey);

  //   d3.selectAll('.axis').selectAll('path')
  //     .attr('stroke', this.darkGrey);

  //   // Update lines
  //   this.svgLines.selectAll('.evolution_line')
  //     .data(this.dataChart)
  //     .transition()
  //     .duration(this.duration)
  //     .attr('d', function(d) { return this.line(d.values); }.bind(this))
  //     .style('stroke', function(d) { return this.colorScale(d.name); }.bind(this));

  //   // Update the points
  //   this.svgLines.selectAll(".dots")
  //       .data(this.dataChart)
  //     .selectAll(".dot_line")
  //       .data(function(d) { return d.values; })
  //       .transition()
  //       .duration(this.duration)
  //       .attr('cx', function(d) { return this.xScale(d.date); }.bind(this))
  //       .attr('cy', function(d) { return this.yScale(d.value); }.bind(this));

  //   // Update table figures
  //   this.svgTable.selectAll('.legend_value')
  //       .data(this.dataChart)
  //       .text(function(d) {
  //         var dataChartFiltered = d.values.filter(function(v) {
  //           return v.date.getFullYear() == this.dataYear.getFullYear();
  //         }.bind(this));
  //         return this.formatPercent(dataChartFiltered[0].value) + this._units();
  //       }.bind(this))
  //       .transition()
  //         .duration(this.duration/4)
  //         .style('font-size', '12px')
  //         .style('font-weight', '600')
  //       .transition()
  //         .duration(this.duration/4)
  //         .style('font-size', '10px')
  //         .style('font-weight', '300');


  //    this.svgTable.selectAll('.legend_dif')
  //       .data(this.dataChart)
  //       .text(function(d) {
  //         var dataChartFiltered = d.values.filter(function(v) {
  //           return v.date.getFullYear() == this.dataYear.getFullYear();
  //         }.bind(this));
  //         return dataChartFiltered[0].dif > 0 ? '+' + this.formatPercent(dataChartFiltered[0].dif) + this._units() : this.formatPercent(dataChartFiltered[0].dif) + this._units();
  //       }.bind(this))
  //       .transition()
  //         .duration(this.duration/4)
  //         .style('font-size', '12px')
  //         .style('font-weight', '600')
  //       .transition()
  //         .duration(this.duration/4)
  //         .style('font-size', '10px')
  //         .style('font-weight', '300');
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
        selectedCy = d3.select(selected).attr('cy');

    var dataChartFiltered = this.dataChart.map(function(d, i) {
      return d.values.filter(function(v) {
        return v.date.getFullYear() == selectedData.date.getFullYear();
      })[0];
    });


    if (this.lastYear != selectedData.date.getFullYear()) {
        // Hide table figures and update text
        // Year header
        d3.selectAll('.year_header')
          .transition()
            .duration(this.duration / 2)
            .style('opacity', 0)
          .text(selectedData.date.getFullYear())
          .transition()
            .duration(this.duration)
            .style('opacity', 1);

        // Values
        d3.selectAll('.value')
          .transition()
            .duration(this.duration / 2)
            .style('opacity', 0)
          .text(function(d) {
              var newValue = dataChartFiltered.filter(function(value) { return value.name == d.name; })
              d.value = newValue[0].value
              return d.value != null ? accounting.formatMoney(d.value) : '-- €';
            })
          .transition()
            .duration(this.duration)
            .style('opacity', 1);

        // Difs
        d3.selectAll('.dif')
          .transition()
            .duration(this.duration / 2)
            .style('opacity', 0)
          .text(function(d) {
            var newValue = dataChartFiltered.filter(function(dif) { return dif.name == d.name; })
            d.dif = newValue[0].dif
            if (d.dif != null) {
              return d.dif <= 0 ? d.dif + '%' : '+' + d.dif + '%';
            } else {
              return '--%'
            }

            })
          .transition()
            .duration(this.duration)
            .style('opacity', 1);
      }

    this.lastYear = selectedData.date.getFullYear();

    this.svgLines.selectAll('.v_line')
        .transition()
        .duration(this.duration / 2)
        .attr('x1', function(d) { return this.xScale(selectedData.date); }.bind(this))
        .attr('x2', function(d) { return this.xScale(selectedData.date); }.bind(this));

    d3.select(selected).transition()
      .duration(this.duration)
      .attr('r', this.radius * 1.5);

    this.svgLines.selectAll('.dot_line')
      .filter(function(d) { return d.name != selectedClass[1] && 'x' + d.date.getFullYear() != selectedClass[2]; })
      .transition()
      .duration(this.duration)
      .style('opacity', this.opacityLow);

    this.svgLines.selectAll('.evolution_line')
      .filter(function(d) { return d.name != selectedClass[1]; })
      .transition()
      .duration(this.duration)
      .style('opacity', this.opacityLow);


  },

  _mouseout: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList,
        selectedData = d3.select(selected).data()[0],
        selectedCx = d3.select(selected).attr('cx'),
        selectedCy = d3.select(selected).attr('cy');

    // this.svgLines.selectAll('.v_line')
    //     .transition()
    //     .duration(this.duration / 3)
    //     .attr('y1', selectedCy)
    //     .attr('y2', selectedCy)
    //     .remove();


    this.svgLines.selectAll('.dot_line')
      .transition()
      .duration(this.duration)
      .attr('r', this.radius)
      .style('opacity', 1);

    this.svgLines.selectAll('.evolution_line')
      .transition()
      .duration(this.duration)
      .style('opacity', 1);
  },

  _mouseoverTable: function () {
    var classed = d3.event.target.classList[d3.event.target.classList.length - 1]

    this.svgLines.selectAll('.dot_line')
      .filter(function(d) { return this._normalize(d.name) != classed; }.bind(this))
      .transition()
      .duration(this.duration)
      .style('opacity', this.opacityLow);

    this.svgLines.selectAll('.evolution_line')
      .filter(function(d) { return this._normalize(d.name) != classed; }.bind(this))
      .transition()
      .duration(this.duration)
      .style('opacity', this.opacityLow);


  },

  _mouseoutTable: function () {
    var classed = d3.event.target.classList[d3.event.target.classList.length - 1]

    this.svgLines.selectAll('.dot_line')
      .transition()
      .duration(this.duration)
      .attr('r', this.radius)
      .style('opacity', 1);

    this.svgLines.selectAll('.evolution_line')
      .transition()
      .duration(this.duration)
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







