<cfmodule template="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

<cfparam name="attributes.inewsId" default = 0>

<cfquery name="newsDetails" datasource="#request.MTRDSN#">
   SELECT a.vaNEWSTITLE, a.vaNEWSBODY, a.vaNEWSIMGFILEPATH, a.vaNEWSSOURCE, a.dtDATECREATED, b.vaUSName, a.iNEWSID,
   a.siSTATUS, c.vaUSName as 'vaAPPRVname', a.dtAPPRV
   FROM NWS0001 a WITH (NOLOCK)
   INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iCREATEDBY
   LEFT JOIN SEC0001 c WITH (NOLOCK) on c.iUSID = a.iAPPRVBY
   WHERE iNEWSID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.inewsId#">
</cfquery>

<body>
  <cfoutput query="newsDetails">
      <div class="container">
        <div class="row">
            <div class="col-lg-12">
              <button style="margin-top: 1.5rem !important;" class="btn btn-danger" type="button" onclick="history.back(-1)"><i class="fa fa-undo" aria-hidden="true"></i> Back</button>
              <h1 class="mt-4">#newsDetails.vaNEWSTITLE#</h1>
              <p class="lead">
                Posted by
                <b>#newsDetails.vaUSName#</b>
                <span class="badge badge-info">#DateTimeFormat(newsDetails.dtDATECREATED, "mmmm dd, yyyy")# at #DateTimeFormat(newsDetails.dtDATECREATED,"HH:nn tt")#</span>
                <br>[Source from : <a href="#newsDetails.vaNEWSSOURCE#">#newsDetails.vaNEWSSOURCE#</a>]
              </p>

              <cfif #session.vars.roleid# eq 1>
                <div>
                  <cfif #newsDetails.siSTATUS# eq 0>
                    
                      <a href="#request.webroot#index.cfm?fusebox=admin&fuseaction=act_approveRejectNews&newsId=#newsDetails.iNEWSID#&statusId=2&#session.urltoken#" class="badge badge-success"><i class="fa fa-check" aria-hidden="true"></i> Approve</a>
                      <a href="#request.webroot#index.cfm?fusebox=admin&fuseaction=act_approveRejectNews&newsId=#newsDetails.iNEWSID#&statusId=1&#session.urltoken#" class="badge badge-warning"><i class="fa fa-times" aria-hidden="true"></i> Reject</a>
                    
                    <cfelseif #newsDetails.siSTATUS# eq 2>
                        <span href="##" class="badge badge-dark">Approved by #newsDetails.vaAPPRVname#</span>
                    <cfelse>
                        <span href="##" class="badge badge-dark">Rejected by #newsDetails.vaAPPRVname#</span>
                  </cfif>
                </div>                
              </cfif>

              <hr>  

              <cfif isnull(#newsDetails.vaNEWSIMGFILEPATH#) or #newsDetails.vaNEWSIMGFILEPATH# eq "">
                <img class="img-fluid rounded" src="#Request.LOGPATH#assets/upload/news/news_002.jpg" alt="header image" style="height: 15vw; width: 1200px">
              <cfelse>
                <img class="img-fluid rounded" src="#Request.LOGPATH##newsDetails.vaNEWSIMGFILEPATH#" alt="header image" style="height: 15vw; width: 1200px">
              </cfif>       
              <hr>

              #newsDetails.vaNEWSBODY#
              
            </div>
          </div>
        </div>
    </div>
  </cfoutput>
</body>