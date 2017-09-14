-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql

DECLARE @db_id SMALLINT = DB_ID(N'db');   
DECLARE @object_id INT = OBJECT_ID(N'dbo.email');  

IF @db_id IS NULL  
BEGIN;  
    PRINT N'Invalid database';  
END;  
ELSE IF @object_id IS NULL  
BEGIN;  
    PRINT N'Invalid object';  
END;  
ELSE  
BEGIN;  
    SELECT * FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'DETAILED');  
END;  
GO  