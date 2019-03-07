$(document).ready(function() {
    setConfirmations();
    setValidators();
    $( "#user_name" ).focus();
});

function setValidators() {
    $("#user_form").validate({
        rules:{
            "user[name]":{required:true},
            "user[login]":{required:true},
            "user[password]":{required:true, minlength:6},
            "user[confirmed_password]":{required:true, minlength:6, equalTo:'#user_password'},
            "user[email]":{required:true}
        },
        messages:{
            "user[name]":{required:"<span title='Name is required' class='errortip'>*</span>"},
            "user[login]":{required:"<span title='Login is required' class='errortip'>*</span>"},
            "user[password]":{required:"<span title='Password is required' class='errortip'>*</span>",
                minlength:"<span title='Password must be of minimum 6 characters' class='errortip'>**</span>"},
            "user[confirmed_password]":{required:"<span title='Confirmed password is required' class='errortip'>*</span>",
                minlength:"<span title='Password must be of minimum 6 characters' class='errortip'>**</span>",
                equalTo:"<span title='Confirmed password doesn&apos;t match with the password' class='errortip'>***</span>"},
            "user[email]":{email:"<span title='Incorrect format' class='errortip'>*</span>"}
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
                        "Yes": function() {
                            window.location.href = loc;
                        },
                        Ni: function() {
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

function createUser() {
    if( !isAtLeastOneRoleSelected() )
    {
        return;
    }
    $('#user_form').get(0).setAttribute('action', $('#user_form').get(0).getAttribute('action').replace('update', 'create'));
    $('#user_form').submit();
}

function updateUser() {
    if( !isAtLeastOneRoleSelected() )
    {
        return;
    }
    $('#user_form').submit();
}

function selectRow(rw) {
    $('#userroletable tr td').removeClass('selected');
    $(rw).contents('td').addClass('selected');
}

function addToRole() {
    var selectedValue = $('#role_id').val();
    var selectedText = $('#role_id option:selected').text();
    if (selectedValue != null) {
        var tableDataText = "<td><input type='hidden' name='roles[role_" + selectedValue + "[id]]' value='0'/>";
        tableDataText += "<input type='hidden' name='roles[role_" + selectedValue + "[role_id]]' value='" + selectedValue + "'/>";
        tableDataText += "<label>" + selectedText + "</label></td>";
        tableDataText += "<td class='centerdata'><input name='roles[role_" + selectedValue + "[is_role_admin]]' type='hidden' value='no' />";
        tableDataText += "<input name='roles[role_" + selectedValue + "[is_role_admin]]' type='checkbox' value='yes' onclick='javascript:adminClicked(this);' /></td>";
        tableDataText += "<td class='centerdata'><input name='roles[role_" + selectedValue + "[can_read_all]]' type='hidden' value='no' />";
        tableDataText += "<input name='roles[role_" + selectedValue + "[can_read_all]]' type='checkbox' value='yes' disabled='disabled' /></td>";
        tableDataText += "<td class='centerdata'><input name='roles[role_" + selectedValue + "[can_insert_all]]' type='hidden' value='no' /></td>";
        tableDataText += "<td class='centerdata'><input name='roles[role_" + selectedValue + "[can_update_all]]' type='hidden' value='no' /></td>";
        tableDataText += "<td class='centerdata'><input name='roles[role_" + selectedValue + "[can_delete_all]]' type='hidden' value='no' /></td>";

        $('#userroletable > tbody:last').append("<tr onclick='javascript:selectRow(this);'>" + tableDataText + '</tr>');
        $('#role_id option:selected').remove();
    }
}

function removeFromRole() {
    $("#userroletable tr > td.selected:first").each(function() {
        var value = $(this).find("input[name$='[role_id]]']").val();
        var text = $(this).text();
        $('#role_id').append("<option value='" + value + "'>" + text + "</option>");
        $(this).parent().remove();
    });
}

function adminClicked(chk) {
    if ($(chk).attr('checked') == true) {
        $(chk).parent().parent().find('input[type=checkbox]').each(function() {
            if ($(this).attr('name') != $(chk).attr('name')) {
                $(this).removeAttr('disabled');
            }
        });
    } else {
        $(chk).parent().parent().find('input[type=checkbox]').each(function() {
            if ($(this).attr('name') != $(chk).attr('name')) {
                $(this).attr('disabled', 'disabled');
                $(this).removeAttr('checked');
            }
        });
    }
}

function submitSearch() {
    $('#user_search_form').submit();
}