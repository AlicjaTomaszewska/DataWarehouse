SELECT * FROM Stores
SELECT * FROM Traffics
SELECT * FROM Marketing_Campaigns
SELECT * FROM Localisations_Marketing_Campaigns
SELECT * FROM Sales
SELECT * FROM Advertising

INSERT INTO Traffics VALUES (589281, 77, '2023-02-01', 1)
INSERT INTO Sales VALUES (589281,'2023-02-01', 7547,1)

DELETE FROM Advertising WHERE Marketing_CampaignID = 121
DELETE FROM  Localisations_Marketing_Campaigns WHERE Marketing_CampaignID=121
DELETE FROM Marketing_Campaigns WHERE Marketing_CampaignID=121
DELETE FROM Traffics WHERE Traffic_Date > '2022-12-31'
DELETE FROM Sales WHERE Sale_Date > '2022-12-31'

UPDATE Stores SET Size = 161 WHERE StoreID = 2