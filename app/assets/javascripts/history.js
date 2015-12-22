$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  function storeVisit(){
    var $trackUrl = $('[data-track-url]');
    if($trackUrl.length == 0) { return; }

    var places = Cookies.get('places');

    if(places === undefined) { places = []; }

    var placeInformation = $('h1').text() + '|' + $trackUrl.data('track-url');

    if (places.indexOf(placeInformation) == -1){
      places.push(placeInformation);
    }

    if(places.length > 10) { places.shift(); }

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
      $listElements.reverse();

      $history.html($listElements.join("\n"));
    }
  }

  storeVisit();
  renderHistory();
});
