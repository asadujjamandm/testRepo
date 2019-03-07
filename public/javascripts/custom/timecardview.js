var duration = 0;

$(document).ready(function() {
    $(".td-with-tooltip").each(function(){
        //console.log($(this).html());
        $(this).attr('title',$(this).html());
    })
    var page_stat = $('#page_stat').val();
    if(page_stat == "1")  {
        clearForm();
    }
    else if(page_stat == "2") {
        //do nothing
    }
    else if(page_stat == "3") {
        return
    }
    else{
        clearForm();
    }
    setConfirmations();
//        setAutoFills();
    setValidators();
    setDurationByUnit();
    $('#timecard_client_id').change(function() {
        populateMatterList();
    });
    $('#timecard_client_id2').attr('disabled', true);
//        $( "#timecard_matter_id" ).change(function(e){
//            checkMatterStatus();
//            return true;
//        });
//        checkMatterStatus();
//        $("#timecard_client_id").focus();
});

function setDurationByUnit() {
    $('#timecard_hours').focusout(function() {
        updateDuration();
    });
}

function updateDuration() {
    var unit = parseInt($('#timecard_units').val());
    duration = $.trim($('#timecard_hours').val());

    if (unit != 0 && duration != "") {
        var durationSeconds = getSecondsFromTime(duration);
        var unitSeconds = 0;

        if ($('#timecard_unit_type').val() == 'Minute')
            unitSeconds = getSecondsFromMinute(unit);
        else if ($('#timecard_unit_type').val() == 'Hour')
            unitSeconds = getSecondsFromHour(unit);
        else
            unitSeconds = unit;

        if( durationSeconds == 0 )
        {
            $('#bill_hours_calculated').text('(' + getTimeFromSecondsWithinOneDay(0) + ')');
        }
        else if (unitSeconds > durationSeconds) {
            $('#bill_hours_calculated').text('(' + getTimeFromSecondsWithinOneDay(unitSeconds) + ')');
        } else {
            var roundedSeconds = 0;
            while (roundedSeconds < durationSeconds) {
                roundedSeconds += unitSeconds;
            }
            $('#bill_hours_calculated').text('(' + getTimeFromSecondsWithinOneDay(roundedSeconds) + ')');
        }
    } else {
        $('#bill_hours_calculated').text('(' + duration + ')');
    }
}

function isTimecardFormInvalid()
{
    $("#timecard_form").valid();
    count = $("#timecard_form").validate().numberOfInvalids();
    if( count >= 1 )
    {
        return true;
    }
    else
    {
        return false;
    }
}

function setConfirmations() {

    $('#update').click(function() {

        if( busy )
        {
            return;
        }

        if( isTimecardFormInvalid() )
        {
            return;
        }

        var loc = $(this).attr('href');
        window.location.href = loc;

        // uncomment following section to enable confirmation before update
        /*$("#dialog-confirm").text( updateConfirmationMessage ),
         $("#dialog-confirm").dialog({
         resizable: false,
         height:160,
         modal: true,
         title: 'Update Changes',
         buttons: {
         "Yes": function() {
         window.location.href = loc;
         },
         No: function() {
         $(this).dialog("close");
         }
         }
         });
         */

        return false;

    });

//    $('span.delete a').click(function() {
//        var loc = $(this).attr('href');
//        $("#dialog-confirm").text(deleteConfirmationMessage),
//            $("#dialog-confirm").dialog({
//                resizable: false,
//                height:180,
//                modal: true,
//                title: 'Delete Timecard',
//                buttons: {
//                    "Yes": function() {
//                        window.location.href = loc;
//                    },
//                    No: function() {
//                        $(this).dialog("close");
//                    }
//                }
//            });
//
//        return false;
//    });

    $('#example2').on('click','span.delete a',function(e){
        e.preventDefault();
        deleteTimeCard(this);

        return false;
    });
    function deleteTimeCard(deletObj)
    {
        console.log("Delete Clicked");
        var loc = $(deletObj).attr('href');
        $("#dialog-confirm").text(deleteConfirmationMessage),
            $("#dialog-confirm").dialog({
                resizable: false,
                height:180,
                modal: true,
                title: 'Delete Timecard',
                buttons: {
                    "Yes": function() {
                        window.location.href = loc;
                    },
                    No: function() {
                        $(this).dialog("close");
                    }
                }
            });

        return false;
    }


    $('#cancel').click(function() {
        var loc = $(this).attr('href');
        $("#dialog-confirm").text(cancelConfirmationMessage),
            $("#dialog-confirm").dialog({
                resizable: false,
                height:180,
                modal: true,
                title: 'Cancel',
                buttons: {
                    "Yes": function() {
                        window.location.href = loc;
                    },
                    No: function() {
                        $(this).dialog("close");
                    }
                }
            });

        return false;
    });

    $('#post').click(function() {
        if( busy )
        {
            return;
        }

        if( isTimecardFormInvalid() )
        {
            return;
        }


        var loc = $(this).attr('href');
        $("#dialog-confirm").text( postConfirmationMessage ),
            $("#dialog-confirm").dialog({
                resizable: false,
                height:200,
                modal: true,
                title: 'Post Confirmation',
                buttons: {
                    "Yes": function() {
                        window.location.href = loc;
                    },
                    No: function() {
                        $(this).dialog("close");
                    }
                }
            });

        return false;

    });

}

