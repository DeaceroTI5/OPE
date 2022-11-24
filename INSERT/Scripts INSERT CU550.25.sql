
--DELETE FROM OpeSch.OpeTraInfoViajeEstimacion

INSERT INTO OpeSch.OpeTraInfoViajeEstimacion
SELECT	 a.ClaUbicacion
		,a.IdViajeOrigen
		,a.ClaUbicacionOrigen
		,a.Remision
		,a.ClaTransportista
		,a.ClaTransporte
		,a.Placas
		,a.EsEntregado
		,a.ComentarioEntrega
		,a.FechaEntregado
		,a.EsRecibido
		,a.ComentarioRecepcion
		,a.FechaRecibido
		,a.FechaUltimaMod
		,a.NombrePcMod
		,a.ClaUsuarioMod
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraInfoViajeEstimacion a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraInfoViajeEstimacion b WITH(NOLOCK)
ON		a.CLAUBICACION			= b.CLAUBICACION
AND		a.IdViajeOrigen			= b.IdViajeOrigen
AND		a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
AND		a.Remision				= b.Remision
WHERE	b.ClaUbicacion IS NULL


--DELETE FROM OpeSch.OpeTraInfoViajeEstimacionDet
INSERT INTO OpeSch.OpeTraInfoViajeEstimacionDet
SELECT	  a.ClaUbicacion
		, a.ClaUbicacionOrigen
		, a.IdViajeOrigen
		, a.IdFabricacion
		, a.IdFabricacionDet
		, a.ClaArticulo
		, a.IdRenglon
		, a.Referencia1
		, a.Referencia2
		, a.Cantidad
		, a.Kilos
		, a.PesoTara
		, a.Comentario
		, a.EsRevisado
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraInfoViajeEstimacionDet a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraInfoViajeEstimacionDet b WITH(NOLOCK)
ON	a.ClaUbicacion			= b.ClaUbicacion
AND a.IdViajeOrigen			= b.IdViajeOrigen
AND a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
AND a.IdFabricacion			= b.IdFabricacion
AND a.IdFabricacionDet		= b.IdFabricacionDet
AND a.ClaArticulo			= b.ClaArticulo
AND a.IdRenglon				= b.IdRenglon
WHERE b.ClaUbicacion IS NULL


-- TRIGGER 'Opesch.OpeTraMovMciasTranEncTi', 'OPEsch.OpeTraMovMciasTranEncTd'
--DELETE FROM OpeSch.OpeTraMovMciasTranDET
--DELETE FROM Operacion.OpeSch.OpeTraMovMciasTranEnc
INSERT INTO Operacion.OpeSch.OpeTraMovMciasTranEnc
SELECT	  a.ClaUbicacion
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
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraMovMciasTranEnc a WITH(NOLOCK)
LEFT JOIN Operacion.OpeSch.OpeTraMovMciasTranEnc b WITH(NOLOCK)
ON		a.ClaUbicacion			= b.ClaUbicacion
AND		a.ClaTipoInventario		= b.ClaTipoInventario
AND		a.IdMovimiento			= b.IdMovimiento
WHERE	b.ClaUbicacion			IS NULL
AND		b.ClaTipoInventario		IS NULL
AND		b.IdMovimiento			IS NULL


-- trigger 'opesch.OpeTraMovMciasTranDetTd'

INSERT INTO OpeSch.OpeTraMovMciasTranDET
SELECT	  a.ClaUbicacion
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
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraMovMciasTranDET a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraMovMciasTranDET b WITH(NOLOCK)
ON		a.ClaUbicacion			= b.ClaUbicacion
AND		a.ClaTipoInventario		= b.ClaTipoInventario
AND		a.IdRenglon				= b.IdRenglon
AND		a.IdMovimiento			= b.IdMovimiento
WHERE	b.ClaUbicacion	IS NULL


