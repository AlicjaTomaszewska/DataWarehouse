use DWschema
go

If (object_id('CampaignView') is not null) DROP VIEW CampaignView;
go

CREATE VIEW CampaignView AS
SELECT ROW_NUMBER() OVER (ORDER BY Marketing_Campaigns.Marketing_CampaignID) AS CampaignID,
PlatformName, Cost as CostValue, CompanyID
FROM [DW].[dbo].[Marketing_Campaigns]
JOIN [DW].[dbo].[Advertising] ON Marketing_Campaigns.Marketing_CampaignID = Advertising.Marketing_CampaignID 
Group by Marketing_Campaigns.Marketing_CampaignID, PlatformName, Cost, CompanyID;
go

If (object_id('CompaniesTemp') is not null) DROP TABLE CompaniesTemp;
go

CREATE TABLE dbo.CompaniesTemp(CompanyID int, Company_Name varchar(100));

BULK INSERT dbo.CompaniesTemp
    FROM 'C:\Users\48531\Desktop\Companies2.csv'
    WITH
    (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
    )

If (object_id('CampaignView2') is not null) DROP VIEW CampaignView2;
go 

CREATE VIEW CampaignView2 AS
SELECT ROW_NUMBER() OVER (ORDER BY Marketing_Campaigns.Marketing_CampaignID) AS CampaignID,
PlatformName, Cost as CostValue, Company_Name
FROM [DW].[dbo].[Marketing_Campaigns]
JOIN [DW].[dbo].[Advertising] ON Marketing_Campaigns.Marketing_CampaignID = Advertising.Marketing_CampaignID 
JOIN [DWschema].[dbo].[CompaniesTemp] ON Marketing_Campaigns.CompanyID = CompaniesTemp.CompanyID 
Group by Marketing_Campaigns.Marketing_CampaignID, PlatformName, Cost, Company_Name;
go

	MERGE INTO Dim_Campaign as TT
	USING CampaignView2 as ST
		ON TT.SK_CampaignID = ST.CampaignID
			WHEN Not Matched 
				THEN
					INSERT Values (
					ST.PlatformName,
					ST.Company_Name,
					CASE 
			WHEN ST.CostValue < 20000 THEN 'small'
			WHEN ST.CostValue BETWEEN 20001 AND 40000 THEN 'medium'
			WHEN ST.CostValue BETWEEN 40001 AND 60000 THEN 'big'
			ELSE 'huge'
			END);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT * FROM Dim_Campaign

	