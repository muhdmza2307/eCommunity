﻿<cfscript>
Attributes.DS.FN=StructNew();
function SVCSetReqLocID(locid)
{
	var tmp=0;
	if(StructKeyExists(Request,"LOCID"))
	{
		tmp=Request.LOCID;
		Request.LOCID=locid;
		return tmp;
	} else
	{
		Request.LOCID=locid;
		return -1;
	}
}
Attributes.DS.FN.SVCSetReqLocID=SVCSetReqLocID;
function SVCdtDBtoLOC(db) // ... locid,dtformat,tmformat,shiftsecs
{
	var locid=0;
	var dtformat="";
	var tmformat="";
	var shiftsecs=0;
	var isbudd=0;
	var budmonth="";
	var arrlen=ArrayLen(Arguments);
	if(db IS "")
		return "";
	if(arrlen LTE 1 OR Arguments[2] LTE 0)
	{
		if(StructKeyExists(Request,"LOCID"))
			locid=Request.LOCID;
		else if(IsDefined("SESSION.VARS.LOCID"))
			locid=SESSION.VARS.LOCID;
		else
			locid=1;
	}
	else
		locid=Arguments[2];
	if(arrlen LTE 2 OR Arguments[3] IS 0)
		dtformat=Request.DS.LOCALES[locid].DTFORMAT;
	else
	{
		dtformat=Arguments[3];
		if(dtformat IS "STD")
			dtformat=Request.DS.LOCALES[locid].DTFORMAT;
		else if(dtformat IS "LONG")
			dtformat=Request.DS.LOCALES[locid].DTFORMATLONG;
		else if(dtformat IS "SHORT")
			dtformat=Request.DS.LOCALES[locid].DTFORMATSHORT;
		else if(dtformat IS "BUDDHIST")
			isbudd=1;
	}
	if(arrlen LTE 3 OR Arguments[4] IS 0)
		tmformat="";
	else
	{
		tmformat=Arguments[4];
		if(tmformat IS "STD")
			tmformat=Request.DS.LOCALES[locid].TMFORMAT;
	}
	if(tmformat IS "" AND dtformat IS "")
		return "";
	if(arrlen LTE 4)
		shiftsecs=(Request.DS.LOCALES[locid].TIMEZONE-Application.SERVERTIMEZONE)*60*60;
	else
		shiftsecs=(Request.DS.LOCALES[locid].TIMEZONE-Application.SERVERTIMEZONE)*60*60+Arguments[5];
	if(shiftsecs IS NOT 0)
		db=DateAdd("s",shiftsecs,db);
	if(isbudd is 1){
		db=DateAdd("yyyy",543,db);

		switch(month(db)){
			case 1: budmonth="มกราคม";break;
			case 2: budmonth="กุมภาพันธ์";break;
			case 3: budmonth="มีนาคม";break;
			case 4: budmonth="เมษายน";break;
			case 5: budmonth="พฤษภาคม";break;
			case 6: budmonth="มิถุนายน";break;
			case 7: budmonth="กรกฎาคม";break;
			case 8: budmonth="สิงหาคม";break;
			case 9: budmonth="กันยายน";break;
			case 10: budmonth="ตุลาคม";break;
			case 11: budmonth="พฤศจิกายน";break;
			case 12: budmonth="ธันวาคม";break;
		}

		if(tmformat IS "")
		{
			return DateFormat(db,"dd") & " " & budmonth & " " & DateFormat(db,"yyyy");
		} else
		{
			return DateFormat(db,"dd") & " " & budmonth & " " & DateFormat(db,"yyyy") & " " & TimeFormat(db,tmformat);
		}

	}
	else {
		if(tmformat IS "")
		{
			return DateFormat(db,dtformat);
		} else
		{
			if(dtformat IS "")
				return TimeFormat(db,tmformat);
			else
				return DateFormat(db,dtformat) & " " & TimeFormat(db,tmformat);
		}
	}
}
Attributes.DS.FN.SVCdtDBtoLOC=SVCdtDBtoLOC;
function SVCdtLOCtoDB(dt) // ... locid,dtformat,tmformat,shiftsecs,dt day end
{
	var locid=0;
	var dtformat="";
	var tmformat="";
	var shiftsecs=0;
	var dpart="";
	var arrlen=ArrayLen(Arguments);
	if(dt IS "")
		return "";
	if(arrlen LTE 1 OR Arguments[2] LTE 0)
	{
		if(StructKeyExists(Request,"LOCID"))
			locid=Request.LOCID;
		else if(IsDefined("SESSION.VARS.LOCID"))
			locid=SESSION.VARS.LOCID;
		else
			locid=1;
	}
	else
		locid=Arguments[2];
	if(arrlen LTE 2 OR Arguments[3] IS 0)
		dtformat=Request.DS.LOCALES[locid].DTFORMAT;
	else
	{
		dtformat=LCase(Arguments[3]);
		if(dtformat IS "STD")
			dtformat=Request.DS.LOCALES[locid].DTFORMAT;
		else if(dtformat IS "LONG")
			dtformat=Request.DS.LOCALES[locid].DTFORMATLONG;
		else if(dtformat IS "SHORT")
			dtformat=Request.DS.LOCALES[locid].DTFORMATSHORT;
	}
	if(arrlen LTE 3 OR Arguments[4] IS 0)
		tmformat="";
	else
	{
		tmformat=Arguments[4];
		if(tmformat IS "STD")
			tmformat=Request.DS.LOCALES[locid].TMFORMAT;
	}
	if(tmformat IS "" AND dtformat IS "")
		return "";
	if(arrlen LTE 4)
		shiftsecs=(Application.SERVERTIMEZONE-Request.DS.LOCALES[locid].TIMEZONE)*60*60;
	else {
		shiftsecs=(Application.SERVERTIMEZONE-Request.DS.LOCALES[locid].TIMEZONE)*60*60+Arguments[5];
	}
	if(Arguments[6]==1){ //dt day end adds 11:59
		shiftsecs+=86399;
	}
	// Swap ddmm for european time
	if(Left(dtformat,4) IS "ddmm")
	{
		dt=Mid(dt,3,2)&Left(dt,2)&Right(dt,abs(Len(dt)-4));
	}
	else
	{
		dpart=Left(dtformat,5);
		if(dpart IS "dd/mm" OR dpart IS "dd.mm" OR dpart IS "dd-mm")
			dt=Mid(dt,4,2)&Mid(dt,3,1)&Left(dt,2)&Right(dt,abs(Len(dt)-5));
	}
	// Andrew 28 June 2011 if not valid date then return empty string
	if(IsDate(dt))
	{
		if(shiftsecs IS 0)
			return dt;
		else{
			 dt=DateAdd("s",shiftsecs,dt);
			 dt=DateFormat(dt,"yyyy/mm/dd")&" "&TimeFormat(dt,"HH:mm");
			 return dt;
		}
	} else
		return "";
}
Attributes.DS.FN.SVCdtLOCtoDB=SVCdtLOCtoDB;
function SVCGetNumFormat() // ...locid,currid)
{
	var locid="";
	var currid = "";
	var arr = "";
	var curr = "";
	var tmp = "";
	var tmp2 = "";
	var ddp = 0;
	var strdp = "";
	var dpsym = "";
	if(ArrayLen(Arguments) GT 0)
		locid=Arguments[1];
	if(ArrayLen(Arguments) GT 1)
		currid=Arguments[2];
	if(locid IS "")
	{
		if(StructKeyExists(Request,"LOCID"))
			locid=REQUEST.LOCID;
		else
			locid=1;
	}
	switch(locid)
	{
		case 4:return (ListToArray("-|.|2|,|3,2","|"));break;	// Indian numeric format
//		default:return (ListToArray("-|.|0|,|3","|"));break;	// Default numeric format

//		case 7:return (ListToArray("-|.|0|,|3","|"));break;	// Indonesian
		default: //default format, but some country might using indian numeric system as well
			curr = Request.DS.FN.SVCGetCurr(currid);

			if(isDefined("curr.CurrencyFormat"))
			{
				tmp = REMatchNoCase('\D', curr.CurrencyFormat);

				tmp = ArrayToList(tmp, '');

				tmp2 = REFindNoCase('\' & Right(tmp, 1), curr.CurrencyFormat, 1);

				if(ArrayLen(REMatchNoCase('^(\D)\1*[^\1]$', tmp)) GT 0)
				{
					if(Left(tmp, 1) NEQ Right(tmp, 1))
					{
						dpsym = Right(tmp,1);
						strdp = curr.CurrencyFormat;

						//remove 0 after decimal point to get true decimal point (.9900 -> .99)
						if( listlen(curr.CurrencyFormat, dpsym) gte 1 )
							strdp = listfirst(curr.CurrencyFormat, dpsym) & dpsym & replace(listlast(curr.CurrencyFormat, dpsym),"0","","all");

						arr = "-|" & Right(tmp, 1) & "|" & (Len(strdp) - tmp2);

						// displayed decimal point
						ddp = Len(curr.CurrencyFormat) - tmp2;
					}
					else
					{
						arr = "-|.|0";
						ddp = "0";
					}

					if(Len(tmp) GT 0)
					{
						// building the 4th item in the array (separator symbol)
						arr = arr & "|" & Left(tmp, 1);
						// building the 5th item in the array (separator pattern)
						if(tmp2 GT 0 AND Left(tmp, 1) NEQ Right(tmp, 1))
							strnodec = Left(curr.CurrencyFormat, tmp2 - 1);
						else
							strnodec = curr.CurrencyFormat;

						arr = arr & "|";

						while(Len(strnodec) GT 0)
						{
							if(Len(ListFirst(strnodec, Left(tmp, 1))) NEQ Len(ListLast(strnodec, Left(tmp, 1))))
							{
								arr = arr & Len(ListLast(strnodec, Left(tmp, 1))) & "," ;
								strnodec = ListDeleteAt(strnodec, ListLen(strnodec, Left(tmp, 1)), Left(tmp, 1));
							}
							else
							{
								arr = arr & Len(ListFirst(strnodec, Left(tmp, 1)));
								strnodec = "";
							}
						}
					}
					else
						arr = arr & "|0|0";

					// build the 6th item in the array - displayed decimal places(HKTIX1)
					arr = arr & "|" & ddp;

					arr = ListToArray(arr, "|");
				}
				else
					arr = ListToArray("-|.|2|,|3|2","|");

			}
			else
				arr = ListToArray("-|.|2|,|3|2","|");

			return arr;
			break;	// Default numeric format
	}
	// Return array: Negative Symbol,Decimal Symbol,Default decimal-places for currency,Separator Symbol,Separator Pattern,displayed decimal places(HKTIX1)
}
Attributes.DS.FN.SVCGetNumFormat=SVCGetNumFormat;
function SVCNumLOCtoDB(val) // ...decsymbol,separator,locid)
{
	var decsymbol=0;
	var separator=0;
	var nformat="";
	var locid="";
	var fl=0;
	if(val IS "")
		return "";
	if(ArrayLen(Arguments) GT 3)
		locid=Arguments[4];
	nformat=Request.DS.FN.SVCGetNumFormat(locid);
	if(ArrayLen(Arguments) IS 1 OR Arguments[2] IS 0)
		decsymbol=nformat[2];
	else
		decsymbol=Arguments[2];
	if(ArrayLen(Arguments) LTE 2 OR Arguments[3] IS 0)
		separator=nformat[4];
	else
		separator=Arguments[3];
	if(separator IS NOT "")
		val=Replace(val,separator,"","ALL");
	if(decsymbol IS NOT ".")
		val=Replace(val,decsymbol,".","ALL");
	if(isNumeric(val))
		return val;
	else
		return "";
}
Attributes.DS.FN.SVCNumLOCtoDB=SVCNumLOCtoDB;
function SVCNumDBtoLOC(fl) // ...decplace,separator,locid,currid)
{
	var decplace="";
	var separator=0;
	var nformat="";
	var locid="";
	var neg="";
	var sepspace="";
	var curspace="";
	var prefix="";
	var currid="";
	var decfixed="";
	if(ArrayLen(Arguments) GT 3)
		locid=Arguments[4];
	if(ArrayLen(Arguments) GT 4)
		currid=Arguments[5];
	if(IsDefined("Request.OVERRIDE_NUMFORMAT") AND Request.OVERRIDE_NUMFORMAT IS NOT "")
		nformat=ListToArray(Request.OVERRIDE_NUMFORMAT,"|");
	//else if(StructKeyExists(Request, "CurrencyID") AND Request.CurrencyID NEQ 0)
		//nformat=Request.DS.FN.SVCGetNumFormat(locid,Request.CurrencyID);
	else
		nformat=Request.DS.FN.SVCGetNumFormat(locid,currid);

	if(ArrayLen(Arguments) IS 1 OR Arguments[2] IS "")
	{
		decplace=nformat[3];
		decfixed="";
	}
	else
	{
		decplace=Arguments[2];
		decfixed=decplace;
	}

	if(ArrayLen(Arguments) LTE 2 OR Arguments[3] IS 0)
		separator=nformat[4];
	else
		separator=Arguments[3];
	if(fl IS "" OR Not(IsNumeric(fl)))
		return "";
	if(decplace GT 0)
	{
		fl=Round(precisionevaluate(fl*(10^decplace)));

		if( FindNoCase("E", fl) ) // fix for numbers that become scientific notation because they were too big
			fl = replacenocase(numberformat(fl),",","","all");

		if(fl LT 0)
		{
			fl=-fl;
			neg="-";
		}
		fl=ToString(fl);
		if(Len(fl) LTE decplace)
		{
			intstr="0";
			postfix=fl;
			while(Len(postfix) LT decplace)
				postfix="0" & postfix;
			postfix=nformat[2] & postfix;
		} else
		{
			intstr=Left(fl,Len(fl)-decplace);
			postfix=nformat[2] & Right(fl,decplace);
		}
		// Add displayed decimal point (HKTIX1)
		if(arrayLen(nformat) gte 6 AND nformat[6] gt 0 AND decfixed eq "")
			postfix = replace( LJustify( postfix, nformat[6]+len(nformat[2]) ), ' ', '0', 'all' );
	} else
	{
		if(fl LT 0)
		{
			fl=-fl;
			neg="-";
		}
		intstr=ToString(Round(fl));

		if( FindNoCase("E", intstr) ) // fix for numbers that become scientific notation because they were too big
			intstr = replacenocase(numberformat(intstr),",","","all");

		if(neg IS "-" AND intstr IS 0)
			neg="";
		postfix="";

		// Add displayed decimal point (HKTIX1)
		if(arrayLen(nformat) gte 6 AND nformat[6] gt 0 AND decfixed eq "")
			postfix = nformat[2] & replace( LJustify( postfix, nformat[6]+len(nformat[2]) ), ' ', '0', 'all' );
	}


	// Add separators
	if(separator IS NOT 0 AND Len(separator) GT 0 AND Len(nformat[5]) GT 0)
	{	prefix="";
		sepspace=nformat[5];
		curspace=ListFirst(sepspace);
		sepspace=ListRest(sepspace);
		while(Len(intstr) GT 0)
		{	if(Len(intstr) GT curspace)
			{	prefix=separator & Right(intstr,curspace) & prefix;
				intstr=Left(intstr,Len(intstr)-curspace);
				if(sepspace IS NOT "")
				{
					curspace=ListFirst(sepspace);
					sepspace=ListRest(sepspace);
				}
			} else
			{	prefix=intstr & prefix;
				intstr="";
		}	}
	} else
		prefix=intstr;
	return (neg & prefix & postfix);
}
Attributes.DS.FN.SVCNumDBtoLOC=SVCNumDBtoLOC;
	//var neg,intstr,prefix,postfix,valstd,nformat,curspace,sepspace;
/*	neg="";
	if(fl==null)
			return ""
	else
	{
		if(IsNumeric() typeof(fl)!="number")
			fl=parseFloat(fl);
		if(isNaN(fl))
			return "";
	}
	// Handle decimals
	if(decplace==null)
		decplace=nformat[2];
	if(decplace>0)
	{
		fl=Math.round(fl*Math.pow(10,decplace))/Math.pow(10,decplace);
		if(fl<0)
		{
			fl=-fl;
			neg="-";
		}
		valstd=fl.toString().split(".");
		if(valstd.length==1)
			valstd[1]="";
		while((valstd[1].length)<decplace)
			valstd[1]=valstd[1]+"0";
		postfix=nformat[1]+valstd[1];
		intstr=valstd[0];
	} else
	{
		fl==Math.round(fl);
		if(fl<0)
		{
			fl=-fl;
			neg="-";
		}
		intstr=fl.toString();
		postfix="";
	}
	// Add separators
	if(separator==null)
		separator=nformat[3];
	if(separator.length>0 && nformat[4].length>0)
	{	prefix="";
		sepspace=nformat[4].split(",");
		curspace=sepspace.pop();
		while(intstr.length>0)
		{	if(intstr.length>curspace)
			{	prefix=separator+intstr.slice(intstr.length-curspace)+prefix;
				intstr=intstr.substring(0,intstr.length-curspace);
				if(sepspace.length>0)
				curspace=sepspace.pop();
			} else
			{	prefix=intstr+prefix;
				intstr="";
		}	}
	} else
		prefix=intstr;
	return neg+prefix+postfix;
}*/
function SVCnumDBround(val) // ...decplace,invert) invert=1: -0.245 will round to -0.25 instead of -0.24
{	// Inputs a DB number and outputs the same DB number rounded to the locales currency
	var decplace="";
	var invert=0;
	var returnval=0;
	var nformat=Request.DS.FN.SVCGetNumFormat();
	if(val IS "")
		return 0;
	if(ArrayLen(Arguments) IS 1 OR Arguments[2] IS "")
		decplace=nformat[3];
	else
		decplace=Arguments[2];
	if(decplace IS "")
		decplace=2;
	if(ArrayLen(Arguments) gte 3 and Arguments[3] eq 1)
		invert=1;
	//http://jamiekrug.com/blog/index.cfm/2009/2/12/ColdFusion-round-function-bug-when-operation-performed-on-argument
	//http://bugs.java.com/bugdatabase/view_bug.do?bug_id=4508009
	val = javaCast('string', val);
	if(invert eq 1 and val lt 0){
		returnval=-(Round(precisionevaluate(-val*(10^decplace)))/(10^decplace));
	} else {
		returnval=Round(precisionevaluate(val*(10^decplace)))/(10^decplace);
	}

	return returnval;
}
Attributes.DS.FN.SVCnumDBround=SVCnumDBround;
function SVCnum(val)
{
	switch(ArrayLen(Arguments))
	{
		case 1: return Request.DS.FN.SVCNumDBtoLOC(val);
		case 2: return Request.DS.FN.SVCNumDBtoLOC(val,Arguments[2]);
		case 3: return Request.DS.FN.SVCNumDBtoLOC(val,Arguments[2],Arguments[3]);
		default : return Request.DS.FN.SVCNumDBtoLOC(val,Arguments[2],Arguments[3],Arguments[4]);
	}
/*	if(val IS "")
		return "";
	if(IsDefined("SESSION.VARS.LOCID"))
		locid=SESSION.VARS.LOCID;
	else
		locid=1;
	numformat=Request.DS.LOCALES[locid].CURRENCYFORMAT;
	if(Request.DS.LOCALES[locid].CURRENCYFORMAT IS "-1")
		return Trim(Request.DS.FN.SVCNum(val));
	else
		return Trim(LSNumberFormat(val,numformat));*/
}
Attributes.DS.FN.SVCnum=SVCnum;
/* this is buggy - please do not use this. #17969 */
/*
function SVCmthdiff(dt1,dt2)
{
	var mthdiff=0;
	if(dt1 IS "" OR dt2 IS "")
		return -1;
	mthdiff=DateDiff("m",dt1,dt2);
	if(mthdiff GT 0 AND Day(dt1) IS Day(dt2))
		mthdiff=mthdiff-1;
	return mthdiff;
}
Attributes.DS.FN.SVCmthdiff=SVCmthdiff;
*/
function SVCcalcdepr(mthdiff,scale)
{
	var scaleA="";
	var mth=0;
	if(scale IS "")
		return -1;
	scaleA=ListToArray(scale);
	if(mthdiff LT 0)
		return 0;
	for(t=1;t LTE ArrayLen(scaleA);t=t+1)
	{
		mth=Val(ListFirst(scaleA[t],"|"));
		if(mth GT 0 AND mthdiff GTE mth)
			return Val(ListLast(scaleA[t],"|"));
	}
	return 0;
}
Attributes.DS.FN.SVCcalcdepr=SVCcalcdepr;
function SVCdt(val)
{
	switch(ArrayLen(Arguments))
	{
		case 1: return Request.DS.FN.SVCdtDBtoLOC(val);
		case 2: return Request.DS.FN.SVCdtDBtoLOC(val,Arguments[2]);
		case 3: return Request.DS.FN.SVCdtDBtoLOC(val,Arguments[2],Arguments[3]);
		case 4: return Request.DS.FN.SVCdtDBtoLOC(val,Arguments[2],Arguments[3],Arguments[4]);
		default : return Request.DS.FN.SVCdtDBtoLOC(val,Arguments[2],Arguments[3],Arguments[4],Arguments[5]);
	}
}
Attributes.DS.FN.SVCdt=SVCdt;
function SVCbinaryXOR(n1,n2)
{
	n1=formatBaseN(n1,2);
	n2=formatBaseN(n2,2);
	return inputBaseN(replace(n1+n2,2,0,"all"),2);
}
Attributes.DS.FN.SVCbinaryXOR=SVCbinaryXOR;
function SVCfusion_encrypt(string,key)
{
	var i="";
	var result="";
	key = repeatString(key, ceiling(len(string) / len(key)));
	for(i=1;i LTE len(string);i=i+1)
	{	result=result&rJustify(formatBaseN(Request.DS.FN.binaryXOR(asc(mid(string, i, 1)), asc(mid(key, i, 1))), 16), 2);
	}
	return replace(result, " ", "0", "all");
}
Attributes.DS.FN.SVCfusion_encrypt=SVCfusion_encrypt;
function SVCencURL(rawurl)
{
	var cfsrvtype="";
	var key="";
	if(StructKeyExists(Application,"APPDEVMODE") AND Application.APPDEVMODE IS 1)
		return rawurl&"&"&Request.MToken;
	/**** commented by HoongMooi on 27/11/2007 - just use static merimen key at the moment
	if(isdefined("Session.Vars.key"))
		key=Session.vars.key;
	else****/

		key="xswpetoiussldkfjqieeiuriuiopqowieua8q-0rweprkoqlwjrsaflkwkejrqsfwer";
	if(StructKeyExists(Application,"CFSVRTYPE"))
		cfsrvtype=Application.CFSVRTYPE;
	else if(StructKeyExists(Request,"CFSVRTYPE"))
		cfsrvtype=Request.CFSVRTYPE;
	if(Left(cfsrvtype, 2) IS "CF")
		return "enc="&cfusion_encrypt(rawurl, key)&"&"&Request.MToken;
	else
		return Request.DS.FN.SVCfusion_encrypt(rawurl,key)&"&"&Request.MToken;
}
Attributes.DS.FN.SVCencURL=SVCencURL;
function SVCremoveURL(urlx,str)
{
	// Sync: JSVCremoveURL() and FN.SVCremoveURL()
	urlx=rereplacenocase(urlx,"([&\?])("&str&")[=][^&]*","\1","all");
	urlx=rereplacenocase(urlx,"([&\?])&*","\1","all");
	urlx=rereplacenocase(urlx,"&*$",""); // remove at ending
	return urlx;
}
Attributes.DS.FN.SVCremoveURL=SVCremoveURL;
function SVCproperCase(str)
{
	str=Trim(str);
	if(Len(str) EQ 0) return "";
	strlen=Len(str);
	result="";
	for(c=1;c LTE strlen;c=c+1)
	{
		frontpointer=c+1;
		if(Mid(str,c,1) IS " ")
		{
		  	result=result & " " & UCase(Mid(str,frontpointer,1));
		    c=c+1;
		}
	    else
		{
			if(c EQ 1)
				result=result & UCase(Mid(str,c,1));
			else
			{
				/*if(Mid(str,c,1) IS UCase(Mid(str,c,1)) AND (Mid(str,frontpointer,1) IS UCase(Mid(str,frontpointer,1)) OR Mid(str,frontpointer,1) IS " "))
					result=result & Mid(str,c,1);
				else*/
					result=result & LCase(Mid(str,c,1));
			}
		}
	}
	return result;
}
Attributes.DS.FN.SVCproperCase=SVCproperCase;
function SVCdaydiff(date1,date2/*,workingDays,returnSql*/) {
	if(ArrayLen(Arguments) IS 2) {
		workingDays=1; // 1:working days Mon-Fri a week, 2:Mon-Sat 6 working days (beta), else calendar days
		returnSql=1;
	}
	else if(ArrayLen(Arguments) IS 3) {
		workingDays=Arguments[3];
		returnSql=1;
	}
	else if(ArrayLen(Arguments) IS 4) {
		workingDays=Arguments[3];
		returnSql=Arguments[4];
	}

	if(returnSql IS 1) { // return sql string
		if(workingDays IS 1)
			return "(datediff(day,#date1#,#date2#) - datediff(week,#date1#,#date2#)*2 + sign(datepart(dw,#date1#)-1) - sign(datepart(dw,#date2#)-1))";
		else if(workingDays IS 2)
			return "(datediff(day,#date1#,#date2#) - datediff(week,#date1#,#date2#) + sign(datepart(dw,#date1#)-1) - sign(datepart(dw,#date2#)-1))";
		else
			return "datediff(day,#date1#,#date2#)";
	} else {
		// WARNING: This is not accurate, do not use the below (use the SQL version for now)
		if(workingDays IS 1)
			return (datediff("d",date1,date2) - datediff("ww",date1,date2)*2 + Sgn(DayOfWeek(date1)-1) - Sgn(DayOfWeek(date2)-1));
		else if(workingDays IS 2)
			return (datediff("d",date1,date2) - datediff("ww",date1,date2) + Sgn(DayOfWeek(date1)-1) - Sgn(DayOfWeek(date2)-1));
		else
			return datediff("d",date1,date2);
	}
}
Attributes.DS.FN.SVCdaydiff=SVCdaydiff;
function SVCGetCurr(/*currid*/){
	var locid = "";
	var currid = "";
	var currs = "";

	if(ArrayLen(Arguments) GT 0 AND Arguments[1] GT 0)
		currid = Arguments[1];
	if(StructKeyExists(Request,"LOCID"))
		locid = REQUEST.LOCID;
	else
		locid = 1;

	currs = StructNew();

	if(currid NEQ "" AND StructKeyExists(Request.DS, "Currencies") AND ArrayIsDefined(Request.DS.Currencies, currid))
	{
			currs = Request.DS.Currencies[currid];
	}
	else if(StructKeyExists(Request, "CurrencyID") AND Request.CurrencyID GT 0)
		currs = Request.DS.Currencies[Request.CurrencyID];
	else
	{
		if(StructKeyExists(Request.DS.LOCALES[locid], "CurrencyID"))
			currid = Request.DS.LOCALES[locid].CurrencyID;

		if(StructKeyExists(Session,"vars") AND StructKeyExists(Session.vars, "ORGID") And StructKeyExists(Request.DS.CO, Session.vars.Orgid))
			if(StructKeyExists(Request.DS.CO[Session.vars.orgid], "CurrencyID"))
				if(Request.DS.CO[Session.vars.orgid].CurrencyID NEQ "")
					currid = Request.DS.CO[Session.vars.orgid].CurrencyID;

		if(currid NEQ "" AND StructKeyExists(Request.DS, "Currencies"))
			currs = Request.DS.Currencies[currid];
		else
		{
			currs.Currency = Request.DS.LOCALES[locid].Currency;
			currs.CurrencyIntl = Request.DS.LOCALES[locid].CurrencyIntl;
			currs.CurrencyFormat = Request.DS.LOCALES[locid].CurrencyFormat;
			currs.CurrencyFull = Request.DS.LOCALES[locid].CurrencyFull;
		}
	}
	currs.CurrencyID =currid;
	return currs;
}
Attributes.DS.FN.SVCGetCurr = SVCGetCurr;
</cfscript>
<!---
function SVCcsv(CSVdata)	// Text delimiter (default ,), TextQualifyer (default ")
{
	var arrlen=ArrayLen(Arguments);
	var TextDelimiter = ",";
	var CSVArray=ArrayNew(1);
	var TextQualifyer = Chr(34); // Chr(34) is the ascii code for "
	var ProcessQualifyer = False; // Determining how record should be processed with qualifier
	var CharMaxNumber = Len(CSVData); // Calculating no. of characters in variable
	var	CharStorage = "";
	var CSVArrayCount = 1;
	var CharCounter = 0;
	var NewRecordCreate =0;

	/* Determining how to handle record at different
    stages of operation
    0 = Don't create new record
    1 = Write data to existing record
    2 = Close record and open new one
	*/
//	if(db IS "")
//		return "";
	if(arrlen GT 1 AND Len(Trim(Arguments[2])) GT 0)
	{
		TextDelimiter=Trim(Arguments[2]);
	}
	if(arrlen GT 2 AND Len(Trim(Arguments[3])) GT 0)
	{
		TextQualifyer=Trim(Arguments[3]);
	}
	CSVArray[1]="";
	// Priming the array counter
	// Record character counter
	//-------------------------------------------------------------------------
	//Starting the main loop
	for(CharLocation=1;CharLocation LTE CharMaxNumber;CharLocation=CharLocation+1)
	{
		//Retrieving the next character in sequence from CSVDataToProcess
	    CharCurrentVal = Mid(CSVData, CharLocation, 1);

		//This will figure out if the record uses a text qualifyer or not
		If (CharCurrentVal EQ TextQualifyer And CharCounter EQ 0)
		{
			ProcessQualifyer = True;
			CharCurrentVal = "";
		}

		//Advancing the record 'letter count' counter
		CharCounter = CharCounter + 1;


		//Choosing data extraction method (text qualifyer or no text qualifyer)
		If (ProcessQualifyer)
		{
		/*This section handles records with a text qualifyer and text delimiter
			It is also handles the special case scenario, where the qualifyer is
			part of the data.  In the CSV file, a double quote represents a single
			one  ie.  "" = "
		*/
			If (NOT Len(CharStorage) EQ 0)
			{
				If (CharCurrentVal EQ TextDelimiter)
				{
					CharStorage = "";
					ProcessQualifyer = False;
					NewRecordCreate = 2;
				}
				else
				{
					CharStorage = "";
					NewRecordCreate = 1;
				}
			}
			else
			{
				If (CharCurrentVal EQ TextQualifyer)
				{
					CharStorage = CharStorage & CharCurrentVal;
					NewRecordCreate = 0;
				}
				else
					NewRecordCreate = 1;
			}
		}
		//This section handles a regular CSV record.. without the text qualifyer
		Else
		{
			If (CharCurrentVal EQ TextDelimiter)
				NewRecordCreate = 2;
			Else
				NewRecordCreate = 1;
		}
		//Writing the data to the array
		switch (NewRecordCreate)
		{
			//This section just writes the info to the array
			case 1:
				{
				CSVArray[CSVArrayCount] = CSVArray[CSVArrayCount] & CharCurrentVal;
				break;
				}
			//This section closes the current record and creates a new one
			case 2:
				{
				CharCounter = 0;
				CSVArrayCount = CSVArrayCount + 1;
				ArrayAppend(CSVArray,"");
				}
		}
	}
	return CSVArray;
}--->
<cffunction name="SVCcsv" hint="Parses a string into CSV array, allowing custom delimiters (comma, pipe, doublepipe) and handling quote qualifiers if used." returntype="array" output="true">
	<cfargument name="CSVdata" required="true" type="string"
		displayname="The input string to parse as CSV array"
		hint="">
	<cfargument name="Delimiter" required="false" default="," type="string"
		displayname="The delimiter for separate data items. Can be multiple character separator"
		hint="If two characters passed in, both are used as separator together, e.g. double-pipe ||.">
	<cfargument name="TextQualifier" required="false" default="""" type="string"
		displayname="What the text qualifier should be e.g. "" or '"
		hint="Only accept a single character as a text qualifier and can only have one type of qualifier">

	<CFSET var CSVArray=ArrayNew(1)>
	<CFSET var ProcessQualifyer = False>
	<CFSET var CharStorage = "">
	<CFSET var CharCounter = 0>
	<CFSEt var NewRecordCreate = 0>
	<CFSET var CharLocation= 0 >
	<CFSET var CharCurrentVal="">
	<!--- NewRecordCreate:
	Determining how to handle record at different
    stages of operation
    0 = Don't create new record
    1 = Write data to existing record
    2 = Close record and open new one
	--->
	<CFSET CSVArray[1]="">
	<CFSET CharLocation=0>
	<CFLOOP CONDITION="CharLocation LTE Len(Arguments.CSVdata)">
		<CFSET CharLocation=CharLocation+1>
		<!--- Retrieving the next character in sequence from CSVDataToProcess --->
		<CFIF CharLocation+Len(Arguments.Delimiter)-1 GT Len(Arguments.CSVdata)>
			<CFSET CharCurrentVal=Mid(CSVData, CharLocation,1)>
		<CFELSE>
	    	<CFSET CharCurrentVal=Mid(CSVData,CharLocation,Len(Delimiter))>
		</CFIF>

		<CFSET CharCounter=CharCounter + 1>

		<!--- This will figure out if the record uses a text qualifyer or not --->
		<CFIF (Left(CharCurrentVal,1) EQ Arguments.TextQualifier And CharCounter EQ 1)>
			<CFSET ProcessQualifyer = True>
			<CFCONTINUE>
			<!---CFSET CharCurrentVal = ""--->
		</CFIF>

		<!--- Advancing the record 'letter count' counter --->

		<!--- Choosing data extraction method (text qualifyer or no text qualifyer --->
		<CFIF (ProcessQualifyer)>
			<!---This section handles records with a text qualifyer and text delimiter
			It is also handles the special case scenario, where the qualifyer is
			part of the data.  In the CSV file, a double quote represents a single
			one  ie.  "" = " --->
			<CFIF Len(CharStorage) GT 0>
				<CFIF (CharCurrentVal EQ Arguments.Delimiter)>
					<CFSET CharStorage = "">
					<CFSET ProcessQualifyer = False>
					<CFSET NewRecordCreate = 2>
					<!---CFABORT--->
				<CFELSE>
					<CFSET CharStorage = "">
					<CFSET NewRecordCreate = 1>
					<CFSET ProcessQualifyer = False>
				</CFIF>
			<CFELSE>
				<CFIF (Left(CharCurrentVal,1) EQ Arguments.TextQualifier)>
					<CFSET CharStorage = CharStorage & Left(CharCurrentVal,1)>
					<CFSET NewRecordCreate = 0>
				<CFELSE>
					<CFSET NewRecordCreate = 1>
				</CFIF>
			</CFIF>
		<CFELSE>
			<!---This section handles a regular CSV record.. without the text qualifyer--->
			<CFIF (CharCurrentVal EQ Arguments.Delimiter)>
				<CFSET NewRecordCreate = 2>
			<CFELSE>
				<CFSET NewRecordCreate = 1>
			</CFIF>
		</CFIF>
		<!--- Writing the data to the array --->
		<CFIF NewRecordCreate IS 1>
			<CFSET CSVArray[ArrayLen(CSVArray)] = CSVArray[ArrayLen(CSVArray)] & Left(CharCurrentVal,1)>
		<CFELSEIF NewRecordCreate IS 2>
			<CFSET CharCounter = 0>
			<CFIF Len(Arguments.Delimiter) GT 1>
				<CFSET CharLocation=CharLocation+Len(Arguments.Delimiter)-1>
			</CFIF>
			<CFSET ArrayAppend(CSVArray,"")>
		</CFIF>
	</CFLOOP>
	<CFRETURN CSVArray>
</cffunction>
<CFSET Attributes.DS.FN.SVCcsv=SVCcsv>
<cffunction name="SVCSvrFileDSUpdate" description="Updates DS with latest server file depending on APPLOCID and if file exists or not" access="public" returntype="boolean" output="false">
	<cfargument name="LOGICNAME" required="false" type="string" default="" displayname="Individual logicname to refresh" hint="">
	<CFQUERY NAME=Local.q_svrfiles DATASOURCE=#Request.SVCDSN#>
	SELECT a.vaSVRFILEGRP,a.vaSVRFILELOGICNAME,a.vaSVRFILENAME,a.vaSVRFILEEXT,a.iSVRFILEVERSION,a.vaSVRFILETYPE,a.vaSVRFILELOGPATH,a.vaSVRFILEWEBROOT
	from FSYS0007 a WITH (NOLOCK)
	WHERE a.siSTATUS=0 AND a.iAPPLOCID IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#Application.APPLOCID#">)
	<CFIF arguments.LOGICNAME neq "" and listlen(arguments.LOGICNAME,'_') gte 2>
		AND a.vaSVRFILELOGICNAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listlast(arguments.LOGICNAME,'_')#">
	</CFIF>
	order by a.vaSVRFILEGRP,a.vaSVRFILELOGICNAME,a.iAPPLOCID DESC
	</CFQUERY>
	<CFSET Local.SVRFILES=StructNew()>
	<CFSET Local.LAST_REFKEY="">
	<CFLOOP query=Local.q_svrfiles>
		<CFSET Local.REFKEY="#UCASE(Trim(vaSVRFILEGRP))#_#UCASE(Trim(vaSVRFILELOGICNAME))#">
		<CFIF Local.REFKEY IS NOT Local.LAST_REFKEY>
			<!--- The loop prioritize the key with the matching APPLOCID before the default APPLOCID=0 script --->
			<CFSET Local.LAST_REFKEY=Local.REFKEY>
			<CFSET Local.SVRFILES[Local.REFKEY]=StructNew()>
			<CFSET Local.SVRFILES[Local.REFKEY].GRP=UCase(Trim(vaSVRFILEGRP))>
			<CFSET Local.SVRFILES[Local.REFKEY].LOGICNAME=UCase(Trim(vaSVRFILELOGICNAME))>
			<CFSET Local.SVRFILES[Local.REFKEY].FILENAME=Trim(vaSVRFILENAME)>
			<CFSET Local.SVRFILES[Local.REFKEY].EXT=Trim(vaSVRFILEEXT)>
			<CFSET Local.SVRFILES[Local.REFKEY].TYPE=UCase(Trim(vaSVRFILETYPE))>
			<CFSET Local.SVRFILES[Local.REFKEY].LOGPATH=Trim(vaSVRFILELOGPATH)>
			<CFSET Local.SVRFILES[Local.REFKEY].WEBROOT=Trim(vaSVRFILEWEBROOT)>
			<!--- Check if versioned file exist in app, if not exist, then use the fallback source file without version --->
			<CFSET Local.PATH=ExpandPath(Evaluate(DE(Trim(vaSVRFILELOGPATH))))>
			<CFIF iSVRFILEVERSION GT 0>
				<cfset versionstr=Trim(iSVRFILEVERSION)>
				<!---cfset versionstr=RepeatString("0",6-Len(iSVRFILEVERSION)) & iSVRFILEVERSION--->
				<CFSET Local.FILEPATH=Local.Path & Trim(vaSVRFILENAME) & versionstr & "-mvs." & Trim(vaSVRFILEEXT)>
				<CFIF FileExists(Local.FILEPATH)>
					<CFSET Local.SVRFILES[Local.REFKEY].VER=iSVRFILEVERSION>
				<CFELSE>
					<CFSET Local.SVRFILES[Local.REFKEY].VER="">
				</CFIF>
			<CFELSE>
				<CFSET Local.FILEPATH=Local.Path & Trim(vaSVRFILENAME) & "." & Trim(vaSVRFILEEXT)>
				<CFSET Local.SVRFILES[Local.REFKEY].VER="">
			</CFIF>
		</CFIF>
	</CFLOOP>
	<!--- Replace DS SVRFILES with latest update copy --->
	<CFIF arguments.LOGICNAME neq "" AND Local.q_svrfiles.RecordCount GT 0 AND NOT structKeyExists(Request.Ds.SVRFILES, Local.REFKEY)><!--- Just update the DS with this new item. --->
		<cfset Request.Ds.SVRFILES[Local.REFKEY] = Local.SVRFILES[Local.REFKEY]>
	<CFELSE>
		<CFSET Request.Ds.SVRFILES=Local.SVRFILES>
	</CFIF>

	<CFRETURN true>
</cffunction>
<CFSET Attributes.DS.FN.SVCSvrFileDSUpdate=SVCSvrFileDSUpdate>
<cffunction name="SVCSvrFileInclude" description="Gets the latest version of a server file/dir from logic name" access="public" returntype="struct" output="false">
<cfargument name="grp" required="true">
<cfargument name="logic" required="true">
<cfargument name="nogen" required="false" default="0">
<cfargument name="mediaparam" required="false" default="">
<CFSET grp=UCase(Trim(grp))>
<CFSET logic=UCase(Trim(logic))>
<CFSET Local.SVRFILE=StructNew()>
<CFSET Local.Refkey=grp&"_"&logic>
<CFIF arguments.mediaparam neq "">
	<cfset arguments.mediaparam = ' media="#arguments.mediaparam#"'>
</CFIF>
<CFIF nogen IS 0>
	<CFIF Not StructKeyExists(Request,"AddedList")>
		<CFSET Request.AddedList=Local.Refkey>
	<CFELSEIF ListFind(Request.AddedList,Local.Refkey) GT 0>
		<CFSET nogen=1>
	<CFELSE>
		<cfset Request.AddedList=ListAppend(Request.AddedList,Local.Refkey)>
	</CFIF>
</CFIF>
<!--- not refreshed, attempt to auto refresh with just this item. --->
<CFIF Not StructKeyExists(Request.DS.SVRFILES,Local.Refkey)>
	<cfset REQUEST.DS.FN.SVCSvrFileDSUpdate(arguments.logic)>
	<!--- If still no file found, throw error. --->
	<cfif Not StructKeyExists(Request.DS.SVRFILES,Local.Refkey)>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADFILE" ExtendedInfo="Missing Svr File Include (#Local.RefKey#)">
	</cfif>
</CFIF>

<CFIF StructKeyExists(Application,"APPDEVMODE") AND Application.APPDEVMODE IS 1>
	<CFSET Local.latestversion_no="">
<CFELSE>
	<CFSET Local.latestversion_no=Request.DS.SVRFILES[Local.refkey].VER>
</CFIF>
<CFSET Local.webrootpath = Evaluate(DE(Request.DS.SVRFILES[Local.refkey].WEBROOT))>
<CFIF Request.DS.SVRFILES[Local.refkey].FILENAME IS NOT "" AND Request.DS.SVRFILES[Local.refkey].EXT IS NOT "">
	<CFIF Local.latestversion_no GT 0>
		<CFSET Local.SVRFILE.PATH=Local.webrootpath & Request.DS.SVRFILES[Local.refkey].FILENAME & Local.latestversion_no & "-mvs." & Request.DS.SVRFILES[Local.refkey].EXT>
	<CFELSE>
		<CFSET Local.SVRFILE.PATH=Local.webrootpath & Request.DS.SVRFILES[Local.refkey].FILENAME & "." & Request.DS.SVRFILES[Local.refkey].EXT>
	</CFIF>
<CFELSE>
	<CFSET Local.SVRFILE.PATH=Local.webrootpath>
</CFIF>
<CFIF Request.DS.SVRFILES[Local.refkey].TYPE IS "CSS">
	<CFSET Local.SVRFILE.HTMSTR="<link href=""" & Local.SVRFILE.PATH & """ rel=stylesheet type=text/css" & arguments.mediaparam & "></link>">
<CFELSE>
	<!--- note: language="" and type="" within the script tag has become unnecessary for javascript with the evolving html and new browsers
	       it sometimes even cause problems, hence its entirely omitted here --->
	<CFSET Local.SVRFILE.HTMSTR="<script src=""" & Local.SVRFILE.PATH & """></script>">
</CFIF>
<CFSET Local.SVRFILE.NOGEN=nogen>
<CFRETURN Local.SVRFILE>
</CFFUNCTION>
<CFSET Attributes.DS.FN.SVCSvrFileInclude=SVCSvrFileInclude>

<cffunction name="SVCwriteJSappvars" description="Write JS appvars file" access="public" returntype="boolean" output="false">
<cfargument name="DS" type="Struct" required="false" default=#Request.DS# hint="The DS to update.">
<cfargument name="DSNName" type="String" required="false" default=#Request.SVCDSN# hint="The DSN name to use.">
<cfargument name="CurFile" type="String" required="true" hint="The JS file path to write.">
<cfquery NAME=Local.q_lang DATASOURCE=#DSNName#>
SELECT a.siLANGID,a.iLID,a.vaTEXT
FROM translation..LNG0003 a WITH (NOLOCK) JOIN translation..LNG0001 b WITH (NOLOCK) ON b.siLANGID=a.siLANGID
WHERE b.vaLCODE IN (<cfqueryparam CFSQLTYPE="cf_sql_varchar" list="YES" value="#DS.LANGLIST#">)
ORDER BY a.siLANGID,a.iLID
</cfquery>
<cfquery NAME=Local.q_holidays DATASOURCE=#DSNName#>
SELECT iLOCID=iUSID,YRS=DATEPART(year,DTDATEFROM),vaDESC,DATEFROM=case when iusid = 10 then REPLACE(CONVERT(VARCHAR(10),DTDATEFROM,110),'-','/') else CONVERT(VARCHAR(10),DTDATEFROM,103) end,DATETO=case when iusid=10 then REPLACE(CONVERT(VARCHAR(10),ISNULL(DTDATETO,DTDATEFROM),110),'-','/') else CONVERT(VARCHAR(10),ISNULL(DTDATETO,DTDATEFROM),103) end
FROM FUTL3001 f WITH (NOLOCK)
WHERE f.siType=3 AND f.siLEAVESTATUS=1 AND f.siSTATUS=0
ORDER BY iLOCID,YRS,DTDATEFROM
</cfquery>
<CFOUTPUT><cfsavecontent variable="Local.tmp">
if(!request.DS) request.DS={};
request.DS.LANGQ=#serializeJSON(Local.q_lang)#;
request.DS.LANG=[];
for(var i=0;i<request.DS.LANGQ.DATA.length;i++) { <!--- Need to optimize this later (avoid loop and redundant LANGQ) --->
	var a=request.DS.LANGQ.DATA[i];
	if(request.DS.LANG[a[0]]==null)
		request.DS.LANG[a[0]]=[];
	request.DS.LANG[a[0]][a[1]]=a[2]; <!--- request.DS.LANG[LANGID][LID]="text" --->
}
request.DS.LANGDEF=#serializeJSON(Server.DS.LANGDEF)#;
request.DS.LOCALES=#serializeJSON(DS.LOCALES)#;
request.DS.HOLIDAYSQ=#serializeJSON(Local.q_holidays)#;
request.DS.HOLIDAYS=[];
for(var i=0;i<request.DS.HOLIDAYSQ.DATA.length;i++) {
	var a=request.DS.HOLIDAYSQ.DATA[i];
	if(typeof(request.DS.HOLIDAYS[a[0]])=='undefined' || request.DS.HOLIDAYS[a[0]]==null)
		request.DS.HOLIDAYS[a[0]]=[];
	request.DS.HOLIDAYS[a[0]][request.DS.HOLIDAYS[a[0]].length]=(a[3]!=null?a[3]:'')+'|'+(a[4]!=null?a[4]:''); <!--- request.DS.HOLIDAYS[LOCID][row]="dtfrom|dtto" --->
}
</cfsavecontent></CFOUTPUT>
<cffile CHARSET="UTF16" ACTION="write" FILE="#CurFile#" OUTPUT=#Local.tmp# ADDNEWLINE=NO>
<cfreturn true>
</cffunction>
<CFSET Attributes.DS.FN.SVCwriteJSappvars=SVCwriteJSappvars>

<!---
function SVCSvrFileInclude(grp,logic)
{
	var refkey="";
	var latestversion_no = "";
	var webrootpath = "";
	var svrfile = StructNew();
	grp=UCase(Trim(grp));
	logic=UCase(Trim(logic));
	refkey=	grp&"_"&logic;
	if(StructKeyExists(Application,"APPDEVMODE") AND Application.APPDEVMODE IS 1){
		latestversion_no = "";
	}else{
		latestversion_no = Request.DS.SVRFILES[refkey].VER;
	}
	webrootpath = Evaluate(DE(Request.DS.SVRFILES[refkey].WEBROOT));

	if (Trim(Request.DS.SVRFILES[refkey].FILENAME)!='' && Trim(Request.DS.SVRFILES[refkey].EXT)!=''){
		if (Trim(Request.DS.SVRFILES[refkey].EXT)=='CSS'){
			svrfile.htmstr='<link href="' & webrootpath & Request.DS.SVRFILES[refkey].FILENAME & latestversion_no & '.' & Request.DS.SVRFILES[refkey].EXT & '" rel=stylesheet type=text/css>';
		}else{
			// note: language="" and type="" within the script tag has become unnecessary for javascript with the evolving html and new browsers
			//       it sometimes even cause problems, hence its entirely omitted here
			svrfile.htmstr='<script src="' & webrootpath & Request.DS.SVRFILES[refkey].FILENAME & latestversion_no & '.' & Request.DS.SVRFILES[refkey].EXT & '"></script>';
		}
		svrfile.path=webrootpath & Request.DS.SVRFILES[refkey].FILENAME & latestversion_no & '.' & Request.DS.SVRFILES[refkey].EXT;
	}else{
		// when pointing to directory
		svrfile.htmstr='<script src="' & webrootpath & '"></script>';
		svrfile.path=webrootpath;
	}
	return svrfile;
}--->
<cffunction name="SVCimageSizeWH" description="Returns proportionally scaled picture size" access="public" returntype="struct">
	<cfargument name="picW" required="true">
	<cfargument name="picH" required="true">
	<cfargument name="maxW" required="true">
	<cfargument name="maxH" required="true">
	<cfset scaleW=maxW/picW>
	<cfset scaleH=maxH/picH>
	<cfset RT=StructNew()>
	<cfif scaleH LT scaleW>
		<CFIF picH GT maxH>
			<CFSET RT.scale=1>
			<CFSET RT.width=Int(maxH*picW/picH)>
			<CFSET RT.height=maxH>
		<CFELSE>
			<CFSET RT.scale=0>
			<CFSET RT.width=picW>
			<CFSET RT.height=picH>
		</CFIF>
	<cfelse>
		<CFIF picW GT maxW>
			<CFSET RT.scale=1>
			<CFSET RT.width=maxW>
			<CFSET RT.height=Int(maxW*picH/picW)>
		<CFELSE>
			<CFSET RT.scale=0>
			<CFSET RT.width=picW>
			<CFSET RT.height=picH>
		</CFIF>
	</cfif>
	<cfreturn RT>
</cffunction>
<cfset Attributes.DS.FN.SVCimageSizeWH=SVCimageSizeWH>
<cffunction name="MTRfeedbackDecode" returntype="any">
	<cfargument name="FBTYPE" type="numeric" required="true">
	<cfargument name="ACTIONSTR" type="string" required="true">
	<cfset result=StructNew()>
	<cfif FBTYPE EQ 10><!--- Change insurer --->
		<cfset st=REFind("CHGINS\{REGNO=([A-Z0-9]+);ACCDATE=([\-\/0-9]{10}|[ ]+);INSCOID=([0-9]+);\};",ACTIONSTR,1,"TRUE")>
		<cfif ArrayLen(st.pos) NEQ 4>
			<cfreturn>
		</cfif>
		<cfset result.REGNO=Mid(ACTIONSTR,st.pos[2],st.len[2])>
		<cfset result.ACCDATE=Mid(ACTIONSTR,st.pos[3],st.len[3])>
		<cfset result.INSCOID=Mid(ACTIONSTR,st.pos[4],st.len[4])>
		<cfreturn result>
	<cfelse>
		<cfreturn>
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.MTRfeedbackDecode=MTRfeedbackDecode>
<cffunction name="MTRfeedbackEncode" returntype="string">
	<cfargument name="FBTYPE" type="numeric" required="true">
	<cfargument name="ACTIONSTR" type="string" required="true">
	<cfset delim=",">
	<cfif FBTYPE EQ 10><!--- Change insurer --->
		<cfif ListLen(ACTIONSTR,delim) NEQ 3>
			<cfreturn "">
		</cfif>
		<cfset result="CHGINS{REGNO=#ListGetAt(ACTIONSTR,1,delim)#;ACCDATE=#ListGetAt(ACTIONSTR,2,delim)#;INSCOID=#ListGetAt(ACTIONSTR,3,delim)#;};">
		<cfreturn result>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.MTRfeedbackEncode=MTRfeedbackEncode>

<cffunction name="SVCsessionChk" returntype="boolean" output="false">
	<cfif Not IsDefined("SESSION.VARS.USERID")>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
	</cfif>
	<cfif StructKeyExists(URL,"USID")>
		<cfif URL.USID IS NOT SESSION.VARS.USID>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="USRMISMATCH">
		</cfif>
	</cfif>
	<CFIF StructKeyExists(SESSION.VARS,"IP") AND SESSION.VARS.IP IS NOT Request.DS.FN.SVCRemoteIpAddr()>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOLOGIN" ExtendedInfo="Invalid IP">
	</cfif>
	<CFIF StructKeyExists(SESSION.VARS,"MACID") AND NOT(StructKeyExists(Request,"SkipCookieCheck") AND Request.SkipCookieCheck IS 1) AND (Not(IsDefined("COOKIE.MACID")) OR SESSION.VARS.MACID IS NOT COOKIE.MACID)>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOLOGIN" ExtendedInfo="Session not matched">
	</cfif>

	<cfif APPLICATION.APPMODE eq "EPL" and StructKeyExists(SESSION.VARS,"SSOSETUPID") AND session.vars.SSOSETUPID gt 0>
	  <!--- if nologin/sso session, direct access is limited --->
	  <cfquery name=q_ssosetup DATASOURCE=#Request.SVCDSN#>
	  select 1 from FSSO_ACCESS b with (nolock)
	  where b.iSSOSETUPID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.SSOSETUPID#">
		and b.vaFUSEBOX=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#url.FUSEBOX#">
		and b.vaFUSEACTION=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#url.FUSEACTION#">
	  </cfquery>
	  <cfif q_ssosetup.recordcount neq 1>
		<CFIF StructKeyExists(Application,"APPDEVMODE") AND Application.APPDEVMODE IS 1>
		  <CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOLOGIN" ExtendedInfo="User access not allowed FUSEBOX:#url.FUSEBOX# FUSEACTION:#url.FUSEACTION#">
		<CFELSE>
		  <CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOLOGIN" ExtendedInfo="User access not allowed">
		</CFIF>
	  </cfif>
	</cfif>

	<CFreturn true>
</cffunction>
<cfset Attributes.DS.FN.SVCsessionChk=SVCsessionChk>

<cffunction name="SVCsessionStop" returntype="boolean" output="false">
	<cfset var local = StructNew() />
	<cfif Not StructKeyExists(application, 'applicationName')>
		<cFreturn false>
	</cfif>
	<cftry>
		<cfif structKeyExists(session,"cfid")>
			<cfset local.sid = session.cfid & '_' & session.cftoken />
		<cfelse>
			<cfset local.sid = session.sessionid />
		</cfif>
		<cfset local.jTracker = CreateObject('java', 'coldfusion.runtime.SessionTracker') />
		<cfset local.jTracker.cleanUp(application.applicationName, local.sid) />
	<cfcatch type="any">
		<cfreturn false>
	</cfcatch>
	</cftry>
	<cfreturn true>
</cffunction>
<cfset Attributes.DS.FN.SVCsessionStop=SVCsessionStop>

<cffunction name="SVCsessionSteal" hint="Steal an existing session (by sessionID) into your session code. Returns true if session successfully found, false if not" returntype="boolean">
	<cfargument name="SessionCode" type="string" required="yes"
		displayname="Get current session code"
		hint="Must be a valid session, without the applicationName_ in front. Thus the application name must match.">
	<!--- Session management must be turned on --->
	<!--- No choice but to replace old session (starting with sessionmanagement=false then setting a session doesn't work) --->
	<CFSET var result="">
	<CFTRY>
		<CFSET result=createObject("java","coldfusion.runtime.SessionTracker").getSession(Application.ApplicationName&"_"&Arguments.SessionCode)>
		<CFIF IsStruct(result)>
			<CFSET StructClear(SESSION)>
			<CFSET Request.DS.FN.SVCsessionStop()>
			<CFSET StructAppend(SESSION, result, true)>
			<CFRETURN true>
		<CFELSE>
			<CFRETURN false>
		</CFIF>
	<CFCATCH>
		<CFRETURN false>
	</CFCATCH>
	</CFTRY>
</cffunction>
<cfset Attributes.DS.FN.SVCsessionSteal=SVCsessionSteal>

<cffunction name="SVCsessionStealCF11" hint="Steal an existing session (by sessionID) into your session code. Returns true if session successfully found, false if not" returntype="boolean">
	<cfargument name="SessionCode" type="string" required="yes"
		displayname="Get current session code"
		hint="Must be a valid session, without the applicationName_ in front. Thus the application name must match.">
	<!--- Session management must be turned on --->
	<!--- No choice but to replace old session (starting with sessionmanagement=false then setting a session doesn't work) --->
	<CFSET var result="">
	<CFTRY>
		<CFSET sessionTracker = createObject("java","coldfusion.runtime.SessionTracker")>
		<CFSET sessionCollection = sessionTracker.getSessionCollection(application.applicationName)>
		<CFSET sessionId=application.applicationName&"_"&Arguments.SessionCode>
		<CFSET userSession = sessionCollection[sessionId]>

		<CFIF StructIsEmpty(userSession)>
			<CFRETURN false>
		</CFIF>

		<!---CFLOOP COLLECTION="#sessionCollection#" ITEM="sessionId">
			<CFSET thisSession = sessionCollection[sessionId]>
			<CFIF isdefined("thisSession.vars.usid") AND thisSession.vars.usid IS userSession.vars.usid>
				<CFIF thisSession.sessionId NEQ userSession.sessionId>
					<CFSET StructClear(thisSession)>
				</CFIF>
			</CFIF>
		</CFLOOP--->

		<CFSET StructAppend(SESSION, userSession, true)>
		<CFRETURN true>
	<CFCATCH>
		<CFRETURN false>
	</CFCATCH>
	</CFTRY>
</cffunction>
<cfset Attributes.DS.FN.SVCsessionStealCF11=SVCsessionStealCF11>

<cffunction name="SVCCheckSessionValid" hint="Check if the session is still valid" returntype="boolean">
	<cfargument name="CFID" type="string" required="yes">
	<cfargument name="CFTOKEN" type="string" required="yes">

	<cfset sessionName = Application.applicationName & "_" & Arguments.CFID & "_" & Arguments.CFTOKEN>
	<cfset sessionTracker = createObject("java","coldfusion.runtime.SessionTracker")/>
	<cfset sess_struct = sessionTracker.getSessionCollection( Application.applicationName )>
	<cfif (structKeyExists(sess_struct,sessionName) and StructKeyExists(sess_struct[sessionName],"vars") and structCount(sess_struct[sessionName].vars) gt 0)>
		<CFRETURN true>
	<cfelse>
		<CFRETURN false>
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCCheckSessionValid=SVCCheckSessionValid>

<cffunction name="SVCGetSessionObj" returntype="any" output="false">
	<cfset sessionTracker=createObject("java","coldfusion.runtime.SessionTracker")/>
	<cfreturn sessionTracker>
</cffunction>
<cfset Attributes.DS.FN.SVCGetSessionObj=SVCGetSessionObj>

<cffunction name="SVCSECUserDomColist" returntype="string" output="false">
	<cfargument name="DOMAINID" type="numeric" required="true">
	<cfif Not IsDefined("SESSION.VARS.USID")>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
	</cfif>
	<CFIF StructKeyExists(SESSION.VARS,"GRPDOMLIST")>
		<CFSET GRPDOMLIST=SESSION.VARS.GRPDOMLIST>
	<CFELSE>
		<CFSET GRPDOMLIST=Request.DS.GLOBAL_GRPDOMLIST>
	</CFIF>
	<CFIF ListFind(GRPDOMLIST,domainid) GT 0>
		<CFIF StructKeyExists(Request.DS.CO,SESSION.VARS.GCOID)>
			<CFreturn Request.DS.CO[SESSION.VARS.GCOID].CHCOLIST>
		<CFELSE>
			<CFreturn SESSION.VARS.GCOID>
		</CFIF>
	<CFELSEIF SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID)>
		<CFreturn Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
	<CFELSE>
		<CFreturn SESSION.VARS.ORGID>
	</CFIF>
</cffunction>
<cfset Attributes.DS.FN.SVCSECUserDomColist=SVCSECUserDomColist>
<cffunction name="SVCSECUserDomCstlist" returntype="string" output="false">
	<cfargument name="DOMAINID" type="numeric" required="true">
	<cfif Not IsDefined("SESSION.VARS.USID")>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
	</cfif>
	<cfif Not IsDefined("SESSION.VARS.CSTID")>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOT CUSTOMER LOGIN">
	</cfif>
	<cfif SESSION.VARS.ORGID NEQ 2>
		<CFIF StructKeyExists(SESSION.VARS,"GRPDOMLIST")>
			<CFSET GRPDOMLIST=SESSION.VARS.GRPDOMLIST>
		<CFELSE>
			<CFSET GRPDOMLIST=Request.DS.GLOBAL_GRPDOMLIST>
		</CFIF>
		<CFIF ListFind(GRPDOMLIST,domainid) GT 0>
			<CFIF StructKeyExists(Request.DS.CO,SESSION.VARS.GCOID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.GCOID],"CSTLIST")>
				<CFreturn Request.DS.CO[SESSION.VARS.GCOID].CSTLIST>
			<CFELSE>
				<CFreturn SESSION.VARS.CSTID>
			</CFIF>
		<CFELSEIF SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CSTLIST")>
			<CFreturn Request.DS.CO[SESSION.VARS.ORGID].CSTLIST>
		<CFELSE>
			<CFreturn SESSION.VARS.CSTID>
		</CFIF>
	<cfelse>
		<CFreturn SESSION.VARS.CSTID>
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCSECUserDomCstlist=SVCSECUserDomCstlist>
<cffunction name=SVCsymbol returntype="string" output=no>
	<cfargument name=NAME type="string">
	<cfargument name=DEFTEXT type="string">
	<cfargument name=LOCID default="">
	<cfset var result=Trim(Arguments.DEFTEXT)>
	<cfset var LOCALE={}>
	<cfif Arguments.LOCID IS "">
		<cfset Arguments.LOCID=Application.APPLOCID>
	</cfif>
	<cfset LOCALE=Request.DS.LOCALES[Arguments.LOCID]>
	<cfif StructKeyExists(LOCALE.SYMBOLS,Arguments.NAME)>
		<cfset result=Trim(LOCALE.SYMBOLS[Arguments.NAME])>
	</cfif>
	<cfset result=REReplace(result,"<!---{[/]*LID[0-9]*}--->","","all")><!--- remove all LID comments --->
	<cfif LCase(Left(result,14)) IS "server.svclang">
		<cfset result=evaluate(result)>
	</cfif>
	<cfreturn result>
</cffunction>
<cfset Attributes.DS.FN.SVCsymbol=SVCsymbol>
<cffunction name="SVCgetAppSettings" returntype="struct" output=no>
	<cfargument name="APPINST" type="string" required="true">
	<cfargument name="DSN" type="string" DEFAULT="" required="false">
	<cfargument name="STR" type="struct" DEFAULT="#StructNew()#" required="false">
	<CFIF Not IsStruct(STR)>
		<CFSET STR=StructNew()>
	</CFIF>
	<CFIF Not IsDefined("DSN") OR DSN IS "">
		<CFSET DSN=Application.SVCDSN>
	</CFIF>
	<CFQUERY NAME=q_app DATASOURCE=#DSN#>
	SELECT * FROM SYS0001 a WITH (NOLOCK) WHERE a.vaAPPINST=<cfqueryparam CFSQLTYPE="cf_sql_varchar" value="#APPINST#"> AND a.siSTATUS=0
	</CFQUERY>
	<CFLOOP query=q_app><CFSET StructInsert(STR,vaAPPVAR,vaAPPVALUE)></CFLOOP>
	<CFreturn str>
</cffunction>
<cfset Attributes.DS.FN.SVCgetAppSettings=SVCgetAppSettings>
<cffunction name="SVCREListFind" access="public" returntype="any" output="false" hint="Finds the first index of the item that matches the given regular expression (returns zero if not found).">
	<!--- Define arguments. --->
	<cfargument name="List" type="string" required="true" hint="The delimited list we are searching.">
	<cfargument name="RegEx" type="string" required="true" hint="The regular expression pattern that we are searching for.">
 	<cfargument name="Delimiter" type="string" required="false" default="," hint="The set of characters that will be used to delimit the list items.">
 	<cfargument name="RegExDelimiter" type="boolean" required="false" default="false" hint="A flag to determine wether the list delimiter is a regular expression or a just a character set.">
 	<cfargument name="ReturnItem" type="boolean" required="false" default="false" hint="A flag to determine wether the item should be return along with the index (as part of a structure containing Pos and Item)">

	<!--- Define the local scope. --->
	<cfset var LOCAL = StructNew()>
	<!---
		Create a default return structure (we might not need
		it but just create a default structure).
	--->
	<cfset LOCAL.Return = StructNew()>
	<cfset LOCAL.Pos = 0>
	<cfset LOCAL.Item = "">
	<!---
		Check to see if our delimiter is a regular expression
		or not. Either way, we are going to convert the list
		to an array, but if it is a regular expression delmiter,
		we will use Java's String::Split() method as opposed to
		ColdFusion's ListToArray().
	--->
	<cfif ARGUMENTS.RegExDelimiter>
		<!---
			We are using a regular expression delimiter, so
			split using Java split.
		--->
		<cfset LOCAL.Items = ARGUMENTS.List.Split(ARGUMENTS.Delimiter)>
	<cfelse>
		<!---
			We are using a character set of delimiters. Just
			convert to array using ColdFusion.
		--->
		<cfset LOCAL.Items = ListToArray(ARGUMENTS.List,ARGUMENTS.Delimiter)>
	</cfif>
	<!---
		ASSERT: At this point, regardless of how we split the
		given list, we now have an array of list items. Be
		careful! It might not be a "Real" ColdFusion array, bit
		we can iterate over both objects like they are arrays.
	--->
	<!--- Loop over items array. --->
	<cfloop index="LOCAL.ItemIndex" from="1" to="#ArrayLen( LOCAL.Items )#" step="1">
		<!--- Check for a regular expression match. --->
		<cfif REFind(ARGUMENTS.RegEx,LOCAL.Items[ LOCAL.ItemIndex ])>
			<!---
				We found a list item match. Return the index
				of the list list item (or, the return structure
				if required).
			--->
			<cfif ARGUMENTS.ReturnItem>
				<!---
					Since we are returning the item structure,
					set the values and then return.
				--->
				<cfset LOCAL.Return.Pos = LOCAL.ItemIndex>
				<cfset LOCAL.Return.Item = LOCAL.Items[ LOCAL.ItemIndex ]>
				<!--- Return struct. --->
				<cfreturn LOCAL.Return>
			<cfelse>
				<!--- Just return the index. --->
				<cfreturn LOCAL.ItemIndex>
			</cfif>
		</cfif>
	</cfloop>
	<!---
		If we made it this far then we didn't find the
		matching list item so return zero (or, the structure
		with item and pos if required).
	--->
	<cfif ARGUMENTS.ReturnItem>
		<!--- Return item structure. --->
		<cfreturn LOCAL.Return>
	<cfelse>
		<!--- Just return index. --->
		<cfreturn 0>
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCREListFind=SVCREListFind>
<cffunction name="SVCFileReadFirstLast" access="public" output="false" returntype="struct">
<cfargument name="filepath" type="string" required="yes" hint="Filepath of text file to process" />
<cfargument name="maxcharsearch" type="numeric" default=1024 hint="Max character to search"/>
	// Efficiently grabs the first and last line of a text file and return it in a struct, ignoring blank lines
	// This uses JAVA RandomAccessFile instead of reading the whole file using CF functions to grab last line
	// This is used to test text file for header and ender line to see if it is complete
	<CFSET var chunkSize= maxcharsearch>
	<CFSET var Byte= createObject("java", "java.lang.Byte")>
	<CFSET var byteArray = createObject("java","java.lang.reflect.Array").newInstance(Byte.TYPE, javacast("int", chunkSize))>
	<CFSET var filesize = 0>
	<CFSET var line = "">
	<CFSET var T = 0>
	<CFSET var lineArr = ArrayNew(1)>
	<CFSET var Results=StructNew()>
	<CFSET var String = createObject("java", "java.lang.String")>
	<CFSET var accessFile = createObject("java", "java.io.RandomAccessFile")>
	<CFTRY>
		<CFSET accessFile.init(filepath, "r")>
		<cfcatch type = "Object">
			<CFTHROW TYPE="EX_SECFAILED" ERRORCODE="BADFILE" ExtendedInfo="Error reading file">
		</cfcatch>
	</CFTRY>
	<CFTRY>
		<CFSET Results.StartLine="">
		<CFSET Results.EndLine="">
		<CFSET Results.Result=0>
		<CFSET filesize=accessFile.length()>
		<CFSET chunkSize = min( chunkSize, filesize )>
		// Read start of file
		<CFSET accessFile.seek( 0 )>
		<CFSET accessFile.readFully( byteArray, javacast("int", 0), javacast("int",chunkSize) )>
	    <CFSET line = String.init( byteArray )>
		<CFSET lineArr=ListToArray(line,Chr(10))>

		<cfloop from=1 to=#ArrayLen(lineArr)# index=T>
			<CFIF Trim(lineArr[t]) IS NOT "">
				<CFSET Results.Result=BitOr(Results.Result,1)>
				<CFSET Results.StartLine=Trim(lineArr[t])>
				<CFBREAK>
			</CFIF>
		</CFLOOP>
		// Read end of file
		<CFSET accessFile.seek( filesize-chunkSize )>
		<CFSET accessFile.readFully( byteArray, javacast("int", 0), javacast("int",chunkSize) )>
		<CFSET line = String.init( byteArray )>
		<CFSET lineArr=ListToArray(line,Chr(10))>

		<cfloop from=#ArrayLen(lineArr)# to=1 STEP=-1 index=T>
			<CFIF Trim(lineArr[t]) IS NOT "">
				<CFSET Results.Result=BitOr(Results.Result,2)>
				<CFSET Results.EndLine=Trim(lineArr[t])>
				<CFBREAK>
			</CFIF>
		</CFLOOP>
		<CFSET accessFile.close()>
	<cfcatch type = "Any">
		<CFSET Results.Result=-1>
		<CFSET accessFile.close()>
		<CFRETHROW>
	</cfcatch>
	</cftry>
	<CFRETURN Results>
</cffunction>
<cfset Attributes.DS.FN.SVCFileReadFirstLast=SVCFileReadFirstLast>
<cffunction name="SVCgenerateRandomKey" access="public" output="false" returntype="string">
	<!---
	Generate a random key with options
	@author Michael Sharman (michael@chapter31.com)
	@version 0, May 9, 2009
	source : http://www.cflib.org/udf/generateRandomKey
	--->
    <cfargument name="case" type="string" default="upper" hint="Whether upper, lower or mixed" />
    <cfargument name="format" type="string" default="alphanumeric" hint="Whether to generate numeric, string, alphanumeric or special (includes alphanumeric and special characters such as ! @ & etc)" />
    <cfargument name="invalidCharacters" type="string" default="" hint="List of invalid characters which will be excluded from the key. This overrides the default list" />
	<cfargument name="length" type="numeric" default="8" hint="The length of the key to generate" />
	<cfargument name="specialChars" type="string" default="" hint="List of special chars to help generate key from. Overrides the default 'characterMap.special' list" />
    <cfargument name="debug" type="boolean" default="false" hint="Returns cfcatch information in the event of an error. Try turning on if function returns no value." />

    <cfscript>

        var i = 0;
        var key = "";
        var keyCase = arguments.case;
        var keyLength = arguments.length;
        var uniqueChar = "";
        var invalidChars = "o,i,l,s,O,0,1,I,L,S,5";    //Possibly confusing characters we will remove
        var characterMap = structNew();
        var characterLib = "";
        var libLength = 0;

        try
        {

            characterMap.numeric = "0,1,2,3,4,5,6,7,8,9";
            characterMap.stringLower = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z";
            characterMap.stringUpper = UCase(characterMap.stringLower);
            characterMap.stringCombined = listAppend(characterMap.stringLower, characterMap.stringUpper);

            if (len(trim(arguments.specialChars)))
                characterMap.special = arguments.specialChars;
            else
                characterMap.special = "!,@,##,$,%,^,&,*,(,),_,-,=,+,/,\,[,],{,},<,>,~";

            switch (arguments.format)
            {
                case "numeric":
                    characterLib = characterMap.numeric;
                    break;
                case "string":
                    if (keyCase EQ "upper")
                    {
                        characterLib = characterMap.stringUpper;
                    }
                    else if (keyCase EQ "lower")
                    {
                        characterLib = characterMap.stringLower;
                    }
                    else if (keyCase EQ "mixed")
                    {
                        characterLib = characterMap.stringCombined;
                    }
                    break;
                case "alphanumeric":
                    invalidChars = invalidChars.concat(",0,1,5");        //Possibly confusing chars removed
                    if (keyCase EQ "upper")
                    {
                        characterLib = listAppend(characterMap.numeric, characterMap.stringUpper);
                    }
                    else if (keyCase EQ "lower")
                    {
                        characterLib = listAppend(characterMap.numeric, characterMap.stringLower);
                    }
                    else if (keyCase EQ "mixed")
                    {
                        characterLib = listAppend(characterMap.numeric, characterMap.stringCombined);
                    }
                    break;
                case "special":
                    invalidChars = invalidChars.concat(",0,1,5");        //Possibly confusing chars removed
                    if (keyCase EQ "upper")
                    {
                        characterLib = listAppend(listAppend(characterMap.numeric, characterMap.stringUpper), characterMap.special);
                    }
                    else if (keyCase EQ "lower")
                    {
                        characterLib = listAppend(listAppend(characterMap.numeric, characterMap.stringLower), characterMap.special);
                    }
                    else if (keyCase EQ "mixed")
                    {
                        characterLib = listAppend(listAppend(characterMap.numeric, characterMap.stringCombined), characterMap.special);
                    }
                    break;
            }

            if (len(trim(arguments.invalidCharacters)))
                invalidChars = arguments.invalidCharacters;

            libLength = listLen(characterLib);

            for (i = 1;i LTE keyLength;i=i+1)
            {
                do
                {
                        uniqueChar = listGetAt(characterLib, randRange(1, libLength));
                }
                while (listFind(invalidChars, uniqueChar));
                key = key.concat(uniqueChar);
            }
        }
        catch (Any e)
        {
            if (arguments.debug)
                key = e.message & " " & e.detail;
            else
                key = "";
        }
        return key;
    </cfscript>
</cffunction>
<cfset Attributes.DS.FN.SVCgenerateRandomKey=SVCgenerateRandomKey>
<cffunction name=SVCdtFormat output=no returntype="string">
<cfargument name=db type="date">
<cfargument name=format type="numeric" default=0><!---0:en,1:ISO-8601 --->
<cfif format IS 1>
	<cfreturn DateFormat(db,"yyyy-MM-dd")&"T"&TimeFormat(db,"HH:mm:ss")>
<cfelse>
	<cfreturn DateFormat(db,"mmmm, dd yyyy")&" "&TimeFormat(db,"HH:mm:ss")>
</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCdtFormat=SVCdtFormat>
<cffunction name="SVCExcelToQuery" access="public" output="false" returntype="any">
<cfargument name="filename" required="true" type="string" />
<cfargument name="sheetName" required="true" type="string" />
<cfargument name="colList" default="" required="false" type="string" />
<cfargument name="extendedQuery" default="" required="false" type="string" />
<cfargument name="columns" default="" required="false" type="string" hint="CF9 - For cfspreadsheet : explicitly specify column range, otherwise empty columns with valid column header get truncated from the query when excludeHeaderRow=true is specified" />
<cfargument name="columnNames" default="" required="false" type="string" hint="CF9 - For cfspreadsheet : comma delimited list that renames the returned query column names" />
<cfargument name="ForceMethod" default="" required="false" type="string" hint="'CF': Use CF Spreadsheet, 'ODBC': Use ODBC. '': Use default choice" />
<CFSET var c="">
<CFSET var stmnt="">
<CFSET var rs="">
<CFSET var sql="">
<CFSET var myQuery="">
<CFSET arguments.filename=Trim(arguments.filename)>
<CFSET arguments.sheetName=Trim(arguments.sheetName)>
<CFSET arguments.colList=Trim(arguments.colList)>
<CFSET arguments.extendedQuery=Trim(arguments.extendedQuery)>
<CFSET arguments.ForceMethod=Trim(UCase(arguments.ForceMethod))>

<CFIF Arguments.ForceMethod IS NOT "CF" AND Arguments.ForceMethod IS NOT "ODBC">
	<CFSET Arguments.ForceMethod="">
</CFIF>
<CFIF len(arguments.filename) and fileExists(arguments.filename)>
	<!--- For CF8 machine only fix: Does not work on CF8 compiler which throws error, have to comment it off and use back the CustomTags version --->
	<cfif Arguments.ForceMethod IS "CF" OR (Arguments.ForceMethod IS "" AND ListFirst(SERVER.ColdFusion.ProductVersion,",") gte 9)>
		<!--- 	Use cfspreadsheet if CF9 and above.
				Have to put in separate template because otherwise CF8 will throw error when parsing
		--->
		<cfmodule template="#request.apppath#services/CustomTags\SVCCfSPreadSheet.cfm" filename="#arguments.filename#" sheetname="#arguments.sheetname#" collist="#arguments.collist#" extendedQuery="#arguments.extendedquery#" columns="#arguments.columns#" columnNames="#arguments.columnNames#">
	<cfelse>
		<CFIF arguments.collist IS "">
			<CFSET arguments.collist="*">
		</CFIF>
		<CFSET sql="Select #arguments.colList# from [#arguments.sheetName#$] "&arguments.extendedQuery>
		<CFTRY>
			<CFSET CreateObject("java","java.lang.Class").forName("sun.jdbc.odbc.JdbcOdbcDriver")>
			<CFSET c = CreateObject("java","java.sql.DriverManager").getConnection("jdbc:odbc:Driver={Microsoft Excel Driver (*.xls)};DBQ=" & arguments.filename )>
			<CFSET stmnt = c.createStatement()>
			<CFSET rs = stmnt.executeQuery(sql)>
			<CFSET myQuery = CreateObject("java","coldfusion.sql.QueryTable").init(rs)>
		<CFCATCH TYPE="ANY">
			<CFRETHROW>
		</CFCATCH>
		</CFTRY>
	</cfif>
</CFIF>
<CFRETURN myQuery>
</cffunction>
<cfset Attributes.DS.FN.SVCExcelToQuery=SVCExcelToQuery>
<cffunction name="SVCdateDiffString" returntype="string" output="no">
<cfargument name="date1" type="date" required="true">
<cfargument name="date2" type="date" default="#now()#" required="false">
<cfargument name="lgid" type="numeric" default="0" required="false">
<cfargument name="accuracy" type="string" default="s" required="false"><!--- d=Day,H=hour,M=minute,S=Second(default) --->
<cfset var dtDiff = (date2 - date1) />
<CFSET var str = "">
<CFSET var FN=Request.DS.FN>
<CFSET var tmp = 0>
<CFIF lgid IS 0>
	<cfif StructKeyExists(Request,"LGID") AND Request.LGID GTE 0>
		<cfset LGID=Request.LGID>
	<cfelseif StructKeyExists(SESSION,"VARS") AND StructKeyExists(SESSION.VARS,"LGID") AND SESSION.VARS.LGID GTE 0>
		<cfset LGID=SESSION.VARS.LGID>
	</cfif>
</CFIF>
<CFSET tmp = Fix(dtDiff)>
<CFIF tmp GT 1><CFSET str=str &" #tmp# " & Server.SVCLang("days",3642,lgid)><CFELSEIF tmp GT 0><CFSET str=str & " #tmp# " & Server.SVCLang("day",8452,lgid)></CFIF>
<CFIF accuracy IS NOT "d">
	<CFSET tmp = TimeFormat( dtDiff, "H" )>
	<CFIF tmp GT 1><CFSET str=str & " #tmp# " & Server.SVCLang("hours",13212,lgid)><CFELSEIF tmp GT 0><CFSET str=str & " #tmp# " & Server.SVCLang("hour",13213,lgid)></CFIF>
	<CFIF accuracy IS NOT "h">
		<CFSET tmp = TimeFormat( dtDiff, "m" )>
		<CFIF tmp GT 1><CFSET str=str & " #tmp# " & Server.SVCLang("minutes",11926,lgid)><CFELSEIF tmp GT 0><CFSET str=str & " #tmp# " & Server.SVCLang("minute",13214,lgid)></CFIF>
		<CFIF accuracy IS NOT "m">
			<CFSET tmp = TimeFormat( dtDiff, "s" )>
			<CFIF tmp GT 1><CFSET str=str & " #tmp# " & Server.SVCLang("seconds",13215,lgid)><CFELSEIF tmp GT 0><CFSET str=str & " #tmp# " & Server.SVCLang("second",13216,lgid)></CFIF>
		</CFIF>
	</CFIF>
</CFIF>
<CFRETURN Trim(str)>
</cffunction>
<cfset Attributes.DS.FN.SVCdateDiffString=SVCdateDiffString>

<cffunction name="SVClangDSUpdate" description="Updates DS with latest language set" access="public" returntype="boolean" output="false">
<cfargument name="DS" type="Struct" required="false" default=#Request.DS# hint="The DS to update.">
<cfargument name="DSNName" type="String" required="false" default=#Request.SVCDSN# hint="The DSN name to use.">
<cfset var lang=ArrayNew(2)>
<cfset var langdef={}>
<cfset var value={}>
<CFSET var applanglist=Application.APPLANGLIST>
<cfquery NAME=Local.q_lang DATASOURCE=#DSNName#>
SELECT a.siLANGID,a.iLID,a.vaTEXT FROM translation..LNG0003 a WITH (NOLOCK)
where a.siLANGID > 0
ORDER BY a.siLANGID,a.iLID
</cfquery>
<cfoutput query=Local.q_lang>
	<cfset lang[siLANGID][iLID]=vaTEXT>
</cfoutput>
<cfquery NAME=Local.q_langdef DATASOURCE=#DSNName#>
SELECT siLANGID,vaDESC,vaLCODE,ilid=isNULL(ilid,0) FROM translation..LNG0001 WITH (NOLOCK) ORDER BY vaDESC
</cfquery>
<cfoutput query=q_langdef>
	<cfset value={LANGID="#siLANGID#",LCODE="#vaLCODE#",DESC="#vaDESC#",ILID="#ILID#"}>
	<cfset StructInsert(langdef,siLANGID,value)>
</cfoutput>
<cflock SCOPE=Server Type=Exclusive TimeOut=60>
	<cfset Server.DS.LANG=lang>
	<cfset Server.DS.LANGDEF=langdef>
</cflock>
<CFIF applanglist IS "">
	<CFSET applanglist="en">
</CFIF>
<cfset DS.LANGLIST=applanglist>
<cfreturn true>
</cffunction>
<CFSET Attributes.DS.FN.SVClangDSUpdate=SVClangDSUpdate>

<!--- START: SVClang functions are shared accross the server --->
<cffunction name="SVClang" returntype="string" output="no">
	<cfargument name="TEXT" type="string">
	<cfargument name="LID" type="numeric" required="false" default=0>
	<cfargument name="LGID" type="any" required="false" default=0 hint="Language Definition ID (translation..LNG0001) / 0: Let the system decide (default), -1: Forcing no translation">

	<!--- Share the same logic in SVCmain.js -- JSVClang / SVCcffunctions.cfm -- SVClang --->
	<cfset var cur_DELIMS="">
	<cfset var cur_LGID2="">
	<cfset var cur_LGID="">
	<cfset var cur_TEXT="">
	<cfset var cur_SPANSTYLE="">
	<cfset var returnval="">
	<cfset var cur_TXT1="">
	<cfset var cur_TXT2="">
	<cfset var cur_FLIP=0>

	<cfset var displayLID = 0>
	<cfif isdefined("session.vars.userid") and listfindnocase("VNADJTRANS,VNTRANS,JPAIG", session.vars.userid) gt 0 and application.appdevmode eq 1>
		<cfset displayLID = 1>
  </cfif>

	<CFIF ArrayLen(Arguments) IS 1 and displayLID>
 		<cfreturn "[0]" & Arguments.TEXT>
	<cfelseif ArrayLen(Arguments) IS 1>
		<cfreturn Arguments.TEXT>
	</cfif>

	<cfif Arguments.LID GT 0>
		<cfif Isstruct(Arguments.LGID) AND NOT IsNumeric(Arguments.LGID)>
			<!--- primary language ID --->
			<cfset cur_LGID=0>
			<!--- secondary language ID --->
			<cfif StructKeyExists(Arguments.LGID,"LGID2")>
				<cfset cur_LGID2=#Arguments.LGID["LGID2"]#>
			</cfif>
			<!--- show both languages separated with delimiter provided --->
			<cfif StructKeyExists(Arguments.LGID,"DELIMS")>
				<cfset cur_DELIMS=#Arguments.LGID["DELIMS"]#>
			<cfelse>
				<cfset cur_DELIMS=" / "><!--- default --->
			</cfif>
			<cfif StructKeyExists(Arguments.LGID,"SPANSTYLE")>
				<cfset cur_SPANSTYLE=#Arguments.LGID["SPANSTYLE"]#>
			<cfelse>
				<cfset cur_SPANSTYLE=""><!--- default --->
			</cfif>
			<cfset cur_TEXT=#Arguments.TEXT#>
			<cfif StructKeyExists(Arguments.LGID,"FLIP")>
				<cfset cur_FLIP=Arguments.LGID["FLIP"]>
			</cfif>
			<!--- struct=?? --->
		<cfelse>
			<cfset cur_LGID=#Arguments.LGID#>
			<!--- <cfdump var="cur_LGID=#cur_LGID#"> --->
		</cfif>

		<cfif cur_LGID IS 0>
			<!--- 0: Let the system decide (default) --->
			<cfif StructKeyExists(Request,"LGID") AND Request.LGID GTE 0>
				<cfset cur_LGID=Request.LGID>
			<cfelseif StructKeyExists(SESSION,"VARS") AND StructKeyExists(SESSION.VARS,"LGID") AND SESSION.VARS.LGID GTE 0>
				<cfset cur_LGID=SESSION.VARS.LGID>
			</cfif>
		<cfelseif cur_LGID IS -1>
			<!--- -1: Forcing no translation --->
			<cfset cur_LGID=0>
		</cfif>
		<cfif cur_LGID GT 0>
			<cfif cur_LGID LTE ArrayLen(Server.DS.LANG) AND ArrayIsDefined(Server.DS.LANG,cur_LGID) AND Arguments.LID LTE ArrayLen(Server.DS.LANG[cur_LGID]) AND ArrayIsDefined(Server.DS.LANG[cur_LGID],Arguments.LID)>
				<cfset Arguments.TEXT=Server.DS.LANG[cur_LGID][Arguments.LID]>
			</cfif>
		</cfif>
	</cfif>

	<cfif ArrayLen(Arguments) GTE 4>
		<cfloop from=4 to=#ArrayLen(Arguments)# index=Local.P>
			<cfset Arguments.TEXT=Replace(Arguments.TEXT,"{"&Local.P-4&"}",Arguments[Local.P],"all")>
		</cfloop>
	</cfif>

	<cfif cur_LGID2 NEQ "" AND cur_TEXT NEQ "" AND cur_LGID2 NEQ cur_LGID>
		<!--- Secondary language --->
		<cfif cur_LGID2 EQ 0>
			<!--- Do not translate (for English display) --->
			<cfset returnval=cur_TEXT>
		<cfelse>
			<cfset returnval=Server.SVClang(cur_TEXT,Arguments.LID,cur_LGID2)>
		</cfif>
		<cfif cur_FLIP EQ 1>
			<cfset cur_TXT1=returnval>
			<cfset cur_TXT2=Arguments.TEXT>
		<cfelse>
			<cfset cur_TXT1=Arguments.TEXT>
			<cfset cur_TXT2=returnval>
		</cfif>
		<cfif cur_SPANSTYLE NEQ "">
			<cfset Arguments.TEXT="#cur_TXT1##cur_DELIMS#<span style=""#cur_SPANSTYLE#"">#cur_TXT2#</span>">
		<cfelse>
			<cfset Arguments.TEXT="#cur_TXT1##cur_DELIMS##cur_TXT2#">
		</cfif>
	</cfif>

	<cfif displayLID>
		<cfset Arguments.TEXT = "[#Arguments.LID#]" & Arguments.TEXT>
	</cfif>

	<cfreturn Arguments.TEXT>
</cffunction>
<cfset Server.SVClang=SVClang>
<CFSET Attributes.DS.FN.SVClang = SVClang>

<cffunction name="SVClangSet" returntype="string" output="yes">
<cfargument name="lcode" type="string" required="true">
<cfargument name="mode" type="numeric" required="false" default=1><!--- Bit 1:Set REQUEST,Bit 2:Set SESSION,Bit 4:Set default lang based on LOCID --->
<cfset var lgid=0>
<cfset var locid=0>
<cfset var q_trxlang={}>
<cfif BitAnd(mode,4) IS 4>
	<cfif StructKeyExists(SESSION,"VARS") AND StructKeyExists(SESSION.VARS,"LOCID")>
		<cfset locid=SESSION.VARS.LOCID>
	<cfelse>
		<cfset locid=Application.APPLOCID>
	</cfif>
	<cfif locid IS 7>
		<cfset lgid=2><!--- Indonesian --->
	<cfelseif locid IS 8>
		<cfset lgid=3><!--- French --->
	<cfelseif locid IS 12>
		<cfset lgid=1><!--- Chinese --->
	<cfelseif locid IS 15>
		<cfset lgid=5><!--- Vietnamese --->
	<cfelseif locid IS 11>
		<cfset lgid=6><!--- Thai --->
	<cfelseif locid IS 17>
		<cfset lgid=7><!--- Japanese --->
	<cfelse>
		<cfset lgid=0><!--- Default: English --->
	</cfif>
<cfelse>
	<!--- Try to decude LGID from LCODE passed in --->
	<cfif NOT IsNumeric(lcode) AND Len(lcode) IS 2>
		<cfquery name=q_trxlang datasource="#Request.SVCDSN#">
		SELECT siLANGID FROM translation..LNG0001 WITH (NOLOCK) WHERE vaLCODE=<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="2" value="#lcode#">
		</cfquery>
		<cfif q_trxlang.recordcount IS NOT 1>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM" ExtendedInfo="LCODE is invalid">
		<cfelse>
			<cfset lgid=q_trxlang.siLANGID>
		</cfif>
	<cfelse>
		<cfset lgid=Val(lcode)>
	</cfif>
</cfif>
<cfif BitAnd(mode,1) IS 1>
	<cfset Request.LGID=lgid>
</cfif>
<cfif BitAnd(mode,2) IS 2>
	<cflock scope="session" type="exclusive" timeout="30">
		<cfset SESSION.VARS.LGID=lgid>
	</cflock>
</cfif>
<cfif lgid GTE 0><script>request.lgid=#lgid#;</script></cfif>
</cffunction>
<cfset Server.SVClangSet=SVClangSet>
<CFSET Attributes.DS.FN.SVClangSet = SVClangSet>
<!--- END: SVClang functions --->

<cffunction name="SVCRemoteIpAddr" returntype="string" output="no">
	<!--- More accurate way of Client IP detection (due to Cloudfare masking) --->
	<cfset var remoteAddress="">
	<cfset var str="">
	<!--- getHttpRequestData() breaks SOAP webservice in CF as reported by Danny
		https://www.bennadel.com/blog/1602-gethttprequestdata-breaks-the-soap-request-response-cycle-in-coldfusion.htm
		https://stackoverflow.com/questions/3980194/gethttprequestdata-and-soap-web-service-request-in-coldfusion-8
	--->
	<!--- cfset var httpHeaders=getHttpRequestData().headers>
	<cfif remoteAddress IS "" AND structKeyExists(httpHeaders,"CF-Connecting-IP")>
		<cfset remoteAddress=httpHeaders["CF-Connecting-IP"]>
	</cfif>
	<cfif remoteAddress IS "" AND structKeyExists(httpHeaders,"X-Forwarded-For")>
		<cfset remoteAddress=httpHeaders["X-Forwarded-For"]>
	</cfif--->
	<cfif remoteAddress IS "">
		<cfset str=Trim(getPageContext().getRequest().getHeader("CF-Connecting-IP"))>
		<cfif str IS NOT "">
			<cfset remoteAddress=str>
		</cfif>
	</cfif>
	<cfif remoteAddress IS "">
		<cfset str=Trim(getPageContext().getRequest().getHeader("X-Forwarded-For"))>
		<cfif str IS NOT "">
			<cfset remoteAddress=str>
		</cfif>
	</cfif>
	<cfif remoteAddress IS "">
		<cfset remoteAddress=CGI.REMOTE_ADDR>
	</cfif>
	<cfreturn remoteAddress>
</cffunction>
<cfset Attributes.DS.FN.SVCRemoteIpAddr=SVCRemoteIpAddr>

<cffunction name="SVCRequestIpChk" output="no">
	<cfset var IPWhiteList="(202.157.152.8)|(202.157.152.9)|(203.115.213.2)|(202.144.202.3)|(202.144.202.4)|(60.49.154.110)|(175.143.126.153)|(175.143.126.154)|(202.190.197.5)|(121.7.217.185)|(203.115.234.151)|(219.92.16.113)|(202.136.168.112)|(202.136.168.108)">

	<!--- Special whitelist IP address for Site24x7 (GIA monitoring purpose) --->
	<cfset IPWhiteList&="|(175.41.141.147)|(139.162.14.50)|(139.162.59.38)|(94.237.64.172)|(121.244.91.46)|(122.15.156.174)|(103.6.87.115)|(209.58.160.49)">

	<!--- Cloudfare --->
	<!---cfset IPWhiteList&="|(172.68.144.)|(162.158.167.)"--->

	<!--- More accurate way of Client IP detection (due to Cloudfare masking) --->
	<cfset remoteAddress=Request.DS.FN.SVCRemoteIpAddr()>

	<cfif NOT(REFindNoCase("^(127.)|(192.)|(10.1.)|(10.2.)|(10.10.)|#IPWhiteList#",remoteAddress) GT 0 OR remoteAddress IS "::1")>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="IPADDR-NOACCESS(#remoteAddress#)">
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCRequestIpChk=SVCRequestIpChk>

<cffunction name="SVCErrorProcessStdXML" returntype="String" output="no">
<cfargument name="ErrorStruct" type="any" required="true"><!--- Pass in CFCATCH or ERROR here --->
<cfargument name="ErrorLogTable" type="string" default="" required="false"><!--- Pass in CFCATCH or ERROR here --->
<cfset var Ret=StructNew()/>
<cfset StructAppend(Ret,ErrorStruct,true) /><!--- CFCATCH not a struct, cannot use structcopy or duplicate --->
<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCroot FUSEACTION=dsp_errordefine ERRORSTRUCT=#Ret#>
<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCroot FUSEACTION=dsp_errorhandler ERRORSTRUCT=#Ret# ErrorDisplay=0 ErrorLogTable=#ErrorLogTable#>
<CFSET str="<RESULT><STATUS>ERR</STATUS>">
<CFSET str=str&"<APPCODE>#XMLFormat(Ret.ErrCode)#</APPCODE>">
<CFSET str=str&"<APPDESC>#XMLFormat(Ret.ErrTitle)#</APPDESC>">
<CFIF StructKeyExists(Ret,"ExtInfo")>
	<CFSET str=str&"<APPERREXTINFO>#XMLFormat(Ret.ExtInfo)#</APPERREXTINFO>">
</CFIF>
<CFIF StructKeyExists(Ret,"ErrLogID") AND Ret.ErrLogID GT 0>
	<CFSET str=str&"<APPERRLOG ID=""#XMLFormat(Ret.ErrLogID)#""/>">
</CFIF>
<CFSET str=str&"</RESULT>">
<CFRETURN str>
</cffunction>
<cfset Attributes.DS.FN.SVCErrorProcessStdXML=SVCErrorProcessStdXML>
<cffunction name="SVCPreprocessErrorStruct" returntype="Struct" output="no">
<cfargument name="ErrorStruct" type="struct" required="true">
<CFIF StructKeyExists(ErrorStruct,"ErrType")>
	<!--- Check that this is only processed once --->
	<CFRETURN ErrorStruct>
</CFIF>
<CFSET ErrorStruct.ErrRootCause=ErrorStruct>
<CFIF StructKeyExists(ErrorStruct,"RootCause")>
	<!--- CF MX & CF8 --->
	<CFSET ErrorStruct.ErrRootCause=ErrorStruct.RootCause>
	<CFSET ErrorStruct.ErrType=ErrorStruct.RootCause.Type>
	<CFSET ErrorStruct.ErrCode=ErrorStruct.RootCause.ErrorCode>
	<CFSET ErrorStruct.ExtInfo=ErrorStruct.RootCause.ExtendedInfo>
<CFELSE>
	<CFSET ErrorStruct.ErrRootCause=ErrorStruct>
	<CFIF StructKeyExists(ErrorStruct,"ExtendedInfo")>
		<CFSET ErrorStruct.ExtInfo=ErrorStruct.ExtendedInfo>
	<CFELSE>
		<CFSET ErrorStruct.ExtInfo="">
	</CFIF>
	<CFIF StructKeyExists(ErrorStruct,"ErrorCode")>
		<CFSET ErrorStruct.ErrCode=ErrorStruct.ErrorCode>
	<CFELSE>
		<CFSET ErrorStruct.ErrCode="">
	</CFIF>
	<CFIF StructKeyExists(ErrorStruct,"Type")>
		<CFSET ErrorStruct.ErrType=ErrorStruct.Type>
	<CFELSE>
		<CFSET ErrorStruct.ErrType="">
	</CFIF>
</CFIF>
<CFIF (Not IsDefined("SESSION.VARS") or StructIsEmpty(Session.vars)) and IsDefined("URL.USID") and ErrorStruct.ErrCode is not "LoginErr" AND StructKeyExists(ErrorStruct,"Diagnostics") AND Find("VARS",ErrorStruct.Diagnostics) GT 0>
	<!--- Trap Error --->
	<CFSET ErrorStruct.ErrType="EX_SECFAILED">
	<CFSET ErrorStruct.ErrCode="NOLOGIN">
</CFIF>
<CFIF ErrorStruct.ErrCode IS "" AND IsDefined("REQUEST.CFERR_ERRORCODE")>
	<!--- BD7 compatibility --->
	<CFSET ErrorStruct.ErrCode=REQUEST.CFERR_ERRORCODE>
</CFIF>
<CFIF ErrorStruct.ExtInfo IS "" AND IsDefined("REQUEST.CFERR_EXTENDEDINFO")>
	<!--- BD7 compatibility --->
	<CFSET ErrorStruct.ExtInfo=REQUEST.CFERR_EXTENDEDINFO>
</CFIF>
<CFSET ErrorStruct.ErrLogMode=0>
<CFSET ErrorStruct.ErrRelogin=0>
<CFSET ErrorStruct.ErrHandled=0>
<CFSET ErrorStruct.ErrLogID=0>
<CFRETURN ErrorStruct>
</CFFUNCTION>
<cfset Attributes.DS.FN.SVCPreprocessErrorStruct=SVCPreprocessErrorStruct>

<!--- http://www.cflib.org/udf/jsonencode
#Request.DS.Fn.SVCSerializeJSON(q_test,'query','upper',false,true,'native')#  equivalent to #serializeJSON(q_test,false)#
#Request.DS.Fn.SVCSerializeJSON(q_test,'query','upper',false,true,'query')#  equivalent to #serializeJSON(q_test,true)#
--->
<cffunction name="SVCSerializeJSON" returntype="string" output="No"	hint="Converts data from CF to JSON format. SerializeJSON is annoying.">
	<cfargument name="data" type="any" required="Yes" />
	<cfargument name="queryFormat" type="string" required="No" default="query" /> <!--- query or array --->
	<cfargument name="queryKeyCase" type="string" required="No" default="lower" /> <!--- lower or upper --->
	<cfargument name="stringNumbers" type="boolean" required="No" default=false ><!--- formats numbers as "1" or 1 --->
	<cfargument name="formatDates" type="boolean" required="No" default=false ><!--- formats dates --->
	<cfargument name="columnListFormat" type="string" required="No" default="string" > <!--- string or array or native --->
	<cfargument name="preserveHTML" type="boolean" required="No" default="false"><!--- preserve most of the HTML except script|embed|applet|meta|object|video|audio|canvas|frame|input|button|iframe|form --->

	<!--- VARIABLE DECLARATION --->
	<cfset var tempVal = "" />
	<cfset var arKeys = "" />
	<cfset var colPos = 1 />
	<cfset var i = 1 />
	<cfset var column = ""/>
	<cfset var datakey = ""/>
	<cfset var recordcountkey = ""/>
	<cfset var columnlist = ""/>
	<cfset var columnlistkey = ""/>
	<cfset var dJSONString = "" />
	<cfset var escapeToVals = "\\,\"",\/,\b,\t,\n,\f,\r" />
	<cfset var escapeVals = "\,"",/,#Chr(8)#,#Chr(9)#,#Chr(10)#,#Chr(12)#,#Chr(13)#" />

	<cfset var _data = arguments.data />
	<cfset var blacklist = "" />

	<cfif arguments.preserveHTML>
		<cfset blacklist = "(script|embed|applet|meta|object|video|audio|canvas|frame|input|button|iframe|form)">
	</cfif>

	<!--- BOOLEAN --->
	<cfif IsBoolean(_data) AND IsBoolean(trim(_data)) AND NOT IsNumeric(_data) AND NOT ListFindNoCase("Yes,No", _data)>
		<cfreturn LCase(ToString(_data)) />

	<!--- NUMBER --->
	<cfelseif NOT stringNumbers AND IsNumeric(_data) AND NOT REFind("^[\+0]+[^\.]",_data)>
		<cfreturn ToString(_data) />

	<!--- DATE --->
	<cfelseif IsDate(_data) AND arguments.formatDates>
		<cfreturn '"#DateFormat(_data, "mmmm, dd yyyy")# #TimeFormat(_data, "HH:mm:ss")#"' />

	<!--- STRING --->
	<cfelseif IsSimpleValue(_data)>
		<cfreturn '"' & ReplaceList(_data, escapeVals, escapeToVals) & '"' />

	<!--- ARRAY --->
	<cfelseif IsArray(_data)>
		<cfset dJSONString = createObject('java','java.lang.StringBuffer').init("") />
		<cfloop from="1" to="#ArrayLen(_data)#" index="i">
			<cfset tempVal = REQUEST.DS.FN.SVCSerializeJSON( _data[i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
			<cfif dJSONString.toString() EQ "">
				<cfset dJSONString.append(tempVal) />
			<cfelse>
				<cfset dJSONString.append("," & REREPLACENOCASE(tempVal,"<(/?#blacklist#[^>]*)>","&lt;\1&gt;","all")) />
			</cfif>
		</cfloop>

		<cfreturn "[" & dJSONString.toString() & "]" />

	<!--- STRUCT --->
	<cfelseif IsStruct(_data)>
		<cfset dJSONString = createObject('java','java.lang.StringBuffer').init("") />
		<cfset arKeys = StructKeyArray(_data) />
		<cfloop from="1" to="#ArrayLen(arKeys)#" index="i">
			<cfset tempVal = REQUEST.DS.FN.SVCSerializeJSON( _data[ arKeys[i] ], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
			<cfif dJSONString.toString() EQ "">
				<cfset dJSONString.append('"' & arKeys[i] & '":' & tempVal) />
			<cfelse>
				<cfset dJSONString.append("," & '"' & arKeys[i] & '":' & REREPLACENOCASE(tempVal,"<(/?#blacklist#[^>]*)>","&lt;\1&gt;","all") ) />
			</cfif>
		</cfloop>

		<cfreturn "{" & dJSONString.toString() & "}" />

	<!--- QUERY --->
	<cfelseif IsQuery(_data)>
		<cfset dJSONString = createObject('java','java.lang.StringBuffer').init("") />

		<!--- Add query meta data --->
		<cfif arguments.queryKeyCase EQ "lower">
			<cfset recordcountKey = "ROWCOUNT" />
			<cfset columnlistKey = "columns" />
			<cfset columnlist = LCase(_data.columnlist) />
			<cfset dataKey = "data" />
		<cfelse>
			<cfset recordcountKey = "ROWCOUNT" />
			<cfset columnlistKey = "COLUMNS" />
			<cfset columnlist = _data.columnlist />
			<cfset dataKey = "DATA" />
		</cfif>

		<cfif arguments.columnListFormat EQ "native">
			<cfset columnlist = "[" & ListQualify(columnlist, '"') & "]" />
			<cfset dJSONString.append('"#columnlistKey#":' & columnlist) />
		<cfelse>
			<cfset dJSONString.append('"#recordcountKey#":' & _data.recordcount) />
			<cfset columnlist = "[" & ListQualify(columnlist, '"') & "]" />
			<cfset dJSONString.append(',"#columnlistKey#":' & columnlist) />
		</cfif>
		<cfset dJSONString.append(',"#dataKey#":') />

		<!--- Make query a structure of arrays --->
		<cfif arguments.queryFormat EQ "query">
			<cfif arguments.columnListFormat eq "native">
					<cfset dJSONString.append("[") />
					<cfloop from="1" to="#_data.recordcount#" index="i"><cfset colcount=0>
						<cfset dJSONString.append("[") />
						<cfloop list="#_data.columnlist#" delimiters="," index="column"><cfset colcount+=1>
							<!--- <cfif isdefined("attributes.formatDates") and attributes.formatDates eq false AND isdefined("attributes.stringNumbers") and attributes.stringNumbers eq false> --->
								<cfset tempVal = REQUEST.DS.FN.SVCSerializeJSON( _data[column][i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
								<cfset dJSONString.append( REREPLACENOCASE(tempVal,"<(/?#blacklist#[^>]*)>","&lt;\1&gt;","all") ) />
							<!--- <cfelse>
								<cfset dJSONString.append( '"' & _data[column][i] &'"') />
							</cfif> --->
							<cfif listlen(_data.columnlist) neq colcount><cfset dJSONString.append(",") /></cfif>
						</cfloop>

						<cfset dJSONString.append("]") />
						<cfif i neq _data.recordCount>
							<cfset dJSONString.append(",") />
						</cfif>
					</cfloop>

					<cfset dJSONString.append("]") />
			<cfelse>
				<cfset dJSONString.append("{") />
				<cfset colPos = 1 />

				<cfloop list="#_data.columnlist#" delimiters="," index="column">
					<cfif colPos GT 1>
						<cfset dJSONString.append(",") />
					</cfif>
					<cfif arguments.queryKeyCase EQ "lower">
						<cfset column = LCase(column) />
					</cfif>
					<cfset dJSONString.append('"' & column & '":[') />

					<cfloop from="1" to="#_data.recordcount#" index="i">
						<!--- Get cell value; recurse to get proper format depending on string/number/boolean data type --->
						<cfset tempVal = REQUEST.DS.FN.SVCSerializeJSON( _data[column][i], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />
						<cfif i GT 1>
							<cfset dJSONString.append(",") />
						</cfif>
						<cfset dJSONString.append( REREPLACENOCASE(tempVal,"<(/?#blacklist#[^>]*)>","&lt;\1&gt;","all") ) />
					</cfloop>

					<cfset dJSONString.append("]") />

					<cfset colPos = colPos + 1 />
				</cfloop>
				<cfset dJSONString.append("}") />
			</cfif>
		<!--- Make query an array of structures --->
		<cfelse>
			<cfset dJSONString.append("[") />
			<cfloop query="_data">
				<cfif CurrentRow GT 1>
					<cfset dJSONString.append(",") />
				</cfif>
				<cfset dJSONString.append("{") />
				<cfset colPos = 1 /><br />

				<cfloop list="#columnlist#" delimiters="," index="column">
					<!--- <cfdump var="#rereplacenocase(column,'[\]','','ALL')#"><cfabort> --->

					<cfset tempVal = REQUEST.DS.FN.SVCSerializeJSON( _data[column][CurrentRow], arguments.queryFormat, arguments.queryKeyCase, arguments.stringNumbers, arguments.formatDates, arguments.columnListFormat ) />

					<cfif colPos GT 1>
						<cfset dJSONString.append(",") />
					</cfif>

					<cfif arguments.queryKeyCase EQ "lower">
						<cfset column = LCase(column) />
					</cfif>

					<cfset dJSONString.append('"' & column & '":' & REREPLACENOCASE(tempVal,"<(/?#blacklist#[^>]*)>","&lt;\1&gt;","all") ) />

					<cfset colPos = colPos + 1 />
				</cfloop>
				<cfset dJSONString.append("}") />
			</cfloop>
			<cfset dJSONString.append("]") />
		</cfif>

		<!--- Wrap all query data into an object --->
		<cfreturn "{" & dJSONString.toString() & "}" />

	<!--- UNKNOWN OBJECT TYPE --->
	<cfelse>
		<cfreturn '"' & "unknown-obj" & '"' />
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCSerializeJSON=SVCSerializeJSON>

<cffunction name="SVCgetExtAttr" returntype="string" output="no" hint="Get extended attribute by PK (ATTRTYPE/ATTRID)">
<cfargument name=ATTRTYPE type="string">
<cfargument name=ATTRID type="numeric">
<cfargument name=OWNDOMID type="numeric">
<cfargument name=OWNOBJID type="numeric">
<cfargument name=ATTRLOC type="numeric" default=0 required="no">
<cfargument name=ATTRCOL type="numeric" default=0 required="no">
<cfset var ResultCode=0>
<cfset var AttrValue="">
<CFSTOREDPROC PROCEDURE="sspFSYSExAttrValueGet" DATASOURCE="#Application.SVCDSN#" RETURNCODE="YES">
<CFPROCPARAM TYPE="IN" DBVARNAME="@as_attrtype" VALUE="#Arguments.ATTRTYPE#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH=8>
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_owndomid" VALUE="#Arguments.OWNDOMID#" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_ownobjid" VALUE="#Arguments.OWNOBJID#" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_attrid" VALUE="#Arguments.ATTRID#" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@asi_attrloc" VALUE="#Arguments.ATTRLOC#" CFSQLTYPE="CF_SQL_SMALLINT">
<CFPROCPARAM TYPE="OUT" DBVARNAME="@as_value" VARIABLE="AttrValue" CFSQLTYPE="CF_SQL_VARCHAR">
<CFPROCPARAM TYPE="IN" DBVARNAME="@asi_attrcol" VALUE="#Arguments.ATTRCOL#" CFSQLTYPE="CF_SQL_SMALLINT">
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_subdom" NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@as_logicname" NULL="YES" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH=50>
</CFSTOREDPROC>
<CFSET ResultCode=CFSTOREDPROC.STATUSCODE>
<CFIF ResultCode LT 0>
	<CFTHROW TYPE="EX_DBERROR" ErrorCode="SVCgetExtAttr(#ResultCode#)">
</CFIF>
<cfreturn AttrValue>
</cffunction>
<cfset Attributes.DS.FN.SVCgetExtAttr=SVCgetExtAttr>

<cffunction name="SVCgetExtAttrLogic" returntype="string" output="no" hint="Get extended attribute by logic (ATTRTYPE/SUBDOM/LOGICNAME)">
<cfargument name=ATTRTYPE type="string">
<cfargument name=SUBDOM type="numeric">
<cfargument name=LOGICNAME type="string">
<cfargument name=OWNDOMID type="numeric">
<cfargument name=OWNOBJID type="numeric">
<cfargument name=ATTRLOC type="numeric" default=0 required="no">
<cfargument name=ATTRCOL type="numeric" default=0 required="no">
<cfset var ResultCode=0>
<cfset var AttrValue="">
<CFSTOREDPROC PROCEDURE="sspFSYSExAttrValueGet" DATASOURCE="#Application.SVCDSN#" RETURNCODE="YES">
<CFPROCPARAM TYPE="IN" DBVARNAME="@as_attrtype" VALUE="#Arguments.ATTRTYPE#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH=8>
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_owndomid" VALUE="#Arguments.OWNDOMID#" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_ownobjid" VALUE="#Arguments.OWNOBJID#" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_attrid" VALUE=0 CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@asi_attrloc" VALUE="#Arguments.ATTRLOC#" CFSQLTYPE="CF_SQL_SMALLINT">
<CFPROCPARAM TYPE="OUT" DBVARNAME="@as_value" VARIABLE="AttrValue" CFSQLTYPE="CF_SQL_VARCHAR">
<CFPROCPARAM TYPE="IN" DBVARNAME="@asi_attrcol" VALUE="#Arguments.ATTRCOL#" CFSQLTYPE="CF_SQL_SMALLINT">
<CFPROCPARAM TYPE="IN" DBVARNAME="@ai_subdom" VALUE="#Arguments.SUBDOM#" CFSQLTYPE="CF_SQL_INTEGER">
<CFPROCPARAM TYPE="IN" DBVARNAME="@as_logicname" VALUE="#Arguments.LOGICNAME#" CFSQLTYPE="CF_SQL_VARCHAR" MAXLENGTH=50>
</CFSTOREDPROC>
<CFSET ResultCode=CFSTOREDPROC.STATUSCODE>
<CFIF ResultCode LT 0>
	<CFTHROW TYPE="EX_DBERROR" ErrorCode="SVCgetExtAttrLogic(#ResultCode#)">
</CFIF>
<cfreturn AttrValue>
</cffunction>
<cfset Attributes.DS.FN.SVCgetExtAttrLogic=SVCgetExtAttrLogic>

<cffunction name="SVCgetIDType" returntype="numeric" output="no" hint="">
<!--- Returns 1 if IDTYPEID is company type, 2 if individual type, 0 if not found --->
<cfargument name=IDTYPEID type="string" required="true" description="The IDTYPEID to retrieve type">
<cfset var Result=0>
<CFIF StructKeyExists(Request.DS.IDtypes,IDTYPEID)>
	<CFSET Result=StructFind(Request.DS.IDtypes,IDTYPEID).IdType>
</CFIF>
<cfreturn Result>
</cffunction>
<cfset Attributes.DS.FN.SVCgetIDType=SVCgetIDType>

<cffunction name="SVCgetIDName" returntype="string" output="no" hint="">
<!--- Returns the Name of the IDTypeID --->
<cfargument name=IDTYPEID type="string" required="true" description="The IDTYPEID to retrieve name">
<cfargument name=DEFNAME type="string" required="false" default="" description="The default name if IDTYPE not found">
<cfargument name=LGID type="numeric" required="false" default=0 description="The LGID (Language) to retrieve. Pass in -1 to retrieve original string without checking LID. Pass in 0 or leave out to use current language.">
<cfset var str=0>
<CFIF StructKeyExists(Request.DS.IDtypes,IDTYPEID)>
	<CFSET str=StructFind(Request.DS.IDtypes,IDTYPEID)>
	<CFSET DEFNAME=str.Name>
	<CFIF LGID GTE 0 AND StructKeyExists(str,"LID")>
		<CFSET DEFNAME=Server.SVCLang(DEFNAME,str.LID,LGID)>
	</CFIF>
</CFIF>
<cfreturn DEFNAME>
</cffunction>
<cfset Attributes.DS.FN.SVCgetIDName=SVCgetIDName>

<cffunction name="SVCgetFullRoot" returntype="string" output="no" hint="Returns the full root." >
<cfset var fullroot = "">
<cfset var port = "">
<cfif CGI.HTTPS EQ "ON">
	<cfset fullroot="https://" & CGI.SERVER_NAME & REQUEST.WEBROOT>
<cfelse>
	<cfif Application.APPDEVMODE IS 1>
		<cfif CGI.SERVER_PORT IS NOT 80>
			<cfset port=":" & CGI.SERVER_PORT>
		<cfelse>
			<cfset port="">
		</cfif>
	<cfelse>
		<cfset port="">
	</cfif>
	<cfset fullroot="http://" & CGI.SERVER_NAME & port & REQUEST.WEBROOT>
</cfif>
<cfreturn fullroot>
</cffunction>
<cfset Attributes.DS.FN.SVCgetFullRoot=SVCgetFullRoot>
<cffunction name="SVCSanitizeInput" returntype="string" output="no" hint="Returns input string with dangerous XSS characters removed." >
<cfargument name=PARAM type="string" required="True" default=""
			description="The input string to sanitize"
			hint="">
<cfargument name=METHOD type="string" required="False" default="JS"
			description=""
			hint="JS-NQ:Remove all quotes and </blacklist tags
					JS:Replace blacklisted tags with </InvalidTag and JSEscapes quotes
					SQL:Replaces sql wildcard characters, [, % and _
					SQLVAR:Remove dangerous SQL injection characters from dynamic variable">
<cfargument name=RETEMPTY type="boolean" required="False" default="false"
			description="Return Empty"
			hint="Return empty string if dangerous XSS characters detected.">
	<cfset var blacklist = "(script|embed|applet|meta|object|video|audio|canvas|frame|input|button|iframe|form|body|alert|console)">
	<cfset var oriparam = ARGUMENTS.PARAM>
	<cfset var htmlpunc=[
					{m=";",r="&##59;"},
					{m="'",r="&##39;"},
					{m="=",r="&##61;"},
					{m="/",r="&##47;"},
					{m="\",r="&##92;"}
				]>
	<cfset var str={}>
		<CFIF Arguments.METHOD IS "JS-NQ" OR Arguments.METHOD IS "JSNQ" OR Arguments.METHOD IS "JS_NQ">
			<cfset Arguments.PARAM=jsstringformat(REReplaceNoCase(Arguments.PARAM,"['""]|</?#blacklist#","","ALL"))>
		<CFELSEIF Arguments.METHOD IS "JS">
			<cfset Arguments.PARAM=JSStringFormat(REReplaceNoCase(Arguments.PARAM,"<(/?)#blacklist#","<\1InvalidTag","ALL"))>
		<CFELSEIF Arguments.METHOD IS "HTML">
			<CFLOOP array=#htmlpunc# index=str>
				<cfset Arguments.PARAM=Replace(Arguments.PARAM, str.m, str.r, "ALL")>
			</CFLOOP>
			<!---cfset Arguments.PARAM=Replace(Arguments.PARAM, ";", "&##59;", "ALL")>
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "'", "&##39;", "ALL")>
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "=", "&##61;", "ALL")>
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "/", "&##47;", "ALL")>
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "\", "&##92;", "ALL")--->
			<cfset Arguments.PARAM=HTMLEditFormat(Arguments.PARAM)><!--- covers <, >, ",& --->
			<!--- The HTMLEditFormat() above will replace the matched items for ex. '&#47' into '&amp;#47', which we need to mitigate. --->
			<CFLOOP array=#htmlpunc# index=str>
				<cfset Arguments.PARAM=Replace(Arguments.PARAM, HTMLEditFormat(str.r), str.r, "ALL")>
			</CFLOOP>
		<CFELSEIF Arguments.METHOD eq "SQL">
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "[", "[[]", "ALL")>
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "%", "[%]", "ALL")>
			<cfset Arguments.PARAM=Replace(Arguments.PARAM, "_", "[_]", "ALL")>
		<CFELSEIF Arguments.METHOD eq "SQLVAR">
			<cfset Arguments.PARAM=REReplaceNoCase(Arguments.PARAM, "[^\_a-z0-9@\.\-]", "", "ALL")>
		</CFIF>
		<CFIF arguments.RETEMPTY and oriparam neq Arguments.PARAM>
			<cfset Arguments.PARAM = "">
		</CFIF>
	<cfreturn Arguments.PARAM>
</cffunction>
<cfset Attributes.DS.FN.SVCSanitizeInput=SVCSanitizeInput>

<cffunction name="SVCSanitizeAllForm" output="no" hint="Sanitize everything in the FORM struct.">
	<cfif structKeyExists(form, "fieldnames")>
	    <cfloop list="#form.fieldNames#" index="i">
			<cfset form[i] = REQUEST.DS.FN.SVCSanitizeInput(form[i],"HTML")>
	    </cfloop>
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCSanitizeAllForm=SVCSanitizeAllForm>

<cffunction name="SVCSanitizeAllAttributes" output="no" hint="Sanitize everything in the Attributes struct.">
    <cfloop collection="#Attributes#" item="i">
		<cfset Attributes[i] = REQUEST.DS.FN.SVCSanitizeInput(Attributes[i],"JS-NQ",true)>
    </cfloop>
</cffunction>
<cfset Attributes.DS.FN.SVCSanitizeAllAttributes=SVCSanitizeAllAttributes>

<cfset Attributes.DS.FN.SVCServerBroadcast={}>
<cffunction name="SVCServerBroadcastOutput" output="yes">
<cfset var LOCID=Application.APPLOCID>
<cfset var msg={}>
<cfset var DO_OUTPUT = false>
<cfif StructKeyExists(Server,"BROADCAST")>
	<cfif Server.BROADCAST.ENABLED>
		<cfif LOCID GT 0 AND StructKeyExists(Server.BROADCAST.LOCALES,LOCID)>
			<cfset msg=Server.BROADCAST.LOCALES[LOCID].MSG>
		<cfelse>
			<cfset msg=Server.BROADCAST.MSG>
		</cfif>
		<CFTRY>
			<cfset msg.CURTITLE=Evaluate(DE(msg.TITLE))>
			<cfset msg.CURCONTENT=Evaluate(DE(msg.CONTENT))>
			<CFOUTPUT><blockquote class=clsSVCColorError>#msg.CURTITLE#<br><br>#msg.CURCONTENT#</blockquote></CFOUTPUT>
		<CFCATCH TYPE="any">
		</CFCATCH>
		</CFTRY>
	</cfif>
	<cfif structKeyExists(Server.BROADCAST,APPLICATION.APPMODE) and structKeyExists(Server.Broadcast[APPLICATION.APPMODE],"loclist") and listfindnocase(Server.Broadcast[APPLICATION.APPMODE].loclist,LOCID) gt 0>
		<cfset DO_OUTPUT = true>
		<cfif LOCID GT 0 AND StructKeyExists(Server.Broadcast[APPLICATION.APPMODE],"LOCALES") and StructKeyExists(Server.Broadcast[APPLICATION.APPMODE].LOCALES,LOCID)>
			<cfset msg=Server.BROADCAST[APPLICATION.APPMODE].LOCALES[LOCID].MSG>
		<CFELSE>
			<cfset msg=Server.BROADCAST[APPLICATION.APPMODE].MSG>
		</CFIF>
		<CFTRY>
			<cfset msg.CURTITLE=Evaluate(DE(msg.TITLE))>
			<cfset msg.CURCONTENT=Evaluate(DE(msg.CONTENT))>
			<CFOUTPUT><blockquote class=clsSVCColorError>#msg.CURTITLE#<br><br>#msg.CURCONTENT#</blockquote></CFOUTPUT>
		<CFCATCH TYPE="any">
		</CFCATCH>
		</CFTRY>
	</cfif>
<cfelse>
	<!--- Load machine registry if not defined (run once) --->
	<cfset Request.DS.FN.SVCServerBroadcast.Load()>
	<cfif Server.BROADCAST.ENABLED or DO_OUTPUT>
		<cfset Request.DS.FN.SVCServerBroadcast.Output()>
	</cfif>
</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCServerBroadcast.Output=SVCServerBroadcastOutput>
<cffunction name="SVCServerBroadcastLoad" output="no" returntype="boolean">
<cflock scope="server" type="exclusive" timeout="10">
	<cfregistry action="get" branch="HKEY_LOCAL_MACHINE\Software\Merimen\ColdFusion" entry="SVRBROADCAST" type="string" variable="Variables.RegValue">
	<cfif StructKeyExists(Variables,"RegValue")>
		<CFTRY>
			<cfset Server.BROADCAST=DeserializeJSON(Variables.RegValue)>
		<CFCATCH type="any">
			<cfset Server.BROADCAST={ENABLED=false}>
		</CFCATCH>
		</CFTRY>
		<cfif NOT(StructKeyExists(Server.BROADCAST,"ENABLED") AND IsBoolean(Server.BROADCAST.ENABLED))>
			<cfset Server.BROADCAST={ENABLED=false}>
		</cfif>
	<cfelse>
		<cfset Server.BROADCAST={ENABLED=false}>
	</cfif>
</cflock>
<cfreturn StructKeyExists(Server.BROADCAST,"MSG")>
</cffunction>
<cfset Attributes.DS.FN.SVCServerBroadcast.Load=SVCServerBroadcastLoad>
<cffunction name="SVCServerBroadcastSave" output="no">
<cfargument name="PARAM" type="struct" required="yes">
<cflock scope="server" type="exclusive" timeout="10">
	<cfset Server.BROADCAST=PARAM>
	<cfregistry action="set" branch="HKEY_LOCAL_MACHINE\Software\Merimen\ColdFusion" entry="SVRBROADCAST" type="string" value="#SerializeJSON(Server.BROADCAST)#">
</cflock>
</cffunction>
<cfset Attributes.DS.FN.SVCServerBroadcast.Save=SVCServerBroadcastSave>
<cffunction name="SVCServerBroadcastDisableLoginDate" output="no" returntype="string">
<cfargument name="getdatetype" type="numeric" required="yes" hint="1:start, 2:end">
	<cfif StructKeyExists(Server,"BROADCAST") and structKeyExists(Server.BROADCAST,APPLICATION.APPMODE)
			and structKeyExists(Server.Broadcast[APPLICATION.APPMODE],"loclist") and listfindnocase(Server.Broadcast[APPLICATION.APPMODE].loclist,application.APPLOCID) gt 0>
		 <cfif arguments.getdatetype eq 1 and structKeyExists(Server.BROADCAST[APPLICATION.APPMODE],"START")>
			<cfreturn Server.BROADCAST[APPLICATION.APPMODE].START>
		<cfelseif arguments.getdatetype eq 2 and structKeyExists(Server.BROADCAST[APPLICATION.APPMODE],"END")>
			<cfreturn Server.BROADCAST[APPLICATION.APPMODE].END>
		</cfif>
	</cfif>
	<cfreturn "">
</cffunction>
<cfset Attributes.DS.FN.SVCServerBroadcast.DisableLoginDate=SVCServerBroadcastDisableLoginDate>

<cffunction
	name="SVCXmlImport"
	access="public"
	returntype="any"
	output="false"
	hint="Imports given XML data (Nodes) into the given XML document so that it can inserted into the node tree. This function does not alter the original tree, it just puts it into the DOM context so that you can then later graft it whereever you want. This XMLImport is needed because if you copy/duplicate between two different XML documents, without first importing it, you will hit 'org.w3c.dom.DOMException:A node is used in a different document than the one that created it' error. So use this function to XMLImport first, then assign the result to the node.">

	<!--- Define arguments. --->
	<cfargument
		name="ParentDocument"
		type="xml"
		required="true"
		hint="The parent XML document into which the given nodes will be imported."
		/>

	<cfargument
		name="Nodes"
		type="any"
		required="true"
		hint="The XML tree or array of XML nodes to be imported. NOTE: If you pass in an array, each array index is treated as it's own separate node tree and any relationship between node indexes is ignored."
		/>

	<!--- Define the local scope. --->
	<cfset var LOCAL = {} />


	<!---
		Check to see how the XML nodes were passed to us. If it
		was an array, import each node index as its own XML tree.
		If it was an XML tree, import recursively.
	--->
	<cfif IsArray( ARGUMENTS.Nodes )>

		<!--- Create a new array to return imported nodes. --->
		<cfset LOCAL.ImportedNodes = [] />

		<!--- Loop over each node and import it. --->
		<cfloop
			index="LOCAL.Node"
			array="#ARGUMENTS.Nodes#">

			<!--- Import and append to return array. --->
			<cfset ArrayAppend(
				LOCAL.ImportedNodes,
				Request.DS.FN.SVCXmlImport(
					ARGUMENTS.ParentDocument,
					LOCAL.Node
					)
				) />

		</cfloop>

		<!--- Return imported nodes array. --->
		<cfreturn LOCAL.ImportedNodes />

	<cfelse>

		<!---
			We were passed an XML document or nodes or XML string.
			Either way, let's copy the top level node and then
			copy and append any children.

			NOTE: Add ( ARGUMENTS.Nodes.XmlNsURI ) as second
			argument if you are dealing with name spaces.
		--->
		<cfset LOCAL.NewNode = XmlElemNew(
			ARGUMENTS.ParentDocument,
			ARGUMENTS.Nodes.XmlName
			) />

		<!--- Append the XML attributes. --->
		<cfset StructAppend(
			LOCAL.NewNode.XmlAttributes,
			ARGUMENTS.Nodes.XmlAttributes
			) />

		<!--- Copy simple values. --->
		<!---
		<cfset LOCAL.NewNode.XmlNsPrefix = ARGUMENTS.Nodes.XmlNsPrefix />
		<cfset LOCAL.NewNode.XmlNsUri = ARGUMENTS.Nodes.XmlNsUri />
		--->
		<cfset LOCAL.NewNode.XmlText = ARGUMENTS.Nodes.XmlText />
		<!---cfset LOCAL.NewNode.XmlComment = ARGUMENTS.Nodes.XmlComment /--->

		<!---
			Loop over the child nodes and import them as well
			and then append them to the new node.
		--->
		<cfloop
			index="LOCAL.ChildNode"
			array="#ARGUMENTS.Nodes.XmlChildren#">

			<!--- Import and append. --->
			<cfset ArrayAppend(
				LOCAL.NewNode.XmlChildren,
				Request.DS.FN.SVCXmlImport(
					ARGUMENTS.ParentDocument,
					LOCAL.ChildNode
					)
				) />

		</cfloop>

		<!--- Return the new, imported node. --->
		<cfreturn LOCAL.NewNode />

	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCXmlImport=SVCXmlImport>
<cffunction
	name="SVCXMLToString"
	access="public"
	returntype="string"
	output="false"
	hint="Converts a CF XML object into the string XML representation.">
	<cfargument
		name="XMLObj"
		type="xml"
		required="true"
		hint="The XML object to convert to string."
		/>
	<cfargument
		name="Mode"
		type="numeric"
		required="false"
		default="1"
		hint="String return option: 1:Strip <?xml > declaration. 0: Leave <?xml > declaration."
		/>
	<CFIF Mode IS 1>
		<CFRETURN REReplace(ToString(XMLObj),"<\?xml[^>]*>","","one")>
	<CFELSE>
		<CFRETURN ToString(XMLObj)>
	</CFIF>
</cffunction>
<cfset Attributes.DS.FN.SVCXMLToString=SVCXMLToString>
<cffunction
	name="SVCNumToHourFormat"
	access="public"
	returntype="string"
	output="false"
	hint="Converts a numeric/float hour to Hour:Minutes format, rounding to nearest minute. Example: 1.1 = 1:06. 65.5 = 65:30">
	<cfargument
		name="Num"
		type="numeric"
		required="true"
		hint="The decimal numeric to convert to Hour:Minutes format."
		/>
	<cfargument
		name="Separator"
		type="string"
		required="false"
		default=":"
		hint="The separator to use. E.g. 1.1 = 1:06 where the separator is :."
		/>
	<CFRETURN "#Round(Arguments.Num*60)\60#:#NumberFormat(Round(Arguments.Num*60)%60,'00')#">
</cffunction>
<cfset Attributes.DS.FN.SVCNumToHourFormat=SVCNumToHourFormat>
<cffunction
	name="SVCHourFormatToNum"
	access="public"
	returntype="string"
	output="false"
	hint="Converts a Hour:Minutes format to numeric 2DP">
	<cfargument
		name="str"
		type="string"
		required="true"
		hint="The number format in Hour:Minutes format."
		/>
	<cfargument
		name="Separator"
		type="string"
		required="false"
		default=":"
		hint="The separator to use. E.g. 1.1 = 1:06 where the separator is :."
		/>
	<CFSET var Arr=ListToArray(str,Separator,true)>
	<CFSET var num=0>
	<CFSET var num2=0>
	<CFSET var i=0>
	<CFIF ArrayLen(arr) IS 0>
		<CFRETURN "">
	<CFELSEIF ArrayLen(arr) IS 1>
		<CFIF IsNumeric(Trim(arr[1])) AND Fix(Trim(arr[1])) IS Val(Trim(arr[1]))>
			<CFRETURN Val(Trim(arr[1]))&".00">
		<CFELSE>
			<CFRETURN "">
		</CFIF>
	<CFELSEIF ArrayLen(arr) GT 1>
		<CFIF IsNumeric(Trim(arr[1])) AND Fix(Trim(arr[1])) IS Val(Trim(arr[1]))>
			<CFSET num=Val(Trim(arr[1]))>
		<CFELSEIF Trim(arr[1]) IS "">
			<CFSET num=0>
		<CFELSE>
			<CFRETURN "">
		</CFIF>
		<CFIF num LT 0>
			<CFRETURN "">
		</CFIF>
		<CFIF IsNumeric(Trim(arr[2])) AND Fix(Trim(arr[2])) IS Val(Trim(arr[2]))>
			<CFSET num2=Val(Trim(arr[2]))>
		<CFELSEIF Trim(arr[1]) IS "">
			<CFSET num2=0>
		<CFELSE>
			<CFRETURN "">
		</CFIF>
		<CFIF num2 LT 0 OR num2 GTE 60>
			<CFRETURN "">
		</CFIF>
		<CFSET num2=Round(num2*100/60)>
		<CFIF num2 LT 10><CFSET num2="0"&num2></CFIF>
		<CFRETURN num&"."&num2>
	</CFIF>
</cffunction>
<cfset Attributes.DS.FN.SVCHourFormatToNum=SVCHourFormatToNum>
<cffunction
	name="SVCBinaryHash"
	access="public"
	returntype="string"
	output="false"
	hint="Generates a standard hash of a binary bytearray. We need this Java-library based function because CF Hash() function only takes in string.">

	<cfargument
		name="byteArray"
		type="Binary"
		required="true"
		hint="The byte Array to get the hash of. This can be read from CFFILE with type Action=READBINARY."
		>
	<cfargument
		name="algorithm"
		type="string"
		required="false"
		default="MD5"
		hint="Any algorithm supported by java MessageDigest - eg: MD5, SHA-1,SHA-256, SHA-384, and SHA-512.  Reference: http://java.sun.com/javase/6/docs/technotes/guides/security/StandardNames.html##MessageDigest">

	<cfset var i = "">
	<cfset var checksumByteArray = "">
	<cfset var checksumHex = "">
	<cfset var hexCouplet = "">
	<cfset var digester = createObject("java","java.security.MessageDigest").getInstance(arguments.algorithm)>

	<cfset digester.update(byteArray,0,len(byteArray))>
	<cfset checksumByteArray = digester.digest()>

	<!--- Convert byte array to hex values --->
	<cfloop from="1" to="#len(checksumByteArray)#" index="i">
		<cfset hexCouplet = formatBaseN(bitAND(checksumByteArray[i],255),16)>
		<!--- Pad with 0's --->
		<cfif len(hexCouplet) EQ 1>
			<cfset hexCouplet = "0#hexCouplet#">
		</cfif>
		<cfset checkSumHex = "#checkSumHex##hexCouplet#">
	</cfloop>
	<cfreturn checkSumHex>
</cffunction>
<cfset Attributes.DS.FN.SVCBinaryHash=SVCBinaryHash>
<cffunction
	name="SVCReserveNextSysID"
	access="public"
	returntype="numeric"
	output="false"
	hint="Reserves the next running ID for a giving variable name and returns it. If variable name not found then throws an error.">
	<cfargument
		name="varName"
		type="string"
		required="true"
		hint="The varName key to retrieve the next running ID in FSYS0006."
		>
	<CFSET var results=0>
	<cfstoredproc datasource=#Request.SVCDSN# procedure="sspFSYSReserveNextID" returncode="Yes">
	<cfprocparam cfsqltype="CF_SQL_CHAR" DBVARNAME="@aa_varname" type="In" value="#arguments.Varname#">
	</cfstoredproc>
	<CFSET results=CFSTOREDPROC.STATUSCODE>
	<CFIF results LT 0>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM" ExtendedInfo="Varname (#arguments.varname#) not found in FSYS0006">
	</CFIF>
	<CFRETURN results>
</cffunction>
<cfset Attributes.DS.FN.SVCReserveNextSysID=SVCReserveNextSysID>
<cffunction
	name="SVCGetTaskStatusByDomObj"
	access="public"
	returntype="struct"
	output="false"
	hint="Returns the task status (in a struct with keys TskStatID,TskStatName) of a task-group by dom-obj. If multiple returns the first found.">
	<cfargument
		name="CoID"
		type="numeric"
		required="true"
		hint="The GCOID that owns the task group."
		>
	<cfargument
		name="TskGrpLogicName"
		type="string"
		required="true"
		hint="The task-group name."
		>
	<cfargument
		name="assocDomain"
		type="numeric"
		required="true"
		hint="The assoc.domainID of the object to retrieve the task status."
		>
	<cfargument
		name="assocObj"
		type="numeric"
		required="true"
		hint="The assoc.objectID of the object to retrieve the task status."
		>
	<cfargument
		name="assocObj2"
		type="numeric"
		required="false"
		hint="The assoc2.objectID of the object to retrieve the task status."
		default=0
		>
	<CFSET var results=0>
	<CFSET var returnStruct=StructNew()>
	<CFSET returnStruct.TskStatID=0>
	<CFSET returnStruct.TskStatName="">
	<CFSET returnStruct.TskStatLogicName="">
	<CFSET returnStruct.TskStatNameiLID="">
	<cfstoredproc datasource=#Request.SVCDSN# procedure="sspFTSKGetTaskStatusByDomObj" returncode="Yes">
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@iTSKGRPID" type="In" value=0 NULL=YES>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@iCOID" type="In" value=#Arguments.COID#>
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" DBVARNAME="@vaTSKGRPNAME" type="In" value="#arguments.TskGrpLogicName#">
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@assocDomain" type="In" value=#Arguments.assocDomain#>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@assocObj" type="In" value=#Arguments.assocObj#>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@iTskStatID" type="Out" value=0 variable=returnStruct.TskStatID>
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" DBVARNAME="@StatDesc" type="Out" value="" variable=returnStruct.TskStatName>
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" DBVARNAME="@StatLogicNm" type="Out" value="" variable=returnStruct.TskStatLogicName>
	<CFIF Arguments.assocObj2 GT 0>
		<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@assocObj2" type="In" value=#Arguments.assocObj2#>
	<CFELSE>
		<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@assocObj2" type="In" NULL=YES value=0>
	</CFIF>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@iTskStatNameiLID" type="Out" value=0 variable=returnStruct.TskStatNameiLID>
	<cfprocparam cfsqltype="CF_SQL_INTEGER" DBVARNAME="@iLASTTSKSTATID" type="Out" value=0 variable=returnStruct.LASTTSKSTATID>
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" DBVARNAME="@LASTTSKSTATLOGICNAME" type="Out" value="" variable=returnStruct.LASTTSKSTATLOGICNAME>
	</cfstoredproc>
	<CFSET results=CFSTOREDPROC.STATUSCODE>
	<CFIF results LT 0>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM" ExtendedInfo="Error in GetTaskStatusByDomObj(#results#)">
	</CFIF>
	<CFRETURN returnStruct>
</cffunction>
<cfset Attributes.DS.FN.SVCGetTaskStatusByDomObj=SVCGetTaskStatusByDomObj>
<cffunction	name="SVCGetTaskGrpID" access="public" returntype="numeric" output="false" hint="Returns the task group ID by task group logic name.">
	<cfargument name="CoID" type="numeric" required="true" hint="The GCOID that owns the task group.">
	<cfargument	name="TskGrpLogicName" type="string" required="true" hint="The task-group name.">
	<cfset var q_trx={}>
	<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	DECLARE @li_tskgrpid int=0

	SELECT @li_tskgrpid=a.ITSKGRPID
	FROM FTSK1001 a WITH (NOLOCK)
	WHERE a.vaTSKGRPNAME=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TskGrpLogicName#"> AND a.siStatus=0
		AND a.iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CoID#">

	SELECT TSKGRPID=@li_tskgrpid
	</cfquery>
	<cfreturn q_trx.TSKGRPID>
</cffunction>
<cfset Attributes.DS.FN.SVCGetTaskGrpID=SVCGetTaskGrpID>

<cffunction name="SVCGetLoginURLCustom" hint="Retrieve the Login Page URL for companies that wish to redirect to their own home page." returntype="string" output="no">
	<CFARGUMENT name="APPMODE" required="false" default="" type="string" hint="Application Mode">
	<CFARGUMENT name="LINKFROM" required="false" default="" type="string" hint="URL Parameter Link From">
	<CFARGUMENT name="DEFAULTURL" required="false" default="" type="string" hint="Default URL to be used">
	<CFARGUMENT name="GCOID" required="false" default=0 type="numeric" hint="URL Parameter GCOID">
	<!--- REMARKS: NO LOGIN CUSTOMER --->
	<cfif (APPMODE eq "EPL" and (LINKFROM eq "EPLRSASG" OR LINKFROM eq "EPLRSAHK" OR (isdefined("session.vars.orgtype") and session.vars.orgtype EQ "C" and isdefined("session.vars.SUBCOTYPEID") and session.vars.SUBCOTYPEID eq 4))) or (APPMODE eq "CLAIMS" and GCOID gt 0) or (isdefined("SESSION.VARS") and isdefined("SESSION.VARS.SSOSETUPID") and SESSION.VARS.SSOSETUPID gt 0)>
		<cfquery name=q_ssosetup DATASOURCE=#Request.SVCDSN#>
			select a.siserverstat,a.vaALTLOGINURL from FSSO_SETUP a with (nolock)
				inner join SEC0005 b with (nolock) on (a.igcoid=b.icoid)
				where a.sistatus=0
				<cfif LINKFROM neq "">
					and b.vacologicname=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LINKFROM#">
				<cfelseif (isdefined("SESSION.VARS") and isdefined("SESSION.VARS.SSOSETUPID") and SESSION.VARS.SSOSETUPID gt 0)>
					and a.issosetupid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.ssosetupid#">
				<cfelseif GCOID gt 0>
					and b.icoid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GCOID#">
				</cfif>
		</cfquery>
		<cfif q_ssosetup.siserverstat eq 0 and q_ssosetup.vaaltloginurl neq "">
			<cfset DEFAULTURL = "#evaluate(de(q_ssosetup.vaaltloginurl))#">
		</cfif>
	</cfif>

	<cfreturn DEFAULTURL>
</cffunction>
<CFSET Attributes.DS.FN.SVCGetLoginURLCustom = SVCGetLoginURLCustom>
<cffunction name="SVCUpdateDS_Docs" hint="Updates DS.DOC* variables (VAAPPEND,DOCCLASS,DOCDEF,DOCDOMAIN)" returntype="any" output="no">
	<cfargument
		name="DS"
		type="Struct"
		required="false"
		default=#Request.DS#
		hint="The DS to update."
		>
	<cfargument
		name="DSNName"
		type="String"
		required="false"
		default=#Request.SVCDSN#
		hint="The DSN name to use."
		>
<!--- Update docs:
		DS.FDOC_CLASSES{iDOCCLASSID:DESC,DEFPRINTPAGES,ALLOWCRTMANAGE}  ...(iDOCCLASSID),
		DS.FDOC_DOCDEFS{iDOCDEFID:DOCCLASSID,DESC,SHORTCAT,STATUS} ...(iDOCDEFID),
		DS_FDOC_DOMDOCS{iDOMAINID:{iDOCDEFID:BCRREAD,BCRCREATE,BCRCONTROL,BCRJOINREVOKE}} ...(iDOMAINID,iDOCDEFID)
	 --->

	<CFSET var TMPSTRUCT=StructNew()>
	<CFSET var q_trx=0>
	<!--- Store DOCCLASS,DOCDEF,DOCDOMAIN --->
	<cfquery NAME=q_trx DATASOURCE=#Arguments.DSNName#>
	SELECT a.iDOCCLASSID,a.vaDOCCLASSDESC,iDEFPRINTPAGES=IsNull(a.iDEFPRINTPAGES,1),iALLOWCRTMANAGE=IsNull(a.iALLOWCRTMANAGE,1),iLID=isNULL(a.iLID,0)
	FROM FDOC3002 a WITH (NOLOCK)
	ORDER BY a.iDOCCLASSID
	</cfquery>
	<CFLOOP query=q_trx>
		<CFSET StructInsert(TMPSTRUCT,"#q_trx.iDOCCLASSID#",{DESC="#Trim(q_trx.vaDOCCLASSDESC)#",DEFPRINTPAGES=#q_trx.iDEFPRINTPAGES#,ALLOWCRTMANAGE=#q_trx.iALLOWCRTMANAGE#,iLID=#q_trx.iLID#})>
	</CFLOOP>
	<CFSET StructInsert(Arguments.DS,"FDOC_CLASSES",TMPSTRUCT,true)>

	<CFSET TMPSTRUCT=StructNew()>
	<cfquery NAME=q_trx DATASOURCE=#Arguments.DSNName#>
	SELECT a.iDOCDEFID,iDOCCLASSID=IsNull(a.iDOCCLASSID,0),a.vaDOCTLONG,a.vaDOCTSHORT,siSTATUS=IsNull(a.siSTATUS,0),iLID=IsNull(a.iLID,0)
	FROM FDOC3001 a WITH (NOLOCK)
	ORDER BY a.iDOCDEFID
	</cfquery>
	<CFLOOP query=q_trx>
		<CFSET StructInsert(TMPSTRUCT,"#q_trx.iDOCDEFID#",{DOCCLASSID=#q_trx.iDOCCLASSID#,DESC="#Trim(q_trx.vaDOCTLONG)#",SHORTCAT="#Trim(q_trx.vaDOCTSHORT)#",STATUS=#q_trx.siSTATUS#,LID=#q_trx.iLID#})>
	</CFLOOP>
	<CFSET StructInsert(Arguments.DS,"FDOC_DOCDEFS",TMPSTRUCT,true)>

	<CFSET TMPSTRUCT=StructNew()>
	<CFSET LASTDOMAINID=-9999>
	<cfquery NAME=q_trx DATASOURCE=#Arguments.DSNName#>
	SELECT a.iDOMAINID,a.iDOCDEFID,b.iDOCCLASSID,bCRCREATE=IsNull(a.bCRCREATE,0),bCRREAD=IsNull(a.bCRREAD,0),bCRCONTROL=IsNull(a.bCRCONTROL,0),bCRJOINREVOKE=IsNull(a.bCRJOINREVOKE,0),bCRLEAVERETAIN=IsNull(a.bCRLEAVERETAIN,0)
	FROM FDOC3010 a with (nolock) INNER JOIN FDOC3001 b with (nolock) ON a.iDOCDEFID=b.iDOCDEFID
	WHERE a.SISTATUS=0
	ORDER BY a.iDOMAINID,b.vaDOCTLONG,a.iDOCDEFID
	</cfquery>
	<CFLOOP query=q_trx>
		<CFIF LASTDOMAINID IS NOT q_trx.iDOMAINID>
			<CFSET LASTDOMAINID=q_trx.iDOMAINID>
			<CFSET CURDOM=StructNew()>
			<CFSET StructInsert(CURDOM,"DocDefArray",ArrayNew(1))>
			<CFSET StructInsert(TMPSTRUCT,"#LASTDOMAINID#",CURDOM)>
		</CFIF>
		<CFSET CURDOM.DocDefArray[ArrayLen(CURDOM.DocDefArray)+1]={DOCDEFID=#q_trx.iDOCDEFID#,DOCCLASSID=#q_trx.iDOCCLASSID#,BCRREAD=#q_trx.BCRREAD#,BCRCREATE=#q_trx.bCRCREATE#,BCRCONTROL=#q_trx.bCRCONTROL#,BCRJOINREVOKE=#q_trx.bCRJOINREVOKE#}>
		<!---CFSET StructInsert(CURDOM,"#q_trx.iDOCDEFID#",{DOCDEFID=#q_trx.iDOCDEFID#,DOCCLASSID=#q_trx.iDOCCLASSID#,BCRREAD=#q_trx.BCRREAD#,BCRCREATE=#q_trx.bCRCREATE#,BCRCONTROL=#q_trx.bCRCONTROL#,BCRJOINREVOKE=#q_trx.bCRJOINREVOKE#})--->
	</CFLOOP>
	<CFSET StructInsert(Arguments.DS,"FDOC_DOMDOCS",TMPSTRUCT,true)>

	<!--- FDOC3005 FILELOCID PATH--->
	<CFSET TMPSTRUCT=StructNew()>
	<cfquery NAME=q_trx DATASOURCE=#Arguments.DSNName#>
	SELECT IFILELOCID, VAAPPEND FROM FDOC3005 WITH (NOLOCK) ORDER BY iFILELOCID
	</cfquery>
	<CFLOOP query=q_trx>
		<CFSET StructInsert(TMPSTRUCT,"#q_trx.IFILELOCID#","#q_trx.VAAPPEND#")>
	</CFLOOP>
	<CFSET StructInsert(Arguments.DS,"FDOC_VAAPPEND",TMPSTRUCT,true)>

	<cfreturn 0>
</cffunction>
<CFSET Attributes.DS.FN.SVCUpdateDS_Docs = SVCUpdateDS_Docs>
<cffunction name="SVCGetCFSQLType" hint="Get the matching CFSQLTYPE given a sql data type." returntype="string" output="no">
	<CFARGUMENT name="sqldatatype" required="true" type="string" hint="SQL data type">
	<!---add in more in future--->
	<cfif sqldatatype eq "int">
		<cfset cfsqltype="CF_SQL_INTEGER">
	<cfelseif sqldatatype eq "bigint">
		<cfset cfsqltype="CF_SQL_BIGINT">
	<cfelseif sqldatatype eq "smallint">
		<cfset cfsqltype="CF_SQL_SMALLINT">
	<cfelseif sqldatatype eq "char">
		<cfset cfsqltype="CF_SQL_CHAR">
	<cfelse>
		<cfset cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	<cfreturn cfsqltype>
</cffunction>
<CFSET Attributes.DS.FN.SVCGetCFSQLType = SVCGetCFSQLType>
<cffunction name="SVCValidateSQLString" hint="Basic checking for sql string to prevent sql injection. However, this will only prevent multiple statements and enforce certain action, union all data is not covered. Syntax error will still hit error." returntype="boolean" output="no">
	<CFARGUMENT name="sqlstring" required="true" default="" type="string" hint="SQL string to be checked">
	<CFARGUMENT name="action" required="false" default="" type="string" hint="Action to be taken in string">
	<cfset sqlstring=rereplacenocase(sqlstring,"'[^']*'","","ALL")>
	<cfif action neq "">
		<cfset valid=refindnocase("^(#action#)[^';]+$",sqlstring)>
	<cfelse>
		<cfset valid=refindnocase("^[^';]+$",sqlstring)>
	</cfif>
	<cfif valid gt 0>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>
<CFSET Attributes.DS.FN.SVCValidateSQLString = SVCValidateSQLString>
<cffunction name="SVCReplaceFormulaCode" hint="Replace formula codes in a string with mapped values. (Used in table management query builder)" returntype="string" output="no">
	<CFARGUMENT name="formulastring" required="true" default="" type="string" hint="String that contains formula codes to be replaced.">
	<cfset condstruct=refindnocase("@[[:alnum:]\s\.:;,\-_='%()]+@",formulastring,0,true)>

	<cfloop condition="condstruct.len[1] gt 0">
		<cfset condstr=Mid(formulastring,condstruct.pos[1]+1,condstruct.len[1]-2)>
		<cfset defarr=listtoarray(condstr,";")>
		<cfif arraylen(defarr) eq 2>
			<cfset defval=defarr[2]>
		<cfelse>
			<cfset defval="''">
		</cfif>
		<cfset condarr=listtoarray(defarr[1],":")>
		<cfif arraylen(condarr) lte 2>
			<cfset condarr[3]="''">
		</cfif>
		<cfif arraylen(condarr) lte 3>
			<cfset condarr[4]="''">
		</cfif>


		<!--- Data: @D:(dataname)[;def-value]@ ... example: @D:mnsuminsured;0@
                attributeData for templates: @P:(dataname)[;def-value]@ ... example: @P:objid;0@" --->
		<cfif condarr[1] eq "A">
			<cfset formulastring = replacenocase(formulastring,"@"&"#condstr#"&"@","##iif(structKeyExists(FORM,'DYNRPT-"&condarr[2]&"') and FORM['DYNRPT-"&condarr[2]&"'] neq '',''"&condarr[3]&"'&'&'FORM[''DYNRPT-"&condarr[2]&"'']'&'&'"&condarr[4]&"'',de("&defval&"))##","ALL")>
		<cfelseif condarr[1] eq "D">
			<cfset formulastring = replacenocase(formulastring,"@"&"#condstr#"&"@","##iif(structKeyExists(FORM,'DYNRPT-"&condarr[2]&"') and FORM['DYNRPT-"&condarr[2]&"'] neq '',''"&condarr[3]&"'&'&'Request.DS.FN.SVCdtLOCtoDB(FORM[''DYNRPT-"&condarr[2]&"''])'&'&'"&condarr[4]&"'',de("&defval&"))##","ALL")>
		<cfelseif condarr[1] eq "CURR">
			<cfset formulastring = replacenocase(formulastring,"@"&"#condstr#"&"@",#Request.DS.Currencies[Request.DS.LOCALES[session.vars.locid].CurrencyID].Currency#,"ALL")>
		<cfelseif condarr[1] eq "TMPL"><!--- attributeData for templates @P:(dataname)[;def-value]@ ... example: @P:objid;0@" --->
            <cfset formulastring = replacenocase(formulastring,"@"&"#condstr#"&"@","##iif(isDefined('attributes."&condarr[2]&"') and attributes."&condarr[2]&" neq '',''"&condarr[3]&"'&'&'attributes."&condarr[2]&"'&'&'"&condarr[4]&"'',de("&defval&"))##","ALL")>
			<!--- <cfset formulastring = replacenocase(formulastring,"@"&"#condstr#"&"@","##iif(structKeyExists(FORM,'DYNRPT-"&condarr[2]&"') and FORM['DYNRPT-"&condarr[2]&"'] neq '',''"&condarr[3]&"'&'&'FORM[''DYNRPT-"&condarr[2]&"'']'&'&'"&condarr[4]&"'',de("&defval&"))##","ALL")> --->
        <cfelse>
			<cfset formulastring = replacenocase(formulastring,"@"&"#condstr#"&"@","","ALL")>
		</cfif>
		<cfset condstruct=refindnocase("@[[:alnum:]\s\.:;,\-_='%()]+@",formulastring,0,true)>
	</cfloop>
	<cfreturn formulastring>
</cffunction>
<CFSET Attributes.DS.FN.SVCReplaceFormulaCode = SVCReplaceFormulaCode>
<cffunction name="SVCAuthLogin" returntype="struct" output="no">
	<CFARGUMENT name="username" required="true" type="string" hint="User Name">
	<CFARGUMENT name="password" required="true" type="string" hint="Password">
	<CFARGUMENT name="pwdtype" required="false" default="0" type="numeric" hint="0: Password in cleartext; 1: Password hashed with SHA+nonce using Merimen's protocol">
	<CFARGUMENT name="logintype" required="false" default="0" type="numeric" hint="0: Normal web login, 1: Integration login, 2: Websvc Login">
	<CFARGUMENT name="lite_mode" required="false" default="0" type="numeric" hint="0: Normal Mode, 1: Light mode (minimal session variables)">
	<CFARGUMENT name="nonce" required="false" default="" type="string" hint="The nonce for SHA login (required if pwdtype=1)">
	<CFARGUMENT name="locid" required="false" default="0" type="numeric" hint="To indicate wether to localize nonce time or not.">
	<CFARGUMENT name="hpassword" required="false" default="" type="string" hint="Case sensitive password.">

	<cfif IsDefined("SESSION.VARS") AND Not StructIsEmpty(Session.vars)>
		<cfif IsDefined("COOKIE.MACID") AND IsDefined("SESSION.VARS.MACID") AND	(COOKIE.MACID IS NOT SESSION.VARS.MACID)>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCLI">
		</cfif>
		<cflock SCOPE="Session" Type="Exclusive" TimeOut="60">
		<cfscript>StructClear(session.vars);</cfscript>
		</cflock>
		<CFSET request.inSession=0>
	</cfif>

	<cfset usname=trim(arguments.username)>
	<cfset hpwd="">
	<cfif arguments.pwdtype eq 0>
		<cfset cslt=hash(ucase(usname)&"bing$748wOLly","SHA-512")>
		<cfset pwd=hash(hash(ucase(arguments.password))&cslt,"SHA-512")>
		<!--- generate nonce --->
		<cfif arguments.locid GT 0>
			<cfset currenttime="#Request.DS.FN.SVCdt(now(),arguments.locid,"mm/dd/yyyy","HH:mm:ss")#">
		<cfelse>
			<cfset currenttime="#DateFormat(now(),'mm/dd/yyyy')# #TimeFormat(now(),'HH:mm:ss')#">
		</cfif>
		<cfset globalnonce=ToBase64(currenttime&Hash(currenttime&"boo$ga56"))><!--- that is our private key --->
		<CFSET Arguments.nonce=Left(globalnonce,27)&UCase(Hash(pwd&Right(globalnonce,Len(globalnonce)-28),"SHA-512"))>
	<cfelse>
		<cfset pwd=arguments.password>
		<cfif IsDefined("arguments.hpassword")>
			<cfset hpwd=arguments.hpassword>
		</cfif>
	</cfif>
	<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_authSHA USERID="#usname#" SHA="#pwd#" VARRESULT=HASHPWDRESULT NONCE=#Arguments.nonce# SHASEN="#hpwd#">
	<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_setloginsession USERID="#usname#" HASHPWDRESULT="#HASHPWDRESULT#" LOGINTYPE=#Arguments.LOGINTYPE# LITE_MODE=#Arguments.LITE_MODE#>
	<cfreturn MODRESULT>
</cffunction>
<CFSET Attributes.DS.FN.SVCAuthLogin = SVCAuthLogin>
<cffunction name="SVCPageAudit" hint="" returntype="any" output="no">
	<cfargument name="TblMode" required="false" default="" type="string"
		displayname="Which auditing table to write to."
		hint="'': Default main table, 'INT' integration table, 'SYNCSERVER' Syncserver table">
	<cfargument name="DSNName" required="true" type="string"
		displayname="The Auditing DSN Name to use."
		hint="This should be configured in SYS0001 for pickup at SETENV">
	<cfargument name="SkipHTTPPost" required="false" default="false" type="boolean"
		displayname="Skip the auditing of the HTTP POST parameters (to conserve space)."
		hint="">

	<CFSET var GCOID=0><CFSET var USERID=""><CFSET var IAID=0><CFSET var IMPER=0>
	<CFIF StructKeyExists(Request,"inSESSION") AND Request.inSESSION IS 1 and IsDefined("SESSION.VARS.GCOID")>
		<CFSET GCOID=SESSION.VARS.GCOID><CFSET USERID=SESSION.VARS.USERID>
		<CFIF StructKeyExists(Session,"vars") and StructKeyExists(Session.vars,"MMUSERID") and Session.vars.MMUSERID neq "">
			<CFSET IMPER=1>
		</CFIF>
	</CFIF>
	<CFIF IMPER eq 0 and StructKeyExists(URL, "fuseaction") and
			((URL.fuseaction eq "act_logintrusted" and StructKeyExists(URL, "impusid") and URL.impusid neq "") or
 		     (URL.fuseaction eq "act_devloginimp" and StructKeyExists(URL,"impersonateid") and URL.impersonateid neq "") or
		     (URL.fuseaction eq "act_login" and StructKeyExists(FORM, "SLEUSERNAME") and TRIM(FORM.SLEUSERNAME) neq "" and Find("$",FORM.SLEUSERNAME) gt 1))>
		<CFSET IMPER=1>
	</CFIF>
	<CFIF IMPER eq 0>
		<CFIF StructKeyExists(URL,"CASEID") AND IsNumeric(URL.CASEID)>
			<CFSET CASEID=URL.CASEID>
		<CFELSE>
			<CFSET CASEID=0>
		</CFIF>
		<CFIF Not(Arguments.SkipHTTPPost) AND USERID IS NOT "">
			<CFSET obj=GetHTTPRequestData()>
			<CFIF IsSimpleValue(obj.content)>
				<CFSET objcontent=Trim(obj.content)>
			<CFELSE>
				<CFSET objcontent="">
			</CFIF>
		<CFELSE>
			<CFSET objcontent="">
		</CFIF>

		<CFSTOREDPROC PROCEDURE="sspFAUDAccessAudit" DATASOURCE=#Arguments.DSNName# RETURNCODE="YES">
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#Arguments.TblMode# DBVARNAME=@as_tblmode>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#GCOID# DBVARNAME=@ai_gcoid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#CASEID# DBVARNAME=@ai_caseid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#USERID# DBVARNAME=@as_userid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#CGI.QUERY_STRING# DBVARNAME=@as_qstr>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#Left(CGI.HTTP_USER_AGENT,255)# DBVARNAME=@as_brwt>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#Request.DS.FN.SVCRemoteIpAddr()# DBVARNAME=@as_rip>
		<CFIF objcontent IS NOT "">
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#objcontent# DBVARNAME=@as_tpost>
		<CFELSE>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR NULL=YES DBVARNAME=@as_tpost>
		</CFIF>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_BIGINT VARIABLE=IAID VALUE=0 DBVARNAME=@ai_aid>
		</CFSTOREDPROC>
		<CFIF CFSTOREDPROC.STATUSCODE LT 0>
			<CFTHROW TYPE="EX_DBERROR" ErrorCode="CANNOTAUDIT">
		<CFELSE>
			<CFSET Request.AccessAuditLogID=IAID>
		</CFIF>
	<CFELSE><!--- Impersonation --->
		<CFSET Request.AccessAuditLogID=0>
	</CFIF>
	<CFRETURN Request.AccessAuditLogID>
</cffunction>
<CFSET Attributes.DS.FN.SVCPageAudit = SVCPageAudit>

<cffunction name="SVCdoZip" access="public" returnType="struct" hint="Function to zip a file/set of files from a subdir, including setting a password. Use the zip application.">
<cfargument name="LocalDir" required="true" type="string"
	displayname="The local directory to do zipping at. Note: Not recursive."
	hint="Output file will also be dumped here.">
<cfargument name="type" required="false" default="zip" type="string"
	displayname="Type of zip. [-t Switch]. Check hint for valid list of types."
	hint="7z|gzip|zip|bzip2|tar|tiso|udf">
<cfargument name="filesArray" required="false" default="" type="any"
	displayname="Array of list of files to include in the zip (files should be relative to localDir)"
	hint="If not an array passed in (i.e. blank string), the matchPattern is used.">
<cfargument name="matchPattern" required="false" default="" type="string"
	displayname="Regular expression pattern to match for zipping within subdirectory. If fileList used, this is ignored."
	hint="Use either maskStr or MatchPattern">
<cfargument name="outputDir" required="false" default="" type="string"
	displayname="The local directory to put the completed zip file at."
	hint="If empty or blank, will put in LocalDir.">
<cfargument name="outputName" required="false" default="" type="string"
	displayname="output zipped file name, without the extension"
	hint="If empty specified, defaults to first file in the list of files">
<cfargument name="removeAfterZip" required="false" default="false" type="boolean"
	displayname="Remove Files after zip"
	hint="Remove files after they have been zipped.">
<cfargument name="timeout" required="false" default="15" type="numeric"
	displayname="Timeout value for cfexecute"
	hint="">
<cfargument name="zipPassword" required="false" default="" type="string"
	displayname="Zip password"
	hint="If non-blank, set this as the ZIP password">
<cfargument name="argString" required="false" default="" type="string"
	displayname="7z Argument String"
	hint="Argument String passed to 7z if you want to construct your own 7z command. Overwrites all other parameters above">

	<cfset var cmdStr = "">
	<cfset var fileExt = "">
	<cfset var filesArr = arrayNew(1)>
	<cfset var j = "">
	<cfset var FileCount = 0>
	<cfset var outputStruct = StructNew()>
	<cfset var errorv = "">
	<cfif trim(arguments.argString) neq "">
		<cfset cmdStr = arguments.argString>
	<cfelse>
		<CFIF Trim(Arguments.OutputDir) IS "">
			<CFSET Arguments.OutputDir=Arguments.LocalDir>
		</CFIF>
		<!---CFIF (StructKeyExists(this.IntSettings,"ZIPPASSWORD") AND Trim(this.IntSettings.ZIPPASSWORD) NEQ "")>
			<cfset password = trim(this.IntSettings.ZIPPASSWORD)>
		</CFIF--->


		<CFIF StructKeyExists(Arguments,"filesArray") AND IsArray(Arguments.filesArray)>

			<cfloop array=#Arguments.filesArray# index="j">
				<CFIF FileExists("#Arguments.LocalDir##j#")>

					<cfset arrayAppend(filesArr,'#Arguments.LocalDir##j#')>
					<cfset FileCount += 1>
					<cfif arguments.outputName eq "" and arrayLen(filesArr) gte 1>
						<cfset arguments.outputName = listFirst(listlast(j,"/\"),".")>
					</cfif>
				<CFELSE>
					<CFTHROW TYPE="EX_FTPFAILED" ErrorCode="BADZIP" ExtendedInfo="File in FileList not found (#j#)">
				</CFIF>
			</cfloop>
		<CFELSE>
			<CFDIRECTORY ACTION="LIST" DIRECTORY="#Arguments.LocalDir#" NAME="FilesToZip" SORT="dateLastModified asc">
			<CFLOOP query="FilesToZip">
				<CFIF 	(FilesToZip.type IS "dir")
					OR	(Arguments.MatchPattern IS NOT "" AND NOT(REFINDNOCASE(Arguments.MatchPattern,FilesToZip.name)))
					>
					<!--- Not file we looking for --->
					<CFCONTINUE>
				</CFIF>
				<cfset arrayAppend(filesArr,'#Arguments.LocalDir##FilesToZip.name#')>
				<cfset FileCount += 1>
				<cfif arguments.outputName eq "" and arrayLen(filesArr) gte 1>
					<cfset arguments.outputName = listFirst(FilesToZip.name,".")>
				</cfif>
			</CFLOOP>
		</CFIF>

		<cfif arguments.outputName eq "">
			<cfset arguments.outputName = "OUTPUT">
		</cfif>
		<CFSET outputStruct.OutputPath="#arguments.Outputdir##arguments.outputName#.#UCASE(arguments.type)#">

		<cfsavecontent variable="cmdStr">
		<cfoutput>a -t#arguments.type# <cfif Arguments.zipPassword neq "">-p#Arguments.zipPassword#</cfif> -y "#outputStruct.OutputPath#" <cfif arrayLen(filesArr) gt 0>"#ArrayToList(filesArr,'" "')#"<cfelse>"#arguments.localdir#*.*"</cfif></cfoutput>
		</cfsavecontent>
	</cfif>
	<CFIF FileCount GT 0>
		<CFTRY>
		 	<CFEXECUTE NAME="#Application.ZIPAPPPATH#" ARGUMENTS="#cmdStr#" VARIABLE="verbose" errorVariable="errorv" timeout="#timeout#"/ >
			<CFCATCH>
				<CFTHROW TYPE="EX_FTPFAILED" ErrorCode="BADZIP" ExtendedInfo="Unable to zip the file with doZip (#cmdStr#) Error:#errorv#">
			</CFCATCH>
		</CFTRY>

		<cfif trim(arguments.argString) eq "" and arguments.removeAfterZip>
			<cfloop array="#filesArr#" index="j">
				<cffile action="delete" file="#j#">
			</cfloop>
		</cfif>
	</CFIF>
	<CFSET outputStruct.FileCount=FileCount>
	<CFRETURN outputStruct>
</cffunction>
<CFSET Attributes.DS.FN.SVCdoZip = SVCdoZip>

<cffunction name="SVCGetOccList" returntype="string" output=no><!--- get occupation list --->
	<cfargument name="igcoid" type="numeric" required="false" default=0>
	<cfargument name="iselector" type="numeric" required="false" default=0>
	<cfif Isdefined("Request.DS.OCCUPATIONLIST")>
		<cfif igcoid GT 0 AND StructKeyExists(Request.DS.OCCUPATIONLIST,igcoid)>
			<cfif iselector GT 0 AND StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid],"iselector")>
				<cfif iselector GT 0 AND StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid].iselector,iselector)>
					<cfset returncode=#Request.DS.OCCUPATIONLIST[igcoid].iselector[iselector].list#>
				<cfelseif StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid],"list")>
					<cfset returncode=#Request.DS.OCCUPATIONLIST[igcoid].list#>
				<cfelse>
					<cfset returncode="">
				</cfif>
			<cfelseif StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid],"list")><!--- no iselector provided --->
				<cfset returncode=#Request.DS.OCCUPATIONLIST[igcoid].list#>
			<cfelse>
				<cfset returncode="">
			</cfif>
		<cfelseif StructKeyExists(Request.DS.OCCUPATIONLIST,0) AND StructKeyExists(Request.DS.OCCUPATIONLIST[0],"list")><!--- no iselector provided --->
			<cfset returncode=#Request.DS.OCCUPATIONLIST[0].list#>
		<cfelse>
			<cfset returncode="">
		</cfif>

		<cfif returncode IS "" AND StructKeyExists(Request.DS.OCCUPATIONLIST,0) AND StructKeyExists(Request.DS.OCCUPATIONLIST[0],"list")>
			<cfset returncode=#Request.DS.OCCUPATIONLIST[0].list#>
		</cfif>
	<cfelse>
		<cfset returncode="">
	</cfif>
	<cfreturn returncode>
</cffunction>
<CFSET Attributes.DS.FN.SVCGetOccList = SVCGetOccList>

<cfscript>
function SVCParagraphFormat(str) {
    str = replace(str,chr(13)&chr(10),chr(10),"ALL");     // first make Windows style into Unix style
    str = replace(str,chr(13),chr(10),"ALL");             // now make Macintosh style into Unix style
    str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL"); // now fix tabs
    return replace(str,chr(10),"<br />","ALL");           // now return the text formatted in HTML
}
</cfscript>
<CFSET Attributes.DS.FN.SVCParagraphFormat = SVCParagraphFormat>

<cffunction
    name="SVCGetRequestTimeout"
    access="public"
    returntype="numeric"
    output="false"
    hint="Returns the current request timeout for the current page page request.">

    <!--- Define the local scope. --->
    <cfset var LOCAL = StructNew() />

    <!--- Get the request monitor. --->
    <cfset LOCAL.RequestMonitor = CreateObject(
        "java",
        "coldfusion.runtime.RequestMonitor"
        ) />

    <!--- Return the current request timeout. --->
    <cfreturn LOCAL.RequestMonitor.GetRequestTimeout() />
</cffunction>
<CFSET Attributes.DS.FN.SVCGetRequestTimeout = SVCGetRequestTimeout>

<cffunction
    name="SVCoptionListToStruct"
    access="public"
    returntype="struct"
    output="false"
    hint="Convert option list (with dictionary key) into struct.">

	<cfargument name="OptionList" required="true" default="" type="string"
		displayname="Option list (with dictionary key)"
		hint="">
	<cfargument name="Delimiter" required="true" default="|" type="string"
		displayname="Option list delimiter"
		hint="">

	<cfset var STR={}>
	<cfset var IDX={}>
	<cfset var I="">

	<CFLOOP from=1 to=#ListLen(OptionList,Delimiter)# index="I" step=2>
		<cfset IDX=ListGetAt(OptionList,I,Delimiter)>
		<cfif NOT StructKeyExists(STR,"#IDX#")>
			<cfset STR["#IDX#"]=ListGetAt(OptionList,I+1,Delimiter)>
		</cfif>
	</CFLOOP>

	<cfreturn STR>
</cffunction>
<CFSET Attributes.DS.FN.SVCOptionListToStruct=SVCOptionListToStruct>
<cffunction
    name="SVCstructToOptionList"
    access="public"
    returntype="string"
    output="false"
    hint="Convert struct (with dictionary key) into option list.">

	<cfargument name="Str" required="true" default="" type="struct"
		displayname="Struct (with dictionary key)"
		hint="">
	<cfargument name="Delimiter" required="true" default="|" type="string"
		displayname="Option list delimiter"
		hint="">

	<cfset var x={}>
	<cfset var result="">

	<CFLOOP collection=#Arguments.Str# item="x">
		<cfset result=ListAppend(result,"#x##Arguments.Delimiter##Arguments.Str[x]#",Arguments.Delimiter)>
	</CFLOOP>

	<cfreturn result>
</cffunction>
<CFSET Attributes.DS.FN.SVCstructToOptionList=SVCstructToOptionList>

<cffunction access="public" name="SVCMYGSTEff" output=false>
    <cfargument name="locale" required="true">
    <cfreturn
            (arguments.locale eq 1 OR arguments.locale eq 5) and datediff('d',dateformat('2015-4-1','yyyy-mm-dd'),now()) gte 0>
</cffunction>
<cfset attributes.ds.fn.SVCMYGSTEff = SVCMYGSTEff >


<cffunction
    name="SVCgetTimeline">
    <cfargument name="key" type="string" required="true">

    <cfset ordering = ["gst6","gst0","sst6"]>
    <cfset var keyval = {
        "gst6"="2015-04-01"
        ,"gst0"="2018-06-01"
        ,"sst6"="2018-09-01"
    }>
    <cfset var result = "1900-01-01">

    <cfif arguments.key eq "latest">
        <cfset index = arraylen(ordering)>
        <cfset arguments.key = ordering[index]>

    </cfif>
    <cfif structKeyExists(keyval,arguments.key)>
        <cfset result = keyval[arguments.key]>
    </cfif>

    <cfreturn result>
</cffunction>
<CFSET Attributes.DS.FN.SVCgetTimeline=SVCgetTimeline>

<cffunction
    name="SVCgetCoVATEffTimeline"
    access="public"
    returntype="struct"
    output="false"
    hint="Check GST timeline">
    <cfargument name="dt" type="date" required="true">

	<CFSTOREDPROC PROCEDURE="sspFSECCoVATEffTimeline" DATASOURCE=#Request.SVCDSN# RETURNCODE="YES">
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_timestamp VALUE=#Arguments.dt# DBVARNAME=@adt_date>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_timestamp VARIABLE="LOCAL.cutoff" DBVARNAME=@adt_gstcutoff>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_timestamp VARIABLE="LOCAL.cutoff2" DBVARNAME=@adt_gstcutoff2>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_bit       VARIABLE="LOCAL.isGSTEra" DBVARNAME=@ab_isGSTEra>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_varchar   VARIABLE="LOCAL.timeline" DBVARNAME=@as_timeline>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_numeric   scale="9" VARIABLE="LOCAL.timelinegst" DBVARNAME=@an_timelineGST>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_smallint  VARIABLE="LOCAL.timelinesvctaxpc" DBVARNAME=@asi_timelineSVCTAXPC>
	</CFSTOREDPROC>

	<CFIF CFSTOREDPROC.STATUSCODE IS -1>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="BADPARAM" ExtendedInfo="Invalid COID">
	<CFELSEIF CFSTOREDPROC.STATUSCODE LT 0>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="FSECCOVATEFFTimeline(#CFSTOREDPROC.STATUSCODE#)">
	</CFIF>

	<cfreturn LOCAL>

</cffunction>
<CFSET Attributes.DS.FN.SVCgetCoVATEfftimeline=SVCgetCoVATEffTimeline>

<cffunction
    name="SVCgetCoVATEff"
    access="public"
    returntype="struct"
    output="false"
    hint="Check whether VAT is effective for a specific company.">

	<cfargument name="COID" required="true" type="numeric"
		displayname="Company ID (primary key iCOID in SEC0005)"
		hint="">

	<cfset var LOCAL={}>

	<CFSTOREDPROC PROCEDURE="sspFSECCoVATEff" DATASOURCE=#Request.SVCDSN# RETURNCODE="YES">
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE=#Arguments.COID# DBVARNAME=@ai_coid>

	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE="LOCAL.CoTaxRegNo" DBVARNAME=@as_taxregno>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_TIMESTAMP VARIABLE="LOCAL.CoTaxRegDate" DBVARNAME=@adt_taxreg>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_TIMESTAMP VARIABLE="LOCAL.CoTaxEffDate" DBVARNAME=@adt_vateffective>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_TIMESTAMP VARIABLE="LOCAL.CoTaxKillDate" DBVARNAME=@adt_taxkill>

	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_bit VARIABLE="LOCAL.myeff" DBVARNAME=@ab_mygsteff>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_bit VARIABLE="LOCAL.coeff" DBVARNAME=@ab_cogsteff>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_bit VARIABLE="LOCAL.infreetradezone" DBVARNAME=@ab_inFreeTradeZone>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_bit VARIABLE="LOCAL.IsVATEff" DBVARNAME=@ab_isvateff>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_timestamp VARIABLE="LOCAL.cutoff" DBVARNAME=@adt_gstcutoff>

	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_timestamp VARIABLE="LOCAL.cutoff2" DBVARNAME=@adt_gstcutoff2>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_bit VARIABLE="LOCAL.isGSTEra" DBVARNAME=@ab_isGSTEra>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_varchar VARIABLE="LOCAL.timeline" DBVARNAME=@as_timeline>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_numeric scale="9" VARIABLE="LOCAL.timelinegst" DBVARNAME=@an_timelineGST>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_smallint VARIABLE="LOCAL.timelinesvctaxpc" DBVARNAME=@asi_timelineSVCTAXPC>
	</CFSTOREDPROC>

	<CFIF CFSTOREDPROC.STATUSCODE IS -1>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="BADPARAM" ExtendedInfo="Invalid COID : #Arguments.COID#">
	<CFELSEIF CFSTOREDPROC.STATUSCODE LT 0>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="FSECCOVATEFF(#CFSTOREDPROC.STATUSCODE#)">
	</CFIF>

	<cfreturn LOCAL>
</cffunction>
<CFSET Attributes.DS.FN.SVCgetCoVATEff=SVCgetCoVATEff>

<cffunction access="public" name="SVCgetCoSVCEff" returntype="string" output=false description="">
    <cfargument name="coid" type="numeric" required="true">
    <cfargument name="dt" type="date" required="false" default=#now()#>
    <cfquery name="qry_sst" datasource="#request.mtrdsn#">
        select b.vasvcregno,b.dtsvcreg,b.dtsvceff
        from sec0005 b with (nolock) where icoid = <cfqueryparam value=#arguments.coid# CFSQLType="cf_sql_integer" null="no">
    </cfquery>
    <cfreturn len(qry_sst.vasvcregno) gt 0 and qry_sst.dtsvceff neq "" and arguments.dt gte qry_sst.dtsvceff>
</cffunction>
<CFSET Attributes.DS.FN.SVCgetCoSVCEff=SVCgetCoSVCEff>

<cffunction
    name="SVCDumpQuery"
    access="public"
    returntype="any"
    output="true"
    hint="Display Query object into a tabular format.">

	<cfargument name="Query" required="true" type="query"
		displayname="Query object"
		hint="">

	<CFSET var i=0>
	<CFSET var cols=[]>
	<CFSET var datatype="">
	<CFSET var value="">
	<CFSET var q=Arguments.Query>

	<CFOUTPUT>
	<CFIF q.RecordCount GT 0>
		<table cellpadding=2 cellspacing=1 width=90% align=center style=text-align:center>
		<tr class=header>
			<cfset cols=q.GetColumnList()>
			<cfloop from=1 to=#ArrayLen(cols)# index=i><td>#cols[i]#</td></cfloop>
		</tr>
		<cfloop query=q>
		<tr class=clsDetail<cfif CurrentRow MOD 2 EQ 1>2<cfelse>1</cfif>>
			<cfloop from=1 to=#ArrayLen(cols)# index=i>
				<cfset value=q[cols[i]][CurrentRow]>
				<cfset datatype=q.GetMetaData().GetColumnTypeName(i).ToLowerCase()>
				<cfif datatype IS "datetime">
					<cfset value=Request.DS.FN.SVCdt(value)>
				<cfelseif datatype IS "money" OR datatype IS "numeric" OR datatype IS "float">
					<cfset value=Request.DS.FN.SVCnum(value)>
				</cfif>
				<td>#HTMLEditFormat(value)#</td>
			</cfloop>
		</tr>
		</cfloop>
		</table>
	<CFELSE>
		<table cellpadding=1 cellspacing=1 width=90% align=center style=text-align:center>
		<tr><td>- No record -</td></tr>
		</table>
	</CFIF>
	</CFOUTPUT>
	<cfreturn>
</cffunction>
<CFSET Attributes.DS.FN.SVCDumpQuery=SVCDumpQuery>

<cffunction
    name="SVCRptGenFilter"
    access="public"
    returntype="any"
    output="true"
    hint="Generate report filter">
<cfargument name="TITLE">
<cfargument name="UI" default="SELECT">
<cfargument name="VARNAME">
<cfargument name="DEFVALUE" default=0>
<cfargument name="OPTLIST" default="">
<cfargument name="COMPULSORY" default=0>
<cfargument name="SIZE" default=20>
<cfargument name="onblur" default="">
<cfargument name="DEFUNIT" default="">
<cfargument name="OPTLISTSEP" default=",">
<cfargument name="LOOKUPURL" default="">
<cfargument name="LOOKUPARGS" default="">
<cfargument name="RADIOWIDTH" default=140>
<cfargument name="RADIOCOLS" default=4>
<cfargument name="APPEND_TITLE" default=1><!--- Report Title - Bit 1:default,Bit 2:don't show subheader --->
<cfargument name="onclick" default=""><!--- Param 16 --->
<cfargument name="MULTIPLE" default=""><!--- Multiple row for SELECT, integer value to indicate how many rows to display --->
<cfargument name="BUTTON_LABEL" default="">
<cfargument name="DOMAINID" default="">

<cfif NOT StructKeyExists(Request,"RPT_RADIOWIDTH")>
	<cfset Request.RPT_RADIOWIDTH=RADIOWIDTH>
</cfif>
<cfif NOT StructKeyExists(Request,"RPT_RADIOCOLS")>
	<cfset Request.RPT_RADIOCOLS=RADIOCOLS>
</cfif>
<cfif APPEND_TITLE IS ""><cfset APPEND_TITLE=1></cfif>
<cfif UI IS "TEXTBOX" AND NOT ListLen("#VARNAME#") LTE 2>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM" ExtendedInfo="#VARNAME#">
</cfif>
<cfloop list="#VARNAME#" index=a>
	<cfparam name="#a#" default=#DEFVALUE#>
</cfloop>
<cfparam name=DRTEXT default="">
<cfloop list="#VARNAME#" index=a>
	<CFIF NOT IsDefined(a)><CFSET "#a#"=VARDEF></CFIF>
	<CFSET "#a#"=Trim(Evaluate("#a#"))>
</cfloop>
<cfif Find("|",OPTLIST) GT 0>
	<cfset OPTLISTSEP="|">
</cfif>
<cfif Len(OPTLIST) GT 0 AND Right(OPTLIST,1) IS OPTLISTSEP>
	<cfset OPTLIST=Left(OPTLIST,Len(OPTLIST)-1)>
</cfif>
<cfset process=0>
<cfif UI IS "STATE">
	<CFQUERY NAME=q_trx DATASOURCE=#Request.SVCDSN#>
	SELECT iCOUNTRYID FROM SEC0005 WHERE iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.ORGID#">
	</CFQUERY>
	<CFSET COUNTRYID=q_trx.iCOUNTRYID>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.SVCDSN#>
	select id=iSTATEID,name=vaDESC
	from SYS0002 WITH (NOLOCK)
	where siSTATUS != 1 AND iCOUNTRYID=<cfqueryparam value="#COUNTRYID#" cfsqltype="CF_SQL_INTEGER">
	order by vaDESC
	</CFQUERY>
	<cfset process=1>
<cfelseif UI IS "REGION">
	<CFQUERY NAME="q_trx" DATASOURCE="#Request.SVCDSN#">
	SELECT iCOUNTRYID FROM SEC0005 WHERE iCOID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.ORGID#">
	</CFQUERY>
	<CFSET COUNTRYID = q_trx.iCOUNTRYID>
	<CFQUERY name="q_trx" datasource="#Request.SVCDSN#">
		IF EXISTS(SELECT 0 FROM FSYS_REGIONLINK WHERE iGCOID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.ORGID#"> AND siSTATUS = 0)
		BEGIN
			SELECT DISTINCT [ID] = R.iREGIONID, [NAME] = <cfif NOT(StructKeyExists(SESSION.VARS,"LGID") AND SESSION.VARS.LGID GTE 0)>R.vaREGIONDESC<CFELSE>R.vaREGIONDESCLOCAL</CFIF>
			FROM FSYS_REGION R WITH (NOLOCK)
			INNER JOIN FSYS_REGIONLINK RL WITH (NOLOCK) ON R.iREGIONID = RL.iREGIONID
			WHERE R.siSTATUS = 0
			AND RL.siSTATUS = 0
			AND iGCOID = <cfqueryparam value="#SESSION.VARS.ORGID#" cfsqltype="CF_SQL_INTEGER">
			AND iCOUNTRYID = <cfqueryparam value="#COUNTRYID#" cfsqltype="CF_SQL_INTEGER">
		END
		ELSE
		BEGIN
			SELECT DISTINCT [ID] = R.iREGIONID, [NAME] = <cfif NOT(StructKeyExists(SESSION.VARS,"LGID") AND SESSION.VARS.LGID GTE 0)>R.vaREGIONDESC<CFELSE>R.vaREGIONDESCLOCAL</CFIF>
			FROM FSYS_REGION R WITH (NOLOCK)
			INNER JOIN FSYS_REGIONLINK RL WITH (NOLOCK) ON R.iREGIONID = RL.iREGIONID
			WHERE R.siSTATUS = 0
			AND RL.siSTATUS = 0
			AND iGCOID = 0
			AND iCOUNTRYID = <cfqueryparam value="#COUNTRYID#" cfsqltype="CF_SQL_INTEGER">
		END
	</CFQUERY>
	<cfset process=1>
</cfif>
<cfif process IS 1>
	<cfset _list=" | |">
	<cfloop query=q_trx><cfset _list=_list & "#id#|#name#|"></cfloop>
	<cfset Request.DS.FN.SVCRptGenFilter(TITLE,"SELECT",VARNAME,"",_list,COMPULSORY,SIZE,onblur,DEFUNIT,OPTLISTSEP,LOOKUPURL,LOOKUPARGS,RADIOWIDTH,RADIOCOLS,APPEND_TITLE,onclick,MULTIPLE,BUTTON_LABEL)>
	<cfexit METHOD=EXITTEMPLATE>
</cfif>
<CFOUTPUT>
<table class=clsNoPrint border=0 align=center cellpadding=1 cellspacing=1 style="width:90%<cfif IsDefined("Attributes.NOLAYOUT")>;display:none</cfif>">
<tr>
	<cfif title neq ""><td style="font-weight:bold;width:25%">#TITLE#:<CFIF UI IS "SELECT" AND MULTIPLE NEQ "" AND MULTIPLE GT 1><br /><em><font style="font-weight: normal; color: green;">#Server.SVCLang("Note: Hold ""Ctrl"" key to select/deselect multiple.",18335)#</font></em></CFIF></td></cfif>
	<cfif BitAnd(APPEND_TITLE,2) IS 0>
		<cfif ListLen("#VARNAME#") IS 2 AND (UI IS "TEXTBOX" OR UI IS "CALDATE")>
			<cfset SUBHEADER="#TITLE# ">
		<cfelse>
			<cfset SUBHEADER="#TITLE#: ">
		</cfif>
	<cfelse>
		<cfset SUBHEADER="">
	</cfif>
	<cfif UI IS "SELECT">
		<td valign=top>
		<select URLVAR <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> name=#VARNAME# onblur="DoReq(this);<cfif onblur IS NOT "">#onblur#</cfif>" onchange="DoReq(this);<cfif onblur IS NOT "">#onblur#</cfif>" <CFIF MULTIPLE NEQ "" AND MULTIPLE GT 1> size="#MULTIPLE#" multiple="multiple"</CFIF>>
			<cfif NOT IsQuery(OPTLIST) AND ListLen(OPTLIST,OPTLISTSEP,"yes") GT 1>
				<CFSET selectedval = "">
				<cfloop FROM=1 TO=#ListLen(OPTLIST,OPTLISTSEP,"yes")# INDEX=a STEP=2>
					<cfset val=ListGetAt(OPTLIST,a,OPTLISTSEP,"yes")>
					<cfset txt=ListGetAt(OPTLIST,a+1,OPTLISTSEP,"yes")>
					<option value="#val#" <CFIF ListFindNoCase(Evaluate("#VARNAME#"), val, "|", "yes") GT 0><CFSET selectedval=ListAppend(selectedval, txt, ", ")>selected</cfif>>#txt#</option>
				</cfloop>
				<cfif BitAnd(APPEND_TITLE,1) IS 1 AND selectedval NEQ "" AND NOT(selectedval IS "All" OR selectedval IS "Not Applicable")>
					<cfset DRText=DRText & " (#SUBHEADER#" & selectedval &")">
				</cfif>
			</cfif>
		</select>
		</td>
	<cfelseif UI IS "TEXTBOX">
		<td valign=top>
		<cfif ListLen("#VARNAME#") IS 2>
			<b>Between</b> <input URLVAR <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> type=textbox name=#ListGetAt(VARNAME,1)# value="#Evaluate("#ListGetAt(VARNAME,1)#")#" size=#SIZE# onblur="<cfif onblur IS NOT "">#onblur#</cfif>" maxlength=10> <b>and</b> <input URLVAR <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> type=textbox name=#ListGetAt(VARNAME,2)# value="#Evaluate("#ListGetAt(VARNAME,2)#")#" size=#SIZE# onblur="DoReq(this);<cfif onblur IS NOT "">#onblur#</cfif>" maxlength=10>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#ListGetAt(VARNAME,1)#") IS NOT "">
				<cfset DRText=DRText&" (#SUBHEADER#>= #Evaluate("#ListGetAt(VARNAME,1)#")##DEFUNIT#)">
			</cfif>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#ListGetAt(VARNAME,2)#") IS NOT "">
				<cfset DRText=DRText&" (#SUBHEADER#<= #Evaluate("#ListGetAt(VARNAME,2)#")##DEFUNIT#)">
			</cfif>
		<cfelse>
			<input URLVAR <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> type=textbox name=#VARNAME# value="#Evaluate("#VARNAME#")#" size=#SIZE# onblur="<cfif onblur IS NOT "">#onblur#</cfif>;<!--- this.value=this.value.replace(/[^a-zA-Z0-9\- ]/gi,''); --->DoReq(this);" maxlength=50>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#VARNAME#") IS NOT "">
				<cfset DRText=DRText&" (#SUBHEADER##Evaluate("#VARNAME#")##DEFUNIT#)">
			</cfif>
		</cfif>
		</td>
	<cfelseif UI IS "CALDATE">
		<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCaddfile.cfm" FNAME="SVCTABLE">
		<td valign=top>
		<cfif ListLen("#VARNAME#") IS 2>
			<b>From</b> <input MRMOBJ=CALDATE URLVAR <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> type=textbox name=#ListGetAt(VARNAME,1)# value="#Evaluate("#ListGetAt(VARNAME,1)#")#" onblur="ObjDate(this);<cfif onblur IS NOT "">#onblur#</cfif>" maxlength=10> <b>To</b> <input MRMOBJ=CALDATE URLVAR <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> type=textbox name=#ListGetAt(VARNAME,2)# value="#Evaluate("#ListGetAt(VARNAME,2)#")#" onblur="ObjDate(this);<cfif onblur IS NOT "">#onblur#</cfif>" maxlength=10>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#ListGetAt(VARNAME,1)#") IS NOT "">
				<cfset DRText=DRText&" (#SUBHEADER#>= #Evaluate("#ListGetAt(VARNAME,1)#")#)">
			</cfif>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#ListGetAt(VARNAME,2)#") IS NOT "">
				<cfset DRText=DRText&" (#SUBHEADER#<= #Evaluate("#ListGetAt(VARNAME,2)#")#)">
			</cfif>
		<cfelse>
			<input URLVAR MRMOBJ=CALDATE <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> type=textbox name=#VARNAME# value="#Evaluate("#VARNAME#")#" onblur="ObjDate(this);<cfif onblur IS NOT "">#onblur#</cfif>" maxlength=10>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#VARNAME#") IS NOT "">
				<cfset DRText=DRText&" (#SUBHEADER##Evaluate("#VARNAME#")#)">
			</cfif>
		</cfif>
		</td>
	<cfelseif UI IS "CHECKBOX">
		<td valign=top>
		<input type=checkbox name=_#VARNAME# value=1 <CFIF Evaluate("#VARNAME#") IS 1>CHECKED</cfif> onclick="document.all.#VARNAME#.value=this.checked?1:0;#onclick#">
		<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#VARNAME#") IS 1>
			<cfset DRText=DRText&" (#SUBHEADER##Server.SVClang("Yes",1310)#)">
		</cfif>
		</td>
	<cfelseif UI IS "RADIO">
		<cfif NOT IsQuery(OPTLIST) AND ListLen(OPTLIST,OPTLISTSEP,"yes") GT 1>
			<td valign=top>
			<table cellspacing=0 cellpadding=0 border=0 width="100%"><tr>
			<cfloop FROM=1 TO=#ListLen(OPTLIST,OPTLISTSEP,"yes")# INDEX=a STEP=2>
				<cfif a MOD (Request.RPT_RADIOCOLS*2+1) IS 0></tr><tr></cfif>
				<cfset val=ListGetAt(OPTLIST,a,OPTLISTSEP,"yes")>
				<cfset txt=ListGetAt(OPTLIST,a+1,OPTLISTSEP,"yes")>
				<td valign=top width="<cfif a EQ ListLen(OPTLIST,OPTLISTSEP,"yes")-1 OR a MOD (Request.RPT_RADIOCOLS*2-1) IS 0>*<cfelse>#Request.RPT_RADIOWIDTH#</cfif>"><table cellpadding=0 cellspacing=0 border=0><tr><td valign=top><input type=radio name=_#VARNAME# id=_rb#VARNAME##val# value="#val#" <cfif val IS Evaluate("#VARNAME#")>checked</cfif> onclick="document.all.#VARNAME#.value=this.value;#onclick#" onblur="<cfif onblur IS NOT "">#onblur#</cfif>"></td><td><label for=_rb#VARNAME##val#>&nbsp;#txt#</label></td></tr></table></td>
				<cfif BitAnd(APPEND_TITLE,1) IS 1 AND val IS Evaluate("#VARNAME#") AND Trim(val) IS NOT "" AND NOT(txt IS "All" OR txt IS "Not Applicable")>
					<cfset DRText=DRText&" (#SUBHEADER#"&txt&")">
				</cfif>
			</cfloop>
			<cfloop FROM=#ListLen(OPTLIST,OPTLISTSEP,"yes")/2# TO=#Request.RPT_RADIOCOLS-1# INDEX=a>
				<td width="<cfif a EQ Request.RPT_RADIOCOLS-1>*<cfelse>#Request.RPT_RADIOWIDTH#</cfif>">&nbsp;</td>
			</cfloop>
			</tr></table></td>
		</cfif>
	<cfelseif UI IS "MULTICHECKBOX">
		<td valign=top>
		<cfif NOT IsQuery(OPTLIST) AND ListLen(OPTLIST,OPTLISTSEP,"yes") GT 1>
			<table cellspacing=0 cellpadding=0 border=0><tr>
			<cfset DRTextChild="">
			<cfloop FROM=1 TO=#ListLen(OPTLIST,OPTLISTSEP,"yes")# INDEX=a STEP=2>
				<cfif a MOD (Request.RPT_RADIOCOLS*2+1) IS 0></tr><tr></cfif>
				<cfset val=ListGetAt(OPTLIST,a,OPTLISTSEP,"yes")>
				<cfset txt=ListGetAt(OPTLIST,a+1,OPTLISTSEP,"yes")>
				<td valign=top width=#Request.RPT_RADIOWIDTH#><input type=CHECKBOX name=_#VARNAME# id=_rb#VARNAME##val# value="#val#" <cfif LISTFIND(Evaluate("#VARNAME#"),val) NEQ 0>checked</cfif> onclick="var y='';obj=document.getElementsByName('_#VARNAME#');for(var i=0;i<obj.length;i++) { if(obj[i].checked) {y=(y==''?y+obj[i].value:y+','+obj[i].value)} } document.all.#VARNAME#.value=y;#onclick#"><label for=_rb#VARNAME##val#>#txt#</label></td>
				<cfif LISTFIND(Evaluate("#VARNAME#"),val) NEQ 0 AND Trim(val) IS NOT "" AND NOT(txt IS "All" OR txt IS "Not Applicable")>
					<cfset DRTextChild=LISTAPPEND(DRTextChild,txt)>
				</cfif>
			</cfloop>
			<cfloop FROM=#ListLen(OPTLIST,OPTLISTSEP,"yes")/2# TO=#Request.RPT_RADIOCOLS-1# INDEX=a>
				<td width=#Request.RPT_RADIOWIDTH#>&nbsp;</td>
			</cfloop>
			</tr></table>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND DRTextChild NEQ ""><cfset DRText=DRText&" (#SUBHEADER#"&DRTextChild&")"></cfif>
		</cfif>
		</td>
	<cfelseif UI IS "LOOKUP">
		<td valign=top>
		<cfset args=ListToArray(LOOKUPARGS)>
		<cfif NOT IsDefined("#VARNAME#TEXT")><cfset "#VARNAME#TEXT"=""></cfif>
		<input <cfif COMPULSORY IS 1>CHKREQUIRED</cfif> URLVAR type=text name=#VARNAME#TEXT id=#VARNAME#TEXT maxlength="100" size="#SIZE#" readonly style="background-color:silver" value="#Evaluate("#VARNAME#TEXT")#" onblur=DoReq(this)>
		<cfmodule template="#request.logpath#index.cfm" fusebox="SVCobj" fuseaction="dsp_SVCSelector"
		URL="#request.webroot#index.cfm?fusebox=SVCobj&fuseaction=#LOOKUPURL#"
		TYPE="CFM" SHOWCHECKBOX="0" TEXTOBJID="#VARNAME#TEXT" VALUEOBJID="#VARNAME#" SRCTEXTFIELD="#args[1]#" SRCVALUEFIELD="#args[2]#" BUTTONTEXT="Lookup...">
		<input type=button class=clsButton value="Clear" onclick="document.getElementById('#VARNAME#').value='';document.getElementById('#VARNAME#TEXT').value='';">
		<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate("#VARNAME#") IS NOT "">
			<CFSET DRText=DRText&"<BR>#Evaluate("#VARNAME#TEXT")#">
		</cfif>
		</td>
	<cfelseif UI IS "CSV-DOWNLOAD">
		<td valign=top>
		<input class=clsSVCButton type=button value="<cfif DEFVALUE NEQ "0">#DEFVALUE#<CFELSE>Download</CFIF>" onclick="<!---this.disabled=true;--->var a=JSVCall('#VARNAME#');a.value=1;ProcessReport();a.value=0"><input URLVAR type=hidden name="#VARNAME#" value=0>
		</td>
	<cfelseif UI IS "CLM-LABEL">
		<CFIF TITLE IS "" AND VARNAME IS "MTRNMlbl"> <!--- MTR & NM LABEL --->
			<!--- query MTR LABELS --->
			<CFQUERY NAME=q_mtr DATASOURCE=#Request.RPTDSN#>
				select ID=ILBLDEFID FROM FOBJB3020
				WHERE ILBLDEFID IN (selecT iLBLDEFID FROM FOBJB3022 WHERE igcoid IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.gcoid#">) AND iSELECTOR & 1610964991>0 AND siSTATUS=0) AND SISTATUS=0 AND ILOCID IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#LOCID#">)
				<CFIF DOMAINID NEQ "">AND IDOMAINID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" list="YES" VALUE="#DOMAINID#">)</CFIF>
				ORDER BY valblname
			</CFQUERY>
			<cfset MTRLIST="">
			<cfloop query=q_mtr><cfset MTRLIST=MTRLIST & "#id#,"></cfloop>
			<CFIF MTRLIST IS NOT "">
				<td valign=top style="font-weight:bold;width:25%">#server.SVClang("Label (Motor)",37631)#:</td>
				<td valign=top>
				<CFSET SUBHEADER="#server.SVClang("Label (Motor)",37631)#: ">
				<CFSET RND=RandRange(1000,9999)>
				<CFSET CNT=0>
				<table cellspacing=0 cellpadding=0 border=0 width="100%" style="table-layout:fixed">
				<cfloop list="#MTRLIST#" index=a>
					<cfif StructKeyExists(Request.DS.LABELS,a)>
						<cfset lbls=Request.DS.LABELS[a]>
						<cfif CNT Mod 4 EQ 0></tr><tr></cfif>
						<td width="25%" nowrap style="overflow:hidden;text-overflow:ellipsis"><input URLVAR onclick=JSVCLabelEditClick(event,this) type=checkbox id=chklbl#a#-#RND# name=#VARNAME# value=#a#<cfif ListFind(Evaluate(VARNAME),a) GT 0> checked</cfif>><LABEL FOR=chklbl#a#-#RND#>&nbsp;<span style="background-color:###lbls.colorbgrnd#;color:###lbls.colortxt#;font-size:10px;padding:2px;padding-left:8px;padding-right:8px">#lbls.lblname#</span></LABEL></td>
						<CFSET CNT+=1>
					</cfif>
				</cfloop>
				</table>
				<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate(VARNAME) IS NOT "">
					<cfset txt="">
					<cfloop list="#MTRLIST#" index=a>
						<cfif ListFind(Evaluate(VARNAME),a) GT 0>
							<cfset txt=ListAppend(txt,Request.DS.LABELS[a].LBLNAME)>
						</cfif>
					</cfloop>
					<cfif ListLen(txt)>
						<cfset DRText=DRText&"<br>(#SUBHEADER##txt#)">
					</cfif>
				</cfif>
			</CFIF> <!--- END IF MTRLISTIS NOT NULL --->

			<CFQUERY NAME=q_nm DATASOURCE=#Request.RPTDSN#>
				select ID=ILBLDEFID FROM FOBJB3020
				WHERE ILBLDEFID IN (selecT iLBLDEFID FROM FOBJB3022 WHERE igcoid IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.gcoid#">) AND iSELECTOR & 536518656>0 AND siSTATUS=0) AND SISTATUS=0 AND ILOCID IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#LOCID#">)
				<CFIF DOMAINID NEQ "">AND IDOMAINID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" list="YES" VALUE="#DOMAINID#">)</CFIF>
				ORDER BY valblname
			</CFQUERY>
			<cfset NMLIST="">
			<cfloop query=q_nm><cfset NMLIST=NMLIST & "#id#,"></cfloop>
			<CFIF MTRLIST IS NOT "" AND NMLIST IS NOT "">
				</td></tr>
				<tr>
			</CFIF>
			<CFIF NMLIST IS NOT "">
				<td valign=top style="font-weight:bold;width:25%">#server.SVClang("Label (Nonmotor)",37632)#:</td>
				<td valign=top>
				<CFSET SUBHEADER="#server.SVClang("Label (Nonmotor)",37632)#: ">
				<CFSET RND=RandRange(1000,9999)>
				<CFSET CNT=0>
				<table cellspacing=0 cellpadding=0 border=0 width="100%" style="table-layout:fixed;background-color:##f0f0f0">
				<cfloop list="#NMLIST#" index=a>
					<cfif StructKeyExists(Request.DS.LABELS,a)>
						<cfset lbls=Request.DS.LABELS[a]>
						<cfif CNT Mod 4 EQ 0></tr><tr></cfif>
						<td width="25%" nowrap style="overflow:hidden;text-overflow:ellipsis"><input URLVAR onclick=JSVCLabelEditClick(event,this) type=checkbox id=chklbl#a#-#RND# name=#VARNAME# value=#a#<cfif ListFind(Evaluate(VARNAME),a) GT 0> checked</cfif>><LABEL FOR=chklbl#a#-#RND#>&nbsp;<span style="background-color:###lbls.colorbgrnd#;color:###lbls.colortxt#;font-size:10px;padding:2px;padding-left:8px;padding-right:8px">#lbls.lblname#</span></LABEL></td>
						<CFSET CNT+=1>
					</cfif>
				</cfloop>
				</table>
				<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate(VARNAME) IS NOT "">
					<cfset txt="">
					<cfloop list="#NMLIST#" index=a>
						<cfif ListFind(Evaluate(VARNAME),a) GT 0>
							<cfset txt=ListAppend(txt,Request.DS.LABELS[a].LBLNAME)>
						</cfif>
					</cfloop>
					<cfif ListLen(txt)>
						<cfset DRText=DRText&"<br>(#SUBHEADER##txt#)">
					</cfif>
				</cfif>
			</CFIF> <!--- NMLISTIS NOT NULL --->
		<CFELSEIF TITLE IS "" AND VARNAME IS "Combinelbl"> <!--- MTR & NM Combine LABEL --->
			<!--- query MTR LABELS ---><!---#24280: [MY] MPI - Motor - Partner Repairer Report enhancement (Part 2)--->
			<CFQUERY NAME=q_mtr DATASOURCE=#Request.RPTDSN#>
				select ID=ILBLDEFID FROM FOBJB3020
				WHERE ILBLDEFID IN (selecT iLBLDEFID FROM FOBJB3022 WHERE igcoid IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.gcoid#">) AND siSTATUS=0) AND SISTATUS=0 AND ILOCID IN (0,<cfqueryparam cfsqltype="cf_sql_integer" value="#LOCID#">)
				<CFIF DOMAINID NEQ "">AND IDOMAINID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" list="YES" VALUE="#DOMAINID#">)</CFIF>
				ORDER BY valblname
			</CFQUERY>
			<cfset LBLLIST="">
			<cfloop query=q_mtr><cfset LBLLIST=LBLLIST & "#id#,"></cfloop>
			<CFIF LBLLIST IS NOT "">
				<td valign=top style="font-weight:bold;width:25%">#Server.SVClang("Label",0)#:</td>
				<td valign=top>
				<CFSET SUBHEADER="#Server.SVClang("Label",0)#: ">
				<CFSET RND=RandRange(1000,9999)>
				<CFSET CNT=0>
				<table cellspacing=0 cellpadding=0 border=0 width="100%" style="table-layout:fixed">
				<cfloop list="#LBLLIST#" index=a>
					<cfif StructKeyExists(Request.DS.LABELS,a)>
						<cfset lbls=Request.DS.LABELS[a]>
						<cfif CNT Mod 4 EQ 0></tr><tr></cfif>
						<td width="25%" nowrap style="overflow:hidden;text-overflow:ellipsis"><input URLVAR onclick=JSVCLabelEditClick(event,this) type=checkbox id=chklbl#a#-#RND# name=#VARNAME# value=#a#<cfif ListFind(Evaluate(VARNAME),a) GT 0> checked</cfif>><LABEL FOR=chklbl#a#-#RND#>&nbsp;<span style="background-color:###lbls.colorbgrnd#;color:###lbls.colortxt#;font-size:10px;padding:2px;padding-left:8px;padding-right:8px">#lbls.lblname#</span></LABEL></td>
						<CFSET CNT+=1>
					</cfif>
				</cfloop>
				</table>
				<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate(VARNAME) IS NOT "">
					<cfset txt="">
					<cfloop list="#LBLLIST#" index=a>
						<cfif ListFind(Evaluate(VARNAME),a) GT 0>
							<cfset txt=ListAppend(txt,Request.DS.LABELS[a].LBLNAME)>
						</cfif>
					</cfloop>
					<cfif ListLen(txt)>
						<cfset DRText=DRText&"<br>(#SUBHEADER##txt#)">
					</cfif>
				</cfif>
			</CFIF> <!--- END IF MTRLISTIS NOT NULL --->
		<CFELSE>
			<td valign=top>
			<CFSET RND=RandRange(1000,9999)>
			<cfloop list="#OPTLIST#" index=a>
				<cfif StructKeyExists(Request.DS.LABELS,a)>
					<cfset lbl=Request.DS.LABELS[a]>
					<input URLVAR onclick=JSVCLabelEditClick(event,this) type=checkbox id=chklbl#a#-#RND# name=#VARNAME# value=#a#<cfif ListFind(Evaluate(VARNAME),a) GT 0> checked</cfif>><LABEL FOR=chklbl#a#-#RND#>&nbsp;<span style="background-color:###lbl.colorbgrnd#;color:###lbl.colortxt#;font-size:10px;padding:2px;padding-left:8px;padding-right:8px">#lbl.lblname#</span></LABEL>
				</cfif>
			</cfloop>
			<cfif BitAnd(APPEND_TITLE,1) IS 1 AND Evaluate(VARNAME) IS NOT "">
				<cfset txt="">
				<cfloop list="#OPTLIST#" index=a>
					<cfif ListFind(Evaluate(VARNAME),a) GT 0>
						<cfset txt=ListAppend(txt,Request.DS.LABELS[a].LBLNAME)>
					</cfif>
				</cfloop>
				<cfif ListLen(txt)>
					<cfset DRText=DRText&"<br>(#SUBHEADER##txt#)">
				</cfif>
			</cfif>
		</CFIF>
		</td>
	</cfif>
</tr>
</table>
<cfif ListFind("RADIO,CHECKBOX,MULTICHECKBOX,LOOKUP",UI) GT 0>
	<input URLVAR type=hidden name=#VARNAME# id=#VARNAME# value="#Evaluate("#VARNAME#")#">
</cfif>
<cfif onclick IS NOT "">
	<script>AddOnloadCode("#onclick#;");</script>
</cfif>
</CFOUTPUT>
</cffunction>
<CFSET Attributes.DS.FN.SVCRptGenFilter=SVCRptGenFilter>

<cffunction
	name="SVCCSVToQuery"
	access="public"
	returntype="query"
	output="false"
	hint="Converts the given CSV string to a query.">

	<!--- Define arguments. --->
	<cfargument
		name="CSV"
		type="string"
		required="true"
		hint="This is the CSV string that will be manipulated."
		/>

	<cfargument
		name="HasHeader"
		type="numeric"
		required="false"
		default=0
		hint="0: the first row is not header of data, 1: the first row is the header of data"
		/>

	<cfargument
		name="Delimiter"
		type="string"
		required="false"
		default=","
		hint="This is the delimiter that will separate the fields within the CSV value."
		/>

	<cfargument
		name="Qualifier"
		type="string"
		required="false"
		default=""""
		hint="This is the qualifier that will wrap around fields that have special characters embeded."
		/>

	<!--- Define the local scope. --->
	<cfset var LOCAL = StructNew() />

	<!---
		When accepting delimiters, we only want to use the first character that we were passed. This is different than standard ColdFusion, but I am trying to make this as easy as possible.
	--->
	<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />

	<!---
		When accepting the qualifier, we only want to accept the first character returned. Is is possible that there is no qualifier being used. In that case, we can just store the empty string (leave as-is).
	--->
	<cfif Len( ARGUMENTS.Qualifier )>
		<cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
	</cfif>
	<!---
		Set a variable to handle the new line. This will be the character that acts as the record delimiter.
	--->
	<cfset LOCAL.LineDelimiter = Chr( 10 ) />

	<!---
		We want to standardize the line breaks in our CSV value. A "line break" might be a return followed by a feed or just a line feed. We want to standardize it so that it 	is just a line feed. That way, it is easy to check for later (and it is a single character which makes our
		life 1000 times nicer).
	--->
	<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(
		"\r?\n",
		LOCAL.LineDelimiter
		) />


	<!---
		Let's get an array of delimiters. We will need this when we are going throuth the tokens and building up field values. To do this, we are going to strip out all characters that are NOT delimiters and then get the
		character array of the string. This should put each	delimiter at it's own index.
	--->
	<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll(
		"[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+",
		""
		)

		<!---
			Get character array of delimiters. This will put each found delimiter in its own index (that should correspond to the tokens).
		--->
		.ToCharArray()
		/>

	<!---
		Add a blank space to the beginning of every theoretical field. This will help in make sure that ColdFusion / Java does not skip over any fields simply because they do not have a value. We just have to be sure to strip out this space later on.
		First, add a space to the beginning of the string.
	--->
	<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
	<!--- Now add the space to each field. --->
	<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll(
		"([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})",
		"$1 "
		) />

	<!---
		Break the CSV value up into raw tokens. Going forward, some of these tokens may be merged, but doing it this way will help us iterate over them. When splitting the string, add a space to each token first to ensure that
		the split works properly.

		BE CAREFUL! Splitting a string into an array using the Java String::Split method does not create a COLDFUSION ARRAY. You cannot alter this array once it has been created. It can merely be referenced (read only).
		We are splitting the CSV value based on the BOTH the field delimiter and the line delimiter. We will handle this later as we build values (this is why we created the array of delimiters above).
	--->
	<cfset LOCAL.Tokens = ARGUMENTS.CSV.Split(
		"[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}"
		) />

	<!---
		Set up the default records array. This will be a full array of arrays, but for now, just create the parent array with no indexes.
	--->
	<cfset LOCAL.Rows = ArrayNew( 1 ) />

	<!---
		Create a new active row. Even if we don't end up adding any values to this row, it is going to make our lives more smiple to have it in existence.
	--->
	<cfset ArrayAppend(
		LOCAL.Rows,
		ArrayNew( 1 )
		) />

	<!---
		Set up the row index. THis is the row to which we are actively adding value.
	--->
	<cfset LOCAL.RowIndex = 1 />

	<!---
		Set the default flag for wether or not we are in the middle of building a value across raw tokens.
	--->
	<cfset LOCAL.IsInValue = false />

	<!---
		Loop over the raw tokens to start building values. We have no sense of any row delimiters yet. Those will have to be checked for as we are building up each value.
	--->
	<cfloop
		index="LOCAL.TokenIndex"
		from="1"
		to="#ArrayLen( LOCAL.Tokens )#"
		step="1">

		<!---
			Get the current field index. This is the current index of the array to which we might be appending values (for a multi-token value).
		--->
		<cfset LOCAL.FieldIndex = ArrayLen(
			LOCAL.Rows[ LOCAL.RowIndex ]
			) />

		<!---
			Get the next token. Trim off the first character which is the empty string that we added to ensure proper splitting.
		--->
		<cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst(
			"^.{1}",
			""
			) />

		<!---
			Check to see if we have a field qualifier. If we do, then we might have to build the value across multiple fields. If we do not, then the raw tokens should line up perfectly with the real tokens.
		--->
		<cfif Len( ARGUMENTS.Qualifier )>
			<!---
				Check to see if we are currently building a field value that has been split up among different delimiters.
			--->
			<cfif LOCAL.IsInValue>
				<!---
					ASSERT: Since we are in the middle of building up a value across tokens, we can assume that our parent FOR loop has already executed at least once. Therefore, we can
					assume that we have a previous token value ALREADY in the row value array and that we have access to a previous delimiter (in our delimiter array).
				--->

				<!---
					Since we are in the middle of building a value, we replace out double qualifiers with a constant. We don't care about the first qualifier as it can ONLY be an escaped qualifier (not a field qualifier).
				--->
				<cfset LOCAL.Token = LOCAL.Token.ReplaceAll(
					"\#ARGUMENTS.Qualifier#{2}",
					"{QUALIFIER}"
					) />
				<!---
					Add the token to the value we are building. While this is not easy to read, add it directly to the results array as this will allow us to forget about it later. Be sure
					to add the PREVIOUS delimiter since it is actually an embedded delimiter character (part of the whole field value).
				--->
				<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (
					LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] &
					LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] &
					LOCAL.Token
					) />
				<!---
					Now that we have removed the possibly escaped qualifiers, let's check to see if this field is ending a multi-token 	qualified value (its last character is a field qualifier).
				--->
				<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
					<!---
						Wooohoo! We have reached the end of a qualified value. We can complete this value and move onto the next field. Remove the trailing quote. Remember, we have already added to token
						to the results array so we must now manipulate the results array directly. Any changes made to LOCAL.Token at this point will not affect the results.
					--->
					<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
					<!---
						Set the flag to indicate that we are no longer building a field value across tokens.
					--->
					<cfset LOCAL.IsInValue = false />
				</cfif>
			<cfelse>
				<!---
					We are NOT in the middle of building a field value which means that we have to be careful of a few special token cases:
					1. The field is qualified on both ends.
					2. The field is qualified on the start end.
				--->

				<!---
					Check to see if the beginning of the field is qualified. If that is the case then either this field is starting a multi-token value OR 	this field has a completely qualified value.
				--->
				<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
					<!---
						Delete the first character of the token. This is the field qualifier and we do NOT want to include it in the final value.
					--->
					<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst(
						"^.{1}",
						""
						) />

					<!---
						Remove all double qualifiers so that we can test to see if the field has a closing qualifier.
					--->
					<cfset LOCAL.Token = LOCAL.Token.ReplaceAll(
						"\#ARGUMENTS.Qualifier#{2}",
						"{QUALIFIER}"
						) />
					<!---
						Check to see if this field is a self-closer. If the first character is a qualifier (already established) and the last character is also a qualifier (what we are about to test for), then this
						token is a fully qualified value.
					--->
					<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<!---
							This token is fully qualified. Remove the end field qualifier and append it to the row data.
						--->
						<cfset ArrayAppend(
							LOCAL.Rows[ LOCAL.RowIndex ],
							LOCAL.Token.ReplaceFirst(
								".{1}$",
								""
								)
							) />
					<cfelse>
						<!---
							This token is not fully qualified (but the first character was a qualifier). We are buildling a value up across differen tokens. Set the flag for building the value.
						--->
						<cfset LOCAL.IsInValue = true />
						<!--- Add this token to the row. --->
						<cfset ArrayAppend(
							LOCAL.Rows[ LOCAL.RowIndex ],
							LOCAL.Token
							) />
					</cfif>
				<cfelse>
					<!---
						We are not dealing with a qualified field (even though we are using field qualifiers). Just add this token value as the next value in the row. --->
					<cfset ArrayAppend(
						LOCAL.Rows[ LOCAL.RowIndex ],
						LOCAL.Token
						) />
				</cfif>
			</cfif>
			<!---
				As a sort of catch-all, let's remove that {QUALIFIER} constant that we may have thrown 	into a field value. Do NOT use the FieldIndex value as this might be a corrupt value at this point in the token iteration.
			--->
			<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(
				LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],
				"{QUALIFIER}",
				ARGUMENTS.Qualifier,
				"ALL"
				) />
		<cfelse>
			<!---
				Since we don't have a qualifier, just use the current raw token as the actual value. We are NOT going to have to worry about building values across tokens.
			--->
			<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ], LOCAL.Token) />
		</cfif>
		<!---
			Check to see if we have a next delimiter and if we 	do, is it going to start a new row? Be cautious that we are NOT in the middle of building a value. If we are building a value then the line delimiter is an  embedded value and should not percipitate a new row.
		--->
		<cfif (
			(NOT LOCAL.IsInValue) AND
			(LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND
			(LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter)
			)>

			<!---
				The next token is indicating that we are about start a new row. Add a new array to the parent and increment the row counter.
			--->
			<cfset ArrayAppend(
				LOCAL.Rows,
				ArrayNew( 1 )
				) />

			<!--- Increment row index to point to next row. --->
			<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />

		</cfif>
	</cfloop>
	<!---
		ASSERT: At this point, we have parsed the CSV into an array of arrays (LOCAL.Rows). Now, we can take that array of arrays and convert it into a query.
	--->

	<!---
		To create a query that fits this array of arrays, we need to figure out the max length for each row as 	well as the number of records.

		The number of records is easy - it's the length of the array. The max field count per row is not that easy. We will have to iterate over each row to find the max.

		However, this works to our advantage as we can use that array iteration as an opportunity to build up a single array of empty string that we will use to pre-populate the query.
	--->

	<!--- Set the initial max field count. --->
	<cfset LOCAL.MaxFieldCount = 0 />

	<!---
		Set up the array of empty values. As we iterate over the rows, we are going to add an empty value to this for each record (not field) that we find. --->
	<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
	<cfset LOCAL.QueryColNames = ArrayNew( 1 ) />


	<!--- Loop over the records array. --->
	<cfif arguments.HasHeader IS 1 AND ArrayLen( LOCAL.Rows ) IS 0>
		<cfset arguments.HasHeader=0>
	</cfif>
	<cfloop
		index="LOCAL.RowIndex"
		from="1"
		to="#ArrayLen( LOCAL.Rows )#"
		step="1">

		<!--- Get the max rows encountered so far. --->
		<cfset LOCAL.MaxFieldCount = Max(
			LOCAL.MaxFieldCount,
			ArrayLen(
				LOCAL.Rows[ LOCAL.RowIndex ]
				)
			) />

		<!--- Add an empty value to the empty array. --->
		<cfset ArrayAppend(
			LOCAL.EmptyArray,
			""
			) />

	</cfloop>


	<!---
		ASSERT: At this point, LOCAL.MaxFieldCount should hold the number of fields in the widest row. Additionally,the LOCAL.EmptyArray should have the same number of	indexes as the row array - each index containing an	empty string.
	--->


	<!---
		Now, let's pre-populate the query with empty strings. We are going to create the query as all VARCHAR data fields, starting off with blank. Then we will override	these values shortly.
	--->
	<cfset LOCAL.Query = QueryNew( "" ) />

	<!---
		Loop over the max number of fields and create a column	for each records.
	--->
	<cfloop
		index="LOCAL.FieldIndex"
		from="1"
		to="#LOCAL.MaxFieldCount#"
		step="1">

		<!---
			Add a new query column. By using QueryAddColumn() rather than QueryAddRow() we are able to leverage ColdFusion's ability to add row values in bulk based on an array of values. Since we are going to pre-populate the query with empty values, we can just send in the EmptyArray we built previously.
		--->


<!--- HasHeader --->
		<cfif arguments.HasHeader IS 1>
			<cfset LOCAL.QueryColNames[LOCAL.FieldIndex]=JavaCast("string",LOCAL.Rows[ 1 ][ LOCAL.FieldIndex ])>
		<cfelse>
			<cfset LOCAL.QueryColNames[LOCAL.FieldIndex]="COLUMN_#LOCAL.FieldIndex#">
		</cfif>

		<cfset QueryAddColumn(
			LOCAL.Query,
			LOCAL.QueryColNames[LOCAL.FieldIndex],
			"CF_SQL_VARCHAR",
			LOCAL.EmptyArray
			) />
	</cfloop>
	<!---
		ASSERT: At this point, our return query LOCAL.Query contains enough columns and rows to handle all the data that we have stored in our array of arrays.
	--->
	<!---
		Loop over the array to populate the query with actual data. We are going to have to loop over each row and then each field.
	--->
	<cfloop
		index="LOCAL.RowIndex"
		from="1"
		to="#ArrayLen( LOCAL.Rows )#"
		step="1">

		<!--- Loop over the fields in this record. --->
		<cfloop
			index="LOCAL.FieldIndex"
			from="1"
			to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#"
			step="1">
			<!---
				Update the query cell. Remember to cast string to make sure that the underlying Java data works properly.
			--->
			<cfset LOCAL.Query[ LOCAL.QueryColNames[LOCAL.FieldIndex] ][ LOCAL.RowIndex ] = JavaCast(
				"string",
				LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]
				) />

		</cfloop>

	</cfloop>

	<cfif arguments.HasHeader IS 1>
		<cfscript>
		      LOCAL.Query.RemoveRows(0,1);
		</cfscript>
	</cfif>

	<cfreturn LOCAL.Query />

