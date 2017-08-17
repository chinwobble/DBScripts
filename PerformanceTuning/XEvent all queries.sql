-- monitors all the sql queries for a database
-- press ctrl+shift+m to set the database ID that this XEvent session monitors

CREATE EVENT SESSION [XE_3dss_dev_queries2] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_pid,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([sqlserver].[database_id]=(<Database Id, int,8>) AND [sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_statement=(1)
    ACTION(sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)))),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    ACTION(sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_statement_completed(SET collect_parameterized_plan_handle=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_pid,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ([package0].[equal_uint64]([sqlserver].[database_id],<Database Id, int,8>) AND [sqlserver].[is_system]=(0)))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


