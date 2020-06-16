<cfparam name="attributes.fuseaction" DEFAULT="">

<cfswitch expression="#attributes.fuseaction#">
	<cfcase value="dsp_NewsList">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_NewsList.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_NewsCreate">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinclude TEMPLATE="dsp_NewsCreate.cfm">
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>
	<cfcase value="dsp_NewsDetails">
	   	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\header.cfm">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.news.index" method="dsp_NewsDetails" ArgumentCollection=#Attributes#>
	    <cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\footer.cfm">
	</cfcase>	
	<cfcase value="act_newNews">
	    <cfinvoke component="#Request.APPPATHCFC#eCommunity.news.index" method="act_newNews" ArgumentCollection=#Attributes#>
	</cfcase>			
</cfswitch>





