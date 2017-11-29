-- monitors all the sql queries for a parciular database
-- press ctrl+shift+m to set the database ID that this XEvent session monitors
-- use the below select statement to find out the db_id

-- [db_of_interest]; select db_id();


CREATE EVENT SESSION [XE_db_queries] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(<Database Id, int,8>)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)) AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio') AND [statement]<>N'exec sp_reset_connection')),
ADD EVENT sqlserver.sp_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)) AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio') AND [sqlserver].[database_id]=(<Database Id, int,8>))),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)) AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Report Server') AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio'))),
ADD EVENT sqlserver.sql_statement_completed(SET collect_parameterized_plan_handle=(1)
    ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],(<Database Id, int,8>)) AND [package0].[equal_boolean]([sqlserver].[is_system],(0)) AND [sqlserver].[client_app_name]<>N'Microsoft SQL Server Management Studio' AND [sqlserver].[client_app_name]<>N'Report Server'))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=2 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO




