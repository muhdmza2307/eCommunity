<!---
FILENAME : Merimen_ic21/root/dsp_error.cfm
DESCRIPTION :
Error processing page for IC21.
   
INPUT/ATTR:
ERROR structure from Cold Fusion Server.

OUTPUT : None.

CREATED BY : Kian Yee
CREATED ON : 22 Oct 2008

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
Kian Yee	23/03/2009	Branch out for different site
Andrew		21/07/2010	Updated to services
--->
<cfset HOMEURL="#Request.Webroot#index.cfm?fusebox=MICroot&fuseaction=dsp_login">	
<CFIF IsDefined("Attributes.TRAIN")>
	<CFSET HOMEURL&="&train=1">
</cfif>

<CFIF IsDefined("Attributes.LF") and Attributes.LF neq "" 
		OR (StructKeyExists(Session,"vars") and StructKeyExists(session.vars,"orgtype") and session.vars.orgType eq "C" and StructKeyExists(session.vars,"subcotypeid") and session.vars.subcotypeid eq 4 and StructKeyExists(Session.vars,"INSCOID"))>
		
	<cfif not IsDefined("Attributes.LF") and structKeyExists(Request.ds.co,session.vars.inscoid)>
		<cfset Attributes.LF = REQUEST.DS.CO[session.vars.inscoid].cologicname>
	</cfif>
	
	<CFSET HOMEURL&="&lf=#UrlEncodedFormat(Request.DS.FN.SVCSanitizeInput(attributes.LF,'JS-NQ'))#">
	<cfset HOMEURL=Request.DS.FN.SVCGetLoginURLCustom(application.appmode,attributes.LF,HOMEURL)>
</cfif>

<CFSET ErrorStruct=StructNew()>
<CFSET StructAppend(ErrorStruct,Error,True)>
<!--- Send it through the MICCore error definition first --->
<cfmodule TEMPLATE="#request.logpath#index.cfm" FUSEBOX=MICroot FUSEACTION=dsp_errordefine ERRORSTRUCT=#ErrorStruct#>
<CFIF ErrorStruct.ErrHandled IS 0>
	<!--- If unhandled, send it through the services one --->
	<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCroot FUSEACTION=dsp_errordefine ERRORSTRUCT=#ErrorStruct#>
</CFIF>
<!--- Process, log and display errorstruct --->
<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCroot FUSEACTION=dsp_errorhandler ERRORSTRUCT=#ErrorStruct# ErrorDisplay=#(application.appdevmode eq 1?1:2)# ErrorNoLogin=1 HomeURL=#HomeURL#>