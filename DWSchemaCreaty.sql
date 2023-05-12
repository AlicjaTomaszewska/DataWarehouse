CREATE TABLE Dim_Localisation (
    SK_LocalisationID int IDENTITY(1,1) PRIMARY KEY,
	Inhabitants varchar(20) NOT NULL,
	CONSTRAINT CHK_Inhabitants CHECK (Inhabitants= 'small' OR Inhabitants= 'medium' OR Inhabitants = 'big' OR Inhabitants = 'Unknown' ),
);


CREATE TABLE Dim_Campaign (
    SK_CampaignID int IDENTITY(1,1) PRIMARY KEY,
	Platform varchar(20),
	Company varchar(30),
	Cost varchar(20),
	CONSTRAINT CHK_Platform CHECK (Platform= 'instagram' OR Platform= 'tiktok' OR Platform= 'Unknown'),
	CONSTRAINT CHK_Cost CHECK (Cost = 'small' OR Cost = 'medium' OR Cost = 'big' OR Cost = 'huge' OR Cost = 'Unknown' )
);

CREATE TABLE Dim_Sme(
    SK_EngagementID int IDENTITY(1,1) PRIMARY KEY,
	SMETotal varchar(20),
	Views varchar(30),
	Followers varchar(20),
	Likes varchar(20),
	Comments varchar(20),
	CONSTRAINT CHK_SMETotal CHECK (SMETotal = 'small' OR SMETotal= 'medium' OR SMETotal= 'big' OR SMETotal= 'huge' OR SMETotal= 'Unknown'),
	CONSTRAINT CHK_Views CHECK (Views = 'very_small' OR Views = 'small' OR Views = 'medium' OR Views = 'big' OR Views = 'huge' OR Views = 'Unknown'),
	CONSTRAINT CHK_Followers CHECK (Followers = 'very_small' OR Followers = 'small' OR Followers = 'medium' OR Followers = 'big' OR Followers = 'huge' OR Followers = 'Unknown'),
	CONSTRAINT CHK_Likes CHECK (Likes = 'very_small' OR Likes = 'small' OR Likes = 'medium' OR Likes = 'big' OR Likes = 'huge' OR Likes = 'Unknown'),
	CONSTRAINT CHK_Comments CHECK (Comments = 'very_small' OR Comments = 'small' OR Comments = 'medium' OR Comments = 'big' OR Comments = 'huge' OR Comments = 'Unknown')
);

CREATE TABLE Dim_Store (
    SK_StoreID int IDENTITY(1,1) PRIMARY KEY,
	BK_StoreID int,
	Size varchar(30),
	Activeness varchar(20),
	StartDate date,
	FinishDate date,
	CONSTRAINT CHK_Size CHECK (Size = 'small' OR Size = 'medium' OR Size = 'big' OR Size = 'Unknown'),
	CONSTRAINT CHK_Activeness CHECK (Activeness = 'active' OR Activeness = 'inactive' OR Activeness = 'Unknown')
);

CREATE TABLE Dim_Date (
    SK_DateID int IDENTITY(1,1) PRIMARY KEY,
	Date date NOT NULL,
	Year int NOT NULL,
	MonthNo tinyint NOT NULL,
	Day tinyint NOT NULL,
	CONSTRAINT CHK_Date CHECK (Date <= GETDATE()),
	CONSTRAINT CHK_Year CHECK ([Year] <= YEAR(GETDATE())),
	CONSTRAINT CHK_MonthNo CHECK (MonthNo BETWEEN 1 AND 12),
	CONSTRAINT CHK_Day CHECK (MonthNo BETWEEN 1 AND 31),
);

CREATE TABLE Store_monitoring (
    SK_DateID int FOREIGN KEY REFERENCES Dim_Date(SK_DateID),
	SK_CampaignID int FOREIGN KEY REFERENCES Dim_Campaign(SK_CampaignID),
	SK_LocalisationID int FOREIGN KEY REFERENCES Dim_Localisation(SK_LocalisationID),
	SK_StoreID int FOREIGN KEY REFERENCES Dim_Store(SK_StoreID),
	SK_EngagementID int FOREIGN KEY REFERENCES Dim_Sme(SK_EngagementID),
	TrafficRatio float NOT NULL,
	SalesRatio float NOT NULL,
	PRIMARY KEY(SK_DateID, SK_CampaignID, SK_LocalisationID, SK_StoreID, SK_EngagementID)
);

DROP TABLE Store_monitoring
DROP TABLE Dim_Store
DROP TABLE Dim_Localisation
DROP TABLE Dim_Sme
DROP TABLE Dim_Campaign
DROP TABLE Dim_Date

