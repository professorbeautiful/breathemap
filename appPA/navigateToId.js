function navigateToId(id)  {
  //location.hash = "#" + id;  // this works.
  // see also https://stackoverflow.com/questions/3163615/how-to-scroll-html-page-to-given-anchor
  var element_to_scroll_to = document.getElementById(id);
  element_to_scroll_to.scrollIntoView();
  //$(document.body).animate({  // not so good. fails for ESC
  //  'scrollTop':   $(id).offset().top },
  //  2000);
}
function navigateToY(Yposition)  {
  window.scrollTo(0,Yposition);
}
$(document).on("keypress", function (e) {
    var x = event.which || event.keyCode;
    if(x==27) // escape key
      //navigateToId(currentLocationId);
      navigateToY(savedYposition);
});
