<!--- <h1>welcome act_login.cfm</h1> --->

<cfparam name="attributes.chkFirstTime" default=0>
<cfparam name="form.txtUserName" default="">
<cfparam name="form.txtPassword" default="">
<cfparam name="form.nonce" default="">
<cfparam name="form.hpwd" default="">
<cfparam name="form.cpwd" default="">

<cfset attributes.Username= form.txtUserName>
<cfset attributes.PMD5= form.txtPassword>
<cfset attributes.nonce= form.nonce>
<cfset attributes.hpwd= form.hpwd>
<cfset attributes.cpwd= form.cpwd>

<!--- Automatic check if first time login for EPLBPIMS  and if e-mail address login format --->


<!--- <cfmodule TEMPLATE="/eCommunity/services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_login ATTRIBUTECOLLECTION=#ATTRIBUTES#> --->

<cfmodule TEMPLATE="/eCommunity/services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_login ATTRIBUTECOLLECTION=#ATTRIBUTES#>







