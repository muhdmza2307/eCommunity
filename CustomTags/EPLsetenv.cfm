<cfsilent><!--- 
Generates application static variables that is specific to the deployment environment.
This tag is called exclusively from SETAPPVARS to set application variables.
Parameters: APPNAME: The name of the application (as in Application.ApplicationName)
--->
<!---cfmodule TEMPLATE="DISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#"--->
<cfparam NAME=Attributes.APPNAME DEFAULT="">
<cfif Attributes.APPNAME IS "">
	<cfset Attributes.APPNAME=Application.ApplicationName>
</cfif>

<CFSET APPINST="ECM-DEV">

<cfset CURAPPLICATION=StructNew()>
<cfif Len(Attributes.APPNAME) GT 6 AND Right(Attributes.APPNAME,6) IS "_train">
	<cfset CURAPPLICATION.MTRDSN="miniProject">
<CFELSE>
	<cfset CURAPPLICATION.MTRDSN="miniProject">
</CFIF>
<CFQUERY NAME=q_app DATASOURCE=#CURAPPLICATION.MTRDSN#>
SELECT * FROM SYS001 a WITH (NOLOCK) WHERE a.vaAPPINST='#APPINST#' AND a.siSTATUS=0
</CFQUERY>
<CFLOOP query=q_app><CFSET StructInsert(CURAPPLICATION,vaAPPVAR,vaAPPVALUE)></CFLOOP>
<CFSET CURAPPLICATION.APPINST = APPINST>
<CFIF StructKeyExists(CURAPPLICATION,"APPDEVMODE") AND CURAPPLICATION.APPDEVMODE IS 1>
	<CFSET CURAPPLICATION.APPFULLNAME=CURAPPLICATION.APPFULLNAME&" ("&SERVER.COLDFUSION.PRODUCTNAME&")">
</CFIF>

<cfset Caller.CURAPPLICATION=CURAPPLICATION></cfsilent>