<cfparam name="attributes.fuseaction" DEFAULT="">

<cfswitch expression="#attributes.fuseaction#">								
	<cfcase value="act_newUser">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.admin.index" method="act_newUser" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase value="dsp_UserCreate">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_UserCreate.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_UserList">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_UserList.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_UserProfile">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.admin.index" method="dsp_UserProfile" ArgumentCollection=#Attributes#>
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="act_editUserProfile">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.admin.index" method="act_editUserProfile" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase value="dsp_mainAdmin">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_mainAdmin.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_ApprovalList">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_ApprovalList.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="act_approveRejectNews">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.admin.index" method="act_approveRejectNews" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>
