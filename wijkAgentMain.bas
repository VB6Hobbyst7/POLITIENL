B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10.2
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False	
#End Region

Sub Process_Globals
	Private xui As XUI
End Sub

Sub Globals
	Private lblStationName As Label
	Private clvAgent As CustomListView
	Private imgAgent As ImageView
	Private lblAgentNaam As Label
	Private lblWerkGebied As Label
	Private pnlAgent As Panel
	Private lblPubDate As Label
	Private pnlUrl As Panel
	Private pnlImg As Panel
	Private lblUrl As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("wijkAgentMain")
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub GetWijkAgent(lst As List, stationName As String)
	clvAgent.Clear
	lblStationName.Text = stationName
		
	For i = 0 To lst.Size - 1
		Dim data As wijkAgent = lst.Get(i)
		clvAgent.Add(GenWijkAgent(lst.Get(i)), data)
	Next
	
End Sub

Sub GenWijkAgent(wijkAgent As wijkAgent) As Panel
	Dim publicationDate As Long
	DateTime.DateFormat = "yyyy-MM-dd"
	publicationDate = $"${DateTime.DateParse(wijkAgent.publicatieDatum.SubString2(0,10)}"$)
	DateTime.DateFormat = "dd-MMM-yyyy"

	Dim pnl As B4XView = xui.CreatePanel("")
	
	pnl.SetLayoutAnimated(0, 0, 0, clvAgent.AsView.Width, 280dip)
	pnl.LoadLayout("pnlWijkAgent")
	
	
	imgAgent.SetBackgroundImage(wijkAgent.afbeelding)
	lblAgentNaam.Text = wijkAgent.naam
	lblWerkGebied.Text = wijkAgent.werkGebied
	lblPubDate.Text = $"Pub. datum $Date{publicationDate}"$
	
	If wijkAgent.url.Length < 10 Then
		lblUrl.TextColor = Colors.Gray
	End If
	Return pnl
End Sub


Sub pnlUrl_Click
	Dim p As Panel = Sender
	Dim wijkAgent As wijkAgent = clvAgent.GetValue(clvAgent.GetItemFromView(p))
	GenFunctions.OpenUrl(wijkAgent.url)
	
End Sub