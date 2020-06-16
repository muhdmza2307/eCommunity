<cfparam name="URL.fusebox" DEFAULT="">
<cfparam name="URL.fuseaction" DEFAULT="">

<html>
    <head>
        <title>Pre Mini Project</title>
        
        <cfoutput>
          <script src="#request.LOGPATH#assets/js/jquery-3.5.1.js"></script>
          <script src="#request.LOGPATH#assets/js/crypto-js.js"></script>
          <link href="#request.LOGPATH#assets/css/font.css" rel="stylesheet">
          <link rel="stylesheet" href="#request.LOGPATH#assets/css/bootstrap-4.5.0.css">
          
          <script src="#request.LOGPATH#assets/js/popper.js"></script>
          <script src="#request.LOGPATH#assets/js/bootstrap-4.5.0.js"></script>
          <script language="JavaScript" type="text/javascript" src="#request.LOGPATH#services/scripts/unencoded/SVCMain.js"></script>

          
          
          <link href="#request.LOGPATH#assets/css/style.css" rel="stylesheet">

          <link href="#request.LOGPATH#assets/vendor/ionicons/css/ionicons.min.css" rel="stylesheet">
          <link href="#request.LOGPATH#assets/vendor/animate.css/animate.min.css" rel="stylesheet">
          <link href="#request.LOGPATH#assets/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet">
          <link href="#request.LOGPATH#assets/vendor/venobox/venobox.css" rel="stylesheet">
          <link href="#request.LOGPATH#assets/vendor/owl.carousel/assets/owl.carousel.min.css" rel="stylesheet">
 
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
                    <li><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList&#session.urltoken#">Report</a></li>
                    <li><a href="" class="btn btn-dark" style="color: white;"><i class="fa fa-power-off"></i> Sign Out</a></li>
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
                    <li><a href="" class="btn btn-dark" style="color: white;"><i class="fa fa-power-off"></i> Sign Out</a></li>
                  </ul>
                </nav>
                
              </cfif>
            </div>
          </header>

        </cfif>
      </cfoutput>

  
