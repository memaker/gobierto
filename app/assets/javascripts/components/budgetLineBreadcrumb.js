(function(window, undefined){
  'use strict';

  window.budgetLineBreadcrumb = flight.component(function(){
    this.attributes({
      areaNamesDict: {
        'G': 'Gastos',
        'I': 'Ingresos'
      }
    });

    this.after('initialize', function() {
      this.areaName = this.$node.data('budget-line-area');
      this.state = this.$node.data('budget-line-breadcrumb');
      this.states = this.state.split('/');
      this.currentKind = this.states[1];
      this.categoriesUrl = this.$node.data('budget-line-categories');
      var $lineBreadcrumb = this.$node.find('[data-line-breadcrumb]');

      $.getJSON(this.categoriesUrl, function(categories){
        this.renderLevel1(categories[this.areaName]);
        this.renderLineBreadcrumb($lineBreadcrumb, this.state, categories[this.areaName]);
        this.assignHandlers(0);

        this.states.slice(2, this.states.length - 1).forEach(function(code, level){
          var currentCode = code.slice(0, code.length-1);
          if(level == 0) {
            currentCode = this.currentKind;
          }
          this.renderLevel(level + 2, currentCode);
        }.bind(this));

      }.bind(this));
    });

    this.renderLineBreadcrumb = function($el, state, categories){
      var html = "";
      html += '<a href="/presupuestos/partidas/'+this.states[0]+'/'+this.areaName+'/' + this.states[1] + '">' + this.states[0] + '</a> »';
      html += '<a href="/presupuestos/partidas/'+this.states[0]+'/'+this.areaName+'/' + this.states[1] + '">' + this.attr.areaNamesDict[this.states[1]] + '</a> »';

      this.states.slice(2, this.states.length - 1).forEach(function(segment){
        html += '<a href="/presupuestos/partidas/'+segment+'/'+this.states[0]+'/'+this.areaName+'/' + this.states[1] + '">' + categories[this.states[1]][segment] + '</a> »';
      }.bind(this));
      $el.html(html);
    };

    this.renderLevel1 = function(categories){
      var html = "";
      var $el = $('[data-level="1"] table');
      for(var c in categories){
        html += '<tr><td data-code="'+c+'"><a href="#">' + this.attr.areaNamesDict[c] + '</a></td></tr>';
      }
      $el.html(html);
      $el.data('current-code', this.currentKind);
      $el.parent().velocity('fadeIn', {duration: 250});
      this.assignHandlers(1);
    };

    this.assignHandlers = function(level){
      var that = this;
      $('[data-level="' + level + '"] [data-code]').mouseenter(function(e){
        e.preventDefault();

        for(var i=(level+2); i < 5; i++){
          $('[data-level="' + i + '"]').velocity('fadeOut', {duration: 100});
        }

        var currentCode = $(this).data('code');
        var nextLevel = parseInt($(this).parents('[data-level]').data('level')) + 1;
        if(nextLevel == 2){ that.currentKind = currentCode; }

        if(nextLevel > 1){
          that.renderLevel(nextLevel, currentCode);
        } else {
          $('[data-level=' + nextLevel + ']').velocity("fadeIn", { duration: 250 });
        }
      });
    };

    this.renderLevel = function(level, currentCode){
      var url = '/budget_line_descendants/' + this.states[0] + '/' + this.areaName + '/' + this.currentKind + '.json';
      if(level > 2){
        url += '?parent_code=' + currentCode;
      }

      var that = this;
      var $el = $('[data-level="'+level+'"] table');
      if($el.data('current-code') != currentCode){
        $.getJSON(url, function(data){
          var html = "";
          data.forEach(function(budgetLine){
            html += '<tr><td data-code="'+budgetLine.code+'"><a href="/site/budget_lines/'+budgetLine.code+'/'+that.states[0]+'/'+that.areaName+'/' + that.states[1] + '">' + budgetLine.name + '</a></td></tr>';
          });
          $el.html(html);
          $el.data('current-code', currentCode);

          $('[data-level=' + level + ']').velocity("fadeIn", { duration: 250 });
          this.assignHandlers(level);
        }.bind(this));
      } else {
        if(!$el.parent().is(':visible'))
          $el.parent().velocity('fadeIn', {duration: 250});
      }
    };
  });

  $(function() {
    window.budgetLineBreadcrumb.attachTo('[data-budget-line-breadcrumb]');
  });

})(window);
