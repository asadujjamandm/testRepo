$(document).ready(function() {
    $("#new_auth").validate({
        rules:{
            "auth[login]"       :          { required: true },
            "auth[password]"    :          { required: true}
        },
        messages:{
            "auth[login]"       :           { required: "<span title='Login is required' style='color: #b70000; padding-top:10px '> Username is required</span>" },
            "auth[password]"    :           { required: "<span title='Password is required' style='color: #b70000; padding-top:10px '> Password is required</span>" }
        },
        errorClass: "validation-error"
    });
});