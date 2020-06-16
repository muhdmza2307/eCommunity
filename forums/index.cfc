<cfcomponent>
<cffunction name="dsp_ForumsDetails" hint="forums detail page" returntype="any" output="true">
	<cfargument name="iforumsId" required="false" default="0" type="numeric"
		displayname="forum Id"
		hint="">
    <cfmodule TEMPLATE="dsp_ForumsDetails.cfm" AttributeCollection=#Arguments#>
    <cfreturn>
</cffunction>
<cffunction name="act_newComment" hint="Action to add new comment." returntype="any" output="true">
	<cfargument name="txtComment" required="false" type="string"
		displayname="comment body"
		hint="Insert comment into cmt_frm0001">
	<cfargument name="forumsId" required="false" type="numeric"
		displayname="forum Id"
		hint="Insert forums id into cmt_frm0001">
	<cfmodule template="act_newComment.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
<cffunction name="act_newForums" hint="Action to add new forum." returntype="any" output="true">
	<cfargument name="txtForumsTitle" required="false" type="string"
		displayname="forum title"
		hint="Insert title into frm0001">
	<cfargument name="txtForumsBody" required="false" type="string"
		displayname="forum body"
		hint="Insert body into frm0001">
	<cfargument name="txtbodyCut" required="false" type="string"
		displayname="forum body short"
		hint="Insert body short into frm0001">
	<cfmodule template="act_newForums.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
</cfcomponent>