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
	Private bbOpenHours As BBCodeView
	Private PCLV As PreoptimizedCLV
	Private CardLayoutsCache As List
	Private ime As IME
	Private clsDb As dbFunctions
	Private clvStation As CustomListView
	Private clsStationData As GetPoliceStations
	Private clsLocalNews As GetLocalNews
	Private clsLoadingIndicator As LoadingIndicator
	
	Private lblStationName, lblAddress, lblZip, lblCity As Label
	Private lblTwitter, lblFacebook, lblUrl, lblMagni As Label
	Private lblItemFound, lblOpenHours, lblNumber, lvlFav As Label
	Private pnlOpenHours, pnlFind, pnlStation As Panel
	Private pnlTwitter, pnlFacebook, pnlUrl, pnlWijkAgent, pnlLocalNews As Panel
	Private edtFind, edtDummyForFocus As EditText
	Private imgFav As ImageView
	Private btnClose As Button
	Private lblDossier As Label
	Private bscrStationName As BBScrollingLabel
	Private ASSegmentedTab1 As ASSegmentedTab
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsDb.Initialize
	clsStationData.Initialize(clsLoadingIndicator, Activity)
	clsLocalNews.Initialize
	CardLayoutsCache.Initialize
	
	Activity.LoadLayout("stationMain")
	clsLoadingIndicator.Initialize(Activity)
	
	'ASSegmentedTab1.Base.SetColorAndBorder(ASSegmentedTab1.Base.Color,0,0,10dip)
	ASSegmentedTab1.Base.SetColorAndBorder(0xff000000,0,0,10dip)
	ASSegmentedTab1.AddTab("",ASSegmentedTab1.FontToBitmap(Chr(0xE88A),True,25,xui.Color_Yellow))
	ASSegmentedTab1.AddTab("",ASSegmentedTab1.FontToBitmap(Chr(0xE906),True,25,xui.Color_Yellow))
	ASSegmentedTab1.AddTab("",ASSegmentedTab1.FontToBitmap(Chr(0xE24D),True,25,xui.Color_Yellow))
	ASSegmentedTab1.AddTab("Test",Null)
	ASSegmentedTab1.AddTab("",ASSegmentedTab1.FontToBitmap(Chr(0xE238),True,15,xui.Color_Yellow))
	ASSegmentedTab1.AddTab("",ASSegmentedTab1.FontToBitmap(Chr(0xE23F),True,15,xui.Color_Yellow))
'	ASSegmentedTab1.SelectionPanel.SetColorAndBorder(ASSegmentedTab1.SelectionPanel.Color,0,0,10dip)'makes the selector rounded
	ASSegmentedTab1.SelectionPanel.SetColorAndBorder(0xFF0000FF,0,0,10dip)'makes the selector rounded
	PCLV.Initialize(Me, "PCLV", clvStation)
	GetStation
	TextEngine.Initialize(pnlOpenHours)
	
	ime.Initialize("IME")
	ime.AddHandleActionEvent(edtFind)
	edtFind.InputType = Bit.Or(edtFind.InputType, 0x00080000)
	GenFunctions.ResetUserFontScale(Activity)
	Activity.RequestFocus
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
		PCLV.AddItem(170dip, xui.Color_White, st)
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
	Dim pnlHeight, pnlTop, pnlCount As Int
	Dim cs As CSBuilder
	Dim city As String
	
	pnlCount = 0
	For Each i As Int In PCLV.VisibleRangeChanged(FirstIndex, LastIndex)
		If pnlCount = 0 Then
			pnlHeight = 200dip
			pnlTop = 10dip
		Else
			pnlHeight = 170dip
			pnlTop = 0dip
		End If
		Dim item As CLVItem = clvStation.GetRawListItem(i)
		Dim station As station = item.Value
		Dim pnl As B4XView = xui.CreatePanel("")
		
		
		item.Panel.AddView(pnl, 0, 0, width, pnlHeight)
		pnl.LoadLayout("clvStation")
		
		SetScrollStationName(station.name, pnl, bscrStationName)

		pnlStation.Top = pnlTop
		cs.Initialize.Color(0xFF00FFFF).Append(station.address).Append(CRLF).Append(station.postalcode).Append(" ").pop
		cs.Color(Colors.Yellow).Append(station.city).PopAll
		
