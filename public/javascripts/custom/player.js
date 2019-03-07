swfobject.registerObject("csSWF", "9.0.115", "/videos/expressInstall.swf");

// override default height calculation
 $(document).ready(function(){
       setTimeout(function(){
        $('.bodycontent').height($(document).height());
        $('.wrapper').height($(document).height());
   }, 100);
});