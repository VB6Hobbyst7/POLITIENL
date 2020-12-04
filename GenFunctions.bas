B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=10.2
@EndOfDesignText@
Sub Process_Globals
	Dim stationData As station
	Private access As Accessibility

End Sub

Sub UUIDv4 As String 'ignore
	Dim sb As StringBuilder
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			If sb.Length = 19 Then c = Asc("8")
			If sb.Length = 14 Then c = Asc("4")
			sb.Append(Chr(c))
		Next
	Next
	Return sb.ToString.ToLowerCase
End Sub

Sub createCustomToast(txt As String, color As String)
	Dim cs As CSBuilder
	cs.Initialize.Typeface(Typeface.LoadFromAssets("Arial.ttf")).Color(Colors.White).Size(16).Append(txt).PopAll
	ShowCustomToast(cs, False, color)
End Sub

Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	'uncomment to show toast in the center:
	'  toast.RunMethod("setGravity", Array( _
	' Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
End Sub

Sub OpenUrl(url As String)
	Dim i As Intent
	i.Initialize(i.ACTION_VIEW, url)
	StartActivity(i)
End Sub

Sub ParseStringDate(strDate As String) As String
	Dim dateStr() As String = Regex.Split(" ", strDate)
	Dim dateAsString, timeAsString As String
	Dim parsedDate As Long
	
	dateAsString = dateStr(0)
	timeAsString = dateStr(1)
	
	DateTime.DateFormat = "yy-MM-dd"
	parsedDate = DateTime.DateParse(dateAsString)
	DateTime.DateFormat = "dd MMMM yyyy"
	Return $"$Date{parsedDate} ${timeAsString.SubString2(0,5)}"$
End Sub

Sub ResetUserFontScale(p As Panel)
	For Each v As View In p
		If v Is Panel Then
			ResetUserFontScale(v)
		Else If v Is Label Then
			Dim lbl As Label = v
			lbl.TextSize = lbl.TextSize / access.GetUserFontScale
		Else If v Is Spinner Then
			Dim s As Spinner = v
			s.TextSize = s.TextSize / access.GetUserFontScale
		End If
	Next
End Sub

Sub ShowLocationOnGoogleMaps(lat As Double, lon As Double)
	Dim gMapIntent As Intent
	Dim uri As String
	
	uri = $"geo:${lat}, ${lon}?q=${lat}, ${lon},18z/data=!5m1!1e1"$
	
	gMapIntent.Initialize(gMapIntent.ACTION_VIEW,uri)
	gMapIntent.SetComponent("googlemaps")
	StartActivity(gMapIntent)
	
End Sub