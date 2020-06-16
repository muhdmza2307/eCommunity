<cfparam name="URL.fusebox" DEFAULT="">
<cfparam name="URL.fuseaction" DEFAULT="">
<html>
    <head>
        <title>Pre Mini Project</title>

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.0.0/crypto-js.min.js"></script> 

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,700,700i|Raleway:300,400,500,700,800|Montserrat:300,400,700" rel="stylesheet">

        <!-- CSS only -->
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">

        <!-- JS, Popper.js, and jQuery -->
        <!-- <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script> -->
         <script src="https://code.jquery.com/jquery-3.5.1.js"></script>
        <!--<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script> -->
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>

        <!-- Template Main CSS File -->
        <link href="../eCommunity/assets/css/style.css" rel="stylesheet">

         <!-- Vendor CSS Files -->
        <!-- <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet"> -->
        <link href="../eCommunity/assets/vendor/ionicons/css/ionicons.min.css" rel="stylesheet">
        <link href="../eCommunity/assets/vendor/animate.css/animate.min.css" rel="stylesheet">
        <link href="../eCommunity/assets/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet">
        <link href="../eCommunity/assets/vendor/venobox/venobox.css" rel="stylesheet">
        <link href="../eCommunity/assets/vendor/owl.carousel/assets/owl.carousel.min.css" rel="stylesheet">

        <cfoutput>
          <script language="JavaScript" type="text/javascript" src="#request.LOGPATH#services/scripts/unencoded/SVCMain.js"></script>
        </cfoutput>
    </head>
   <body>

<cfoutput>
   <cfif #URL.fuseaction# eq "" or #URL.fuseaction# eq "dsp_login">
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
            <h1><a href="" class="scrollto">e<span>Community</span></a></h1>
          </div>

         <!---  <nav id="nav-menu-container">
            <ul id="barList" class="nav-menu">
              <li><a href="#request.webroot#index.cfm?fusebox=MICroot&fuseaction=dsp_home">Home</a></li>
              <li><a href="#request.webroot#index.cfm?fusebox=News&fuseaction=dsp_NewsList">News</a></li>
              <li><a href="#request.webroot#index.cfm?fusebox=Forums&fuseaction=dsp_ForumsList">Forum</a></li>
              <li><a href="" class="btn btn-dark" style="color: white;"><i class="fa fa-power-off"></i> Sign Out</a></li>
            </ul>
          </nav> --->

          <cfif #session.vars.roleid# eq 1>
             <nav id="nav-menu-container">
              <ul id="barList" class="nav-menu">
                <li><a href="#request.webroot#index.cfm?fusebox=MICroot&fuseaction=dsp_home&#session.urltoken#">Home</a></li>
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

  
