USE Operacion
GO
ALTER VIEW OpeSch.OpeRelMovMciasTranMxUsaVw
AS
	WITH  ViajesEnc AS (	
			SELECT    ClaUbicacionOrigen = a.ClaUbicacion
					, IdViajeOrigen = a.NumViaje
					, Placa = a.Placas
					, c.ClaUbicacionDestino
					, IdMovimiento
					, ClaTipoInventario
					, Estatus = EstatusTransito
			FROM    OpeSch.OpeTraMovMciasTranEncVw a WITH(NOLOCK)
			INNER JOIN OpeSch.OpeTiCatUbicacionVw  b
			ON		a.ClaUbicacion			= b.ClaUbicacion
			AND		a.ClaUbicacionOrigen	= b.ClaUbicacion
	--		AND		b.ClaEmpresa			= 52
			CROSS APPLY(	
						SELECT	TOP 1 ClaUbicacionDestino
						FROM	OpeSch.OpeTraMovMciasTranDetVw c
						INNER JOIN OpeSch.OpeTiCatUbicacionVw d
						ON		c.ClaUbicacionDestino	= d.ClaUbicacion
						AND		d.ClaEmpresa			= 59
						WHERE	a.ClaUbicacion		= c.ClaUbicacion
						AND		a.ClaTipoInventario = c.ClaTipoInventario
						AND		a.IdMovimiento		= c.IdMovimiento
					) c
			WHERE	a.EstatusTransito IN (0,1)
	)	
		SELECT	  a.ClaUbicacionOrigen 
				, a.IdViajeOrigen 
				, a.Placa 
				, a.ClaUbicacionDestino 
				, a.Estatus
				, IdMovimiento
				, ClaTipoInventario
				, b.ClaEstatus
				, b.EsRecepcionTerminada
		FROM	ViajesEnc a
		LEFT JOIN OpeSch.OpeTraRecepTraspaso b WITH(NOLOCK)
		ON		a.IdViajeOrigen = b.IdViajeOrigen
		AND		a.ClaUbicacionOrigen = b.ClaUbicacionOrigen
		AND		a.ClaUbicacionDestino= b.ClaUbicacion


