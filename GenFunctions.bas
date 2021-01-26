B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10.2
@EndOfDesignText@
Sub Process_Globals
	Dim stationData As station
	Private access As Accessibility
	Private xui As XUI

End Sub

Sub UUIDv4 As String 'ignore
	Dim sb As StringBuilder
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			If sb.Length = 19 Then c = Asc("8")
			If sb.Length = 14 Then c = Asc("4")
			sb.Append(Chr(c))
		Next
	Next
	Return sb.ToString.ToLowerCase
End Sub

Sub createCustomToast(txt As String, color As String)
	Dim cs As CSBuilder
	cs.Initialize.Typeface(Typeface.LoadFromAssets("Arial.ttf")).Color(Colors.White).Size(16).Append(txt).PopAll
	ShowCustomToast(cs, False, color)
End Sub

Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	'uncomment to show toast in the center:
	'  toast.RunMethod("setGravity", Array( _
	' Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
End Sub

Sub OpenUrl(url As String)
	Dim i As Intent
	i.Initialize(i.ACTION_VIEW, url)
	StartActivity(i)
End Sub

Sub ParseStringDate(strDate As String, dtf As String) As String
	If strDate = "" Then
		Return "onbekend"
	End If
	
	Dim dateStr() As String '= Regex.Split(" ", strDate)
	Dim dateAsString, timeAsString As String
	Dim parsedDate As Long
	
	If strDate.IndexOf(" ") = -1 Then
		strDate = $"${strDate} 00:00:00"$
	End If
	
	dateStr = Regex.Split(" ", strDate)
	
	dateAsString = dateStr(0)
	timeAsString = dateStr(1)
	
	DateTime.DateFormat = "yy-MM-dd"
	parsedDate = DateTime.DateParse(dateAsString)
	'DateTime.DateFormat = "dd MMMM yyyy"
	DateTime.DateFormat = "dd-MM-yyyy"
	If dtf = "d" Then
		Return $"$Date{parsedDate}"$
	Else If dtf = "t" Then
		Return $"${timeAsString.SubString2(0,5)}"$
	Else
		Return $"$Date{parsedDate} ${timeAsString.SubString2(0,5)}"$
	End If
End Sub

Sub ResetUserFontScale(p As Panel)
	For Each v As View In p
		If v Is Panel Then
			ResetUserFontScale(v)
		Else If v Is Label Then
			Dim lbl As Label = v
			lbl.TextSize = lbl.TextSize / access.GetUserFontScale
		Else If v Is Spinner Then
			Dim s As Spinner = v
			s.TextSize = s.TextSize / access.GetUserFontScale
		End If
	Next
End Sub

Sub ShowLocationOnGoogleMaps(lat As Double, lon As Double)
	Dim gMapIntent As Intent
	Dim uri As String
	
	uri = $"geo:${lat}, ${lon}?q=${lat}, ${lon},18z/data=!5m1!1e1"$
	'uri = $"${lat},${lon},18z/data=!5m1!1e1"$
	
	gMapIntent.Initialize(gMapIntent.ACTION_VIEW,uri)
	gMapIntent.SetComponent("googlemaps")
	StartActivity(gMapIntent)
End Sub

Sub ParseHtmlTextBlock(alTitle As String, alTextBlock As String, color As String, imageUrl As String) As String
'	If imageUrl.Length > 6 Then
'		Log(imageUrl)
'	End If
	
	Dim newText As String = alTextBlock
	newText = newText.Replace("[", "(")
	newText = newText.Replace("]", ")")
	If alTitle <> "" Then
		alTitle = alTitle.Replace("[", "(")
		alTitle = alTitle.Replace("]", ")")
		If imageUrl.Length > 6 Then
			alTitle = $"[alignment=left][img url=${imageUrl} width = 150, height=200/][/alignment]${CRLF}[Alignment=Center][url=${imageUrl}][color=#ffff00]Vergroot[/color][/url][/Alignment]${CRLF}${alTitle}"$
		End If
	Else if imageUrl <> "" Then
		alTitle = $"[img url=${imageUrl} width = 150, height=200/]${CRLF}[Alignment=Center][url=${imageUrl}][color=#ffff00]Vergroot[/color][/url][/Alignment]${CRLF}"$
	End If

	Try
		newText = newText.Replace($"align="bottom""$, "")
		newText = newText.Replace("<p><sup><em>Stockfoto politie</em></sup></p>", "")
		newText = newText.Replace("<p><em>Foto ter illustratie.</em></p>", "")
	
		newText = GetAHref(newText)
		newText = newText.Replace(CRLF, "")
		If color <> "" Then
			newText = $"${color}${alTitle}[/color]${CRLF}${newText}"$
		Else
			newText = $"${alTitle}${CRLF}${newText}"$
		End If
		newText = newText.Replace("<p>", "") ' & alTextBlock.Replace("<p>", "")
		newText = newText.Replace("<HR>", "") ' & alTextBlock.Replace("<p>", "")
		newText = newText.Replace("</p>", CRLF)
		newText = newText.Replace("<br />\n", CRLF)
		newText = newText.Replace("<br/>", CRLF)
		newText = newText.Replace("<br />", CRLF)
