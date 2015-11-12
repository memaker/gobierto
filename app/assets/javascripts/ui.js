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

  $('.select2').select2();
  $('.sparkline').sparkline('html',SPARKLINES_DEFAULTS);
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

  if($('#functional_area').val() !== ""){
    var $option = $('#functional_area');
    var value = $option.val();
    var text = $('[data-menu-area=' + value + ']').text();
    $option.parent().find('.label a').text(text);
  }

  if($('#economic_area').val() !== ""){
    var $option = $('#functional_area');
    var value = $option.val();
    var text = $('[data-menu-area=' + value + ']').text();
    $option.parent().find('.label a').text(text);
  }

});

