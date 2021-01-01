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
	Private clsLocalNews As GetLocalNews
	Private clvLocalNews As CustomListView
	Private lblPubDate As Label
	Private lblHeadline As Label
	Private lblArea As Label
	Private lblStationName As Label
	Private pnlOpenUrl As Panel
	Private pnlReadItem As Panel
	Private lblIntroduction As Label
	Private btnPrev As Button
	Private btnNext As Button
	Private lblNext As Label
	Private lblPrev As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Dim cd As ColorDrawable
	cd.Initialize(Colors.RGB(255,255,255),3dip)
	clsLocalNews.Initialize
	Activity.LoadLayout("lokaalNieuwsMain")
	btnNext.Background = cd
	btnPrev.Background = cd
	GenFunctions.ResetUserFontScale(Activity)
	lblStationName.Text = $"Lokaal Nieuws${CRLF}${GenFunctions.stationData.name}"$
	showProcessDialog
	GetLocalNewsItems
	HideProcessDialog
	
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub showProcessDialog
	ProgressDialogShow2("Ophalen lokale nieuws items..", False)
	Sleep(200)
End Sub


Private Sub HideProcessDialog
	ProgressDialogHide
End Sub

Private Sub GetLocalNewsItems
	showProcessDialog
	clvLocalNews.Clear
	wait for (clsLocalNews.GetLocalNewsHeadlines) Complete (lstNews As List)
	
	If lstNews.Size = 0 Then
		HideProcessDialog
		GenFunctions.createCustomToast("Niets gevonden", Colors.Red)
		Activity.Finish
	End If
	
	For Each item As localNewsHeadline In lstNews
		clvLocalNews.Add(GenNewsList(item), item)
	Next
	
	lblNext.Visible = Not(Starter.localNewsOffsetEnd)
	lblPrev.Visible = Starter.localNewsOffset >= 10
	HideProcessDialog
End Sub

Private Sub GenNewsList(item As localNewsHeadline) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	
	pnl.SetLayoutAnimated(0, 0, 0, clvLocalNews.AsView.Width, 310dip)
	pnl.LoadLayout("pnlNewsLocalHeadline")
	
	lblArea.Text = item.area
	lblPubDate.Text = item.pubDate
	lblHeadline.Text = item.title
	lblIntroduction.Text = item.introduction
	GenFunctions.ResetUserFontScale(pnl)
	Return pnl
End Sub

Sub ShowHidePrevNextButton
	btnNext.Visible = Not(Starter.localNewsOffsetEnd)
	btnPrev.Visible = Starter.localNewsOffset > 0
End Sub

Sub pnlOpenUrl_Click
	Dim pnl As Panel = Sender
	Dim data As localNewsHeadline = clvLocalNews.GetValue(clvLocalNews.GetItemFromView(pnl))
	InitNews(data)
End Sub

Sub pnlReadItem_Click
	GenFunctions.OpenUrl("https://www.politie.nl/contact/contactformulier.html")
End Sub

Sub InitNews(data As localNewsHeadline)
	Wait For (clsLocalNews.GetLocalNewsDetail(data.latitude, data.longtitude, data.uid)) Complete (parsedData As String)
	
	StartActivity(newsDetail)
	
	CallSubDelayed2(newsDetail, "SetNewsdate", data.pubDate)
	CallSubDelayed2(newsDetail, "SetNewsText", parsedData)
	CallSubDelayed2(newsDetail, "SetNewsArea", data.area)
End Sub

Sub pnlHeadline_Click
	pnlOpenUrl_Click
End Sub

Sub lblPrev_Click
	If Starter.localNewsOffset >= 10 Then
		Starter.localNewsOffset = Starter.localNewsOffset - 10
		GetLocalNewsItems
	End If
End Sub

Sub lblNext_Click
	Starter.localNewsOffset = Starter.localNewsOffset + 10
	GetLocalNewsItems
End Sub

Sub btnPrev_Click
	If Starter.localNewsOffset >= 10 Then
		Starter.localNewsOffset = Starter.localNewsOffset - 10
		GetLocalNewsItems
	End If
End Sub

Sub btnNext_Click
	Starter.localNewsOffset = Starter.localNewsOffset + 10
	GetLocalNewsItems
End Sub