</cffunction>
<CFSET Attributes.DS.FN.SVCCSVToQuery=SVCCSVToQuery>

<cffunction name="SVCHtmlReplaceGraphicsLink" access="public"
	returntype="string"
	output="false"
	hint="Map to server path for all relative path (HTML tag img/link) in the HTML content.">
<cfargument name="htmstr" type="string">
<CFSET var replacestr="http://#Application.APPWEBSERVER#">
<CFIF IsDefined("Application.APPPATH") AND Application.APPPATH IS NOT "">
	<CFSET APPPATH=Application.APPPATH>
	<cfset Arguments.htmstr=REReplaceNoCase(REReplaceNoCase(htmstr,"(\\)","/","ALL"),"((src|link href)\=[""']*)(#Application.APPPATH#)","\1#replacestr##Application.APPPATH#","ALL")>
<CFELSE>
	<cfset Arguments.htmstr=REReplaceNoCase(htmstr,"((src|link href)\=[""']*)(#request.approot#)","\1#replacestr##request.approot#","ALL")>
</CFIF>
<cfreturn Arguments.htmstr>
</cffunction>
<CFSET Attributes.DS.FN.SVCHtmlReplaceGraphicsLink=SVCHtmlReplaceGraphicsLink>

<cffunction name="QuarterFirstDate" returnType="date">
    <cfargument name="quarternumber" required="yes" type="numeric">
    <cfargument name="yr" type="numeric" default="2014">
    <cfargument name="startmonth" type="numeric" default="1">
    <cfset firstDate = DateAdd("m",startmonth-1,CreateDate(yr, ((quarternumber-1)*3)+1, "1"))>
    <cfreturn firstDate>
