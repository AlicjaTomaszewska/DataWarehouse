CREATE TABLE Localisations (
    LocalisationID int PRIMARY KEY,
    Province char(100) NOT NULL,
	Inhabitants int NOT NULL,
	CONSTRAINT CHK_Province CHECK ( Province NOT LIKE '%[0-9!@#$%^&*]%'),
);

CREATE TABLE Stores (
    StoreID int PRIMARY KEY,
    Size int,
    City char(100) NOT NULL,
    Street char(100) NOT NULL,
	LocalisationID int NOT NULL FOREIGN KEY REFERENCES Localisations(LocalisationID),
	CONSTRAINT CHK_City CHECK (City NOT LIKE '%[0-9!@#$%^&*]%'),
);

CREATE TABLE Traffics (
    TrafficID int PRIMARY KEY,
    Number_Of_People int NOT NULL,
    Traffic_Date date NOT NULL,
	StoreID int NOT NULL FOREIGN KEY REFERENCES Stores(StoreID),
	CONSTRAINT CHK_Traffic_Date CHECK (Traffic_Date < GETDATE()),
);


CREATE TABLE Sales (
    SaleID int PRIMARY KEY,
    Sale_Date date NOT NULL,
	Turnover int NOT NULL,
	StoreID int NOT NULL FOREIGN KEY REFERENCES Stores(StoreID),
	CONSTRAINT CHK_Sale_Date CHECK (Sale_Date < GETDATE()),
);

CREATE TABLE Marketing_Campaigns (
    Marketing_CampaignID int PRIMARY KEY,
    Start_Date date NOT NULL,
    Finish_Date date NOT NULL,
	Marketing_Campaign_Name char(100),
	Cost int NOT NULL,
	CompanyID int NOT NULL,
	CONSTRAINT CHK_Start_Date CHECK (Start_Date < GETDATE()),
	CONSTRAINT CHK_Cost CHECK (Cost< 10000000),
);


CREATE TABLE Localisations_Marketing_Campaigns (
LocalisationID int NOT NULL FOREIGN KEY REFERENCES Localisations(LocalisationID) ON DELETE CASCADE ON UPDATE CASCADE,
Marketing_CampaignID int NOT NULL FOREIGN KEY REFERENCES Marketing_Campaigns(Marketing_CampaignID) ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY(LocalisationID, Marketing_CampaignID)
);


CREATE TABLE Advertising (
    AdvertisingID int PRIMARY KEY,
    Publication_Date date,
    No_Of_Likes int,
	No_Of_Comments int,
	No_Of_Followers int,
	No_Of_Views int,
    PlatformName char(100) NOT NULL,
	Marketing_CampaignID int NOT NULL FOREIGN KEY REFERENCES Marketing_Campaigns(Marketing_CampaignID),
	CONSTRAINT CHK_PlatformName CHECK (PlatformName= 'TikTok' OR PlatformName= 'Instagram' ),
	CONSTRAINT CHK_PublicationDate CHECK (Publication_Date >= '2013.01.01'),
	CONSTRAINT CHK_No_Of_Likes CHECK ( No_Of_Likes>=100 AND No_Of_Likes<=100000 ),
	CONSTRAINT CHK_No_Of_Comments CHECK (No_Of_Comments>= 20 AND No_Of_Comments<= 5000),
	CONSTRAINT CHK_No_Of_Views CHECK (No_Of_Views >= 10000 AND No_Of_Views <= 1000000),
	CONSTRAINT CHK_No_Of_Followers CHECK (No_Of_Followers >= 100 AND No_Of_Followers <= 3000)
);

