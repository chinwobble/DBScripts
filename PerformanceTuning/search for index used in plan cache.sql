--https://www.sqlskills.com/blogs/jonathan/finding-what-queries-in-the-plan-cache-use-a-specific-index/
--https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-cached-plans-transact-sql#examples
--https://www.sqlshack.com/searching-the-sql-server-query-plan-cache/

-- save all the queries into a temp table and then query them with XQuery


create table #showPlans 
(
	[plan] xml not null
)
insert into #showPlans 
select top(10) query_plan
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_query_plan(plan_handle)  
where query_plan is not null;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
DECLARE @IndexName AS NVARCHAR(128) = 'PK_permission_user';

IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName); 
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName; 
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']';

;WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')    
SELECT 
stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text
,obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName
,obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName
,obj.value('(@Table)[1]', 'varchar(128)') AS TableName 
,obj.value('(@Index)[1]', 'varchar(128)') AS IndexName
,obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind
,[plan]
from #showPlans
CROSS APPLY [plan].nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj) 
OPTION(MAXDOP 1, RECOMPILE);