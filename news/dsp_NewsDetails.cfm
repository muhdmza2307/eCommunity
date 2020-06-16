<cfparam name="attributes.inewsId" default = 0>

<cfquery name="newsDetails" datasource="#request.MTRDSN#">
   SELECT a.vaNEWSTITLE, a.vaNEWSBODY, a.vaNEWSIMGFILEPATH, a.vaNEWSSOURCE, a.dtDATECREATED, b.vaUSName
   FROM NWS0001 a WITH (NOLOCK)
   INNER JOIN SEC0001 b WITH (NOLOCK) on b.iUSID = a.iCREATEDBY
   WHERE iNEWSID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.inewsId#">
</cfquery>

<body>
  <cfoutput query="newsDetails">
      <div class="container">
        <div class="row">
            <div class="col-lg-12">
              <h1 class="mt-4">#newsDetails.vaNEWSTITLE#</h1>
              <p class="lead">
                Posted by
                <b>#newsDetails.vaUSName#</b>
                <span class="badge badge-danger">#DateTimeFormat(newsDetails.dtDATECREATED, "mmmm dd, yyyy")# at #DateTimeFormat(newsDetails.dtDATECREATED,"HH:nn tt")#</span>
                <br>[Source from : <a href="#newsDetails.vaNEWSSOURCE#">#newsDetails.vaNEWSSOURCE#</a>]
              </p>
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