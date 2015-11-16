//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require vendor/velocity.min
//= require vendor/jquery.dynatable
//= require vendor/jquery.sticky
//= require vendor/tipsy
//= require vendor/jquery.sparkline
//= require vendor/jquery.bonsai
//= require vendor/accounting.min
//= require vendor/jquery.autocomplete
//= require vendor/d3.v3.min
//= require vendor/d3-legend
//= require vendor/klass
//= require vis_bars
// require vis

//= require ui

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
  minChars: 2,
  showNoSuggestionNotice: true,
  noSuggestionNotice: 'Lo sentimos, pero no hay resultados.',
  preserveInput: true,
  autoSelectFirst: true,
  triggerSelectOnValidInput: false
};

var searchOptions = {
  serviceUrl: '/search',
  onSelect: function (suggestion) {
    $('#place').val(suggestion.data.id);
    $('#search').val(suggestion.value);
  },
  groupBy: 'category',
};

