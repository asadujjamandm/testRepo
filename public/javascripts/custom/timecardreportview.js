$(document).ready(function() {
    /*$('.modal-btn-report').click(function(ev){

        //console.log($(this).attr('data-regid'));
        //var par = $(this).parent();
        //console.log($(par).prevAll().eq(2).html());
        //var farmname= par.child(2);
        $('#timeActivityForm').modal('show');
        $('#timeActivityForm').css("z-index", "1500");
        //$('#timeActivityForm .modal-dialog').css('width', '400px');
        $('#timeActivityForm .modal-dialog').css('margin-left', 'auto');
        $('#timeActivityForm .modal-dialog').css('margin-right', 'auto');
        //$('#farm_name_list').val("");
        //$('#farm_setting_xml_export_path').prop('disabled', false);
        //$('#farm_setting_setting_timcard_persistent_days').prop('disabled', false);
        //$('#farm_setting_sync_enabled').prop('disabled', false);
        //$('#farm_setting_farm_name').val("");
        //$('#farm_setting_farm_name').val($(par).prevAll().eq(1).html().trim());
        //$('#farm_setting_xml_export_path').val("");
        //$('.errortip').html("");
        //$("#regid").val($(this).attr('data-regid'));
        //$('#farmEntry').appendTo("body");


    });*/
    $("#time_activity_new").validate({
        rules:{
            "time_activity[reference_no]":{required:true},
            "time_activity[customer_ref]":{required:true},
            "time_activity[hourly_rate]":{required:true}
        },
        messages:{
            "time_activity[reference_no]":{required:"<span title='Please select a reference no' class='errortip'>*</span>"},
            "time_activity[customer_ref]":{required:"<span title='Please select a customer ref' class='errortip'>*</span>"},
            "time_activity[hourly_rate]":{required:"<span title='Please enter hourly rate' class='errortip'>*</span>"}
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
    //$('#farm_setting_id').on('click',function(){
    //e.preventDefault();
    //$(this).css('disable','true');
    //});
    //setValidators();
});
function submitSearch() {
    $('#timecard_search_form').get(0).setAttribute('action', $('#timecard_search_form').get(0).getAttribute('action').replace('view_pdf', 'search').replace('export_timecard_txt', 'search').replace('export_timecard_xml','search').replace('week_report', 'search'));
    $('#timecard_search_form').attr('target', '_self');
    $('#timecard_search_form').submit();
}

function submitViewPdf() {
    $('#timecard_search_form').get(0).setAttribute('action', $('#timecard_search_form').get(0).getAttribute('action').replace('search', 'view_pdf').replace('export_timecard_txt', 'view_pdf').replace('export_timecard_xml','view_pdf').replace('week_report', 'view_pdf'));
    $('#timecard_search_form').attr('target', '_blank');
    $('#timecard_search_form').submit();
}

function submitWeekReport() {
    $('#timecard_search_form').get(0).setAttribute('action', $('#timecard_search_form').get(0).getAttribute('action').replace('search', 'week_report').replace('export_timecard_txt', 'week_report').replace('export_timecard_xml','week_report').replace('view_pdf', 'week_report'));
    $('#timecard_search_form').attr('target', '_blank');
    $('#timecard_search_form').submit();
}

/*function exportTimecard() {
    $('#timecard_search_form').get(0).setAttribute('action', $('#timecard_search_form').get(0).getAttribute('action').replace('search', 'export_timecard').replace('view_pdf', 'export_timecard'));
    $('#timecard_search_form').attr('target', '_blank');
    $('#timecard_search_form').submit();
}*/

function exportTimecard(format) {
    if(format=="txt"){
        $('#timecard_search_form').get(0).setAttribute('action', $('#timecard_search_form').get(0).getAttribute('action').replace('search', 'export_timecard_txt').replace('view_pdf', 'export_timecard_txt').replace('export_timecard_xml','export_timecard_txt').replace('week_report', 'export_timecard_txt'));
        $('#timecard_search_form').attr('target', '_blank');
        $('#timecard_search_form').submit();

    }
    else if(format=="xml"){
        $('#timecard_search_form').get(0).setAttribute('action', $('#timecard_search_form').get(0).getAttribute('action').replace('search', 'export_timecard_xml').replace('view_pdf', 'export_timecard_xml').replace('export_timecard_txt','export_timecard_xml').replace('week_report', 'export_timecard_xml'));
        $('#timecard_search_form').attr('target', '_blank');
        $('#timecard_search_form').submit();

    }

}