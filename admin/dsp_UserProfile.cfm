<cfparam name="attributes.profileId" default = 0>

<body>

   <cfquery name="userDetail" datasource="#request.MTRDSN#">
      SELECT  a.iPROFILEID, a.iGENDER,
      a.dtDATEBIRTH, a.dtDATECREATED, a.vaEMAIL, b.vaUSName, b.iROLEID
      FROM USR_PROF0001 a WITH (NOLOCK)
      INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iUSID
      WHERE iPROFILEID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.profileId#">
   </cfquery>

   <cfquery name="roleList" datasource="#request.MTRDSN#">
      SELECT iROLEID, vaROLENAME 
      FROM ROL0001 WITH (NOLOCK)
      ORDER BY iROLEID ASC
   </cfquery>

   <!--- <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script> --->
   <script src="https://unpkg.com/gijgo@1.9.13/js/gijgo.min.js" type="text/javascript"></script>
    <link href="https://unpkg.com/gijgo@1.9.13/css/gijgo.min.css" rel="stylesheet" type="text/css" />


   <div class="body-content">
      <div class="container">
         <main class="create-form">
            <div class="container">
               <div class="row justify-content-center">
                  <div class="col-md-8">
                     <div class="card">
                        <div class="card-header">User Profile</div>
                        <div class="card-body">
                           <cfoutput query="userDetail">
                              <form name="addForm" action="#request.logpath#index.cfm?fusebox=admin&fuseaction=act_editUserProfile&#session.urltoken#" method ="POST" enctype="multipart/form-data">   
                           
                                                     
                                 <div class="form-group row">
                                    <label for="txt_Username" class="col-md-4 col-form-label text-md-right">Username</label>
                                    <div class="col-md-6">
                                       <input type="text" name="txt_Username" id="txt_Username" class="form-control" value="#userDetail.vaUSName#" disabled="true">
                                    </div>
                                 </div>

                                 <div class="form-group row">
                                    <label for="txt_Dob" class="col-md-4 col-form-label text-md-right">Date of Birth</label>
                                    <div class="col-md-6">
                                      <input type="text" name="txt_Dob" id="txt_Dob" class="form-control" value="#DateTimeFormat(userDetail.dtDATEBIRTH, "dd/mm/yyyy")#">
                                    </div>
                                 </div>

                                 <div class="form-group row">
                                    <label for="txt_Gender" class="col-md-4 col-form-label text-md-right">Gender</label>
                                    <div class="col-md-6">
                                       <cfset genderVal = "#userDetail.iGENDER#">
                                       <select name="txt_Gender" id="txt_Gender" class="form-control">
                                             <option value="0">Male</option>
                                             <option value="1">Female</option>
                                       </select>
                                    </div>
                                 </div>

                                 <div class="form-group row">
                                    <label for="txt_Email" class="col-md-4 col-form-label text-md-right">Email</label>
                                    <div class="col-md-6">
                                       <input type="email" name="txt_Email" id="txt_Email" class="form-control" value="#userDetail.vaEMAIL#">
                                    </div>
                                 </div>

                                 <div class="form-group row">
                                    <label for="txt_RoleId" class="col-md-4 col-form-label text-md-right">User Type</label>
                                    <div class="col-md-6">
                                       <cfset roleVal = "#userDetail.iROLEID#">
                                       <select name="txt_RoleId" id="txt_RoleId" class="form-control"disabled="true">
                                          <cfloop query="roleList">
                                             <option value=#roleList.iROLEID#>#roleList.vaROLENAME#</option>
                                          </cfloop>
                                       </select>
                                    </div>
                                 </div>

                                 <input type="hidden" id="txt_profileId" name="txt_profileId" value="#attributes.profileId#">

                                 <div class="col-md-6 offset-md-4">
                                    <button type="submit" class="btn btn-primary">Submit</button>
                                 </div>
                              </form>
                              </cfoutput>
                           
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </main>
      </div>
   </div>
</body>

<cfoutput>
   <script>

        today = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());

        $('##txt_Dob').datepicker(
            {
                uiLibrary: 'bootstrap4',
                format: 'dd/mm/yyyy',
                maxDate: today
            }
        );

        $(function() {
             $('##txt_Gender').val(#genderVal#);
         });

        $(function() {
             $('##txt_RoleId').val(#roleVal#);
         });

    </script>
 </cfoutput>