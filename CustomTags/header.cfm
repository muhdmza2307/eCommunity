<cfparam name="URL.fusebox" DEFAULT="">
<cfparam name="URL.fuseaction" DEFAULT="">

<html>
    <head>

        <cfoutput><title>#application.appfullname#</title>

          <link rel="shortcut icon" href="##" />
        
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="JQUERY">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="CRYPTO">
           <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="FONT">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="BOOTSTRAP_CSS">
          
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="POPPER">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="BOOTSTRAP_JS">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="SVCMain">

          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="STYLE">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="IONICONS">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="ANIMATE">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="FONTAWESOME">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="VENOBOX">
          <cfmodule TEMPLATE="#request.LOGPATH#/CustomTags/ECADDFILE.cfm" Fname="CAROUSEL">
 
        </cfoutput>
    </head>

    <body>

      <cfoutput>
        <cfif #URL.fuseaction# eq "" or #URL.fuseaction# eq "dsp_login" or #URL.fuseaction# eq "dsp_changePassword">
          <header id="header">
            <div class="container">
              <div id="logo" class="pull-left">
                <h1><a href="" class="scrollto">e<span>Community</span></a></h1>
              </div>
              <nav id="nav-menu-container">
              </nav>
            </div>
          </header>

        <cfelse>
          <header id="header">
            <div class="container">
              <div id="logo" class="pull-left">
                <h1><a href="#request.webroot#index.cfm?fusebox=MICroot&fuseaction=dsp_home&#session.urltoken#" class="scrollto">e<span>Community</span></a></h1>
              </div>
              <cfif #session.vars.roleid# eq 1>
                 <nav id="nav-menu-container">
                  <ul id="barList" class="nav-menu">
                    <li><a href="#request.webroot#index.cfm?fusebox=MICroot&fuseaction=dsp_home&#session.urltoken#">Home</a></li>
                     <li><a href="#request.webroot#index.cfm?fusebox=admin&fuseaction=dsp_UserList&#session.urltoken#">User</a></li>
                    <li><a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsList&#session.urltoken#">News</a></li>
                    <li><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList&#session.urltoken#">Forum</a></li>
                    <!--- <li><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList&#session.urltoken#">Report</a></li> --->
                    <li><a href="#request.webroot#index.cfm?fusebox=account&fuseaction=act_logout&#session.urltoken#" class="btn btn-dark" style="color: white;"><i class="fa fa-power-off"></i> Sign Out</a></li>
                  </ul>
                </nav>

              <cfelse>
                <nav id="nav-menu-container">
                  <ul id="barList" class="nav-menu">
                    <li><a href="#request.webroot#index.cfm?fusebox=MICroot&fuseaction=dsp_home&#session.urltoken#">Home</a></li>
                    <li><a href="#request.webroot#index.cfm?fusebox=admin&fuseaction=dsp_UserProfile&profileId=#session.vars.profileId#&#session.urltoken#">User</a></li>
                    <li><a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsList&#session.urltoken#">News</a></li>
                    <li><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList&#session.urltoken#">Forum</a></li>
                    <!--- <li><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList">Report</a></li> --->
                    <li><a href="#request.webroot#index.cfm?fusebox=account&fuseaction=act_logout&#session.urltoken#" class="btn btn-dark" style="color: white;"><i class="fa fa-power-off"></i> Sign Out</a></li>
                  </ul>
                </nav>
                
              </cfif>
            </div>
          </header>

        </cfif>
      </cfoutput>

  
