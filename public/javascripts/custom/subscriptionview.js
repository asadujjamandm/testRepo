
$(document).ready(function() {
    setValidators();
});

function setValidators() {
    $("#subscription_form").validate({
        rules:{
            "subscription[subscription_model]":{required:true}
        },
        messages:{
            "subscription[subscription_model]":{required:"<span title='Please select a subscription model' class='errortip'>*</span>"}
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



function submitSubscription() {
    $('#subscription_form').get(0).setAttribute('action','/subscriptions/confirm');
    $('#subscription_form').submit();
}
function submitFirmSubscription() {
    $('#farm_subscription_form').get(0).setAttribute('action','/subscriptions/confirm');
    $('#farm_subscription_form').submit();
}

function submitSearch() {
    $('#subscription_form').submit();
}
