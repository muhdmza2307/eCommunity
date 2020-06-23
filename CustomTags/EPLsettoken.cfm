<cfsilent>
<CFPARAM NAME=Attributes.URLPREFIX DEFAULT="">

<cfif CGI.HTTPS EQ "ON">
	<cfset SSLflag="yes">
<cfelse>
	<cfset SSLflag="no">
</cfif>


<cfif IsDefined("Attributes.ClearSession")>
	<cfset MURLTOKEN=""><cfset BASICTOKEN="">
	<cfcookie NAME=MACID EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	<CFIF IsDefined("SESSION.CFID")>
		<cfcookie NAME=CFID VALUE="#SESSION.CFID#" EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
		<cfcookie NAME=CFTOKEN VALUE="#SESSION.CFTOKEN#" EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	<CFELSEIF IsDefined("SESSION.JSESSIONID")>
		<cfcookie NAME=JSESSIONID VALUE="#SESSION.JSESSIONID#" EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	<CFELSE>
		<cfcookie NAME=CFID EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
		<cfcookie NAME=CFTOKEN EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
		<cfcookie NAME=JSESSIONID EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	</CFIF>
<cfelse>
	<cfif Request.inSession IS 1>
	 	<CFIF NOT IsDefined("SESSION.VARS.COOKIESESSION")>
			<CFSET BASICTOKEN=SESSION.URLToken><CFSET MURLTOKEN=BASICTOKEN>
		<CFELSE>
			<CFSET BASICTOKEN=""><CFSET MURLTOKEN="">
		</CFIF>
		<cfif IsDefined("SESSION.VARS.LOCID")>
			<cfset request.LOCID=SESSION.VARS.LOCID><cfset MURLTOKEN=ListAppend(MURLTOKEN,"USID=#SESSION.VARS.USID#&RID=#RandRange(1000000,9999999)#","&")>
			<CFIF IsDefined("SESSION.VARS.ORGTYPE") and SESSION.VARS.ORGTYPE IS "D" AND StructKeyExists(URL,"LOCID") AND URL.LOCID IS NOT ""><cfset MURLTOKEN=ListAppend(MURLTOKEN,"LOCID=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(URL.LOCID))#","&")></cfif>
		</cfif>
	<cfelseif IsDefined("SESSION.VARS.USIDCHG") and Request.inSession eq 0 and IsDefined("SESSION.URLTOKEN") AND NOT IsDefined("SESSION.VARS.COOKIESESSION")>
		<CFSET BASICTOKEN=SESSION.URLToken><CFSET MURLTOKEN=BASICTOKEN>
	<cfelse>
		<CFSET BASICTOKEN=""><CFSET MURLTOKEN="">
</cfif>
	<cfif IsDefined("URL.NOLAYOUT")><cfset MURLTOKEN= ListAppend(MURLTOKEN,"NOLAYOUT=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(URL.NOLAYOUT,'JS-NQ'))#","&")>
	</cfif>
	<cfif IsDefined("URL.BR") AND URL.BR IS NOT ""><cfset MURLTOKEN= ListAppend(MURLTOKEN,"BR=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(URL.BR,'JS-NQ'))#","&")>
	</cfif>
	<cfif IsDefined("URL.CT") AND URL.CT IS NOT ""><cfset MURLTOKEN= ListAppend(MURLTOKEN,"CT=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(URL.CT,'JS-NQ'))#","&")>
	</cfif>
	<cfif IsDefined("URL.LF") AND URL.LF IS NOT ""><cfset MURLTOKEN= ListAppend(MURLTOKEN,"LF=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(URL.LF,'JS-NQ'))#","&")>
	</cfif>
	<!--- <cfdump var="#request.ds#" abort> --->
	<cfif Request.DS.FN.SVCGetResp() and isdefined('URL.MOBILE')><cfset MURLTOKEN=ListAppend(MURLTOKEN,"MOBILE=#Request.DS.FN.SVCSanitizeInput(URL.MOBILE,'JS-NQ')#","&")>
	</cfif>
</cfif>

<cfif IsDefined("ATTRIBUTES.SETNEXTLOC")>
	<cfinclude TEMPLATE="FORMATURL.cfm"><cfset MURLTOKEN=ListAppend(MURLTOKEN,"nextloc=#result#","&")>
<cfelseif IsDefined("URL.NEXTLOC") AND Not IsDefined("Attributes.NoNextLoc")>
	<cfset MURLTOKEN=ListAppend(MURLTOKEN,"nextloc=#URLEncodedFormat(URL.NextLoc)#","&")>
</cfif>

