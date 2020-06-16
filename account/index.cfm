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
</cfswitch>





