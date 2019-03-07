/**
 * Created by rifat on 12/11/14.
 */
$(document).ready(function() {
    setValidators();
});
function updateClient(isActive)
{
//      $('#client_form').submit();
//      if( busy )
//      {
//          alert( 'Page is busy, please try again.' );
//          return;
//      }
    $('#client_form').get(0).setAttribute('action', $('#client_form').get(0).getAttribute('action').replace('create', 'update'));
    $('#client_form').submit();
    //clearForm();
}
function submitSearch() {
    $('#client_search_form').submit();
}
function cancel()
{
    $('#client_client_name').val('');
    $('#client_display_name').val('');
}
function createClient(isActive)
{
    $('#client_form').submit();
    if( busy )
    {
        alert( 'Page is busy, please try again.' );
        return;
    }


    $('#timecard_form').get(0).setAttribute('action', $('#timecard_form').get(0).getAttribute('action').replace('edit', 'create'));
    $("#timecard_bill_status").removeAttr('disabled'); //enable the field while posting to post field value
    if( isPost )
    {
        $("#timecard_finalized").val( "true" );
    }
    else
    {
        $("#timecard_finalized").val( "false" );
    }
    $('#client_form').submit();
    //clearForm();
}

function setValidators() {
    $("#client_form").validate({
        rules:{
            "client[client_name]":{required:true},
            "client[display_name]":{required:true}
        },
        messages:{
            "client[client_name]":{required:"<span title='Matter name is required' class='errortip'>*</span>"},
            "client[display_name]":{required:"<span title='Matter nick name is required' class='errortip'>*</span>"}
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
