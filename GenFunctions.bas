B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10.2
@EndOfDesignText@
Sub Process_Globals
	Dim stationData As station
	Private access As Accessibility

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

Sub ParseStringDate(strDate As String) As String
	Dim dateStr() As String = Regex.Split(" ", strDate)
	Dim dateAsString, timeAsString As String
	Dim parsedDate As Long
	
	dateAsString = dateStr(0)
	timeAsString = dateStr(1)
	
	DateTime.DateFormat = "yy-MM-dd"
	parsedDate = DateTime.DateParse(dateAsString)
	DateTime.DateFormat = "dd MMMM yyyy"
	Return $"$Date{parsedDate} ${timeAsString.SubString2(0,5)}"$
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
	
	gMapIntent.Initialize(gMapIntent.ACTION_VIEW,uri)
	gMapIntent.SetComponent("googlemaps")
	StartActivity(gMapIntent)
End Sub

Sub ParseHtmlTextBlock(alTitle As String, alTextBlock As String) As String
	Dim newText As String = alTextBlock
	
	If alTitle <> "" Then
		newText = newText & $"[b]${alTitle}[/b]${CRLF}"$
	End If
	
	newText = newText.Replace($"align="bottom""$, "")
	newText = GetAHref(newText)
	newText = newText.Replace("<p>", "") ' & alTextBlock.Replace("<p>", "")
	newText = newText.Replace("</p>", "")
	newText = newText.Replace("<br />\n", CRLF)
	newText = newText.Replace("&nbsp;", " ")
	newText = newText.Replace("<strong>", "[b]")
	newText = newText.Replace("</strong>", "[/b]")
	newText = GetHtmlTextBlockList(newText)
	newText = newText.Replace("<li>", "[*]")
	newText = newText.Replace("</li>", "")
	newText = newText.Replace("</ul>", "[/list]")
	newText = newText.Replace("\n", CRLF)
	newText = newText.Replace("<br />", CRLF)
	newText = newText.Replace("<em>", "[b][u]")
	newText = newText.Replace("</em>", "[/u][/b]")
	newText = newText.Replace("<b>", "[b]")
	newText = newText.Replace("</b>", "[/b]")
	newText = newText.Replace($"-&gt;"$, "")
	
	newText = GetImageFromText(newText)
	
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
	changedText = alTextBlock.Replace(ahrefString, $"${CRLF}[url=${url}]${linkTitle}[/url]"$)
	
	'FIND MORE <a href
	If changedText.IndexOf(startARefTag) <> -1 Then
		Return GetAHref(changedText)
	End If

	Return changedText

End Sub

Sub GetImageFromText(alTextBlock As String) As String
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
	If imgTextNew.IndexOf("http") = -1 Then Return alTextBlock
	
	imgTextNew.Replace($" "$, "")
	Dim bbString As String = $"[alignment=left][img url=${imgTextNew} width = 150, height=200/][/alignment]${CRLF}"$
	
	
	alTextBlock =alTextBlock.Replace(imgText, bbString)
	
	If alTextBlock.IndexOf("<img") <> -1 Then
		Return GetImageFromText(alTextBlock)
	End If
	
	Return alTextBlock
	
End Sub