RETURN


		--SELECT * FROM OpeSch.OpeTraPlanCarga WHERE IdPlanCarga = 68944
		--SELECT * FROM OpeSch.OpeTiCatestatusVw WHERE ClaClasificacionEstatus =   390004
		--SELECT * FROM dbo.TiCatClasificacionEstatusVw WHERE NombreClasificacionEstatus LIKE '%recep%'
		--SELECT * FROM dbo.TiCatClasificacionEstatusVw WHERE NombreClasificacionEstatus LIKE '%traspaso%'

		INSERT INTO OpeSch.OpeTraMovMciasTranEncVw
		SELECT    a.ClaUbicacion
				, a.ClaTipoInventario
				, a.IdMovimiento
				, a.ClaMotivoInventario
				, a.ClaTipoClaveMovimiento
				, a.ClaUbicacionOrigen
				, a.ClaUsuarioAutorizo
				, a.ClaveMovimiento
				, a.FechaAutorizacion
				, a.EstatusTransito
				, a.FechaHoraMovimiento
				, a.NombrePcAutorizo
				, a.NoRenglonesMovimiento
				, a.PesoEntrada
				, a.PesoNeto
				, a.PesoSalida
				, a.PesoTara
				, a.NumViaje
				, a.CampoEntero1
				, a.CampoEntero2
				, a.CampoEntero3
				, a.CampoEntero4
				, a.CampoEntero5
				, a.CampoEntero6
				, a.CampoEntero7
				, a.CampoEntero8
				, a.CampoEntero9
				, a.CampoEntero10
				, a.CampoTexto1
				, a.CampoTexto2
				, a.CampoTexto3
				, a.CampoTexto4
				, a.CampoTexto5
				, a.CampoTexto6
				, a.CampoTexto7
				, a.CampoTexto8
				, a.CampoTexto9
				, a.CampoTexto10
				, a.FechaMovimiento
				, a.FechaCierreTraspaso
				, a.Moneda
				, a.ClaTransporte
				, a.ClaTransportista
				, a.Placas
				, a.NombreChofer
				, a.FechaUltimaMod
				, a.ClaUsuarioMod
				, a.NombrePcMod
				, a.ClaGrupoTMA
				, a.PesoDocumentado
				, a.PesoNoDocumentado
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraMovMciasTranEncVw a
		LEFT JOIN OpeSch.OpeTraMovMciasTranEncVw b
		ON		a.ClaUbicacion			= b.ClaUbicacion
		AND		a.ClaTipoInventario		= b.ClaTipoInventario
		AND		a.IdMovimiento			= b.IdMovimiento
		INNER JOIN DEAITKUSANET01.Operacion.OpeSch.OpeRelMovMciasTranMxUsaVw c
		ON		a.ClaUbicacion			= c.ClaUbicacionOrigen
		AND		a.ClaTipoInventario		= c.ClaTipoInventario
		AND		a.IdMovimiento			= c.IdMovimiento
		WHERE	b.ClaUbicacion IS NULL

		INSERT INTO OpeSch.OpeTraMovMciasTranDetVw 
		SELECT	 a.ClaUbicacion
				, a.ClaTipoInventario
				, a.IdRenglon
				, a.IdMovimiento
				, a.ClaTMA
				, a.ClaArticulo
				, a.ClaUbicacionDestino
				, a.CampoEntero1
				, a.CampoEntero2
				, a.CampoEntero3
				, a.CampoEntero4
				, a.CampoEntero5
				, a.CampoEntero6
				, a.CampoTexto1
				, a.CampoTexto2
				, a.CantidadEnviada
				, a.CantidadRecibida
				, a.CantidadCancelada
				, a.CantidadDepurada
				, a.Saldo
				, a.EntradaSalida
				, a.EstatusTransito
				, a.FechaHoraMovimiento
				, a.Importe
				, a.KilosPesados
				, a.KilosTeoricos
				, a.PesoTeorico
				, a.ReferenciaCompras
				, a.MciasTranProcesado
				, a.FechaUltimaMod
				, a.ClaUsuarioMod
				, a.NombrePcMod
				, a.KilosTara
				, a.NumericoExtra1
				, a.NumericoExtra2
				, a.NumericoExtra3
				, a.NumericoExtra4
				, a.NumericoExtra5
				, a.NumericoExtra6
				, a.NumericoExtra7
				, a.TextoExtra1
				, a.TextoExtra2
				, a.TextoExtra3
				, a.TextoExtra4
				, a.TextoExtra5
				, a.TextoExtra6
				, a.TextoExtra7
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraMovMciasTranDetVw a
		INNER JOIN OpeSch.OpeTraMovMciasTranEncVw c
		ON		a.ClaUbicacion			= c.ClaUbicacion
		AND		a.ClaTipoInventario		= c.ClaTipoInventario
		AND		a.IdMovimiento			= c.IdMovimiento
		LEFT JOIN OpeSch.OpeTraMovMciasTranDetVw b
		ON		a.ClaUbicacion			= b.ClaUbicacion
		AND		a.ClaTipoInventario		= b.ClaTipoInventario
		AND		a.IdRenglon				= b.IdRenglon
		AND		a.IdMovimiento			= b.IdMovimiento
		WHERE	b.ClaUbicacion IS NULL

		INSERT INTO OpeSch.OpeTraRecepTraspaso
		SELECT    a.IdViajeOrigen
				, a.ClaUbicacionOrigen
				, a.ClaUbicacion
				, a.IdBoleta
				, a.FechaViaje
				, a.ClaTransporte
				, a.ClaTransportista
				, a.NomTransportista
				, a.NomChofer
				, a.Placa
				, a.NumCaja
				, a.Sello
				, a.ComentariosOrigen
				, a.PesoDocumentado
				, a.ClaEstatus
				, a.ClaAgenteAduanal
				, a.HrLlegadaAreaDescarga
				, a.HrInicioDescarga
				, a.HrFinDescarga
				, a.HrLiberacion
				, a.ContieneTaraRetornable
				, a.ComentariosRecepcion
				, a.FechaUltimaMod
				, a.NombrePcMod
				, a.ClaUsuarioMod
				, a.EsFacturadoVirtual
				, a.EsCruzoFrontera
				, a.EsRecepcionTerminada
				, a.ClaOperador
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraRecepTraspaso a
		LEFT JOIN OpeSch.OpeTraRecepTraspaso b
		ON		a.IdViajeOrigen			= b.IdViajeOrigen		
		AND		a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= b.ClaUbicacion		
		INNER JOIN DEAITKUSANET01.Operacion.OpeSch.OpeRelMovMciasTranMxUsaVw c
		ON		a.IdViajeOrigen			= c.IdViajeOrigen		
		AND		a.ClaUbicacionOrigen	= c.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= c.ClaUbicacionDestino	
		WHERE 	b.ClaUbicacion IS NULL

		INSERT INTO OpeSch.OpeTraFabricacion
		SELECT    a.IdFabricacion
				, a.ClaEstatus
				, a.ClaTipoMercadoPta
				, a.FechaPromesaActual
				, a.FechaUltimaMod
				, a.NombrePcMod
				, a.ClaUsuarioMod
				, a.ClaUbicacion
				, a.FechaIns
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraFabricacion a WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraFabricacion b WITH(NOLOCK)
		ON		a.IdFabricacion	= b.IdFabricacion
		WHERE	b.IdFabricacion IS NULL

		INSERT INTO OpeSch.OpeTraFabricacionDet
		SELECT    a.IdFabricacion
				, a.IdFabricacionDet
				, a.CantPlanes
				, a.CantSurtida
				, a.ClaEstatus
				, a.IdOpm
				, a.FechaUltimaMod
				, a.NombrePcMod
				, a.ClaUsuarioMod
				, a.ClaveRollo
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraFabricacionDet a WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraFabricacionDet b WITH(NOLOCK)
		ON		a.IdFabricacion = b.IdFabricacion
		AND		a.IdFabricacionDet = b.IdFabricacionDet
		WHERE	b.IdFabricacion IS NULL


		INSERT INTO OpeSch.OpeTraRecepTraspasoFab
		SELECT    a.IdViajeOrigen
				, a.ClaUbicacionOrigen
				, a.ClaUbicacion
				, a.IdFabricacion
				, a.EsRecibida
				, a.IdEntSalOrigen
				, a.IdFacturaOrigen
				, a.IdEntSalDestino
				, a.CantTotalEmpaque
				, a.Comentarios
				, a.FechaUltimaMod
				, a.NombrePcMod
				, a.ClaUsuarioMod
				, a.IdFacturaAlfanumericoOrigen
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraRecepTraspasoFab a WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraRecepTraspasoFab b WITH(NOLOCK)
		ON		a.IdViajeOrigen			= b.IdViajeOrigen
		AND		a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= b.ClaUbicacion
		AND		a.IdFabricacion			= b.IdFabricacion
		INNER JOIN OpeSch.OpeTraRecepTraspaso c
		ON		a.IdViajeOrigen			= c.IdViajeOrigen		
		AND		a.ClaUbicacionOrigen	= c.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= c.ClaUbicacion	
		WHERE 	b.IdViajeOrigen IS NULL
		-- FK_OpeTraRecepTraspasoFabOpeTraRecepTraspaso



		INSERT INTO OpeSch.OpeTraRecepTraspasoProd
		SELECT    a.IdViajeOrigen
				, a.ClaUbicacionOrigen
				, a.ClaUbicacion
				, a.IdFabricacion
				, a.IdFabricacionDet
				, a.ClaArticuloRemisionado
				, a.CantRemisionada
				, a.PesoRemisionado
				, a.PesoTaraRemisionado
				, a.AplicaReclasificacion
				, a.FechaUltimaMod
				, a.NombrePcMod
				, a.ClaUsuarioMod
				, a.IdMovimientoInvRec
				, a.ImporteRemisionado
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraRecepTraspasoProd a WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraRecepTraspasoProd b WITH(NOLOCK)
		ON		a.ClaUbicacion			= b.ClaUbicacion
		AND		a.IdViajeOrigen			= b.IdViajeOrigen
		AND		a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
		AND		a.IdFabricacion			= b.IdFabricacion
		AND		a.IdFabricacionDet		= b.IdFabricacionDet
		INNER JOIN OpeSch.OpeTraRecepTraspaso c
		ON		a.IdViajeOrigen			= c.IdViajeOrigen		
		AND		a.ClaUbicacionOrigen	= c.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= c.ClaUbicacion		
		WHERE 	b.ClaUbicacion IS NULL

		INSERT INTO OpeSch.OpeTraRecepTraspasoProdRecibido
		SELECT a.IdViajeOrigen
				, a.ClaUbicacionOrigen
				, a.ClaUbicacion
				, a.IdFabricacion
				, a.IdFabricacionDet
				, a.IdRenglonRecepcion
				, a.ClaAlmacen
				, a.ClaSubAlmacen
				, a.ClaSubSubAlmacen
				, a.ClaSeccion
				, a.Referencia1
				, a.Referencia2
				, a.Referencia3
				, a.Referencia4
				, a.Referencia5
				, a.ClaArticuloRecibido
				, a.CantRecibida
				, a.PesoRecibido
				, a.PesoTaraRecibido
				, a.ComentariosRecepcion
				, a.FechaUltimaMod
				, a.NombrePcMod
				, a.ClaUsuarioMod
				, a.ClaTipoInventario
				, a.EsPesajeParcial
				, a.KilosReales
				, a.IdBoleta
				, a.PorcentajeMaterial
				, a.ClaTaraRecibida
				, a.CantTaraRecibida
		FROM	DEAITKUSANET01.Operacion.OpeSch.OpeTraRecepTraspasoProdRecibido a WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeTraRecepTraspasoProdRecibido b WITH(NOLOCK)
		ON		a.IdViajeOrigen			= b.IdViajeOrigen
		AND		a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= b.ClaUbicacion
		AND		a.IdFabricacion			= b.IdFabricacion
		AND		a.IdFabricacionDet		= b.IdFabricacionDet
		AND		a.IdRenglonRecepcion	= b.IdRenglonRecepcion
		INNER JOIN OpeSch.OpeTraRecepTraspaso c
		ON		a.IdViajeOrigen			= c.IdViajeOrigen		
		AND		a.ClaUbicacionOrigen	= c.ClaUbicacionOrigen
		AND		a.ClaUbicacion			= c.ClaUbicacion		
		WHERE 	b.ClaUbicacion IS NULL