use DWschema
go

--This checks if a view named StoreView3 exists in the database and drops it if it does.

If (object_id('StoreView3') is not null) DROP VIEW StoreView3;
go

/*
This creates a new view named StoreView3 that selects data from the [DW].[dbo].[Stores] table.
It renames the StoreID column as BusinessID and creates a new column called Size based on the value of the Size column in the Stores table.
The Size column is categorized as 'small', 'medium', or 'big' based on its value.
*/

CREATE VIEW StoreView3 AS
SELECT StoreID AS BusinessID,
CASE 
					WHEN Size < 121 THEN 'small'
					WHEN Size BETWEEN 121 AND 160 THEN 'medium'
					ELSE 'big'
		             END AS Size   
FROM [DW].[dbo].[Stores];
go

--While loading T1 @EntryDate was '2013-01-01' and it was changed for loading T2 to the value '2023-01-01'.

Declare @EntryDate date = '2023-01-01';

/*
This is the main SCD2 logic implemented using the MERGE statement. 
It merges the data from the StoreView3 view into the Dim_Store table. Here's a breakdown of the different cases handled:

WHEN Not Matched: 
If a row from StoreView3 does not have a matching BK_StoreID in Dim_Store, it means it's a new record. 
In this case, a new row is inserted into Dim_Store with the values from StoreView3 and the entry date as the start date.

WHEN Matched AND (ST.Size <> TT.Size) AND TT.Activeness = 'active':
If a row from StoreView3 has a matching BK_StoreID in Dim_Store but the Size has changed and the existing row in Dim_Store is still active,
it means an update is needed. The existing row in Dim_Store is marked as 'inactive' with the finish date set to the entry date.

WHEN Not Matched BY Source AND TT.BK_StoreID != -1:
If a row exists in Dim_Store that doesn't have a matching BusinessID in StoreView3 and the BK_StoreID is not -1,
it means the record doesn't exist in the source anymore. In this case, the row in Dim_Store is marked as 'inactive' with the finish date set to the entry date.
*/

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

--This section inserts any new records from StoreView3 into Dim_Store that were not handled by the MERGE statement. 
--The EXCEPT clause is used to exclude any rows that already exist in Dim_Store, based on the BK_StoreID, Size, and StartDate values.

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
--SELECT * FROM Dim_Store