<cfparam name="Attributes.Username" default="">
<cfparam name="Attributes.PMD5" default="">
<cfparam name="Attributes.nonce" default="">
<cfparam name="Attributes.hpwd" default="">
<cfparam name="Attributes.cpwd" default="">


<cfset username=Replace(Attributes.Username," ","","ALL")>

<cfstoredproc PROCEDURE="sspUserLogin" DATASOURCE="#request.MTRDSN#" RETURNCODE="YES">
    <cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="#username#" DBVARNAME=@as_USName>
    <cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="#Attributes.cpwd#" DBVARNAME=@as_USPwd>
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=out dbvarname=@ai_USID variable="userId">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=out dbvarname=@ai_PROFILEID variable="profileId">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=out dbvarname=@ai_ROLEID variable="roleid">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=out dbvarname=@as_usrName variable="user_Name">
</cfstoredproc>

<cfset ResultCode=CFSTOREDPROC.STATUSCODE>


<cfif ResultCode IS -1>
	<cfset HLOC="index.cfm?fusebox=MICroot&fuseaction=dsp_login">
    <cflocation URL="#request.webroot##HLOC#&retryid=1&skip_browsertest=1&USERID=#URLEncodedFormat(username)#" ADDTOKEN="yes">
<cfelseif ResultCode IS -3>
    <cfset HLOC="index.cfm?fusebox=Account&fuseaction=dsp_changePassword&userid=#userId#&username=#user_Name#">
    <cflocation URL="#request.webroot##HLOC#&#Request.MToken#" ADDTOKEN="yes">
 <cfelse>
	<cflock scope="SESSION" type="exclusive" timeout="60">
        <CFSET SESSION.VARS=StructNew()>
        <cfset structInsert(SESSION.VARS, "UserId", userId, true)>
        <cfset structInsert(SESSION.VARS, "profileId", profileId, true)>
        <cfset structInsert(SESSION.VARS, "RoleId", roleid, true)>
        <cfset structInsert(SESSION.VARS, "Username", user_Name, true)>
    </cflock>

 	<cfset HLOC="index.cfm?fusebox=MICroot&fuseaction=dsp_home">
    <cflocation URL="#request.webroot##HLOC#&#Request.MToken#" ADDTOKEN="yes">
    
</cfif> 
