B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10.2
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
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
	Private pnlFacebook As Panel
	Private lblFacebook As Label
	Private pnlTwitter As Panel
	Private lblTwitter As Label
	Private lblInstagram As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("wijkAgentMain")
	GenFunctions.ResetUserFontScale(Activity)
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
	Dim publicationDate As Long 'ignore
	DateTime.DateFormat = "yyyy-MM-dd"
	publicationDate = $"${DateTime.DateParse(wijkAgent.publicatieDatum.SubString2(0,10)}"$)
	DateTime.DateFormat = "dd-MMM-yyyy"

	Dim pnl As B4XView = xui.CreatePanel("")
	
	pnl.SetLayoutAnimated(0, 0, 0, clvAgent.AsView.Width, 200dip)
	pnl.LoadLayout("pnlWijkAgent")
	
	
	imgAgent.SetBackgroundImage(wijkAgent.afbeelding)
	lblAgentNaam.Text = wijkAgent.naam
	lblWerkGebied.Text = wijkAgent.werkGebied
	lblPubDate.Text = $"${GenFunctions.ParseStringDate(wijkAgent.publicatieDatum, "d")}"$
	
	If wijkAgent.url.Length < 10 Then
		lblUrl.TextColor = Colors.Gray
	End If
	If wijkAgent.twitter = "http://twitter.com//" Then
		lblTwitter.TextColor = Colors.Gray
	End If
	If wijkAgent.instagram = "" Then
		lblInstagram.TextColor = Colors.Gray
	End If
	If wijkAgent.facebook = "" Then
		lblFacebook.TextColor = Colors.Gray
	End If
	
	GenFunctions.ResetUserFontScale(pnl)
	Return pnl
End Sub


Sub pnlUrl_Click
	Dim p As Panel = Sender
	Dim wijkAgent As wijkAgent = clvAgent.GetValue(clvAgent.GetItemFromView(p))
	GenFunctions.OpenUrl(wijkAgent.url)
	
End Sub

Sub pnlFacebook_Click
	Dim p As Panel = Sender
	Dim wijkAgent As wijkAgent = clvAgent.GetValue(clvAgent.GetItemFromView(p))
	If wijkAgent.facebook.Length > 10 Then
		GenFunctions.OpenUrl(wijkAgent.facebook)
	End If
End Sub

Sub pnlTwitter_Click
	Dim p As Panel = Sender
	Dim wijkAgent As wijkAgent = clvAgent.GetValue(clvAgent.GetItemFromView(p))
	If wijkAgent.twitter <> "http://twitter.com//" Then
		GenFunctions.OpenUrl(wijkAgent.twitter)
	End If
End Sub

Sub pnlInstagram_Click
	Dim p As Panel = Sender
	Dim wijkAgent As wijkAgent = clvAgent.GetValue(clvAgent.GetItemFromView(p))
	If wijkAgent.instagram.Length > 10 Then
		GenFunctions.OpenUrl(wijkAgent.instagram)
	End If
End Sub