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

//= require ui

SPARKLINES_DEFAULTS = {
  width: 60,
  numberDigitGroupSep: '.',
  numberDecimalMark: ',',
  lineColor: '#82CAD8',
  spotColor: '',
  spotRadius: 0,
  fillColor: false,
  tagValuesAttribute: 'data-sparkvalues'
}

accounting.settings = {
  currency: {
    symbol: "€",    // default currency symbol is '$'
    format: "%v %s", // controls output: %s = symbol, %v = value/number (can be object: see below)
    decimal: ".",   // decimal point separator
    thousand:  ",",  // thousands separator
    precision: 2    // decimal places
  },
  number: {
    precision: 2,  // default precision on numbers is 0
    thousand: ",",  // thousands separator
    decimal: ".",   // decimal point separator
  }
}
