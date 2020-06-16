<cfparam name="form.txtComment" type="string" default = "">
<cfparam name="form.forumsId" type="integer" default = "">

<!--- save into db --->
<cfstoredproc procedure="sspAddForumsComment" datasource="#request.MTRDSN#" returncode=yes>
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_FORUMSID value="#form.forumsId#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_COMMENTBODY value="#form.txtComment#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_CREATEDBY value="#session.vars.UserId#">
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO POST NEW COMMENT: (#returncode#)">
    </cfif>
   

 <cflocation url="#request.logpath#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsDetails&iforumsId=#form.forumsId#"> 
