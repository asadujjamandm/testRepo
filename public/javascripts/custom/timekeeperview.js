/**
 * Created by akash on 12/1/14.
 */
$(document).ready(function() {
    /*setConfirmations();*/
    setValidators();
    /*$( "#user_name" ).focus();  */
});

function setValidators() {
    $("#timekeepers_form").validate({
        rules:{
            "timekeeper[timekeeper_number]":{required:true},
            "timekeeper[display_name]":{required:true},
            "timekeeper[bill_name]":{required:true}
        },
        messages:{
            "timekeeper[timekeeper_number]":{required:"<span title='Timekeeper No is required' class='errortip'>*</span>"},
            "timekeeper[display_name]":{required:"<span title='Display Name is required' class='errortip'>*</span>"},
            "timekeeper[bill_name]":{required:"<span title='Timekeeper Billname is required' class='errortip'>*</span>"}
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

function setConfirmations() {
    $('#update').click(function() {
        var loc = $(this).attr('href');
        window.location.href = loc;

        // uncomment the following line to enable update confirmation
        /*$("#dialog-confirm").text( updateConfirmationMessage ),
         $("#dialog-confirm").dialog({
         resizable: false,
         height:160,
         modal: true,
         title: 'Update Changes',
         buttons: {
         "Yes": function() {            z
         window.location.href = loc;
         },
         Ni: function() {
         $(this).dialog("close");
         }
         }
         });*/

        return false;
    });

    /*$('span.delete a').click(function() {
        var loc = $(this).attr('href');
        $("#dialog-confirm").text( deleteConfirmationMessage ),
            $("#dialog-confirm").dialog({
                resizable: false,
                height:160,
                modal: true,
                title: 'Delete User',
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

    $('#cancel').click(function() {
        var loc = $(this).attr('href');
        $("#dialog-confirm").text( cancelConfirmationMessage ),
            $("#dialog-confirm").dialog({
                resizable: false,
                height:160,
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
    }); */
}

function createTimekeeper() {
    $('#timekeepers_form').get(0).setAttribute('action','create');
    $('#timekeepers_form').submit();
}
function updateTimekeeper()
{
    $('#timekeepers_form').get(0).setAttribute('action',$('#timekeepers_form').get(0).getAttribute('action').replace('create', 'update'));
    $('#timekeepers_form').submit();
}
function submitSearch() {
    $('#timekeeper_search_form').submit();
}
