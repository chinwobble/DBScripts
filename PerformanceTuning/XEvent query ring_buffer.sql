--uery the XML to get the Target Data 
declare @xevent_session_name varchar(100) = 'xe_db_queries'
;with xevents AS 
(
	SELECT 
		event.value('(event/@name)[1]', 'varchar(50)') AS event_name, 
		DATEADD(hh, 
				DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
				event.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp], 
		ISNULL(event.value('(event/data[@name="statement"]/value)[1]', 'nvarchar(max)'), 
				event.value('(event/data[@name="batch_text"]/value)[1]', 'nvarchar(max)')) AS [stmt/btch_txt], 
		event.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as [sql_text],
		event.value('(event/data[@name="logical_reads"]/value)[1]','nvarchar(max)') as logical_reads,
		event.value('(event/data[@name="writes"]/value)[1]','nvarchar(max)') as writes,
		event.value('(event/data[@name="duration"]/value)[1]','nvarchar(max)') as duration,
		event.value('(event/action[@name="database_id"]/value)[1]','nvarchar(max)') as database_id
		
	FROM 
	(   SELECT n.query('.') as event 
		FROM 
		( 
			SELECT CAST(target_data AS XML) AS target_data 
			FROM sys.dm_xe_sessions AS s    
			JOIN sys.dm_xe_session_targets AS t 
				ON s.address = t.event_session_address 
			WHERE s.name = @xevent_session_name
			  AND t.target_name = 'ring_buffer' 
		) AS sub 
		CROSS APPLY target_data.nodes('RingBufferTarget/event') AS q(n) 
	) AS tab
)
select *
from xevents
--where timestamp > '2018-02-20 18:40'