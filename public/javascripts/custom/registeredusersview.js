/**
 * Created by akash on 12/1/14.
 */
$(document).ready(function() {
    $('.modal-btn').click(function(ev){

        console.log($(this).attr('data-regid'));
        var par = $(this).parent();
        console.log($(par).prevAll().eq(2).html());
        //var farmname= par.child(2);
        $('#farmEntry').modal('show');
        $('#farmEntry').css("z-index", "1500");
        $('#farmEntry .modal-dialog').css('width', '320px');
        $('#farmEntry .modal-dialog').css('margin-left', 'auto');
        $('#farmEntry .modal-dialog').css('margin-right', 'auto');
        $('#farm_name_list').val("");
        $('#farm_setting_xml_export_path').prop('disabled', false);
        $('#farm_setting_setting_timcard_persistent_days').prop('disabled', false);
        $('#farm_setting_sync_enabled').prop('disabled', false);
        $('#farm_setting_farm_name').val("");
        $('#farm_setting_farm_name').val($(par).prevAll().eq(1).html().trim());
        $('#farm_setting_xml_export_path').val("");
        $('.errortip').html("");
        $("#regid").val($(this).attr('data-regid'));
        //$('#farmEntry').appendTo("body");


    });
    //$('#farm_setting_id').on('click',function(){
        //e.preventDefault();
        //$(this).css('disable','true');
    //});
    //setValidators();
});

function setValidators() {
    $("#farm_setting_new").validate({
        rules:{
            //"farm_setting[farm_name]":{required:true},
            "farm_setting[xml_export_path]":{required:true}
        },
        messages:{
            //"farm_setting[farm_name]":{required:"<span title='Firm Name is required' class='errortip'>Firm Name is required</span>"},
            "farm_setting[xml_export_path]":{required:"<span title='XML Export path is required' class='errortip'>XML Export path is required</span>"}
        },
        errorClass: "validation-error"
    });
}


function createFarm() {
    $('#farm_setting_new').get(0).setAttribute('action','registered_users/create_farm');
    $('#farm_setting_new').submit();
}


