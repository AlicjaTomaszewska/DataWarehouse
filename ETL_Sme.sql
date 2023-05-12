use DWschema
go

If (object_id('SmeView') is not null) DROP VIEW SmeView;
go

CREATE VIEW SmeView AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY YEAR(Publication_Date), MONTH(Publication_Date), DAY(Publication_Date)) AS ID,
    YEAR(Publication_Date) AS [YEAR], 
    MONTH(Publication_Date) AS [MONTH], 
    DAY(Publication_Date) AS [DAY], 
    SUM(No_of_likes*0.2 + No_of_followers*0.4 + No_of_views*0.1 + No_of_comments*0.3) AS SME, 
    SUM(No_of_likes) AS TotalLikes, 
    SUM(No_of_comments) AS TotalComments, 
    SUM(No_Of_views) AS TotalViews, 
    SUM(No_Of_followers) AS TotalFollowers
FROM [DW].[dbo].[Advertising]
GROUP BY YEAR(Publication_Date), MONTH(Publication_Date), DAY(Publication_Date);
go

MERGE INTO Dim_Sme as TT
	USING SmeView as ST
		ON TT.SK_EngagementID = ST.ID
			WHEN Not Matched 
				THEN
					INSERT Values (
					CASE 
						WHEN ST.SME < 3200000 THEN 'small'
						WHEN ST.SME BETWEEN 3200001 AND 3400000 THEN 'medium'
						WHEN ST.SME BETWEEN 3400001 AND 3700000 THEN 'big'
						ELSE 'huge'
					END,
						CASE 
						WHEN ST.TotalViews < 23000000 THEN 'very_small'
						WHEN ST.TotalViews BETWEEN 23000001 AND 26000000 THEN 'small'
						WHEN ST.TotalViews BETWEEN 26000001 AND 30000000 THEN 'medium'
						WHEN ST.TotalViews BETWEEN 30000001 AND 32000000 THEN 'big'
						ELSE 'huge'
					END,
					CASE 
						WHEN ST.TotalComments < 115000 THEN 'very_small'
						WHEN ST.TotalComments BETWEEN 115000  AND 130000  THEN 'small'
						WHEN ST.TotalComments BETWEEN 130001  AND 145000 THEN 'medium'
						WHEN ST.TotalComments BETWEEN 145001 AND 155000 THEN 'big'
						ELSE 'huge'
					END, 
					CASE 
						WHEN ST.TotalFollowers < 75000 THEN 'very_small'
						WHEN ST.TotalFollowers BETWEEN 75000 AND 85000 THEN 'small'
						WHEN ST.TotalFollowers BETWEEN 85001 AND 90000 THEN 'medium'
						WHEN ST.TotalFollowers BETWEEN 90001 AND 98000 THEN 'big'
						ELSE 'huge'
					END, 
					CASE 
						WHEN ST.TotalLikes < 2350000 THEN 'very_small'
						WHEN ST.TotalLikes BETWEEN 2350001 AND 2600000 THEN 'small'
						WHEN ST.TotalLikes BETWEEN 2600001 AND 2800000 THEN 'medium'
						WHEN ST.TotalLikes BETWEEN 2800001 AND 3200000 THEN 'big'
						ELSE 'huge'
					END );

-------------------------------------------------------------------------------------------------------------------------------------------------------------





