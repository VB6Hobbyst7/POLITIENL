B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'Select pl.*, fs.ps_id As 'fav' from police pl
'LEFT JOIN favstation fs on
'fs.ps_id = pl.ps_id
'WHERE pl.name like "%zaa%" Or fs.ps_id Not Null
'ORDER by fs.ps_id DESC, pl.name Asc


Sub Class_Globals
	Private qry As String
	Private rs As ResultSet
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub dbInitialized
	If Starter.sql.IsInitialized = False Then
		Starter.sql.Initialize(Starter.filePath, "politie.db", False)
	End If
End Sub

Sub CheckIfFavStationExists
	dbInitialized
	
	qry = $"SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='favstation';"$
	Dim count As Int = Starter.sql.ExecQuerySingleResult(qry)
	
	If count = 1 Then
		Return
	End If
	
	qry = $"CREATE TABLE IF NOT EXISTS "favstation" (
	"id"	TEXT,
	"ps_id"	TEXT NOT NULL,
	PRIMARY KEY("id")
);"$
	Starter.sql.ExecNonQuery(qry)
	qry = $"CREATE INDEX "idx_favstation" ON "favstation" (
	"ps_id"	ASC
);"$
	Starter.sql.ExecNonQuery(qry)
	
End Sub


Sub CheckFavIfStationIsInFav(id As String) As Boolean
	dbInitialized
	Dim favCount As Int
	
	qry = $"SELECT count(*) as inFav FROM favstation WHERE ps_id=?"$
	favCount = Starter.sql.ExecQuerySingleResult2(qry, Array As String(id))
	
	If favCount <> 0 Then
		qry = $"DELETE FROM favstation WHERE ps_id=?"$
		Starter.sql.ExecNonQuery2(qry, Array As String(id))
		Return False
	Else
		qry = $"INSERT INTO favstation (id, ps_id) VALUES (?, ?)"$	
		Starter.sql.ExecNonQuery2(qry, Array As String(GenFunctions.UUIDv4, id))
		Return True
	End If
End Sub


#Region ClearDbs
Sub CleanPoliceDb
	dbInitialized
	qry = $"DELETE FROM police"$
	Starter.sql.ExecNonQuery(qry)
End Sub

Sub CleanOpenHoursDb
	dbInitialized
	qry = $"DELETE FROM openinghours"$
	Starter.sql.ExecNonQuery(qry)
End Sub

Sub CleanSocialMediaDb
	dbInitialized
	qry = $"DELETE FROM socialmedia"$
	Starter.sql.ExecNonQuery(qry)
End Sub

Sub CleanAddressDb
	dbInitialized
	qry = $"DELETE FROM address"$
	Starter.sql.ExecNonQuery(qry)
End Sub

#End Region

Sub AddPoliceStations(lstPsStation As List)
	dbInitialized
	
	Starter.sql.BeginTransaction
	For Each station As psStation In lstPsStation
		If CheckRecordExists(station.uid,"police", "ps_id") = 1 Then
			Continue
		End If
		qry = $"INSERT INTO police (ps_id, name, longtitude, latitude) VALUES (?, ?, ?, ?)"$
		Starter.sql.ExecNonQuery2(qry, Array As String(station.uid, station.naam, station.longtitude, station.latitude))
		AddOpenhours(station.uid, station.openHours)
	Next
	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
End Sub

Sub AddOpenhours(ps_id As String, hours As String)
	qry = $"INSERT INTO openinghours (id, ps_id, opening_hours) VALUES (?, ?, ?)"$
	Starter.sql.ExecNonQuery2(qry, Array As String(GenFunctions.UUIDv4, ps_id, GenFunctions.ParseHtmlTextBlock("", hours, "", "").Trim))
End Sub

Sub AddSocialmedia(lstPsSocialMedia As List)
	dbInitialized
	Starter.sql.BeginTransaction
	For Each media As psSocialMedia In lstPsSocialMedia
		If CheckSocMediaExists(media.psId,media.url, media.media) = 1 Then
			Continue
		End If
		qry = $"INSERT INTO socialmedia (ps_id, url, media_type) VALUES(?, ?, ?)"$
		Starter.sql.ExecNonQuery2(qry, Array As String(media.psId, media.url, media.media))
	Next
	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
