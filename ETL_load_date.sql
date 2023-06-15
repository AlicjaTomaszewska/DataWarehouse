use DWschema
go

-- Fill DimDates Lookup Table
-- Step a: Declare variables use in processing
Declare @StartDate date; 
Declare @EndDate date;

-- Step b:  Fill the variable with values for the range of years needed
SELECT @StartDate = '2013-01-01', @EndDate = '2023-02-01';

-- Step c:  Use a while loop to add dates to the table
Declare @DateInProcess datetime = @StartDate;

While @DateInProcess <= @EndDate
	Begin
	--Add a row into the date dimension table for this date
		Insert Into [dbo].[Dim_Date] 
		( [Date]
		, [Year]
		, [MonthNo]
		, [Day]
		)
		Values ( 
		  @DateInProcess -- [Date]
		  , Cast( Year(@DateInProcess) as int) -- [Year]
		  , Cast( Month(@DateInProcess) as tinyint) -- [MonthNo]
		  , Cast( DAY(@DateInProcess) as tinyint) -- [DayOfMonthNo]
		);  
		-- Add a day and loop again
		Set @DateInProcess = DateAdd(d, 1, @DateInProcess);
	End
go
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT * FROM Dim_Date