-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-estimate-data-compression-savings-transact-sql

declare @schema varchar(100) = 'dbo'
declare @object varchar(100) = 'email'
exec sp_estimate_data_compression_savings  @schema, @object, null, null, 'page'
exec sp_estimate_data_compression_savings  @schema, @object, null, null, 'row'

alter table [email] rebuild with (data_compression = none)