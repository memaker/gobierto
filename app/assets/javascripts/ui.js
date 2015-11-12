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
    console.log('in');
    $(this).find('.tree').show();
  }, function(e) {
    console.log('out');
    $(this).find('.tree').hide();
  });

  $('menu.global').velocity("fadeIn", { duration: 250 });
      $('menu.global').addClass('global_open'); 
      $('menu.global .content').velocity({ 
        translateX: 740,
        opacity: 1
      }, 250);

});
