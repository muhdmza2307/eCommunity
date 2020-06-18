<cfcomponent displayname="admin" hint="">
<cffunction name="act_newUser" hint="Action to add new user." returntype="any" output="true">
	<cfargument name="txt_Username" required="false" type="string"
		displayname="Username"
		hint="Insert username into sec0001">
	<cfmodule template="act_newUser.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
<cffunction name="dsp_UserProfile" hint="Display user profile." returntype="any" output="true">
	<cfargument name="iprofileId" required="false" type="string"
		displayname="profileId"
		hint="">
	<cfmodule template="dsp_UserProfile.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
<cffunction name="act_editUserProfile" hint="Action to edit user profile" returntype="any" output="true">
	<cfmodule template="act_editUserProfile.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
<cffunction name="act_approveRejectNews" hint="Action to edit news status" returntype="any" output="true">
	<cfargument name="newsId" required="false" type="numeric"
		displayname="newsId"
		hint="">
		<cfargument name="statusId" required="false" type="numeric"
		displayname="statusId"
		hint="">
	<cfmodule template="act_approveRejectNews.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
</cfcomponent>