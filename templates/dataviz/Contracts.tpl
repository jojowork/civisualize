{crmTitle title="Abo Abschlüsse"}
	<div id="datacount" style="margin-bottom:20px;">
	    <h2><strong><span class="filter-count"></span></strong> Contract Signup activities selected from a total of <strong><span id="total-count"></span></strong> records</h2>
	    <br>
	</div>
  <div class="clear"></div>
  <div id="signup-bar-by-year">
    <strong>Date - Contract Created by Year Bar-Chart</strong>
    <a class="reset civisualize-reset" href data-chart-name="signupBarYear" >reset</a>
    <div class="clearfix"></div>
  </div>

  <div id="signup-bar-by-month">
    <strong>Date - Contract Created by Month Bar-Chart</strong>
    <a class="reset civisualize-reset" href data-chart-name="signupBarMonth" >reset</a>
    <div class="clearfix"></div>
  </div>
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


<div id="contract-series-chart">
  <strong>Date - Contract Series Chart</strong>
  <a class="reset civisualize-reset" href data-chart-name="contractSeriesChart" >reset</a>
  <div class="clearfix"></div>
</div>

  <div class="clear"></div>


<script>
var data = {crmSQL sql="SELECT DATE(activity_date_time) AS date, count(*) AS count, 0 as count_cancel,'signup' AS activity FROM civicrm_activity WHERE activity_type_id IN (57) group by DATE(activity_date_time) union SELECT DATE(activity_date_time) AS date, 0 as count, -count(*) AS count_cancel,'cancel' AS activity FROM civicrm_activity WHERE activity_type_id IN (60 ) group by DATE(activity_date_time)"};
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


  var creationMonth = ndx.dimension(function(d) {  return d.dd; });
  var creationMonthGroup = creationMonth.group().reduceSum(function(d) { return d.count; });

  var cancelMonth = ndx.dimension(function(d) {  return d.dd; });
  var cancelMonthGroup = cancelMonth.group().reduceSum(function(d) { return d.count_cancel; });

  var min = d3.timeDay.offset(d3.min(data.values, function(d) { return d.dd;} ),-2);
  var max = d3.timeDay.offset(d3.max(data.values, function(d) { return d.dd;} ), 2);

  var minY = d3.min(data.values, function(d){ return d.count_cancel; });
  var maxY = d3.max(data.values, function(d){ return d.count; });
  var y = d3.scaleLinear().domain([minY, maxY]).range([minY, maxY]);

  var x = d3.scaleTime().domain([min, max])


  // instantiate Charts
  monthLine=null;
  monthLine 	= dc.lineChart('#signups-by-month');

  cancelLine=null;
  cancelLine 	= dc.lineChart('#cancels-by-month');

  var byMonth     = ndx.dimension(function(d) { return d3.timeMonth(d.dd); });
  var volumeByMonthGroup  = byMonth.group().reduceSum(function(d) { return d.count; });
  signupBar = null;
  signupBar 	= dc.barChart('#signup-bar-by-month');


  var byYear     = ndx.dimension(function(d) { return d3.timeYear(d.dd); });
  var volumeByYearGroup  = byYear.group().reduceSum(function(d) { return d.count; });
  yearSignupBar = null;
  yearSignupBar 	= dc.barChart('#signup-bar-by-year');

  // Signup by Year Barchart
  yearSignupBar
          .width(800)
          .height(150)
          .margins({top: 0, right: 50, bottom: 30, left: 50})
          .dimension(byYear)
          .group(volumeByYearGroup)
          .x(d3.scaleTime().domain([min, max]))
          //.x(d3.scaleOrdinal().domain([min, max]))
          //.x(d3.scaleBand().domain([min,max]))
          //.x(d3.scaleLinear().domain([min,max]))
          //.brushOn(false)
          .round(d3.timeYear.round)
          //.xUnits(dc.units.ordinal)
          .xUnits(d3.timeYears)
          .colors("#00aa00")
          .yAxisLabel("Signups per Year")
          .renderLabel(true)
          .clipPadding(120)
          ;

  // Signup by Month Barchart
  signupBar
          .width(800)
          .height(200)
          .margins({top: 30, right: 50, bottom: 30, left: 50})
          .dimension(byMonth)
          .group(volumeByMonthGroup)
          .x(x)
          .round(d3.timeMonth.round)
          .xUnits(d3.timeMonths)
          //.xUnits(dc.units.ordinal)
          .colors("#00aa00")
          .gap(1)
          .yAxisLabel("Signups per Month")
          .renderLabel(true)
          .centerBar(true)
          .clipPadding(20)
          //.brushOn(false)
          .rangeChart(yearSignupBar)
          ;

  // Signup LineChart
  monthLine
        .width(800)
        .height(200)
        .margins({top: 10, right: 50, bottom: 30, left: 50})
        .dimension(creationMonth)
        .group(creationMonthGroup)
        .x(x)
        .y(y)
        .round(d3.timeDay.round)
        //.elasticY(true)
        .xUnits(d3.timeDays)
        //.mouseZoomable(true)
        .colors("#00aa00")
        .rangeChart(signupBar)
        .brushOn(false)
        ;

  // Canceled LineChart
  cancelLine
        .width(800)
        .height(200)
        .margins({top: 10, right: 50, bottom: 30, left: 50})
        .dimension(cancelMonth)
        .group(cancelMonthGroup)
        .x(x)
        .y(y)
        .round(d3.timeDay.round)
        //.elasticY(true)
        .xUnits(d3.timeDays)
        .colors("#cc0000")
        .rangeChart(signupBar)
        .brushOn(false);









  var seriesDimension = ndx.dimension(function(d) { return d.dd;});
  var seriesGroup = seriesDimension.group().reduceSum(function(d){ return d.count; });


  dc.renderAll();


  //CRM.civisualize.charts['exampleTypePie'] = typePie;
  //CRM.civisualize.charts['exampleGenderPie'] = genderPie;
  CRM.civisualize.charts['contactsMonthLine'] = monthLine;
  CRM.civisualize.charts['cancelMonthLine'] = cancelLine;
  CRM.civisualize.charts['signupBarMonth'] = signupBar;
  CRM.civisualize.charts['signupBarYear'] = yearSignupBar;
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
