$(document).ready(function() {
    setValidators();

});

function setValidators() {
    $("#register_new").validate({
        rules:{
            "register[full_name]":{required:true},
            "register[email]":{required:true, email: true },
            "register[password]":{required:true, minlength:6},
            "register[confirmed_password]":{required:true, minlength:6, equalTo:'#register_password'}

        },
        messages:{
            "register[full_name]":{required:"<span title='User Full Name is required' style='color: #b70000; padding-top:10px' >User Full Name is required</span>"},
            "register[password]":{required:"<span title='Password is required' style='color: #b70000; padding-top:10px '>Password is required</span>",
                minlength:"<span title='Password must be of minimum 6 characters' style='color: #b70000; padding-top:10px' >Password must be of minimum 6 characters</span>"},
            "register[confirmed_password]":{required:"<span title='Confirmed password is required' style='color: #b70000; padding-top:10px' >Confirmed password is required</span>",
                minlength:"<span title='Password must be of minimum 6 characters' style='color: #b70000; padding-top:10px '>Password must be of minimum 6 characters</span>",
                equalTo:"<span title='Confirmed password doesn&apos;t match with the password' style='color: #b70000; padding-top:10px '>Confirmed password doesn't match with the password</span>"},
            "register[email]":{required: "<span title='User Email is required' style='color: #b70000; padding-top:10px' >User Email is required</span>",
            email: "<span title='User Email is invalid' style='color: #b70000; padding-top:10px' >Please enter a valid email</span>"}
        },
        errorClass: "validation-error"
    });
}