'		newText = newText.Replace("<br />", "")
		newText = newText.Replace("&nbsp;", " ")
		newText = newText.Replace("<strong>", "")'"[b]")
		newText = newText.Replace("</strong>", "")'"[/b]")
		newText = GetHtmlTextBlockList(newText)
		newText = newText.Replace("<li>", "[*]")
		newText = newText.Replace("</li>", "")
		newText = newText.Replace("</u>", "")
		newText = newText.Replace("<u>", "")
		newText = newText.Replace("</i>", "")
		newText = newText.Replace("<i>", "")
		newText = newText.Replace("</ul>", "[/list]")
		newText = newText.Replace("\n", CRLF)
		newText = newText.Replace("<br />", CRLF)
		newText = newText.Replace("<em>", "[u]")'"[b][u]")
		newText = newText.Replace("</em>", "[/u]") '"[/u][/b]")
		newText = newText.Replace("<b>", "")'"[b]")
		newText = newText.Replace("</b>", "")'"[/b]")
		newText = newText.Replace($"-&gt;"$, "")
'		newText = ConvertTable(newText)
		newText = GetImageFromText(newText)
		newText = GetHeaderStyle(newText)
		newText = GetSupTag(newText)
	Catch
'		Log(LastException)
		newText = "Kan bericht niet openen"
	End Try
	Return newText
End Sub

Sub GetHtmlTextBlockList(alTextBlock As String) As String
	Dim startPosList, endPosList As Int
	Dim ulString As String
	
	startPosList = alTextBlock.IndexOf("<ul")
	If startPosList = -1 Then
		Return alTextBlock
	End If
	
	'ZOEK DE EERST VOLGEND > VANAF DE STARTPOSLIST
	For i = startPosList To alTextBlock.Length-1
		
		If alTextBlock.SubString2(i, i+1) = ">" Then
			endPosList = i+1
			ulString = alTextBlock.SubString2(startPosList, endPosList)
			Exit
		End If
	Next
	

	Return alTextBlock.Replace(ulString, "[list]")
		
End Sub

