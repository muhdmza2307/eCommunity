<cfparam name="attributes.newsId" type="integer" default = 0>
<cfparam name="attributes.statusId" type="integer" default = 1>

<!--- <cfdump var="#attributes#" abort> --->

<!--- save into db --->
<cfstoredproc procedure="sspUpdateNewsStatus" datasource="#request.MTRDSN#" returncode=yes>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_USID value="#session.vars.UserId#">
	<cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_NEWSID value="#attributes.newsId#">   
	<cfprocparam cfsqltype="CF_SQL_SMALLINT" type=in dbvarname=@ai_STATUSID value="#attributes.statusId#"> 
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO UPDATE NEWS STATUS: (#returncode#)">
    </cfif>

 <cflocation url="#request.logpath#index.cfm?fusebox=News&fuseaction=dsp_NewsDetails&inewsId=#attributes.newsId#"> 
