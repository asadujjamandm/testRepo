/**
 * Created by akash on 12/1/14.
 */
$(document).ready(function() {
    /*setConfirmations();*/
    setValidators();
    /*$( "#user_name" ).focus();  */
});

function setValidators() {
    $("#activitycode_form").validate({
        rules:{
            "activitycode[activity_code]":{required:true},
            "activitycode[activity_desc]":{required:true}
        },
        messages:{
            "activitycode[activity_code]":{required:"<span title='Activity code is required' class='errortip'>*</span>"},
            "activitycode[activity_desc]":{required:"<span title='Activity description is required' class='errortip'>*</span>"}
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

}

function createActivitycode() {
    $('#activitycode_form').get(0).setAttribute('action','create');
    $('#activitycode_form').submit();
}
function updateActivitycode()
{
    $('#activitycode_form').get(0).setAttribute('action',$('#activitycode_form').get(0).getAttribute('action').replace('create', 'update'));
    $('#activitycode_form').submit();
}

function submitSearch() {
    $('#activity_search_form').submit();
}