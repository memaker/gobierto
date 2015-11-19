'use strict';

// Behaviour:
//
// - everything disabled by default, until the location is selected
// - if a location is selected, disable the size filter
// - if the kind selected changes, reload the economic select
// - when selected a functional line, disable expending/incoming select
// - when selected a functional line, reload the options of the economic select
// - when selected an economic line, disable functional select
// - selecting a location loads by ajax the form, any change reloads the ajax

var Filters = Class.extend({
  init: function($form) {
    this.$form = $form;
    this.$functional = null;
    this.$economic = null;
  }
});