--DELETE FROM OpeSch.OPETraMovEntSalDet
--DELETE FROM Operacion.OpeSch.OPETraMovEntSal
INSERT INTO Operacion.OpeSch.OPETraMovEntSal
SELECT	  a.ClaUbicacion
		, a.IdMovEntSal
		, a.IdBoleta
		, a.ClaMotivoEntrada
		, a.IdFabricacion
		, a.ClaUbicacionDestino
		, a.ClaUbicacionOrigen
		, a.ClaProveedor
		, a.ClaMaquilador
		, a.ClaValorEstatus
		, a.Comentarios
		, a.EntSalOrigen
		, a.FechaRecibido
		, a.EsRecibido
		, a.FechaEntSal
		, a.IdNumMovimientoInv
		, a.ClaGrupoTMA
		, a.IdViaje
		, a.EsParcialTotal
		, a.PesoEmbarcado
		, a.PesoTara
		, a.IdFactura
		, a.IdFacturaAlfanumerico
		, a.IdEntSal
		, a.Referencia
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
FROM	DEAITKNET04.Operacion.OpeSch.OPETraMovEntSal a WITH(NOLOCK)
LEFT JOIN Operacion.OpeSch.OPETraMovEntSal b WITH(NOLOCK)
ON		a.ClaUbicacion	= b.ClaUbicacion
AND		a.IdMovEntSal	= b.IdMovEntSal
WHERE	b.ClaUbicacion IS NULL


INSERT INTO OpeSch.OPETraMovEntSalDet
SELECT	  a.ClaUbicacion
		, a.IdMovEntSal
		, a.ClaArticulo
		, a.IdEntSalDet
		, a.IdFabricacion
		, a.IdFabricacionDet
		, a.CantEmbarcada
		, a.CantRecibida
		, a.PesoRecibido
		, a.PesoEmbarcado
		, a.PesoTara
		, a.ClaTMA
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
FROM	DEAITKNET04.Operacion.OpeSch.OPETraMovEntSalDet a WITH(NOLOCK)
LEFT JOIN OpeSch.OPETraMovEntSalDet b WITH(NOLOCK)
ON		a.ClaUbicacion		= b.ClaUbicacion
AND		a.IdMovEntSal		= b.IdMovEntSal
AND		a.ClaArticulo		= b.ClaArticulo
AND		a.IdEntSalDet		= b.IdEntSalDet
WHERE	b.ClaUbicacion IS NULL



--DELETE FROM  OpeSch.OpeTraEvidenciaViajeEstimacion
INSERT INTO OpeSch.OpeTraEvidenciaViajeEstimacion
SELECT	  a.ClaUbicacion
		, a.IdViajeOrigen
		, a.ClaUbicacionOrigen
		, a.Remision
		, a.NombreArchivo
		, a.Extension
		, a.Ruta
		, a.Archivo
		, a.Comentarios
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
		, a.ArchivosComprimidos
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraEvidenciaViajeEstimacion a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraEvidenciaViajeEstimacion b WITH(NOLOCK)
ON		a.ClaUbicacion			= b.ClaUbicacion
AND		a.IdViajeOrigen			= b.IdViajeOrigen
AND		a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
AND		a.Remision				= b.Remision
WHERE b.ClaUbicacion IS NULL


--DELETE FROM OpeSch.OpeBitFabricacionEstimacion
INSERT INTO OpeSch.OpeBitFabricacionEstimacion
SELECT	  a.ClaUbicacion
		, a.IdBitacora
		, a.IdFabricacionOriginal
		, a.IdFabricacionEstimacion
		, a.IdFabricacionUnificado
		, a.IdFabricacionAgrupado
		, a.Estatus
		, a.KgsPedidaPU
		, a.KgsSurtidaPU
		, a.FechaRegistro
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
FROM	DEAITKNET04.Operacion.OpeSch.OpeBitFabricacionEstimacion a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeBitFabricacionEstimacion b WITH(NOLOCK)
ON		a.IdBitacora				= b.IdBitacora
AND		a.ClaUbicacion 				= b.ClaUbicacion 
AND		a.IdFabricacionOriginal		= b.IdFabricacionOriginal
AND		a.IdFabricacionAgrupado		= b.IdFabricacionAgrupado
WHERE	b.IdBitacora				IS NULL

--DELETE FROM OpeSch.OPETraFabricacionesCanceladasEnPlanBit
--DELETE FROM OpeSch.OpeTraFabricacionDet
--DELETE FROM OpeSch.OpeTraFabricacion

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
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraFabricacion a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraFabricacion b WITH(NOLOCK)
ON		a.IdFabricacion	= b.IdFabricacion
WHERE	b.IdFabricacion  IS NULL


