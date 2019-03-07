/**
 * Created by rifat on 12/11/14.
 */
$(document).ready(function() {
    setValidators();
    $( "#user_name" ).focus();
});

function cancel()
{
    $('#matter_matter_name').val('');
    $('#matter_matter_nick_name').val('');
    $('#matter_matter_number').val('');

    $('#matter_client_name').val('');
    $('#matter_client_id').val('');
}

function cancelUpdate()
{

    $('#matter_matter_name').val('');
    $('#matter_matter_nick_name').val('');
    $('#matter_matter_number').val('');

}

function submitSearch() {
    $('#matter_search_form').submit();
}

function setValidators() {
//    if($.trim($('#matter_client_name').html())=='')
//        $('#client_id').val('');

    $("#matter_form").validate({
        rules:{
            "matter[matter_name]":{required:true},
            "matter[matter_nick_name]":{required:true},
            "matter[client_name]":{required:true},
            "matter[client_id]":{required:true},
            "matter[matter_number]":{required:true}
        },
        messages:{
            "matter[matter_name]":{required:"<span title='Matter name is required' class='errortip'>*</span>"},
            "matter[matter_nick_name]":{required:"<span title='Matter nick name is required' class='errortip'>*</span>"},
            "matter[client_name]":{required:"<span title='Client is required' class='errortip'>*</span>"},
            "matter[client_id]":{required:"<span title='Client is required' class='errortip'>*</span>"},
            "matter[matter_number]":{required:"<span title='Matter number is required' class='errortip'>*</span>"}
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






