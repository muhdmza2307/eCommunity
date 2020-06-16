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
---><cfsilent>
<!---cfmodule TEMPLATE="DISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#"--->
<!---cflock SCOPE=Application Type=Exclusive TimeOut=60>
<cfif Not IsDefined("Application.SetVars") OR Application.SetVars IS 0>
<cfmodule TEMPLATE="MICSETENV.cfm"--->
	
<cfset CURDSN=CURAPPLICATION.MICDSN>
<!--- Company Cache - select out all insurers, adjusters, or companies with hierarchy --->
<!--- Some settings follow GCOID, some own branch --->
<cfset co=StructNew()>
<cfset codtl=StructNew()>
<!---@COTYPE@:Add into request.ds.co--->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.iCOID,iPCOID=IsNull(a.iPCOID,0),iGCOID=IsNull(a.iGCOID,a.iCOID),iCOUNTRYID=a.iCOUNTRYID
,a.iCOID
,iTERMSET=case when a.siCOTYPEID=2 then isNULL(p.iTERMSET,isNULL(a.iTERMSET,0))
			   when a.siCOTYPEID=6 then isNULL(b.iTERMSET,isNULL(p.iTERMSET,0))
			   when a.siCOTYPEID=14 then isNULL(g.iTERMSET,isNULL(p.iTERMSET,0)) <!--- Corporate Client --->
			   else isNULL(a.iTERMSET,0) end
,iPOLSTATSET=case when a.siCOTYPEID=2 then isNULL(p.iPOLSTATSET,isNULL(a.iPOLSTATSET,0))
				  when a.siCOTYPEID=6 then isNULL(b.iPOLSTATSET,isNULL(p.iPOLSTATSET,0))
				  when a.siCOTYPEID=14 then isNULL(g.iPOLSTATSET,isNULL(p.iPOLSTATSET,0)) <!--- Corporate Client --->
				  else ISNULL(a.iPOLSTATSET,0) end
