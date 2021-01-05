B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

'Sub GetCityJsonFromCoords(lat As Double, lon As Double) As ResumableSub
'	Dim job As HttpJob
'	Dim jsonData As String
'	
'	job.Initialize("", Me)
'	job.Download($"https://geocode.xyz/${lat},${lon}?geoit=json"$)
'	
'	Wait For (job) jobDone(jobDone As HttpJob)
'	
'	If jobDone.Success Then
'		jsonData = job.GetString
'	Else
'		jsonData = "err"
'	End If
'	
'	job.Release
'	
'	If jsonData = "err" Then 
'		Return "err"
'	End If
'	
'	Return ParseCity(jsonData)
'	
'End Sub

'Private Sub ParseCity(data As String) As String
'	Dim parser As JSONParser
'	parser.Initialize(data)
'	Dim root As Map = parser.NextObject
'	Dim city As String = root.Get("city")
'
'	If city.Length > 5 Then
'		Log($"PARSED CITY ${city}"$)
'		Return city
'	Else
'		Return "err"
'	End If
'End Sub