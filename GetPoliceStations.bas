B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Dim parser As JSONParser
	Dim clsdb As dbFunctions
	Dim clsWijkAgent As ParseWijkAgent
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsdb.Initialize
	clsWijkAgent.Initialize
End Sub

Sub GetStationList As ResumableSub 'ignore
	Log($"$Time{DateTime.now} Start"$)
	Private psUrl As String = $"https://api.politie.nl/v4/politiebureaus/all?offset=0"$
	wait for (RetrieveStation(psUrl)) Complete (done As Boolean)
	wait for (RetrieveStation($"https://api.politie.nl/v4/politiebureaus/all?offset=100"$)) Complete (done As Boolean)
	wait for (RetrieveStation($"https://api.politie.nl/v4/politiebureaus/all?offset=200"$)) Complete (done As Boolean)
	wait for (RetrieveStation($"https://api.politie.nl/v4/politiebureaus/all?offset=300"$)) Complete (done As Boolean)
	wait for (RetrieveStation($"https://api.politie.nl/v4/politiebureaus/all?offset=400"$)) Complete (done As Boolean)
	Log($"$Time{DateTime.now} Done"$)
	Return True
End Sub

Private Sub RetrieveStation(url As String) As ResumableSub
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(url)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		wait for (ParsePsData(job.GetString)) Complete (done As Boolean)
		Return True
	End If
	Return True
End Sub

Private Sub ParsePsData(data As String) As ResumableSub
	Dim parser As JSONParser
	Dim lstPsBase, lstPsSocialMedia, lstPsAddress As List
	
	lstPsBase.Initialize
	lstPsSocialMedia.Initialize
	lstPsAddress.Initialize
	
	parser.Initialize(data)

	Dim root As Map = parser.NextObject
'	Dim iterator As Map = root.Get("iterator")
'	Dim last As String = iterator.Get("last")
'	Dim offset As Int = iterator.Get("offset")
	Dim politiebureaus As List = root.Get("politiebureaus")
	For Each colpolitiebureaus As Map In politiebureaus
'		Dim publicatiedatum As String = colpolitiebureaus.Get("publicatiedatum")
		Dim twitterurl As String = colpolitiebureaus.Get("twitterurl")
'		Dim openingstijden As String = colpolitiebureaus.Get("openingstijden")
'		Dim displayName As String = colpolitiebureaus.Get("displayName")
		
		Dim bezoekadres As Map = colpolitiebureaus.Get("bezoekadres")
		Dim bezoekadres_plaats As String = bezoekadres.Get("plaats")
		Dim bezoekadres_postcode As String = bezoekadres.Get("postcode")
		Dim bezoekadres_postadres As String = bezoekadres.Get("postadres")
		
		Dim postadres As Map = colpolitiebureaus.Get("postadres")
		Dim post_plaats As String = postadres.Get("plaats")
		Dim post_postcode As String = postadres.Get("postcode")
		Dim Post_postadres As String = postadres.Get("postadres")
		
'		Dim faxnummer As String = colpolitiebureaus.Get("faxnummer")
		Dim locaties As List = colpolitiebureaus.Get("locaties")
		For Each collocaties As Map In locaties
			Dim latitude As Double = collocaties.Get("latitude")
			Dim longitude As Double = collocaties.Get("longitude")
		Next
		Dim naam As String = colpolitiebureaus.Get("naam")
		Dim url As String = colpolitiebureaus.Get("url")
		Dim uid As String = colpolitiebureaus.Get("uid")
		Dim facebookurl As String = colpolitiebureaus.Get("facebookurl")
'		Dim telefoonnummer As String = colpolitiebureaus.Get("telefoonnummer")
'		Dim afbeelding As Map = colpolitiebureaus.Get("afbeelding")
'		Dim alttext As String = afbeelding.Get("alttext")
'		Dim afbeeldingurl As String = afbeelding.Get("url")
'		Dim links As String = colpolitiebureaus.Get("links")
'		Dim extrainformatie As String = colpolitiebureaus.Get("extrainformatie")
'		Dim availabletranslations As String = colpolitiebureaus.Get("availabletranslations")
		
		lstPsBase.Add(CreatepsStation(naam, uid, longitude, latitude))
		
		lstPsSocialMedia.Add(CreatesocialMedia(uid, "twitter", twitterurl))
		lstPsSocialMedia.Add(CreatesocialMedia(uid, "facebook", facebookurl))
		lstPsSocialMedia.Add(CreatesocialMedia(uid, "url", url))
		
		lstPsAddress.Add(CreatepsAdress(uid, "visit", bezoekadres_postadres, bezoekadres_postcode, bezoekadres_plaats))
		lstPsAddress.Add(CreatepsAdress(uid, "post", Post_postadres, post_postcode, post_plaats))
	Next
	
	clsdb.AddPoliceStations(lstPsBase)
	
	clsdb.AddSocialmedia(lstPsSocialMedia)
	clsdb.AddAdress(lstPsAddress)
	Return True
End Sub

'STATION BASE
Public Sub CreatepsStation (naam As String, uid As String, longtitude As Double, latitude As Double) As psStation
	Dim t1 As psStation
	t1.Initialize
	t1.naam = naam
	t1.uid = uid
	t1.longtitude = longtitude
	t1.latitude = latitude
	Return t1
End Sub

Public Sub CreatesocialMedia (psId As String, media As String, url As String) As psSocialMedia
	Dim t1 As psSocialMedia
	t1.Initialize
	t1.media = media
	t1.url = url
	t1.psId = psId
	Return t1
End Sub

Public Sub CreatepsAdress (psId As String, addressTypes As String, address As String, postcode As String, city As String) As psAdress
	Dim t1 As psAdress
	t1.Initialize
	t1.psId = psId
	t1.addressTypes = addressTypes
	t1.address = address
	t1.postcode = postcode
	t1.city = city
	Return t1
End Sub

Public Sub GetWijkAgent(longtitude As Double, latitude As Double) As ResumableSub
	Private jsonData As String
	Private strWijkAgentUrl As String
	Private job As HttpJob
	
	strWijkAgentUrl = $"https://api.politie.nl/v4/wijkagenten?language=nl&lat=${latitude}&lon=${longtitude}&radius=5.0&maxnumberofitems=10&offset=0"$
	
	job.Initialize("", Me)
	job.Download(strWijkAgentUrl)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		jsonData = job.GetString
		job.Release
	End If
	wait for (clsWijkAgent.ParseWijkAgentJson(jsonData)) Complete (lst As List)
	Return lst	
	
End Sub