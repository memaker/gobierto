'use strict';

var WidgetRenderer = Class.extend({
  init: function(options){
    this.widgetId = options.id;
    this.widgetDataURL = options.url;
    this.widgetTemplate = $(options.template).html();
  },

  render: function(){
    $.getJSON(this.widgetDataURL, function(data){
      $('[data-widget-type=' + this.widgetId + ']').html(Mustache.render(this.widgetTemplate, data));
    }.bind(this));
  }
});
