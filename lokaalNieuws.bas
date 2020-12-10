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
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsLocalNews.Initialize
	Activity.LoadLayout("lokaalNieuwsMain")
	GenFunctions.ResetUserFontScale(Activity)
	lblStationName.Text = $"Lokaal Nieuws${CRLF}${GenFunctions.stationData.name}"$
	ProgressDialogShow2("Ophalen lokale nieuws items..", False)
	Sleep(300)
	GetLocalNewsItems
	Sleep(300)
	ProgressDialogHide
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetLocalNewsItems
	clvLocalNews.Clear
	wait for (clsLocalNews.GetLocalNewsHeadlines) Complete (lstNews As List)
	
	For Each item As localNewsHeadline In lstNews
		clvLocalNews.Add(GenNewsList(item), item)
	Next
	
End Sub

Private Sub GenNewsList(item As localNewsHeadline) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	
	pnl.SetLayoutAnimated(0, 0, 0, clvLocalNews.AsView.Width, 240dip)
	pnl.LoadLayout("pnlNewsLocalHeadline")
	
	lblArea.Text = item.area
	lblPubDate.Text = item.pubDate
	lblHeadline.Text = item.title
	GenFunctions.ResetUserFontScale(pnl)
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
End Sub