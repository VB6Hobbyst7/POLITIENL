B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Dim parser As JSONParser
	
End Sub

Public Sub Initialize
	
End Sub

Sub GetLocalNewsHeadlines As ResumableSub
	Private lst As List
	Private jsonData, data As String
	Private strLocalNewsUrl As String
	Private latitude As Double, longtitude As Double
	Private job As HttpJob
	
	latitude = GenFunctions.stationData.latitude
	longtitude = GenFunctions.stationData.longtitude
	strLocalNewsUrl = $"https://api.politie.nl/v4/nieuws/lokaal?language=nl&lat=${latitude}&lon=${longtitude}&radius=5.0&maxnumberofitems=10&offset=0"$
	
	job.Initialize("", Me)
	job.Download(strLocalNewsUrl)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		data = job.GetString
	End If
	job.Release
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
		Dim publicatiedatum As String = colnieuwsberichten.Get("publicatiedatum")
		Dim alineas As List = colnieuwsberichten.Get("alineas")
		For Each colalineas As Map In alineas
			Dim coltitel As String = colalineas.Get("titel")
			Dim alineatype As String = colalineas.Get("alineatype")
			Dim opgemaaktetekst As String = colalineas.Get("opgemaaktetekst")
			Dim bestanden As String = colalineas.Get("bestanden")
		Next
		Dim gebied As String = colnieuwsberichten.Get("gebied")
		Dim displayName As String = colnieuwsberichten.Get("displayName")
		Dim locaties As List = colnieuwsberichten.Get("locaties")
		For Each collocaties As Map In locaties
			Dim latitude As Double = collocaties.Get("latitude")
			Dim longitude As Double = collocaties.Get("longitude")
		Next
		Dim colnieuwsurl As String = colnieuwsberichten.Get("url")
		Dim uid As String = colnieuwsberichten.Get("uid")
		Dim colnewstitel As String = colnieuwsberichten.Get("titel")
		Dim introductie As String = colnieuwsberichten.Get("introductie")
		Dim afbeelding As Map = colnieuwsberichten.Get("afbeelding")
		Dim alttext As String = afbeelding.Get("alttext")
		Dim url As String = afbeelding.Get("url")
		Dim links As String = colnieuwsberichten.Get("links")
		Dim availabletranslations As String = colnieuwsberichten.Get("availabletranslations")
		Dim uidtipformulier As String = colnieuwsberichten.Get("uidtipformulier")
		Dim urltipformulier As String = colnieuwsberichten.Get("urltipformulier")
		
'		Log($"PUB DATE : ${GenFunctions.ParseStringDate(publicatiedatum)}"$)
'		Log(colnieuwsurl)
'		Log($"GEBIED : ${gebied}"$)
'		Log($"TITEL : ${colnewstitel}"$)
		lst.Add(CreatelocalNewsHeadline(gebied, GenFunctions.ParseStringDate(publicatiedatum), colnewstitel, uid, colnieuwsurl))
	Next
	
	Return lst
End Sub

Public Sub CreatelocalNewsHeadline (area As String, pubDate As String, title As String, uid As String, newsUrl As String) As localNewsHeadline
	Dim t1 As localNewsHeadline
	t1.Initialize
	t1.area = area
	t1.pubDate = pubDate
	t1.title = title
	t1.uid = uid
	t1.newsUrl = newsUrl
	Return t1
End Sub

