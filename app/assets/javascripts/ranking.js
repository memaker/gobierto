$(function () {
  if ($('.filters').length > 0) {
    function updateRanking() {
      var ranking_url = $('[data-ranking-url]').data('ranking-url');
      var params = ""
      $('#filter_population').each(function() {
        var values = this.noUiSlider.get();
        var filter_name = this.id.replace('filter_','');
        params+= "&filters[" + filter_name + "][from]=" + parseInt(values[0]);
        params+= "&filters[" + filter_name + "][to]=" + parseInt(values[1]);
      })
      $.ajax(ranking_url + params);
  // filter_per_inhabitant
    }

    var pop_slider = document.getElementById('filter_population');

    noUiSlider.create(pop_slider, {
      start: [0, 5000000],
      snap: true,
      connect: true,
      range: {
        'min': 0,
        '10%':1000,
        '20%':5000,
        '30%':10000,
        '40%':25000,
        '50%':50000,
        '60%':100000,
        '70%':200000,
        '80%':500000,
        'max': 5000000
      }
    });
    
    pop_slider.noUiSlider.on('update', function( values, handle ) {
      $('#size_value_' + handle).text(parseInt(values[handle]));
    });    

    pop_slider.noUiSlider.on('change', function( values, handle ) {
      updateRanking();
    });

    var tot_slider = document.getElementById('filter_total');

    noUiSlider.create(tot_slider, {
      start: [0, 5000000000],
      snap: true,
      connect: true,
      range: {
        'min':0,
        '2.5%':50000,
        '5%':100000,
        '7.5%':200000,
        '10%':300000,
        '12.5%':400000,
        '15%':500000,
        '17.5%':600000,
        '20%':700000,
        '22.5%':800000,
        '25%':900000,
        '27.5%':1000000,
        '30%':2500000,
        '40%':5000000,
        '50%':10000000,
        '65%':25000000,
        '80%':200000000,
        'max':5000000000
      }
    });

    tot_slider.noUiSlider.on('update', function( values, handle ) {
      $('#total_value_' + handle).text(parseInt(values[handle]));
    });

    tot_slider.noUiSlider.on('change', function( values, handle ) {
      // updateRanking();
    });
  }
});