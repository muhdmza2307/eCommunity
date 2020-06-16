<cfcomponent displayname="sec" hint="">
	<cffunction name="act_login" hint="" returntype="any" output="true">
			<cfargument name="chkFirstTime" required="false" default="0" type="numeric"
		displayname="Check First Time Login"
		hint="Check if first time login. Invoke act_firsttimelogin from services for neccessary action and setup for first time login.">
	<cfmodule template="act_login.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
	</cffunction>
</cfcomponent>