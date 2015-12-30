'use strict';

function rebindAll() {
  $('.tipsit').tipsy({fade: true, gravity: 's', html: true});
  $('.tipsit-n').tipsy({fade: true, gravity: 'n', html: true});
  $('.tipsit-w').tipsy({fade: true, gravity: 'w', html: true});
  $('.tipsit-e').tipsy({fade: true, gravity: 'e', html: true});
  $('.tipsit-treemap').tipsy({fade: true, gravity: $.fn.tipsy.autoNS, html: true});
}

$(function(){
  $('.spinner').hide();

  if($(window).width() > 740) {
    rebindAll();
  }

  var searchOptions = {
    serviceUrl: '/search',
    onSelect: function (suggestion) {
      if(suggestion.data.type == 'Place') {
        window.location.href = '/places/' + suggestion.data.slug + '/2015';
      }
    },
    groupBy: 'category'
  };

  $('#search').autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));
  $('.sticky').sticky({topSpacing:0});

  $(document).on('mouseenter', '.compare_cont', function(e){
    e.preventDefault();
    $(this).find('.compare').velocity("fadeIn", { duration: 250 });
  });

  $(document).on('mouseleave', '.compare_cont', function(e){
    e.preventDefault();
    $(this).find('.compare').velocity("fadeOut", { duration: 250 });
  });

  $('#kind').on('change', function(e){
    $.ajax('/categories/economic/' + $(this).val());
  });

  $('#year,#population').on('change', function(e){
    submitForm();
  });

  $(".places_menu ul li").hover(function(e){
    // e.preventDefault();
    $(this).find('ul').toggle();
  });

  $('[data-line-widget-url]').on('click', function(e){
    e.preventDefault();
    $('.metric').removeClass('selected');
    $(this).addClass('selected');
  });

  // adjust height of sidebar
  $('header.global').css('height', $(document).height());
  
  $('.switcher').hover(function(e) {
    e.preventDefault();
    $(this).find('ul').show();
    $(this).find('.current').hide();
  }, function(e) {
    $(this).find('ul').hide();
    $(this).find('.current').show();
  });

  $('.modal_widget').hover(function(e) {
    e.preventDefault();
    $(this).find('.inner').velocity("fadeIn", { duration: 50 });
  }, function(e) {
    $(this).find('.inner').velocity("fadeOut", { duration: 50 });
  });

  $('.modal_widget li').hover(function(e) {
    e.preventDefault();
    $(this).find('.del_item').velocity("fadeIn", { duration: 0 });
  }, function(e) {
    $(this).find('.del_item').velocity("fadeOut", { duration: 0 });
  });

  $('th.location').hover(function(e) {
    e.preventDefault();
    $(this).find('.remove').velocity("fadeIn", { duration: 100 });
  }, function(e) {
    $(this).find('.remove').velocity("fadeOut", { duration: 100 });
  });

  $('th.add_location_cont').click(function(e) {
    e.preventDefault();
    $('.add_location input').focus();
  });

  $('th.add_location_cont').hover(function(e) {
    $('.add_location input').focus();
    $(this).find('.add_location').velocity("fadeIn", { duration: 100 });
  }, function(e) {
    $(this).find('.add_location ').velocity("fadeOut", { duration: 100 });
  });

  window.widgets = [];
  $('[data-widget-type]').each(function(){   
    window.widgets.push(new WidgetRenderer({   
      id: $(this).data('widget-type'), url: $(this).data('widget-data-url'), template: $(this).data('widget-template')   
    }));   
  });    
   
  window.widgets.forEach(function(widget){   
    widget.render();   
  });

  function parent_treemap_url(parent_url) {
    var pattern = /parent_code=\d+/;
    parent_url = parent_url.replace(pattern, function(match) {
      return match.substring(0,match.length - 1)
    });
    return parent_url + '&amp;format=json';
  }

    /* Tree navigation */
  $('.items').on('ajax:success', 'a[data-remote=true]', function(event, data, status, xhr) {
    $(this).addClass('extended');
    $(this).find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
  });

  /* Collapses branch - Prevents resending the form when extended */
  $('.items').on('ajax:beforeSend', 'a.extended', function(event, xhr, settings) {
    xhr.abort();
    $(this).removeClass('extended');
    $(this).find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
    $(this).parents('tr').next('.child_group').remove();
    
    if (window.treemap != undefined)
      window.treemap.render(parent_treemap_url($(this).attr('href')));
  });

  $('.items').on('ajax:beforeSend', 'a:not(.extended)', function(event, xhr, settings) {
    var sibs = $(this).parents('tr:not(.child_group)').siblings();
    sibs.find('a.extended').removeClass('extended').find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
    sibs.siblings('.child_group').remove();
  });

  if($('#income-treemap').length > 0){
    window.incomeTreemap = new TreemapVis('#income-treemap', 'small', false);
    window.incomeTreemap.render($('#income-treemap').data('economic-url'));
  }

  if($('#expense-treemap').length > 0){
    window.expenseTreemap = new TreemapVis('#expense-treemap', 'small', false);
    window.expenseTreemap.render($('#expense-treemap').data('economic-url'));
  }

  if($('#lines_chart').length > 0){
    var $widget = $('[data-line-widget-url].selected');
    var visLineasJ = new VisLineasJ('#lines_chart', '#lines_tooltip', $widget.data('widget-type'));
    visLineasJ.render($widget.data('line-widget-url'));

    $('[data-line-widget-url]').on('click', function(e){
      e.preventDefault();
      visLineasJ.measure = $(this).data('line-widget-type');
      visLineasJ.render($(this).data('line-widget-url'));
    });
  }

  if($('#treemap').length > 0){
    window.treemap = new TreemapVis('#treemap', 'big', true);
    window.treemap.render($('#treemap').data('url'));

    // When the treemap is clicked, we extract the URL of the node
    // and detect which is the link that expands the tree nodes with the
    // children. That node is clicked, and it triggers the treemap re-rendering
    $(document).on('click', '.treemap_node', function(e){
      e.preventDefault();
      // Remove all open tipsy
      $('.tipsit-treemap').each(function(){
        $(this).data('tipsy').hide();
      });
      var url = $(this).data('url');
      var parser = document.createElement('a');
      parser.href = url;
      url = parser.pathname + parser.search;
      var parts = url.split('?');
      url = parts[0].split('.')[0] + '?' + parts[1];
      $('a[href="'+ url + '"]').click();
    });
  }

  $('header.place').bind('inview', function(event, isInView) {
    if (isInView) {
      $('.tools').css('z-index', 10);
      $('header.sticky_top').velocity("fadeOut", { duration: 50 });
    } else {
      $('.tools').css('z-index', 200);
      $('header.sticky_top').velocity("fadeIn", { duration: 50 });
    }
  });

  $('.ie_intro .items table').click(function(e) {
    window.location.href = $(this).data("url");
  });

  
});