End Sub

Sub AddAdress(lstAddress As List)
	dbInitialized
	
	Starter.sql.BeginTransaction
	For Each addr As psAdress In lstAddress
		If CheckAdresExists(addr.psId, addr.address, addr.postcode, addr.addressTypes) = 1 Then
			Continue
		End If
		qry = "insert into address (ps_id, adress_type, address, postalcode, city) VALUES(?,?,?,?,?)"
		Starter.sql.ExecNonQuery2(qry, Array As String(addr.psId, addr.addressTypes, addr.address, addr.postcode, addr.city))
	Next
	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
End Sub

Private Sub CheckRecordExists(psId As String, table As String, column As String) As Int
	qry = $"select count(${column}) as count from ${table} where ${column} = ?"$
	
	Return Starter.sql.ExecQuerySingleResult2(qry, Array As String(psId))
End Sub

Private Sub CheckSocMediaExists(psId As String, url As String, mediatype As String) As Int
	qry = $"select count(ps_id) as count from socialmedia where ps_id = ? AND url = ? AND media_type = ?"$
	
	Return Starter.sql.ExecQuerySingleResult2(qry, Array As String(psId, url, mediatype))
End Sub

Private Sub CheckAdresExists(psId As String, address As String, postalcode As String, addressType As String) As Int
	qry = $"select count($ps_id) as count from address where ps_id = ? AND address = ? AND postalcode = ? AND adress_type = ?"$
	
	Return Starter.sql.ExecQuerySingleResult2(qry, Array As String(psId, address,  postalcode, addressType))
End Sub

Sub GetFindStationList(hint As String) As List
	dbInitialized
	Dim lstStation As List
	Dim searchStr As String = $"%${hint}%"$
	
	qry = $"SELECT pc.ps_id as id, pc.name as name, pc.latitude as lat, pc.longtitude as long
,ad.address, ad.postalcode
,(SELECT url FROM socialmedia where ps_id = pc.ps_id AND media_type = 'url') as url
,(SELECT url FROM socialmedia where ps_id = pc.ps_id AND media_type = 'twitter') as twitter
,(SELECT url FROM socialmedia where ps_id = pc.ps_id AND media_type = 'facebook') as facebook
,ad.city
,fs.ps_id as favid
,oh.opening_hours
FROM police pc
inner join address ad on
ad.ps_id = pc.ps_id
LEFT JOIN favstation fs on
fs.ps_id = pc.ps_id
LEFT JOIN openinghours oh ON
oh.ps_id = pc.ps_id
WHERE ad.adress_type = 'visit' And (pc.name LIKE ? OR ad.city LIKE ? OR ad.postalcode LIKE ? OR fs.ps_id IS NOT NULL)
ORDER by fs.ps_id DESC, ad.city Asc"$

	rs = Starter.sql.ExecQuery2(qry, Array As String(searchStr, searchStr, hint&"%"))

	lstStation.Initialize	
	Do While rs.NextRow
		lstStation.Add(Createstation(rs.GetString("id"), rs.GetString("name"), rs.GetDouble("long"), rs.GetDouble("lat"), _
		rs.GetString("address"), rs.GetString("postalcode"), rs.GetString("city"), _
		rs.GetString("url"), rs.GetString("twitter"), rs.GetString("facebook"), rs.GetString("favid"), rs.GetString("opening_hours")))
	Loop
	rs.Close
	Return lstStation
End Sub

Public Sub Createstation (ps_id As String, name As String, longtitude As Double, latitude As Double, address As String, _
						  postalcode As String, city As String, url As String, twitter As String, facebook As String, _
						  favid As String, openHours As String) As station
	Dim t1 As station
	t1.Initialize
	t1.ps_id = ps_id
	t1.name = name
	t1.longtitude = longtitude
	t1.latitude = latitude
	t1.address = address
	t1.postalcode = postalcode
	t1.city = city
	t1.url = url
	t1.twitter = twitter
	t1.facebook = facebook
	t1.fav_id = favid
	t1.openHours = openHours
	Return t1
End Sub