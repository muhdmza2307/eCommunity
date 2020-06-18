<cfquery name="bar_activeUser" datasource="#request.MTRDSN#">
	SELECT c.vaUSName, sum(c.total) AS iTOTALCount FROM
	(SELECT COUNT(a.iCREATEDBY) AS total, b.vaUSName
	FROM NWS0001 a WITH(NOLOCK)
	INNER JOIN SEC0001 b WITH(NOLOCK) ON b.iUSID = a.iCREATEDBY
	GROUP BY a.iCREATEDBY, b.vaUSName
	UNION ALL
	SELECT COUNT(a.iCREATEDBY) AS total, b.vaUSName
	FROM FRM0001 a WITH(NOLOCK)
	INNER JOIN SEC0001 b WITH(NOLOCK) ON b.iUSID = a.iCREATEDBY
	GROUP BY a.iCREATEDBY, b.vaUSName) c 
	GROUP BY c.vaUSName
</cfquery>

<cfquery name="pie_commType" datasource="#request.MTRDSN#">
	DECLARE @i_TOTAL INT
	DECLARE @i_SUBNEWSTOTAL DECIMAL(18,2)
	DECLARE @i_SUBFRMSTOTAL DECIMAL(18,2)
	DECLARE @temp_TABLE TABLE (
     vaCOMMTYPE NVARCHAR(25),
	 iSUBTOTAL DECIMAL(18,2)
 	);

	SELECT @i_TOTAL = SUM(c.SUBTOTAL) FROM
	(SELECT COUNT(a.iNEWSID) AS SUBTOTAL
	FROM NWS0001 a WITH(NOLOCK)
	UNION
	SELECT COUNT(b.iFORUMSID) AS SUBTOTAL
	FROM FRM0001 b WITH(NOLOCK)) c

	SELECT @i_SUBNEWSTOTAL = COUNT(a.iNEWSID)
	FROM NWS0001 a WITH(NOLOCK)

	SELECT @i_SUBFRMSTOTAL = COUNT(b.iFORUMSID) 
	FROM FRM0001 b WITH(NOLOCK)

	INSERT INTO @temp_TABLE
	VALUES('News', @i_SUBNEWSTOTAL)

	INSERT INTO @temp_TABLE
	VALUES('Forums', @i_SUBFRMSTOTAL)


	SELECT vaCOMMTYPE, CAST(ROUND(iSUBTOTAL * 100.0 / @i_TOTAL, 2)AS NUMERIC(36,2)) AS 'perc_SUB'
	FROM @temp_TABLE
</cfquery>

<cfquery name="pendingApp" datasource="#request.MTRDSN#">
  SELECT TOP 3 a.iNEWSID, a.dtDATECREATED, b.vaUSName
  FROM NWS0001 a WITH (NOLOCK)
  INNER JOIN SEC0001 b WITH (NOLOCK) ON b.iUSID = a.iCREATEDBY
  WHERE a.siSTATUS = 0
  ORDER BY a.dtDATECREATED DESC
</cfquery>

<cfquery name="pendingCount" datasource="#request.MTRDSN#">
  SELECT COUNT(a.iNEWSID) as iCount
  FROM NWS0001 a WITH (NOLOCK)
  WHERE a.siSTATUS = 0
</cfquery>