<cfif Len(Application.ApplicationName) GT 6 AND Right(Application.ApplicationName,6) IS "_train"><cfset MURLTOKEN= ListAppend(MURLTOKEN,"train=1","&")></cfif>

<CFSET curlogpath = Application.LOGPATH>
<CFSET curapppath = Application.APPPATH>

<cfset request.mtoken=murltoken>
<cfset Request.MICTOKEN = murltoken>


<cfset request.newUI=false>
<cfif StructKeyExists(SESSION, "SSO_UID")>
	<cfset request.newUI=true>
</cfif>

<cfset request.MTRDSN=Application.MTRDSN>
<cfset request.logpath= Application.CFPREFIX & curlogpath>
<cfset request.apppath= Application.CFPREFIX & curapppath>

<cfset request.apppathcfc= Application.APPPATHcfc>

<cfif (Request.InSession AND StructKeyExists(SESSION.VARS,"HTTPS") AND SESSION.VARS.HTTPS IS 1) OR <!--- For clients requiring HTTPS for all sessions --->
		(Request.InSession IS 0 AND CGI.SERVER_PORT_SECURE IS 1) OR <!--- For https to be enforced before you are logged on.  --->
			StructKeyExists(URL,"SECURED") OR <!--- for going to the next https page --->
				(StructKeyExists(URL,"LF") AND StructKeyExists(REQUEST.DS,"ENFORCESSL") AND listfindnocase(REQUEST.DS.ENFORCESSL,URL.LF) gt 0) <!--- Based on URL.LF for dsp_login page --->
					>
	<CFIF CGI.SERVER_PORT_SECURE IS NOT 1>
		<CFLOCATION url="https://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#" addtoken=no>
	</CFIF>
<cfelse>
	<CFIF CGI.SERVER_PORT_SECURE IS 1>
		<CFLOCATION url="http://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#" addtoken=no>
	</CFIF>
</cfif>

<cfset REQUEST.WEBROOT=Attributes.URLPREFIX&curlogpath>
<cfset REQUEST.APPROOT=Attributes.URLPREFIX&curapppath>
<!---cfset REQUEST.SVCROOT=Attributes.URLPREFIX&cursvcpath>
<cfset REQUEST.MICROOT=Attributes.URLPREFIX&curmicpath--->
<!--- <cfset request.MTRROOT=Attributes.URLPREFIX&curmtrpath> --->
</cfsilent>


<cfif Not IsDefined("Attributes.NoScript")>
<script><CFOUTPUT>
var request=new Object();
request.webroot="#Request.Webroot#";
<!---request.microot="#request.approot#MInsCore/";--->
request.approot="#request.approot#";
<!--- request.mtrroot="#request.mtrroot#"; --->
request.mtoken="#Request.MToken#";
<!--- request.ssoroot="#request.ssopath#"; --->
request.apptmz=<cfif StructKeyExists(Application,"SERVERTIMEZONE") AND IsNumeric(Application.SERVERTIMEZONE)>#Application.SERVERTIMEZONE#<cfelse>8.0</cfif>;
</CFOUTPUT></script>
</cfif>


<cfset MODULESARR=arrayNew(1)>
<!--- TODO : @@REMARKS@@ Need module management for EPL even though IC21 doesn't need it.--->
<!--- @@REMARKS@@ Please take note.
      This page is 'hit' every time you load a page. Might want to move it to act_setloginsession.cfm.
      Moving it to act_login where IC21's MODULES is set will cause impersonatino from error page to break.