,C.LABELLIST, D.gcolist, D.gconame, E.aglist, F.BRANCHES, F.BRNAMELIST, F.PCOLIST, F.CSTLIST
,vaCOLOGICNAME=isNULL(nullif(a.vaCOLOGICNAME,''),p.vaCOLOGICNAME)
,iGCOID=IsNull(a.iGCOID,a.iCOID),a.vaCONAME,a.vaCOBRNAME,siSUBSCRIBE=IsNull(a.siSUBSCRIBE,0),siHIERARCHY=IsNull(a.siHIERARCHY,0),
siCOTYPEID=a.siCOTYPEID,
a.vaADD1,a.vaADD2,a.vaPOSTCODE,a.vaCOREGNO,a.iCITYID,
TELNO=RTrim(a.aTELNO),FAXNO=RTrim(a.aFAXNO),
iINTSYNCFLAG=CASE WHEN IsNull(a.iINTSYNCFLAG,0) & 8=0 THEN IsNull(p.iINTSYNCFLAG,0) ELSE IsNull(a.iINTSYNCFLAG,0) END,
iLOCID=a.iLOCID, a.iCurrencyID, a.sistatus, dtVATEFFECTIVE= case when a.iLOCID=1 then isnull(a.dtVATEFFECTIVE,'2015-04-01 00:00:00.000') else a.dtVATEFFECTIVE end,
siGSTREG=case when a.iLOCID=1 AND (a.bgstregistered=1 or isnull(a.vaTAXREGNO,'')!='') then 1 else 0 end
FROM SEC0005 a WITH (NOLOCK) LEFT OUTER JOIN SEC0005 p WITH (NOLOCK) ON a.iGCOID=p.iCOID
LEFT JOIN (
	SELECT distinct B.IACOID,iTERMSET = case when a.iSUBCOTYPEFLAG=2 then isNULL(a.iTERMSET,ISNULL(C.iTERMSET, 0)) else ISNULL(C.iTERMSET, ISNULL(A.iTERMSET, 0)) end
		,iPOLSTATSET = case when a.iSUBCOTYPEFLAG=2 then isNULL(a.iPOLSTATSET,isNULL(c.iPOLSTATSET,0)) else ISNULL(C.iPOLSTATSET, ISNULL(A.iPOLSTATSET, 0)) end
		FROM SEC0005 A WITH (NOLOCK)
	INNER JOIN FSEC1001 B WITH (NOLOCK) ON A.ICOID = B.IACOID AND A.siStatus = 0 AND B.siStatus = 0
	INNER JOIN SEC0005 C WITH (NOLOCK) ON B.IIGCOID = C.ICOID AND C.siStatus = 0
	INNER JOIN (SELECT IACOID from FSEC1001 WITH (NOLOCK) WHERE siStatus = 0 group by IACOID having COUNT(distinct iigcoid)=1) D on D.IACOID=A.iCOID
) b on b.IACOID = a.iCOID
LEFT JOIN( <!--- Join with Corporate Client iTERMSET & iPOLSTATSET --->
	SELECT DISTINCT d.iCOID as CustomerID,d.VACONAME,
		iTERMSET =ISNULL(d.iTERMSET, ISNULL(e.iTERMSET, 0)),
		iPOLSTATSET=ISNULL(d.iPOLSTATSET, ISNULL(e.iPOLSTATSET, 0))
	FROM FCST0001 a
	JOIN sec0005 d ON a.iOBJID=d.iCOID AND d.SISTATUS=0 AND a.SISTATUS=0 <!--- link with customer --->
	JOIN sec0005 e ON a.IGCOID=e.iCOID AND e.SISTATUS=0 <!--- link with insurer --->
)g ON g.CustomerID = a.iCOID
LEFT JOIN (
	select DISTINCT C.iGCOID, LABELLIST=STUFF(( select ','+cast(a.ILBLDEFID as varchar) from FOBJB3022 a inner join FOBJB3020 b on a.iLBLDEFID=b.ILBLDEFID
		where a.siSTATUS=0 and b.SIPRIVATE=1 and b.SISTATUS=0 and a.iGCOID=c.iGCOID for xml path(''), ELEMENTS), 1, 1, '')
	FROM FOBJB3022 c where c.sistatus=0
) c on c.iGCOID=a.iCOID
LEFT JOIN (
	select DISTINCT C.iGCOID
	, gcolist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 and a.iGCOID=c.iCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
	, gconame=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 and a.iGCOID=c.iCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
	FROM SEC0005 c WHERE c.iPCOID=0 and c.siSTATUS=0
) d on d.iGCOID=a.iCOID
LEFT JOIN (
	select DISTINCT C.iCOID
	, aglist = STUFF(( select ','+cast(a.IACOID as varchar) from FSEC1001 a inner join SEC0005 b on a.iacoid=b.icoid where a.siSTATUS=0 and b.sistatus=0 and ((a.IICOID=c.iCOID and c.iPCOID<>0) or (a.iIGCOID=c.iCOID and c.iPCOID=0)) order by a.iacoid for xml path(''), ELEMENTS), 1, 1, '')
	FROM SEC0005 c WHERE c.siSTATUS=0 and c.siCOTYPEID=2
) e on e.iCOID = a.iCOID
left join (
	SELECT DISTINCT x.iCOID
		,BRANCHES   = STUFF(( select ','+cast(a.icoid as varchar)			   				from SEC0005 a, SEC0015 b where a.iCOID=b.iCHCOID and ((b.siHIERARCHY>0 and a.siSTATUS=0) or (a.iCOID=x.iCOID)) and b.iCOID=x.iCOID AND a.siCOTYPEID IN (2,6,14) order by a.iorder for xml path(''), ELEMENTS), 1, 1, '')
		,BRNAMELIST = dbo.fUNXML(STUFF(( select ','+cast( RTRIM(a.vaCOBRNAME) as varchar) 	from SEC0005 a, SEC0015 b where a.iCOID=b.iCHCOID and ((b.siHIERARCHY>0 and a.siSTATUS=0) or (a.iCOID=x.iCOID)) and b.iCOID=x.iCOID AND a.siCOTYPEID IN (2,6,14) order by a.iorder for xml path(''), ELEMENTS), 1, 1, ''))
		,PCOLIST	= isNULL(STUFF(( select ','+cast( RTRIM(a.iCOID) as varchar) from SEC0005 a, SEC0015 b where a.iCOID=b.iCHCOID and a.siSTATUS=0 and (b.siHIERARCHY<0) and b.iCOID=x.iCOID AND a.siCOTYPEID IN (2,6,14) order by a.iorder desc for xml path(''), ELEMENTS), 1, 1, ''),0)
		,CSTLIST 	= STUFF(( select ','+cast(icstid as varchar) from FCST0001 a with (nolock) inner join SEC0015 b with (nolock) on (a.iobjid=b.ichcoid and b.sihierarchy>=0 and b.iCOID=x.icoid) where a.idomainid=10 and a.sistatus=0 order by b.sihierarchy asc for xml path(''), ELEMENTS), 1, 1, '')
	FROM SEC0005 x WITH (NOLOCK) where x.siCOTYPEID IN (2,6,14) <!--- and a.sistatus=0 --->
) f on f.iCOID = a.iCOID
WHERE ((a.siCOTYPEID=2 OR a.siCOTYPEID=6 OR a.siCOTYPEID=14) OR (a.iCOID IN (SELECT DISTINCT iCOID FROM SEC0015 WHERE siHIERARCHY<>0)))
</cfquery>
<cfoutput query=q_trx>
	<cfset StructClear(codtl)>
	<cfset StructInsert(codtl,"GCOID",iGCOID)>
	<cfset StructInsert(codtl,"LOCID",iLOCID)>

	<cfset StructInsert(codtl,"ADD1",Trim(vaADD1))>
	<cfset StructInsert(codtl,"ADD2",Trim(vaADD2))>
	<cfset StructInsert(codtl,"POSTCODE",Trim(vaPOSTCODE))>
	<cfset StructInsert(codtl,"COREGNO",Trim(vaCOREGNO))>
	<cfset StructInsert(codtl,"CITYID",iCITYID)>

	<cfset StructInsert(codtl,"COTYPEID",siCOTYPEID)>
	<cfset StructInsert(codtl,"SUBSCRIBE",siSUBSCRIBE)>
	<!---CFSET StructInsert(codtl,"ESOURCE",siESOURCE)--->
	<!---CFSET StructInsert(codtl,"GCFORM",siGCFORM)--->
	<cfset StructInsert(codtl,"TELNO",TELNO)>
	<cfset StructInsert(codtl,"FAXNO",FAXNO)>
	<cfset StructInsert(codtl,"CONAME",Trim(vaCONAME))>
	<cfset StructInsert(codtl,"COBRNAME",Trim(vaCOBRNAME))>
	<cfset StructInsert(codtl,"INTSYNCFLAG",iINTSYNCFLAG)>
	<cfset StructInsert(codtl,"TERMSET",iTERMSET)>
	<cfset StructInsert(codtl,"POLSTATSET",iPOLSTATSET)>
	<CFSET StructInsert(codtl,"CURRENCYID", iCurrencyID)>
	<CFSET StructInsert(codtl,"COLOGICNAME", vaCOLOGICNAME)>
	<CFSET StructInsert(codtl,"status", sistatus)>

	<cfif IGCOID IS iCOID>
		<cfset StructInsert(codtl,"LABELLIST",LABELLIST)>
		<cfset StructInsert(codtl,"COUNTRYID",iCOUNTRYID)>
		<cfset StructInsert(codtl,"GCOLIST",GCOLIST)>
		<cfset StructInsert(codtl,"GCONAME",GCONAME)>
	</cfif>
	<cfset StructInsert(codtl,"PCOLIST",pcolist)>
	<cfset StructInsert(codtl,"HIERARCHY",siHIERARCHY)>
	<cfset StructInsert(codtl,"CHCOLIST",branches)>
	<cfset StructInsert(codtl,"CHCOBRLIST",brnamelist)>

	<!--- List of Insurer agents --->
  	<cfif q_trx.sicotypeid eq 2 and aglist neq "">
		<cfset StructInsert(codtl,"AGENTLIST",aglist)>
	</cfif>

	<!---KY: Accessible customer list--->
  	<cfif q_trx.sicotypeid eq 14 and cstlist neq "">
		<cfset StructInsert(codtl,"CSTID",listfirst(cstlist))>
		<cfset StructInsert(codtl,"CSTLIST",cstlist)>
	</cfif>

	<!---Mardhiah: Malaysian's GST effective date--->
	<cfif iLOCID eq 1>
		<CFSET StructInsert(codtl,"vatEffDate", dtVATEFFECTIVE)>
		<CFSET StructInsert(codtl,"GSTREG", siGSTREG)>
		<CFSET StructInsert(codtl,"NEWGSTDATE", '2018-06-01 00:00:00.000')>
		<CFSET StructInsert(codtl,"GSTTERMDATE", '2018-09-01 00:00:00.000')>
	</cfif>

	<!---cfset StructInsert(codtl,"MAILLIST",QuotedValueList(q_trx2.MID))--->
	<cfset StructInsert(co,iCOID,Duplicate(codtl))>
