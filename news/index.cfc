<cfcomponent>
<cffunction name="dsp_NewsDetails" hint="news detail page" returntype="any" output="true">
	<cfargument name="inewsId" required="false" default="0" type="numeric"
		displayname="news Id"
		hint="">
    <cfmodule TEMPLATE="dsp_NewsDetails.cfm" AttributeCollection=#Arguments#>
    <cfreturn>
</cffunction>
<cffunction name="act_newNews" hint="Action to add new news." returntype="any" output="true">
	<cfargument name="txtNewsTitle" required="false" type="string"
		displayname="news title"
		hint="Insert title into nws0001">
	<cfargument name="txtNewsBody" required="false" type="string"
		displayname="news body"
		hint="Insert body into nws0001">
	<cfargument name="txtNewsSource" required="false" type="string"
		displayname="news source"
		hint="Insert source into nws0001">
	<cfargument name="imgPath" required="false" type="string"
		displayname="news image path"
		hint="Insert imgPath into nws0001">
	<cfargument name="txtbodyCut" required="false" type="string"
		displayname="news body short"
		hint="Insert body short into nws0001">
	<cfmodule template="act_newNews.cfm" AttributeCollection=#Arguments#>
	<cfreturn>
</cffunction>
</cfcomponent>