--->
<CFIF IsDefined("SESSION.VARS.MODULES")>
	<cflock SCOPE="Session" Type="Exclusive" TimeOut="60"><!--- Override the modules setting from act_login --->
		<CFIF Session.vars.COTYPEID IS 4>
			<!---CFSET StructInsert(SESSION.VARS,"MODULES","1,4")--->
			<cfset tmp=arrayAppend(MODULESARR,1)>
			<cfset tmp=arrayAppend(MODULESARR,4)>
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="16R"> <!--- suppose to be 16 --->
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,9)></cfif>
			<CFSET SESSION.VARS.MODULES = ArrayToList(MODULESARR,",")>

		<CFELSEIF Session.vars.COTYPEID IS 2>
			<!--- Policy --->
			<cfif StructKeyExists( SESSION.VARS,"userid") AND listfindnocase("EDPLHK,EDPLJH",SESSION.VARS.userid) eq 0><!--- #15261 temp hardcode --->
			<cfset tmp=arrayAppend(MODULESARR,2)>
			</cfif>
			<!--- Create --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="413R,493R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,7)></cfif>
			<!--- Manual Renewal --->
			<cfmodule template="#request.apppath#MInsCore/CustomTags/MICGetCoEA.cfm" FIELDLOGICNAME="EPLMODULES" IOWNOBJID=#SESSION.VARS.GCOID#>
			<cfif isNumeric(q_EA.vaATTR) and bitAND(q_ea.vaATTR,4) gt 0>
				<cfset tmp=arrayAppend(MODULESARR,15)>
			</cfif>
			<!--- <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="427R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,15)></cfif> --->
			<!--- Claims #4472 - [ALL] Claim notification in Insurer module
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="417R,148R,420R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,3)></cfif>
			--->
			<!--- Customer --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="409R,405R,407R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,6)></cfif>
			<!--- Reinsurance --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="505R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,16)></cfif>
			<!--- Accounts --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="430R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,11)></cfif>
			<!--- Master Cover --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="465R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,17)></cfif>
			<!--- Reports --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="421R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,9)></cfif>
			<!--- Mail --->
			<cfif session.vars.maliaslist neq ""><cfset tmp=arrayAppend(MODULESARR,21)></cfif>
			<!--- User Profile --->
			<cfset tmp=arrayAppend(MODULESARR,12)>
			<!---<cfset tmp=arrayAppend(MODULESARR,13)>Comments & Rating --->
			<!--- Preferences
			<cfset tmp=arrayAppend(MODULESARR,99)>--->
			<!--- Admin --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="422R,482R,465R,601R,702R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,1)></cfif>
			<!--- SecureCode Verification --->
			<!--- KY : Moved to MIC.js instead --->
			<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="483R">
			<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,18)></cfif--->
			<!--- Help --->
			<cfset tmp=arrayAppend(MODULESARR,14)>
			<cfif SESSION.VARS.LOCID eq 1 and listfindnocase(SESSION.VARS.PRODCLSLIST,50) gt 0>
				<cfset tmp=arrayAppend(MODULESARR,25)>
			</cfif>
			<!--- Payment Group --->
			<cfmodule template="#request.apppath#MInsCore/CustomTags/MICGetCoEA.cfm" FIELDLOGICNAME="EPLMODULES" IOWNOBJID=#SESSION.VARS.GCOID#>
			<cfif isNumeric(q_EA.vaATTR) and bitAND(q_ea.vaATTR,2) gt 0>
				<cfset tmp=arrayAppend(MODULESARR,19)>
			</cfif>

			<cfif listfindnocase(SESSION.VARS.PRODCLSLIST,110) gt 0><!--- #22933--->
			<cfset tmp=arrayAppend(MODULESARR,22)><!---Plan module for group health--->
			<cfset tmp=arrayAppend(MODULESARR,23)><!---Group member maintainance module for group health--->
			<cfset tmp=arrayAppend(MODULESARR,26)><!---Quotation search--->
			<cfset tmp=arrayAppend(MODULESARR,27)><!---Billing/Invoice--->
			</cfif>
			<CFSET SESSION.VARS.MODULES = ArrayToList(MODULESARR,",")>
			<!---CFSET StructInsert(SESSION.VARS,"MODULES","5,7,2,3,6,11,9,1")
			<cfif session.vars.locid eq 1>
				<CFSET SESSION.VARS.MODULES = "2,15,6,9,12,13,14,16,20">
			<cfelse>
				<CFSET SESSION.VARS.MODULES = "2,6,9,12,13,16,14,20">
			</cfif>--->
		<CFELSEIF Session.vars.COTYPEID IS 6>

	       <!---  <cfif arrayLen(session.vars.plist) eq 2 and session.vars.plist[1] eq 421 and session.vars.plist[2] eq 428>

				<!--- Reports --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="421R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,9)></cfif>
				<!--- User Profile --->
				<cfset tmp=arrayAppend(MODULESARR,12)>
				<!--- Preferences <cfset tmp=arrayAppend(MODULESARR,99)>--->
				<!--- Admin --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="423R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,1)></cfif>
				<!--- Help --->
				<cfset tmp=arrayAppend(MODULESARR,14)>

				<CFSET SESSION.VARS.MODULES = ArrayToList(MODULESARR,",")>

			<cfelse> --->
				<!--- Policy --->
				<cfset tmp=arrayAppend(MODULESARR,2)>
				<!--- Create --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="413R,493R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,7)></cfif>
				<!--- Manual Renewal --->
				<cfmodule template="#request.apppath#MInsCore/CustomTags/MICGetCoEA.cfm" FIELDLOGICNAME="EPLMODULES" IOWNOBJID=#SESSION.VARS.INSCOID#><!--- Insurer Module --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="427R">
				<cfif CanRead eq 1 and isNumeric(q_EA.vaATTR) and bitAND(q_ea.vaATTR,4) gt 0>
					<cfset tmp=arrayAppend(MODULESARR,15)>
				</cfif>
				<!--- Customer --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="409R,405R,407R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,6)></cfif>
				<!--- Accounts --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="430R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,11)></cfif>
				<!--- Master Cover --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="465R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,17)></cfif>
				<!--- Reports --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="421R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,9)></cfif>
				<!--- Mail --->
				<cfif session.vars.maliaslist neq ""><cfset tmp=arrayAppend(MODULESARR,21)></cfif>
				<!--- User Profile --->
				<cfset tmp=arrayAppend(MODULESARR,12)>
				<!--- Preferences
				<cfset tmp=arrayAppend(MODULESARR,99)>--->
				<!--- Admin --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="423R,465R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,1)></cfif>
				<!--- Help --->
				<cfset tmp=arrayAppend(MODULESARR,14)>
				<!--- Payment Group --->
				<CFIF StructKeyExists(SESSION.VARS,"INSCOID") and SESSION.VARS.INSCOID neq "">
					<cfmodule template="#request.apppath#MInsCore/CustomTags/MICGetCoEA.cfm" FIELDLOGICNAME="EPLMODULES" IOWNOBJID=#REQUEST.DS.CO[SESSION.VARS.INSCOID].GCOID#>
					<cfif isNumeric(q_EA.vaATTR) and bitAND(q_ea.vaATTR,2) gt 0>
						<cfset tmp=arrayAppend(MODULESARR,19)>
					</cfif>
				</CFIF>

				<CFSET SESSION.VARS.MODULES = ArrayToList(MODULESARR,",")>
			<!--- </cfif> --->
			<!---CFSET StructInsert(SESSION.VARS,"MODULES","5,7,2,3,6,11,1")
			<!--- if got admin permission have to enable the admin panel liao --->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="423R"><!--- Admin Privy --->
			<cfif CanRead IS 1>
				<CFSET SESSION.VARS.MODULES = "2,15,6,9,12,1,14,20">
			<cfelse>
				<CFSET SESSION.VARS.MODULES = "2,15,6,9,12,14,20">
			</cfif>
			<cfif session.vars.locid neq 1>
				<cfset SESSION.VARS.MODULES=REREPLACENOCASE(SESSION.VARS.MODULES,",15","ONE")>
			</cfif>--->
		<CFELSEIF Session.vars.COTYPEID IS 14>
			<!---CFSET StructInsert(SESSION.VARS,"MODULES","10,7,2,3,11,8")--->
			<!---@REMARKS@:Due to time constraint marine customers use this list directly...since no other epolicy corporate client yet--->
			<cfif session.vars.subcotypeid eq 4>
				<CFSET SESSION.VARS.MODULES = "7">
			<cfelse>
				<!--- Policy --->
				<cfset tmp=arrayAppend(MODULESARR,2)>
				<!--- Create --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="413R,493R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,7)></cfif>
				<!---@REMARKS@@CORP@:Currently gcoid!=2 are corporate clients--->
				<cfif session.vars.gcoid neq 2>
					<CFIF listfindnocase(session.vars.PRODCLSLIST,70) gt 0>
						<cfset tmp=arrayAppend(MODULESARR,6)>
					</cfif>
				</cfif>
				<!--- Accounts --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="430R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,11)></cfif>
				<!--- Master Cover --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="465R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,17)></cfif>
				<cfif session.vars.gcoid neq 2>
					<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="421R">
					<cfset tmp=arrayAppend(MODULESARR,9)>
				</cfif>
				<!--- Mail --->
				<cfif session.vars.maliaslist neq ""><cfset tmp=arrayAppend(MODULESARR,21)></cfif>
				<!--- User Profile --->

				<CFIF session.vars.gcoid eq 2>
					<cfset tmp=arrayAppend(MODULESARR,18)>
				<cfelse>
					<cfset tmp=arrayAppend(MODULESARR,12)>
				</cfif>
				<!--- Admin --->
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="465R">
				<cfif CanRead eq 1><cfset tmp=arrayAppend(MODULESARR,1)></cfif>
				<!--- Help --->
				<cfset tmp=arrayAppend(MODULESARR,14)>

				<CFSET SESSION.VARS.MODULES = ArrayToList(MODULESARR,",")>
			</cfif>
		</CFIF>
	</cflock>
	<!--- EPOLICY ONLY HAS GROUPWIDE FOR PRODUCT DOMAIN --->
	<CFSET SESSION.VARS.GRPDOMLIST = "203">
</CFIF>