INSERT INTO OpeSch.OpeTraFabricacionDet
SELECT	  a.IdFabricacion
		, a.IdFabricacionDet
		, a.CantPlanes
		, a.CantSurtida
		, a.ClaEstatus
		, a.IdOpm
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
		, a.ClaveRollo
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraFabricacionDet a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraFabricacionDet b WITH(NOLOCK)
ON		a.IdFabricacion		= b.IdFabricacion
AND		a.IdFabricacionDet	= b.IdFabricacionDet
WHERE	b.IdFabricacion IS NULL



INSERT INTO OpeSch.OPETraFabricacionesCanceladasEnPlanBit
SELECT	  a.ClaUbicacion
		, a.IdFabricacion
		, a.IdFabricacionDet
		, a.ClaArticulo
		, a.IdPlanCarga
		, a.CantEmbarcar
		, a.CantEmbarcada
		, a.ClaEstatusPlanCarga
		, a.Placa
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
FROM	DEAITKNET04.Operacion.OpeSch.OPETraFabricacionesCanceladasEnPlanBit a WITH(NOLOCK)
LEFT JOIN OpeSch.OPETraFabricacionesCanceladasEnPlanBit b WITH(NOLOCK)
ON		a.ClaUbicacion			= b.ClaUbicacion
AND		a.IdFabricacion			= b.IdFabricacion
AND		a.IdFabricacionDet		= b.IdFabricacionDet
AND		a.IdPlanCarga			= b.IdPlanCarga
WHERE	b.ClaUbicacion IS NULL


--DELETE FROM OpeSch.OpeTraPlanCargaDet
--DELETE FROM OpeSch.OpeTraPlanCarga

INSERT INTO OpeSch.OpeTraPlanCarga
SELECT    a.ClaUbicacion
		, a.IdPlanCarga
		, a.ClaChofer
		, a.ClaEjeTransporte
		, a.ClaEstatusPlanCarga
		, a.ClaOperador
		, a.ClaTipoPlan
		, a.ClaTipoViaje
		, a.ClaTransporte
		, a.ClaTransportista
		, a.ClaJefeEmbarque
		, a.Comentarios
		, a.FechaPlan
		, a.FechaCaptura
		, a.PesoCubEmbarcado
		, a.PesoRealEmbarcado
		, a.NumCaja
		, a.IdBoleta
		, a.Placa
		, a.EsEmbarqueAcarreo
		, a.EsPesajeParcial
		, a.EsUltimoPesajeParcial
		, a.FechaVencimiento
		, a.ClaRuta
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
		, a.ProNumber
		, a.ClaMotivoTranspExcede
		, a.EsCargaTerminada
		, a.FechaFinalizado
		, a.FechaInicioCarga
		, a.IdPlanCargaOTM
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraPlanCarga a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraPlanCarga b WITH(NOLOCK)
ON		a.ClaUbicacion	 = b.ClaUbicacion
AND		a.IdPlanCarga	 = b.IdPlanCarga
WHERE b.ClaUbicacion IS NULL


INSERT INTO OpeSch.OpeTraPlanCargaDet
SELECT	  a.ClaUbicacion
		, a.IdPlanCarga
		, a.IdFabricacion
		, a.IdFabricacionDet
		, a.OrdenAcomodo
		, a.CantPorSurtir
		, a.CantEmbarcar
		, a.CantEmbarcada
		, a.ClaArticulo
		, a.PesoEmbarcado
		, a.PesoCub
		, a.PesoMaximoEmbarcar
		, a.EsPesajeParcial
		, a.PesoTara
		, a.Comentarios
		, a.FechaUltimaMod
		, a.NombrePcMod
		, a.ClaUsuarioMod
		, a.EsCompletaMovil
		, a.ComentariosEmbarquesDet
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraPlanCargaDet a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraPlanCargaDet b WITH(NOLOCK)
ON		a.ClaUbicacion			= b.ClaUbicacion		
AND		a.IdPlanCarga			= b.IdPlanCarga
AND		a.IdFabricacion			= b.IdFabricacion
AND		a.IdFabricacionDet		= b.IdFabricacionDet
WHERE	b.ClaUbicacion IS NULL


