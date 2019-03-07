$(document).ready(function() {
    setValidators();
});

function setValidators() {
    $("#change_password_form").validate({
        rules:{
            "password[old]":{required:true},
            "password[new]":{required:true, minlength:5},
            "password[confirmed]":{required:true, minlength:5, equalTo:'#password_new'}
        },
        messages:{
            "password[old]":{required:"<span title='Old password is required' class='errortip'>*</span>"},
            "password[new]":{required:"<span title='New password is required' class='errortip'>*</span>",
                            minlength:"<span title='Password must be of minimum 5 characters' class='errortip'>**</span>"},
            "password[confirmed]":{required:"<span title='Confirmed password is required' class='errortip'>*</span>",
                            minlength:"<span title='Password must be of minimum 5 characters' class='errortip'>**</span>",
                            equalTo:"<span title='Confirmed password doesn&apos;t match with the new password' class='errortip'>***</span>"}
        },
        errorClass: "validation-error"
    });
}

function submitChange() {
    $('#change_password_form').submit();
}