B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
#IgnoreWarnings:9

Sub Class_Globals
	Private selectedUID As String
	Public lstString, lstMeerafbeeldingen As List
	Public itemFoundData As foundItemDetail
End Sub

Public Sub Initialize
	
End Sub

Public Sub GetData(url As String, passedUid As String) As ResumableSub
	Dim jobString As String
	selectedUID = passedUid
	
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(url)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		jobString = job.GetString
		job.Release
		wait for (ParseData(jobString)) Complete (done As Boolean)
	End If
	
	Return True
End Sub

Private Sub ParseData(data As String) As ResumableSub
	Dim parser As JSONParser
	Dim root As Map

	parser.Initialize(data)
	root = parser.NextObject
	lstString.Initialize
	lstMeerafbeeldingen.Initialize
	
#region parse json
	Dim iterator As Map = root.Get("iterator")
	Dim last As String = iterator.Get("last")
	Dim offset As Int = iterator.Get("offset")
	
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
		Dim UID As String = colopsporingsberichten.Get("uid")
		
		'*** GET SELECTED UID ***
		If UID <> selectedUID Then
			Continue
		End If
		
		Dim titel As String = colopsporingsberichten.Get("titel")
		Dim meerafbeeldingen As List = colopsporingsberichten.Get("meerafbeeldingen")
		'ZIJN ER FOTOs
		If meerafbeeldingen.Size > 0 Then
			For Each colmeerafbeeldingen As Map In meerafbeeldingen
				Dim alttextmeer As String = colmeerafbeeldingen.Get("alttext")
				Dim urlmeer As String = colmeerafbeeldingen.Get("url")
				lstMeerafbeeldingen.Add(urlmeer)
			Next
		Else
			If omschrijving.IndexOf("<table") > -1 Then
				GetImageUrlFromTable(omschrijving)
				omschrijving = DeleteTableFromOmschrijving(omschrijving)
			End If
		End If
		
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
		If UID == selectedUID Then
			Exit
		End If
	Next
	
	lstString.Add(CreatefoundItemDetail(omschrijving, urltipformulier, "", vraag))

	Return True
End Sub

Private Sub DeleteTableFromOmschrijving(omschrijving As String) As String
	Dim startTablePos, endTablePos As Int
	Dim endStrTable As String = "</table>"
	
	startTablePos = omschrijving.IndexOf("<table")
	endTablePos = omschrijving.IndexOf(endStrTable)+endStrTable.Length
	
	Return omschrijving.SubString2(0, startTablePos)
End Sub

Private Sub GetImageUrlFromTable(tableString As String)
	File.WriteString(Starter.filePath, "td.tmp", tableString)
	
	Dim tdStr As String = "<td><img src="
	Dim imgLink, tmpFile As String
	Dim cleanTable As List
	Dim endPos As Int
	
	tmpFile = "td.tmp"
	
	cleanTable = File.ReadList(Starter.filePath, tmpFile)
	
	For Each line As String In cleanTable
		If line.IndexOf(tdStr) > -1 Then
			line = line.Replace($"${tdStr}""$, "")
			endPos = line.IndexOf($"""$)
			imgLink = line.SubString2(0, endPos)
			lstMeerafbeeldingen.Add($"https://www.politie.nl${imgLink.Trim}"$)
		End If
	Next
	File.Delete(Starter.filePath, tmpFile)
End Sub

Public Sub CreatefoundItemDetail (description As String, urlTipFormulier As String, question As String, questionOwner As String) As foundItemDetail
	Dim t1 As foundItemDetail
	t1.Initialize
	t1.description = description
	t1.urlTipFormulier = urlTipFormulier
	t1.question = question
	t1.questionOwner = questionOwner
	
	itemFoundData = t1
	Return t1
End Sub