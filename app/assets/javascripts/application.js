//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require vendor/velocity.min
//= require vendor/jquery.sticky
//= require vendor/tipsy
//= require vendor/accounting.min
//= require vendor/jquery.autocomplete
//= require vendor/js.cookie
//= require vendor/mustache.min
//= require vendor/d3.v3.min
//= require vendor/d3-legend.min
//= require vendor/select2.min
//= require vendor/klass
//= require vendor/jquery.inview
//= require vendor/jquery.magnific-popup.min
//= require vendor/nouislider
//= require vis_treemap
//= require vis_lineas_tabla
//= require widget_renderer
//= require history
//= require compare
//= require ui
//= require ranking

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
  preventBadQueries: false
};
