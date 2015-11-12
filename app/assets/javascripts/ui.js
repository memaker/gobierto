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
      perPageDefault: 25,
      perPageOptions: [25,50,100, 300]
    }
  });

  $('.sparkline').sparkline('html',SPARKLINES_DEFAULTS);

  $('.select2').select2();
  $('.bonsai').bonsai();
  
  $('.select_from_tree').hover(function(e) {
    e.preventDefault();
    $(this).find('.tree').show();
  }, function(e) {
    $(this).find('.tree').hide();
  });

  $('[data-menu-area]').click(function(e){
    e.preventDefault();
    $('#' + $(this).data('rel')).val($(this).data('menu-area'));

    var text = $(this).text();
    $(this).parents('.select_from_tree').find('.label a').text(text);
    $(this).parents('.tree').hide();
  });

  var $option = $('#functional_area');
  var value = $option.val();
  if(value !== undefined && value !== ""){
    var text = $('[data-menu-area=' + value + ']').text();
    $option.parent().find('.label a').text(text);
  }

  var $option = $('#functional_area');
  var value = $option.val();
  if(value !== undefined && value !== ""){
    var text = $('[data-menu-area=' + value + ']').text();
    $option.parent().find('.label a').text(text);
  }

});

