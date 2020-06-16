<cfparam name="form.txt_CurrentPass" type="string" default = "">
<cfparam name="form.txt_NewPass" type="string" default = "">
<cfparam name="form.txt_userId" type="string" default = 0>
<cfparam name="form.txt_Username" type="string" default = "">

<!--- <cfdump var="#form#" abort> --->

<!--- save into db --->
<cfstoredproc procedure="sspUpdateUserPassword" datasource="#request.MTRDSN#" returncode=yes>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_USID value="#form.txt_userId#">
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_USName value="#form.txt_Username#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@ava_USPWD value="#form.txt_CurrentPass#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@ava_NEWUSPWD value="#form.txt_NewPass#">    
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO UPDATE USER PASSWORD: (#returncode#)">
    </cfif>

 <cflocation url="#request.logpath#index.cfm"> 


