B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.9
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	Public filePath, itemFoundUid, dossierUid As String
	Private rp As RuntimePermissions
	Public sql As SQL
	Public localNewsOffset, itemsFoundOffset, dossierOffset As Int = 0
	Public localNewsOffsetEnd, itemsFoundOffsetEnd, dossierOffsetEnd As Boolean
	Private clsDb As dbFunctions
	
	Public urlOwnerItem As String	= "https://api.politie.nl/v4/gezocht/eigenaargezocht?language=nl&radius=5.0&maxnumberofitems=10&offset="
	Public urlDossier As String		= "https://api.politie.nl/v4/gezocht/dossiers?language=nl&radius=5.0&maxnumberofitems=10&offset="
End Sub

Sub Service_Create
	GetSetFilepath
	clsDb.Initialize
	CheckDatabaseExists

End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
#if debug
	Log(StackTrace)
#end if	
	Return True
End Sub

Sub Service_Destroy

End Sub

Private Sub GetSetFilepath
	Dim getFilePath() As String = rp.GetAllSafeDirsExternal("")
	filePath = getFilePath(0)
End Sub

Sub CheckDatabaseExists
	If File.Exists(filePath, "politie.db") = False Then
		File.Copy(File.DirAssets, "politie.db", filePath, "politie.db")
	End If
	clsDb.CheckIfFavStationExists
End Sub