-------------------------------



--DELETE FROM OpeSch.OpeTraPlanCargaRemisionEstimacion
INSERT INTO OpeSch.OpeTraPlanCargaRemisionEstimacion
SELECT	  a.ClaUbicacionEstimacion
		, a.IdBoletaEstimacion
		, a.IdPlanCargaEstimacion
		, a.IdViajeEstimacion
		, a.ClaUbicacionVenta
		, a.IdBoletaVenta
		, a.IdPlanCargaVenta
		, a.IdViajeVenta
		, a.FechaIns
		, a.FechaUltimaMod
		, a.ClaUsuarioMod
		, a.NombrePCMod
FROM	DEAITKNET04.Operacion.OpeSch.OpeTraPlanCargaRemisionEstimacion a WITH(NOLOCK)
LEFT JOIN OpeSch.OpeTraPlanCargaRemisionEstimacion b WITH(NOLOCK)
ON		a.ClaUbicacionVenta			= b.ClaUbicacionVenta
AND		a.IdBoletaVenta				= b.IdBoletaVenta
AND		a.IdPlanCargaVenta			= b.IdPlanCargaVenta
AND		a.IdViajeVenta				= b.IdViajeVenta
AND		a.ClaUbicacionEstimacion	= b.ClaUbicacionEstimacion
AND		a.IdBoletaEstimacion		= b.IdBoletaEstimacion
AND		a.IdPlanCargaEstimacion		= b.IdPlanCargaEstimacion
AND		a.IdViajeEstimacion			= b.IdViajeEstimacion
WHERE	b.ClaUbicacionVenta IS NULL

	--DELETE FROM OpeSch.OPETraBoleta
	 INSERT INTO OpeSch.OPETraBoleta
	 SELECT   a.ClaUbicacion
			, a.IdBoleta
			, a.ClaBascula
			, a.ClaChofer
			, a.ClaEjeTransporte
			, a.ClaEstatusPlaca
			, a.ClaMotivoEntrada
			, a.ClaSubMotivoEntrada
			, a.ClaTipoPesaje
			, a.ClaTransporte
			, a.ClaTransportista
			, a.NomTransportista
			, a.ClaUbicacionOrigen
			, a.IdViajeOrigen
			, a.Comentarios
			, a.EsEntradaManual
			, a.FechaHoraEntrada
			, a.FechaHoraSituada
			, a.PesoDocumentado
			, a.NomChofer
			, a.NumManiobra
			, a.AplicaPagoFlete
			, a.PesoEntrada
			, a.PesoTara
			, a.Placa
			, a.Referencia
			, a.Remision
			, a.EsReutilizable
			, a.IdBoletaOrigenReuso
			, a.ClaTipoReferencia
			, a.ReferenciaNum1
			, a.ReferenciaNum2
			, a.IdPlanRecoleccion
			, a.ClaProveedor
			, a.ClaCliente
			, a.FechaUltimaMod
			, a.NombrePcMod
			, a.ClaUsuarioMod
			, a.Cita
			, a.ClaveChofer
	 FROM	DEAITKNET04.Operacion.OpeSch.OPETraBoleta a WITH(NOLOCK)
	 LEFT JOIN OpeSch.OPETraBoleta b WITH(NOLOCK)
	 ON		a.ClaUbicacion	= b.ClaUbicacion
	 AND	a.IdBoleta		= b.IdBoleta
	 WHERE	b.ClaUbicacion IS NULL

	-- DELETE FROM   OpeSch.OPETraBoletaHis
	INSERT INTO OpeSch.OPETraBoletaHis
	SELECT	  a.ClaUbicacion
			, a.IdBoleta
			, a.ClaBasculaEntrada
			, a.ClaBasculaSalida
			, a.ClaChofer
			, a.ClaEjeTransporte
			, a.ClaEstatusPlaca
			, a.ClaMotivoEntrada
			, a.ClaSubMotivoEntrada
			, a.ClaTipoPesajeEntrada
			, a.ClaTipoPesajeSalida
			, a.ClaTransporte
			, a.ClaTransportista
			, a.ClaUbicacionOrigen
			, a.IdViajeOrigen
			, a.Comentarios
			, a.EsEntradaManual
			, a.FechaHoraEntrada
			, a.FechaHoraSalida
			, a.FechaHoraSituada
			, a.PesoDocumentado
			, a.PesoNoDocumentado
			, a.NomChofer
			, a.NomTransportista
			, a.NumManiobraEntrada
			, a.NumManiobraSalida
			, a.IdNumMovimientoInv
			, a.AplicaPagoFlete
			, a.PesoEntrada
			, a.PesoTara
			, a.PesoBruto
			, a.PorcentajeDiferencia
			, a.Placa
			, a.Remision
			, a.EsReutilizable
			, a.IdBoletaOrigenReuso
			, a.IdBoletaCaja
			, a.ClaTipoReferencia
			, a.ReferenciaNum1
			, a.ReferenciaNum2
			, a.Referencia
			, a.PesoNeto
			, a.PesoSalida
			, a.PesoDiferencia
			, a.EsSalidaManual
			, a.ClaProveedor
			, a.ClaCliente
			, a.FechaHrDetenido
			, a.FechaHrPreregistro
			, a.FechaHrLiberado
			, a.FechaHrLimiteIngreso
			, a.IdPlanRecoleccion
			, a.NombrePcMod
			, a.ClaUsuarioMod
			, a.FechaUltimaMod
			, a.IdBoletaAcarreo
			, a.Cita
			, a.ClaveChofer
			, a.FechallegadaTranspTraspaso
	FROM	DEAITKNET04.Operacion.OpeSch.OPETraBoletaHis a WITH(NOLOCK)
	LEFT JOIN OpeSch.OPETraBoletaHis b WITH(NOLOCK)
	ON		a.ClaUbicacion		= b.ClaUbicacion
	AND		a.IdBoleta			= b.IdBoleta
	WHERE  b.ClaUbicacion IS NULL


	 INSERT INTO OpeSch.OpeTraRecepTraspaso 
	 SELECT   a.IdViajeOrigen
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
			, a.FechaInicioDescarga
			, a.FechaFinDescarga
	 FROM	DEAITKNET04.Operacion.OpeSch.OpeTraRecepTraspaso a WITH(NOLOCK)
	 LEFT JOIN OpeSch.OpeTraRecepTraspaso b WITH(NOLOCK)
	 ON		a.IdViajeOrigen			= b.IdViajeOrigen
	 AND	a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
	 AND	a.ClaUbicacion			= b.ClaUbicacion
	 WHERE	b.IdViajeOrigen IS NULL
	 

	 INSERT INTO OpeSch.OpeTraRecepTraspasoFab
	 SELECT   a.IdViajeOrigen
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
	 FROM	DEAITKNET04.Operacion.OpeSch.OpeTraRecepTraspasoFab a WITH(NOLOCK)
	 LEFT JOIN OpeSch.OpeTraRecepTraspasoFab b WITH(NOLOCK)
	 ON		a.IdViajeOrigen			= b.IdViajeOrigen
	 AND	a.ClaUbicacionOrigen	= b.ClaUbicacionOrigen
	 AND	a.ClaUbicacion			= b.ClaUbicacion
	 AND	a.IdFabricacion			= b.IdFabricacion
	 WHERE	b.IdViajeOrigen IS NULL


	 
	 INSERT INTO OpeSch.OpeTraRecepTraspasoProd 	 
	 SELECT   a.IdViajeOrigen
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
	 FROM	DEAITKNET04.Operacion.OpeSch.OpeTraRecepTraspasoProd a WITH(NOLOCK)	 
	 LEFT JOIN OpeSch.OpeTraRecepTraspasoProd b WITH(NOLOCK)
	 ON		a.ClaUbicacion		= b.ClaUbicacion
	 AND	a.IdViajeOrigen		= b.IdViajeOrigen
	 AND	a.ClaUbicacionOrigen= b.ClaUbicacionOrigen
	 AND	a.IdFabricacion		= b.IdFabricacion
	 AND	a.IdFabricacionDet	= b.IdFabricacionDet
	 WHERE	b.ClaUbicacion IS NULL