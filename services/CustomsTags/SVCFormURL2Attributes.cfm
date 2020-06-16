<CFSILENT>
<!---cfsetting enablecfoutputonly="yes"--->
<!--- 
Adds URL and FORM structure to the Caller's Attributes structure. Usually called ONCE
from app_global for each request.

Attributes:
displaybase: Display BASE tag (default:yes)
noform: 1/YES-Skip adding from FORM, 0-Add FORM (default:0)

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================
Theng Hey	27/2/2004	Revise this tag such that it supports url parameters of the form: varA=1&varB=&varC=32,
						meaning one or more of the parameters are blank.
Andrew		21/7/2004	Removed attributeslist & setfuseaction/caller.id. Added NOFORM to skip FORMs.
--->
<!---cfparam name="request.attributeslist" default=""--->
<!---cfparam name="setfuseaction" default=""--->
<!---cfparam name="attributes.displaybase" default="yes"--->
<!---cfparam name="caller.id" default=""--->
<!--- This will convert URL variables to attribute variables --->
<cfif StructKeyExists(CGI,"query_string") and StructKeyExists(cgi,"script_name")>
	<!---CFIF Not IsDefined("caller.attributes") OR Not IsStruct(caller.attributes)--->
	<CFIF Not StructKeyExists(caller,"attributes") OR Not IsStruct(caller.attributes)>
		<CFSET caller.attributes=StructNew()>
	</CFIF>
	<cfif not len(cgi.query_string)>
		<!--- This will support Search Engine capable URLs
			ex: http://127.0.0.1/index.cfm/fuseaction/shoppingcart/additems/127,88/myvar/hello+world --->
		<cfparam name="cleanpathinfo" default="#CGI.SCRIPT_NAME#">
		
		<cfset findindex=findnocase("index.cfm",cleanpathinfo)>
		<cfif findindex>
			<cfset cleanpathinfo=RemoveChars(cleanpathinfo, 1, findindex+9)>
		</cfif>
		
		<cfif len(cleanpathinfo)>
			<!--- If you want to append .htm onto the end of your URL, this will clean it 
				so it doesn't affect your variables --->
			<cfif len(cleanpathinfo) gte 4 and right(cleanpathinfo,4) is ".htm">
				<cfset cleanpathinfo=RemoveChars(cleanpathinfo, len(cleanpathinfo)-3, 4)>
			</cfif>
			
			<cfloop index="i" from="1" to="#listlen(cleanpathinfo, "/")#" step="2"> 
				<cfset urlname = listgetat(cleanpathinfo, i, "/")>
				<cfif listlen(cleanpathinfo,"/") gte i+1>
					<cfset urlvalue = listgetat(cleanpathinfo, i + 1, "/")>
					<!--- This will allow you to pass slashes in your values, escape your / with a slash_ --->
					<cfset urlvalue=replacenocase(urlvalue,"slash_","/","all")>
					<CFIF refindnocase("[[:alpha:]]",left(trim(urlname),1)) and NOT ISDEFINED( 'caller.ATTRIBUTES.' & urlname )>
						<cfswitch expression="#urlname#">
							<cfcase value="cfid">
								<cfparam name="url.cfid" default="#urlvalue#">
							</cfcase>
							<cfcase value="cftoken">
								<cfparam name="url.cftoken" default="#urlvalue#">
							</cfcase>
							<cfdefaultcase>
								<cfif urlvalue is "null">
								    <cfset "caller.attributes.#urlname#" = ""> 
								<cfelse> 
								    <cfset "caller.attributes.#urlname#" = urlvalue> 
								</cfif>
								<!---cfset request.attributeslist = listappend(request.attributeslist,urlname,"&")>
								<cfset request.attributeslist = listappend(request.attributeslist,urlencodedformat(evaluate("caller.attributes.#urlname#")),"=")--->
							</cfdefaultcase>
						</cfswitch>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
	<!--- This is for converting url fields to attributes scoped variables --->
	<cfelse>

	<!--- quick fix for &amp;fuseaction passed back in URL from payment gateway--->
	<cfif refindnocase("&amp;fuseaction",CGI.query_string) gt 0>
		<cflocation url="#CGI.SCRIPT_NAME#?#rereplacenocase(CGI.query_string,'&amp;','&','all')#" addtoken="no">
	</cfif>

		<!--- Param/Attributes to be excluded from sanitization --->
		<cfset excludeList="">
		<cfset excludeList=listAppend(excludeList, "CREATEDATA")> <!--- from client portal (fusebox=MTRcmt&fuseaction=dsp_claimantdtls) --->

		<cfset encodeList="">
		<cfset encodeList=listAppend(encodeList, "CLMNO")>
		<cfloop list="#encodeList#" index="ii">
			<cfif IsDefined("URL.#ii#")>
				<cfset tmpHolder="#evaluate("url."&"#ii#")#">
				<cfset tmpHolder=EncodeForHTML(tmpHolder)>
				<cfset "url.#ii#" = "#tmpHolder#"> 
			</cfif>
		</cfloop>

		<cfloop list="#cgi.query_string#" delimiters="&" index="valuepair"> 
			<cfset URLName = "#ListGetAt(valuepair, 1, "=")#"> 
			<CFIF refindnocase("[[:alpha:]]",left(trim(urlname),1)) and NOT ISDEFINED( 'caller.ATTRIBUTES.' & urlname )>
				<!--- Experimental : Attempted to sanitize url (for tags that is tested prone to xss)--->
				<cfif urlname IS "CT"><!--- Claim Type Tag --->
					<cfset tmpHolder="#evaluate("url."&"#urlname#")#">
					<cfif reFindNoCase("([^0-9])", tmpHolder) GT 0><!--- Not suppose to have text, if contains any, assume tainted, default value to 0 --->
						<cfset tmpHolder=0>
						<cfset "caller.attributes.#urlname#" = tmpHolder>
						<cfset evaluate("url.#urlname#=#tmpHolder#")>
					</cfif>
					<cfset "caller.attributes.#urlname#" = tmpHolder>
				<cfelseif urlname IS "BR"><!--- Branch Tag --->
					<cfset tmpHolder="#evaluate("url."&"#urlname#")#">
					<cfset tmpHolder=TRIM(REReplace(tmpHolder, "[^0-9,\-*]", "", "all"))>
					<cfif listLen(tmpHolder) GT 0>
						<cfset clnBR="">
						<cfloop list="#tmpHolder#" index="i">
							<cfif i NEQ "">
								<cfset clnBR=listAppend(clnBR, i)>
							</cfif>
						</cfloop>
						<CFSET tmpHolder=clnBR>
						<cfset url.BR=tmpHolder>
						<!--- <cfset evaluate("url.#urlname#=#tmpHolder#")> --->
					</cfif>	
					<cfset "caller.attributes.#urlname#" = tmpHolder>
				<cfelseif urlname IS "NOLAYOUT">
					<cfset tmpHolder="#evaluate("url."&"#urlname#")#">
					<CFSET tmpHolder=reReplace(tmpHolder, "[^0-9]", "", "all")> <!--- NOLAYOUT expect values 1 or 0 (or maybe others),remove anything that is not numeric --->
					<cfset evaluate("url.#urlname#=#tmpHolder#")>
					<cfset "caller.attributes.#urlname#" = tmpHolder>
				<cfelseif urlname IS "userid">
					<cfset tmpHolder="#evaluate("url."&"#urlname#")#">
					<cfif ListGetAt(SERVER.ColdFusion.ProductVersion,1) IS 9>
						<CFSET tmpHolder=reReplaceNoCase(URLDecode(userid), "[<()>+\']", "", "all")>
					<cfelse>
						<CFSET tmpHolder=reReplaceNoCase(DecodeForHTML(userid), "[<()>+\']", "", "all")>
					</cfif>					
					<cfset evaluate("url.#urlname#='#tmpHolder#'")>
					<cfset "caller.attributes.#urlname#" = tmpHolder>
				<cfelse>
					<cfset tmpHolder="#evaluate("url."&"#urlname#")#">		
					<cfset tmpHolder=REQUEST.DS.FN.SVCSanitizeInput(tmpHolder,"JS-NQ",true)>			
					<cfset "caller.attributes.#urlname#" = "#tmpHolder#"> 
				</cfif>
				
				<!--- Remove these next 2 lines if you don't want a list of all attributes... 
				it'll speed up processing by about .15 millisecond--->
				<!---cfset request.attributeslist = listappend(request.attributeslist,urlname,"&")>
				<cfset request.attributeslist = listappend(request.attributeslist,urlencodedformat(evaluate("url.#urlname#")),"=")--->
			</CFIF>
		</cfloop>

        <!--- special section for enc --->
        <cfif StructKeyExists(URL,"enc") and StructKeyExists(SESSION,"VARS")>
            <cfif StructKeyExists(SESSION.VARS,"key") >
                <!--- cfset key = Session.Vars.Key --->
                <cfset key = "xswpetoiussldkfjqieeiuriuiopqowieua8q-0rweprkoqlwjrsaflkwkejrqsfwer">
            <cfelse>
                <cfset key = "xswpetoiussldkfjqieeiuriuiopqowieua8q-0rweprkoqlwjrsaflkwkejrqsfwer">
            </cfif> 
            <cfscript>       
                a="";
                queryString = url.enc;
                a = cfusion_decrypt(querystring, key);
               //WriteOutput(a);
            </cfscript>
			<cfset Request.QString=a>
			<cfset caller.attributes.xurl="#a#">		
			<!---CFIF FindNoCase("fuseaction=", a) is 0 >
				<cfthrow type="EX_SECFAILED">
			</CFIF--->
			
            <cfloop list="#a#" delimiters="&" index="valuepair">
			    <cfset URLName = "#ListGetAt(valuepair, 1, "=")#">
			    <CFIF refindnocase("[[:alpha:]]",left(trim(urlname),1)) and NOT ISDEFINED( 'caller.ATTRIBUTES.' & urlname )>
				    <cfif ListLen(valuepair,"=") is 1> 
						<cfset "caller.attributes.#urlname#" = "">
					<cfelse>
						<cfset "caller.attributes.#urlname#" = "#ListGetAt(valuepair, 2, "=")#">
					</cfif>
					
				    <!--- Remove these next 2 lines if you don't want a list of all attributes... 
				    it'll speed up processing by about .15 millisecond--->
				    <!--- <cfset request.attributeslist = listappend(request.attributeslist,urlname,"&")>
			 	    <cfset request.attributeslist = listappend(request.attributeslist,urlencodedformat(evaluate("url.#urlname#")),"=")> --->
			    </CFIF>
		    </cfloop>
        </cfif>
	</cfif>
