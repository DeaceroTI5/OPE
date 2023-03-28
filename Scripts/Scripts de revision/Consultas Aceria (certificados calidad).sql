-- Revisión relacionada con el mensaje de error al capturar certificados (Error algenerar certificado)

	SELECT	ClaUbicacionFilialVentas = ClaUbicacionVentas
	FROM	AceSch.AceTiCatUbicacionVw
	WHERE	ClaUbicacion = 324--@pnClaUbicacion	
	
	SELECT	*
	FROM	AceSch.VtaCTraFacturaVw WITH(NOLOCK)
	WHERE	IdFacturaAlfanumerico IN ('QN3635', 'QN2675', 'QN2666')

	SELECT 	
			*
	FROM	ACESch.AceTraCertificado (NOLOCK)
	WHERE	IdFactura IN (1034002666, 1034002675, 1034003635)
	AND		ClaUbicacion		= 324
--	AND		ClaUbicacionOrigen	= @pnClaUbicacionOrigen
--	AND		IdViaje				= @nIdViajeItk
--	AND		IdFabricacion		= @IdFabricacionItk
	ORDER BY FechaUltimaMod DESC


	SELECT	* -- IdViaje
	FROM	ACESch.AcePloCTraMovEntSalVw WITH(NOLOCK)
	WHERE	ClaUbicacion	= 324
	AND		IdFactura IN (1034002666, 1034002675, 1034003635)


	--------------------------------------------------------------------------

       DECLARE         @sNumFacturaFilial INT
                     , @sNumFacturaOrigen INT
                     , @idFabricacionItk         INT
       --            , @idFabricacionOrigen     INT
                     , @nClaUbicacionFilialVentas INT
                     , @nClaUbicacionOrigenVentas INT

       SELECT @nClaUbicacionFilialVentas = ClaUbicacionVentas
       FROM   AceSch.AceTiCatUbicacionVw
       WHERE  ClaUbicacion = @pnClaUbicacion

       SELECT @nClaUbicacionOrigenVentas = ClaUbicacionVentas
       FROM   AceSch.AceTiCatUbicacionVw
       WHERE  ClaUbicacion = @pnClaUbicacionOrigen


       SELECT @idFabricacionItk   = IdFabricacion,
                     @sNumFacturaFilial  = IdFacturaAlfanumerico
       FROM   AceSch.VtaCTraFacturaVw WITH(NOLOCK)
       WHERE  IdFactura = @pnIdFactura


       SELECT @sNumFacturaOrigen         = IdFacturaAlfanumerico
       --            @idFabricacionOrigen = IdFabricacion                    
       FROM   AceSch.VtaCTraFacturaVw WITH(NOLOCK)
       WHERE  IdFactura                   = @pnIdFacturaOrigen 
