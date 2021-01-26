B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=10.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals
	Private xui As XUI
End Sub

Sub Globals
	Private clsLoadingIndicator As LoadingIndicator
	Private ClsDossier As ClassDossier
	Private clsBbHeight As GetBbCodeViewHeight
	Private TextEngine As BCTextEngine
	Private lblHeader As Label
	Private clvDossier As CustomListView
	Private lblPrev As Label
	Private lblNext As Label
	Private lblDelictDate As Label
	Private lblLocation As Label
	Private lblPubDate As Label
	Private lblShowDetail As Label
	Private lblTitle As Label
	Private pnlDossierItem As Panel
	Private bbIntroductiontext As BBCodeView
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsLoadingIndicator.Initialize(Activity)
	ClsDossier.Initialize
	clsBbHeight.Initialize
	Activity.LoadLayout("dossierMain")
	TextEngine.Initialize(Activity)
	
	GetData
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetData
	clvDossier.Clear
	clsLoadingIndicator.ShowIndicator("Ophalen dossiers, even geduld..")
	Sleep(200)
'	Log($"${Starter.urlDossier}${Starter.dossierOffset}"$)
	Wait For (ClsDossier.GetData($"${Starter.urlDossier}${Starter.dossierOffset}"$)) Complete(lst As List)
	
	SetNextPrevButtons
	
	For Each dossierItem As dossier In lst
		clvDossier.Add(SetData(dossierItem), dossierItem)
	Next
	
	Wait For(clsLoadingIndicator.HideIndicator) complete (done As Boolean)
End Sub

Private Sub SetNextPrevButtons
	If Starter.dossierOffsetEnd = False Then
		lblNext.Visible = True
	Else
		lblNext.Visible = False
	End If
If Starter.dossierOffset > 0 And Starter.dossierOffsetEnd = False Then 
		lblPrev.Visible = True
	Else
		lblPrev.Visible = False
	End If
End Sub

Private Sub SetData(item As dossier) As Panel
	Dim pnl As B4XView = xui.CreatePanel("")
	
	pnl.SetLayoutAnimated(0, 0, 0, clvDossier.AsView.Width, 320dip)
	pnl.LoadLayout("pnlDossier")
	TextEngine.Initialize(pnl)
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	
	If item.plaatsDelict.Length < 4 Then
		lblLocation.Text = "Locatie onbekend"
	Else
		lblLocation.Text = item.plaatsDelict
	End If
	lblTitle.Text = item.titel
	lblPubDate.Text = $"${GenFunctions.ParseStringDate( item.publicatieDatum, "d")}"$
	lblDelictDate.Text = $"${GenFunctions.ParseStringDate(item.datedelict, "d")}"$

	pnl.Height =  clsBbHeight.GetHeight(bbIntroductiontext, item.introductie) + 200dip
	bbIntroductiontext.Text = item.introductie
	Dim pHeight As Int = clsBbHeight.SetMainPanelHeigth(pnl) 'ignore
	lblShowDetail.Top = pHeight - 40dip

	
	bbIntroductiontext.Text = GenFunctions.ParseHtmlTextBlock("", item.introductie, "", "")
	Return pnl
End Sub

Private Sub lblShowDetail_Click
	Dim lbl As Label = Sender
	Dim data As dossier = clvDossier.GetValue(clvDossier.GetItemFromView(lbl.Parent))
	Starter.dossierUid = data.uid
	StartActivity(dossierDetail)
End Sub

Private Sub lblPrev_Click
	Starter.dossierOffset = Starter.dossierOffset - 10
	GetData
End Sub

Private Sub lblNext_Click
	Starter.dossierOffset = Starter.dossierOffset + 10
	GetData
End Sub