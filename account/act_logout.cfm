<cfstoredproc procedure="sspUserLogout" datasource="#request.MTRDSN#" returncode=yes>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_USID value="#session.vars.userId#">  
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO LOGOUT: (#returncode#)">
    </cfif>

<cflock SCOPE="Session" Type="Exclusive" TimeOut=60>
	<cfscript>StructClear(session.vars);</cfscript>
</cflock>

<cflocation url="#request.logpath#index.cfm" addtoken="false"> 





