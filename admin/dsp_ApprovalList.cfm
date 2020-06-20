<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

    <cfquery name="appList" datasource="#request.MTRDSN#">
   SELECT a.iNEWSID, a.vaNEWSTITLE, a.dtDATECREATED, b.vaUSName
    FROM NWS0001 a WITH (NOLOCK)
    INNER JOIN SEC0001 b WITH (NOLOCK) ON b.iUSID = a.iCREATEDBY
    WHERE a.siSTATUS = 0
    ORDER BY a.dtDATECREATED DESC
</cfquery>

<body>

    <cfoutput>
      <script type="text/javascript" src="#request.LOGPATH#assets/js/dataTable/jquery.dataTables.js"></script>
      <script type="text/javascript" src="#request.LOGPATH#assets/js/dataTable/dataTables.bootstrap4.js"></script>
      <link rel="stylesheet" type="text/css" href="#request.LOGPATH#assets/css/dataTable/dataTables.bootstrap4.css">
   </cfoutput>

    <script>
        $(document).ready(function() {
            $('#tblApp').DataTable();
        } );    
    </script>

    <div class="body-content">
       <div class="container">
            <div style="text-align:center"><h2>Approval List</h2></div><br><br>
            
            <div class="col-sm col-xs-12">
                <table id="tblApp" width="100%" class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th style="width: 20px">No.</th>
                            <th>Title</th>
                            <th style="width: 120px">Posted By</th>
                            <th style="width: 100px">Date Posted</th>
                            <th style="width: 60px">Action</th>
                        </tr>
                    </thead>

                    <cfset i = 0>
                    <cfoutput>
                        <cfloop query="appList">
                            <cfset i = i + 1> 
                            <tbody>
                                <tr>
                                    <td>#i#</td>
                                    <td>#appList.vaNEWSTITLE#</td>
                                    <td>#appList.vaUSName#</td>
                                    <td>#DateTimeFormat(appList.dtDATECREATED, "dd-mm-yyyy")#</td>
                                    <td>
                                      <a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsDetails&inewsId=#appList.iNEWSID#&#session.urltoken#" class="badge badge-info"><i class="fa fa-search" aria-hidden="true"></i> Details</a>
                                      <!--- <a href="##" class="badge badge-danger">Decline</a> --->
                                    </td>                      
                                </tr>
                            </tbody>
                        </cfloop>
                    </cfoutput>
                </table>    
            </div>
               
       </div>
    </div>
</body>