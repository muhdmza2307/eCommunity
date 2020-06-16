<!--- <h1>welcome index sec<h1> --->

<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#Attributes.fuseaction#">
	<cfcase value="act_login">
		<cfinvoke component="#Request.APPPATHCFC#eCommunity.sec.index" method="act_login" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>

