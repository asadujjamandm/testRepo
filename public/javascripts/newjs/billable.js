$(document).ready(function(){
$(".calendartitle").load(function(){
  var i=0;
  
  $("table.innertablewithtimecard>tbody>tr>td.billablebox").each(function(){ 
   i++; 
});
  alert(i);
    var billh = 0;
    var billm = 0;
    var non_billh = 0;
    var non_billm = 0;
    
    var postedh = 0;
    var postedm = 0;
    var pendingh = 0;
    var pendingm = 0;
  
    $(".billablebox").each(function(){
      
     var v = $(this).text();
     var val = v.split('/');
     
     var bill = val[0].split(':');
     var non_bill = val[1].split(':');
     billh += parseInt(bill[0]); 
     billm += parseInt(bill[1]);
     
     non_billh += parseInt(non_bill[0]); 
     non_billm += parseInt(non_bill[1]);
      
    });
   
    billh = billh + parseInt((billm/60));
    billm = (billm % 60);
    
    non_billh = non_billh + parseInt(non_billm/60);
    non_billm = (non_billm % 60);
    $("#billable").html(billh + ":"+billm+"/"+non_billh + ":"+ non_billm);
  
  $(".postedbox").each(function(){
     var p = $(this).text();
     var pval = p.split('/');
     
     var post = pval[0].split(':');
     var non_post = pval[1].split(':');
     postedh += parseInt(post[0]); 
     postedm += parseInt(post[1]);
     
     pendingh += parseInt(non_post[0]); 
     pendingm+= parseInt(non_post[1]);
      
    });
   
    postedh = postedh + parseInt((postedm/60));
    postedm = (postedm % 60);
    
    pendingh = pendingh + parseInt(pendingm/60);
    pendingm = (pendingm % 60);
    $("#posted").html(postedh + ":"+postedm+"/"+pendingh+ ":"+ pendingm);
    $("#timecard").html(i);
  });
  
});