'		lblStationName.Text = station.name
		
		lblAddress.Text =  cs
		city = $"${station.postalcode} ${station.city}"$
		If city.Length < 5 Then
			lblAddress.textColor = Colors.Yellow
			lblAddress.Typeface = Typeface.LoadFromAssets("VeraMono-Italic.ttf")
			lblAddress.Text = "Geen adresgevens..."
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
		If station.fav_id <> Null Then
			lvlFav.TextColor = 0xFF7FFF00
		Else
			lvlFav.TextColor = Colors.Gray
		End If
		SetImgFav(station.fav_id <> Null, imgFav)
		GenFunctions.ResetUserFontScale(pnl)
	Next
	
End Sub

Private Sub SetScrollStationName(name As String, pnl As Panel, scrollLabel As BBScrollingLabel)
	Dim bbScrTextEngine As BCTextEngine
	
	bbScrTextEngine.Initialize(pnl)
	bbScrTextEngine.CustomFonts.Put("veramono",xui.CreateFont(Typeface.CreateNew(Typeface.LoadFromAssets("VeraMono.ttf"), Typeface.STYLE_NORMAL), 19)) 'size not important
	scrollLabel.TextEngine = bbScrTextEngine
	scrollLabel.WidthPerSecond=Rnd(90, 130)
	scrollLabel.Gap = 100
	scrollLabel.Text = $"[font=veramono][color=yellow] [TextSize=19]${name}[/textsize][/color][/font]"$
	scrollLabel.StartPositionDelay = 10
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
		edtFind.RequestFocus
		ime.ShowKeyboard(edtFind)
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
	clsLoadingIndicator.ShowIndicator("Ophalen gegevens wijkagenten..")
	'ProgressDialogShow2("Ophalen gegevens wijkagent(en)..", False)
	'Sleep(300)	
	stationData = clvStation.GetValue(clvStation.GetItemFromView(pnl))
	Wait For (clsStationData.GetWijkAgent(stationData.longtitude, stationData.latitude)) Complete (lstWijkAgent As List)
	'ProgressDialogHide
	
	If lstWijkAgent.Size > 0 Then
		StartActivity(wijkAgentMain)
		CallSubDelayed3(wijkAgentMain, "GetWijkAgent", lstWijkAgent, stationData.name)
	End If
	clsLoadingIndicator.HideIndicator
End Sub

Sub GetStationData(p As Panel) As station
	Return clvStation.GetValue(clvStation.GetItemFromView(p))
End Sub

Sub pnlLocalNews_Click
	Dim pnl As Panel = Sender
'	clsLoadingIndicator.ShowIndicator("Ophalen lokaal nieuws")
	Starter.localNewsOffset = 0
	GenFunctions.stationData = clvStation.GetValue(clvStation.GetItemFromView(pnl))
	StartActivity(lokaalNieuws)	
'	clsLoadingIndicator.HideIndicator
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

Sub lvlFav_Click
	Dim lbl As Label = Sender
	Dim stationData As station
	Dim psId As String
	Dim addStationFav As Boolean
	
	stationData = clvStation.GetValue(clvStation.GetItemFromView(lbl.Parent))
	psId = stationData.ps_id
	
	addStationFav = clsDb.CheckFavIfStationIsInFav(psId)
	If addStationFav Then
		lbl.TextColor = 0xFF7FFF00 '0XFF00FFFF
		GenFunctions.createCustomToast("Bureau als favoriet ingesteld", Colors.Blue)
	Else
		GenFunctions.createCustomToast("Bureau geen favoriet meer", Colors.Blue)
		lbl.TextColor = Colors.Red
	End If
	
	
End Sub

Private Sub lblDossier_Click
	StartActivity(dossierMain)
End Sub