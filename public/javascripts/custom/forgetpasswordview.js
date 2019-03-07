$(document).ready(function() {
    $("#forget_password_new").validate({
        rules:{
            "forget_password[email]"   :          { required: true },
            "forget_password[firm_id]" :          { required: true}
        },
        messages:{
            "forget_password[email]"       :           { required: "<span title='Email is required' style='color: #b70000; padding-top:10px '> Email is required</span>" },
            "forget_password[firm_id]"    :           { required: "<span title='Firm ID is required' style='color: #b70000; padding-top:10px '> Firm ID is required</span>" }
        },
        errorClass: "validation-error"
    });
});