B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Private textEngine As BCTextEngine
	Private xui As XUI
End Sub

Public Sub Initialize
	
End Sub

Sub GetHeight (bbView As BBCodeView, txt As String) As Int
	textEngine.Initialize(xui.CreatePanel(""))

	bbView.Text = txt
	bbView.sv.Height = bbView.sv.ScrollViewContentHeight + 10dip
	bbView.mBase.Height = bbView.sv.Height
	Return bbView.sv.Height+0dip
End Sub

Sub SetMainPanelHeigth(pnl As Panel) As Int
	Dim p As Panel
	For Each v As View In pnl.GetAllViewsRecursive
		If v Is Panel Then
			p = v
			p.Height = pnl.Height-10dip
			Return p.Height
		End If
	Next
	Return pnl.Height-10dip
End Sub