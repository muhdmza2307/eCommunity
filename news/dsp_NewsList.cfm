<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

  <cfquery name="newsList" datasource="#request.MTRDSN#">
   SELECT  a.iNEWSID, a.vaNEWSTITLE, a.vaNEWSBODYSHORT, a.dtDATECREATED,  b.vaUSName
   FROM NWS0001 a WITH (NOLOCK)
   INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iCREATEDBY
   WHERE a.siSTATUS = 2 --0:pending, 1:deactive, 2:active
   ORDER BY iNEWSID DESC
</cfquery>

<body>

    <cfoutput>
      <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="JQUERY_DATATABLES_JS">
      <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="DATATABLES_BOOTSTRAP_JS">
      <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="DATATABLES_BOOTSTRAP_CSS">
   </cfoutput>

    <script>
        $(document).ready(function() {
            $('#tblNews').DataTable();
        } );    
    </script>

    <div class="body-content">
       <div class="container">
            <div style="text-align:center"><h2>News List</h2></div><br><br>
            
            <div class="col-sm col-xs-12">
                <cfoutput><button type="button" class="btn btn-success" style="float: left;" onclick="location.href='#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsCreate&#session.urltoken#';"><i class="fa fa-plus"></i> Create New</button></cfoutput>          
                <br><br><br>
                <table id="tblNews" width="100%" class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th style="width: 5%">No.</th>
                            <th>Title</th>
                            <!--- <th>Content</th> --->
                            <th style="width: 20%">Posted By</th>
                            <th style="width: 20%">Date Posted</th>
                            <th style="width: 10%">Action</th>
                        </tr>
                    </thead>

                    <cfset i = 0>
                    <cfoutput>
                        <cfloop query="newsList">
                            <cfset i = i + 1> 
                            <tbody>
                                <tr>
                                    <td>#i#</td>
                                    <td>#newsList.vaNEWSTITLE#</td>
                                    <!--- <td>#newsList.vaNEWSBODYSHORT#</td> --->
                                    <td>#newsList.vaUSName#</td>
                                    <td>#DateTimeFormat(newsList.dtDATECREATED, "dd-mm-yyyy")#</td>
                                    <td>
                                      <a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsDetails&inewsId=#newsList.iNEWSID#&#session.urltoken#" class="badge badge-info"><i class="fa fa-book" aria-hidden="true"></i> Read More</a>
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