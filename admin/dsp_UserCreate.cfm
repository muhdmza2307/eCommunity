<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

   <body>
   <cfquery name="roleList" datasource="#request.MTRDSN#">
      SELECT iROLEID, vaROLENAME 
      FROM ROL0001 WITH (NOLOCK)
      ORDER BY iROLEID ASC
   </cfquery>

   <div class="body-content">
      <div class="container">
         <main class="create-form">
            <div class="container">
               <div class="row justify-content-center">
                  <div class="col-md-8">
                     <div class="card">
                        <div class="card-header">Create User</div>
                        <div class="card-body">
                           <cfoutput>
                              <form name="addForm" action="#request.logpath#index.cfm?fusebox=admin&fuseaction=act_newUser&#session.urltoken#" method ="POST" enctype="multipart/form-data">   
                           </cfoutput>
                                                     
                                 <div class="form-group row">
                                    <label for="txt_Username" class="col-md-4 col-form-label text-md-right">Username</label>
                                    <div class="col-md-6">
                                       <input type="text" name="txt_Username" id="txt_Username" class="form-control" chkrequired chklbl="Username" autocomplete=off>
                                    </div>
                                 </div>

                                 <div class="form-group row">
                                    <label for="txt_RoleId" class="col-md-4 col-form-label text-md-right">Type</label>
                                    <div class="col-md-6">
                                       <select name="txt_RoleId" id="txt_RoleId" class="form-control">
                                          <cfoutput query="roleList">
                                             <option value=#roleList.iROLEID#>#roleList.vaROLENAME#</option>
                                          </cfoutput>
                                       </select>
                                    </div>
                                 </div>

                                 <div class="col-md-6 offset-md-4">
                                    <button type="button" class="btn btn-danger" onclick="history.back(-1)"><i class="fa fa-undo" aria-hidden="true"></i> Back</button>
                                    <button type="button" class="btn btn-primary" onclick="SubmitForm()"><i class="fa fa-check" aria-hidden="true"></i> Submit</button>
                                 </div>
                              </form>
                           
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </main>
      </div>
   </div>
</body>