</cfoutput>

<!--- COADMIN Extended Attributes --->
<CFQUERY NAME="q_coexattr" DATASOURCE="#CURDSN#">
select a.vafieldlogicname,b.vaattr,b.iOWNOBJID from fsys0012 a with (nolock)
	inner join fsys0013 b with (nolock) on (a.iattrid=b.iattrid and a.vaattrtype='COADMIN')
where b.iowndomid=10 and a.sistatus=0
</CFQUERY>
<cfif q_coexattr.recordcount gt 0>
	<cfloop query=q_coexattr>
		<cfif structKeyExists(co,q_coexattr.iownobjid)>
			<cfset StructInsert(co[q_coexattr.iownobjid],"EXATTR_#q_coexattr.vafieldlogicname#",q_coexattr.vaattr)>
		</cfif>
	</cfloop>
</cfif>

<!--- Occupation --->
<cfset occupation=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT ID=a.siOCCUPATION,vaDESC=a.vaDESC,iLID=IsNull(a.iLID,0) FROM SYS0018 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(OCCUPATION,ID,vaDESC)>
	<cfset StructInsert(OCCUPATION,"LID_#ID#",iLID)>
</cfoutput>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT ID=a.siOCCUPATION, igcoid , iselector=NULL/*=ct.iclmtypemask*/
FROM SYSB0018 a WITH (NOLOCK) JOIN SYS0018 b with (nolock) ON a.siOCCUPATION=b.siOCCUPATION
/*LEFT JOIN CLMD0010 ct WITH (NOLOCK) ON a.iselector&ct.iclmtypemask>0*/
WHERE a.siSTATUS=0 ORDER BY a.igcoid/*, ct.vaclmtype*/, b.vaDESC
</cfquery>
<!--- <cfset occupationlist=ValueList(q_trx.ID)> --->
<cfset occupationlist=StructNew()>
<cfoutput query="q_trx" group="igcoid">
<!--- 	<cfif igcoid IS 0>
		<cfset StructInsert(occupationlist,"list",StructNew())>
		<cfset nodestr=occupationlist[igcoid]>
	<cfelse> --->
		<cfset StructInsert(occupationlist,igcoid,StructNew())>
		<cfset nodestr=occupationlist[igcoid]>
<!--- 	</cfif> --->
	<cfoutput group="iselector">
		<cfif iselector IS "">
			<cfset StructInsert(nodestr,"list","")>
			<cfset nodestr=nodestr>
		<cfelse>
			<cfset StructInsert(nodestr,"iselector",StructNew())>
			<cfset StructInsert(nodestr.iselector,"#iselector#",StructNew())>
			<cfset StructInsert(nodestr.iselector[iselector],"list","")>
			<cfset nodestr=nodestr.iselector[iselector]>
		</cfif>
		<cfset itmlist="">
		<cfoutput>
			<cfset itmlist=listappend(itmlist,q_trx.ID)>
		</cfoutput>
		<cfset nodestr.list="#itmlist#">
	</cfoutput>
</cfoutput>

<cfset DS=StructNew()>
<cfset DS.CO=co>
<cfset DS.OCCUPATION=occupation>
<cfset DS.OCCUPATIONLIST=occupationlist>
<CFSET DS.GLOBAL_GRPDOMLIST="31,203">

