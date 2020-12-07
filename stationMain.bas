B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10.2
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: false
#End Region

Sub Process_Globals
	Dim xui As XUI
End Sub

Sub Globals
	Private PCLV As PreoptimizedCLV
	Private CardLayoutsCache As List
	Dim ime As IME
	Private clsDb As dbFunctions
	Private clvStation As CustomListView
	Private clsStationData As GetPoliceStations
	Private clsLocalNews As GetLocalNews
	
	Private pnlStation As Panel
	Private lblStationName As Label
	Private lblAddress As Label
	Private lblZip As Label
	Private lblCity As Label
	Private pnlTwitter As Panel
	Private pnlFacebook As Panel
	Private pnlUrl As Panel
	Private lblTwitter As Label
	Private lblFacebook As Label
	Private lblUrl As Label
	Private edtFind As EditText
	Private lblMagni As Label
	Private pnlFind As Panel
	Private edtDummyForFocus As EditText
	Private pnlWijkAgent As Panel
	Private pnlLocalNews As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsDb.Initialize
	clsStationData.Initialize
	clsLocalNews.Initialize
	CardLayoutsCache.Initialize
	
	Activity.LoadLayout("stationMain")
	
	PCLV.Initialize(Me, "PCLV", clvStation)
	GetStation
	
	ime.Initialize("IME")
	ime.AddHandleActionEvent(edtFind)
	edtFind.InputType = Bit.Or(edtFind.InputType, 0x00080000)
	GenFunctions.ResetUserFontScale(Activity)

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub IME_HeightChanged(NewHeight As Int, OldHeight As Int)
'	btnHideKeyboard.Top = NewHeight - btnHideKeyboard.Height
'	EditText1.Height = btnHideKeyboard.Top - EditText1.Top
End Sub

Sub IME_HandleAction As Boolean
	edtFind_EnterPressed
	Return False 'will close the keyboard
End Sub

Sub clvStation_ItemClick (Index As Int, Value As Object)
	
End Sub

Sub GetStation
	Dim lstStation As List = clsDb.GetStationList
	
	clvStation.Clear

	For Each st As station In lstStation
		PCLV.AddItem(160dip, xui.Color_White, st)
	Next
	
	PCLV.Commit
End Sub

Sub PCLV_HintRequested (Index As Int) As Object
	Dim word As station = clvStation.GetValue(Index)
	Return word.name
End Sub

Sub clvStation_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim width As Int = clvStation.AsView.Width
		
	For Each i As Int In PCLV.VisibleRangeChanged(FirstIndex, LastIndex)
		Dim item As CLVItem = clvStation.GetRawListItem(i)
		Dim station As station = item.Value
		Dim pnl As B4XView = xui.CreatePanel("")
	
		item.Panel.AddView(pnl, 0, 0, width, 160dip)
		pnl.LoadLayout("clvStation")
		
		lblStationName.Text = station.name
		lblAddress.Text = station.address
		lblCity.Text = $"${station.postalcode} ${station.city}"$
		
		If lblCity.Text.Length < 5 Then
			lblCity.Text = "Adresgevens van dit bureau niet beschikbaar"
			lblCity.TextColor = Colors.Red
		End If
		If station.url.Length > 2 Then
			pnlUrl.Tag = station.url
		Else
			pnlUrl.Enabled = False
			lblUrl.TextColor = Colors.Gray
		End If
		If station.twitter.Length > 2 Then
			pnlTwitter.Tag = station.twitter
		Else
			pnlTwitter.Enabled = False
			lblTwitter.TextColor = Colors.Gray
		End If
		If station.facebook.Length > 2 Then
			pnlFacebook.Tag = station.facebook
		Else
			pnlFacebook.Enabled = False
			lblFacebook.TextColor = Colors.Gray
		End If
		GenFunctions.ResetUserFontScale(pnl)
	Next
End Sub

Sub pnlTwitter_Click
	Dim p As Panel = Sender
	Dim stationData As station = GetStationData(p)
	
	GenFunctions.OpenUrl(stationData.twitter)
End Sub

Sub pnlFacebook_Click
	Dim p As Panel = Sender
	Dim stationData As station = GetStationData(p)
	
	GenFunctions.OpenUrl(stationData.facebook)
End Sub

Sub pnlUrl_Click
	Dim p As Panel = Sender
	Dim stationData As station = GetStationData(p)
	
	GenFunctions.OpenUrl(stationData.url)
	
End Sub

Sub edtFind_EnterPressed
	edtDummyForFocus.RequestFocus
	If edtFind.Text = "" Then
	Dim lstStation As List = clsDb.GetStationList
		Else
	Dim lstStation As List = clsDb.GetFindStationList(edtFind.Text)
	End If
	ime.HideKeyboard
	FindStation(lstStation)	
	clvStation.ScrollToItem(0)
End Sub

Sub lblMagni_Click
	'IN FIND
	If lblMagni.Text = Chr(0xf156) Then
		edtFind.Text = ""
		ime.HideKeyboard
		lblMagni.Text = Chr(0xf349)
		edtDummyForFocus.RequestFocus
		'GO FIND
	else If lblMagni.Text = Chr(0xf349) Then
		lblMagni.Text = Chr(0xf156)
		ime.ShowKeyboard(edtFind)
		edtFind.RequestFocus
	End If
	
	edtDummyForFocus.RequestFocus
	If edtFind.Text = "" Then
		Dim lstStation As List = clsDb.GetStationList
	Else
		Dim lstStation As List =clsDb.GetFindStationList(edtFind.Text)
	End If
	FindStation(lstStation)
End Sub

Sub FindStation(lstStation As List)
	If lstStation.Size < 1 Then
		GenFunctions.createCustomToast("Niets gevonden..", Colors.Red)
		Return
	End If
	clvStation.Clear
	
	For Each st As station In lstStation
		PCLV.AddItem(180dip, xui.Color_White, st)
	Next
	PCLV.Commit
	clvStation.ScrollToItem(0)
End Sub

Sub edtFind_TextChanged (Old As String, New As String)
	If New.Length > 0 Then
		lblMagni.Text = Chr(0xf156)
	End If
End Sub

Sub pnlWijkAgent_Click
	Dim pnl As Panel = Sender
	Dim stationData As station
	
	ProgressDialogShow2("Ophalen gegevens wijkagent(en)..", False)
	Sleep(300)	
	stationData = clvStation.GetValue(clvStation.GetItemFromView(pnl))
	Wait For (clsStationData.GetWijkAgent(stationData.longtitude, stationData.latitude)) Complete (lstWijkAgent As List)
	ProgressDialogHide
	
	If lstWijkAgent.Size > 0 Then
		StartActivity(wijkAgentMain)
		CallSubDelayed3(wijkAgentMain, "GetWijkAgent", lstWijkAgent, stationData.name)
	End If
	
End Sub

Sub GetStationData(p As Panel) As station
	Return clvStation.GetValue(clvStation.GetItemFromView(p))
End Sub

Sub pnlLocalNews_Click
	Dim pnl As Panel = Sender
	GenFunctions.stationData = clvStation.GetValue(clvStation.GetItemFromView(pnl))
	StartActivity(lokaalNieuws)	
End Sub

Sub lblLocation_Click
	Dim lbl As Label = Sender
	Dim stationData As station
	
	stationData = clvStation.GetValue(clvStation.GetItemFromView(lbl.Parent))
	
	GenFunctions.ShowLocationOnGoogleMaps(stationData.latitude, stationData.longtitude)
End Sub