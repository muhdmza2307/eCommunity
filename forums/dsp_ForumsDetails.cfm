<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

<cfparam name="attributes.iforumsId" default = 0>

<cfquery name="forumsDetails" datasource="#request.MTRDSN#">
      SELECT a.iFORUMSID, a.vaFORUMSTITLE, a.vaFORUMSBODY, a.dtDATECREATED, b.vaUSName
      FROM FRM0001 a WITH (NOLOCK)
      INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iCREATEDBY
      WHERE iFORUMSID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iforumsId#">
   </cfquery>
   <cfquery name="fComments" datasource="#request.MTRDSN#">
      SELECT a.vaCOMMENTBODY, a.dtDATECREATED, b.vaUSName
      FROM CMT_FORUM0001 a WITH (NOLOCK)
      INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iCREATEDBY
      WHERE iFORUMSID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iforumsId#">
   </cfquery>

<body>  
  <cfoutput>
     <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="SUMMERNOTE_CSS">
      <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="SUMMERNOTE_JS">
  </cfoutput>
  
   <cfoutput query="forumsDetails">
      <div class="container">
         <div class="row">
            <div class="col-lg-12">
               <button style="margin-top: 1.5rem !important;" class="btn btn-danger" type="button" onclick="history.back(-1)"><i class="fa fa-undo" aria-hidden="true"></i> Back</button>
               <h1 class="mt-4">#forumsDetails.vaFORUMSTITLE#</h1>
               <p class="lead">
                  Posted by
                  <b>#forumsDetails.vaUSName#</b>
                  <span class="badge badge-info">#DateTimeFormat(forumsDetails.dtDATECREATED, "mmmm dd, yyyy")# at #DateTimeFormat(forumsDetails.dtDATECREATED,"HH:nn tt")#</span>
               </p>
               <hr>
               #forumsDetails.vaFORUMSBODY#
               </cfoutput>

               <cfoutput>
                  <div class="card my-4">
                     <h5 class="card-header">Leave a Comment:</h5>
                     <div class="card-body">
                        <form name="addForm" action="#request.logpath#index.cfm?fusebox=forums&fuseaction=act_newComment&#session.urltoken#" method ="POST" enctype="multipart/form-data">
                           <div class="form-group">
                              <textarea name="txtComment" id="txtComment" class="form-control" rows="3" chkrequired chklbl="Comment"></textarea>
                           </div>
                           <input type="hidden" name="forumsId" id="forumsId" value="#forumsDetails.iFORUMSID#">
                           <button type="submit" class="btn btn-primary" style="float: right" onclick="SubmitForm()">Post</button>
                        </form>
                     </div>
                  </div>
               </cfoutput>

               <cfoutput query="fComments">
                  <div class="media mb-4">
                     <div class="media-body">
                        <p class="lead">
                           Commented by
                           <b>#fComments.vaUSName#</b> 
                           <span class="badge badge-info">#DateTimeFormat(fComments.dtDATECREATED, "mmmm dd, yyyy")# at #DateTimeFormat(fComments.dtDATECREATED,"HH:nn tt")#</span><hr>
                        </p>
                        #fComments.vaCOMMENTBODY#
                     </div>
                  </div>  
               </cfoutput> 

               
            </div>
         </div>
      </div>
   
</body>
<script type="text/javascript">
   $(document).ready(function() {
     $('#txtComment').summernote({
       height: 100,                
       minHeight: null,            
       maxHeight: null,
       toolbar: [    
         ['style', ['bold', 'italic', 'underline', 'clear']],
         ['font', ['strikethrough', 'superscript', 'subscript']],
         ['fontsize', ['fontsize']],
         ['color', ['color']],
         ['para', ['ul', 'ol', 'paragraph']],
         ['height', ['height']]
       ],
     });
   }); 
   
</script>