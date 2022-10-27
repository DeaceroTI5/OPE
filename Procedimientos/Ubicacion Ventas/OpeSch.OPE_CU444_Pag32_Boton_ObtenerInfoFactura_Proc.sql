---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--sp_helptext 'OPESch.OPE_CU444_Pag32_Boton_ObtenerInfoFactura_Proc'
--sp_helptext 'OpeSch.OpeConexionRemotaFn'

--*----
--*Objeto:                          OPESch.OPE_CU444_Pag32_Boton_ObtenerInfoFactura_Proc 
--*Autor:                           Sergio Rico - 
--*Modificado por:					Joel Coronadodcsd
--*Fecha:                           2015
 
CREATE PROCEDURE OpeSch.OPE_CU444_Pag32_Boton_ObtenerInfoFactura_Proc
--DECLARE 
	@pnClaUbicacion INT,
	@psIdFacturaAlfanumerico VARCHAR(25),
	@pnIdFactura INT = NULL OUTPUT 
AS
BEGIN

--SELECT @pnClaUbicacion=153,@psIdFacturaAlfanumerico='34235',@pnIdFactura=NULL
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
		-- Ubicacion de Ventas
		DECLARE @nClaUbicacionVentas INT
	
		SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
		FROM	OpeSch.OpeTiCatUbicacionVw 
		WHERE	ClaUbicacion		= @pnClaUbicacion
		

		--* Declaracion de variables locales 
		DECLARE @sConexionRemota		VARCHAR(1000),
				@pnClaSistema			INT,
				@psNombreClave			VARCHAR(50),
				@psObjetoRemoto			VARCHAR(50)
	 
		--SET @pnClaUbicacion = 5
		SET @pnClaSistema = 199
		SET @psNombreClave = 'VTA3'
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
			
			INSERT INTO #tmpFacturaConvertida				
			EXEC @sConexionRemota 
			@fac_str=@psIdFacturaAlfanumerico ,  
			@cla_factura=NULL ,   
			@retornar = 1,  
			@formato_nuevo = 0,  
			@str_to_cla = 1  
	 
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
		DECLARE	@nKilosSurtidos         NUMERIC 
		DECLARE	@sIdFacturaAlfanumerico VARCHAR(15) 
		DECLARE @sExec NVARCHAR(MAX)	
		DECLARE @nClaSistema INT
		DECLARE @sNombreClave VARCHAR(50)
			
		SET @nClaSistema = 199
		SET @sNombreClave = 'VTA3'
		SET @psObjetoRemoto = 'VtaCTraFacturaVw'
		SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
		
		--CREAMOS TABLA DONDE ALMACENAREMOS INFORMACION DE TABLA REMOTA
		CREATE TABLE #tmpcTraFactura(
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
		KilosSurtidos INT,
		IdFacturaAlfanumerico VARCHAR(20),
		IdFactura INT)
		
		--CREAMOS CONSULTA	
		SET @sExec = 'INSERT INTO #tmpcTraFactura SELECT ClaUbicacion,IdViaje,IdFabricacion,ClaCliente,ClaConsignado,ClaCiudad,ClaOrganizacion,ClaTransportista,TipoFlete,ClaMoneda,FechaFactura,KilosSurtidos,IdFacturaAlfanumerico,IdFactura
						FROM ' + @sConexionRemota + ' A WITH(NOLOCK) WHERE IdFactura = ' + convert(varchar, @nIdFactura)
	
		SELECT @sExec 
	
		EXEC SP_EXECUTESQL @sEXEC
 
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
		--SELECT * FROM VTA3_6OFGRALES_LNKSVR.VENTAS.dbo.VtaCTraFacturaVw WHERE ClaUbicacion = 153
		FROM #tmpcTraFactura
		WHERE IdFactura = @nIdFactura
		
		drop table #tmpcTraFactura
 
		-- Insertar encabezado de factura en ventas local (trabajo)
		IF (@sIdFacturaAlfanumerico IS NOT NULL)
		BEGIN
		
			EXEC Ventas.VtaSch.VtaCTraFacturaIUSrv
				1, --Version
				@nIdFactura, 
				@nClaUbicacionVentas, --@nClaUbicacion, 
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
				NumRenglon      INT NOT NULL,
				IdFabricacion   INT NULL,
				NumRenglonFab   INT NULL,
				ClaArticulo     INT NULL,
				CantidadSurtida NUMERIC (22,4) NULL,
				KilosSurtidos   NUMERIC (22,4) NULL
				)
		 
			SET @nClaSistema = 199
			SET @sNombreClave = 'VTA3'
			SET @psObjetoRemoto = 'VtaCTraFacturaDetVw'
			SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
			
			--CREAMOS CONSULTA	
			SET @sExec = 'SELECT NumRenglon,NumRenglonFab,ClaArticulo,CantidadSurtida,KilosSurtidos
							FROM ' + @sConexionRemota + ' A WITH(NOLOCK) WHERE IdFactura = ' + CONVERT(varchar, @nIdFactura)	+ ' AND NumRenglonFab <> 0'			
			SELECT @sExec ='INSERT INTO #tmpVtaCTraFacturaDet (
					NumRenglon,
					NumRenglonFab,
					ClaArticulo,
					CantidadSurtida,
					KilosSurtidos
			)' + @sExec
			EXEC SP_EXECUTESQL  @sExec
		 
			-- Insertar cada detalle de la factura
			DECLARE @minNumRenglon INT
			DECLARE @nNumRenglonFab   INT
			DECLARE @nClaArticulo     INT
			DECLARE @nCantidadSurtida NUMERIC
		 
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
	SELECT @pnIdFactura
	SET NOCOUNT OFF
 
END