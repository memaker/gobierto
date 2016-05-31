(function(window, undefined){
  'use strict';

  window.dataWidget = flight.component(function(){
    this.after('initialize', function() {
      $.getJSON(this.$node.data('widget-data-url'), function(data){
        var template = $(this.$node.data('widget-template')).html();
        if(this.$node.attr('title').length){
          data.title = this.$node.attr('title');
        }
        var html = Mustache.render(template, data);
        this.$node.html(html);
      }.bind(this));
    });
  });

  $(function() {
    window.dataWidget.attachTo('[data-widget-type]');
  });

})(window);
