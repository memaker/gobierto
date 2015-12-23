$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  function compareUrl(list) {
    //"http://localhost:3000/places/compare/madrid:valencia/2015/expense/economic";
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
    window.location.href = compareUrl(comparison);
    
  }

  function renderCompareList(list) {
    var $compare_list = $('#compare_list');
    var $list_elements = [];

    for(var i = 0; i < list.length; i++){
      var placeInformation = list[i].split('|');
      var placeName = placeInformation[0];
      var placeURL = placeInformation[1];
      $list_elements.push('<li><a href="' + placeURL + '">' + placeName + ' <span class="del_item"><a href="#">X</a></span></li>');
    }

    $compare_list.html($list_elements.join("\n"));
  }

  function gatherCompareList(){
    var comparison = Cookies.get('comparison');

    if (comparison === undefined || comparison.length == 0) { 
      comparison = [];
      
      var recent_places = Cookies.get('places');
      if (recent_places.length > 1) {
        // if the compare list is empty, we take the site that was previously visited
        renderCompareList([recent_places[1]]);
      }
      else {
        //es primera vez navega en el site
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
  })

  gatherCompareList();
});