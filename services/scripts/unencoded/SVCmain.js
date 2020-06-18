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

            if(obj.name == 'txt_NewPass'){
            	if( $('#alert').html() != ""){
            		obj.value = '';
            	}
            }

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

// change password

function updateStrengthMeter() {
  const passwordInput = document.getElementById('txt_NewPass')
  const reasonsContainer = document.getElementById('alert')
  const weaknesses = calculatePasswordStrength(passwordInput.value)

  let strength = 100
  reasonsContainer.innerHTML = ''
  weaknesses.forEach(weakness => {
    console.log(weakness);
    if (weakness == null){
      return
    } 
    const messageElement = document.createElement("div")
    messageElement.innerHTML = weakness.message
    reasonsContainer.appendChild(messageElement)
  })
}

function calculatePasswordStrength(password) {
  const weaknesses = []
  weaknesses.push(lengthWeakness(password))
  weaknesses.push(lowercaseWeakness(password))
  weaknesses.push(uppercaseWeakness(password))
  weaknesses.push(numberWeakness(password))
  weaknesses.push(specialCharactersWeakness(password))
  return weaknesses
}

function lengthWeakness(password) {
  const length = password.length

  if (length <= 5) {
    return {
      message: "<b style='color:red !important'>New password need atleast 6 characters</b><br>",
    }
  }
}

function uppercaseWeakness(password) {
  return characterTypeWeakness(password, /[A-Z]/g, 'uppercase character')

}

function lowercaseWeakness(password) {
  return characterTypeWeakness(password, /[a-z]/g, 'lowercase character')
}

function numberWeakness(password) {
  return characterTypeWeakness(password, /[0-9]/g, 'number')
}

function specialCharactersWeakness(password) {
  return characterTypeWeakness(password, /[^0-9a-zA-Z\s]/g, 'special character')
}

function characterTypeWeakness(password, regex, type) {
  const matches = password.match(regex) || []

  if (matches.length === 0) {
    return {
      message: "<b style='color:red !important'>New password need atleast one " + type  + "</b><br>",
    }
  }

}

