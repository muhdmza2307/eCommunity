<cfquery name="userList" datasource="#request.MTRDSN#">
   SELECT  a.iPROFILEID, CASE WHEN iGENDER = 0  THEN 'Male' ELSE 'Female' END as 'vaGender',
   a.dtDATEBIRTH, a.dtDATECREATED, a.vaEMAIL, b.vaUSName, c.vaROLENAME
   FROM USR_PROF0001 a WITH (NOLOCK)
   INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iUSID
   INNER JOIN ROL0001 c WITH (NOLOCK) on c.iROLEID = b.iROLEID
   ORDER BY iPROFILEID DESC
</cfquery>

<body>

   <cfoutput>
      <script type="text/javascript" src="#request.LOGPATH#assets/js/dataTable/jquery.dataTables.js"></script>
      <script type="text/javascript" src="#request.LOGPATH#assets/js/dataTable/dataTables.bootstrap4.js"></script>
      <link rel="stylesheet" type="text/css" href="#request.LOGPATH#assets/css/dataTable/dataTables.bootstrap4.css">
   </cfoutput>

   
   <div class="body-content">
      <div class="container">
         <div style="text-align:center">
            <h2>User List</h2>
         </div>
         <br><br>
         <div class="col-sm col-xs-12">
            <cfoutput><button type="button" class="btn btn-success" style="float: left;" onclick="location.href='#request.webroot#index.cfm?fusebox=admin&fuseaction=dsp_UserCreate&#session.urltoken#';"><i class="fa fa-plus"></i> Create User</button></cfoutput>
            <br><br><br>
            <table id="tblUser" width="100%" class="table table-striped table-bordered">
               <thead>
                  <tr>
                     <th style="width: 20px">No.</th>
                     <th>Name</th>
                     <th style="width: 70px">Date of Birth</th>
                     <th style="width: 70px">Gender</th>
                     <th style="width: 90px">Email</th>
                     <th style="width: 90px">Role</th>
                     <th style="width: 50px">Action</th>
                  </tr>
               </thead>

               <cfset i = 0>
               <cfoutput>
                  <cfloop query="userList">
                  <cfset i = i + 1>   
                     <tbody>
                        <tr>
                           <td>#i#</td>
                           <td>#userList.vaUSName#</td>
                           <td>#DateTimeFormat(userList.dtDATEBIRTH, "dd-mm-yyyy")#</td>
                           <td>#userList.vaGender#</td>
                           <td>#userList.vaEMAIL#</td>
                           <td>#userList.vaROLENAME#</td>
                           <td><a href="#request.webroot#index.cfm?fusebox=admin&fuseaction=dsp_UserProfile&profileId=#userList.iPROFILEID#&#session.urltoken#" type="button"><i class="fa fa-info-circle"></i> Details</a></td>
                        </tr>
                     </tbody>
                  </cfloop>
               </cfoutput>
            </table>
         </div>
      </div>
   </div>
</body>

<script>
      $(document).ready(function() {
          $('#tblUser').DataTable();
      } );    
   </script>