<!--- Set Application Variables --->
<cfif IsDefined("CURAPPLICATION.APPPATH")><!--- and IsDefined("CURAPPLICATION.MICPATH")--->
<cfmodule TEMPLATE="#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/CustomTags/SVCcffunctions.cfm" DS=#DS#>
<cfmodule TEMPLATE="#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#MInsCore/CustomTags/MICcffunctions.cfm" DS=#DS#>
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
</cfif>

<!--- Update docs:
		DS.FDOC_CLASSES{iDOCCLASSID:DESC,DEFPRINTPAGES,ALLOWCRTMANAGE}  ...(iDOCCLASSID),
		DS.FDOC_DOCDEFS{iDOCDEFID:DOCCLASSID,DESC,SHORTCAT,STATUS} ...(iDOCDEFID),
		DS_FDOC_DOMDOCS{iDOMAINID:{iDOCDEFID:BCRREAD,BCRCREATE,BCRCONTROL,BCRJOINREVOKE}} ...(iDOMAINID,iDOCDEFID)
	 --->
<CFSET DS.FN.SVCUpdateDS_Docs(DS,CURDSN)>

<cfquery NAME=q_countries DATASOURCE=#CURDSN#>
select icountryid,vadesc
	,InsCoList = STUFF((select ',' + cast(igcoid as varchar) from sec0005 where ipcoid=0 AND siCOTYPEID=2 AND siSTATUS=0 AND siACCEPTCASE=1 AND iCOUNTRYID=a.icountryid order by vaconame for xml path(''), ELEMENTS), 1, 1, '')
	,AdjCoList = STUFF((select ',' + cast(igcoid as varchar) from sec0005 where ipcoid=0 AND siCOTYPEID=3 AND siSTATUS=0 AND siACCEPTCASE=1 AND iCOUNTRYID=a.icountryid order by vaconame for xml path(''), ELEMENTS), 1, 1, '')
from sys0005 a
</cfquery>
<cfset DS.COUNTRIES=ArrayNew(1)>
<cfoutput query=q_countries>
	<cfset DS.COUNTRIES[iCOUNTRYID]=StructNew()>
	<cfset DS.COUNTRIES[iCOUNTRYID].NAME=vaDESC>
	<cfset DS.COUNTRIES[iCOUNTRYID].InsCoList=InsCoList>
	<cfset DS.COUNTRIES[iCOUNTRYID].AdjCoList=AdjCoList>
</cfoutput>
<cfquery NAME=q_states DATASOURCE=#CURDSN#>
SELECT a.iSTATEID,a.vaDESC,a.iCOUNTRYID FROM SYS0002 a WITH (NOLOCK)
</cfquery>
<cfset DS.STATES=ArrayNew(1)>
<cfset DS.STATECOUNTRY=ArrayNew(1)>
<cfoutput query=q_states>
	<cfset DS.STATES[iSTATEID]=vaDESC>
	<cfset DS.STATECOUNTRY[iSTATEID]=iCOUNTRYID>
</cfoutput>
<cfquery NAME=q_cities DATASOURCE=#CURDSN#>
SELECT a.iCITYID,a.iSTATEID,a.vaDESC, a.nLGTTAXPC FROM SYS0003 a WITH (NOLOCK)
</cfquery>
<cfset DS.CITIES=ArrayNew(1)>
<cfset DS.CITYSTATE=ArrayNew(1)>
<cfset DS.CITYSTATELGT=ArrayNew(1)>
<cfoutput query=q_cities>
	<cfset DS.CITIES[iCITYID]=vaDESC>
	<cfset DS.CITYSTATE[iCITYID]=iSTATEID>
	<cfset DS.CITYSTATELGT[iCITYID]=nLGTTAXPC>
</cfoutput>


<!--- Set Locales --->
<cfset DS.LOCALES=StructNew()>
<cfquery NAME="q_countries" DATASOURCE=#CURDSN#>
SELECT a.ILOCID,a.VALOCNAME,a.VACURRENCY,a.VACURRENCYINTL,a.VACURRENCYFORMAT,a.VACURRENCYNAME,a.VAROADAUTH,
	a.NTIMEZONE,a.VADTFORMAT,a.VADTFORMATLONG,a.VADTFORMATSHORT,a.VATMFORMAT, a.vaPOLICERPTNAME, a.vaLOSSTYPENAME,
	a.iPDBLOCID,a.iPDBPSCID,a.IPDBESTFLAG, a.vaDRIVERNAME,a.mnKFKMANDATE,a.iKFKREPLYDAYS,a.vaEXCESSNAME,
	a.vaVATTAXNAME,a.iVATTAXFLAG,a.vaSVCTAXNAME,a.nSVCTAXPC,a.nVATTAXPC,a.vaHPHONEPREFIXLIST,a.vaHPHONEPATTERN,a.iDEFCOUNTRYID,a.mnDEFTOWING,a.vaBTTRRATE,a.vaIDDEF,a.vaPIAMNAME,a.vaREPCARDSTAGESLIST,a.vaLOCSHORTCODE,a.siVCTREADUNIT,
	a.iCurrencyID, a.vaSTAMPDUTYNAME,a.mnSTAMPDUTYAMT,siLGTTAXFLAG=isnull(a.siLGTTAXFLAG,0)
	,labellist = STUFF(( select ','+cast(iLBLDEFID as varchar) from fobjb3020 with (nolock) where SISTATUS=0 AND SIPRIVATE=0 AND ILOCID=a.ILOCID for xml path(''), ELEMENTS), 1, 1, '')
