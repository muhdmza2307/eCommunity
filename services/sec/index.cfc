<cfcomponent displayname="Sec" hint="Merimen Services- Sec">
	<cffunction name="act_login" hint="Action file for log in." returntype="struct" output="true">
	<cfargument name="custlogin" required="false" default="0" type="numeric"
		displayname="Customer Login"
		hint="1=MinsCore Customer type login with e-mail address. 2=MInsCore non-customer login (re-directs to fusebox=MICroot&fuseaction=dsp_login if login failed). 0=Normal application login.">
	<cfargument name="UserID" required="false" type="string"
		displayname="The User ID"
		hint="User login id.">
	<cfargument name="PMD5" required="false" type="string"
		displayname="Password in MD5 Hash"
		hint="MD5 hash of the user login password. (UPDATE: Changed to SHA algorithm)">
	<cfargument name="NONCE" required="false" type="string"
		displayname="Once off check string."
		hint="Check string generated with the current time and merimen's own secret private key at dsp_login. Validated before password authentication can happen.">
	<CFSET Arguments.ReturnStruct=StructNew()>
	<CFMODULE template="act_login.cfm" AttributeCollection=#Arguments#>
	<CFRETURN Arguments.ReturnStruct>
</cffunction>
</cfcomponent>