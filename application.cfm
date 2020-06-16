
<cfif structKeyExists(URL,"mobile") and listfindnocase("1,2",URL.mobile) gt 0>
	<!DOCTYPE html>
</cfif>
<!-- Copyright 2000-2006. All rights reserved -->
<cfif NOT findNoCase("/index.cfm", cgi.script_name)>
	<cfif IsDefined("url.CFID")>
		<CFLOCATION URL="index.cfm?CFID=#url.CFID#&CFTOKEN=#url.CFTOKEN#&USID=#url.USID#&RID=#RandRange(1000000,9999999)#" ADDTOKEN="no">
	<cfelse>
		<CFLOCATION url="index.cfm" ADDTOKEN="no">
	</cfif>
</cfif>
<cfinclude TEMPLATE="app_globals.cfm">