</cffunction>
<CFSET Attributes.DS.FN.QuarterFirstDate=QuarterFirstDate>

<cffunction name="QuarterLastDate" returnType="date">
    <cfargument name="quarternumber" required="yes" type="numeric">
    <cfargument name="yr" type="numeric"  default="2014">
    <cfargument name="startmonth" type="numeric" default="1">
    <!--- <cfset lastDate = DateAdd("m",startmonth-1,CreateDate(yr, quarternumber*3, DaysInMonth(CreateDate(yr, quarternumber*3, "1"))))> --->
    <cfset lastDate = DateAdd("d", -1, DateAdd("m", quarternumber*3, CreateDate(yr, startmonth, 1)))>
    <cfreturn lastDate>
</cffunction>
<CFSET Attributes.DS.FN.QuarterLastDate=QuarterLastDate>

<cffunction name="SVCwriteActLog" access="public" returntype="any" output="false">
<cfargument name="DomID" type=numeric required=true>
<cfargument name="ObjID" type=numeric required=true>
<cfargument name="LogTypeID" type=numeric required=true>
<cfargument name="CoRole" type=numeric required=true>
<cfargument name="Text" type=string required=true>
<cfargument name="UserID" type=numeric required=false default=0>
<cfargument name="cattype" type=numeric required=false default=0>
<cfargument name="redirectpathtoclear" type=numeric required=false default=2>
<CFTRY>
	<cfif Arguments.UserID IS 0>
		<cfif StructKeyExists(SESSION,"VARS") AND StructKeyExists(SESSION.VARS,"USID")>
			<cfset Arguments.UserID=SESSION.VARS.USID>
		<cfelse>
			<CFTHROW TYPE="EX_DBERROR" ErrorCode="SVC-WriteActivityLog" ExtendedInfo="UserID must be specified.">
		</cfif>
	</cfif>
	<CFQUERY NAME=Local.q_trx DATASOURCE=#Request.SVCDSN#>
	SELECT CURDT=GETDATE(),USNAME=vaUSNAME
	FROM SEC0001 WHERE iUSID=<cfqueryparam cfsqltype="cf_sql_integer" value="#Arguments.UserID#">
	</CFQUERY>
	<cfif Local.q_trx.RecordCount NEQ 1>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="SVC-WriteActivityLog" ExtendedInfo="UserID not found.">
	</cfif>

	<cfset local.remarks = "">

    <cfif Len(arguments.text) gt 0>
        <cfif arguments.cattype gt 0>
            <cfif Len(arguments.text) gt 0>
                <cfquery name="qry_logcat2" dbtype="query">
                    select vadesc from request.ds.logcat where iCAT = <cfqueryparam value="#arguments.cattype#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
                <cfset local.remarks = "[Category: #qry_logcat2.vadesc#] [#Request.DS.FN.SVCdt(Local.q_trx.curdt,0,'STD','STD')#] #Local.q_trx.USNAME#:" & Chr(13)&Chr(10)&Chr(9) & REReplace(Trim(Arguments.Text),"\n",Chr(13)&Chr(10)&Chr(9),"all") & Chr(13)&Chr(10)&Chr(13)&Chr(10)>
            <cfelse>
                <cfset Local.Remarks="[#Request.DS.FN.SVCdt(Local.q_trx.curdt,0,'STD','STD')#] #Local.q_trx.USNAME#:" & Chr(13)&Chr(10)&Chr(9) & REReplace(Trim(Arguments.Text),"\n",Chr(13)&Chr(10)&Chr(9),"all") & Chr(13)&Chr(10)&Chr(13)&Chr(10)>
            </cfif>
		<CFELSE>
			<cfset local.remarks = arguments.text>
        </cfif>
	<CFELSE>
		<cfset local.remarks = arguments.text>
    </cfif>

	<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCobj FUSEACTION=act_actlog
		DOMAINID=#Arguments.DomID# OBJID=#Arguments.ObjID# USID=#Arguments.UserID# COROLE=#Arguments.CoRole# LOGTYPE=#Arguments.LogTypeID# REMARKS=#Local.Remarks# category=#arguments.cattype# redirectpathtoclear=#arguments.redirectpathtoclear#>
	<CFCATCH TYPE="ANY">
		<CFRETHROW>
	</CFCATCH>
