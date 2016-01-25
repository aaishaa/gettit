$(document).ready(function(){
  $(".prod-cell").click(function(){
    window.document.location = $(this).data("href");
  });
});