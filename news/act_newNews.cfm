<cfparam name="form.txtNewsTitle" type="string" default = "">
<cfparam name="form.txtNewsBody" type="string" default = "">
<cfparam name="form.txtNewsSource" type="string" default = "">
<cfparam name="form.imgPath" default = "">
<cfparam name="form.txtbodyCut" type="string" default = "">

<cfset uploadImagePath = "">

<cfif #form.imgPath#  is not "">
	<cfset strPath1 = ExpandPath( "./" ) />
	<cfset tempUploadPath = "#strPath1#assets/upload/news/temp">
	<cfset UploadPath = "#strPath1#assets/upload/news">

	<!--- create if not path not exist --->
	<cfif not directoryExists(#uploadPath#)>
		<cfdirectory action="create" directory="#uploadPath#">
	</cfif>

	<cfif not directoryExists(#tempUploadPath#)>
		<cfdirectory action="create" directory="#tempUploadPath#">
	</cfif>

	<!--- Upload file into server --->
    <cffile
    action="upload"
    destination="#tempUploadPath#/#Trim(txtNewsTitle)#.jpg"
    fileField="imgPath"
    nameConflict="overwrite">

    <!--- convert to image extension --->
    <cfimage
    action="convert"
    source="#tempUploadPath#/#Trim(txtNewsTitle)#.jpg"
    destination="#tempUploadPath#/#Trim(txtNewsTitle)#.jpg"
    overwrite="true">

    <!--- resize image --->
    <cfimage
    action="resize"
    width="500"
    height=""
    source="#tempUploadPath#/#Trim(txtNewsTitle)#.jpg"
    destination="#UploadPath#/#Trim(txtNewsTitle)#.jpg"
    overwrite="true">

    <!--- delete temp file --->
    <cffile
    action = "delete"
    file = "#tempUploadPath#/#Trim(txtNewsTitle)#.jpg">

    <cfset uploadImagePath = "assets/upload/news/#Trim(txtNewsTitle)#.jpg">
</cfif>

<!--- save into db --->
<cfstoredproc procedure="sspAddNews" datasource="#request.MTRDSN#" returncode=yes>
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_NEWSTITLE value="#form.txtNewsTitle#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_NEWSBODY value="#form.txtNewsBody#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_NEWSSOURCE value="#form.txtNewsSource#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_NEWSIMGFILEPATH value="#uploadImagePath#">
    <cfprocparam cfsqltype="CF_SQL_VARCHAR" type=in dbvarname=@as_NEWSBODYSHORT value="#form.txtbodyCut#">
    <cfprocparam cfsqltype="CF_SQL_INTEGER" type=in dbvarname=@ai_CREATEDBY value="#session.vars.UserId#">
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
    <cfif returncode LT 0>
        <cfthrow TYPE=EX_DBERROR ErrorCode="UNABLE TO POST NEW NEWS: (#returncode#)">
    </cfif>

 <cflocation url="#request.logpath#index.cfm?fusebox=News&fuseaction=dsp_NewsList"> 