function setValidators() {
    validateTextareas();


    $.validator.addMethod('hoursValidation', function (data) {
        return isTimeValid($('#timecard_hours').val());
    }, ' *');
    $.validator.addMethod('timeValidation', function (data) {
        return isTimeValid($('#timecard_hhmm').val());
    }, ' *');

//    timecard[activity_code]

    $("#timecard_form").validate({
        rules:{
            "timecard[date]":{required:true},
            "timecard[matter_id]":{required:true},
            "timecard[matter_number]":{required:true},
            "timecard[client_id]":{required:true},
            "timecard[client_number]":{required:true},
            "timecard[timekeeper_id]":{required:true},
            "timecard[hours]":{required:true,hoursValidation: true},
            "timecard[activity_id]":{required:true},
            "timecard[activity_code]":{required:true}
        },
        messages:{
            "timecard[date]":{required:"<span title='Date is required' class='errortip'>*</span>"},
            "timecard[matter_id]":{required:"<span title='Matter is required' class='errortip'>*</span>"},
            "timecard[matter_number]":{required:"<span title='Matter is required' class='errortip'>*</span>"},
            "timecard[client_id]":{required:"<span title='Client is required' class='errortip'>*</span>"},
            "timecard[client_number]":{required:"<span title='Client is required' class='errortip'>*</span>"},
            "timecard[timekeeper_id]":{required:"<span title='Timekeeper is required' class='errortip'>*</span>"},
            "timecard[hours]":{required:"<span title='Hours is required' class='errortip'>*</span>",
                hoursValidation:"<span title='Incorrect hour format' class='errortip'>**</span>"},
            "timecard[activity_id]":{required:"<span title='Activity is required' class='errortip'>*</span>"},
            "timecard[activity_code]":{required:"<span title='Activity is required' class='errortip'>*</span>"}
        },
        errorClass: "validation-error",
        invalidHandler: function(form, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                var message = errors == 1
                    ? singleErrorMessage
                    : multipleErrorMessage.replace("#n", errors );
                showErrorMessage( message );
            } else {
                //do nothing
            }
        }
    });
}


function submitTimecard(newId) {

    $('#timecard_dirty_timecard_id').val(newId);
    $("#timecard_bill_status").removeAttr('disabled'); //enable the field while posting to post field value

    if( isNew ) //for new timecards, enable submit without validation
    {
        //disable validation on submit
        $("#timecard_form").validate().cancelSubmit = true;
        $("#timecard_form").submit();
        return false;
    }

    $('#timecard_form').submit();

}

function submitEditTimecard(newId) {

    $('#timecard_dirty_timecard_id').val(newId);
    $("#timecard_bill_status").removeAttr('disabled'); //enable the field while posting to post field value

    //--------------
    $('#timecard_form').get(0).setAttribute('action', $('#timecard_form').get(0).getAttribute('action').replace('create', 'edit'));
    $("#timecard_bill_status").removeAttr('disabled'); //enable the field while posting to post field value
//    if( isPost )
//    {
//        $("#timecard_finalized").val( "true" );
//    }
//    else
//    {
//        $("#timecard_finalized").val( "false" );
//    }
    //-------------

    if( isNew ) //for new timecards, enable submit without validation
    {
        //disable validation on submit
        $("#timecard_form").validate().cancelSubmit = true;
        $("#timecard_form").submit();
        return false;
    }

    $('#timecard_form').submit();

}

function updateTimecards( isPost ) {
    if( busy )
    {
        alert( 'Page is busy, please try again.' );
        return;
    }

    $('#timecard_form').get(0).setAttribute('action', $('#timecard_form').get(0).getAttribute('action').replace('edit', 'update'));
    $("#timecard_bill_status").removeAttr('disabled'); //enable the field while posting to post field value
    if( isPost )
    {
        $("#timecard_finalized").val( "true" );
    }
    else
    {
        $("#timecard_finalized").val( "false" );
    }
    $('#timecard_form').submit();

}

function createTimecard( isPost ) {

    if( busy )
    {
        alert( 'Page is busy, please try again.' );
        return;
    }


    $('#timecard_form').get(0).setAttribute('action', $('#timecard_form').get(0).getAttribute('action').replace('edit', 'create'));
    $("#timecard_bill_status").removeAttr('disabled'); //enable the field while posting to post field value
    if( isPost )
    {
        $("#timecard_finalized").val( "true" );
    }
    else
    {
        $("#timecard_finalized").val( "false" );
    }
    $('#timecard_form').submit();
    //clearForm();
}

function clearForm(){

    //form text fields
    $("#timecard_client_number").val('');
    $("#timecard_matter_number").val('');
    $("#timecard_activity_code").val('');
    $("#timecard_hours").val('00:00');
    $("#timecard_description").val('');
    //hidden fields
    $("#timecard_client_id").val('');
    $("#timecard_matter_id").val('');
    $("#activity_id").val('');
    //$("#timecard_hhmm").val('');
    //$("#timecard_description").val('');     not required
}

function submitSearch() {
    $('#timecard_search_form').get(0).setAttribute('action', '/timecards/search' );
    $("#state").val( "search" );
    $('#timecard_search_form').submit();
}

function submitSearch2() {
    $('#timecard_search_form').get(0).setAttribute('action', '/timecards/search' );
    $("#state").val( "normal" );
    $('#timecard_search_form').submit();
}

function submitSearch3( criteria ) {
    $( "#search_timecard_additional" ).val( criteria );
    state = $("#state").val();
    if( !( state == "search" || state == "calendar" ) )
    // That is, if state is 'new' or 'update' then if search3 clicked then bring to normal state
    {
        $("#state").val( 'normal' )
    }
    $('#timecard_search_form').submit();
}

function submitCalendarView() {
    $('#timecard_search_form').get(0).setAttribute('action', '/timecards/calendar_view' );
    $('#timecard_search_form').submit();
}
function cancel()
{
    $('#timecard_search_form').get(0).setAttribute('action', '/timecards/search' );
    $("#state").val( "normal" );
    $('#timecard_search_form').submit();
}