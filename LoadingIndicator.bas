B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private passedActivity As Activity
	Private xui As XUI
	Private TextEngine As BCTextEngine
	Private bbLoadingMessage As BBLabel
	Private pnl As B4XView
	
	Public loadingText As String 
	
	Private lblDateTime As Label
End Sub

Public Sub Initialize(act As Activity)
	passedActivity = act
	pnl = xui.CreatePanel("")
	pnl.Visible = False
	CreateIndicator
End Sub

Public Sub CreateIndicator
	Dim aWidth As Long = passedActivity.Width
	
	pnl.SetLayoutAnimated(0, 0, 0, aWidth, 120dip)
	pnl.LoadLayout("loadingPanel")
	TextEngine.Initialize(pnl)
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	
	passedActivity.AddView(pnl, 0dip, (100%y/2)-60, aWidth, 120dip)
End Sub

Public Sub ShowIndicator(msg As String)
	lblDateTime.Text = $"$DateTime{DateTime.Now}"$
	loadingText = msg
	bbLoadingMessage.Text = loadingText
	If pnl.Visible = False Then
		pnl.SetVisibleAnimated(0, True)
		End If
	Sleep(1)
End Sub

Public Sub HideIndicator As ResumableSub
	pnl.SetVisibleAnimated(0, False)
	Return True
End Sub