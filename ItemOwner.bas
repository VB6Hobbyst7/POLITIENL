B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
#IgnoreWarnings: 9
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub


Public Sub GetData(url As String, forList As Boolean) As ResumableSub
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(url)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		wait for (ParseData(job.GetString, forList)) Complete (lst As List)
'		Return lst
	End If
	Return lst
End Sub

Public Sub GetMoreData(url As String, forList As Boolean) As ResumableSub
	Private job As HttpJob
	Private success As Boolean
	job.Initialize("", Me)
	job.Download(url)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		success = job.Success
	End If
	
	Return success
End Sub

Private Sub ParseData(data As String, forList As Boolean) As ResumableSub
	Dim parser As JSONParser
	Dim root As Map
	Dim lst As List

	parser.Initialize(data)
	root = parser.NextObject
	lst.Initialize
#region parse json
	Dim iterator As Map = root.Get("iterator")
	Dim last As String = iterator.Get("last")
	Dim offset As Int = iterator.Get("offset")
	Starter.itemsFoundOffsetEnd = last
	Dim opsporingsberichten As List = root.Get("opsporingsberichten")
	For Each colopsporingsberichten As Map In opsporingsberichten
		Dim publicatiedatum As String = colopsporingsberichten.Get("publicatiedatum")
		Dim verdachte As String = colopsporingsberichten.Get("verdachte")
		Dim displayName As String = colopsporingsberichten.Get("displayName")
		Dim dossier As String = colopsporingsberichten.Get("dossier")
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
			Dim alttextmeer As String = colmeerafbeeldingen.Get("alttext")
			Dim urlmeer As String = colmeerafbeeldingen.Get("url")
		Next
		Dim afbeeldingen As List = colopsporingsberichten.Get("afbeeldingen")
		For Each colafbeeldingen As Map In afbeeldingen
			Dim alttextafb As String = colafbeeldingen.Get("alttext")
			Dim urlafb As String = colafbeeldingen.Get("url")
		Next
		Dim zaaknummer As String = colopsporingsberichten.Get("zaaknummer")
		Dim introductie As String = colopsporingsberichten.Get("introductie")
		Dim links As String = colopsporingsberichten.Get("links")
		Dim availabletranslations As String = colopsporingsberichten.Get("availabletranslations")
		Dim urltipformulier As String = colopsporingsberichten.Get("urltipformulier")
		Dim gestolen_gevonden As Map = colopsporingsberichten.Get("gestolen-gevonden")
		Dim opgelost As String = gestolen_gevonden.Get("opgelost")
		Dim update As String = gestolen_gevonden.Get("update")
		Dim videos As String = gestolen_gevonden.Get("videos")
		Dim plaatsdelict As String = gestolen_gevonden.Get("plaatsdelict")
		Dim datumdelict As String = gestolen_gevonden.Get("datumdelict")
		Dim vraag As String = gestolen_gevonden.Get("vraag")
#end region		
		'List of items
		If forList Then
			lst.Add(CreatefoundItemList(publicatiedatum, titel, introductie, uid, plaatsdelict))
		End If
	Next
	
	Return lst
End Sub

Public Sub CreatefoundItemList (pubData As String, title As String, description As String, uid As String, location As String) As foundItemList
	Dim t1 As foundItemList
	t1.Initialize
	t1.pubData = pubData
	t1.title = title
	t1.description = description
	t1.uid = uid
	t1.location = location
	Return t1
End Sub