</CFTRY>
</cffunction>
<CFSET Attributes.DS.FN.SVCwriteActLog=SVCwriteActLog>

<cffunction	name="SVCListDeleteValue" access="public" returntype="string" output="false" hint="Deletes a given value (or list of values) from a list. This is not case sensitive.">
	<cfargument	name="List"	type="string" required="true" hint="The list from which we want to delete values."/>
	<cfargument name="Value" type="string" required="true" hint="The value or list of values that we want to delete from the first list."/>
	<cfargument name="Delimiters" type="string" required="false" default="," hint="The delimiting characters used in the given lists."/>

	<cfset var LOCAL = StructNew() />
	<cfset LOCAL.Result = ArrayNew( 1 ) />
	<cfset LOCAL.ListArray = ListToArray(ARGUMENTS.List,ARGUMENTS.Delimiters) />
	<cfset LOCAL.ValueLookup = StructNew() />

	<cfloop index="LOCAL.ValueItem"	list="#ARGUMENTS.Value#" delimiters="#ARGUMENTS.Delimiters#">
		<cfset LOCAL.ValueLookup[ LOCAL.ValueItem ] = true />
	</cfloop>

	<cfloop index="LOCAL.ValueIndex" from="1" to="#ArrayLen( LOCAL.ListArray )#" step="1">
		<cfset LOCAL.Value = LOCAL.ListArray[ LOCAL.ValueIndex ] />
		<cfif NOT StructKeyExists(LOCAL.ValueLookup,LOCAL.Value)>
			<cfset ArrayAppend(LOCAL.Result,LOCAL.Value) />
		</cfif>
	</cfloop>

	<cfreturn ArrayToList(LOCAL.Result,	Left( ARGUMENTS.Delimiters, 1 ))/>
