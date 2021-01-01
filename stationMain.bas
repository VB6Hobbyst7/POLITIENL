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
	Private TextEngine As BCTextEngine
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
	Private imgFav As ImageView
	Private lblItemFound As Label
	Private lblOpenHours As Label
	Private pnlOpenHours As Panel
	Private bbOpenHours As BBCodeView
	Private btnClose As Button
	Private lblNumber As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsDb.Initialize
	clsStationData.Initialize
	clsLocalNews.Initialize
	CardLayoutsCache.Initialize
	
	Activity.LoadLayout("stationMain")
	
	PCLV.Initialize(Me, "PCLV", clvStation)
	GetStation
	TextEngine.Initialize(pnlOpenHours)
	
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
	Dim lstStation As List = clsDb.GetFindStationList("")
	
	clvStation.Clear

	For Each st As station In lstStation
		PCLV.AddItem(180dip, xui.Color_White, st)
	Next
	PCLV.ShowScrollBar = False
	PCLV.Commit
End Sub

Sub PCLV_HintRequested (Index As Int) As Object
	Dim word As station = clvStation.GetValue(Index)
	Return word.name
End Sub

Sub clvStation_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim width As Int = clvStation.AsView.Width
	Dim cs As CSBuilder	
	For Each i As Int In PCLV.VisibleRangeChanged(FirstIndex, LastIndex)
		Dim item As CLVItem = clvStation.GetRawListItem(i)
		Dim station As station = item.Value
		Dim pnl As B4XView = xui.CreatePanel("")
	
		item.Panel.AddView(pnl, 0, 0, width, 180dip)
		pnl.LoadLayout("clvStation")
		cs.Initialize.Color(0xFF00FFFF).Append(station.address).Append(CRLF).Append(station.postalcode).Append(" ").pop
		cs.Color(Colors.Yellow).Append(station.city).PopAll
		lblNumber.Text = NumberFormat(i+1,3, 0)
		lblStationName.Text = station.name
		lblAddress.Text =  cs'$"${station.address}${CRLF}${station.postalcode} ${station.city}"$
		lblCity.Text = $"${station.postalcode} ${station.city}"$
		
		If lblCity.Text.Length < 5 Then
			lblAddress.textColor = Colors.Yellow
			lblAddress.Typeface = Typeface.LoadFromAssets("VeraMono-Italic.ttf")
			lblAddress.Text = "Geen adresgevens..."
'			lblAddress.TextColor = Colors.Red
		End If
		
		If station.openHours.Length < 5 Then
			lblOpenHours.Visible = False
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
		
		SetImgFav(station.fav_id <> Null, imgFav)
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
'	If edtFind.Text = "" Then
'	Dim lstStation As List = clsDb.GetFindStationList(edtFind.Text)
'		Else
'	End If
	Dim lstStation As List = clsDb.GetFindStationList(edtFind.Text)
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
		Dim lstStation As List = clsDb.GetFindStationList("")
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
	Starter.localNewsOffset = 0
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

Sub imgFav_Click
	Dim imgv As ImageView = Sender
	Dim stationData As station
	Dim psId As String
	Dim addStationFav As Boolean
	
	stationData = clvStation.GetValue(clvStation.GetItemFromView(imgv.Parent))
	psId = stationData.ps_id
	
	addStationFav = clsDb.CheckFavIfStationIsInFav(psId)
	If addStationFav Then
		GenFunctions.createCustomToast("Bureau als favoriet ingesteld", Colors.Blue)
	Else
		GenFunctions.createCustomToast("Bureau geen favoriet meer", Colors.Blue)
	End If
	
	SetImgFav(addStationFav, imgv)
End Sub

Sub SetImgFav(show As Boolean, v As ImageView)
	If show Then
		v.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "favourite_on.png", 25dip, 25dip, True))
		v.Gravity = Gravity.FILL
	Else
		v.SetBackgroundImage(LoadBitmapResize(File.DirAssets, "favourite_off.png", 25dip, 25dip, True))
		v.Gravity = Gravity.FILL
	End If
	
End Sub

Sub lblItemFound_Click
	StartActivity(ItemsFound)
End Sub

Sub lblOpenHours_Click
	Dim stationData As station
	Dim lbl As Label = Sender
	Dim pnl As Panel = lbl.Parent
	
	stationData = clvStation.GetValue(clvStation.GetItemFromView(pnl))
	
	If pnlOpenHours.Visible = True Then Return
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	bbOpenHours.Text = stationData.openHours
	pnlOpenHours.Visible = True
	
End Sub

Sub pnlOpenHours_Click
	
End Sub

Sub bbOpenHours_LinkClicked (URL As String)
	GenFunctions.OpenUrl(URL)
End Sub

Sub btnClose_Click
	pnlOpenHours.Visible = False
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If pnlOpenHours.Visible Then
			pnlOpenHours.Visible = False
			Return True
		End If
	End If

'	Activity.Finish
	Return False
End Sub