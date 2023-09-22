		SELECT	a.ClaUbicacion,
				a.NumFacturaFilial,
				a.ClaUbicacionOrigen,
				a.NumFacturaOrigen,
		--		a.IdFacturaOrigen,
		--		a.MensajeError,
				c.IdViaje, 
				c.IdFabricacion, 
				d.ClaCliente,
				a.IdFacturaFilial,
				e.IdPlanCarga,
				b.ClaTipoUbicacion
		FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
		INNER JOIN OpeSch.OpeTiCatUbicacionVw b
		ON		a.ClaUbicacionOrigen = b.ClaUbicacion
		LEFT JOIN OpesCH.OpeTraMovEntSal c WITH(NOLOCK)
		ON		a.ClaUbicacion = c.ClaUbicacion
		AND		a.NumFacturaFilial = c.IdFacturaAlfanumerico
		LEFT JOIN OpeSch.OpeVtaCTraFabricacionEncVw d WITH(NOLOCK)
		ON		c.IdFabricacion = d.IdFabricacion
		LEFT JOIN OpeSch.OpeTraViaje e WITH(NOLOCK)
		ON		c.ClaUbicacion = e.ClaUbicacion
		AND		c.IdViaje = e.IdViaje
		WHERE	a.ClaUbicacion = 324
		AND		NumFacturaFilial IN ('QN7964', 'QN7963', 'QN7969', 'QN7975', 'QN7979', 'QN7949') 
--		AND		a.ClaEstatus IN (1,2) -- Pendiente y En Proceso


--@pnClaTipoUbicacion = 2
--EXEC DEAOFINET04.Operacion.AceSch.AceGeneraCertificadoSumDirectoSrv_IGTK
--    @pnClaUbicacion             =   324,
--    @psNumFacturaFilial         =   'QN7747',
--    @pnClaUbicacionOrigen       =   7,
--    @psNumFacturaOrigen         =   'G398840',
--    @pnIdCertificado            =   @nIdCertificado     OUT,
--    @psNumeroCertificado        =   @sNumCertificado    OUT,
--    @piArchivoCertificado       =   NULL,
--    @pnClaEstatus               =   @nNumError          OUT,
--    @psMensajeError             =   @sMensajeError      OUT,
--    @pnClaViajeFilial           =   7687,
--    @pnIdFabricacionFilial      =   24833700,
--    @pnClaCliente               =   830280,
--    @pnIdFacturaFilial          =   1034007747,
--    @pnNumPlanFilial            =   7893,
--    @pnDebug                    =   1 -- default = 0