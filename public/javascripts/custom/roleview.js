$(document).ready(function() {
    setConfirmations();
    setValidators();
    $( "#select_all" ).focus();
});

function setValidators() {
    validateTextareas();

    $("#role_form").validate({
        rules:{
            "role[name]":{required:true}
        },
        messages:{
            "role[name]":{required:"<span title='Name is required' class='errortip'>*</span>"}
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

        // uncomment the following section to enable update confirmation
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
                });*/

        return false;
    });

    $('span.delete a').click(function() {
        var loc = $(this).attr('href');
        $("#dialog-confirm").text( deleteConfirmationMessage ),
                $("#dialog-confirm").dialog({
                    resizable: false,
                    height:180,
                    modal: true,
                    title: 'Delete Role',
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
}

function createRole() {
    $('#role_form').get(0).setAttribute('action', $('#role_form').get(0).getAttribute('action').replace('update', 'create'));
    $('#role_form').submit();
}

function updateRole() {
    $('#role_form').submit();
}

function selectPermissions(all) {
    if (all) {
        $('#permissiontable input[type=checkbox]').attr('checked', 'checked');
    } else {
        $('#permissiontable input[type=checkbox]').removeAttr('checked');
    }
}

function selectDefaultPermissions() {
    $('#permissiontable input[type=checkbox]').removeAttr('checked');

    // index of checkboxes
    var arr=[0,1,2,3,4,5,6,7,23,24,25,26,27,28,29];
    var i=0;
    $($('#permissiontable input[type=checkbox]').each(function(){
        var chk = $(this)
        $(arr).each(function(index, val){
            if(val == i){
                chk.attr('checked', 'checked');
            }
        });
        i++;
    }))
}