--Check for NULL
Select *
From dbo.BTC_USD
Where  "Date" IS NULL OR
"Open" IS NULL OR
"High" IS NULL OR
"Low" IS NULL OR
"Close" IS NULL OR
Volume_USD IS NULL;

--Alter Columns to correct data type
ALTER TABLE dbo.BTC_USD
ALTER COLUMN "Date" DATE;

ALTER TABLE dbo.BTC_USD
ALTER COLUMN "Open" Decimal(12,2); 

ALTER TABLE dbo.BTC_USD
ALTER COLUMN "High" Decimal(12,2); 

ALTER TABLE dbo.BTC_USD
ALTER COLUMN "Low" Decimal(12,2); 

ALTER TABLE dbo.BTC_USD
ALTER COLUMN "Close" Decimal(12,2);

--Check for Outliers
Select TOP 30 *
From dbo.BTC_USD
Order By "Open" asc;

Select TOP 30 *
From dbo.BTC_USD
Order By "Open" desc;
--Repeat for each column

--Calculate Daily Return
ALTER TABLE dbo.BTC_USD
ADD Daily_Return
AS (("Close"-"Open")/"Open" * 100);

--30 day moving average volume and LEAD
Select *,
avg(Volume_USD) OVER(ORDER BY "Date"
      ROWS 30 PRECEDING)
      as "30MA_Volume",
LEAD(Daily_Return,1)over(Order by"Date") "Day_1",
LEAD(Daily_Return,2)over(Order by"Date") "Day_2",
LEAD(Daily_Return,3)over(Order by"Date") "Day_3"
Into dbo.BTC_AGG
From dbo.BTC_USD;

--Calculate volume as a percentage of the 30 day MA
ALTER TABLE dbo.BTC_AGG
ADD Relative_Volume
AS (("Volume_USD"-"30MA_Volume")/"30MA_Volume" * 100);

--Alter Columns to correct data type
ALTER TABLE dbo.BTC_AGG
ALTER COLUMN "Daily_Return" Decimal(12,2);

ALTER TABLE dbo.BTC_AGG
ALTER COLUMN "Day_1" Decimal(12,2); 

ALTER TABLE dbo.BTC_AGG
ALTER COLUMN "Day_2" Decimal(12,2); 

ALTER TABLE dbo.BTC_AGG
ALTER COLUMN "Day_3" Decimal(12,2);

--The Results
Select *
From dbo.BTC_AGG
Where"Date" > '2017-01-30' and Relative_Volume > 50 and Daily_Return > 5;
