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
	Private textView As BCTextEngine
	Private BBCodeView1 As BBCodeView
	Private clsLocalNews As GetLocalNews
	Private clsBbHeight As GetBbCodeViewHeight
	Private pnlOpenUrl, pnlReadItem As Panel
	Private clvLocalNews As CustomListView
	Private lblIntroduction, lblNext,lblPrev As Label
	Private lblPubDate, lblHeadline, lblArea, lblStationName As Label
	Private lblOpenItem As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsLocalNews.Initialize
	clsBbHeight.Initialize
	Activity.LoadLayout("lokaalNieuwsMain")
	textView.Initialize(Activity)
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
		Dim p As Panel = GenNewsList(item)
		GenFunctions.ResetUserFontScale(p)
		
		clvLocalNews.Add(p, item)
	Next
	
	lblNext.Visible = Not(Starter.localNewsOffsetEnd)
	lblPrev.Visible = Starter.localNewsOffset >= 10
	HideProcessDialog
End Sub

Private Sub GenNewsList(item As localNewsHeadline) As Panel
	
	Dim pnl As B4XView = xui.CreatePanel("")
	pnl.SetLayoutAnimated(0, 0, 0, clvLocalNews.AsView.Width, 300dip)
	pnl.LoadLayout("pnlNewsLocalHeadline")
	
	textView.Initialize(pnl)
	textView.KerningEnabled = Not(textView.KerningEnabled)
	
	lblArea.TextColor = Colors.Yellow
	lblArea.Text = item.area
	lblPubDate.Text = item.pubDate
	lblHeadline.Text = item.title
	
	pnl.Height =  clsBbHeight.GetHeight(BBCodeView1, item.introduction) + 200dip
	BBCodeView1.Text= item.introduction
	
	Dim pHeight As Int = clsBbHeight.SetMainPanelHeigth(pnl)
	pnlOpenUrl.Top = pHeight - 40dip
	pnlReadItem.Top = pHeight - 40dip
	lblOpenItem.Height = pnl.Height - 100dip
	Return pnl
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

Sub clvLocalNews_ItemClick (Index As Int, Value As Object)
	Dim data As localNewsHeadline = Value
	InitNews(data)
End Sub

Private Sub lblOpenItem_Click
	Dim lbl As Label = Sender
	Dim pnl As Panel = lbl.Parent
	Dim data As localNewsHeadline = clvLocalNews.GetValue(clvLocalNews.GetItemFromView(pnl))
	InitNews(data)
End Sub