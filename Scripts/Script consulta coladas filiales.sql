SELECT * FROM opeSch.AceColadaEmbarcadaIngetekVw  WHERE Cla_Planta IN (7,1,22)

SELECT	HeatID
		, IdColada	= CASE WHEN CHARINDEX('-',HeatID) > 0 THEN SUBSTRING(HeatID,1,CHARINDEX('-',HeatID)-1) ELSE NULL END
		, Secuencia	= CASE WHEN CHARINDEX('-',HeatID) > 0 THEN SUBSTRING(HeatID,CHARINDEX('-',HeatID)+1,LEN(HeatID)) ELSE NULL END
INTO	#Remisiones
FROM	OpeSch.OPEASAShippingTicketHeatData WITH(NOLOCK)

DELETE FROM #Remisiones WHERE IdColada IS NULL OR Secuencia IS NULL

SELECT	DISTINCT a.Cla_Colada AS IdColada , a.Cla_Secuencia AS Secuencia
		, Cla_horno_fusion AS Horno ,Cla_Molino AS Molino
INTO	#Universo
FROM	opeSch.AceColadaEmbarcadaIngetekVw  a
INNER JOIN #Remisiones b 
ON		CONVERT(VARCHAR(10),a.Cla_Colada) = CONVERT(VARCHAR(10),b.IdColada)
AND		CONVERT(VARCHAR(10),a.Cla_Secuencia) = CONVERT(VARCHAR(10),b.Secuencia)
WHERE	a.Cla_Planta IN (7,1,22)	




SELECT	IdColada, Secuencia,  COUNT(1) Conteo
FROM	#Universo
GROUP BY IdColada, Secuencia
HAVING COUNT(1) > 1

SELECT	IdColada, Secuencia, Horno, COUNT(1) Conteo
FROM	#Universo
GROUP BY IdColada, Secuencia, Horno
HAVING COUNT(1) > 1


-- DELETE FROM OpeSch.OpeTraPlanCargaColada

UPDATE	a 
SET		Cla_Molino = 4
FROM	

SELECT distinct Cla_Secuencia, Cla_horno_fusion, Cla_Molino
FROM	opeSch.AceColadaEmbarcadaIngetekVw  a
WHERE	Cla_Planta IN (7,1,22)	
AND		cla_colada = 125497


-- DROP TABLE #Remisiones
-- DROP TABLE #Universo


UPDATE	a 
SET		Cla_Molino = 4
FROM	opeSch.AceColadaEmbarcadaIngetekVw  a
WHERE	Cla_Planta IN (7,1,22)	
AND		cla_colada = 125497
AND		Num_Viaje = 656484

INSERT INTO opeSch.AceColadaEmbarcadaIngetekVw
SELECT    Cla_Cliente
		, Cla_Consignado
		, Cla_Planta				= 1
		, Num_Viaje
		, Fecha_Viaje
		, Num_Factura
		, Cla_pedido
		, Renglon
		, Fol_Producto
		, Num_orden
		, Cla_Producto_Cargado
		, Cla_version_cargada
		, Cla_Colada_Cargada		
		, Cla_horno_fusion			= 1
		, Cla_Colada				= 121484
		, Cla_Molino				= 2
		, Cla_Secuencia				= 121789
FROM	opeSch.AceColadaEmbarcadaIngetekVw  a
WHERE	Cla_Planta IN (7,1,22)	
AND		cla_colada = 125497
AND		Num_Viaje = 656484


	SELECT	nValor1,nValor2, svalor1
	FROM	OpcSch.OpcTiCatConfiguracionVw WITH(NOLOCK)
	WHERE	ClaUbicacion= 325
	AND		ClaSistema = 127 
	AND		ClaConfiguracion IN (1271213, 1271214 ,1271215)



EXEC OPESch.OpeObtenerHornoMolinoAceProc
	  @pnClaUbicacion	= 325
	, @pnIdColada		= 125497
	, @pnSecuencia		= 123312
	, @pnClaProveedorMP	= 1
	, @pnClaHorno		= null
	, @pnClaMolino		= 4
	, @pnDebug			= 1