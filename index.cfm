<cfparam name="attributes.fusebox" DEFAULT="">
<cfparam name="attributes.fuseaction" DEFAULT="">


<cfswitch expression="#attributes.fusebox#">
	<cfcase value="">
	    <cfinclude TEMPLATE="account/index.cfm">
	</cfcase>
	<cfcase value="MICroot">
		<cfswitch expression="#attributes.fuseaction#">
			<cfcase value="dsp_login">
			    <cfinclude TEMPLATE="account/index.cfm">
			</cfcase>
			<cfcase value="dsp_main">
			    <cfinclude TEMPLATE="account/index.cfm">
			</cfcase>
			<cfcase value="dsp_home">
			    <cfinclude TEMPLATE="account/index.cfm">
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