FROM SYS0009 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_countries>
	<cfset DS.LOCALES[ILOCID]=StructNew()>
	<cfset DS.LOCALES[ILOCID].NAME=vaLOCNAME>
	<cfset DS.LOCALES[ILOCID].LOCSHORTCODE=vaLOCSHORTCODE>
	<cfset DS.LOCALES[ILOCID].Currency=vaCURRENCY>
	<cfset DS.LOCALES[ILOCID].CurrencyIntl=vaCURRENCYINTL>
	<cfset DS.LOCALES[ILOCID].CurrencyFormat=vaCURRENCYFORMAT>
	<cfset DS.LOCALES[ILOCID].CurrencyFull=vaCURRENCYNAME>
	<cfset DS.LOCALES[ILOCID].CurrencyId=iCurrencyID>
	<cfset DS.LOCALES[ILOCID].RoadAuth=vaROADAUTH>
	<cfset DS.LOCALES[ILOCID].TIMEZONE=nTIMEZONE>
	<cfset DS.LOCALES[ILOCID].DTFORMAT=vaDTFORMAT>
	<cfset DS.LOCALES[ILOCID].DTFORMATLONG=vaDTFORMATLONG>
	<cfset DS.LOCALES[ILOCID].DTFORMATSHORT=vaDTFORMATSHORT>
	<cfset DS.LOCALES[ILOCID].TMFORMAT=vaTMFORMAT>
	<cfset DS.LOCALES[ILOCID].PoliceRptName=vaPOLICERPTNAME>
	<cfset DS.LOCALES[ILOCID].LossTypeName=vaLOSSTYPENAME>
	<cfset DS.LOCALES[ILOCID].PDBLOCID=iPDBLOCID>
	<cfset DS.LOCALES[ILOCID].PDBPSCID=iPDBPSCID>
	<cfset DS.LOCALES[ILOCID].PDBESTFLAG=iPDBESTFLAG>
	<cfset DS.LOCALES[ILOCID].DriverName=vaDRIVERNAME>
	<cfset DS.LOCALES[ILOCID].KFKREPLYDAYS=iKFKREPLYDAYS>
	<cfset DS.LOCALES[ILOCID].KFKMANDATE=mnKFKMANDATE>
	<cfset DS.LOCALES[ILOCID].EXCESSNAME=vaEXCESSNAME>
	<cfset DS.LOCALES[ILOCID].STAMPDUTYNAME=Trim(vaSTAMPDUTYNAME)>
	<cfset DS.LOCALES[ILOCID].VATTAXNAME=Trim(vaVATTAXNAME)>
	<cfset DS.LOCALES[ILOCID].SVCTAXNAME=Trim(vaSVCTAXNAME)>
	<cfset DS.LOCALES[ILOCID].SVCTAXPC=nSVCTAXPC>
	<cfset DS.LOCALES[ILOCID].VATTAXPC=nVATTAXPC>
	<cfset DS.LOCALES[ILOCID].VATTAXFLAG=iVATTAXFLAG>
	<cfset DS.LOCALES[ILOCID].VCTREADUNIT=siVCTREADUNIT>
	<cfset DS.LOCALES[ILOCID].HPHONEPREFIXLIST=Trim(vaHPHONEPREFIXLIST)>
	<cfset DS.LOCALES[ILOCID].HPHONEPATTERN=Trim(vaHPHONEPATTERN)>
	<cfset DS.LOCALES[ILOCID].DEFCOUNTRYID=iDEFCOUNTRYID>
	<cfset DS.LOCALES[ILOCID].DEFTOWING=mnDEFTOWING>
	<cfset DS.LOCALES[ILOCID].BTTRRATE=vaBTTRRATE>
	<cfset DS.LOCALES[ILOCID].IDDEF=vaIDDEF>
	<cfset DS.LOCALES[ILOCID].PIAMNAME=vaPIAMNAME>
	<cfset DS.LOCALES[ILOCID].LABELLIST=LABELLIST>
	<CFIF ILOCID IS 7>
		<cfset DS.LOCALES[ILOCID].CURRROUNDDP=0>
	<CFELSE>
		<cfset DS.LOCALES[ILOCID].CURRROUNDDP=2>
	</CFIF>
	<cfset DS.LOCALES[ILOCID].REPSTAGELIST=vaREPCARDSTAGESLIST>
	<cfset DS.LOCALES[ILOCID].STAMPDUTYAMT=mnSTAMPDUTYAMT>
	<cfset DS.LOCALES[ILOCID].siLGTTAXFLAG=siLGTTAXFLAG>
</cfoutput>

<CFQUERY NAME="q_currency" DATASOURCE="#CURDSN#">
	SELECT *
	FROM SYS0029 WITH (NOLOCK)
	WHERE siStatus = 0
</CFQUERY>
<CFSET DS.Currencies = ArrayNew(1)>
<CFOUTPUT query="q_currency">
	<cfset DS.Currencies[iCurrencyID] = StructNew()>
	<cfset DS.Currencies[iCurrencyID].Currency=vaCURRENCY>
	<cfset DS.Currencies[iCurrencyID].CurrencyIntl=vaCURRENCYINTL>
	<cfset DS.Currencies[iCurrencyID].CurrencyFormat=vaCURRENCYFORMAT>
	<cfset DS.Currencies[iCurrencyID].CurrencyFull=vaCURRENCYNAME>
</CFOUTPUT>

