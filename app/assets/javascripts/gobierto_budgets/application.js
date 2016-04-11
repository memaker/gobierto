//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require gobierto_budgets/vendor/velocity.min
//= require gobierto_budgets/vendor/velocity.ui.min
//= require gobierto_budgets/vendor/jquery.sticky
//= require gobierto_budgets/vendor/tipsy
//= require gobierto_budgets/vendor/accounting.min
//= require gobierto_budgets/vendor/jquery.autocomplete
//= require gobierto_budgets/vendor/js.cookie
//= require gobierto_budgets/vendor/mustache.min
//= require gobierto_budgets/vendor/d3.v3.min
//= require gobierto_budgets/vendor/d3-legend.min
//= require gobierto_budgets/vendor/select2.min
//= require gobierto_budgets/vendor/klass
//= require gobierto_budgets/vendor/jquery.inview
//= require gobierto_budgets/vendor/jquery.magnific-popup.min
//= require gobierto_budgets/vendor/nouislider
//= require gobierto_budgets/vis_treemap
//= require gobierto_budgets/vis_lineas_tabla
//= require gobierto_budgets/widget_renderer
//= require gobierto_budgets/history
//= require gobierto_budgets/compare
//= require gobierto_budgets/ui
//= require gobierto_budgets/ranking
//= require gobierto_budgets/analytics

SPARKLINES_DEFAULTS = {
  width: 60,
  numberDigitGroupSep: '.',
  numberDecimalMark: ',',
  lineColor: '#0063EE',
  spotColor: '',
  spotRadius: 0,
  fillColor: false,
  tagValuesAttribute: 'data-sparkvalues'
}

accounting.settings = {
  currency: {
    symbol: "€",    // default currency symbol is '$'
    format: "%v %s", // controls output: %s = symbol, %v = value/number (can be object: see below)
    decimal: ",",   // decimal point separator
    thousand:  ".",  // thousands separator
    precision: 2    // decimal places
  },
  number: {
    precision: 2,  // default precision on numbers is 0
    decimal: ",",   // decimal point separator
    thousand: ".",  // thousands separator
  }
}

var AUTOCOMPLETE_DEFAULTS = {
  dataType: 'json',
  minChars: 3,
  showNoSuggestionNotice: true,
  noSuggestionNotice: 'Lo sentimos, pero no hay resultados.',
  preserveInput: true,
  autoSelectFirst: true,
  triggerSelectOnValidInput: false,
  preventBadQueries: false,
  tabDisabled: true
};


$.Velocity.RegisterEffect("transition.slideLeftLongOut", { defaultDuration: 500, calls: [[ { opacity: [ 0, 1 ], translateX: -500, translateZ: 0 } ]],reset: { translateX: 0 }})

$.Velocity.RegisterEffect("transition.slideLeftLongIn", { defaultDuration: 500, calls: [[ { opacity: [ 1, 0 ], translateX: [0,-500], translateZ: 0 } ]]})

$.Velocity.RegisterEffect("transition.slideRightLongOut", { defaultDuration: 500, calls: [[ { opacity: [ 0, 1 ], translateX: 500, translateZ: 0 } ]],reset: { translateX: 0 }})

$.Velocity.RegisterEffect("transition.slideRightLongIn", { defaultDuration: 500, calls: [[ { opacity: [ 1, 0 ], translateX: [0,500], translateZ: 0 } ]]})
