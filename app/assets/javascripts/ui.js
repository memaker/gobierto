'use strict';

$(function(){

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

  $('#search').autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $('.compare_cont').hover(function(e) {
    e.preventDefault();
    $(this).find('.compare').velocity("fadeIn", { duration: 250 });
  }, function(e) {
    $(this).find('.compare').velocity("fadeOut", { duration: 250 });
  });

  // TODO
  //window.filters = new Filters($('form'));

  $('#kind').on('change', function(e){
    $.ajax('/categories/economic/' + $(this).val());
  });

  $(document).on('click', '.js-disabled', function(e){
    e.preventDefault();
  });

});

