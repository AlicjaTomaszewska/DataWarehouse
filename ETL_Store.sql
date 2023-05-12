use DWschema
go


If (object_id('StoreView3') is not null) DROP VIEW StoreView3;
go

CREATE VIEW StoreView3 AS
SELECT StoreID AS BusinessID,
CASE 
					WHEN Size < 121 THEN 'small'
					WHEN Size BETWEEN 121 AND 160 THEN 'medium'
					ELSE 'big'
		             END AS Size   
FROM [DW].[dbo].[Stores];
go

Declare @EntryDate date = '2023-01-01';

	MERGE INTO Dim_Store as TT
	USING StoreView3 as ST
		ON TT.BK_StoreID = ST.BusinessID
			WHEN Not Matched 
				THEN
					INSERT Values (
					ST.BusinessID,
					CASE 
					WHEN Size = 'small' THEN 'small'
					WHEN Size = 'medium' THEN 'medium'
					ELSE 'big'
		             END,
					'active',
					@EntryDate,
					NULL
					)
			WHEN Matched 
				AND (ST.Size <> TT.Size) AND TT.Activeness = 'active'
			THEN
				UPDATE
				SET TT.Activeness = 'inactive',
				TT.FinishDate = @EntryDate
			WHEN Not Matched BY Source
			AND TT.BK_StoreID != -1 
			THEN
				UPDATE
				SET TT.Activeness = 'inactive',
					TT.FinishDate =  @EntryDate
			;



INSERT INTO Dim_Store
(BK_StoreID, 
Size, Activeness, 
StartDate, 
FinishDate
	)
	SELECT 
		BusinessID, 
		Size, 
		'active', 
		@EntryDate, 
		NULL 
	FROM StoreView3
	EXCEPT
	SELECT 
		BK_StoreID, 
		Size, 
		'active', 
		@EntryDate, 
		NULL 
	FROM Dim_Store;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------



