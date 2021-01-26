B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Dim parser As JSONParser
	
End Sub

Public Sub Initialize
	
End Sub

Public Sub GetData(url As String) As ResumableSub
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(url)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		wait for (ParserDossier(job.GetString)) Complete (lst As List)
'		Return lst
	End If
	Return lst
End Sub

Private Sub ParserDossier(data As String) As ResumableSub
	parser.Initialize(data)
	
	Dim root As Map = parser.NextObject
	Dim iterator As Map = root.Get("iterator")
	Dim last As String = iterator.Get("last")
	Dim offset As Int = iterator.Get("offset")
	
	Starter.dossierOffsetEnd = last
	
	Dim opsporingsberichten As List = root.Get("opsporingsberichten")
	For Each colopsporingsberichten As Map In opsporingsberichten
		Dim publicatiedatum As String = colopsporingsberichten.Get("publicatiedatum")
		Dim verdachte As String = colopsporingsberichten.Get("verdachte")
		Dim displayName As String = colopsporingsberichten.Get("displayName")
		Dim dossier As Map = colopsporingsberichten.Get("dossier")
		Dim slachtoffer As String = dossier.Get("slachtoffer")
		Dim plaatsdelict As String = dossier.Get("plaatsdelict")
		Dim zaakcontent As List = dossier.Get("zaakcontent")
		For Each colzaakcontent As Map In zaakcontent
			Dim titel As String = colzaakcontent.Get("titel")
			Dim alineatype As String = colzaakcontent.Get("alineatype")
			Dim opgemaaktetekst As String = colzaakcontent.Get("opgemaaktetekst")
			Dim bestanden As String = colzaakcontent.Get("bestanden")
		Next
		Dim datumdelict As String = dossier.Get("datumdelict")
		Dim documenttype As String = colopsporingsberichten.Get("documenttype")
		Dim locaties As List = colopsporingsberichten.Get("locaties")
		For Each collocaties As Map In locaties
			Dim latitude As Double = collocaties.Get("latitude")
			Dim longitude As Double = collocaties.Get("longitude")
		Next
		Dim voortvluchtige As String = colopsporingsberichten.Get("voortvluchtige")
		Dim url As String = colopsporingsberichten.Get("url")
		Dim omschrijving As String = colopsporingsberichten.Get("omschrijving")
		Dim uid As String = colopsporingsberichten.Get("uid")
		Dim titel As String = colopsporingsberichten.Get("titel")
		Dim meerafbeeldingen As List = colopsporingsberichten.Get("meerafbeeldingen")
		For Each colmeerafbeeldingen As Map In meerafbeeldingen
			Dim alttext As String = colmeerafbeeldingen.Get("alttext")
			Dim url As String = colmeerafbeeldingen.Get("url")
		Next
		Dim afbeeldingen As List = colopsporingsberichten.Get("afbeeldingen")
		For Each colafbeeldingen As Map In afbeeldingen
			Dim alttext As String = colafbeeldingen.Get("alttext")
			Dim url As String = colafbeeldingen.Get("url")
		Next
		Dim zaaknummer As String = colopsporingsberichten.Get("zaaknummer")
		Dim introductie As String = colopsporingsberichten.Get("introductie")
		Dim links As String = colopsporingsberichten.Get("links")
		Dim availabletranslations As String = colopsporingsberichten.Get("availabletranslations")
		Dim urltipformulier As String = colopsporingsberichten.Get("urltipformulier")
		Dim gestolen_gevonden As String = colopsporingsberichten.Get("gestolen-gevonden")
	
	lst.Add(Createdossier(uid, titel, introductie, GenFunctions.ParseStringDate(publicatiedatum, "d"), GenFunctions.ParseStringDate(datumdelict, "d"), plaatsdelict))
	Next
	
	Return lst
End Sub

Public Sub Createdossier (uid As String, titel As String, introductie As String, publicatieDatum As String, datedelict As String, plaatsDelict As String) As Dossier
	Dim t1 As Dossier
	t1.Initialize
	t1.uid = uid
	t1.titel = titel
	t1.introductie = introductie
	t1.publicatieDatum = publicatieDatum
	t1.datedelict = datedelict
	t1.plaatsDelict = plaatsDelict
	Return t1
End Sub