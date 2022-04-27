{crmTitle title="Abo Abschlüsse"}
	<div id="datacount" style="margin-bottom:20px;">
	    <h2><strong><span class="filter-count"></span></strong> Contract Signup activities selected from a total of <strong><span id="total-count"></span></strong> records</h2>
	    <br>
	</div>
  <div class="clear"></div>
  <div id="signups-by-month">
      <strong>Date - Contract Created</strong>
      <a class="reset civisualize-reset" href data-chart-name="contactsMonthLine" >reset</a>
      <div class="clearfix"></div>
  </div>
  <div id="cancels-by-month">
    <strong>Date - Contract Canceled</strong>
    <a class="reset civisualize-reset" href data-chart-name="cancelMonthLine" >reset</a>
    <div class="clearfix"></div>
  </div>

  <div class="clear"></div>


<script>
var data = {crmSQL sql="SELECT DATE(activity_date_time) AS date, count(*) AS count FROM civicrm_activity WHERE activity_type_id IN (56 ) group by DATE(activity_date_time)"};
var cancelData = {crmSQL sql="SELECT DATE(activity_date_time) AS date, count(*) AS count FROM civicrm_activity WHERE activity_type_id IN (60 ) group by DATE(activity_date_time)"};
//var data = {crmSQL file="activities"};
{literal}
(function() { function bootViz() {
  // Use our versions of the libraries.
  var d3 = CRM.civisualize.d3, dc = CRM.civisualize.dc, crossfilter = CRM.civisualize.crossfilter;


  var totalContacts = 0;

  var dateFormat = d3.timeParse("%Y-%m-%d");
  var totalSignups = 0;

  data.values.forEach(function(d){
      totalSignups+=d.count;
      totalContacts+=d.count;
      d.dd = dateFormat(d.date);
  });

  var ndx  = crossfilter(data.values);
  var all = ndx.groupAll();


  var totalCount = dc.dataCount("#datacount")
    .dimension(ndx)
    .group(all);
  document.getElementById("total-count").innerHTML=totalSignups;


  monthLine=null;
  monthLine 	= dc.lineChart('#signups-by-month');




  var creationMonth = ndx.dimension(function(d) {  return d.dd; });
  var creationMonthGroup = creationMonth.group().reduceSum(function(d) { return d.count; });

  var min = d3.timeDay.offset(d3.min(data.values, function(d) { return d.dd;} ),-2);
  var max = d3.timeDay.offset(d3.max(data.values, function(d) { return d.dd;} ), 2);

  monthLine
        .width(800)
        .height(200)
        .margins({top: 10, right: 50, bottom: 30, left: 50})
        .dimension(creationMonth)
        .group(creationMonthGroup)
        .x(d3.scaleTime().domain([min, max]))
        .round(d3.timeDay.round)
        .elasticY(true)
        .xUnits(d3.timeDays);

  // cancels
    var totalCancels = 0;
    cancelData.values.forEach(function(d){
        totalCancels+=d.count;
        totalContacts+=d.count;
        d.dd = dateFormat(d.date);
    });

    ndx  = crossfilter(cancelData.values);
    all = ndx.groupAll();


    totalCount = dc.dataCount("#datacount")
        .dimension(ndx)
        .group(all);


    cancelLine=null;
    cancelLine 	= dc.lineChart('#cancels-by-month');



    var cancelMonth = ndx.dimension(function(d) {  return d.dd; });
    var cancelMonthGroup = cancelMonth.group().reduceSum(function(d) { return d.count; });

    min = d3.timeDay.offset(d3.min(cancelData.values, function(d) { return d.dd;} ),-2);
    max = d3.timeDay.offset(d3.max(cancelData.values, function(d) { return d.dd;} ), 2);

    cancelLine
        .width(800)
        .height(200)
        .margins({top: 10, right: 50, bottom: 30, left: 50})
        .dimension(cancelMonth)
        .group(cancelMonthGroup)
        .x(d3.scaleTime().domain([min, max]))
        .round(d3.timeDay.round)
        .elasticY(true)
        .xUnits(d3.timeDays);

  dc.renderAll();

  //CRM.civisualize.charts['exampleTypePie'] = typePie;
  //CRM.civisualize.charts['exampleGenderPie'] = genderPie;
  CRM.civisualize.charts['contactsMonthLine'] = monthLine;
  CRM.civisualize.charts['cancelMonthLine'] = cancelLine;
  CRM.civisualize.bindResetLinks();

  }

  // Boot our script as soon as ready.
  CRM.civisualizeQueue = CRM.civisualizeQueue || [];
  CRM.civisualizeQueue.push(bootViz);
})();
</script>

<style>
.clear {clear:both;}

</style>
{/literal}
