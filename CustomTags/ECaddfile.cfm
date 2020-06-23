<!--- 
Checks for the script to use in the application.
Parameters: FNAME: Logical name of the application (required)
NOGEN: Do not generate SCRIPT element
PATH: Logical path name
Return Values : RESULT: Filename
--->
<CFPARAM NAME=Attributes.grp Default="MIC">
<CFPARAM NAME=Attributes.NoGen Default=0>

<CFSET Ret=Request.DS.FN.SVCSvrFileInclude("MIC",Attributes.FName,Attributes.NoGen)>
<!--- <cfdump var="#ret#" abort> --->
<CFIF Ret.NoGen IS 0><CFOUTPUT>#RET.HTMSTR#</CFOUTPUT></CFIF>
<CFSET Caller.Result=Ret.PATH>
