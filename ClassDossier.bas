B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
#IgnoreWarnings: 9
Sub Class_Globals
	Dim parser As JSONParser
	Dim lst As List
	Public dossierUID As String
End Sub

Public Sub Initialize
	
End Sub

Public Sub GetData(url As String) As ResumableSub
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(url)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
'		Log($"$DateTime{DateTime.Now}"$)
		wait for (ParserDossier(job.GetString)) Complete (lstDossier As List)
	End If
	Return lst
End Sub

Private Sub ParserDossier(data As String) As ResumableSub
	parser.Initialize(data)
	lst.Initialize
	
	Dim root As Map = parser.NextObject
	Dim iterator As Map = root.Get("iterator")
	Dim last As String = iterator.Get("last")
	Dim offset As Int = iterator.Get("offset")
	Dim dossierText As String = ""
	
	Starter.dossierOffsetEnd = last
	
	Try
		Dim opsporingsberichten As List = root.Get("opsporingsberichten")
		For Each colopsporingsberichten As Map In opsporingsberichten
			Dim publicatiedatum As String = colopsporingsberichten.Get("publicatiedatum")
			Dim verdachte As String = colopsporingsberichten.Get("verdachte")
			Dim displayName As String = colopsporingsberichten.Get("displayName")
			Dim dossier As Map = colopsporingsberichten.Get("dossier")
			Dim slachtoffer As String = dossier.Get("slachtoffer")
			Dim plaatsdelict As String = dossier.Get("plaatsdelict")
'			Try
'				Dim zaakcontent As List = dossier.Get("zaakcontent")
'				For Each colzaakcontent As Map In zaakcontent
'					Dim zaakcontent_titel As String = colzaakcontent.Get("titel")
'					Dim zaakcontent_alineatype As String = colzaakcontent.Get("alineatype")
'					Dim zaakcontent_opgemaaktetekst As String = colzaakcontent.Get("opgemaaktetekst")
'					Dim zaakcontent_bestanden As String = colzaakcontent.Get("bestanden")
'					dossierText = SetDossierText(zaakcontent_titel, zaakcontent_opgemaaktetekst, dossierText)
'				Next
'			Catch
'				Log(LastException.Message)
'			End Try
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
			'GET DOSSIER DETAIL
			If Starter.dossierUID <> "" Then
				If Starter.dossierUID <> uid Then
					Continue
				End If
			End If
			
			Dim titel As String = colopsporingsberichten.Get("titel")
			Dim meerafbeeldingen As List = colopsporingsberichten.Get("meerafbeeldingen")
			For Each colmeerafbeeldingen As Map In meerafbeeldingen
				Dim alttext As String = colmeerafbeeldingen.Get("alttext")
				Dim url As String = colmeerafbeeldingen.Get("url")
			Next
			Dim afbeeldingen As List = colopsporingsberichten.Get("afbeeldingen")
			For Each colafbeeldingen As Map In afbeeldingen
				Dim afbeeldingen_alttext As String = colafbeeldingen.Get("alttext")
				Dim afbeeldingen_url As String = colafbeeldingen.Get("url")
			Next
			Dim zaaknummer As String = colopsporingsberichten.Get("zaaknummer")
			Dim introductie As String = colopsporingsberichten.Get("introductie")
			Dim links As String = colopsporingsberichten.Get("links")
			Dim availabletranslations As String = colopsporingsberichten.Get("availabletranslations")
			Dim urltipformulier As String = colopsporingsberichten.Get("urltipformulier")
			Dim gestolen_gevonden As String = colopsporingsberichten.Get("gestolen-gevonden")
			
			If Starter.dossierUID = uid Then
				Try
					Dim zaakcontent As List = dossier.Get("zaakcontent")
					For Each colzaakcontent As Map In zaakcontent
						Dim zaakcontent_titel As String = colzaakcontent.Get("titel")
						Dim zaakcontent_alineatype As String = colzaakcontent.Get("alineatype")
						Dim zaakcontent_opgemaaktetekst As String = colzaakcontent.Get("opgemaaktetekst")
						Dim zaakcontent_bestanden As String = colzaakcontent.Get("bestanden")
						dossierText = SetDossierText(zaakcontent_titel, zaakcontent_opgemaaktetekst, dossierText)
					Next
				Catch
					Log(LastException.Message)
				End Try
			End If
			If Starter.dossierUID = "" Then
				lst.Add(Createdossier(uid, titel, introductie, publicatiedatum, datumdelict, plaatsdelict))
			Else
				lst.Add(CreatedossierDetail(titel, url, introductie, publicatiedatum, afbeeldingen_url, datumdelict, plaatsdelict, urltipformulier, zaaknummer, dossierText))
				Exit
			End If
		Next
	Catch
		Log($"${LastException} ${LastException.Message}"$)
	End Try
	Return lst
End Sub

Private Sub SetDossierText(title As String, text As String, dossierText As String) As String
	If dossierText.Length > 20 Then
		dossierText = $"${dossierText}${CRLF}"$
	End If
	
	If title <> "" Then
		dossierText = $"${dossierText}${CRLF}${title}${CRLF}"$
	End If
	If text <> "" Then
		dossierText = $"${dossierText}${CRLF}${text}"$
	End If
	
	Return dossierText
End Sub

Public Sub Createdossier (uid As String, titel As String, introductie As String, publicatieDatum As String, datedelict As String, plaatsDelict As String) As dossier
	Dim t1 As dossier
	t1.Initialize
	t1.uid = uid
	t1.titel = titel
	t1.introductie = introductie
	t1.publicatieDatum = publicatieDatum
	t1.datedelict = datedelict
	t1.plaatsDelict = plaatsDelict
	Return t1
End Sub

Public Sub CreatedossierDetail (titel As String, url As String, introductie As String, publicatieDatum As String, afbeeldingUrl As String, dossierDatumDelict As String, dossierPlaatsDelict As String, urlTipFormulier As String, zaakNummer As String, DossierText As String) As dossierDetail
	Dim t1 As dossierDetail
	t1.Initialize
	t1.titel = titel
	t1.url = url
	t1.introductie = introductie
	t1.publicatieDatum = publicatieDatum
	t1.afbeeldingUrl = afbeeldingUrl
	t1.dossierDatumDelict = dossierDatumDelict
	t1.dossierPlaatsDelict = dossierPlaatsDelict
	t1.urlTipFormulier = urlTipFormulier
	t1.zaakNummer = zaakNummer
	t1.DossierText = DossierText
	Return t1
End Sub