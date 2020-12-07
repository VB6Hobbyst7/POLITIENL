B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Dim lstWijkAgent As List
	Private pnlInstagram As Panel
	Private lblInstagram As Label
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Public Sub GetWijkAgent(wijkAgentData As String) As List
	ParseWijkAgentJson(wijkAgentData)
	Return lstWijkAgent
End Sub

Public Sub ParseWijkAgentJson(wijkAgentData As String) As ResumableSub
	
	Dim parser As JSONParser
	Dim afbUrl As String
	
	lstWijkAgent.Initialize
	parser.Initialize(wijkAgentData)
	
	
	
	Dim root As Map = parser.NextObject
	
	Dim wijkagenten As List = root.Get("wijkagenten")
	For Each colwijkagenten As Map In wijkagenten
		Dim publicatiedatum As String = colwijkagenten.Get("publicatiedatum")
'		Dim displayName As String = colwijkagenten.Get("displayName")
'		Dim locaties As List = colwijkagenten.Get("locaties")
'		For Each collocaties As Map In locaties
'			Dim latitude As Double = collocaties.Get("latitude")
'			Dim longitude As Double = collocaties.Get("longitude")
'		Next
		Dim naam As String = colwijkagenten.Get("naam")
		Dim url As String = colwijkagenten.Get("url")
		Dim werkgebied As String = colwijkagenten.Get("werkgebied")
'		Dim uid As String = colwijkagenten.Get("uid")
		Dim twitter As Map = colwijkagenten.Get("twitter")
'		Dim accountnaam As String = twitter.Get("accountnaam")
		Dim twitterAccount As String = twitter.Get("list")
'		Dim title As String = twitter.Get("title")
		Dim facebookurl As String = colwijkagenten.Get("facebookurl")
'		Dim werkgebiedpolygoon As String = colwijkagenten.Get("werkgebiedpolygoon")
		Dim instagramurl As String = colwijkagenten.Get("instagramurl")
		Dim afbeelding As Map = colwijkagenten.Get("afbeelding")
'		Dim alttext As String = afbeelding.Get("alttext")
'		Dim url As String = afbeelding.Get("url")
'		Dim links As String = colwijkagenten.Get("links")
'		Dim telefoon As String = colwijkagenten.Get("telefoon")
'		Dim extrainformatie As String = colwijkagenten.Get("extrainformatie")
'		Dim availabletranslations As String = colwijkagenten.Get("availabletranslations")
		Log(facebookurl)
		Log (twitterAccount)		
		Log(instagramurl)
		afbUrl = afbeelding.Get("url")
		If afbUrl.Length > 10 Then
			wait for (GetAfbeelding(afbeelding.Get("url"))) Complete (img As Bitmap)
		'	If done Then
				lstWijkAgent.Add(CreatewijkAgent(naam, img, werkgebied, publicatiedatum, url, instagramurl, twitterAccount, facebookurl))
		'	End If
		End If
	Next
	Return lstWijkAgent
End Sub

Private Sub GetAfbeelding(afbeeldingUrl As String) As ResumableSub
	Dim job As HttpJob
	Dim bm As Bitmap
	
	job.Initialize("", Me)
	job.Download(afbeeldingUrl)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		bm = job.GetBitmapResize(150, 150, True)
		job.Release
	End If
	Return bm
End Sub

Public Sub CreatewijkAgent (naam As String, afbeelding As Bitmap, werkGebied As String, publicatieDatum As String, url As String, instagram As String, twitter As String, facebook As String) As wijkAgent
	Dim t1 As wijkAgent
	t1.Initialize
	t1.naam = naam
	t1.afbeelding = afbeelding
	t1.werkGebied = werkGebied
	t1.publicatieDatum = publicatieDatum
	t1.url = url
	t1.instagram = instagram
	t1.twitter = twitter
	t1.facebook = facebook
	Return t1
End Sub