<cfquery name=q_labeldtls datasource=#CURDSN#>
select ilbldefid,idomainid,ilocid,siprivate,bcocreate,bcoread,icolortxt,icolorbgrnd,valblname
,GCOID = STUFF(( select ','+cast(iGCOID as varchar) from FOBJB3022 with (nolock) where ILBLDEFID = a.iLBLDEFID and SISTATUS=0 for xml path(''), ELEMENTS), 1, 1, '')
from fobjb3020 a with (nolock) where sistatus = 0
</cfquery>
<cfset DS.LABELS=StructNew()>
<cfoutput query=q_labeldtls>
	<cfset DS.LABELS[iLBLDEFID]=StructNew()>
	<cfset DS.LABELS[iLBLDEFID].DOMAINID=iDOMAINID>
	<cfset DS.LABELS[iLBLDEFID].LOCID=iLOCID>
	<cfset DS.LABELS[iLBLDEFID].GCOID=GCOID>
	<cfset DS.LABELS[iLBLDEFID].PRIVATE=siPRIVATE>
	<cfset DS.LABELS[iLBLDEFID].COCREATE=bCOCREATE>
	<cfset DS.LABELS[iLBLDEFID].COREAD=bCOREAD>
	<cfset DS.LABELS[iLBLDEFID].COLORTXT=iCOLORTXT>
	<cfset DS.LABELS[iLBLDEFID].COLORBGRND=iCOLORBGRND>
	<cfset DS.LABELS[iLBLDEFID].LBLNAME=vaLBLNAME>
</cfoutput>

<cfquery name=Q_TERMS datasource=#CURDSN#>
	select * from pold4003 with (nolock) where sistatus = 0
	order by itermset, siLANGID
</cfquery>
<cfset tmpColumnArr = Q_TERMS.GetColumnList()>
<cfset tmpTermArr = arrayNew(1)>
<CFLOOP array="#tmpColumnArr#" index=i>
	<CFIF listfindnocase("iPRODCLSID,siSTATUS,iTERMSET,siLANGID",i) eq 0>
		<cfset arrayAppend(tmpTermArr, i)>
	</CFIF>
</CFLOOP>
<cfset DS.TERMS=StructNew()>
<!--- <cfset DS.TERMS.WORDSET=StructNew()>--->
<cfoutput query=Q_TERMS GROUP="ITERMSET">
	<cfset DS.TERMS[ITERMSET]=StructNew()>
	<CFOUTPUT group="siLANGID">
		<cfset DS.TERMS[ITERMSET][siLANGID]=StructNew()>
		<CFLOOP FROM=1 TO=#ARRAYLEN(tmpTermArr)# index=i>
			<cfset DS.TERMS[ITERMSET][siLANGID][tmpTermArr[i]] = evaluate(tmpTermArr[i])>
		</CFLOOP>
	</CFOUTPUT>
	<!--- 0 would have been available --->
	<cfloop list="1,2,3,4,5,6" index=i>
		<cfif not structKeyExists(DS.TERMS[ITERMSET],i)>
			<cfset DS.TERMS[ITERMSET][i]=Duplicate(DS.TERMS[ITERMSET][0])>
		</cfif>
	</cfloop>
</cfoutput>
<!---
<cfset DS.TERMS.STATUSSET=StructNew()>
<cfoutput query=Q_TERMS group="itermset">
	<cfset DS.TERMS.STATUSSET[ITERMSET]=StructNew()>
	<cfoutput group="sipolstat">
	<cfset DS.TERMS.STATUSSET[ITERMSET].POLSTAT[SIPOLSTAT]=StructNew()>
	<cfset DS.TERMS.STATUSSET[ITERMSET].POLSTAT[SIPOLSTAT].VAPOLSTATDESC=VAPOLSTATDESC>
	<cfset DS.TERMS.STATUSSET[ITERMSET].POLSTAT[SIPOLSTAT].VAPOLSTATSUBDESC=VAPOLSTATSUBDESC>
	</cfoutput>
</cfoutput>
--->
<cfquery name=Q_POLSTATSET datasource=#CURDSN#>
	select ipolstatset, sipolstat, vapolstatdesc, vapolstatsubdesc, siLANGID, siEVALSUBDESC from pold4002 with (nolock) where sistatus = 0
	order by ipolstatset, siLANGID, sipolstat asc
</cfquery>
<cfset DS.POLSTATSET=StructNew()>
<cfoutput query=Q_POLSTATSET group="ipolstatset">
	<cfset DS.POLSTATSET[ipolstatset]=StructNew()>
	<cfoutput group="siLANGID">
		<cfset DS.POLSTATSET[ipolstatset][siLANGID] = StructNew()>
		<cfoutput group="sipolstat">
			<cfset DS.POLSTATSET[iPOLSTATSET][siLANGID][SIPOLSTAT]=StructNew()>
			<cfset DS.POLSTATSET[iPOLSTATSET][siLANGID][SIPOLSTAT].DESC=VAPOLSTATDESC>
			<cfset DS.POLSTATSET[iPOLSTATSET][siLANGID][SIPOLSTAT].SUBDESC=VAPOLSTATSUBDESC>
			<cfset DS.POLSTATSET[iPOLSTATSET][siLANGID][SIPOLSTAT].EVALSUBDESC=SIEVALSUBDESC>
		</cfoutput>
	</cfoutput>

	<!--- 0 would have been available --->
	<cfloop list="1,2,3,4,5,6" index=i>
		<cfif not structKeyExists(DS.POLSTATSET[iPOLSTATSET],i)>
			<cfset DS.POLSTATSET[iPOLSTATSET][i]=Duplicate(DS.POLSTATSET[iPOLSTATSET][0])>
		</cfif>
	</cfloop>
</cfoutput>

