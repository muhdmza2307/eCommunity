<cfparam name="form.txt_Dob" type="string" default = "">
<cfparam name="form.txt_Gender" type="integer" default = "">
<cfparam name="form.txt_Email" type="string" default = "">
<cfparam name="form.txt_profileId" type="integer" default = "">

<!--- <cfdump var="#DateTimeFormat(form.txt_Dob, "yyyy-mm-dd")#" abort> --->

<!--- save into db --->
<cfstoredproc procedure="sspUpdateUser" datasource="#request.MTRDSN#" returncode=yes>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_PROFILEID value="#form.txt_profileId#">
	<cfprocparam cfsqltype="CF_SQL_DATE" type=in dbvarname=@adt_DATEBIRTH value="#DateTimeFormat(form.txt_Dob, "yyyy-mm-dd")#">
	<cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@asi_GENDER value="#form.txt_Gender#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@ava_EMAIL value="#form.txt_Email#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_MODIFYBY value="#session.vars.UserId#">    
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO UPDATE USER PROFILE: (#returncode#)">
    </cfif>

 <cflocation url="#request.logpath#index.cfm?fusebox=admin&fuseaction=dsp_UserList"> 