</cffunction>
<CFSET Attributes.DS.FN.SVCListDeleteValue=SVCListDeleteValue>

<cffunction name="SVCListCommon" access="public" output="false" returnType="string" hint="compare 2 list and return list of common values">
	<cfargument name="list1" type="string" required="true" />
	<cfargument name="list2" type="string" required="true" />

	<cfset var list1Array = ListToArray(arguments.List1) />
	<cfset var list2Array = ListToArray(arguments.List2) />

	<cfset list1Array.retainAll(list2Array) />

	<cfreturn ArrayToList(list1Array) />
</cffunction>
<CFSET Attributes.DS.FN.SVCListCommon=SVCListCommon>

<cffunction name="SVCCurrencyGenRequestVars" description="Generate request variables" access="public" returntype="any" output="true">
	<cfargument name="BASECURRENCYID" type="string" required="false" default="">
	<cfargument name="RATELOCALPERBASE" type="string" required="false" default="">
	<cfargument name="NUMREFORMAT" type="string" required="false" default="">
	<cfif NOT(arguments.BASECURRENCYID GT 0)>
		<cfset arguments.BASECURRENCYID=#request.ds.locales[session.vars.locid].currencyID#>
		<cfset arguments.RATELOCALPERBASE=1>
	</cfif>
	<cfset request.BASECURRENCY=Request.DS.FN.SVCgetCurr(arguments.BASECURRENCYID)>
	<cfset request.BASECURRENCY.RATETOLOCAL=#arguments.RATELOCALPERBASE#>
	<!--- <cfset request.currencyID=arguments.BASECURRENCYID> --->
	<cfoutput>
	<script>try{JSVCSetLocale(#session.vars.locid#,#Request.DS.FN.SVCSerializeJSON(Request.DS.FN.SVCGetNumFormat(session.vars.locid,arguments.BASECURRENCYID))#);} catch (e) {}</script>
	<cfif ARGUMENTS.NUMREFORMAT NEQ ""><!--- e.g. : "-|.|2|,|3|2" --->
		<cfset temp=#request.DS.FN.SVCNumReFormat(ARGUMENTS.NUMREFORMAT)#>
	<!--- <cfelse>
		<cfset Request.OVERRIDE_NUMFORMAT="">
		<script>jSVCnumformat=null;</script> --->
	</cfif>
	</cfoutput>
	<cfreturn>
</cffunction>
<cfset Attributes.DS.FN.SVCCurrencyGenRequestVars=SVCCurrencyGenRequestVars>

<cffunction name="SVCNumReFormat" description="Re-format numeric" access="public" returntype="any" output="true">
	<cfargument name="NUMREFORMAT" type="string" required="false" default="">
	<cfif ARGUMENTS.NUMREFORMAT NEQ ""><!--- e.g. : "-|.|2|,|3|2" --->
		<cfset Request.OVERRIDE_NUMFORMAT=#ARGUMENTS.NUMREFORMAT#>
		<script>jSVCnumformat='#JSStringFormat(ARGUMENTS.NUMREFORMAT)#'.split("|");</script>
	</cfif>
	<cfreturn>
</cffunction>
<cfset Attributes.DS.FN.SVCNumReFormat=SVCNumReFormat>

<cffunction name="CurrencyType" description="Show Type of currency" access="public" returntype="any" output="false">
	<cfargument name="mode" type="string" required="false" default="BASE"><!--- BASE or LOCAL --->
	<cfset var CurrencyCode=false>
	<cfif arguments.mode IS ""><cfset arguments.mode="BASE"></cfif>

	<!--- #26874: Display currency in currency code name (ISO-4217) instead of currency symbol --->
	<cfif StructKeyExists(SESSION,"VARS") AND StructKeyExists(SESSION.VARS,"LOCID") AND SESSION.VARS.LOCID IS 11>
		<cfset CurrencyCode=true>
	</cfif>

	<cfif Isdefined("request.BASECURRENCY")>
		<cfif arguments.mode IS "LOCAL">
			<!--- <cfset local.returnvalue=#request.ds.locales[session.vars.locid].currencyID#> --->
			<cfif CurrencyCode>
				<cfset local.returnvalue=#request.ds.currencies[request.ds.locales[session.vars.locid].currencyID].CurrencyIntl#>
			<cfelse>
				<cfset local.returnvalue=#request.ds.currencies[request.ds.locales[session.vars.locid].currencyID].currency#>
			</cfif>
		<!---cfelseif arguments.mode IS "BASE">
			<cfset local.returnvalue=#request.BASECURRENCY.currency#> --->
		<cfelse><!--- base --->
			<cfif CurrencyCode>
				<cfset local.returnvalue=#request.BASECURRENCY.CurrencyIntl#>
			<cfelse>
				<cfset local.returnvalue=#request.BASECURRENCY.currency#>
			</cfif>
		</cfif>
	<cfelse>
		<!--- <cfset local.returnvalue=#request.ds.locales[session.vars.locid].currencyID#> --->
		<cfif CurrencyCode>
			<cfset local.returnvalue=#request.ds.currencies[request.ds.locales[session.vars.locid].currencyID].CurrencyIntl#>
		<cfelse>
			<cfset local.returnvalue=#request.ds.currencies[request.ds.locales[session.vars.locid].currencyID].currency#>
		</cfif>
	</cfif>
	<CFRETURN local.returnvalue>
</cffunction>
<cfset Attributes.DS.FN.CurrencyType=CurrencyType>

<cffunction name="SVCCurrencyQueryBaseToLocal" description="Convert query provided from base currency amount to Local currency amount" access="public" returntype="any" output="false">
	<!--- it was built which commonly to convert the base currency into local in order to do comparision between user approval limit (in local currency) and approval amount (in base currency) --->
	<cfargument name="currentquery" type="query" required="true">
	<cfargument name="collist" type="string" required="true">
	<cfargument name="cols_apply_for_positive_value_only" type="string" required="false" default=""><!--- include column name in this param if the column shouldn't converted, esp for approval limit, mandate limit, etc --->
	<cfargument name="ratetolocal" type="string" required="false" default="">
	<cfset local.thequerylist=#ArrayToList(currentquery.getColumnNames())#>
	<cfset local.recordrow=0>
	<cfset local.thisamount=0>
<!--- 	..<cfdump var=#local.thequerylist#> vs <cfdump var=#arguments.collist#> ..
<cfabort> --->
	<cfif arguments.collist IS ""><cfthrow TYPE="EX_SECFAILED" ExtendedInfo="Query column name should be specified"></cfif>
	<cfloop list="#arguments.collist#" index="col">
		<cfif LISTFINDNOCASE(local.thequerylist,col) IS 0>
			<cfthrow TYPE="EX_SECFAILED" ExtendedInfo="Invalid query var defined">
		</cfif>
	</cfloop>
	<cfoutput query="arguments.currentquery">
		<cfset local.recordrow=#currentrow#>
		<cfloop list="#local.thequerylist#" index="col">
			<cfset local.thisamount=#arguments.currentquery[col][local.recordrow]#>
			<cfif local.thisamount NEQ "" AND LISTFINDNOCASE(arguments.collist,col) GT 0>
				<cfif LISTFINDNOCASE(arguments.cols_apply_for_positive_value_only,col) IS 0 OR (LISTFINDNOCASE(arguments.cols_apply_for_positive_value_only,col) GT 0 AND local.thisamount GT 0)>
					<cfset querysetcell(arguments.currentquery,"#col#",request.DS.FN.SVCCurrencyBaseToLocal(local.thisamount,arguments.ratetolocal),local.recordrow)>
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>
	<CFRETURN arguments.currentquery>
</cffunction>
<cfset Attributes.DS.FN.SVCCurrencyQueryBaseToLocal=SVCCurrencyQueryBaseToLocal>

<cffunction name="SVCCurrencyBaseToLocal" description="Convert base currency amount to Local currency amount" access="public" returntype="any" output="false">
	<cfargument name="baseamount" type="numeric" required="true">
	<cfargument name="ratetolocal" type="string" required="false" default="">
	<cfif NOT(arguments.ratetolocal GT 0) AND Isdefined("request.BASECURRENCY.RATETOLOCAL")>
		<cfset arguments.ratetolocal=#request.BASECURRENCY.RATETOLOCAL#>
	</cfif>
	<cfif NOT(arguments.ratetolocal GT 0)><cfthrow TYPE="EX_SECFAILED" ExtendedInfo="Invalid Exchange Rate Base/Local"></cfif>
	<cfif arguments.baseamount NEQ "" AND Isnumeric(arguments.baseamount)>
		<CFRETURN evaluate(baseamount*arguments.ratetolocal)>
	<cfelse>
		<CFRETURN "">
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCCurrencyBaseToLocal=SVCCurrencyBaseToLocal>

<cffunction name="SVCDetectMobile" access="public" output="false" hint="Detect whether to display mobile version or not. Sets request.mobile=1 if user agent string matches, or if URL.mobile=1. If URL.mobile doesn't exist, determine from user agent string (detectmobilebrowsers.com).">
	<!---
	Note : 	The new mobile pages are designed with RWD in mind (Responsive Web Design) and can be viewed in desktop/tablet/mobile.
			The new mobile pages will eventually replace the old pages once it is stable.

				For testing, pass in the following flags :
				mobile = 0 Display desktop version
						 1 Display mobile version
					 2 Display responsive version
					 No mobile flag, display old version. (default for production/uat/pages not yet converted to mobile.)
	 --->
	<!--- <Cfif ListFindNoCase("DEV,UAT",Application.DB_MODE) GT 0> --->
		<cfif APPLICATION.appmode eq "CLAIMS" and isdefined("URL.mobile")>
			<cfif structKeyExists(URL,"mobile") and listfindnocase("1,2",URL.mobile) gt 0>
				<!--- this is to make testing easier on desktop browser --->
				<cfset request.mobile = URL.mobile>

				<!--- <cfif (isdefined("session.vars.orgtype") and session.vars.orgtype NEQ "P") or (isdefined("session.vars.locid") and session.vars.locid NEQ 11)>
					<cfset request.mobile = 0>
				</cfif> --->


			<!--- <cfelseif reFindNoCase("(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino",CGI.HTTP_USER_AGENT) GT 0 OR reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-",Left(CGI.HTTP_USER_AGENT,4)) GT 0>
				<!--- this is based on http://detectmobilebrowsers.com/ can be completely removed since these pages are now responsive.--->
				<cfset request.mobile = 1>--->
			<!--- Will only set request.mobile = 2 after fixing all the ie bugs --->
			<!--- <cfelse>
				<cfset request.mobile = 2> --->
			</cfif>
		<cfelseif APPLICATION.appmode eq "EPL" and isdefined("URL.mobile") and ListFindNoCase("DEV",Application.DB_MODE) GT 0>
			<cfif structKeyExists(URL,"mobile") and listfindnocase("1,2",URL.mobile) gt 0>
				<!--- this is to make testing easier on desktop browser --->
				<cfset request.mobile = URL.mobile>
			</cfif>
		<cfelseif structKeyExists(URL,"fuseaction") and URL.fuseaction eq "dsp_docupload">
			<cfset request.mobile = 2>
		</cfif>
	<!--- </cfif> --->
</cffunction>

<CFSET Attributes.DS.FN.SVCDetectMobile=SVCDetectMobile>

<cffunction name="SVCBitAND" description="Evalute BIT AND between two big integer numbers" access="public" returntype="any" output="false">
	<cfargument name="m" required="true" type="string">
	<cfargument name="n" required="true" type="string">
	<cfset var bigInt = createObject('java', 'java.math.BigInteger')>
	<cfset var result1 = bigInt.init(0)>
	<cfset result1 = result1.valueOf(javaCast('long', m))>
	<cfset result1 = result1.AND(bigInt.valueOf(javaCast('long', n)))>
	<CFRETURN result1>
</cffunction>
<cfset Attributes.DS.FN.SVCBitAND=SVCBitAND>
<cffunction name="SVCWelcomeLastLogon" description="Evalute BIT AND between two big integer numbers" access="public" returntype="any" output="true">
	<cfargument name="LASTLOGON" required="false" default="" type="string">
	<cfargument name="PWDEXPIRYDAYS" required="false" default="" type="string">
	<cfoutput>
	<br>
	<div class="clsMRMLastLogon">
	<CFIF IsDefined("SESSION.VARS.USERNAME")>
		#Server.SVClang("Welcome, {0}.",3125,0,"<span>#HTMLEditFormat(SESSION.VARS.USERNAME)#</span>")#
	</CFIF>
	<cfif Arguments.LASTLOGON IS "">
		#Server.SVClang("This is your first login.",3126)#
	<cfelse>
		#Server.SVClang("You last logged-in on ",3127)#<span>#Arguments.LASTLOGON#</span>.
	</cfif><br>
	<CFIF IsNumeric(Arguments.PWDEXPIRYDAYS) AND Arguments.PWDEXPIRYDAYS LTE 14>
		<br><div align=center><div class="clsMRMLastLogonExpiry">#server.SVClang("Your password will expire in <b>{0}</b> days.",10811,0,"#Arguments.PWDEXPIRYDAYS#")#<br>#server.SVClang("Click",1573)# <input class=clsButton value="#server.SVClang("Change Password",4958)#" onclick="window.location.href='#request.webroot#index.cfm?fusebox=SVCsec&fuseaction=dsp_userprofile&REQCHGPWD=1&#request.mtoken#';"> #server.SVClang("to change your password now.",13010)#</div></div>
	</CFIF>
	</div>
	</cfoutput>
	<CFRETURN>
</cffunction>
<cfset Attributes.DS.FN.SVCWelcomeLastLogon=SVCWelcomeLastLogon>

<cffunction name="SVCGetCGIAttr" description="Extract parameters from CGI String Query" access="public" returntype="any" output="false">
	<cfargument name="queryString" required="true" type="string" hint="CGI.QUERY_STRING">
	<cfargument name="paramName" required="true" type="string" hint="Param name">

	<cfset paramStruct = StructNew()>
	<cfloop list="#queryString#" delimiters="&" index="i">
		<cfif ArrayLen(i.split('=')) GT 1>
			<cfif not structKeyExists(paramStruct,i.split("=")[1])>
				<cfset StructInsert(paramStruct, i.split("=")[1], i.split("=")[2])>
			</cfif>
		</cfif>
	</cfloop>
	<cfset result="">
	<cfif structKeyExists(paramStruct, paramName)>
		<cfset paramStruct[paramName]=Replace(paramStruct[paramName], "%2C", ",","all")>
		<cfset result=paramStruct[paramName]>
	</cfif>

	<CFRETURN result>
</cffunction>
<cfset Attributes.DS.FN.SVCGetCGIAttr=SVCGetCGIAttr>

<cffunction name="SVCRemoveCGIAttr" description="Remove parameters from CGI String Query (Return boolean)" access="public" returntype="boolean" output="false">
	<cfargument name="queryString" required="true" type="string" hint="CGI.QUERY_STRING">
	<cfargument name="paramName" required="true" type="string" hint="Param name">
	<cfset paramStruct = StructNew()>
	<cfloop list="#queryString#" delimiters="&" index="i">
		<cfif ArrayLen(i.split('=')) GT 1>
			<cfset StructInsert(paramStruct, i.split("=")[1], i.split("=")[2])>
		</cfif>
	</cfloop>

	<cfset result=false>
	<cfif structKeyExists(paramStruct, paramName)>
		<cfset paramStruct[paramName]=Replace(paramStruct[paramName], "&"&paramName&paramStruct[paramName], "","all")> <!--- &paramName=value --->
		<cfset result=true>
	</cfif>

	<CFRETURN result>
</cffunction>
<cfset Attributes.DS.FN.SVCRemoveCGIAttr=SVCRemoveCGIAttr>

<!---#17969--->
<cffunction name="SVCmthdiff" description="To replace the old SVCmthdiff" access="public" output="false" returntype="any">
	<cfargument name="dt1" required="true" hint="date 1 for month comparison. expect yyyy/mm/dd format which is passed in from MTRGetDepcr">
	<cfargument name="dt2" required="true" hint="date 2 for month comparison. expect yyyy/mm/dd format which is passed in from MTRGetDepcr">

	<cfset var mthdiff=0>

	<cfif (dt1 IS "" OR dt2 IS "")>
		<cfreturn -1>
	</cfif>
	<!--- <cfset mthdiff = DateDiff("m",dt1,dt2)> is buggy, use sql fDateDiff --->
	<cfquery name="q_getmdiff" datasource="#REQUEST.SVCDSN#">
		select diff = dbo.fDateDiff('m',<cfqueryparam CFSQLTYPE="cf_sql_timestamp" value="#dt1#">,<cfqueryparam CFSQLTYPE="cf_sql_timestamp" value="#dt2#">)
	</cfquery>

	<cfset mthdiff = q_getmdiff.diff>

	<cfif (mthdiff GT 0 AND Day(dt1) IS Day(dt2))>
		<cfset mthdiff=mthdiff-1>
	</cfif>

	<CFRETURN mthdiff>

</cffunction>
<cfset Attributes.DS.FN.SVCmthdiff=SVCmthdiff>

<cffunction access="public" name="SVCpadding" output=false>
    <cfargument name="tstring" required="true">
    <cfargument name="tlen" required="false" default=#len(arguments.tlen)#>
    <cfargument name="talign" required="false" default="L"> <!--- L:left, R:right --->
    <cfargument name="ttrunc" required="false" default="L"> <!--- L:left, R:right --->
    <cfargument name="tpad" required="false" default=#chr(48)#> <!--- 32:space, 48:0 --->
    <cfif arguments.ttrunc eq "R">
        <cfset arguments.tstring = right(arguments.tstring,tlen)>
    <cfelse>
        <cfset arguments.tstring = left(arguments.tstring,tlen)>
    </cfif>
    <cfset var padlen = arguments.tlen - len(arguments.tstring)>
    <cfset var padding = repeatstring(arguments.tpad,min(arguments.tlen,padlen))>
    <cfif arguments.talign eq "R">
        <cfset arguments.tstring = padding&arguments.tstring>
    <cfelse>
        <cfset arguments.tstring = arguments.tstring&padding>
    </cfif>
    <cfreturn arguments.tstring>
</cffunction>
<cfset Attributes.DS.FN.SVCpadding=SVCpadding>

<cffunction access="public" name="SVCdtDBtoLOCTimeFilter" output=false>
	<cfargument name="dbdatetime" type="any" required="true"><!--- Must be in DB time --->
	<cfargument name="locid" type="numeric" default=0>
	<cfargument name="displayEmptyTime" type="numeric" default=0>
	<cfset var returnval=structnew()>
	<cfset var dt=""><cfset var thedate="">
	<cfif dbdatetime NEQ "">
		<CFSET dt=request.ds.FN.SVCdtDBtoLOC(dbdatetime,locid,"STD","HH:MM:SS.LLL")>
		<cfset thedate=#Request.DS.FN.SVCdtDBtoLOC(dbdatetime,locid)#>
	</cfif>
	<CFSET var thetime="">
	<CFSET var thedt="">
	<CFIF Len(dt) GT 3>
		<cfif Right(dt,12) IS "00:00:01.000"><!--- blank time --->
			<CFIF displayEmptyTime IS 0>
				<CFSET thetime="">
			<CFELSE>
				<CFSET thetime=Mid(dt,Len(dt)-11,5)> <!--- display 00:00 --->
			</CFIF>
			<CFSET thedt="#thedate#">
		<cfelse>
			<CFSET thetime=Mid(dt,Len(dt)-11,5)>
			<cfif Right(dt,12) IS "00:00:00.000"><!--- exactly 00:00 --->
				<CFSET thedt="#thedate#">
			<cfelse>
				<CFSET thedt="#dt#">
			</cfif>
		</cfif>
	</cfif>
	<cfset returnval.date="#thedate#">
	<cfset returnval.time="#thetime#">
	<cfset returnval.dt="#thedt#">
	<cfreturn returnval>
</cffunction>
<cfset Attributes.DS.FN.SVCdtDBtoLOCTimeFilter=SVCdtDBtoLOCTimeFilter>

<cffunction access="public" name="SVCGetResp" output=false>
	<cfif StructKeyExists(request,"mobile") and request.mobile eq 2>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>
<cfset Attributes.DS.FN.SVCGetResp=SVCGetResp>


<!--- proposed recipe:
<cfquery name="qry_members" result="rs_members" datasource="claims_dev"> ... </cfquery>

<cfset a = SVCQueryToArray(qry_groups,rs_groups)>
<cfset b = serializeJson(a)>

example result:
[
    {"GROUPNAME":"Front Panel","GROUPCODE":10000000}
    ,{"GROUPNAME":"Bonnet & Engine","GROUPCODE":20000000},...
]
--->
<cffunction access="public" name="SVCQueryToArray" returntype="array" output=false
    description="converts query into array of structures, for further serialising">

    <cfargument name="q" type="query" required="true" description="query name">
    <cfargument name="cols" type="string" required="false" description="" default="">
    <cfset var total = []>

    <cfloop index="i" from="1" to="#arguments.q.recordCount#" step="1">
        <cfset var temp = {}>
        <cfloop list=#arguments.q.columnlist# index="item" delimiters=",">
            <cfset thecol = arguments.q[item][i]>

            <cfset ignore = false>
            <cfif len(arguments.cols) gt 0>
                <cfset ignore = listfindnocase(arguments.cols,item) eq 0>
            </cfif>

            <cfif not ignore>
                <cfset temp[item] = thecol>
            </cfif>
        </cfloop>
        <cfset arrayAppend(total,temp)>
    </cfloop>
    <cfreturn total>
</cffunction>
<cfset Attributes.DS.FN.svcquerytoarray=svcquerytoarray>

<cffunction access="public" name="SVCPrepareJson" returntype="void" output=true description="">
    <cfargument name="rdata" type="any" required="false">

    <cfset var empty = {}>
    <cfset empty.statuscode = 204>
    <cfset empty.statustext = "No content/ records">

    <cfset var good = {}>
    <cfset good.statuscode = 200>
    <cfset good.statustext = "Success">

    <cfset var json = "">
    <cfif (isArray(arguments.rdata) and arrayLen(arguments.rdata) gt 0)
        or (isStruct(arguments.rdata) and not structIsEmpty(arguments.rdata))
        or (isQuery(arguments.rdata) and arguments.rdata.recordcount gt 0 )
        or (isValid("string",arguments.rdata) and len(arguments.rdata) gt 0 )>

        <cfset var json = serializeJSON(arguments.rdata)>
    </cfif>

    <cfif len(json) gt 0>
        <cfset var target = good>
    <cfelse>
        <cfset var target = empty>
    </cfif>

    <cfheader statuscode="#target.statuscode#" statustext="#target.statustext#" />
    <cfcontent reset=yes type="application/json" variable="#tobinary(toBase64(json))#">
</cffunction>

<cfset Attributes.DS.FN.SVCPrepareJson=SVCPrepareJson>


<cffunction name="SVCHTMLTOIMAGE">
	<cfargument name="html" hint="htmlto generate to image" default="">
	<cfargument name="domainid" hint="domainid" default="1" required="true">
	<cfargument name="objid" hint="objid" default="0" required="true">
	<cfargument name="docdefid" hint="docdefid" default="0" required="true">
	<cfargument name="img" hint="image when html is empty. just use this one" default="" required="false">
	<cfargument name="docid" hint="docid to use for image store" default="" required="false">

	<cfset var returnedError = "">
	<cfset var fname = "">
	<cfset var tmphtmlpath = "">
	<cfset var tmpimagepath = "">
	<cfset var preserve = 1>
	<cfset var RET_POIDOCID = "">

	<CFIF arguments.html neq "">

		<cfif arguments.domainid eq 1>
			<cfset arguments.html = trim(request.ds.mtrfn.MtrReplaceImgPath(arguments.html))>
		</cfif>

		<!--- write html to temporary html file --->
		<cfset fname = createUUID()>

		<cfset tmphtmlpath = APPLICATION.TMPDIR & fname & ".HTML">
		<cfset tmpimagepath = APPLICATION.TMPDIR & fname & ".JPG">
		<cffile action="write" file="#tmphtmlpath#" output="#arguments.HTML#" charset="UTF-8">
		<CFEXECUTE NAME="#expandPath('#request.apppath#services\cfc\lib\wkhtmltopdf\wkhtmltoimage-0.12.2.3.exe')#" arguments="--crop-w 650 #tmphtmlpath# #tmpimagepath#" timeout="30" VARIABLE=outstr errorVariable="returnedError"></CFEXECUTE>
		<cfset preserve = 0>
	<CFELSE>
		<cfset tmpimagepath = arguments.img>
		<cfset preserve = 1>
	</CFIF>

	<CFMODULE template="#request.apppath#services/index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER FILEEXT="JPG"
       DOMAINID=#arguments.domainid# OBJID=#arguments.objid# CRTCOID=1 CRTCOROLE=0 DOCDEFID=#arguments.docdefid# DOCCLASSID=2 USID=1
       LINKID=#arguments.objid# DOCSTAT=1 COPYFILE="#tmpimagepath#"
       PICRESIZE=0 THUMBS=0 PRESERVE_ORIGINAL=#preserve# DOCID=#VAL(arguments.docid)#>

	<cfset RET_POIDOCID=MODRESULT.DOCID>

	<cffile action="delete" file="#tmphtmlpath#">

	<CFRETURN RET_POIDOCID>
</cffunction>
<cfset Attributes.DS.FN.SVCHTMLTOIMAGE=SVCHTMLTOIMAGE>


<cffunction access="public" name="SVCGetInsGCOID" output=false hint="get insurer gcoid (or whoever the customized framework setting is for) based on domain and object provided">
	<cfargument name="domainid" type="numeric" required="true" default="0">
	<cfargument name="objid" type="numeric" required="true" default="0">
	<cfset var gcoid = 0>
	<CFIF arguments.domainid eq 1>
		<cfquery name="q_getins" datasource="#Request.SVCDSN#">
			select icoid from trx0008 with (nolock) where icaseid=<cfqueryparam value="#val(arguments.objid)#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	<CFELSEIF arguments.domainid eq 201>
		<cfquery name="q_getins" datasource="#Request.SVCDSN#">
			select icoid=iicoid from pol4004 with (nolock) where ipolid=<cfqueryparam value="#val(arguments.objid)#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</CFIF>
	<CFIF isdefined('q_getins') and q_getins.recordCount gt 0 and val(q_getins.icoid) gt 0>
		<cfset gcoid = q_getins.icoid>
		<cfif structKeyExists(request.ds.co, gcoid)>
			<cfset gcoid = request.ds.co[gcoid].gcoid>
		</cfif>
	</CFIF>
	<cfreturn gcoid>
</cffunction>
<cfset Attributes.DS.FN.SVCGetInsGCOID=SVCGetInsGCOID>


<cffunction name="SVCGetLocalBank" hint="Retrieve list of local banks" returntype="query" output="false">
	<cfargument name="LOCID" required="true" type="numeric" displayname="Locale ID" hint="The current locale. <SYS0009.iLOCID>">
	<cfquery name="Local.q_bank" datasource="#Request.MTRDSN#">
	SELECT a.iCOID,a.vaCONAME, a.vaBANKSWIFTCODE,a.iPCOID,a.vaCOBRNAME,a.vaBRANCHCODE, c.vaLANGDATA
	FROM SEC0005 a WITH (NOLOCK)
		INNER JOIN SEC0001 b WITH (NOLOCK) ON b.vaUSID=a.aCRTBY
		LEFT JOIN FLNG0002 c WITH (NOLOCK) ON c.iOWNER_OBJID=a.iCOID
	WHERE a.siSTATUS=0 AND a.siCOTYPEID=7 AND a.iLOCID=<cfqueryparam cfsqltype="cf_sql_integer" value="#Arguments.LOCID#">
	<CFIF Arguments.LOCID IS 1>
		<!--- TEMP: Msia has too many redundant banks created by users --->
		AND b.iCOID=1 AND (a.iCOID IN (785,788,2218,789,790,791,794,795,796,799,802,803,801,798,805,2858,807,1051,2216,2863,3749,22782)
							OR a.dtCRTON>='2017-09-14')
	<CFELSE>
		AND b.iCOID=1
	</CFIF>
		ORDER BY a.vaCONAME
	</cfquery>
	<cfreturn Local.q_bank>
</cffunction>
<cfset Attributes.DS.FN.SVCGetLocalBank=SVCGetLocalBank>


<cffunction name="SVCFilterDocGroup" hint="Filter document groups in q_docs" output="false">
	<cfargument name="DOMAINID" required="true" default="1" hint="Domainid">
	<cfargument name="q_docs" required="true" hint="q_docs document query">
	<cfargument name="DOCGROUP" required="true" default="0" hint="ExtAttr : bitmask doc group setting">
	<!--- below parameters used in dsp_docmanage --->
	<cfargument name="SINGLEGRP" required="true" default="false" hint="indicate all groups within q_doc, or just a single group within q_doc">
	<cfargument name="GRPTYPE" required="true" default="0" hint="1:dynamic group, 2:fixed group">
	<cfargument name="GRPID" required="true" default="0" hint="iDEFGRPID or iFIXEDGRPID">
	<cfargument name="GROUPDATE" required="true" default="" hint="Grouping by date">
	<!--- end of dsp_docmanage parameters --->

	<cfset var frow = 0>
	<cfset var q_grpdocs = "">
	<cfset var BYGROUP = false>

	<cfif arguments.GRPTYPE GT 0 AND arguments.GRPID GT 0 AND BITAND(arguments.DOCGROUP,5) GT 0>
		<cfset BYGROUP = true>
	</cfif>

	<cfquery name="q_grpdocs" datasource="#Request.SVCDSN#">
		SELECT GRPID=ISNULL(def.iDEFID,c.iFIXEDGRPID),GRPTITLE = isNULL(def.vaGRPTITLE, c.vaDESC), DATEGRP = ISNULL(c.siDATEGROUP,0), EDITGRP=ISNULL(c.siEDITABLE,0), UIUPLOAD=isNULL(c.siUIUPLOAD,0),
				iDOCGRPID,grp.iDOCID
				,GRPTYPE=case when def.idefid>0 then 1 when c.ifixedgrpid>0 then 2 else 0 end
				,GRPORDER=isNULL(c.iGRPORDER,99999)
		FROM FDOC3003_GRP grp WITH (NOLOCK)
			LEFT JOIN FDOC3003_DEF def WITH (NOLOCK) ON def.iDEFID=grp.iDEFGRPID AND def.iOBJID = grp.iOBJID AND def.iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.GCOID#">  AND def.iDOMAINID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.DOMAINID#">  AND def.siSTATUS=0
			LEFT JOIN FDOC_FIXEDGRP c WITH (NOLOCK) on c.iFIXEDGRPID = grp.iFIXEDGRPID AND c.siSTATUS=0
			<CFIF BYGROUP AND GroupDate neq "">
				INNER JOIN FDOC3003 doc WITH (NOLOCK) on doc.idocid = grp.idocid
			</CFIF>
		WHERE grp.iOBJID=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.OBJID#">
		<cfif BitAnd(arguments.DOCGROUP,4) eq 0>AND grp.iFIXEDGRPID=0</cfif>
		<cfif BitAnd(arguments.DOCGROUP,1) eq 0>AND grp.iDEFGRPID=0</cfif>
		<CFIF BYGROUP>
			AND <cfif arguments.GRPTYPE eq 1>def.iDEFID<cfelse>c.iFIXEDGRPID</cfif> = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.GRPID#">
			<CFIF BYGROUP AND GroupDate neq "">
				AND CONVERT(DATE, doc.dtfinalon) = CONVERT(DATE,<cfqueryparam CFSQLTYPE="cf_sql_varchar" value="#GroupDate#">)
			</CFIF>
		</CFIF>
	</cfquery>

	<cfif q_grpdocs.recordCount gt 0 AND arguments.SINGLEGRP>
		<!--- Filter q_docs --->
		<cfquery name="q_docs" dbtype="query">
			select * from q_docs WHERE iDOCID <CFIF NOT BYGROUP>NOT </CFIF>IN (#valuelist(q_grpdocs.idocid)#)
		</cfquery>
	</CFIF>

	<!--- Patch in these values into q_docs so that we only need to maintain 1 q_docs output --->
	<cfset QueryAddColumn(q_docs, "GRPTITLE", "Varchar", ArrayNew(1))>
	<cfset QueryAddColumn(q_docs, "GRPORDER", "Integer",[0])>
	<cfset QueryAddColumn(q_docs, "DATEGRP", "Integer", [0])>
	<cfset QueryAddColumn(q_docs, "GRPID", "Integer", [0])>
	<cfset QueryAddColumn(q_docs, "GRPTYPE", "Integer", [0])>
	<cfset QueryAddColumn(q_docs, "GRPFINDATE", "Time", [0])>

	<cfloop query="q_docs">
		<cfset frow=q_grpdocs['IDOCID'].indexOf( JavaCast( "int", "#idocid#" ) )><cfset frow += 1>
		<cfif frow eq 0>
			<cfset QuerySetCell(q_docs, 'GRPORDER', 0, CurrentRow)>
			<cfset QuerySetCell(q_docs, 'DATEGRP', 0, CurrentRow)>
			<cfset QuerySetCell(q_docs, 'GRPID', 0, CurrentRow)>
            <cfset QuerySetCell(q_docs, 'GRPTYPE', 0, CurrentRow)>
            <cfset QuerySetCell(q_docs, "GRPFINDATE", 0, CurrentRow)>
		<cfelse>
			<cfset QuerySetCell(q_docs, 'GRPTITLE', q_grpdocs['GRPTITLE'][frow], CurrentRow)>
			<cfset QuerySetCell(q_docs, 'GRPORDER', q_grpdocs['GRPORDER'][frow], CurrentRow)>
			<cfset QuerySetCell(q_docs, 'DATEGRP', q_grpdocs['DATEGRP'][frow], CurrentRow)>
			<cfset QuerySetCell(q_docs, 'GRPID', q_grpdocs['GRPID'][frow], CurrentRow)>
			<cfset QuerySetCell(q_docs, 'GRPTYPE', q_grpdocs['GRPTYPE'][frow], CurrentRow)>

			<cfif q_grpdocs['DATEGRP'][frow] eq 1>
                <cfset QuerySetCell(q_docs, 'GRPFINDATE', q_docs.dtfinalon, CurrentRow)>
            <cfelse>
                <cfset QuerySetCell(q_docs, "GRPFINDATE", 0, CurrentRow)>
			</cfif>
		</cfif>

		<cfif q_docs.iorder eq "">
			<cfset q_docs.iorder = 99999>
		</cfif>
	</cfloop>

	<!--- order correctly --->
	<cfquery name="q_docs" dbtype="query">
		select * from q_docs ORDER BY GRPORDER,IORDER ASC,GRPFINDATE DESC,GRPTITLE,IDOCCLASSID DESC, ICRTCOSECPOS, iCRTCOID, <!--- IORDER, ---> DTFINALON, DTCRTON
	</cfquery>

	<cfreturn arguments.q_docs>
</cffunction>
<CFSET Attributes.DS.FN.SVCFilterDocGroup=SVCFilterDocGroup>


<cffunction name="SVCSanitizeForm" output="true">
	<cfargument name="sFORM" required="true" type="string" default=""><!--- deserialised value --->
	<cfset var THESTRUCT=#DeserializeJSON(sFORM)#>
	<cfloop collection=#THESTRUCT# item="key">
		<cfif NOT(isdefined("FORM.#key#"))>
			<cfset FORM[KEY]=#THESTRUCT[key]#>
		</cfif>
    </cfloop>
	<cfreturn>
</cffunction>
<CFSET Attributes.DS.FN.SVCSanitizeForm=SVCSanitizeForm>

<CFFUNCTION name="SVCValidateStruct" hint="validate required fields and datatype. Empty value will be assigend if field is not required">
	<CFARGUMENT name="POSTDATA" type="struct" required="true">
	<CFARGUMENT name="FIELDS" type="array" required="true">
	<CFARGUMENT name="LOCID" type="string" default="#Application.APPLOCID#">
	<CFARGUMENT name="CURHIER" type="string" default="">

	<CFLOOP array="#FIELDS#" index="FIELD">
		<CFSET var CURRENTFIELD=listAppend(CURHIER, FIELD.NAME, ".")>
		<CFSET var REQ=1>
		<CFIF isDefined("FIELD.REQ")>
			<CFSET var REQ=FIELD.REQ>
		</CFIF>

		<CFIF NOT isDefined("POSTDATA.#FIELD.NAME#")>
			<CFIF REQ IS 1>
				<CFTHROW TYPE="EX_SECFAILED" ErrorCode="VALERROR" ExtendedInfo="#CURRENTFIELD# is missing">
			<CFELSE>
				<CFIF FIELD.DATATYPE IS "STRUCT">
					<CFSET POSTDATA[FIELD.NAME]={}>
				<CFELSEIF FIELD.DATATYPE IS "ARRAY">
					<CFSET POSTDATA[FIELD.NAME]=[]>
				<CFELSE>
					<CFSET POSTDATA[FIELD.NAME]="">
				</CFIF>
			</CFIF>
		</CFIF>

		<CFSET var STATUS=1>

		<CFIF NOT (isStruct(POSTDATA[FIELD.NAME]) OR isArray(POSTDATA[FIELD.NAME])) AND POSTDATA[FIELD.NAME] IS NOT "">
			<CFIF FIELD.DATATYPE IS "NUMERIC">
				<CFSET STATUS=isNumeric(POSTDATA[FIELD.NAME])>
			<CFELSEIF FIELD.DATATYPE IS "DATE">
				<CFSET STATUS=isDate(POSTDATA[FIELD.NAME])>
				<CFSET POSTDATA[FIELD.NAME]=REQUEST.DS.FN.SVCdtLOCtoDB(POSTDATA[FIELD.NAME], LOCID, 'yyyy-mm-dd', 'HH:mm:ss')>
			<CFELSEIF FIELD.DATATYPE IS "BOOLEAN">
				<CFSET STATUS=isBoolean(POSTDATA[FIELD.NAME])>
			</CFIF>
		<CFELSE>
			<CFIF FIELD.DATATYPE IS "STRUCT">
				<CFSET STATUS=isStruct(POSTDATA[FIELD.NAME])>
			<CFELSEIF FIELD.DATATYPE IS "ARRAY">
				<CFSET STATUS=isArray(POSTDATA[FIELD.NAME])>
			</CFIF>
		</CFIF>

		<CFIF STATUS IS 0>
			<CFTHROW TYPE="EX_SECFAILED" ERRORCODE="VALERROR" EXTENDEDINFO="#CURRENTFIELD# requires datatype of #FIELD.DATATYPE#">
		</CFIF>

		<CFIF isStruct(POSTDATA[FIELD.NAME])>
			<CFIF (REQ IS 1 OR NOT structIsEmpty(POSTDATA[FIELD.NAME])) AND structKeyExists(FIELD, "FIELDS")>
				<CFSET REQUEST.DS.FN.SVCValidateStruct(POSTDATA[FIELD.NAME], FIELD.FIELDS, LOCID, CURRENTFIELD)>
			</CFIF>
		<CFELSEIF isArray(POSTDATA[FIELD.NAME])>
			<CFIF structKeyExists(FIELD, "FIELDS")>
				<CFSET var COUNTER=0>
				<CFSET var ARRAYFILEDS=FIELD.FIELDS>
				<CFSET var FILEDNAME=FIELD.NAME>

				<CFLOOP array="#POSTDATA[FIELD.NAME]#" index="ITM">
					<CFSET REQUEST.DS.FN.SVCValidateStruct(ITM, ARRAYFILEDS, LOCID, listAppend(CURHIER, FILEDNAME&"[#COUNTER#]", "."))>
					<CFSET COUNTER=COUNTER+1>
				</CFLOOP>
			</CFIF>
		<CFELSEIF REQ IS 1 AND POSTDATA[FIELD.NAME] IS "">
			<CFTHROW TYPE="EX_SECFAILED" ErrorCode="VALERROR" ExtendedInfo="#CURHIER#.#FIELD.NAME# is required">
		</CFIF>
	</CFLOOP>
</CFFUNCTION>
<CFSET Attributes.DS.FN.SVCValidateStruct=SVCValidateStruct>

<CFFUNCTION name="SVCGenToken" hint="">
	<CFARGUMENT name="EXPMINS" type="numeric" required="false" default="60">
	<CFARGUMENT name="PAYLOAD" type="struct" required="false" default="#StructNew()#">

	<CFSET FINALPAYLOAD={
		ID= insert("-", CreateUUID(), 23),
		ISSDT= dateTimeFormat(now(), 'yyyy-mm-dd HH:nn:ss'),
		EXPDT= dateTimeFormat(dateAdd('n', ARGUMENTS.EXPMINS, now()), 'yyyy-mm-dd HH:nn:ss'),
		ENV= Application.DB_COUNTRY&"-"&Application.DB_MODE
	}>

	<CFIF NOT StructIsEmpty(ARGUMENTS.PAYLOAD)>
		<CFLOOP collection="#ARGUMENTS.PAYLOAD#" item="KEY">
			<CFSET FINALPAYLOAD[KEY]=PAYLOAD[KEY]>
		</CFLOOP>
	</CFIF>

	<CFSET FINALPAYLOAD.HASH=hash(serializeJSON(FINALPAYLOAD)&'sIYFp'&hash(FINALPAYLOAD.ID)&'o0*^D', 'SHA-256')>

	<CFRETURN toBase64(serializeJSON(FINALPAYLOAD))>
</CFFUNCTION>
<CFSET Attributes.DS.FN.SVCGenToken=SVCGenToken>

<CFFUNCTION name="SVCValToken" hint="">
	<CFARGUMENT name="TOKEN" type="string" required="true">
	<CFARGUMENT name="CHKDUPLICATE" type="boolean" required="false" default="1">

	<CFSET JSON=ToString(ToBinary(ARGUMENTS.TOKEN))>

	<CFIF NOT isJSON(JSON)>
		<CFTHROW type="EX_SECFAILED" errorcode="AUTHERR" extendedinfo="Invalid token">
	</CFIF>

	<CFSET PAYLOAD=deserializeJSON(JSON)>
	<CFSET PAYLOADHASH=PAYLOAD.HASH>
	<CFSET PAYLOAD.ENV=Application.DB_COUNTRY&"-"&Application.DB_MODE>
	<CFSET structDelete(PAYLOAD, "HASH")>
	<CFSET ACTUALHASH=hash(serializeJSON(PAYLOAD)&'sIYFp'&hash(PAYLOAD.ID)&'o0*^D', 'SHA-256')>

	<CFIF PAYLOADHASH IS NOT ACTUALHASH>
		<CFTHROW type="EX_SECFAILED" errorcode="AUTHERR" extendedinfo="Invalid token">
	<CFELSEIF PAYLOAD.EXPDT LT now()>
		<CFTHROW type="EX_SECFAILED" errorcode="AUTHERR" extendedinfo="Token expired">
	</CFIF>

	<CFIF ARGUMENTS.CHKDUPLICATE>
		<CFTRY>
			<CFSET structInsert(FORM, "FORMGUID", PAYLOAD.ID, true) >
			<CFMODULE TEMPLATE="#request.apppath#services\CustomTags\SVCchkguid.cfm" REQUIRED>

			<CFCATCH>
				<CFIF CFCATCH.ErrorCode IS "RESUBMIT">
					<CFTHROW type="EX_SECFAILED" errorcode="AUTHERR" extendedinfo="Token has been reused">
				<CFELSE>
					<CFRETHROW>
				</CFIF>
			</CFCATCH>
		</CFTRY>
	</CFIF>

	<CFRETURN PAYLOAD>
</CFFUNCTION>
<CFSET Attributes.DS.FN.SVCValToken=SVCValToken>

<cffunction name="SVCChk2FA" hint="Check for 2FA">
	<cfif StructKeyExists(session.vars,"SECURITYFLAG") AND ListFind("I,R,A,G,L,RG,P",SESSION.VARS.ORGTYPE) AND
	(
		LISTFIND("PROD",APPLICATION.DB_MODE)
		OR (LISTFIND("UAT",APPLICATION.DB_MODE) AND SESSION.VARS.ORGTYPE IS "I" AND NOT ListFind("200002,203977",SESSION.VARS.ORGID))
		OR (LISTFIND("TRAIN",APPLICATION.DB_MODE) AND SESSION.VARS.ORGID IS 200036)
	)>
		<CFIF (NOT StructKeyExists(session.vars,"LOGIN2FA") or (StructKeyExists(session.vars,"LOGIN2FA") and session.vars.LOGIN2FA eq "")) and attributes.fuseaction neq "dsp_2FAvalidation">
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCurlback.cfm" NEW>

			<CFLOCATION URL="#request.webroot#index.cfm?fusebox=MTRgia&fuseaction=dsp_2FAvalidation&#newurlback#&#Request.MToken#" ADDTOKEN="no">
		</CFIF>
	</cfif>
	<cfreturn true>
</cffunction>
<CFSET  Attributes.DS.FN.SVCChk2FA=SVCChk2FA>

<cffunction name="SVCQueryAppend" access="public" returntype="void" output="true" hint="This takes two queries and appends the second one to the first one. This actually updates the first query and does not return anything.">
    <cfargument name="QueryOne" type="query" required="true">
    <cfargument name="QueryTwo" type="query" required="true">
    <cfargument name="EmptyAsNull" default="" required="false">
    <cfargument name="OrderClause" type="string" required="false" default="">
	<cfargument name="max" type="numeric" required="false" default="200">

	<cfset var LOCAL = StructNew()>
    <cfset LOCAL.Columns = ListToArray(ARGUMENTS.QueryOne.ColumnList)>
    <cfset LOCAL.EmptyAsNull = 0>
	<cfset LOCAL.q_trx = QueryNew("")>
	<cfset var CombinedQuery = Duplicate(Arguments.QueryOne)>

    <cfif isValid("boolean", ARGUMENTS.EmptyAsNull) AND ARGUMENTS.EmptyAsNull>
        <cfset LOCAL.EmptyAsNull = 1>
    </cfif>

    <cfloop query="ARGUMENTS.QueryTwo">
        <cfset QueryAddRow(CombinedQuery)>
        <cfloop ARRAY="#LOCAL.Columns#" index="LOCAL.ColumnName">
            <cfif StructKeyExists(ARGUMENTS.QueryTwo, LOCAL.ColumnName) AND (NOT LOCAL.EmptyAsNull OR LEN(ARGUMENTS.QueryTwo[LOCAL.ColumnName][ARGUMENTS.QueryTwo.CurrentRow]))>
                <cfset CombinedQuery[LOCAL.ColumnName][CombinedQuery.RecordCount] = ARGUMENTS.QueryTwo[LOCAL.ColumnName][ARGUMENTS.QueryTwo.CurrentRow]>
            </cfif>
        </cfloop>
    </cfloop>

    <CFQUERY name="LOCAL.q_trx" dbtype="query" maxRows="#Arguments.max#">
      select * from CombinedQuery <!--- @CFIGNORESQL_S --->#OrderClause#<!--- @CFIGNORESQL_E --->
    </CFQUERY>

    <cfloop from=1 to=#MIN(Arguments.max,CombinedQuery.recordCount)# index=j>
		<CFIF j gt ARGUMENTS.QueryOne.recordCount>
			<cfset QueryAddRow(ARGUMENTS.QueryOne)>
		</CFIF>
		<cfloop ARRAY="#LOCAL.Columns#" index="LOCAL.ColumnName">
			<cfset ARGUMENTS.QueryOne[LOCAL.ColumnName][j] = LOCAL.q_trx[LOCAL.ColumnName][j]>
		</cfloop>
    </cfloop>
    <cfreturn>
</cffunction>
<CFSET Attributes.DS.FN.SVCQueryAppend=SVCQueryAppend>


<cffunction name="SVCGetPDFGenType" hint="Get PDF Generation Type">
	<CFARGUMENT name="DOCID" type="numeric" default=0>

	<cfset PDFGENTYPE="">

	<!--- FDOC3008.siPDFGENTYPE - NULL/0/'':cfdocument ; 1:wkhtml ; 2:puppeteer --->
	<!--- For EPL incase EPL need it, CLAIMS define at doc\index.cfc --->
	<!--- For CLAIMS only, EPL defined at cfc\EPLGENPDF.cfc --->

	<CFIF ARGUMENTS.DOCID GT 0>
		<cfquery name="q_getPDFGENTYPE" datasource="#REQUEST.SVCDSN#">
			select pdfGenType=IsNull(siPDFGENTYPE,0)
			from FDOC3003 a WITH (NOLOCK) LEFT JOIN
			FDOC3008 b with (NOLOCK) ON a.iDOCDEFID=b.iDOCDEFID AND a.iCRTCOID=b.iCOID and a.iDOMAINID=b.iDOMAINID and b.sistatus=0
			where a.idocid=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.DOCID#">
		</cfquery>

		<CFIF q_getPDFGENTYPE.recordCount eq 1>
			<CFIF q_getPDFGENTYPE.pdfGenType eq 1>
				<cfset PDFGENTYPE="wkhtml">
			<CFELSEIF q_getPDFGENTYPE.pdfGenType eq 2>
				<cfset PDFGENTYPE="puppeteer">
			</CFIF>
		</CFIF>
	</CFIF>

	<CFRETURN PDFGENTYPE>
</cffunction>
<CFSET  Attributes.DS.FN.SVCGetPDFGenType=SVCGetPDFGenType>
