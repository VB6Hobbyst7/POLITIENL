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
	Private bbNewsDetail As BBCodeView
	Private TextEngine As BCTextEngine
	Private lblDate As Label
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
	bbNewsDetail.Text = newsDetailText
	GenFunctions.ResetUserFontScale(Activity)
End Sub

Sub SetNewsdate(date As String)
	lblDate.Text = date
End Sub

Sub bbNewsDetail_LinkClicked(url As String)
	GenFunctions.OpenUrl(url)
End Sub

