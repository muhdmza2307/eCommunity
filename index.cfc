<cfcomponent>
<cffunction name="dsp_login" hint="login page" returntype="any" output="true">
    <cfmodule template="index.cfm" AttributeCollection="#Arguments#">
    <cfreturn>
</cffunction>
<cffunction name="dsp_NewsDetails" hint="news detail page" returntype="any" output="true">
	<cfargument name="inewsId" required="false" default="0" type="numeric"
		displayname=""
		hint="">
    <cfmodule TEMPLATE="news/dsp_NewsDetails.cfm" AttributeCollection=#Arguments#>
    <cfreturn>
</cffunction>
<cffunction name="dsp_ForumsDetails" hint="forums detail page" returntype="any" output="true">
	<cfargument name="iforumsId" required="false" default="0" type="numeric"
		displayname=""
		hint="">
    <cfmodule TEMPLATE="forums/dsp_ForumsDetails.cfm" AttributeCollection=#Arguments#>
    <cfreturn>
</cffunction>
</cfcomponent>