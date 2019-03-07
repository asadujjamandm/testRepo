$(document).ready(function(){
  if($.browser.msie){
      $("tr:even").css("background-color", "#DCEEF9");
  }

  if($.browser.webkit){
      $('#formtable caption, #datatable caption').css('margin-right','-2px');
  }
});