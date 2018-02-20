-- monitors all the sql queries for a parciular database
-- press ctrl+shift+m to set the database ID that this XEvent session monitors
-- use the below select statement to find out the database of interest

CREATE event session [XE_db_queries] ON server ADD event sqlserver.rpc_completed(SET collect_statement=(1) action(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id) WHERE (
  [sqlserver].[database_name]=N'<database_name, string, adventuresWorks>' 
  AND 
  [package0].[equal_boolean]([sqlserver].[is_system],(0)) 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio') 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([statement],N'exec sp_reset_connection') 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Query') 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense') 
) 
), ADD event sqlserver.sp_statement_completed(SET collect_object_name=(1), 
  collect_statement=(1) action(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text) WHERE (
    [package0].[equal_boolean]([sqlserver].[is_system],(0)) 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio') 
    AND 
    [sqlserver].[database_name]=N'<database_name, string, adventuresWorks>' 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Query') 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense') 
  ) 
), ADD event sqlserver.sql_batch_completed(SET collect_batch_text=(1) action(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash) WHERE (
  [package0].[equal_boolean]([sqlserver].[is_system],(0)) 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Report Server') 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio') 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Query') 
  AND 
  [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense') 
  AND 
  [sqlserver].[database_name]=N'<database_name, string, adventuresWorks>' 
) 
), ADD event sqlserver.sql_statement_completed(SET collect_parameterized_plan_handle=(1), 
  collect_statement=(1) action(sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id) WHERE (
    [sqlserver].[database_name]=N'<database_name, string, adventuresWorks>' 
    AND 
    [package0].[equal_boolean]([sqlserver].[is_system],(0)) 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio') 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Report Server') 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Query') 
    AND 
    [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense') 
  ) 
) ADD target package0.ring_buffer WITH (max_memory=4096 kb, 
event_retention_mode=allow_single_event_loss, 
max_dispatch_latency=2 seconds, 
max_event_size=0 kb, 
memory_partition_mode=none, 
track_causality=OFF, 
startup_state=OFF)