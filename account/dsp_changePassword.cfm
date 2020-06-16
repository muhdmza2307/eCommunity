<cfparam name="attributes.userid" DEFAULT=0>
<cfparam name="attributes.username" DEFAULT="">

<body>
   <div class="body-content">
      <div class="container">
         <main class="create-form">
            <div class="container">

               <div class="row justify-content-center">                
                  <div class="col-md-8">
                     <div class="alert alert-danger" role="alert">
                       You must <b>update your password</b> because this is first time you've signed in.
                     </div>
                  </div>
               </div>

               <div class="row justify-content-center">                
                  <div class="col-md-8">
                     <div class="card">
                        <div class="card-header">Update Password</div>
                        <div class="card-body">
                           <cfoutput>
                              <form name="addForm" action="#request.logpath#index.cfm?fusebox=account&fuseaction=act_changePassword" method ="POST" enctype="multipart/form-data">   
                           
                                                     
                                 <div class="form-group row">
                                    <label for="txt_CurrentPass" class="col-md-4 col-form-label text-md-right">Current Password</label>
                                    <div class="col-md-6">
                                       <input type="password" name="txt_CurrentPass" id="txt_CurrentPass" class="form-control">
                                    </div>
                                 </div>

                                  <div class="form-group row">
                                    <label for="txt_NewPass" class="col-md-4 col-form-label text-md-right">New Password</label>
                                    <div class="col-md-6">
                                       <input type="password" name="txt_NewPass" id="txt_NewPass" class="form-control">
                                    </div>
                                 </div>

                                 <input type="hidden" id="txt_userId" name="txt_userId" value="#attributes.userid#">

                                 <input type="hidden" id="txt_Username" name="txt_Username" value="#attributes.username#">

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