$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  function storeVisit(){
    if($('[data-no-track]').length != 0) { return; }

    var places = Cookies.get('places');

    if(places === undefined) { places = []; }

    var placeInformation = $('h1').text() + '|' + window.location.pathname;

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
        $listElements.push('<li><a href="' + placeURL + '">' + placeName + '</a></li>');
        $('.history_default').hide();
      }
      $listElements.reverse();
      var $list = $('<ul/>', {
        html: $listElements.join("\n")
      });

      $history.html($list);
    }
  }

  storeVisit();
  renderHistory();

});