Sub GetAHref(alTextBlock As String) As String
	Dim startPosList, endPosList As Int
	Dim ahrefString, endAhRefTag, startARefTag, url, linkTitle As String
	Dim changedText As String
	
	startARefTag = "<a href"
	endAhRefTag = "</a>"
	
	startPosList = alTextBlock.IndexOf(startARefTag)
	endPosList = alTextBlock.IndexOf(endAhRefTag)

	If startPosList = -1 Then
		Return alTextBlock
	End If
	
	ahrefString = alTextBlock.SubString2(startPosList, endPosList+endAhRefTag.Length)
	
	'GET URL BETWEEN THE 2 "
	startPosList = ahrefString.IndexOf($"""$)
	For i = startPosList+1 To ahrefString.Length - 1
		If ahrefString.SubString2(i, i+1) = $"""$ Then
			url = ahrefString.SubString2(startPosList, i+1)
			Exit
		End If
	Next
	
	
	startPosList = ahrefString.IndexOf($">"$)
	
	For i = startPosList+2 To ahrefString.Length - 1
		If ahrefString.SubString2(i, i+1) = $"<"$ Then
			linkTitle = ahrefString.SubString2(startPosList+1, i)
			Exit
		End If
	Next
	
	'GET COMPLETE URL START END
	If ahrefString.IndexOf("bronRegistratie") <> -1 Then
		ahrefString = ""
	Else
		changedText = alTextBlock.Replace(ahrefString, $"${CRLF}[url=${url}][Color=#ffff00]${linkTitle}[/color][/url]"$)
	End If
	
	'FIND MORE <a href
	If changedText.IndexOf(startARefTag) <> -1 Then
		Return GetAHref(changedText)
	End If

	Return changedText

End Sub

Sub GetImageFromText(alTextBlock As String) As String
	Try
	
	
	Dim startPosList, endPosList As Int
	Dim imgText, imgTextNew As String
	
	startPosList = alTextBlock.IndexOf("<img")
	If startPosList = - 1 Then
		Return alTextBlock
	End If
	
	endPosList = alTextBlock.IndexOf(" />")+3
	imgText = alTextBlock.SubString2(startPosList, endPosList)
	
	For i = imgText.IndexOf($"""$)+1 To imgText.Length -1
		If imgText.SubString2(i, i+1) = $"""$ Then
			endPosList = i+1
			imgTextNew = imgText.SubString2(imgText.IndexOf($"""$), endPosList)
			Exit
		End If
	Next
	If imgTextNew.IndexOf("http") = -1 Then
			imgTextNew = $"https://www.politie.nl${imgTextNew.Replace($"""$, "")}"$
	End If
	
	imgTextNew.Replace($" "$, "")
'	Dim bbString As String = $"[alignment=Left][img url=${imgTextNew.Trim} width = 150, height=200/][/alignment]${CRLF}${imgTextNew}"$
		Dim bbString As String = $"[img url=${imgTextNew.Trim} width = 150, height=200/]${CRLF}[Alignment=Center][url=${imgTextNew}][color=#ffff00]Vergroot[/color][/url][/Alignment]${CRLF}"$
	
	
	alTextBlock =alTextBlock.Replace(imgText, bbString)
	
	If alTextBlock.IndexOf("<img") <> -1 Then
		Return GetImageFromText(alTextBlock)
		End If
		
	Catch
		Log(LastException)
	End Try
	Return alTextBlock
	
End Sub

Sub GetHeaderStyle(alTextBlock As String) As String
	Dim startHeader As Int = alTextBlock.ToLowerCase.IndexOf("<h")
	Dim endHeader As Int
	Dim newText, header As String
	
	If startHeader = -1 Then
		Return alTextBlock
	End If
	
	endHeader = alTextBlock.ToLowerCase.IndexOf(">")
	
	If endHeader < startHeader Then
		Return alTextBlock
	End If
	header = alTextBlock.SubString2(startHeader, endHeader+1)
	newText = alTextBlock.Replace(header, "")
	'GET END TAG
	
	startHeader = newText.IndexOf("</h")
	endHeader = startHeader+5
	header = newText.SubString2(startHeader, endHeader)
	newText = newText.Replace(header, "")
	
	If newText.ToLowerCase.IndexOf("<h") > -1 Then
		Return GetHeaderStyle(newText)
	End If
	
	Return newText
End Sub

Sub GetSupTag(alTextBlock As String) As String
	Dim startTag,endTag As String
	Dim supText, newText As String
	
	startTag = alTextBlock.IndexOf("<sup>")
	
	If startTag = -1 Then
		Return alTextBlock
	End If
	
	endTag = alTextBlock.IndexOf("</sup>")
	supText = alTextBlock.SubString2(startTag, endTag+6)
	
	newText = alTextBlock.Replace(supText, "")
	
	If newText.IndexOf("<sup") > -1 Then
		Return GetSupTag(newText)
	End If
	
	Return newText
	
End Sub

'Private Sub ConvertTable(alTextBlock As String) As String
'	Dim tableStartPos, tableEndPos As Int
'	Dim replaceString, NewText As String
'	
'	tableStartPos = alTextBlock.ToLowerCase.IndexOf("<table")
'	If tableStartPos < 0 Then 
'		Return alTextBlock
'	End If
'	tableEndPos = alTextBlock.ToLowerCase.IndexOf(">")+1
'	Log($"${tableStartPos} > ${tableEndPos}"$)
'	
'	replaceString = alTextBlock.SubString2(tableStartPos, tableEndPos)
'	NewText = alTextBlock.Replace(replaceString, "[list]")
'	NewText = NewText.Replace($"<tbody>${CRLF}"$, "")
'	NewText = NewText.Replace($"<tr>${CRLF}"$, "")
'	NewText = NewText.Replace($"<td>${CRLF}"$, "")
'	Return NewText
'	
'	
'End Sub

Sub CreateRoundRectBitmap (Input As B4XBitmap, Radius As Float) As B4XBitmap
	Dim BorderColor As Int = xui.Color_Black
	Dim BorderWidth As Int = 4dip
	Dim c As B4XCanvas
	Dim xview As B4XView = xui.CreatePanel("")
	xview.SetLayoutAnimated(0, 0, 0, Input.Width, Input.Height)
	c.Initialize(xview)
	Dim path As B4XPath
	path.InitializeRoundedRect(c.TargetRect, Radius)
	c.ClipPath(path)
	c.DrawRect(c.TargetRect, BorderColor, True, BorderWidth) 'border
	c.RemoveClip
	Dim r As B4XRect
	r.Initialize(BorderWidth, BorderWidth, c.TargetRect.Width - BorderWidth, c.TargetRect.Height - BorderWidth)
	path.InitializeRoundedRect(r, Radius - 0.7 * BorderWidth)
	c.ClipPath(path)
	c.DrawBitmap(Input, r)
	c.RemoveClip
	c.Invalidate
	Dim res As B4XBitmap = c.CreateBitmap
	c.Release
	Return res
End Sub