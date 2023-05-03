USE Operacion
GO
-- EXEC SP_HELPTEXT 'OPESch.OPE_CU441_Pag2_Boton_ObtenerInfoFactura_Proc'
/*
BEGIN TRAN
	declare @p3 int
	set @p3=null
	exec OPESch.OPE_CU441_Pag2_Boton_ObtenerInfoFactura_Proc @pnClaUbicacion=267,@psIdFacturaAlfanumerico='RN1',@pnIdFactura=@p3 output, @pnDebug= 0
	select @p3
ROLLBACK TRAN
*/
GO
ALTER PROCEDURE OPESch.OPE_CU441_Pag2_Boton_ObtenerInfoFactura_Proc
@pnClaUbicacion INT,
@psIdFacturaAlfanumerico VARCHAR(25),
@pnIdFactura INT = NULL OUTPUT,
@pnDebug TINYINT = 0
AS
BEGIN
SET NOCOUNT ON
 
	IF NOT EXISTS (
					SELECT 1
					FROM OpeSch.OpeVtaCTraFacturaVw VtaFactura WITH(NOLOCK)
					WHERE (VtaFactura.IdFactura = 
							(CASE	WHEN  ISNUMERIC(SUBSTRING(@psIdFacturaAlfanumerico,1,1)) = 1 
									THEN  CAST(@psIdFacturaAlfanumerico AS INT) 
									ELSE VtaFactura.IdFactura 
							END)
							AND
							VtaFactura.IdFacturaAlfanumerico = 
							(CASE	WHEN  ISNUMERIC(SUBSTRING(@psIdFacturaAlfanumerico,1,1)) = 0 
									THEN  CAST(@psIdFacturaAlfanumerico AS VARCHAR(30)) 
									ELSE VtaFactura.IdFacturaAlfanumerico 
							END)
														  )
	)
	BEGIN
		
		--* Declaracion de variables locales 
		DECLARE @sConexionRemota		VARCHAR(1000),
				@pnClaSistema			INT,
				@psNombreClave			VARCHAR(50),
				@psObjetoRemoto			VARCHAR(50)
	 
		 
		SET @pnClaSistema = 1990
		SET @psNombreClave = 'VTA5'
		SET @psObjetoRemoto = 'VtaConvierteNumFacturaSrv'
	 
		--* Obtener conexion remota de InvIntInsertaMovEncSrv para ejecucion 
		SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
					
		-- Si la factura es en formato alfanumerico, convertirla a numerica
		DECLARE @nIdFactura INT
	 
		IF(ISNUMERIC(SUBSTRING(@psIdFacturaAlfanumerico,1,1)) = 0)
		BEGIN
			CREATE TABLE #tmpFacturaConvertida (
				FacturaConvertida INT
		)
			
			--INSERT INTO #tmpFacturaConvertida				
			--EXEC @sConexionRemota 
			--@fac_str=@psIdFacturaAlfanumerico ,  
			--@cla_factura=NULL ,   
			--@retornar = 1,  
			--@formato_nuevo = 0,  
			--@str_to_cla = 1  
			
			IF @pnDebug = 1 
				SELECT @sConexionRemota AS '@sConexionRemota 1'
			
			INSERT INTO #tmpFacturaConvertida				
			EXEC @sConexionRemota 
			@psIdFacturaAlfanumerico ,  
			0,   
			1,  
			0,  
			1  
	 
			SELECT @nIdFactura = FacturaConvertida FROM #tmpFacturaConvertida
	 
			DROP TABLE #tmpFacturaConvertida
		END
		ELSE
		BEGIN
			 SET @nIdFactura = CAST(@psIdFacturaAlfanumerico AS INT)
		END
	 
	 
		-- Consultar encabezado de factura en Oficinas Generales
		DECLARE	@nClaUbicacion          INT 
		DECLARE	@nIdViaje               INT 
		DECLARE	@nIdFabricacion         INT 
		DECLARE	@nClaCliente            INT 
		DECLARE	@nClaConsignado         INT 
		DECLARE	@nClaCiudad             INT 
		DECLARE	@nClaOrganizacion       INT 
		DECLARE	@nClaTransportista      INT 
		DECLARE	@nTipoFlete             INT 
		DECLARE	@nClaMoneda             INT 
		DECLARE	@dFechaFactura          DATETIME
		DECLARE	@nKilosSurtidos         NUMERIC(22, 4)
		DECLARE	@sIdFacturaAlfanumerico VARCHAR(15) 
		DECLARE @sExec NVARCHAR(MAX)	
		DECLARE @nClaSistema INT
		DECLARE @sNombreClave VARCHAR(50)
			
			
		
		SET @pnClaSistema = 1990
		SET @psNombreClave = 'VTA5'	
		SET @psObjetoRemoto = 'VtaObtieneFacturaEncOpeSrv'
		SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
		
		--CREAMOS TABLA DONDE ALMACENAREMOS INFORMACION DE TABLA REMOTA
		CREATE TABLE #tmpcTraFactura(
		IdFactura INT,
		ClaUbicacion INT,
		IdViaje INT,
		IdFabricacion INT,
		ClaCliente INT,
		ClaConsignado INT,
		ClaCiudad INT,
		ClaOrganizacion INT,
		ClaTransportista INT,
		TipoFlete INT,
		ClaMoneda INT,
		FechaFactura DATETIME,
		KilosSurtidos NUMERIC(22, 4),
		IdFacturaAlfanumerico VARCHAR(20),
		)
		
		--CREAMOS CONSULTA	
		/*
		SET @sExec = 'INSERT INTO #tmpcTraFactura SELECT IdFactura,ClaUbicacionNet,IdViaje,IdFabricacion,ClaCliente,ClaConsignado,ClaCiudad,ClaOrganizacion,ClaTransportista,TipoFlete,ClaMoneda,FechaFactura,KilosSurtidos,IdFacturaAlfanumerico
						FROM ' + @sConexionRemota + ' A WITH(NOLOCK) WHERE IdFactura = ' + convert(varchar, @nIdFactura)
	
		EXEC SP_EXECUTESQL
		SET @pnClaSistema = 1990
		SET @psNombreClave = 'VTA5'
		*/
		
		--- Se llena por medio de los servicios de DEAOFINET05.ventas.VtaSch.VtaObtieneFacturaEncOpeSrv
		
			IF @pnDebug = 1 
				SELECT @sConexionRemota AS '@sConexionRemota 2'

			INSERT INTO #tmpcTraFactura			
			EXEC @sConexionRemota 
			@nIdFactura, 
			null
				
		
		--ASIGNAMOS INFORMACION
		SELECT
			@nClaUbicacion = ClaUbicacion,
			@nIdViaje = IdViaje,
			@nIdFabricacion = IdFabricacion,
			@nClaCliente = ClaCliente,
			@nClaConsignado = ClaConsignado,
			@nClaCiudad = ClaCiudad,
			@nClaOrganizacion = ClaOrganizacion,
			@nClaTransportista = ClaTransportista,
			@nTipoFlete = TipoFlete,
			@nClaMoneda = ClaMoneda,
			@dFechaFactura = FechaFactura,
			@nKilosSurtidos = KilosSurtidos,
			@sIdFacturaAlfanumerico = IdFacturaAlfanumerico
		--FROM VTA3_6OFGRALES_LNKSVR.VENTAS.dbo.VtaCTraFacturaVw 
		FROM #tmpcTraFactura
		WHERE IdFactura = @nIdFactura
		
		drop table #tmpcTraFactura

		IF @pnDebug = 1 
			SELECT @sIdFacturaAlfanumerico AS '@sIdFacturaAlfanumerico'
 
		-- Insertar encabezado de factura en ventas local (trabajo)
		IF (@sIdFacturaAlfanumerico IS NOT NULL)
		BEGIN
		
			EXEC Ventas.VtaSch.VtaCTraFacturaIUSrv
				1, --Version
				@nIdFactura, 
				@nClaUbicacion, 
				@nIdViaje, 
				@nIdFabricacion, 
				@nClaCliente, 
				@nClaConsignado, 
				@nClaCiudad, 
				@nClaOrganizacion, 
				@nClaTransportista, 
				@nTipoFlete, 
				@nClaMoneda, 
				@dFechaFactura, 
				@nKilosSurtidos, 
				@sIdFacturaAlfanumerico
		 
			-- Consultar detalles de factura en Oficinas Generales
			CREATE TABLE #tmpVtaCTraFacturaDet
				(
				IdFactura		INT NULL,
				NumRenglon      INT NOT NULL,
				IdFabricacion   INT NULL,
				NumRenglonFab   INT NULL,
				ClaArticulo     INT NULL,
				CantidadSurtida NUMERIC (22,4) NULL,
				KilosSurtidos   NUMERIC (22,4) NULL
				)
		 
			SET @nClaSistema = 1990
			SET @sNombreClave = 'VTA5'
			SET @psObjetoRemoto = 'VtaObtieneFacturaDetOpeSrv'
			SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
			
			--CREAMOS CONSULTA	
			/*
			SET @sExec = 'SELECT IdFactura, NumRenglon,NumRenglonFab,ClaArticulo,CantidadSurtida,KilosSurtidos
							FROM ' + @sConexionRemota + ' A WITH(NOLOCK) WHERE IdFactura = ' + CONVERT(varchar, @nIdFactura)	+ ' AND NumRenglonFab <> 0'			
			SELECT @sExec ='INSERT INTO #tmpVtaCTraFacturaDet (
					NumRenglon,
					NumRenglonFab,
					ClaArticulo,
					CantidadSurtida,
					KilosSurtidos
			)' + @sExec
			EXEC SP_EXECUTESQL  @sExec*/
			
			
		--- Se llena por medio de los servicios de  DEAOFINET05.ventas.VtaSch.VtaObtieneFacturaDetOpeSrv 
		
			IF @pnDebug = 1 
				SELECT @sConexionRemota AS '@sConexionRemota 3'

			INSERT INTO #tmpVtaCTraFacturaDet		
			EXEC	@sConexionRemota 
					@nIdFactura, 
					null
			
					
		 
			-- Insertar cada detalle de la factura
			DECLARE @minNumRenglon INT
			DECLARE @nNumRenglonFab   INT
			DECLARE @nClaArticulo     INT
			DECLARE @nCantidadSurtida NUMERIC(22, 4)
		 
			SELECT @minNumRenglon = MIN(NumRenglon)
			FROM #tmpVtaCTraFacturaDet
		 
			WHILE @minNumRenglon IS NOT NULL
			BEGIN
		 
				SELECT 
					@nNumRenglonFab = NumRenglonFab,
					@nClaArticulo = ClaArticulo,
					@nCantidadSurtida = CantidadSurtida,
					@nKilosSurtidos = KilosSurtidos
				FROM #tmpVtaCTraFacturaDet
				WHERE NumRenglonFab = @minNumRenglon
		 
		 
				-- Insertar encabezado de factura en ventas local (trabajo)
				EXEC Ventas.VtaSch.VtaCTraFacturaDetIUSrv
					1, --Version
					@nIdFactura, 
					@minNumRenglon, 
					@nIdFabricacion, 
					@nNumRenglonFab, 
					@nClaArticulo, 
					@nCantidadSurtida, 
					@nKilosSurtidos
		 
				SELECT @minNumRenglon = MIN(NumRenglon)
				FROM #tmpVtaCTraFacturaDet
				WHERE NumRenglon > @minNumRenglon
				
			END
		 
		 
			DROP TABLE #tmpVtaCTraFacturaDet
	END 
 
	END
 
	SELECT @pnIdFactura = @nIdFactura
	SELECT 1
	SET NOCOUNT OFF
 
END