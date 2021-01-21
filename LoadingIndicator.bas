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
	Private busyIndicator As B4XLoadingIndicator
	Dim pnl As B4XView 
End Sub

Public Sub Initialize(act As Activity)
	passedActivity = act
	pnl = xui.CreatePanel("")
	pnl.Visible = False
	CreateIndicator
End Sub

Public Sub CreateIndicator
	
	
	pnl.SetLayoutAnimated(0, 0, 0, passedActivity.Width, 120dip)
	pnl.LoadLayout("loadingPanel")
	TextEngine.Initialize(pnl)
	TextEngine.KerningEnabled = Not(TextEngine.KerningEnabled)
	
	passedActivity.AddView(pnl, 0dip, (100%y/2)-60, passedActivity.Width, 120dip)
	busyIndicator.Show
	
End Sub

Public Sub ShowIndicator(msg As String)
	bbLoadingMessage.Text = msg
	pnl.Visible = True
	
End Sub

Public Sub HideIndicator
	pnl.Visible = False
End Sub