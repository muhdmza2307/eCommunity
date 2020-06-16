<cfcomponent displayname="account" hint="">
<cffunction name="act_changePassword" hint="Action to change passowrd." returntype="any" output="true">
	<cfargument name="txt_CurrentPass" required="false" type="string"
		displayname="Current Password"
		hint="">
	<cfargument name="txt_NewPass" required="false" type="string"
	displayname="New Password"
	hint="update password sec0001">
	<cfmodule template="act_changePassword.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
</cfcomponent>