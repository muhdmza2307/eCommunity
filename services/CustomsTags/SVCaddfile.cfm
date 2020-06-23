<!--- 
Checks for the script to use in the application.
Parameters: FNAME: Logical name of the application (required)
NOGEN: Do not generate SCRIPT element
PATH: Logical path name
Return Values : RESULT: Filename
MEDIA : CSS media parameter
--->
<CFPARAM NAME=Attributes.NoGen Default=0>
<CFPARAM NAME=Attributes.MEDIA Default="">
<cfdump var="#Request#" abort>
<CFSET Ret=Request.DS.FN.SVCSvrFileInclude("SVC",Attributes.FName,Attributes.NoGen,Attributes.Media)>
<cfdump var="#Ret#">
<CFIF Ret.NoGen IS 0><CFOUTPUT>#RET.HTMSTR#</CFOUTPUT></CFIF>
<CFSET Caller.Result=Ret.PATH>