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
   <cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
