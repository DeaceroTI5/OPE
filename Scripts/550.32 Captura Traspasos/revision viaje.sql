	SELECT	ClaPais, IdPlanCarga, IdBoleta ,IdNumTabular
	FROM	Opesch.OpeTraViaje WITH(NOLOCK)
	WHERE	ClaUbicacion = 360
	AND		IdViaje = 347

	SELECT	IdPlanCarga, ClaTipoPlan, ClaTipoViaje
	FROM	OpeSch.OpeTraPlanCarga WITH(NOLOCK)
	WHERE	ClaUbicacion	=  360 
	AND		IdBoleta		= 222420002

	SELECT	ClaTipoPesajeSalida , ClaMotivoEntrada, *
	FROM	OpeSch.OpeTraBoletaHis WITH(NOLOCK) 
	WHERE	ClaUbicacion	= 360
	AND		IdBoleta		= 222420002

	----Si viene de Plan de Carga, trae la boleta y el motivo entrada no, obtener valor
	--SELECT	ClaMotivoEntrada, ClaUbicacion 
	--FROM	OpeSch.OpeTraBoleta WITH(NOLOCK)
	--WHERE	IdBoleta		= 222420002



	SELECT	IdMovEntSal, IdFabricacion, IdViaje, IdFactura
	FROM	OpeSch.OpeTraMovEntSal WITH(NOLOCK)
	WHERE	ClaUbicacion	= 360 
	AND		Idboleta		= 222420002 
	AND		IdViaje			= 347 


	SELECT	DISTINCT Cli.ClaCliente, Cli.ClaEmpresa
	FROM	OpeSch.OpeTraViaje viaje WITH (NOLOCK)
	INNER	JOIN OpeSch.OpeTraMovEntSal entSal WITH (NOLOCK) 
	ON		viaje.ClaUbicacion		= entSal.ClaUbicacion 
	AND		viaje.IdViaje			= entSal.IdViaje 
	AND		ISNULL(entSal.IdFactura, -1) > 0
	INNER	JOIN OpeSch.OpeTraFabricacionVw fab WITH (NOLOCK) 
	ON		entSal.IdFabricacion	= fab.IdFabricacion 
	AND		entSal.ClaUbicacion		= fab.ClaPlanta
	LEFT	JOIN OpeSch.OpeVtaCatClienteVw Cli
	ON		Cli.ClaCliente			= fab.ClaCliente
	WHERE	viaje.ClaUbicacion		= 360
	AND		viaje.IdViaje			= 347



	---       @pnEsFacturacion INT = 1, /* 1-Facturación, 0-Bascula,3-SoloCertificados*/
	SELECT	  A.ClaMotivoEntrada, A.ClaFormatoImpresion, B.NomFormatoImpresion, A.NoCopias 
			, A.EsRequeridoAlFacturar, A.EsImprimirEnEntradas, A.EsRequeridoEnSalida
	FROM	OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
	LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) 
	ON		B.ClaFormatoImpresion	= A.ClaFormatoImpresion
	WHERE	A.ClaUbicacion			= 360 
	AND		A.ClaMotivoEntrada		= 1	-- Camion por Cargar
	AND		A.BajaLogica			= 0 
	AND		A.NoCopias				> 0
	AND		A.ClaFormatoImpresion	= 8


	SELECT	rf.* 
	FROM	OpeSch.OPETraMovEntSal op (NOLOCK)    
	INNER JOIN OpeSch.OpeReporteFactura  rf (NOLOCK)    
	on		op.ClaUbicacion		= rf.ClaUbicacion    
	AND		op.IdFactura		= rf.IdFactura		    
	AND		rf.ClaFormatoImpresion in (32,27,11,8)    
	WHERE	op.ClaUbicacion		= 360
--	AND		op.NombrePcMod		<> 'Migracion'
--	AND		OP.FechaEntSal BETWEEN '20220801' AND '20220906'
	AND		op.IdFactura IS NOT NULL    
	AND		op.IdBoleta = 222420002 


	SELECT * FROM OpeSch.OpeRelViajeDocumento WHERE ClaUbicacion = 360 AND IdViaje = 347

--	SELECT * FROM OpeSch.OpeCatMotivoEntrada WHERE ClaMotivoEntrada = 1

	SELECT *
	FROM	OPESch.TiCatConfiguracionVw WITH(NOLOCK)
	WHERE	ClaUbicacion		= 360
	AND		ClaSistema			= 127 
	AND		ClaConfiguracion	= 1271148

	SELECT *
	FROM	OPESch.TiCatConfiguracionVw WITH(NOLOCK)
	WHERE	ClaUbicacion		= 360
	AND		ClaSistema			= 127 
	AND		ClaConfiguracion	= 1271149 

	SELECT *
	FROM OPESch.TiCatConfiguracionVw WITH(NOLOCK)
	WHERE ClaUbicacion = 360
	AND ClaSistema = 127
	AND ClaConfiguracion = 1271091
	AND BajaLogica = 0

	--SELECT * FROM OPESch.OpeCatClienteRequierenCertificadosDigitales

	SELECT	* 
	FROM	OPESch.TiCatConfiguracionVw WITH(NOLOCK)
	WHERE	ClaUbicacion = 360 
	AND		ClaSistema = 127 
	AND		ClaConfiguracion = 1271066
	AND		BajaLogica = 0

	SELECT COUNT(1) FROM OPESch.OpeTraOrdenEnvio
	SELECT COUNT(1) FROM OPESch.OpeTraOrdenEnvioFabricacion
	SELECT COUNT(1) FROM OPESch.OpeCatOrdenEnvioFormatoImpresion
	SELECT * FROM OpeSch.OpeTraPlanCargaEmpaque WHERE ClaUbicacion = 360 AND IdPlanCarga = 396
	SELECT * FROM OpeSch.OpetraplancargaExporta WHERE ClaUbicacion = 360 AND IdPlanCarga = 396


	SELECT *
	FROM OpeSch.OpeTraPlanCargaLocInvVw WITH(NOLOCK)
	WHERE ClaUbicacion = 360
	and IdPlanCarga = 396

	---------------------------------------------------------------------------------
	DECLARE	@pnClaUbicacion INT

	SET @pnClaUbicacion = 360
	
	SELECT	*
	FROM	OpeSch.OpeTraViajeVw a
	INNER JOIN OpeSch.OpeTraBoletaHisVw b
	ON		a.ClaUbicacion	= b.ClaUbicacion
	AND		a.IdBoleta		= b.IdBoleta
	WHERE	a.ClaUbicacion			= @pnClaUbicacion
	AND		a.ClaTipoViaje			= 4	--Exportación
	AND		b.ClaMotivoEntrada		= 1	-- Camion por Cargar
	AND		b.ClaTipoPesajeEntrada	= 1	-- Tractor + Caja
	AND		b.ClaTipoPesajeSalida	= 4 -- Camión con Movimiento

	SELECT	* 
	FROM	OpeSch.OpeTraBoletaHisVw
	WHERE	ClaMotivoEntrada		= 1	-- Camion por Cargar
	AND		ClaTipoPesajeEntrada	= 1	-- Tractor + Caja
	AND		ClaTipoPesajeSalida		= 4 -- Camión con Movimiento