</cfif>

<!--- This is for converting form fields to attributes scoped variables --->
<CFIF Not(StructKeyExists(Attributes,"NOFORM")) OR Attributes.NOFORM IS 0>
	<cfif StructKeyExists(FORM,"fieldnames")>
		<cfloop list="#form.fieldnames#" index="field">
			<CFIF refindnocase("[[:alpha:]]",left(trim(field),1)) and NOT ISDEFINED( 'Caller.ATTRIBUTES.' & trim(field) )>
				<cfset "caller.attributes.#trim(field)#" = "#evaluate("form.#trim(field)#")#">
				<!--- This is so that you can have multiple type="image" buttons on the same page, if 
					you name the button name="fuseaction_[the value you want]" it will set the fuseaction
					to that value--->
				<!---cfif findnocase("fuseaction_",field) and findnocase(".x",field)>
					<cfset setfuseaction=replacenocase(field,"fuseaction_","")>
					<cfset setfuseaction=replacenocase(setfuseaction,".x","")>
					<cfif refind("[0-9]",setfuseaction)>
						<!--- This is so you can associate an "ID" with an image button (optional) like this:
							<INPUT type="Image" src="/IMAGES/MYIMAGE.GIF" NAME="fuseaction_addthisaddress56">
							it would return ID=56 That way you can a bunch of image buttons in the same form
							that do the same thing but each one has an ID associated with it.
							--->
						<cfset thisid=val(mid(setfuseaction,refind("[0-9]",setfuseaction),len(setfuseaction)))>
						<cfif thisid>
							<cfset caller.ID=thisid>
						</cfif>
					</cfif>
				</cfif--->
				<!--- Remove these next 2 lines if you don't want a list of all attributes... 
				it'll speed up processing by about .15 millisecond--->
				<!--- cfset request.attributeslist = listappend(request.attributeslist,trim(field),"&")>
				<cfset request.attributeslist = listappend(request.attributeslist,urlencodedformat(evaluate("form.#trim(field)#")),"=")--->
			</cfif>
		</cfloop>
	</cfif>
