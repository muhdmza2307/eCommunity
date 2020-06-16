<!---
FILENAME : CLAIMS/root/app_globals.cfm
DESCRIPTION :
Do steps that is required for every page request - if first call:
1) Sets the CFAPPLICATION name and CFERROR template.
2) If first time run:Calls MTRSETAPPVARS (which calls MTRSETENV) to create application DataStore.
3) Put DS refence into Request.DS variable.
4) Call SETTOKEN to set Request vars.
5) Process URL attrs into ATTRIBUTES.
6) Call PAGEAUDIT to audit
   
INPUT/ATTR: None

OUTPUT : None.

CREATED BY : Andrew
CREATED ON : 21 Mar 2003

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
--->
<cfif Not(StructKeyExists(Request,"MTRfirstcall"))>  <!--- check if first call (yes, go inside statement)--->
	<cfsilent>
		<cfif StructKeyExists(URL,"TRAIN")>
			<cfapplication NAME="merimen_eComm_train" ScriptProtect="ALL" CLIENTMANAGEMENT=No SETCLIENTCOOKIES=No SESSIONMANAGEMENT=Yes>
		<cfelse>
			<cfapplication NAME="merimen_eComm" ScriptProtect="ALL" CLIENTMANAGEMENT=No SETCLIENTCOOKIES=No SESSIONMANAGEMENT=Yes>
		</cfif>

		<cfset request.MTRfirstcall=0>

		<CFIF IsDefined("SESSION.VARS.USID")>
			<CFSET request.inSession=1>
			<cfif StructKeyExists(SESSION.VARS,"HTTPS") AND SESSION.VARS.HTTPS IS 1><!--- For clients requiring HTTPS for all sessions --->
				<CFIF CGI.HTTPS IS NOT "on">
					<CFLOCATION url="https://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#" addtoken=no>
				</CFIF>
			</cfif>		
		<CFELSE>
			<CFSET request.inSession=0>
		</CFIF>

		<cferror Type=Exception Exception=ANY TEMPLATE=dsp_error.cfm>
		<!--- Uncomment below to reset app vars --->
		<!---CFLOCK SCOPE=Application Type=Exclusive TimeOut=60>
			<CFSET Application.Setvars=0>
		</CFLOCK--->
		<!--- If first time run, then only create App. DS store --->
		<CFSET CheckSvrFileVersion=0>
		<cfif Not(StructKeyExists(Application,"SETVARS")) OR Application.SetVars IS 0>
			<cfinclude TEMPLATE="CustomTags\EPLSETAPPVARS.cfm">
			<CFSET CheckSvrFileVersion=1>
		</cfif>
		<!--- Each time DS refreshed, it will alternate DS1 and DS2 to prevent read corruption --->
		<cfif Application.CURDS IS 1>
			<cfset REQUEST.DS=Application.DS1>
		<cfelse>
			<cfset REQUEST.DS=Application.DS2>
		</cfif>
		<!--- Refresh functions? For debugging - otherwise will set in SETAPPVARS --->
		<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCcffunctions.cfm" DS=#Request.DS#--->
		</cfsilent><cfinclude TEMPLATE="CustomTags\EPLSETTOKEN.cfm"><cfsilent>
		<CFIF CheckSvrFileVersion IS 1>
			<CFSET Request.DS.FN.SVCSvrFileDSUpdate()>
		</CFIF>
		<cfmodule TEMPLATE="/services/CustomTags/SVCFORMURL2ATTRIBUTES.cfm" NOFORM=1>
		<!--- <CFSET Request.DS.FN.SVCpageAudit("",Application.MTRAUDDSN,true)> --->
		<!---cfmodule TEMPLATE="CustomTags\PAGEAUDIT.cfm" APPNAME="MTR"--->
	</cfsilent>
</cfif>
