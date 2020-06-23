<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

<body>
  <cfoutput>
     <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="SUMMERNOTE_CSS">
      <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="SUMMERNOTE_JS">
  </cfoutput>
   <div class="body-content">
      <div class="container">
         <div style="text-align:center">
            <h2>Create Forums</h2>
         </div>
         <br><br>
         <cfoutput>
            <form name="addForm" action="#request.logpath#index.cfm?fusebox=forums&fuseaction=act_newForums&#session.urltoken#" method ="POST" enctype="multipart/form-data">
               <div class="col-sm col-xs-12">
                  <div class="form-group">
                     <label for="txtForumsTitle">Title</label>
                     <input type="text" name="txtForumsTitle" id="txtForumsTitle" class="form-control" chkrequired chklbl="Title" autocomplete=off>
                  </div>
                  <div class="form-group">
                     <label for="txtForumsBody">Body Content :</label>
                     <textarea  name="txtForumsBody" id="txtForumsBody" class="form-control" rows="3" chkrequired chklbl="Body Content"></textarea>
                  </div>
                  <br>
                  <div class="form-group">
                     <div class="btn-group" style="float: right">
                        <button type="button" class="btn btn-danger" style="margin-right:0.5rem;" onclick="history.back(-1)"><i class="fa fa-undo"></i> Back</button>
                        <button type="button" id="btnPost" class="btn btn-primary" onclick="SubmitForm()"><i class="fa fa-share"></i> Post</button>
                     </div>
                  </div>
                  <input type="hidden" name="txtbodyCut" id="txtbodyCut">                              
               </div>
            </form>
         </cfoutput>
      </div>
   </div>

   <div id="myModal" class="modal">
      <div class="modal-dialog">
         <div class="modal-content">
            <div class="modal-header">
               <h4 id="modalTitle" class="modal-title"></h4>
               <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div id="modalBody" class="modal-body">       
            </div>
            <div class="modal-footer">
               <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
            </div>
         </div>
      </div>
   </div>
</body>

<script type="text/javascript">

   $(document).ready(function() {
     $('#txtForumsBody').summernote({
       height: 200,                 
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
       callbacks: {
         onChange: function(contents, $editable) {
         $('#txtbodyCut').val($($("#txtForumsBody").summernote("code")).text());
         }
       }
     });
   });
   
</script>