</CFIF>

<!--- <cfif StructKeyExists(FORM,'FIELDNAMES')>
	<cfloop list="#FIELDNAMES#" index="i">
		<cfset tmpHolder=evaluate("FORM."&i)>
		<cfset tmpHolder=REQUEST.DS.FN.SVCSanitizeInput(tmpHolder,"JS-NQ",true)>
		<cfset "FORM.#i#"=tmpHolder>
	</cfloop>
</cfif> --->


<!--- <cfset tmpHolder="#evaluate("url."&"#urlname#")#">		
	<cfset tmpHolder=REQUEST.DS.FN.SVCSanitizeInput(tmpHolder,"JS-NQ",true)>			
	<cfset "caller.attributes.#urlname#" = "#tmpHolder#">  --->


<!---cfif len(setfuseaction)>
	<cfset caller.attributes.fuseaction=setfuseaction>
	<cfif len(caller.id)>
		<cfset caller.attributes.fuseaction=replace(setfuseaction,caller.id,"")>
	</cfif>
</cfif--->
<!--- this is so that your relative images will work, this is only needed if your using search engine urls --->
<CFSET CALLER.ATTRIBUTES.FROMEXTERNAL=1>
</CFSILENT><!---cfif attributes.displaybase><CFSET caller.Base = REReplace(CGI.SCRIPT_NAME, "[^/]+\.cfm.*", "")><CFSET caller.Base= "http://" & CGI.SERVER_NAME & caller.Base><cfoutput><base href="#caller.Base#"></cfoutput></cfif---><cfsetting enablecfoutputonly="No">