<!--- server files --->
<CFQUERY NAME=q_svrfiles DATASOURCE=#CURDSN#>
SELECT vaSVRFILEGRP,vaSVRFILELOGICNAME,vaSVRFILENAME,vaSVRFILEEXT,iSVRFILEVERSION,vaSVRFILETYPE,vaSVRFILELOGPATH,vaSVRFILEWEBROOT from FSYS0007 WITH (NOLOCK)
WHERE siSTATUS=0 order by vaSVRFILEGRP
</CFQUERY>
<CFSET DS.SVRFILES=StructNew()>
<CFLOOP query=q_svrfiles>
	<CFSET REFKEY="#UCASE(vaSVRFILEGRP)#_#UCASE(vaSVRFILELOGICNAME)#">
	<CFSET DS.SVRFILES[REFKEY]=StructNew()>
	<CFSET DS.SVRFILES[REFKEY].GRP=vaSVRFILEGRP>
	<CFSET DS.SVRFILES[REFKEY].LOGICNAME=vaSVRFILELOGICNAME>
	<CFSET DS.SVRFILES[REFKEY].FILENAME=vaSVRFILENAME>
	<CFSET DS.SVRFILES[REFKEY].EXT=vaSVRFILEEXT>
	<CFSET DS.SVRFILES[REFKEY].VER=iSVRFILEVERSION>
	<CFSET DS.SVRFILES[REFKEY].TYPE=vaSVRFILETYPE>
	<CFSET DS.SVRFILES[REFKEY].LOGPATH=vaSVRFILELOGPATH>
	<CFSET DS.SVRFILES[REFKEY].WEBROOT=vaSVRFILEWEBROOT>
</CFLOOP>

<!--- Store ID types --->
<CFSET StructInsert(DS,"IDtypes",StructNew())>
<cfquery name=q_labeldtls datasource=#CURDSN#>
SELECT a.iIDTYPEID,a.vaIDNAME,a.vaIDCHKSTR,a.siIDTYPE,a.iLANGID,a.iCOUNTRYID
FROM FSYS0008 a WITH (NOLOCK)
WHERE a.siSTATUS=0
</cfquery>
<CFOUTPUT query=q_labeldtls>
	<cfset strct=StructNew()>
	<cfset strct.Name=Trim(vaIDNAME)>
	<cfset strct.IdType=Trim(siIDTYPE)>
	<CFIF siIDTYPE IS NOT "">
		<cfset strct.IdChkStr=Trim(vaIDCHKSTR)>
	</CFIF>
	<CFIF iCOUNTRYID IS NOT "">
		<cfset strct.CountryID=Trim(iCOUNTRYID)>
	</CFIF>
	<cfset StructInsert(DS.IDtypes,iIDTYPEID,strct)>
</CFOUTPUT>

<CFSET StructInsert(DS,"TSKSTAT",StructNew())>
<cfquery name=q_taskstatus datasource=#CURDSN#>
SELECT a.ITSKSTATID,a.ITSKRULEGRPID,a.VATSKSTATDESC,a.VATSKSTATLOGICNAME,a.SIISCLOSED,a.IORDER,a.siSTATUS
FROM FTSK1006 a WITH (NOLOCK)
ORDER BY a.ITSKRULEGRPID,a.IORDER,a.SIISCLOSED,a.iTSKSTATID
</cfquery>
<CFLOOP query=q_taskstatus>
	<cfset strct=StructNew()>
	<cfset strct.Name=Trim(VATSKSTATLOGICNAME)>
	<cfset strct.Desc=Trim(VATSKSTATDESC)>
	<cfset strct.TskRuleGrpID=Trim(ITSKRULEGRPID)>
	<CFIF SIISCLOSED IS "">
		<cfset strct.IsClosed=0>
	<CFELSE>
		<cfset strct.IsClosed=SIISCLOSED>
	</CFIF>
	<cfset StructInsert(DS.TSKSTAT,ITSKSTATID,strct)>
</CFLOOP>

<CFIF application.appdevmode EQ 0>
	<CFSET StructInsert(DS,"ENFORCESSL","EPLTMFHK,EPLTMTH,EPLOAC,MARAXA,EPLUICVN")>
<CFELSE>
	<CFSET StructInsert(DS,"ENFORCESSL","")>
</CFIF>

<CFSET StructInsert(DS,"TSKRULEGRP",StructNew())>
<cfquery name=q_taskgrp datasource=#CURDSN#>
SELECT a.ITSKRULEGRPID,a.VATSKRULEGRPDESC,a.VATSKRULEGRPLOGICNAME
FROM FTSK1005 a WITH (NOLOCK)
ORDER BY a.ITSKRULEGRPID
</cfquery>
<CFLOOP query=q_taskgrp>
	<cfset strct=StructNew()>
	<cfset strct.Name=Trim(VATSKRULEGRPLOGICNAME)>
	<cfset strct.Desc=Trim(VATSKRULEGRPDESC)>
	<cfset StatList="">
	<CFSET TSKRULEGRPID=ITSKRULEGRPID>
	<CFLOOP query=q_taskstatus>
		<CFIF siSTATUS IS 0 AND iTSKRULEGRPID IS TSKRULEGRPID>
			<CFSET StatList=ListAppend(StatList,iTSKSTATID,"|")>
		</CFIF>
	</CFLOOP>
	<CFSET strct.StatList=StatList>
	<cfset StructInsert(DS.TSKRULEGRP,ITSKRULEGRPID,strct)>
</CFLOOP>

<!---Struct Label List--->
<cfset objLabels = createObject("component","#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/cfc/labels")>
<cfset objLabels.init(CURDSN)>
<cfset DS.LABELS = objLabels.resetVars()>

