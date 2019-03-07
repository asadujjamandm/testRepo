// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/* footer sticking to the bottom is disabled
$(document).ready(function(){
   setTimeout(function(){
    $('.bodycontent').height($(document).height()-($('header').height()+$('.pagefooter').height() + 74 ));
    $('.wrapper').height($(document).height()-($('header').height()+$('.pagefooter').height() + 64 ));
   }, 100);
});
*/

/* set minimum height of the content */
$(document).ready(function(){
       setTimeout(function(){
           if($('.bodycontent').height() < 400){
                $('.bodycontent').height($(document).height()-($('header').height()+$('.pagefooter').height() + 54));
                $('.wrapper').height($(document).height()-($('header').height()+$('.pagefooter').height() + 44));
           }
   }, 100);

   /*$('.messageContainer').delay(500).fadeOut('normal', function() {
      $(this).delay(500).fadeIn();
   });*/

    $('.messageContainer').fadeTo(500, 0, function() {
      $(this).fadeTo(500, 1, function(){
        $(this).fadeTo(500, 0, function(){
            $(this).fadeTo(500, 1);
        });
      });
   });
});

function validateTextareas(){
  $("textarea[maxlength]").keyup(function(){
     var limit = parseInt($(this).attr('maxlength'));
     var text = $(this).val();
     var chars = text.length;
     if(chars >= limit){
         var new_text = text.substr(0, limit);
         $(this).val(new_text);
     }
  });
}

function getCurrentTime(){
    var currentDate = new Date();
    return currentDate.getHours() + ":" + currentDate.getMinutes() + ":"+currentDate.getSeconds();
}

function isTimeValid(timevalue){
    var reg = new RegExp('^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    var reg2 = new RegExp('^([0]?[1-9]|1[0-2]):[0-5][0-9] (AM|PM)$');
    var m = reg.exec(timevalue);
    var m2 = reg2.exec(timevalue);
    if( m != null )
    {
        return true;
    }
    else if( m2 != null )
    {
        return true;
    }
    else
    {
        return false;
    }
}

function lpad(number, length) {
    var str = '' + number;
    while (str.length < length) {
        str = '0' + str;
    }

    return str;
}

function getSecondsFromTime(time){
    if(time == null || time == '')
        return 0;

    var hhmmss = time.split(':');
    if(hhmmss.length == 2){
         var hh = parseInt(hhmmss[0], 10);
         var mm = parseInt(hhmmss[1], 10);
         //var ss = parseInt(hhmmss[2], 10);

        //return (hh * 3600)+(mm * 60)+ss;
        return (hh * 3600)+(mm * 60);
    } else {
        return 0;
    }
}

function getSecondsFromMinute(minute){
    if(minute <= 0)
        return 0;

    return minute * 60;
}

function getSecondsFromHour(hour){
    if(hour <= 0)
        return 0;

    return hour * 60 * 60;
}

function getTimeFromSeconds(seconds){
    if(seconds <= 0)
        return 0;

    var hh = Math.floor(seconds / 3600);
    var mod = seconds % 3600;
    var mm = Math.floor(mod/60);
    var ss = mod % 60;

    return lpad(hh, 2) + ":" + lpad(mm, 2) + ":" + lpad(ss, 2);
}

function getTimeFromSecondsWithinOneDay(seconds){
    var hh = 0;
    var mm = 0;
    var ss = 0;

    if(seconds > 0){
        if(seconds < 86400){
            hh = Math.floor(seconds / 3600);
            var mod = seconds % 3600;
            mm = Math.floor(mod/60);
            ss = mod % 60;
        } else {
            hh = 23;
        }
    }

    //return lpad(hh, 2) + ":" + lpad(mm, 2) + ":" + lpad(ss, 2);
    return lpad(hh, 2) + ":" + lpad(mm, 2);
}


function showErrorMessage( message )
{
    div = $( "#messageDiv" );
    if( div != null )
    {
        div.html( message );
        div.attr("class","flash error");
        div.css( "display", "block" );
    }
}

function showBlockedMessage(msg)
{
    $.blockUI({ 
        css: { 
            border: 'none', 
            padding: '15px', 
            backgroundColor: '#000', 
            '-webkit-border-radius': '10px', 
            '-moz-border-radius': '10px', 
            opacity: .5, 
            color: '#fff'
        },
        message: msg
    });
}