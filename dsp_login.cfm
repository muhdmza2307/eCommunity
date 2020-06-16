<cfif IsDefined("URL.retryId")>
  <cfset retryId="#URL.retryId#">
<cfelse>
	<cfset retryId = 0>
</cfif>

<cfset currenttime="#DateFormat(now(),'mm/dd/yyyy')# #TimeFormat(now(),'HH:mm:ss')#">
<cfset nonce=ToBase64(currenttime&Hash(currenttime&"boo$ga56"))><!--- that is our private key --->

<body>
<cfoutput>
      <script language="JavaScript" type="text/javascript" src="#request.LOGPATH#services/scripts/unencoded/SVCLogin.js"></script>
</cfoutput>


   <main class="login-form">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">Sign In</div>
                    <div class="card-body">
                        <form onsubmit="JSVCLoginSubmit(this,'fusebox=MICsec&fuseaction=act_login')" method="post">
                           <div id="alert" align="center">
                              <b>Please enter your Username and Password.</b>
                           </div><br>
                            <div class="form-group row">
                                <label for="txtUserName" class="col-md-4 col-form-label text-md-right">Username</label>
                                <div class="col-md-6">
                                    <input type="text" id="txtUserName" class="form-control" name="txtUserName" autofocus>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="txtPassword" class="col-md-4 col-form-label text-md-right">Password</label>
                                <div class="col-md-6">
                                    <input type="password" id="txtPassword" class="form-control" name="txtPassword">
                                </div>
                            </div>

                            <input type="hidden" id='Nonce' name='Nonce'>
                            <input type="hidden" id='hpwd' name='hpwd'>
                            <input type="hidden" id='cpwd' name='cpwd'>

                            <div class="col-md-6 offset-md-4">
                                <button type="submit" class="btn btn-primary"><i class="fa fa-key"></i> Sign In
                                </button>
                            </div>
                    </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    </div>

</main>

<cfoutput>
    <script>
      JSVCDoLogin('#nonce#','#retryId#');
    </script>
</cfoutput>

</body>
    

          
