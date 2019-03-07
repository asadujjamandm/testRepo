<script type="text/javascript">
    $(document).ready(function(){
        var chartDataJSON = $("#chart_data_json").html();
        var jsonData = $.parseJSON(chartDataJSON);
        var billable = [];
        var non_billable = [];
        var i = 0;
        $.each(jsonData, function() {
            billable[i]= calcHours(this['total_billable_current']);
            non_billable[i]=calcHours(this['total_non_billable_current']);
            billable[i+1] = calcHours(this['total_billable_last_month']);
            non_billable[i+1]=calcHours(this['total_non_billable_last_month']);
            billable[i+2] = calcHours(this['total_billable_last_month2']);
            non_billable[i+2]=calcHours(this['total_non_billable_last_month2']);
        });

        function calcHours(strtime){
            var actualH;
            if(strtime == "0") actualH = parseInt(strtime);
            else{
                var t = strtime.split(':') ;
                var  h = parseInt(t[0]);
                var  m = parseInt(t[1]);
                actualH = parseFloat(h) + parseFloat(m/100);
            }
            return actualH;
        }
        var monthNames = ["January", "February","March","April","May","June","July","August","September","October","November","December"];
        var d = new Date();
        var barChartData = {
            labels : [monthNames[d.getMonth() - 2],monthNames[d.getMonth() - 1],monthNames[d.getMonth()]],
            datasets : [
                {
                    fillColor : "#00c0ef",
                    strokeColor : "#48A4D1",
                    highlightFill: "#01A9DB",
                    highlightStroke: "#48A4D1",
                    data : [billable[i + 2], billable[i + 1],billable[i]]
                },
                {
                    fillColor : "#A9D0F5",
                    strokeColor : "rgba(72,174,209,0.4)",
                    highlightFill: "#58ACFA",
                    highlightStroke: "#48A4D1",
                    /*data : [non_billable[i + 2], non_billable[i+1], non_billable[i]]    */
                    data : [10.5, 5.6,28.3]
                }
            ]

        }
        var ctx = document.getElementById("chart").getContext("2d");
        new Chart(ctx).Bar(barChartData,{
            responsive : true

        });
    });
</script>