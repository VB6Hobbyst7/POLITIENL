B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Dim parser As JSONParser
	Dim itemsOffset As Int = 0
End Sub

Public Sub Initialize
	
End Sub

Sub GetLocalNewsHeadlines As ResumableSub
	Private lst As List
	Private latitude As Double, longtitude As Double
'	
	latitude = GenFunctions.stationData.latitude
	longtitude = GenFunctions.stationData.longtitude
	
	Wait For (GetDataFromUrl(latitude, longtitude, Starter.localNewsOffset)) Complete (data As String)
	Wait For (GetDataFromUrl(latitude, longtitude, Starter.localNewsOffset+10)) Complete (moreData As String)
	
	'SHOW HIDE PREV/NEXT BUTTON
	If moreData.Length > 10 Then
		CallSubDelayed2(lokaalNieuws, "ShowHidePrevNextButton", True)
	Else
		CallSubDelayed2(lokaalNieuws, "ShowHidePrevNextButton", False)
	End If

	lst = ParseLocalNewsData(data)
	
	Return lst
End Sub

Private Sub ParseLocalNewsData(data As String) As List
	Dim lst As List
	Dim parser As JSONParser
	Dim root As Map
	
	parser.Initialize(data)
	lst.Initialize
	root = parser.NextObject
	
	Dim nieuwsberichten As List = root.Get("nieuwsberichten")
	For Each colnieuwsberichten As Map In nieuwsberichten
		Dim introductie As String = colnieuwsberichten.get("introductie")
		Dim publicatiedatum As String = colnieuwsberichten.Get("publicatiedatum")
		Dim gebied As String = colnieuwsberichten.Get("gebied")
		Dim colnieuwsurl As String = colnieuwsberichten.Get("url")
		Dim uid As String = colnieuwsberichten.Get("uid")
		Dim colnewstitel As String = colnieuwsberichten.Get("titel")
		Dim locaties As List = colnieuwsberichten.Get("locaties")
		For Each collocaties As Map In locaties
			Dim latitude As Double = collocaties.Get("latitude")
			Dim longitude As Double = collocaties.Get("longitude")
			Exit
		Next
		lst.Add(CreatelocalNewsHeadline(gebied, GenFunctions.ParseStringDate(publicatiedatum), colnewstitel, uid, colnieuwsurl, latitude, longitude, introductie))
	Next
	
	Return lst
End Sub

Public Sub CreatelocalNewsHeadline (area As String, pubDate As String, title As String, uid As String, newsUrl As String, latitude As Double, longtitude As Double, introductie As String) As localNewsHeadline
	Dim t1 As localNewsHeadline
	t1.Initialize
	t1.area = area
	t1.pubDate = pubDate
	t1.title = title
	t1.uid = uid
	t1.newsUrl = newsUrl
	t1.latitude = latitude
	t1.longtitude = longtitude
	t1.introduction = introductie
	Return t1
End Sub

Sub GetLocalNewsDetail(latitude As Double, longtitude As Double, uid As String) As ResumableSub
	Private latitude, longtitude As Double
	
	latitude = GenFunctions.stationData.latitude
	longtitude = GenFunctions.stationData.longtitude
	 
	Wait For (GetDataFromUrl(latitude, longtitude, Starter.localNewsOffset)) Complete (data As String)

	
	Return ParseLocalNewsDetail(data, uid)
End Sub

Private Sub GetDataFromUrl(latitude As Double, longtitude As Double, offset As Int) As ResumableSub
	Private job As HttpJob
	Dim strLocalNewsUrl, data As String
	
	strLocalNewsUrl = $"https://api.politie.nl/v4/nieuws/lokaal?language=nl&lat=${latitude}&lon=${longtitude}&radius=5.0&maxnumberofitems=10&offset=${offset}"$
	job.Initialize("", Me)
	job.Download(strLocalNewsUrl)
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		data = job.GetString
	Else
		data = "error"
	End If
	job.Release
	
	Return data
End Sub

Private Sub ParseLocalNewsDetail(data As String, uidNewsItem As String) As String 'ignore
	Dim parser As JSONParser
	Dim alineasText As String = ""
	Dim titleFound As Boolean
	
	parser.Initialize(data)
	
	Dim root As Map = parser.NextObject
	
	Dim nieuwsberichten As List = root.Get("nieuwsberichten")
	For Each colnieuwsberichten As Map In nieuwsberichten
'		Dim publicatiedatum As String = colnieuwsberichten.Get("publicatiedatum")
		Dim alineas As List = colnieuwsberichten.Get("alineas")

'		Dim gebied As String = colnieuwsberichten.Get("gebied")
'		Dim displayName As String = colnieuwsberichten.Get("displayName")
		Dim locaties As List = colnieuwsberichten.Get("locaties")
		For Each collocaties As Map In locaties
'			Dim latitude As Double = collocaties.Get("latitude")
'			Dim longitude As Double = collocaties.Get("longitude")
		Next
'		Dim url As String = colnieuwsberichten.Get("url")
		Dim uid As String = colnieuwsberichten.Get("uid")
		Dim coltitel As String = colnieuwsberichten.Get("titel")
'		Dim introductie As String = colnieuwsberichten.Get("introductie")
'		Dim afbeelding As Map = colnieuwsberichten.Get("afbeelding")
'		Dim alttext As String = afbeelding.Get("alttext")
'		Dim url As String = afbeelding.Get("url")
'		Dim links As String = colnieuwsberichten.Get("links")
'		Dim availabletranslations As String = colnieuwsberichten.Get("availabletranslations")
'		Dim uidtipformulier As String = colnieuwsberichten.Get("uidtipformulier")
'		Dim urltipformulier As String = colnieuwsberichten.Get("urltipformulier")
		
		If uid = uidNewsItem Then
			For Each colalineas As Map In alineas
				Dim al_titel As String = colalineas.Get("titel")
				Dim al_opgemaaktetekst As String = colalineas.Get("opgemaaktetekst")
				If al_opgemaaktetekst = "null" Or al_titel = "null" Then
					Continue
				End If
				alineasText = alineasText & GenFunctions.ParseHtmlTextBlock(al_titel.Replace(CRLF, ""), al_opgemaaktetekst)
				alineasText = alineasText & CRLF& CRLF
			Next
			If titleFound = False Then
				alineasText = $"[alignment=center][b]${coltitel}[/b][/alignment]${CRLF}${CRLF}${alineasText}"$
			End If
			
			Return alineasText
			Exit
		End If
	Next
	
End Sub

Private Sub CheckForMoreNewsItems
	
End Sub