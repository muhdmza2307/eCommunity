<link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.js"></script>

<body>
   <div class="body-content">
      <div class="container">
         <div style="text-align:center">
            <h2>Create News</h2>
         </div>
         <br><br>

         <cfoutput>
            <form name="addForm" action="#request.logpath#index.cfm?fusebox=news&fuseaction=act_newNews&#session.urltoken#" method ="POST" enctype="multipart/form-data">
               <div class="col-sm col-xs-12">
                  <div class="form-group">
                     <label for="txtNewsTitle">Title</label>
                     <input type="text" name="txtNewsTitle" id="txtNewsTitle" class="form-control" chkrequired chklbl="Title" autocomplete=off>
                  </div>

                  <div class="form-group">
                     <label for="txtNewsBody">Body Content :</label>
                     <textarea name="txtNewsBody" id="txtNewsBody" class="form-control" rows="3" chkrequired chklbl="Body Content"></textarea>
                  </div>

                  <div class="form-group">
                     <label for="txtNewsSource">Source :</label>
                     <input type="text" name="txtNewsSource" id="txtNewsSource" class="form-control" autocomplete=off>
                  </div>

                  <div class="form-group">
                     <label for="filePath">Image Upload :</label>
                     <input type="file" name="imgPath" id="imgPath" class="form-control-file"> 
                  </div>
                  <br>

                  <div class="form-group">
                     <div class="btn-group" style="float: right">
                        <button type="button" class="btn btn-danger" style="margin-right:0.5rem;" onclick="history.back(-1)"><i class="fa fa-undo"></i> Back</button>
                        <button type="button"class="btn btn-primary" id="btnPost" onclick="SubmitForm()"><i class="fa fa-share"></i> Post</button>
                     </div>
                  </div>

               </div>
               <input type="hidden" id="txtbodyCut" name="txtbodyCut">                              
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
            <div id="modalBody" class="modal-body"> </div>
            <div class="modal-footer">
               <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
            </div>
         </div>
      </div>
   </div>

</body>

<script type="text/javascript">

   $(document).ready(function() {
     $('#txtNewsBody').summernote({
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
          $('#txtbodyCut').val($($("#txtNewsBody").summernote("code")).text());
         }
       }
     });
   });
     
</script>