SET IDENTITY_INSERT dbo.Dim_Campaign ON;  
GO

INSERT INTO dbo.Dim_Campaign(
	SK_CampaignID,
	Platform,
	Company,
	Cost)
Values(-1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN');
go

SET IDENTITY_INSERT dbo.Dim_Campaign OFF; 
SET IDENTITY_INSERT dbo.Dim_Localisation ON;  
GO 

INSERT INTO dbo.Dim_Localisation(
	SK_LocalisationID,
	Inhabitants)
Values(-1, 'UNKNOWN');
go


SET IDENTITY_INSERT DWschema.dbo.Dim_Localisation OFF;

SET IDENTITY_INSERT dbo.Dim_Sme ON;  
GO

INSERT INTO dbo.Dim_Sme(
SK_EngagementID,
	SMETotal,
	Views,
	Followers,
	Likes,
	Comments)
Values(-1, 'UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN','UNKNOWN');
go


SET IDENTITY_INSERT DWschema.dbo.Dim_Sme OFF;

SET IDENTITY_INSERT dbo.Dim_Store ON;  
GO

INSERT INTO dbo.Dim_Store(
	SK_StoreID,
	BK_StoreID,
	Size,
	Activeness,
	StartDate,
	FinishDate)
Values(-1, -1,'UNKNOWN','UNKNOWN','1980-01-01','1980-01-02');
go


SET IDENTITY_INSERT DWschema.dbo.Dim_STORE OFF;

SET IDENTITY_INSERT dbo.Dim_Date ON;  
GO

INSERT INTO dbo.Dim_Date(
	SK_DateID,
	Date,
	Year,
	MonthNo,
	Day)
Values(-1, '1980-01-01',1980,1,1);
go