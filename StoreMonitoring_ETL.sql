use DWschema
go

/*
This code block first checks if the view named "DimSmeVIEW" exists and drops it if it does.
Then, it creates a new view called "DimSmeVIEW".
The view selects distinct values for columns MC (derived from Advertising.Marketing_CampaignID),
SmeID (calculated as the ratio of the maximum AdvertisingID to the count of AdvertisingID for a specific Publication_Date),
Localisation (retrieved from Localisations_Marketing_Campaigns table), and Advertising.Publication_Date.
The SELECT statement joins the Dim_Date, Advertising, and Localisations_Marketing_Campaigns tables.
*/

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

/*
Similar to the previous block, this code block drops the existing "TrafficSalesView" view if it exists and creates a new one.
The view selects columns StoreID, SaleID, TrafficID, Turnover, Number_Of_People, SK_DateID, Date, and LocalisationID from the specified tables using joins.
*/

If (object_id('TrafficSalesView') is not null) Drop view TrafficSalesView;
go


CREATE VIEW TrafficSalesView AS SELECT 
Stores.StoreID, Sales.SaleID, Traffics.TrafficID, Sales.Turnover , Traffics.Number_Of_People, Dim_Date.SK_DateID, Dim_Date.Date, Stores.LocalisationID
From [DWschema].[dbo].[Dim_Date]
JOIN [DW].[dbo].[Traffics] ON Traffics.Traffic_Date = Dim_Date.Date
JOIN [DW].[dbo].[Sales] ON Sales.Sale_Date = Dim_Date.Date  AND Traffics.Traffic_Date = Sales.Sale_Date
RIGHT JOIN [DW].[dbo].[Stores] ON Traffics.StoreID = Stores.StoreID AND Sales.StoreID = Stores.StoreID
go

/*
This code block drops the existing "TrafficSalesView2" view if it exists and creates a new one.
The view selects columns StoreID, SK_DateID, LocalisationID, and calculated values SalesRatio and TrafficRatio using functions SalesRatio
and TrafficRatio with parameters Dim_Date.Date and Stores.StoreID. It performs various joins between tables.
*/

If (object_id('TrafficSalesView2') is not null) Drop view TrafficSalesView2;
go

CREATE VIEW TrafficSalesView2 AS SELECT 
Stores.StoreID, Dim_Date.SK_DateID, Stores.LocalisationID, dbo.SalesRatio(Dim_Date.Date, Stores.StoreID) AS SalesRatio, dbo.TrafficRatio(Dim_Date.Date, Stores.StoreID) AS TrafficRatio
From [DWschema].[dbo].[Dim_Date]
LEFT JOIN [DW].[dbo].[Traffics] ON Traffics.Traffic_Date = Dim_Date.Date
LEFT JOIN [DW].[dbo].[Sales] ON Sales.Sale_Date = Dim_Date.Date  AND Traffics.Traffic_Date = Sales.Sale_Date
RIGHT JOIN [DW].[dbo].[Stores] ON Traffics.StoreID = Stores.StoreID AND Sales.StoreID = Stores.StoreID
go

/*
This code block drops the existing "StoreMonitoring2" view if it exists and creates a new one.
The view selects various columns from different tables using joins and assigns them aliases.
It uses the previously created views "TrafficSalesView" and "DimSmeVIEW" in the join operations.
*/

/*
T3.Date >= T5.StartDate: This condition ensures that the date from the Dim_Date table (aliased as T3) 
is greater than or equal to the start date of the corresponding store in the Dim_Store table. 
This condition helps filter out records where the date is before the store's start date.

T3.Date < ISNULL(T5.FinishDate, CURRENT_TIMESTAMP): 
This condition checks if the date from the Dim_Date table is less than the finish date of the store in the Dim_Store table. 
If the FinishDate is NULL, it is replaced with the current timestamp using CURRENT_TIMESTAMP. 
This condition ensures that the date is within the valid range of the store's existence.

These conditions are  used to implement Slowly Changing Dimension Type 2 (SCD2) into fact table. 
The conditions in the join help filter the records based on the date range to retrieve the appropriate version of the store's data
that was valid for a specific date.
By using a left join and applying these conditions, the query includes all records from the TrafficSalesView table 
and retrieves the corresponding store information from the Dim_Store table based on the matching store ID and valid date range. 
*/

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
	 LEFT JOIN [DWSchema].[dbo].[Dim_Store] AS T5 ON T5.BK_StoreID = T2.StoreID AND  T3.Date >= T5.StartDate AND T3.Date< isnull(T5.FinishDate, CURRENT_TIMESTAMP) 
	 LEFT JOIN [DWSchema].[dbo].[Dim_Localisation] AS T7 ON T7.SK_LocalisationID = T2.LocalisationID
	 LEFT JOIN DimSmeVIEW AS T10 ON T10.Publication_Date = T3.Date AND T10.Localisation = T7.SK_LocalisationID
	 LEFT JOIN [DWSchema].[dbo].[Dim_Campaign] AS T11 ON T11.SK_CampaignID = T10.MC
	 LEFT JOIN [DWSchema].[dbo].[Dim_Sme] AS T12 ON T12.SK_EngagementID = T10.SmeID
go	

/*
This MERGE statement merges the data from the "StoreMonitoring2" view into the "Store_monitoring" table based on matching conditions.
If a match is not found, it performs an INSERT operation to insert the values from the source view into the target table.
The code creates and uses several views to retrieve data from different tables and then merges the data into a target table.
The views help organize the logic and make the code more readable and maintainable.
*/

SELECT * FROM StoreMonitoring2
MERGE INTO Store_monitoring as TT
	USING StoreMonitoring2 as ST
		ON 	
			TT.SK_DateID = ST.SK_DateID
		AND TT.SK_CampaignID = ST.SK_CampaignID
		AND TT.SK_LocalisationID = ST.SK_LocalisationID
		AND TT.SK_StoreID = ST.SK_StoreID
		AND TT.SK_EngagementID = ST.SK_EngagementID
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
--SELECT * FROM Store_monitoring

