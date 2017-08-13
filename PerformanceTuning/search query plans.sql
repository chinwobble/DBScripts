-- https://www.red-gate.com/simple-talk/sql/database-administration/exploring-query-plans-in-sql/
-- http://www.scarydba.com/2012/07/02/querying-data-from-the-plan-cache/
-- https://littlekendra.com/2017/01/24/how-to-find-queries-using-an-index-and-queries-using-index-hints/


SELECT top(1)
	querystats.plan_handle,
	querystats.query_hash,
	SUBSTRING(sqltext.text, (querystats.statement_start_offset / 2) + 1, 
				(CASE querystats.statement_end_offset 
					WHEN -1 THEN DATALENGTH(sqltext.text) 
					ELSE querystats.statement_end_offset 
				END - querystats.statement_start_offset) / 2 + 1) AS sqltext, 
	querystats.execution_count,
	querystats.total_logical_reads,
	querystats.total_logical_writes,
	querystats.creation_time,
	querystats.last_execution_time,
	CAST(query_plan AS xml) as plan_xml
FROM sys.dm_exec_query_stats as querystats
CROSS APPLY sys.dm_exec_text_query_plan
	(querystats.plan_handle, querystats.statement_start_offset, querystats.statement_end_offset) 
	as textplan
CROSS APPLY sys.dm_exec_sql_text(querystats.sql_handle) AS sqltext 
WHERE CAST(query_plan as xml).exist('declare namespace 
		qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
        //qplan:Object[@Index="[PK_email]"]')=1
ORDER BY querystats.last_execution_time DESC
OPTION (RECOMPILE);
GO
