/*Script consulta linkedServer que apuntan a TiCentral/TiSeguridad*/
USE Operacion
GO

SELECT	name, provider, product,data_source, catalog
FROM	sys.servers  
WHERE	data_source = 'TICENTRAL' 
AND		catalog = 'TiSeguridad'
