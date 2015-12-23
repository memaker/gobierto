$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  function storeVisit(){
    var $trackUrl = $('[data-track-url]');
    if($trackUrl.length == 0) { return; }

    var places = Cookies.get('places');
    if(places === undefined) { places = []; }

    var placeInformation = $trackUrl.data('place-name') + '|' + $trackUrl.data('track-url') + '|' + $trackUrl.data('place-slug');

    if (places.indexOf(placeInformation) == -1){
      places.unshift(placeInformation);
    } 
    else {
      // we put it at the front
      var repeat = places.splice(places.indexOf(placeInformation),1)[0];
      places.unshift(repeat);
    }

    if(places.length > 10) { places.pop(); }

    Cookies.set('places', places);
  }

  function renderHistory(){
    var $history = $('#history');
    var places = Cookies.get('places');

    if(places === undefined) { 
      places = []; 
    }

    if($history !== undefined){

      var $listElements = [];
      for(var i = 0; i < places.length; i++){
        var placeInformation = places[i].split('|');
        var placeName = placeInformation[0];
        var placeURL = placeInformation[1];
        $listElements.push('<li><a href=' + placeURL + '>' + placeName + '</a></li>');
      }

      $history.html($listElements.join("\n"));
    }
  }

  storeVisit();
  renderHistory();
});
