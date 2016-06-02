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
      this.currentState = this.states[1];
      this.categoriesUrl = this.$node.data('budget-line-categories');
      var $lineBreadcrumb = this.$node.find('[data-line-breadcrumb]');

      $.getJSON(this.categoriesUrl, function(categories){
        this.renderLineBreadcrumb($lineBreadcrumb, this.state, categories[this.areaName]);
        this.renderLevel1(categories[this.areaName]);
        this.assignHandlers(0);
      }.bind(this));
    });

    this.renderLineBreadcrumb = function($el, state, categories){
      var html = "";
      html += '<a href="#">' + this.states[0] + '</a> »';
      html += '<a href="#">' + this.attr.areaNamesDict[this.states[1]] + '</a> »';

      this.states.slice(2, this.states.length - 1).forEach(function(segment){
        html += '<a href="#">' + categories[this.states[1]][segment] + '</a> »';
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
      this.assignHandlers(1);
    };

    this.assignHandlers = function(level){
      var that = this;
      $('[data-level="' + level + '"] [data-code]').hover(function(e){
        e.preventDefault();
        var currentCode = $(this).data('code');
        var nextLevel = parseInt($(this).parents('[data-level]').data('level')) + 1;
        if(nextLevel == 2){ that.currentState = currentCode; }

        if(nextLevel > 1){
          that.renderLevel(nextLevel, currentCode);
        } else {
          $('[data-level=' + nextLevel + ']').velocity("fadeIn", { duration: 250 });
        }
      });
    };

    this.renderLevel = function(level, currentCode){
      var url = '/site/budget_line_descendants/' + this.states[0] + '/' + this.areaName + '/' + this.currentState + '.json';
      if(level > 2){
        url += '?parent_code=' + currentCode;
      }
      console.log(url);

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

          // On Ajax success
          $('[data-level=' + level + ']').velocity("fadeIn", { duration: 250 });

          this.assignHandlers(level);
        }.bind(this));
      }
    };
  });

  $(function() {
    window.budgetLineBreadcrumb.attachTo('[data-budget-line-breadcrumb]');
  });

})(window);
