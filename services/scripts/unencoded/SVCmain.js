function SVChtm(txt,typ,relist,reresult)
{	if(typeof(txt)!="string")return null;
	txt=txt.replace(/&/g,"&amp;").replace(/\"/g,"&quot;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
	if(typ==2){
		if(txt.substring(txt.length-2,txt.length)=="\n ")
			txt=txt.substring(0,txt.length-2)+"<br>&nbsp;";
		txt=txt.replace(/\n/g,"<br>");
		if(relist!=null&&reresult!=null)
		for(var t in relist)
			txt=txt.replace(relist[t],reresult[t]);
	}
	return txt;
}

function baseUrl() {
    var href = window.location.href.split('/');
    return href[0]+'//'+href[2]+'/';
 }

function SubmitForm(){
    var doc;
    var a;
    
    doc = document.addForm;
    
    if(VerifyForm(doc)){
        doc.submit();
    }       
}

function VerifyForm(form){
    var column, i, obj;
    column = form.elements;
    
     if(column != null){
        for(i=0; i<column.length; i++){
            obj = column[i];
            var ver=obj.getAttribute("chkrequired");
            var str=obj.getAttribute("chklbl");
		    var val=obj.value;

		    if (ver != null){
		    	if (ver != ""){
		    		try{
		    			if (val == "") {
					        if (!VerifyObj(obj, str))
					            return false;
					    }
		    		}
		    		catch(e){

		    		}
		    	}
		    	else{
		    		try{
		    			if (val == "") {
					        if (!VerifyObj(obj, str)) 
					            return false;				        
					    }
		    		}
		    		catch(e){

		    		}
		    	}
		    }


        }
    }
    return true; 
}

function VerifyObj(obj, str){
    var msg = str + " should be specified.";
    var title = "Alert";
    
    SVCpopalert(obj, msg, title);
}

function SVCpopalert(obj, msg, title){

	var inpt = obj.name;

	$('#modalTitle').empty();
	$('#modalBody').empty();

    $("#modalTitle").append(title);
    $("#modalBody").append(msg);
    $("#myModal").modal("show");

    $('[name =' + inpt + ']').focus(); 


}

