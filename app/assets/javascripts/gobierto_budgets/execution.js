$(function () {
  'use strict';

  $('.execution_vs_budget_table tr:nth-of-type(n+6)').hide()

  $('.execution_vs_budget_table + .more').on('click', function(e) {
    e.preventDefault();
    $(this).prev('.execution_vs_budget_table').find('tr:nth-of-type(n+6)').toggle();
    if ($(this).text() == $(this).data('more-literal'))
      $(this).text($(this).data('less-literal'));
    else
      $(this).text($(this).data('more-literal'));
  })
});