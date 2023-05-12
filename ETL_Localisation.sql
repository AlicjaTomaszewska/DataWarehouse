use DWschema
go

If (object_id('LocalisationView') is not null) DROP VIEW LocalisationView;
go

CREATE VIEW LocalisationView
AS SELECT
      LocalisationID,
      Inhabitants
FROM [DW].[dbo].[Localisations]
go


MERGE INTO Dim_Localisation as TT
	USING LocalisationView as ST
		ON TT.SK_LocalisationID = ST.LocalisationID
			WHEN Not Matched 
				THEN
					INSERT Values (
					CASE 
						WHEN Inhabitants < 3000000 THEN 'small'
						WHEN Inhabitants BETWEEN 3000001 AND 4000000 THEN 'medium'
						ELSE 'big'
					END);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------


