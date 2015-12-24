$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  function compareUrl(list) {
    var slugs = $.map(list, function(place, i) {
      return place.split('|')[2];
    });
    var year = $('body').data('year');
    var area = $('body').data('area');
    var kind = $('body').data('kind');
    
    var url = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/places/compare/";
    url += slugs.join(':');
    url += "/" + year + "/" + kind + "/" + area;
    return url;
  }

  //assumes the places cookie is set
  function updateListAndCompare(){
    var places = Cookies.get('places');
    var comparison = Cookies.get('comparison');

    if (comparison.length == 0) {
      //Sets the list to the previous and current one
      comparison = places.slice(0,2);
    }
    else if (comparison.indexOf(places[0]) < 0) {
      comparison.unshift(places[0]);
    }

    Cookies.set('comparison', comparison);
    
    compare();
  }

  function removeFromList(place_name) {
    var comparison = Cookies.get('comparison');

    var i = comparison.findIndex(function(el) {
      return el.indexOf(place_name) == 0
    })

    comparison.splice(i,1);
    Cookies.set('comparison',comparison);
  }

  function compare() {
    var comparison = Cookies.get('comparison');
    window.location.href = compareUrl(comparison);
  }

  function currentPlaceIsOnList() {
    var current_place = Cookies.get('places')[0];
    var comparison = Cookies.get('comparison');

    return comparison.indexOf(current_place) > -1;
  }

  function renderCompareList(list) {
    var $compare_list = $('#compare_list');
    var $list_elements = [];

    for(var i = 0; i < list.length; i++){
      var placeInformation = list[i].split('|');
      var placeName = placeInformation[0];
      var placeURL = placeInformation[1];
      $list_elements.push('<li><a href="' + placeURL + '">' + placeName + '</a> <span class="del_item"><a href="#" class="del_link">X</a></span></li>');
    }

    $compare_list.html($list_elements.join("\n"));

    if (currentPlaceIsOnList()) {
      $('#add_compare,#without_current_note').css('display',"none");
      $('.widget_compare .sep').css('display',"none");
    } 

  }

  function gatherCompareList(){
    var comparison = Cookies.get('comparison');

    if (comparison === undefined || comparison.length == 0) { 
      comparison = [];
      
      var recent_places = Cookies.get('places');
      if (recent_places.length > 1) {
        // if the compare list is empty, we take the site that was previously visited so that he can compare
        // the current one and the previous one
        renderCompareList([recent_places[1]]);
      }
      else {
        // first time on site
      }
    }
    else {
      renderCompareList(comparison);
    }

    Cookies.set('comparison', comparison);
  }

  $('#add_compare').on('click', function(e) {
    e.preventDefault();
    updateListAndCompare();
  });

  $('#view_compare').on('click', function(e) {
    e.preventDefault();
    compare();
  });

  $('#compare_list').on('click', 'a.del_link', function(e) {
    e.preventDefault();
    var $list_item = $(this).parents('li');
    var place = $list_item.children('a').text();
    removeFromList(place);
    $list_item.remove();
  });

  gatherCompareList();
});