<cfquery name="newsList" datasource="#request.MTRDSN#">
   SELECT TOP 3 a.vaNEWSIMGFILEPATH, a.vaNEWSTITLE, a.dtDATECREATED, 
   a.vaNEWSBODYSHORT, a.iNEWSID, b.vaUSName FROM NWS0001 a WITH (NOLOCK)
   INNER JOIN SEC0001 b on b.iUSID = a.iCREATEDBY
   WHERE a.siSTATUS = 2 --0:pending, 1:deactive, 2:active
   ORDER BY iNEWSID DESC
</cfquery>

<cfquery name="forumsList" datasource="#request.MTRDSN#">
   SELECT top 3 a.vaFORUMSTITLE, a.dtDATECREATED,
   a.vaFORUMSBODYSHORT, a.iFORUMSID, b.vaUSName  FROM FRM0001 a WITH (NOLOCK)
   INNER JOIN SEC0001 b on b.iUSID = a.iCREATEDBY
   WHERE a.siSTATUS = 0 --0:active, 1:deactive
   ORDER BY iFORUMSID DESC
</cfquery>

<body>
<div class="dashboard">
   <div class="container">
      <div class="row_header">
         <p><b>Latest News</b></p>
      </div>
      <div class="row">

         <cfif #newsList.recordCount# gt 0>
               <cfoutput query="newsList">
                <cfset diffDay="#dateDiff("d", DateFormat(newsList.dtDATECREATED, "YYYY-MM-DD"), DateFormat(now(), "YYYY-MM-DD"))#">

               <cfif diffDay eq 0>
                  <cfset diffDay = "Posted Today">
               <cfelseif diffDay eq 1>
                  <cfset diffDay = "Posted #diffDay# day ago">
               <cfelse>
                  <cfset diffDay = "Posted #diffDay# days ago">
               </cfif>

               <div id="card" class="col-sm-4">
                  <div class="card">
                     <cfif isnull(#newsList.vaNEWSIMGFILEPATH#) or #newsList.vaNEWSIMGFILEPATH# eq "">
                        <img class="card-img-top" src="#Request.LOGPATH#assets/upload/news/news_002.jpg" alt="Card image cap">
                     <cfelse>
                        <img class="card-img-top" src="#Request.LOGPATH##newsList.vaNEWSIMGFILEPATH#" alt="Card image cap">
                     </cfif>
                     
                     <div class="card-body">
                        <h5 class="card-title">#newsList.vaNEWSTITLE#</h5>
                         <span class="badge badge-danger">#diffDay#</span> 
                         <span class="badge badge-success">By #newsList.vaUSName#</span>
                        <p class="card-text">#newsList.vaNEWSBODYSHORT#..</p>
                        <a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsDetails&inewsId=#newsList.iNEWSID#&#session.urltoken#" class="btn btn-info">Read More <i class="fa fa-angle-double-right"></i></a>
                     </div>
                  </div>
                  <br>
               </div>
            </cfoutput>

            <cfif #newsList.recordCount# eq 1>
               <div class="col-sm-4"></div>
               <div class="col-sm-4"></div>
            <cfelseif #newsList.recordCount# eq 2>
               <div class="col-sm-4"></div>
            </cfif>

            <cfoutput><div style="margin:auto"><a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsList&#session.urltoken#" class="btn btn-outline-primary"><i class="fa fa-sign-in"></i> Go to list</a></div></cfoutput>
         <cfelse>
            <div class="container" align="center">
               No record available
            </div>
         </cfif>
      </div>

      <br> 

      <div class="row_header">
         <p><b>Latest Forums</b></p>
      </div>
      <div class="row">

         <cfif #forumsList.recordCount# gt 0>
            <cfoutput query="forumsList">
            <cfset diffDay="#dateDiff("d", DateFormat(forumsList.dtDATECREATED, "YYYY-MM-DD"), DateFormat(now(), "YYYY-MM-DD"))#">

            <cfif diffDay eq 0>
               <cfset diffDay = "Posted Today">
            <cfelseif diffDay eq 1>
               <cfset diffDay = "Posted #diffDay# day ago">
            <cfelse>
               <cfset diffDay = "Posted #diffDay# days ago">
            </cfif>

            <div id="card" class="col-sm-4">
               <div class="card">
                  <img class="card-img-top" src="#Request.LOGPATH#assets/upload/forums/forums_001.png" alt="Card image cap">
                  <div class="card-body">
                     <h5 class="card-title">#forumsList.vaFORUMSTITLE#</h5>
                     <span class="badge badge-danger">#diffDay#</span>
                     <span class="badge badge-success">By #forumsList.vaUSName#</span>
                     <p class="card-text">#forumsList.vaFORUMSBODYSHORT#..</p>
                     <a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsDetails&iforumsId=#forumsList.iFORUMSID#&#session.urltoken#" class="btn btn-info">Read More <i class="fa fa-angle-double-right"></i></a>
                  </div>
               </div>
               <br>
            </div>
            </cfoutput>

            <cfif #forumsList.recordCount# eq 1>
               <div class="col-sm-4"></div>
               <div class="col-sm-4"></div>
            <cfelseif #forumsList.recordCount# eq 2>
               <div class="col-sm-4"></div>
            </cfif>

            <cfoutput><div style="margin:auto"><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList&#session.urltoken#" class="btn btn-outline-primary"><i class="fa fa-sign-in"></i> Go to list</a></div></cfoutput>
         <cfelse>
            <div class="container" align="center">
               No record available
            </div>
         </cfif>     
      </div>

   </div>
</div>
</body>
