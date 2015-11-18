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
      perPageDefault: 100,
      perPageOptions: [25,50,100, 300],
      sorts: { 'gasto': -1, 'ingreso': -1 }
    },
    readers: {
      'habitantes': function(el, record) { return Number(el.textContent); },
      'gasto/Hab': function(el, record) { return Number(el.textContent); },
      'ingreso/Hab': function(el, record) { return Number(el.textContent); },
      'gasto': function(el, record) { return Number(el.textContent); },
      'ingreso': function(el, record) { return Number(el.textContent); },
      '%S/Total': function(el, record) { return Number(el.textContent); },
    },
    writers: {
      'habitantes': function(record) { return "<span class='soft'>" + accounting.formatNumber(record.habitantes, 0) +"</span>"; },
      'gasto/Hab': function(record) { return accounting.formatMoney(record['gasto/Hab']); },
      'ingreso/Hab': function(record) { return accounting.formatMoney(record['ingreso/Hab']); },
      'gasto': function(record) { return accounting.formatMoney(record.gasto, '€', 0); },
      'ingreso': function(record) { return accounting.formatMoney(record.ingreso, '€', 0); },
      '%S/Total': function(record) { return accounting.formatNumber(record['%S/Total'], 2) + " %"; },
    },
    table: {
      copyHeaderClass: true
    }
  }).bind('dynatable:afterUpdate', function(){
    sparkRender();
  });

  function sparkRender(){
    $('.sparkline').sparkline('html',SPARKLINES_DEFAULTS);
  }
  sparkRender();

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

