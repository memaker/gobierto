'use strict';

function rebindAll() {
  $('.tipsit').tipsy({fade: true, gravity: 's', html: true});
  $('.tipsit-n').tipsy({fade: true, gravity: 'n', html: true});
  $('.tipsit-w').tipsy({fade: true, gravity: 'w', html: true});
  $('.tipsit-e').tipsy({fade: true, gravity: 'e', html: true});
  $('.tipsit-treemap').tipsy({fade: true, gravity: $.fn.tipsy.autoNS, html: true});
}

function responsive() {
  if($(window).width() > 740) {
    return true;
  }
}

$(function(){
  $('.spinner').hide();
  Turbolinks.enableProgressBar();

  $(document).on('click', '.popup', function(e){
    e.preventDefault();
    window.open($(this).attr("href"), "popupWindow", "width=600,height=600,scrollbars=yes");
    if($(this).data('rel') !== undefined){
      ga('send', 'event', 'Social Shares', 'Click', $(this).data('rel'), {nonInteraction: true});
    }
  });

  if($(window).width() > 740) {
    rebindAll();
  }

  var searchOptions = {
    serviceUrl: '/search',
    onSelect: function(suggestion) {
      if(suggestion.data.type == 'Place') {
        ga('send', 'event', 'Place Search', 'Click', 'Search', {nonInteraction: true});
        window.location.href = '/places/' + suggestion.data.slug + '/2015';
      }
    },
    groupBy: 'category'
  };

  $('.search_auto').autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));
  $('.global .ham .fa-bars').click(function(e){
    e.preventDefault();
    $('.global .desktop').toggle();
  });

  var $searchBudget = $('.search_categories_budget');
  var searchCategoriesOptions = {
    serviceUrl: $searchBudget.data('search-url'),
    onSelect: function(suggestion) {
      window.location.href = suggestion.data.url;
    }
  };
  $searchBudget.autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchCategoriesOptions));

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

  $('.metric').on('click','.ranking_link', function(e){
    e.stopImmediatePropagation();
  })

  function render_comp_table(what) {
    what = what.replace('_','-');
    var other = (what == 'per-person') ? 'total-budget' : 'per-person';
    $('.variable_values').each(function() {
      $(this).find('.selected_indicator').text($(this).data(what));
    });
    $('li.' + what).show();
    $('li.' + other).hide();
  }

  if($('.comparison_table').length > 0) {
    var $widget = $('[data-line-widget-url].selected');
    render_comp_table($widget.data('line-widget-type'));
  }

  $('[data-line-widget-url]').on('click', function(e){
    $('.selected').removeClass('selected');
    $(this).addClass('selected');

    if($('.comparison_table').length > 0) {
      e.preventDefault();
      render_comp_table($(this).data('line-widget-type'));
    }

  });

  // adjust height of sidebar
  // if($(window).width() > 740) {
  if(responsive()) {
    $('header.global').css('height', $(document).height());
  };

  $('.switcher').hover(function(e) {
    e.preventDefault();
    $(this).find('ul').show();
  }, function(e) {
    $(this).find('ul').hide();
  });

  $('.switcher').click(function(e){
    ga('send', 'event', 'Year Selection', 'Click', 'ChangeYear', {nonInteraction: true});
  });

  $('.modal_widget').click(function(e) {
    var eventLabel = $(this).attr('id');
    ga('send', 'event', 'Header Tools', 'Click', eventLabel, {nonInteraction: true});
  });

  $('.modal_widget').hover(function(e) {
    e.preventDefault();
    $(this).find('.inner').velocity("fadeIn", { duration: 50 });
    var eventLabel = $(this).attr('id');
    ga('send', 'event', 'Header Tools', 'Hover', eventLabel, {nonInteraction: true});
  }, function(e) {
    $(this).find('.inner').velocity("fadeOut", { duration: 50 });
  });

  // TODO: can we remove it? It is causing trouble on the follow form
  $('.modal_widget').click(function(e) {
    if($('.modal_widget .inner').css('display') == 'none') {
      e.preventDefault();  
      console.log('preventing');
      $(this).find('.inner').velocity("fadeIn", { duration: 50 });
    }
  });

  $('#follow_link').click(function(e) {
    e.preventDefault();
    $('#user_email').focus();
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

    var url = parent_treemap_url($(this).attr('href'));
    if ($('#income-treemap').is(':visible'))
      window.incomeTreemap.render(url);
    if ($('#expense-treemap').is(':visible'))
      window.expenseTreemap.render(url);
  });

  $('.items').on('ajax:beforeSend', 'a:not(.extended)', function(event, xhr, settings) {
    var sibs = $(this).parents('tr:not(.child_group)').siblings();
    sibs.find('a.extended').removeClass('extended').find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
    sibs.siblings('.child_group').remove();
  });

  if($('#income-treemap').length > 0){
    window.incomeTreemap = new TreemapVis('#income-treemap', 'big', true);
    window.incomeTreemap.render($('#income-treemap').data('economic-url'));
  }

  if($('#expense-treemap').length > 0){
    window.expenseTreemap = new TreemapVis('#expense-treemap', 'big', true);
    window.expenseTreemap.render($('#expense-treemap').data('functional-url'));
  }

  if($('#lines_chart').length > 0){
    var $widget = $('[data-line-widget-url].selected');
    var visLineasJ = new VisLineasJ('#lines_chart', '#lines_tooltip', $widget.data('line-widget-type'), $widget.data('line-widget-series'));
    visLineasJ.render($widget.data('line-widget-url'));

    $('[data-line-widget-url]').on('click', function(e){
      visLineasJ.measure = $(this).data('line-widget-type');
      visLineasJ.render($(this).data('line-widget-url'));
    });
  }

  // When the treemap is clicked, we extract the URL of the node
  // and detect which is the link that expands the tree nodes with the
  // children. That node is clicked, and it triggers the treemap re-rendering
  $('body').on('click', '.treemap_node', function(e){
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

  $('header.place').bind('inview', function(event, isInView) {
    if (isInView) {
      $('.tools').css('z-index', 10);
      $('header.sticky_top').velocity("fadeOut", { duration: 50 });
    } else {
      $('.tools').css('z-index', 200);
      $('header.sticky_top').velocity("fadeIn", { duration: 50 });
    }
  });

  $('.tabs li a').click(function(e) {
    e.preventDefault();
    $(this).parent().parent().find('li a').removeClass('active');
    $(this).addClass('active');
    var tab = $(this).data("tab-target");
    $('.tab_content').hide();
    $('.tab_content[data-tab="'+tab+'"]').show();
  });

  $('[data-link]').click(function(e){
    e.preventDefault();
    window.location.href = $(this).data('link');
  });

  var ie_intro_height = $('.ie_intro').height();
  $('[data-rel="cont-switch"]').click(function(e){
    e.preventDefault();
    var target = $(this).data('target');
    $('.ie_intro').css('min-height', ie_intro_height);
    $(this).parents('div:eq(0)').velocity('fadeOut',
      {
        duration: 100,
        complete: function(e) {
          $('.' + target).velocity('fadeIn', {
            duration: 100,
            complete: function(e) {
              if (target.indexOf('income') > 1) {
                window.incomeTreemap.render($('#income-treemap').data('economic-url'));
              }
              else {
                window.expenseTreemap.render($('#expense-treemap').data('functional-url'));
              }
            }});
        }
      }
    );
    
  });

  // Google Analytics Events
  $('.form_filters a').click(function(e) {
    var eventLabel = $(this).attr('id');
    ga('send', 'event', 'Expense Type Selector', 'Click', eventLabel, {nonInteraction: true});
  })
});
