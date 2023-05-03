USE Integrator
GO

SELECT	* 
FROM	Integrator.dbo.Integrator_grupos 
WHERE	grupo = 'Manufactura' 
AND		sub_grupo = 'Operacion'

SELECT	*
FROM	Integrator.dbo.Integrator_tablas a 
WHERE	grupo = 'Manufactura' 
AND		sub_grupo = 'Operacion' 
AND		(tabla_destino LIKE '%ArticuloComposicion%' 
			OR tabla_destino LIKE '%ArticuloCapacidad%'
		)

--- /*UPDATE*/ 
BEGIN TRAN
	UPDATE	a
	SET		where_adic = 'ClaPlanta in (185,322,323,324,325,326,327,328,329,360,361,362,363,366,367,368,375,434,435,437)'
			,fuc = GETDATE()
	FROM	Integrator.dbo.Integrator_tablas a WHERE grupo = 'Manufactura' AND sub_grupo = 'Operacion' AND tabla_destino LIKE '%ArticuloComposicion%'


	UPDATE	a
	SET		 where_adic = 'ClaPlanta in (185,322,323,324,325,326,327,328,329,360,361,362,363,366,367,368,375,434,435,437)'
			,fuc = GETDATE()
	FROM	Integrator.dbo.Integrator_tablas a WHERE grupo = 'Manufactura' AND sub_grupo = 'Operacion' AND tabla_destino LIKE '%ArticuloCapacidad%'

SELECT	*
FROM	Integrator.dbo.Integrator_tablas a 
WHERE	grupo = 'Manufactura' 
AND		sub_grupo = 'Operacion' 
AND		(tabla_destino LIKE '%ArticuloComposicion%' 
			OR tabla_destino LIKE '%ArticuloCapacidad%'
		)


COMMIT TRAN
