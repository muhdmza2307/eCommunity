<!---
Generates application static variables that is available from the database
that is DEPLOYMENT INDEPENDENT. Variables specific to the deployment
environment (request.webroot, dsn, etc.) should be set in CF_SETENV, which is called
from this tag exclusively.

Only run if Application.SetVars=0 and no one started it (locked) yet.
If successful, it will write the cache variables to the next available
datastore (if current used is DS1, then write to DS2, else write to DS1)
and set Application.* environment variables.

Parameters: None
--->

<cfsilent>
   <!---cfmodule TEMPLATE="DISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#"--->
   <cflock SCOPE=Application Type=Exclusive TimeOut=600>
      <cfif Not IsDefined("Application.SetVars") OR Application.SetVars IS 0>
	      <cfmodule TEMPLATE="EPLSETENV.cfm">
	      <cfset CURDSN=CURAPPLICATION.MTRDSN>
	      <cfset DS=StructNew()>

	      <!--- <cfdump var="#CURAPPLICATION#" abort> --->

	      <cfif IsDefined("CURAPPLICATION.APPPATH")>
		      <CFIF Not IsDefined("CURAPPLICATION.APPPATHcfc")>
		      <!--- Figure out APPPATHcfc from APPPPATH by converting / and \ to . and removing leading . --->
		      <CFIF IsDefined("CURAPPLICATION.CFPREFIX")>
		      <CFSET APPPATHcfc=Trim(CURAPPLICATION.CFPREFIX)&Trim(CURAPPLICATION.APPPATH)>
		      <CFELSE>
		      <CFSET APPPATHcfc=Trim(CURAPPLICATION.APPPATH)>
		      </CFIF>
		      <CFSET APPPATHcfc=REReplace(APPPATHcfc,"[\\/]",".","ALL")>
		      <CFSET APPPATHcfc=Replace(APPPATHcfc,"..",".","ALL")>
		      <CFIF APPPATHcfc IS "" OR APPPATHcfc IS ".">
		      <CFSET APPPATHcfc="">
		      <CFELSEIF Left(APPPATHcfc,1) IS ".">
		      <CFSET APPPATHcfc=Right(APPPATHcfc,Len(APPPATHcfc)-1)>
		      </CFIF>
		      <CFIF APPPATHcfc IS NOT "" AND Right(APPPATHcfc,1) IS NOT ".">
		      <CFSET APPPATHcfc=APPPATHcfc&".">
		      </CFIF>
		      <CFSET CURAPPLICATION.APPPATHcfc=APPPATHcfc>
		      </CFIF>
		      <cfloop LIST=#StructKeyList(CURAPPLICATION)# INDEX=IDX>
		         <cfset StructInsert(Application,idx,StructFind(CURAPPLICATION,idx),true)>
		      </cfloop>
		      <!--- <cfmodule TEMPLATE="#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/CustomTags/SVCcffunctions.cfm" DS=#DS#> --->

		      	<cfmodule TEMPLATE="#CURAPPLICATION.LOGPATH#CustomTags/ECcffunctions.cfm" DS=#DS#>
		      <!---<cfmodule TEMPLATE="MTRcffunctions.cfm" DS=#DS#> --->
	      </cfif>

	      <CFSET StructInsert(DS,"SVC_SETTINGS",StructNew())>
	      <CFSET StructInsert(DS.SVC_SETTINGS,"HEADER","##Request.Logpath##CustomTags/header.cfm")>
	      <CFSET StructInsert(DS.SVC_SETTINGS,"FOOTER","##Request.Logpath##CustomTags/footer.cfm")>
	      <cfif IsDefined("APPLICATION.CURDS")>
	      <cfset APPLICATION.CURDS=APPLICATION.CURDS MOD 2+1>
	      <cfelse>
	      <cfset APPLICATION.CURDS=1>
	      </cfif>
	      <cfif Application.CURDS IS 1>
	         <cfset Application.DS1=DS>
	         <cfelse>
	         <cfset Application.DS2=DS>
	      </cfif>
	      <cfset Application.Setvars=1>
      </cfif>
   </cflock>
</cfsilent>

