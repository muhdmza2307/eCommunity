<!--- process param --->
<cfparam name="form.txt_Username" type="string" default = "">
<cfparam name="form.txt_RoleId" type="integer" default = 0>


<!--- save into db --->
<cfstoredproc procedure="sspAddUser" datasource="#request.MTRDSN#" returncode=yes>
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_USName value="#form.txt_Username#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_ROLEID value="#form.txt_RoleId#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_CREATEDBY value="#session.vars.UserId#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=out dbvarname=@ai_PROFILEID variable="profileId">
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO CREATE NEW USER: (#returncode#)">
    </cfif>

 <cflocation url="#request.logpath#index.cfm?fusebox=admin&fuseaction=dsp_UserProfile&profileId=#profileId#">
