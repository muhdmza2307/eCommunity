<cfparam name="form.txtForumsTitle" type="string" default = "">
<cfparam name="form.txtForumsBody" type="string" default = "">
<cfparam name="form.txtbodyCut" type="string" default = "">


<!--- save into db --->
<cfstoredproc procedure="sspAddForums" datasource="#request.MTRDSN#" returncode=yes>
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_FORUMSTITLE value="#form.txtForumsTitle#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_FORUMSBODY value="#form.txtForumsBody#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_FORUMSBODYSHORT value="#form.txtbodyCut#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_CREATEDBY value="#session.vars.UserId#">
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO POST NEW FORUMS: (#returncode#)">
    </cfif>

<cflocation url="#request.logpath#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList"> 
