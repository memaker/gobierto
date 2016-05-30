//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require flight-for-rails
//= require_directory ../components/
//= require_directory ./vendor/
//= require mustache.min

function rebindAll() {
  $('.tipsit').tipsy({fade: true, gravity: 's', html: true});
  $('.tipsit-n').tipsy({fade: true, gravity: 'n', html: true});
  $('.tipsit-w').tipsy({fade: true, gravity: 'w', html: true});
  $('.tipsit-e').tipsy({fade: true, gravity: 'e', html: true});
  $('.tipsit-treemap').tipsy({fade: true, gravity: $.fn.tipsy.autoNS, html: true});
}

$(function(){
	
	if($(window).width() > 740) {
    rebindAll();
  }

	Turbolinks.enableProgressBar();

	$('.tabs li a').click(function(e) {
    e.preventDefault();
    $(this).parent().parent().find('li a').removeClass('active');
    $(this).addClass('active');
    var tab = $(this).data("tab-target");
    $('.tab_content').hide();
    $('.tab_content[data-tab="'+tab+'"]').show();
  });

	$(".stick_ip").stick_in_parent();

	$('.bread_hover').hover(function(e) {
    $('.line_browser').velocity("fadeIn", { duration: 50 });
  }, function(e) {
    $('.line_browser').velocity("fadeOut", { duration: 50 });
  });

  $('[data-level]').hover(function(e) {
  	var level = $(this).data('level') + 1;
    $('[data-level=' + level + ']').velocity("fadeIn", { duration: 250 });
  });




});