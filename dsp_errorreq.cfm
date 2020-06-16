<blockquote style="border:10px solid;background-color:red;color:white;text-align:center;font-weight:bold">
We're sorry, an error has occured and we could not log the error. Please print the diagnostic messages below
<br> and inform support.portal@merimen.com about it. We will attend to it as soon as we can.
<br>&nbsp;<br>Date and Time the Error Occurred : <cfoutput>#ERROR.DateTime#</cfoutput>
<br>&nbsp;<br>URL where Error Occured: <script>document.write(document.location)</script>
</blockquote>

<cflog type="Error" 
        file="myapp_errors" 
        text="Exception error --  
            Exception type: #error.type# 
            Template: #error.template#, 
            Remote Address: #error.remoteAddress#,  
            HTTP Reference: #error.HTTPReferer# 
            Diagnostics: #error.diagnostics#"> 