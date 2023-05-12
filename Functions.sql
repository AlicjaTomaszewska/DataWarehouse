CREATE FUNCTION SalesRatio (@val1 DATE, @val2 INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
	Declare @YEAR int = 2018;
	Declare @MONTH int = MONTH(@val1);
	Declare @DAY int = DAY(@val1);
    DECLARE @SalesNow DECIMAL(18,2) = (
        SELECT Turnover
        FROM [DW].[dbo].[Sales] s
        JOIN [DWSchema].[dbo].[Dim_Date] d ON s.Sale_Date = d.Date
        WHERE d.Date = @val1 AND s.StoreID = @val2
    )
    DECLARE @Sales2018 DECIMAL(18,2) = (
        SELECT Turnover
        FROM [DW].[dbo].[Sales] s
        JOIN [DWSchema].[dbo].[Dim_Date] d ON s.Sale_Date = d.Date
        WHERE d.Year = @YEAR AND d.MonthNo = MONTH(@val1) AND d.Day = DAY(@val1) AND s.StoreID = @val2
    )
    RETURN @SalesNow / @Sales2018            
END;



CREATE FUNCTION TrafficRatio (@val1 DATE, @val2 INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
	Declare @YEAR int = 2018;
	Declare @MONTH int = MONTH(@val1);
	Declare @DAY int = DAY(@val1);
    DECLARE @TrafficsNow DECIMAL(18,2) = (
        SELECT Number_Of_People
        FROM [DW].[dbo].[Traffics] s
        JOIN [DWSchema].[dbo].[Dim_Date] d ON s.Traffic_Date = d.Date
        WHERE d.Date = @val1 AND s.StoreID = @val2
    )
    DECLARE @Traffics2018 DECIMAL(18,2) = (
        SELECT Number_Of_People
        FROM [DW].[dbo].[Traffics] s
        JOIN [DWSchema].[dbo].[Dim_Date] d ON s.Traffic_Date = d.Date
        WHERE d.Year = @YEAR AND d.MonthNo = MONTH(@val1) AND d.Day = DAY(@val1) AND s.StoreID = @val2
    )
    RETURN @TrafficsNow / @Traffics2018           
END;
------------
DROP FUNCTION SalesRatio
SELECT dbo.SalesRatio('2022-03-15', 150) AS "Why don't you understand"
SELECT Turnover FROM Sales WHERE Sale_Date ='2022-03-15' AND StoreID =150
SELECT Turnover FROM Sales WHERE Sale_Date ='2018-03-15' AND StoreID =150
SELECT dbo.TrafficRatio('2022-03-15', 150) AS "Why"
SELECT Number_Of_People FROM Traffics WHERE Traffic_Date ='2022-03-15' AND StoreID =150
SELECT Number_Of_People FROM Traffics WHERE Traffic_Date ='2018-03-15' AND StoreID =150