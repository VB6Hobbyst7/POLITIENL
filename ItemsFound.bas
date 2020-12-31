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
	Private xui As XUI
End Sub

Sub Globals
	Private TextEngine As BCTextEngine
	Dim clsItemOwner As ItemOwner
	Dim url As String = $"https://api.politie.nl/v4/gezocht/eigenaargezocht?language=nl&radius=5.0&maxnumberofitems=10&offset=_items"$
	Private lblLocation As Label
	Private lblTitle As Label
	Private pnlItemFound As Panel
	Private clvItemFound As CustomListView
	Private lblDate As Label
	Private bbItemDescription As BBCodeView
	Private btnPrev As Button
	Private btnNext As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Dim cd As ColorDrawable
	cd.Initialize(Colors.RGB(255,255,255),3dip)
	clsItemOwner.Initialize
	Activity.LoadLayout("ItemFoundMain")
	
	btnPrev.Background = cd
	btnNext.Background = cd
	
	GetItems
	
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetItems
	ProgressDialogShow2("Items ophalen", False)
	Sleep(200)
	SetItemsOffset
	clvItemFound.Clear
	wait for (clsItemOwner.GetData(SetItemsOffset, True)) Complete (lst As List)
	
	If lst.Size = 0 Then
		HideProgressDialog
		GenFunctions.createCustomToast("Niets gevonden", Colors.Blue)
		Return
	End If
	
	GenList(lst)
	
	btnNext.Visible = Not(Starter.itemsFoundOffsetEnd)
	btnPrev.Visible = Starter.itemsFoundOffset >= 10
	HideProgressDialog
End Sub

Private Sub HideProgressDialog
	ProgressDialogHide
End Sub

Private Sub SetItemsOffset As String
	Dim newUrl As String = url.Replace("_items", Starter.itemsFoundOffset)
	Return newUrl
	
End Sub

Private Sub GenList(lst As List)
	Dim pnl As Panel
	
	For Each item As foundItemList In lst
		pnl = AddItem(item)
		GenFunctions.ResetUserFontScale(pnl)
		clvItemFound.Add(pnl, item)
	Next
	
End Sub

Private Sub AddItem(item As foundItemList) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	Dim pnlBbHeight, pnlDiff As Int 
	
	pnl.SetLayoutAnimated(0, 0, 0, clvItemFound.AsView.Width, 280dip)
	pnl.LoadLayout("clvItemFound")

	TextEngine.Initialize(pnl)
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	bbItemDescription.Text = item.description
	pnlBbHeight = bbItemDescription.mBase.Height
	
	pnlDiff = bbItemDescription.Paragraph.Height - pnlBbHeight

	Dim ContentHeight As Int = Min(bbItemDescription.Paragraph.Height / TextEngine.mScale + bbItemDescription.Padding.Top + bbItemDescription.Padding.Bottom, bbItemDescription.mBase.Height)
	bbItemDescription.sv.ScrollViewContentHeight = ContentHeight+20dip
	bbItemDescription.mBase.Height = bbItemDescription.sv.Height
	pnl.Height = bbItemDescription.mBase.Height + 120dip
	
	lblLocation.Text = item.location
	lblTitle.Text = item.title
	lblDate.Text = GenFunctions.ParseStringDate(item.pubData, "d")
	Return pnl
End Sub

Sub pnlItemFound_Click
	
End Sub



Sub btnPrev_Click
	If Starter.itemsFoundOffset = 0 Then Return
	
	Starter.itemsFoundOffset = Starter.itemsFoundOffset - 10
	GetItems
End Sub

Sub btnNext_Click
	Starter.itemsFoundOffset = Starter.itemsFoundOffset + 10
	GetItems
End Sub