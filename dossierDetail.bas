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
	Private clsDossier As ClassDossier
	Private TextEngine As BCTextEngine
	Private lblPlaatsDelict As Label
	Private lblDelictDate As Label
	Private lblTitel As Label
	Private bbDossierDetail As BBCodeView
	Private pnlZoomImage As Panel
	Private ZoomImage As ZoomImageView
	Private lblClose As Label
	Private lblCaseNr As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("dossierDetail")
	TextEngine.Initialize(Activity)
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	clsDossier.Initialize
	GetDetailDossier
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If pnlZoomImage.Visible Then
			pnlZoomImage.SetVisibleAnimated(200, False)
			Return True
		End If
	End If
	
	Return False
End Sub

Sub GetDetailDossier
'	Log($"${Starter.urlDossier}${Starter.dossierOffset}"$)
	Wait For (clsDossier.GetData($"${Starter.urlDossier}${Starter.dossierOffset}"$)) Complete(dataLst As List)
	
	SetData(dataLst)
	
End Sub

Private Sub SetData(dataLst As List)
	Dim data As dossierDetail = dataLst.Get(0)
	
	lblTitel.Text = data.titel
	lblPlaatsDelict.Text = data.dossierPlaatsDelict
	lblDelictDate.Text = GenFunctions.ParseStringDate(data.dossierDatumDelict, "d")
	lblCaseNr.Text = data.zaakNummer
	bbDossierDetail.Text = GenFunctions.ParseHtmlTextBlock("", data.DossierText, "", data.afbeeldingUrl)
End Sub

Private Sub bbDossierDetail_LinkClicked (url As String)
	'show image in zoomview
	If url.IndexOf(".png") <> -1 Or url.IndexOf(".jpg") <> -1 Then
		GetImageForZoomView(url)
	Else
		GenFunctions.OpenUrl(url)	
	End If
End Sub

Private Sub pnlZoomImage_Click
	
End Sub

Private Sub lblClose_Click
	pnlZoomImage.SetVisibleAnimated(200, false)
End Sub

Private Sub GetImageForZoomView(imgUrl As String)
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(imgUrl)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		ZoomImage.SetBitmap(job.GetBitmap)
		ZoomImage.ImageView.GetBitmap.Resize(pnlZoomImage.Width, pnlZoomImage.Height, True)
		pnlZoomImage.SetVisibleAnimated(400, True)
	End If
	
	job.Release
End Sub