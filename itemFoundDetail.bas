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
	Dim xui As XUI
End Sub

Sub Globals
	Private loadingImages As Boolean
	Private textView As BCTextEngine
	Dim clickedImage As Bitmap
	Dim selectedImage As ImageView
	Dim imgRotate As Float = 0
	Dim clsItemDetail As itemOwnerDetail
'	Dim lstImages As List
	Dim urlItems As String
	Private lblStationName As Label
	Private bbDescription As BBCodeView
	Private clvImage As CustomListView
	Private imgItem As ImageView
	Private pnlImg As Panel
	Private imgZoom As ZoomImageView
	Private pnlimgContainer As Panel
	Private lblRotate As Label
	Private pnlThumbnail As Panel
	Private lblImgNumber As Label
	Private lblImgCounter As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	clsItemDetail.Initialize
	'***
	Activity.LoadLayout("itemFoundDetail")
	textView.Initialize(Activity)
	textView.KerningEnabled = Not(textView.KerningEnabled)
	imgZoom.ImageView.Height = pnlImg.Height
	GetItemDetail
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If loadingImages Then
			loadingImages = False
			Return True
		End If
	End If
	
	Return False
End Sub

Sub GetItemDetail
	Dim tipUrl, itemDescription, itemQuestion As String 'ignore
	clvImage.Clear
	
'	urlItems = $"https://api.politie.nl/v4/gezocht/eigenaargezocht?language=nl&radius=5.0&maxnumberofitems=10&offset=${Starter.itemsFoundOffset}"$
	urlItems = $"${Starter.urlOwnerItem}${Starter.itemsFoundOffset}"$
	Wait For (clsItemDetail.GetData(urlItems, Starter.itemFoundUid)) Complete (done As Boolean)
	

	
	itemDescription = GenFunctions.ParseHtmlTextBlock("", $"${clsItemDetail.itemFoundData.description.Trim}${""}"$, "")
	itemQuestion = GenFunctions.ParseHtmlTextBlock("", $"${clsItemDetail.itemFoundData.questionOwner.Trim}${""}"$, "")
	tipUrl = GenFunctions.ParseHtmlTextBlock("", GetSetTipUrl(clsItemDetail.itemFoundData.urlTipFormulier.Trim), "")

	itemDescription = $"${CreateHeader("Omschrijving")}${itemDescription}"$
	itemQuestion = $"${CreateHeader("Vraag")}${itemQuestion}"$
	tipUrl = $"${CreateHeader("Heeft u informatie")}${tipUrl}"$

	bbDescription.Text = $"${itemDescription}${CRLF}${itemQuestion}${CRLF}${tipUrl}"$
	
	If done Then
		GetSetImages
	End If
	
End Sub

Private Sub CreateHeader(headerText As String) As String
	Return $"[Span MinWidth=100%x Alignment=center][TextSize=19][color=#FFFFF00]${headerText}[/color][/TextSize][/Span]"$
	 
End Sub

Sub GetSetTipUrl(tipUrl As String) As String
	If tipUrl.Length > 0 And tipUrl.IndexOf("http") > -1 Then
		Return $"<a href="${tipUrl}">Klik hier om het "Tip formulier" te openen</a>"$
	End If
	Return "noUrl"
End Sub

Sub GetSetImages
	Dim imgCount As Int = 1
	loadingImages = True
	lblImgCounter.SetVisibleAnimated(0, True)
	For Each imageUrl As String In clsItemDetail.lstMeerafbeeldingen
		Wait For (GetImageFromUrl(imageUrl, imgCount)) Complete (done As Boolean)
		
		If loadingImages = False Then
			Exit
		End If
				
		lblImgCounter.Text = $"Laden afbeelding ${NumberFormat(imgCount, 3 ,0)} van ${NumberFormat(clsItemDetail.lstMeerafbeeldingen.Size, 3 ,0)}"$
		imgCount = imgCount + 1
		
	Next
	Sleep(200)
	lblImgCounter.SetVisibleAnimated(1000, False)
	loadingImages = False
End Sub

Sub GetImageFromUrl(imgUrl As String, imgCount As Int)As ResumableSub
	Private job As HttpJob
	job.Initialize("", Me)
	job.Download(imgUrl)
	
	Wait For (job) jobDone(jobDone As HttpJob)
	
	If jobDone.Success Then
		
		Dim pnl As B4XView = xui.CreatePanel("")
	
		pnl.SetLayoutAnimated(0, 0, 5dip, 110dip, 110dip)
		pnl.LoadLayout("pnlItemImage")
		
		imgItem.Bitmap = job.GetBitmap
		imgItem.Gravity = Gravity.FILL
		lblImgNumber.Text = NumberFormat(imgCount, 3 ,0)
		
		clvImage.Add(pnl, "")
		Else
			Log(job.ErrorMessage)
	End If
	
		job.Release
		Return True
End Sub


Private Sub imgItem_Click
	selectedImage = Sender
	imgRotate = 0
	Dim clickedImg As ImageView = Sender
	clickedImage.Initialize3(clickedImg.Bitmap)
	
	imgZoom.SetBitmap(clickedImg.Bitmap)
	imgZoom.ImageView.GetBitmap.Resize(pnlimgContainer.Width, pnlimgContainer.Height, True)
	
	pnlImg.SetVisibleAnimated(500, True)
	clvImage.ScrollToItem(clvImage.GetItemFromView(clickedImg.Parent))
	ImgPanelYellowBorder(Sender)
End Sub

Private Sub pnlImg_Click
	pnlImg.SetVisibleAnimated(500, False)
	SelectedImgPanelNoYellowBorder(selectedImage)
End Sub

Private Sub lblRotate_Click
	Dim bmRotate As B4XBitmap
	bmRotate = clickedImage
	If imgRotate = 360 Then
		imgRotate = 0
	Else
		imgRotate = imgRotate + 90
	End If
	imgZoom.SetBitmap(bmRotate.Rotate(imgRotate))
	imgZoom.ImageView.GetBitmap.Resize(pnlimgContainer.Width, pnlimgContainer.Height, True)
End Sub

Sub ImgPanelYellowBorder(img As ImageView)
	Dim p As Panel = img.Parent
	Dim c As ColorDrawable
	ClearPanelBorders
	c.Initialize2(Colors.Transparent,0dip,2dip,Colors.Yellow)
	p.Background = c

End Sub

Sub SelectedImgPanelNoYellowBorder(img As ImageView)
	Dim p As Panel = img.Parent
	Dim c As ColorDrawable
'	ClearPanelBorders
	c.Initialize2(Colors.Transparent,0dip,0dip,Colors.Yellow)
	p.Background = c

End Sub

Sub ImgPanelNoBorder(p As Panel)
	Dim c As ColorDrawable
	Dim iPanel As Panel
	For Each v As View In p.GetAllViewsRecursive
		If v Is Panel Then
			iPanel = v
			c.Initialize2(Colors.Transparent,0dip,0dip,Colors.Red)
			iPanel.Background = c
		End If
	Next
	
	
End Sub

Sub ClearPanelBorders
	For i = 0 To clvImage.Size -1
		ImgPanelNoBorder(clvImage.GetPanel(i))
	Next
	
End Sub

Private Sub bbDescription_LinkClicked (url As String)
	GenFunctions.OpenUrl(url)
End Sub