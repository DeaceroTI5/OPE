USE Operacion
GO


	CREATE TABLE #Inventario (
		  ClaMovimiento			INT
		, FechaHoraMovimiento   DATETIME
		, HoraMovimiento        DATETIME
		, ClaveArticulo			VARCHAR(30)
		, NomArticulo           VARCHAR(200)
		, DescripcionTMA        VARCHAR(100)
		, EntradaSalida			INT
		, Cantidad				NUMERIC(22,4)
		, KilosTeoricos         NUMERIC(22,4)
		, ExistenciaCantidad    NUMERIC(22,4)
		, ExistenciaKilos       NUMERIC(22,4)
		, NomAlmacen            VARCHAR(50)
		, NomSubAlmacen         VARCHAR(50)
		, NomSubSubAlmacen      VARCHAR(50)
		, NomSeccion            VARCHAR(50)
		, NomTipoReferencia1    VARCHAR(50)
		, ValorReferencia1      VARCHAR(30)
		, NomTipoReferencia2    VARCHAR(50)
		, ValorReferencia2      VARCHAR(30)
		, NomTipoReferencia3    VARCHAR(50)
		, ValorReferencia3      VARCHAR(30)
		, ViajeOriginal			INT
		, ReferenciaCompras		INT
		, UsuarioModifico       VARCHAR(100)
		, PCModifico			VARCHAR(65)
		, ClaUsuarioMod			INT
		, IdRenglon				INT
	)

	CREATE TABLE #MovMaquilador (
		  Id						INT IDENTITY(1,1)
		, IdRegistroMovMaquilador	INT
		, IdMovimientoPlanta		INT
		, CantidadMovimiento		NUMERIC(22,4)
		, KilosMovimiento			NUMERIC(22,4)
		, ClaArticulo 				INT
		, Fecha						DATETIME
		, Hora						DATETIME
		, Boleta					INT
		, Placa						VARCHAR(20)
		, IdRenglon					INT
		, NomTipoMov				VARCHAR(20)
		, Ajuste					VARCHAR(200)
	)
	
	--------------------------------------------------------------
	-- Existencias Maquilador
	SELECT	a.claMaquilador,
			c.NomMaquilador,
			a.claArticulo,
			nomArticulo = 	b.claveArticulo+ '-' + b.nomArticulo,
			a.cantidad,
			a.kilos,
			a.FechaUltimaMod,
			a.NombrePcMod,
			a.ClaUsuarioMod
	INTO	#Existencias
	FROM	OpeSch.OpeTraExistenciaMaquilador a WITH(NOLOCK)
	LEFT JOIN OpeSch.OpeArtCatArticuloVw b	WITH(NOLOCK) 
	ON		a.claArticulo = b.claArticulo
	AND		a.ClaTipoInventario = b.ClaTipoInventario
	LEFT JOIN OpeSch.OpeCatMaquilador c	WITH(NOLOCK) 
	ON		a.ClaUbicacion	= c.ClaUbicacion
	AND		a.ClaMaquilador = c.ClaMaquilador
	WHERE	a.ClaUbicacion	= 54
	ORDER BY c.NomMaquilador, b.nomArticulo


	--------------------
	-- Movimientos Maquilador
	SELECT	t1.IdRegistroMovMaquilador, 
			t1.FechaMovimiento,
			t1.FechaMovimiento AS HoraMovimiento,
			t1.ClaMaquilador,
			t3.NomMaquilador,
			t2.IdRenglon,
			t2.ClaArticulo,
			t4.ClaveArticulo,
			LTRIM(t4.ClaveArticulo) +  ' - ' + LTRIM(t4.NomArticulo) AS NomArticulo,
			t2.ClaTipoInventario,
			t2.TipoMovimiento,
			CantidadMovimiento = t2.CantidadMovimiento * TipoMovimiento,
			KilosMovimiento = t2.KilosMovimiento * TipoMovimiento,
			t2.IdMovimientoPlanta,
			t2.IdRenglonPlanta,
			t5.IdBoleta		AS IdBoleta,
			t5.Placa,
			t6.idFolioAjuste,	
			t1.NombrePcMod	AS PCModifico,
			t10.NomUsuario	AS UsuarioModifico,
			t7.NomTipoMov	AS NomTipoMov,
			t6.Motivo		AS MotivoAjuste
	INTO	#MovimientosMaquilador
	FROM	OpeSch.OpeTraRegistroMovMaquilador			t1	WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraRegistroMovMaquiladorDet	t2  WITH(NOLOCK) 
	ON		t2.ClaUbicacion = t1.ClaUbicacion	
	AND		t2.IdRegistroMovMaquilador	= t1.IdRegistroMovMaquilador
	INNER JOIN OpeSch.OpeCatMaquilador					t3	WITH(NOLOCK) 
	ON		t3.ClaUbicacion = t1.ClaUbicacion	
	AND		t3.ClaMaquilador			= t1.ClaMaquilador
	INNER JOIN OpeSch.OpeArtCatArticuloVw				t4	WITH(NOLOCK) 
	ON		t4.ClaArticulo  = t2.ClaArticulo	
	AND		t4.ClaTipoInventario		= t2.ClaTipoInventario
	LEFT  JOIN OpeSch.OpeTraBoletaHis					t5	WITH(NOLOCK) 
	ON		t5.ClaUbicacion = t1.ClaUbicacion	
	AND		t5.IdNumMovimientoInv		= t2.IdMovimientoPlanta
	LEFT  JOIN OpeSch.OpeTraAjusteManualMaquilador		t6  WITH(NOLOCK) 
	ON		t6.ClaUbicacion = t1.ClaUbicacion   
	AND		t6.IdRegistroMovMaquilador  = t1.IdRegistroMovMaquilador
	INNER JOIN OpeSch.OpeCatTipoMovMaquiladorVw			t7	WITH(NOLOCK) 
	ON		t7.ClaTipoMov	= t2.TipoMovimiento
	INNER JOIN OpeSch.OpeTiCatUsuarioVw					t10 WITH(NOLOCK) 
	ON		t10.ClaUsuario  = t1.ClaUsuarioMod 
	WHERE	t1.ClaUbicacion = 54
	AND		t1.ClaMaquilador = 1
	ORDER BY t3.NomMaquilador, t1.FechaMovimiento DESC, t1.IdRegistroMovMaquilador DESC, t4.ClaveArticulo

	-------------------------------------------------
	-- Ajustes
	SELECT	t1.IdRegistroMovMaquilador, 
			t1.FechaMovimiento,
			t1.FechaMovimiento AS HoraMovimiento,
			t1.ClaMaquilador,
			t2.IdRenglon,
			t2.ClaArticulo,	
			CantidadMovimiento = t2.CantidadMovimiento * TipoMovimiento,
			t6.idFolioAjuste,	
			t6.Motivo		AS MotivoAjuste
	INTO	#Ajuste
	FROM	OpeSch.OpeTraRegistroMovMaquilador			t1	WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraRegistroMovMaquiladorDet	t2  WITH(NOLOCK) 
	ON		t2.ClaUbicacion = t1.ClaUbicacion	
	AND		t2.IdRegistroMovMaquilador	= t1.IdRegistroMovMaquilador
	INNER  JOIN OpeSch.OpeTraAjusteManualMaquilador		t6  WITH(NOLOCK) 
	ON		t6.ClaUbicacion = t1.ClaUbicacion   
	AND		t6.IdRegistroMovMaquilador  = t1.IdRegistroMovMaquilador
	WHERE	t1.ClaUbicacion = 54
	AND		t1.ClaMaquilador = 1

	-------------------------------------------------
	-- Sumatoria Cantidad
	SELECT	ClaArticulo, CantidadMovimiento = SUM(CantidadMovimiento)
	INTO	#MovimientosMaquilador2 
	FROM	#MovimientosMaquilador
	GROUP BY ClaArticulo

	-- Diferencias Maquilador (Existencias vs Movimientos)
	SELECT	a.ClaArticulo, a.NomArticulo, a.Cantidad, b.CantidadMovimiento,Diferencia = a.Cantidad - b.CantidadMovimiento
	FROM	#Existencias a 
	LEFT JOIN #MovimientosMaquilador2 b 
	ON	a.ClaArticulo = b.ClaArticulo

	------------------------------------------
	-- Universo
	INSERT INTO #MovMaquilador
	SELECT	IdRegistroMovMaquilador
			, IdMovimientoPlanta
			, CantidadMovimiento
			, KilosMovimiento
			, ClaArticulo = CASE WHEN TipoMovimiento = 1 THEN 294834 ELSE 564515 END 
			, FechaMovimiento
			, HoraMovimiento
			, IdBoleta
			, Placa
			, IdRenglon
			, NomTipoMov
			, Ajuste = CONVERT(VARCHAR(10),idFolioAjuste) + ' - ' + ISNULL(MotivoAjuste,'')
	FROM	#MovimientosMaquilador 
	WHERE	ClaArticulo in (294834) 
	ORDER BY IdRegistroMovMaquilador ASC

	SELECT	  Id = MIN(Id)  
			, IdMovimientoPlanta
			, ClaArticulo
	INTO	#MovMaquilador2	-- agrupado
	FROM	#MovMaquilador
	GROUP BY IdMovimientoPlanta
			, ClaArticulo

	----------------------
	--Movimientos Inventario

	DECLARE	  @nId				INT
			, @nClaveMovimiento	INT
			, @nClaArticulo		INT

	SELECT	@nId	= MIN(Id)
	FROM	#MovMaquilador2
	
	WHILE @nId IS NOT NULL
	BEGIN
		SELECT	  @nClaveMovimiento	= NULL
				, @nClaArticulo		= NULL

		SELECT	  @nClaveMovimiento	= IdMovimientoPlanta
				, @nClaArticulo		= ClaArticulo
		FROM	#MovMaquilador2
		WHERE	Id = @nId


		INSERT INTO #Inventario
		EXEC OPESch.OPE_CU400_Pag3_Grid_GridMovimientos_SelHv
			@pnVersion				= 1
			,@pnClaUbicacion		= 54
			,@pnClaTipoInventario	= 1
			,@pnClaArticulo			= @nClaArticulo
			,@ptFechaInicial		= '2023-02-13 00:00:00'
			,@ptFechaFinal			= '2023-02-13 00:00:00'
			,@pnClaAlmacen			= NULL
			,@pnClaSubAlmacen		= NULL
			,@pnClaSubSubAlmacen	= NULL
			,@pnClaSeccion			= NULL
			,@pnClaTipoReferencia1	= 3
			,@psValorReferencia1	= ''
			,@pnClaTipoReferencia2	= 4
			,@psValorReferencia2	= ''
			,@pnClaTipoReferencia3	= NULL
			,@psValorReferencia3	= ''
			,@pnClaTMA				= NULL
			,@psIdioma				= 'Spanish'
			,@pnReferenciaCompras	= NULL
			,@pnClaveMovimiento2	= @nClaveMovimiento
			,@pnUsuario				= NULL

		SELECT	@nId	= MIN(Id)
		FROM	#MovMaquilador2
		WHERE	Id > @nId
	END

	-------------------------------------------------------
	-- Resultado
	SELECT	  [Movimiento Maquilador] = a.IdRegistroMovMaquilador
			, [Renglon]				= a.IdRenglon
			, [Fecha Maquilador]	= a.Fecha
			, [Hora Maquilador]		= a.Hora
			, [Boleta]				= a.Boleta
			, [Placa]				= a.Placa
			, [Movimiento Inventario] = a.IdMovimientoPlanta
			, [Mov. Maquilador]		=  a.NomTipoMov
			, [Fecha Inventario]	= b.FechaHoraMovimiento
			, [Hora Inventario]		= b.HoraMovimiento 
			, [Clave]				= b.ClaveArticulo
			, [Cantidad Maquilador]	= a.CantidadMovimiento
			, [Kilos Maquilador]	= a.KilosMovimiento
			, [Cantidad Inventario]	= b.Cantidad
			, [Kilos Inventario]	= b.KilosTeoricos
			, Diferencia			= a.CantidadMovimiento + b.Cantidad
			, [TMA]					= b.DescripcionTMA
			, [Almacen]				= b.NomAlmacen
			, [Referencia Compras]	= CASE WHEN ReferenciaCompras IS NULL THEN '' ELSE CONVERT(VARCHAR(20),ReferenciaCompras) END
			, [PC Modificó]			= b.PCModifico
			, [Usuario Modificó]	= b.UsuarioModifico
			, Ajuste
	--		, a.ClaArticulo , b.ExistenciaCantidad	, b.ExistenciaKilos
	FROM	#MovMaquilador a
	LEFT JOIN #Inventario b
	ON		a.IdMovimientoPlanta = b.ClaMovimiento
	AND		a.IdRenglon = b.IdRenglon
	WHERE	a.ClaArticulo IS NOT NULL

	--------