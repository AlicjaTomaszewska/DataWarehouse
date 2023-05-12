use DWschema
go

If (object_id('DimSmeVIEW ') is not null) Drop view DimSmeVIEW;
go


CREATE VIEW DimSmeVIEW 
AS
SELECT DISTINCT 
    Advertising.Marketing_CampaignID AS MC,
    (SELECT Max(AdvertisingID)/COUNT(AdvertisingID) FROM [DW].[dbo].[Advertising] WHERE Publication_Date = Dim_Date.Date) AS SmeID,
    Localisations_Marketing_Campaigns.LocalisationID AS Localisation,
	Advertising.Publication_Date
FROM [DWschema].[dbo].[Dim_Date]
JOIN [DW].[dbo].[Advertising] ON Dim_Date.Date = Advertising.Publication_Date
JOIN [DW].[dbo].[Localisations_Marketing_Campaigns] ON Localisations_Marketing_Campaigns.Marketing_CampaignID = Advertising.Marketing_CampaignID;
go



If (object_id('TrafficSalesView') is not null) Drop view TrafficSalesView;
go


CREATE VIEW TrafficSalesView AS SELECT 
Stores.StoreID, Sales.SaleID, Traffics.TrafficID, Sales.Turnover , Traffics.Number_Of_People, Dim_Date.SK_DateID, Dim_Date.Date, Stores.LocalisationID
From [DWschema].[dbo].[Dim_Date]
JOIN [DW].[dbo].[Traffics] ON Traffics.Traffic_Date = Dim_Date.Date
JOIN [DW].[dbo].[Sales] ON Sales.Sale_Date = Dim_Date.Date  AND Traffics.Traffic_Date = Sales.Sale_Date
RIGHT JOIN [DW].[dbo].[Stores] ON Traffics.StoreID = Stores.StoreID AND Sales.StoreID = Stores.StoreID
go

SELECT * FROM TrafficSalesView

If (object_id('TrafficSalesView2') is not null) Drop view TrafficSalesView2;
go

CREATE VIEW TrafficSalesView2 AS SELECT 
Stores.StoreID, Dim_Date.SK_DateID, Stores.LocalisationID, dbo.SalesRatio(Dim_Date.Date, Stores.StoreID) AS SalesRatio, dbo.TrafficRatio(Dim_Date.Date, Stores.StoreID) AS TrafficRatio
From [DWschema].[dbo].[Dim_Date]
LEFT JOIN [DW].[dbo].[Traffics] ON Traffics.Traffic_Date = Dim_Date.Date
LEFT JOIN [DW].[dbo].[Sales] ON Sales.Sale_Date = Dim_Date.Date  AND Traffics.Traffic_Date = Sales.Sale_Date
RIGHT JOIN [DW].[dbo].[Stores] ON Traffics.StoreID = Stores.StoreID AND Sales.StoreID = Stores.StoreID
go

If (object_id('StoreMonitoring2') is not null) Drop view StoreMonitoring2;
go


CREATE VIEW StoreMonitoring2
AS
SELECT
SK_DateID = T3.SK_DateID,
SK_StoreID = T5.SK_StoreID ,
SK_LocalisationID = T7.SK_LocalisationID,  
SK_CampaignID  = isNull(T11.SK_CampaignID,-1),
SK_EngagementID = isNull(T12.SK_EngagementID, -1),
TrafficRatio = T2.Number_Of_People,--T2.TrafficRatio, 
SalesRatio = T2.Turnover --T2.SalesRatio

	 FROM [DWSchema].[dbo].[Dim_Date] AS T3 
	 JOIN TrafficSalesView AS T2 ON T3.SK_DateID = T2.SK_DateID
	 LEFT JOIN [DWSchema].[dbo].[Dim_Store] AS T5 ON T5.BK_StoreID = T2.StoreID AND  T3.Date >= T5.StartDate AND T3.Date< isnull(T5.FinishDate, CURRENT_TIMESTAMP) --T3.Date BETWEEN T5.StartDate AND isnull(T5.FinishDate, CURRENT_TIMESTAMP)
	 LEFT JOIN [DWSchema].[dbo].[Dim_Localisation] AS T7 ON T7.SK_LocalisationID = T2.LocalisationID
	 LEFT JOIN DimSmeVIEW AS T10 ON T10.Publication_Date = T3.Date AND T10.Localisation = T7.SK_LocalisationID
	 LEFT JOIN [DWSchema].[dbo].[Dim_Campaign] AS T11 ON T11.SK_CampaignID = T10.MC
	 LEFT JOIN [DWSchema].[dbo].[Dim_Sme] AS T12 ON T12.SK_EngagementID = T10.SmeID
go	

SELECT * FROM StoreMonitoring2
MERGE INTO Store_monitoring as TT
	USING StoreMonitoring2 as ST
		ON 	
			TT.SK_DateID = ST.SK_DateID
		AND TT.SK_CampaignID = ST.SK_CampaignID
		AND TT.SK_LocalisationID = ST.SK_LocalisationID
		AND TT.SK_StoreID = ST.SK_StoreID
		AND TT.SK_EngagementID = ST.SK_EngagementID
		--AND TT.TrafficRatio = ST.TrafficRatio
		--AND TT.SalesRatio = ST.SalesRatio
			WHEN Not Matched
				THEN
					INSERT
					Values (
						  ST.SK_DateID,
						  ST.SK_CampaignID,
						  ST.SK_LocalisationID,
						  ST.SK_StoreID,
						  ST.SK_EngagementID,
						  ST.TrafficRatio,
						  ST.SalesRatio
						  
							)
						;



--------------------------------------------------------------------
--SELECT COUNT(*) FROM Store_monitoring WHERE SK_StoreID = 2
--SELECT COUNT(*) FROM Store_monitoring WHERE SK_StoreID = 161
--SELECT * FROM Store_monitoring
--SELECT COUNT(*) FROM Store_monitoring
