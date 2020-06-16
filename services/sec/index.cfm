<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#Attributes.fuseaction#">
	<cfcase value=act_login>
		<cfinvoke component="#Request.APPPATHCFC#eCommunity.services.sec.index" method="act_login" ArgumentCollection=#Attributes# returnVariable="ReturnStruct">
		<CFIF IsStruct(ReturnStruct) AND Not StructIsEmpty(ReturnStruct) AND IsDefined("Caller")>
			<CFSET StructAppend(Caller,ReturnStruct,true)>
		</CFIF>
	</cfcase>
</cfswitch>