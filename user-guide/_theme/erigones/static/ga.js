// Load GA js code
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-87330218-2', 'auto');
ga('send', 'pageview');

var ua = navigator.userAgent || navigator.vendor || window.opera;

if ((ua.indexOf('FBAN') > -1) || (ua.indexOf('FBAV') > -1)) {
    document.getElementById('menu').style.display = 'none';
}

// Function that send event to GA
var trackOutboundLink = function(mouseclick) {
    ga('send', 'event', 'Outbound Link', mouseclick.target.href);
}

// Function that send event to GA
var trackScreenShotView = function(mouseclick) {
    ga('send', 'event', 'Screenshots', mouseclick.target.src);
}

document.addEventListener('DOMContentLoaded', function () {
    // AddEventListener for links with external class and notify GA with url on click
    var buttons = document.getElementsByClassName('external');
    for (var i = 0; i < buttons.length; i++) {
        buttons[i].addEventListener('click', trackOutboundLink);
    }
    // AddEventListener for pictures with screenshot class and notify GA with url on click
    var images = document.getElementsByClassName('screenshot');
    for (var i = 0; i < images.length; i++) {
        images[i].addEventListener('click', trackScreenShotView);
    }
});
