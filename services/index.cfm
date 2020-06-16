<cfparam NAME="attributes.FUSEBOX" DEFAULT="">
<cfparam NAME="attributes.FUSEACTION" DEFAULT="">

<cfswitch expression="#attributes.fusebox#">
	<cfcase VALUE="SVCsec">
        <cfinclude TEMPLATE="sec/index.cfm">
    </cfcase>
</cfswitch>