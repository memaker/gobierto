'use strict';

function submitForm(){
  if($('#location_type').val() === '' && $('#functional_area').val() === '' && $('#economic_area').val() === ''){
    return false;
  } 
  $('.spinner').show();
  document.forms[0].submit();
}

$(function(){
  $('.spinner').hide();

  if($(window).width() > 740) {
    function rebindAll() {
      $('.tipsit').tipsy({fade: true, gravity: 's'});
      $('.tipsit-n').tipsy({fade: true, gravity: 'n'});
      $('.tipsit-w').tipsy({fade: true, gravity: 'w'});
      $('.tipsit-e').tipsy({fade: true, gravity: 'e'});
    }
  }

  // init
  $('.dynatable').dynatable({
    inputs: {
      paginationPrev: 'Anterior',
      paginationNext: 'Siguiente',
      paginationGap: [1,2,2,1],
      perPageText: 'Mostrar: ',
      recordCountText: 'Mostrando ',
      processingText: 'Procesando...', 
      searchText: 'Buscar:'
    },
    dataset: {
      perPageDefault: 50,
      perPageOptions: [25,50,100],
      //sorts: { 'budget': -1 },
      ajax: true,
      ajaxUrl: window.location.pathname + '.json/' + window.location.search,
      ajaxOnLoad: true,
      records: []
    },
    readers: {
      'population': function(el, record) { return Number(el.textContent); },
      'budget_per_inhabitant': function(el, record) { return Number(el.textContent); },
      'budget': function(el, record) { return Number(el.textContent); },
      'percentage_from_total': function(el, record) { return Number(el.textContent); },
    },
    writers: {
      'population': function(record) { return "<span class='soft'>" + accounting.formatNumber(record.population, 0) +"</span>"; },
      'budget_per_inhabitant': function(record) { return accounting.formatMoney(record.budget_per_inhabitant); },
      'budget': function(record) { return accounting.formatMoney(record.budget, '€', 0); },
      'percentage_from_total': function(record) { return accounting.formatNumber(record.percentage_from_total, 2) + " %"; },
    },
    table: {
      copyHeaderClass: true,
    }
  }).bind('dynatable:afterUpdate', function(){
    sparkRender();
    updateHeaders();
  });

  function sparkRender(){
    $('.sparkline').sparkline('html',SPARKLINES_DEFAULTS);
  }
  sparkRender();

  function updateHeaders(){
    $('.dynatable th a').each(function(){
      $(this).text(window.headerName[$(this).text().replace(' ▼', '').replace(' ▲', '')]);
    });
  }

  $('.bonsai').bonsai();

  $('.select_from_tree').hover(function(e) {
    e.preventDefault();
    $(this).find('.tree').show();
  }, function(e) {
    $(this).find('.tree').hide();
  });

  $(document).on('click', '[data-menu-area]', function(e){
    e.preventDefault();
    $('#' + $(this).data('rel')).val($(this).data('menu-area'));

    var text = $(this).text();
    $('.js-' + $(this).data('rel') + ' a').text(text);
    $(this).parents('.tree').hide();

    submitForm();
  });

  var $option = $('#functional_area');
  var value = $option.val();
  if(value !== undefined && value !== ""){
    var text = $('.js-functional [data-menu-area=' + value + ']').text();
    $('.js-functional_area a').text(text);
  }

  var $option = $('#economic_area');
  var value = $option.val();
  if(value !== undefined && value !== ""){
    var text = $('.js-economic [data-menu-area=' + value + ']').text();
    $('.js-economic_area a').text(text);
  }

  var searchOptions = {
    serviceUrl: '/search',
    onSelect: function (suggestion) {
      $('#location_id').val(suggestion.data.id);
      $('#location_type').val(suggestion.data.type);
      $('#search').val(suggestion.value);
      submitForm();
    },
    groupBy: 'category',
  };

  $('#search').autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $(document).on('mouseenter', '.compare_cont', function(e){
    e.preventDefault();
    $(this).find('.compare').velocity("fadeIn", { duration: 250 });
  });

  $(document).on('mouseleave', '.compare_cont', function(e){
    e.preventDefault();
    $(this).find('.compare').velocity("fadeOut", { duration: 250 });
  });

  // TODO
  //window.filters = new Filters($('form'));

  $('#kind').on('change', function(e){
    $.ajax('/categories/economic/' + $(this).val());
  });

  $('#year,#population').on('change', function(e){
    submitForm();
  });

  $(document).on('click', '.js-disabled', function(e){
    e.preventDefault();
  });

  var selector = '#bars_vis_fun';
  if($(selector).length > 0){
    var barsVisFun = new BarsVis(selector, 'mean_national');
    barsVisFun.render($(selector).data('url'));
  }

  var selector = '#bars_vis_econ';
  if($(selector).length > 0){
    var barsVisEcon = new BarsVis(selector, 'mean_national');
    barsVisEcon.render($(selector).data('url'));
  }

  d3.selectAll('.context.button')
  .on('click', function(d) {
    d3.selectAll(".context.button.buttonSelected").classed("buttonSelected", false);
    d3.select(this).classed("buttonSelected", true);
    barsVisFun.context = this.id;
    barsVisFun.updateRender();
    barsVisEcon.context = this.id;
    barsVisEcon.updateRender();
  });

  $('[data-reset]').on('click', function(e){
    e.preventDefault();
    var selector = $(this).data('reset');
    if(selector == 'location'){
      $('#location_id').val('');
      $('#location_type').val('');
      $('#search').val('');
      submitForm();
    } else {
      $('#' + selector).val('');
      $('.js-' + selector + ' a').html('&nbsp; <i class="fa fa-sort-down"></i>');
    }
  });

  if($('#vis_distribution').size() > 0) {

    var visDistribution = new VisDistribution('#vis_distribution', 'per_person');//, 'percentage', 'mean_province');
    // visDistribution.render('api/data/distribution.json' + location.search);
    visDistribution.render('/distribution_sample_with_buckets.json');

    d3.selectAll('.measure.button')
      .on('click', function(d) {
        d3.selectAll(".measure.button.buttonSelected").classed("buttonSelected", false);
        d3.select(this).classed("buttonSelected", true);
        visDistribution.measure = this.id;

        visDistribution.updateRender();
      });
  }

  if($('#vis_dispersion').size() > 0) {
    var visDispersion = new VisDispersion('#vis_dispersion', 'per_person');
    visDispersion.render('/api/data/dispersion.json' + location.search);
  }

});