<body>

	<cfoutput>
      <script type="text/javascript" src="#request.LOGPATH#assets/js/jqplot/jquery.jqplot.js"></script>
      <script type="text/javascript" src="#request.LOGPATH#assets/js/jqplot/plugins/jqplot.barRenderer.js"></script>
      <script src="#request.LOGPATH#assets/js/jqplot/plugins/jqplot.categoryAxisRenderer.js"></script>
	  <script src="#request.LOGPATH#assets/js/jqplot/plugins/jqplot.pointLabels.js"></script>
	  <script src="#request.LOGPATH#assets/js/jqplot/plugins/jqplot.pieRenderer.js"></script>
      <link rel="stylesheet" type="text/css" href="#request.LOGPATH#assets/css/jqplot/jquery.jqplot.min.css">
   </cfoutput>

	<div style="padding-top: 1.5rem; padding-bottom: 1.5rem;">
	<div class="container">
		<div class="row"> 
        <div class="col-xl-3 col-md-6 mb-4">
		      <cfoutput><a class="card border-left-primary shadow h-100 py-2" style="background-color: ##FFDAB9" href="#request.webroot#index.cfm?fusebox=admin&fuseaction=dsp_ApprovalList&#session.urltoken#"></cfoutput>
		        <div class="card-body">
		          <div class="row no-gutters align-items-center">
		            <div class="col mr-2">
		              <div class="text-xs font-weight-bold text-dark text-uppercase mb-1">Pending Approval</div>
		            </div>
		            <div class="col-auto">
		              <i class="fa fa-bell fa-2x text-gray-300" style="color: black"></i>
		              <cfoutput query="pendingCount"><span class="badge badge-danger badge-counter">#pendingCount.iCount#+</span></cfoutput>
		            </div>
		          </div>
		        </div>
		      </a>
		    </div>

		</div>

		<div class="row">
			<div class="col-xl-6 col-lg-5">
              <div class="card shadow mb-4">
              	<div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                  <h6 class="m-0 font-weight-bold text-dark">Bar Chart - Most active user</h6>
              </div>
                <div class="card-body text-center" style="background-color: #FFDAB9">
                  <div class="chart-area">
                    <div id="bar_activeUser" style="height:200px;width:250px;margin-left: auto;margin-right: auto; "></div>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-xl-6 col-lg-5">
              <div class="card shadow mb-4">
              	<div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                  <h6 class="m-0 font-weight-bold text-dark">Pie Chart - Percentage on Communication Use</h6>
              </div>
                <div class="card-body text-center" style="background-color: #FFDAB9">
                  <div class="chart-area">
                    <div id="pie_commType" style="height:200px;width:250px;margin-left: auto;margin-right: auto; "></div>
                  </div>
                </div>
              </div>
            </div>
		</div>
	</div>
	</div>
</body>

<script type="text/javascript">

	$(document).ready(function(){
        $.jqplot.config.enablePlugins = true;

        var s1 = [<cfoutput query=bar_activeUser>#iTOTALCount#<cfif currentRow lt bar_activeUser.recordCount>,</cfif></cfoutput>];

        var ticks = [<cfoutput query=bar_activeUser>'#JSStringFormat(vaUSName)#'<cfif currentRow lt bar_activeUser.recordCount>,</cfif></cfoutput>];
 
        plot1 = $.jqplot('bar_activeUser', [s1], {
            animate: !$.jqplot.use_excanvas,
            seriesDefaults:{
                renderer:$.jqplot.BarRenderer,
                pointLabels: { show: true }
            },
            axes: {
                xaxis: {
                    renderer: $.jqplot.CategoryAxisRenderer,
                    ticks: ticks
                }
            },
            highlighter: { show: false }
        });

        var data = [
			    <cfoutput query="pie_commType">['#JSStringFormat(vaCOMMTYPE)# - #perc_SUB#',#perc_SUB#]<cfif currentrow lt pie_commType.recordCount>,</cfif></cfoutput>
			];

        var plot2 = $.jqplot('pie_commType', [data], {
        gridPadding: {top:0, bottom:38, left:0, right:0},
        seriesDefaults:{
            renderer:$.jqplot.PieRenderer, 
            trendline:{ show:false }, 
            rendererOptions: { padding: 8, showDataLabels: true }
        },
        legend:{
            show:true, 
            placement: 'outside', 
            rendererOptions: {
                numberRows: 1
            }, 
            location:'s',
            marginTop: '15px'
        }       
    });
     
        	
    });
</script>
