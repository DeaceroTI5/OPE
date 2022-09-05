BEGIN TRAN

SELECT *

FROM vtapta.dbo.v_fab_real_enc a

where a.cla_fabricacion in (select idfabricacionoriginal from opesch.OpeBitFabricacionEstimacionVw)



SELECT *

FROM Ventas.[VtaSch].[VtaCTraFabricacionEnc] a

WHERE a.idFabricacion in (select idfabricacionoriginal from opesch.OpeBitFabricacionEstimacionVw)



SELECT *

FROM Operacion.OpeSch.OpeTraFabricacion a

WHERE a.idFabricacion in (select idfabricacionoriginal from opesch.OpeBitFabricacionEstimacionVw)


	DECLARE @nPlantaVirtual INT
	SET		@nPlantaVirtual = 365
	
	UPDATE	a
	SET		a.cla_planta = @nPlantaVirtual
	FROM	vtapta.dbo.v_fab_real_enc a WITH(NOLOCK)
	WHERE	a.cla_planta <> @nPlantaVirtual
	AND		a.cla_fabricacion IN (SELECT idfabricacionoriginal FROM opesch.OpeBitFabricacionEstimacionVw )
   

	UPDATE	a
	SET		a.claUbicacion = @nPlantaVirtual
	FROM	Ventas.[VtaSch].[VtaCTraFabricacionEnc] a WITH(NOLOCK)
	WHERE	a.claUbicacion <> @nPlantaVirtual
	AND		a.idFabricacion IN (SELECT idfabricacionoriginal FROM opesch.OpeBitFabricacionEstimacionVw)


	UPDATE	a
	SET		a.claUbicacion = 365
	FROM	Operacion.OpeSch.OpeTraFabricacion a WITH(NOLOCK)
	WHERE	a.claUbicacion <> @nPlantaVirtual
	AND		a.idFabricacion IN (SELECT idfabricacionoriginal FROM opesch.OpeBitFabricacionEstimacionVw)

SELECT *

FROM vtapta.dbo.v_fab_real_enc a

where a.cla_fabricacion in (select idfabricacionoriginal from opesch.OpeBitFabricacionEstimacionVw)



SELECT *

FROM Ventas.[VtaSch].[VtaCTraFabricacionEnc] a

WHERE a.idFabricacion in (select idfabricacionoriginal from opesch.OpeBitFabricacionEstimacionVw)



SELECT *

FROM Operacion.OpeSch.OpeTraFabricacion a

WHERE a.idFabricacion in (select idfabricacionoriginal from opesch.OpeBitFabricacionEstimacionVw)

ROLLBACK TRAN