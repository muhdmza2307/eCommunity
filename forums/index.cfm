<cfparam name="attributes.fuseaction" DEFAULT="">

<cfswitch expression="#attributes.fuseaction#">
	<cfcase value="dsp_ForumsList">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_ForumsList.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_ForumsCreate">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_ForumsCreate.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_ForumsDetails">
	   	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.forums.index" method="dsp_ForumsDetails" ArgumentCollection=#Attributes#>
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>	
	<cfcase value="act_newComment">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.forums.index" method="act_newComment" ArgumentCollection=#Attributes#>
	</cfcase>	
	<cfcase value="act_newForums">
	    <!--- <cfinclude TEMPLATE="act_newForums.cfm"> --->
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.forums.index" method="act_newForums" ArgumentCollection=#Attributes#>
	</cfcase>	
</cfswitch>





