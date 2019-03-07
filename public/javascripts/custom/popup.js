
popupWidthSet = false;

function showPopup( divName )
{


    if( !popupWidthSet )
    {
       setPopupWidth( divName );
       popupWidthSet = true;
    }

    $('#' + divName + "_outer" ).fadeTo("normal",0.8);
    $('#' + divName ).fadeIn('normal');

    $("#timecard_client_number2").focus(); //this is only for timecard page

}
function closePopup( divName )
{
    $('#' + divName + "_outer" ).fadeOut('fast');
    $('#' + divName ).fadeOut('fast');
}


//This method should be called once when document is ready
function setPopupWidth( divName )
{

    fullWidth = $(document).width();
    fullHeight = $(document).height();

    $('#' + divName + "_outer" ).width( fullWidth );
    $('#' + divName + "_outer" ).height( fullHeight );

    windowsWidth = $('#' + divName ).width();
    windowsHeight = $('#' + divName ).height();

    leftOffset = ( fullWidth - windowsWidth ) / 2;
    topOffset = ( fullHeight - windowsHeight ) / 2;

    $('#' + divName).offset({left:leftOffset,top:topOffset});

}