<!--- Store COROLES --->
<CFSET COROLES=StructNew()>
<CFSET COROLESByCODE=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.iDOMAINID,a.iCOROLE,a.vaCOROLECODE,a.vaLONGDESC,iLID=isNULL(a.iLID,0) FROM FOBJ3003 a WITH (NOLOCK)
ORDER BY a.iDOMAINID,a.iCOROLE
</cfquery>
<CFLOOP query=q_trx>
	<CFSET StructInsert(COROLES,"#q_trx.iDOMAINID#,#q_trx.iCOROLE#",{CODE="#Trim(q_trx.vaCOROLECODE)#",DESC="#Trim(q_trx.vaLONGDESC)#",LID="#Trim(q_trx.iLID)#"})>
	<CFSET StructInsert(COROLESByCODE,"#q_trx.iDOMAINID#,#Trim(q_trx.vaCOROLECODE)#",{COROLE="#q_trx.iCOROLE#",DESC="#Trim(q_trx.vaLONGDESC)#",LID="#Trim(q_trx.iLID)#"})>
</CFLOOP>
<CFSET StructInsert(DS,"COROLES",COROLES)>
<CFSET StructInsert(DS,"COROLESByCODE",COROLESByCODE)>


<!--- Store CVYTYPEID --->
<CFSET CVYTYPE=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT iCVYTYPEID,vaCVYTYPEDESC FROM ZMAR2001 a with (NOLOCK) order by a.iCVYTYPEID
</cfquery>
<CFLOOP query=q_trx>
	<CFSET StructInsert(CVYTYPE,"#q_trx.iCVYTYPEID#","#q_trx.vaCVYTYPEDESC#")>
</CFLOOP>
<CFSET StructInsert(DS,"CVYTYPE",CVYTYPE)>

<!--- begin: cache java loader and classes --->
<cfset paths 	= arrayNew(1)>
<cfset paths[1] = expandPath("#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/QR/core-2.1.jar")>
<cfset paths[2] = expandPath("#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/QR/javase-2.1.jar")>

<cfset ds.loader= createObject("component", "#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services\cfc\Javaloader").init(paths)>
<!--- end  : cache java loader and classes --->

<!--- Language DS stuff --->
<CFSET DS.FN.SVClangDSUpdate(DS,CURDSN)>

<!--- Client JS appvars --->
<cfif IsDefined("Application.SETVARS_WRITEJS") AND Application.SETVARS_WRITEJS IS 0>

	<!--- SVCappvars --->
	<CFSET CURFILE="#ExpandPath(CURAPPLICATION.CFPREFIX&CURAPPLICATION.APPPATH&CURAPPLICATION.SVCPATH)#scripts\SVCappvars.js">
	<CFSET DS.FN.SVCwriteJSappvars(DS,CURDSN,CURFILE)>

	<!--- MICappvars --->
	<CFOUTPUT><cfsavecontent variable="tmp">
	if(!request.DS) request.DS={};
	request.DS.LANGLIST="#DS.LANGLIST#"; <!--- Available language selection (updated from SVClangDSUpdate) --->
	</cfsavecontent></CFOUTPUT>
	<CFSET CURFILE="#ExpandPath(CURAPPLICATION.CFPREFIX&CURAPPLICATION.APPPATH&CURAPPLICATION.MICPATH)#\scripts\MICappvars.js">
	<cffile CHARSET="UTF16" ACTION="write" FILE="#CURFILE#" OUTPUT=#tmp# ADDNEWLINE=NO>

	<!--- MICPorts --->
	<cfquery name="q_ports" datasource=#CURDSN#>
		select a.iportid,a.vaportname,a.icountryid from FZMAR_PORTS a with (nolock)
		where a.sistatus=0 and a.sitype=1 and a.icountryid is not null
		order by a.icountryid,a.vaportname asc
	</cfquery>
	<cfsavecontent variable="tmp">var SEAPORTS={0:""<cfoutput query=q_ports group="icountryid">,#icountryid#:{portname:[""<cfoutput>,"#jsstringformat(vaportname)#"</cfoutput>],portid:[""<cfoutput>,"#iportid#"</cfoutput>]}</cfoutput>};</cfsavecontent>
	<CFSET CURFILE="#ExpandPath(CURAPPLICATION.CFPREFIX&CURAPPLICATION.APPPATH&CURAPPLICATION.MICPATH)#\scripts\MICPorts.js">
	<cffile CHARSET="UTF16" ACTION="write" FILE="#CURFILE#" OUTPUT=#tmp# ADDNEWLINE=NO>

	<cfset Application.SETVARS_WRITEJS=1>
</cfif>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT DB_APP=dbo.fGetDBSettings('APP'),DB_COUNTRY=dbo.fGetDBSettings('COUNTRY'),DB_MODE=dbo.fGetDBSettings('MODE')
</cfquery>
<CFSET Application.DB_APP=q_trx.DB_APP>
<CFSET Application.DB_COUNTRY=q_trx.DB_COUNTRY>
<CFSET Application.DB_MODE=q_trx.DB_MODE>

<!---cfif IsDefined("APPLICATION.CURDS")>
	<cfset APPLICATION.CURDS=APPLICATION.CURDS MOD 2+1>
<cfelse>
	<cfset APPLICATION.CURDS=1>
< /cfif>
<cfif Application.CURDS IS 1>
	<cfset Application.DS1=DS>
<cfelse>
	<cfset Application.DS2=DS>
</cfif>
<cfset Application.Setvars=1>
< /cfif>
< /cflock---></cfsilent>