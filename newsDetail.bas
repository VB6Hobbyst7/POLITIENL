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

End Sub

Sub Globals
	Dim access As Accessibility
	Private bbNewsDetail As BBCodeView
	Private TextEngine As BCTextEngine
	Private lblDate As Label
	Private lblArea As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("newsDetail")
	TextEngine.Initialize(Activity)
	GenFunctions.ResetUserFontScale(Activity)
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub SetNewsText(newsDetailText As String)
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	bbNewsDetail.Text = newsDetailText
'	bbNewsDetail.sv.TextSize =  bbNewsDetail.sv.TextSize / access.GetUserFontScale
	GenFunctions.ResetUserFontScale(Activity)
End Sub

Sub SetNewsdate(date As String)
	lblDate.Text = date
End Sub

Sub SetNewsArea(area As String)
	lblArea.Text = area
End Sub

Sub bbNewsDetail_LinkClicked(url As String)
	GenFunctions.OpenUrl(url)
End Sub

