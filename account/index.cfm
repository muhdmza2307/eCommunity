<cfparam name="attributes.fuseaction" DEFAULT="">

<cfswitch expression="#attributes.fuseaction#">
	<cfcase value="dsp_changePassword">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_changePassword.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="act_changePassword">
		<cfinvoke component="#Request.APPPATHCFC#eCommunity.account.index" method="act_changePassword" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase value="act_logout">
		<cfmodule template="act_logout.cfm">
	</cfcase>
	<cfcase value="">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_login.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>	
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





