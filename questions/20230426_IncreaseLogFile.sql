-- Title: Code that increases transaction log based on actual size of transaction log. Problem with assigning the size as a variable

-- I have a SQL Server 2019 database with a 300GB transaction log file. I want to automatically manage the transaction log file size with a job to prevent it from expanding automatically during peak hours.

-- My approach is to increase transaction log file size by 20% at night when available log space is less than 10%.

-- The example is based on AdventureWorks2019 database.

DECLARE @logSizeMB INT
DECLARE @logFreeSpace_mb INT
DECLARE @logIncrementPercent INT
DECLARE @newSize INT

-- Get current size in MB
SELECT @logSizeMB = size/128 FROM sys.database_files WHERE type_desc = 'LOG'

-- Get free space  in MB
SELECT @logFreeSpace_mb = FILEPROPERTY(name, 'SpaceUsed')/128 FROM sys.database_files WHERE type_desc = 'LOG'

-- Calculate growth amount in MB
SET @logIncrementPercent = @logSizeMB * 0.20

IF (@logFreeSpace_mb < (@logSizeMB * 0.10))
BEGIN
	SET @newSize = @logSizeMB + @logIncrementPercent
	-- Error below: Incorrect syntax near '@newSize'. Expecting ID, Integer, QUOTED_ID, String OR TEXT_LEX
    ALTER DATABASE [AdventureWorks2019] MODIFY FILE (NAME = N'AdventureWorks2019_log', SIZE = @newSize)
END

-- I get Incorrect syntax near '@newSize' error while assigning a variable @newSize to SIZE. Everything is fine when using a number e.g. 1024, as written below:

ALTER DATABASE [AdventureWorks2019] MODIFY FILE (NAME = N'AdventureWorks2019_log', SIZE = 1024)

--How to resolve that problem, not using dynamic SQL?