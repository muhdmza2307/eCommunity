<cfparam name="attributes.fusebox" DEFAULT="">
<cfparam name="attributes.fuseaction" DEFAULT="">


<!--- <cfdump var="#session#"> --->

<!--- <cfdump var="#attributes#"> --->

<cfswitch expression="#attributes.fusebox#">
	<cfcase value="">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_login.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="MICroot">
		<cfswitch expression="#attributes.fuseaction#">
			<cfcase value="dsp_login">
				<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
			    <cfinclude TEMPLATE="dsp_login.cfm">
			    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
			</cfcase>
			<cfcase value="dsp_main">
				<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
			    <cfinclude TEMPLATE="dsp_main.cfm">
			    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
			</cfcase>
			<cfcase value="dsp_home">
			    <cfinclude TEMPLATE="dsp_home.cfm">
			</cfcase>
		</cfswitch>		
	</cfcase>
	<cfcase value="News">
		<cfinclude TEMPLATE="news/index.cfm">
	</cfcase>
	<cfcase value="Forums">
		<cfinclude TEMPLATE="forums/index.cfm">
	</cfcase>
	<cfcase value="Admin">
		<cfinclude TEMPLATE="admin/index.cfm">
	</cfcase>
	<cfcase value="Account">
		<cfinclude TEMPLATE="account/index.cfm">
	</cfcase>
	<cfdefaultcase>
		<cfinclude TEMPLATE="#Request.LOGPATH#sec/index.cfm">
	</cfdefaultcase>
</cfswitch>