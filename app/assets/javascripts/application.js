// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery_ujs
//= require jquery.tipsy
//= require jquery.textillate
//= require jquery.lettering
//= require_tree .

$(window).scroll(function() {
    $(".loading").css({ "margin-top": $(window).scrollTop() });
});

$(".loading h1").textillate({
    loop: true,
    minDisplayTime: 1000,
    autoStart: true,
    in: {
        effect: 'bounce',
        delayScale: 1.5,
        delay: 50,
        sync: false,
        shuffle: true
    },
    out: {
        effect: 'bounce',
        delayScale: 1.5,
        delay: 50,
        sync: false,
        shuffle: true
    }
});
