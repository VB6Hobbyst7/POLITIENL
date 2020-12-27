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
	Dim url As String = $"https://api.politie.nl/v4/gezocht/eigenaargezocht?language=nl&radius=5.0&maxnumberofitems=10&offset=${Starter.itemsFoundOffset}"$
	Private lblLocation As Label
	Private lblTitle As Label
	Private pnlItemFound As Panel
	Private clvItemFound As CustomListView
	Private lblDate As Label
	Private bbItemDescription As BBCodeView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsItemOwner.Initialize
	Activity.LoadLayout("ItemFoundMain")
	
	GetItems
	
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetItems
	Dim pnl As Panel
	clvItemFound.Clear
	wait for (clsItemOwner.GetData(url, True)) Complete (lst As List)
	
	If lst.Size = 0 Then
		GenFunctions.createCustomToast("Niets gevonden", Colors.Blue)
		Return
	End If
	
	For Each item As foundItemList In lst
		pnl = AddItem(item)
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
	Log($"PNL HEIGHT BEFORE ${bbItemDescription.sv.ScrollViewContentHeight}"$)
	pnl.Height = bbItemDescription.mBase.Height + 120dip
Log($"PNL HEIGHT After ${pnl.Height}"$)
	
	lblLocation.Text = item.location
	lblTitle.Text = item.title
	lblDate.Text = GenFunctions.ParseStringDate(item.pubData)
'	bbItemDescription.Text = item.description
	Return pnl
End Sub

Private Sub GetMoreItems
	'SEE IF THE ARE MORE ITEMS
	Starter.itemsFoundOffset = Starter.itemsFoundOffset + 10
End Sub

Sub pnlItemFound_Click
	
End Sub

