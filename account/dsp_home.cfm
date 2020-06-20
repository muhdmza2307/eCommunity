<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
   
<cfif isdefined("session.vars.roleid")>
   <cfif session.vars.roleid eq 1>
      <cfset Attributes.fusebox="admin">
      <cfset Attributes.fuseaction="dsp_mainAdmin">     
   <cfelse>
      <cfset Attributes.fusebox="MICroot">
      <cfset Attributes.fuseaction="dsp_main"> 
   </cfif>
   <cfmodule TEMPLATE="#request.logpath#index.cfm" AttributeCollection=#Attributes#>
<cfelse>
   <!--- <cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN"> --->
    <cflocation url="#request.logpath#index.cfm" addtoken="false"> 
</cfif>
