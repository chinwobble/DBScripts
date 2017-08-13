-- reference https://sqlfascination.com/2010/03/10/locating-table-scans-within-the-query-cache/

declare @DatabaseName varchar(100) = 'DatabaseName'

WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
CachedPlans (DatabaseName,SchemaName,ObjectName,PhysicalOperator, LogicalOperator, QueryText,QueryPlan, CacheObjectType, ObjectType)
AS
(
	SELECT
		Coalesce(RelOp.op.value(N'TableScan[1]/Object[1]/@Database', N'varchar(50)') , 
			RelOp.op.value(N'OutputList[1]/ColumnReference[1]/@Database', N'varchar(50)') ,
			RelOp.op.value(N'IndexScan[1]/Object[1]/@Database', N'varchar(50)') ,
			'Unknown') as DatabaseName,
		Coalesce(RelOp.op.value(N'TableScan[1]/Object[1]/@Schema', N'varchar(50)') ,
			RelOp.op.value(N'OutputList[1]/ColumnReference[1]/@Schema', N'varchar(50)') ,
			RelOp.op.value(N'IndexScan[1]/Object[1]/@Schema', N'varchar(50)') ,
			'Unknown'
			) as SchemaName,
		Coalesce(
			RelOp.op.value(N'TableScan[1]/Object[1]/@Table', N'varchar(50)') ,
			RelOp.op.value(N'OutputList[1]/ColumnReference[1]/@Table', N'varchar(50)') ,
			RelOp.op.value(N'IndexScan[1]/Object[1]/@Table', N'varchar(50)') ,
			'Unknown') as ObjectName,
		RelOp.op.value(N'@PhysicalOp', N'varchar(50)') as PhysicalOperator,
		RelOp.op.value(N'@LogicalOp', N'varchar(50)') as LogicalOperator,
		st.text as QueryText,
		qp.query_plan as QueryPlan,
		cp.cacheobjtype as CacheObjectType,
		cp.objtype as ObjectType
	FROM
		sys.dm_exec_cached_plans cp
		CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
		CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
		CROSS APPLY qp.query_plan.nodes(N'//RelOp') RelOp (op)
)
SELECT
	DatabaseName,
	SchemaName,
	ObjectName,
	PhysicalOperator, 
	LogicalOperator, 
	QueryText,
	CacheObjectType, 
	ObjectType, 
	queryplan
FROM
	CachedPlans
WHERE
	CacheObjectType = N'Compiled Plan'
	and (PhysicalOperator = 'Clustered Index Scan' 
	or PhysicalOperator = 'Table Scan' 
	or PhysicalOperator = 'Index Scan')
	and DatabaseName = @DatabaseName
order by ObjectName