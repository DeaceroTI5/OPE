ALTER PROC OpeSch.OPE_CU71_Pag4_ImprimirSrvBack_Proc_Hv
	  @pnClaUbicacion	INT
	, @pnIdOrderRemp	INT
	, @pnDebug			TINYINT = 0
AS
BEGIN		
SET NOCOUNT ON
	-- EXEC OpeSch.OPE_CU71_Pag4_ImprimirSrvBack_Proc_Hv 267, 1, 0

	DECLARE
		@nIdViaje			  INT,
	    @nIdBoleta			  INT, 
	    @sPlaca				  VARCHAR(12), 
	    @nIdTabular			  INT, 
	    @nIdTipoConcepto	  INT, 
	    @nClaCliente		  INT, 
		@nIdFabricacion		  INT, 
		@nIdFabricacionDet    INT, 
		@nPorcReal			  NUMERIC(22,4), 
		@nPorcCub			  NUMERIC(22,4), 
		@sMontacarguista	  VARCHAR(250),
		@EmbReal			  NUMERIC(22,2),
		@Embcub				  NUMERIC(22,2),
		@CapCub				  NUMERIC(22,2),
		@CapReal			  NUMERIC(22,2), 
		@nNumVersion		  INT, 
		@nIdFactura			  INT,
		@nIdMovEntsal		  INT, 
		@nEsEntrada			  INT,
		@nClaTipoPesajeSalida INT, 
		@nNoCopias			  INT, 
		@nEsExportarPDF       INT,   
		@nEmpresaStayTuff     INT,
		@nEsStayTuff		  INT, 
		@psIdioma		      VARCHAR(10),
		@pnIdRegistro         INT,
		@CountWh              INT,
		@Formato              INT,
		@pnIdPlanCargaFact	  INT,
		@pnIdPlanCarga        INT,
		@pnIdboleta			  INT,
		@pnEsFacturacion      INT,
		@pnClaMotivoEntrada	  INT,
		@cert				   INT, 
		@psClaIdioma		   VARCHAR(5), 
		@nConfigTipoImpGral    INT,
		@nConfigTipoImpToron   INT,
		@nConfigTipoImpEstrobo INT,
		@nConfigTipoImpHouston INT,
		@sFamTipoImpGral	   VARCHAR(500),
		@sFamTipoImpToron	   VARCHAR(500),
		@sFamTipoImpEstrobo    VARCHAR(500),
		@sFamTipoImpHouston    VARCHAR(500),
	    @sUnidadEsp			   VARCHAR(100),
		@sUnidadIng			   VARCHAR(100),
		@pnEsVistaPrevia	   INT	   
		
	CREATE TABLE #reportes (
		orden			    INT IDENTITY(1,1),
		ClaFormatoImpresion	INT,
		NombreReporte		VARCHAR(500),
		pnClaUbicacion		INT,
		ClaUbicacion		INT NULL,
		IdViaje				INT NULL,
		pnIdViaje			INT NULL,
		pnNumVersion		INT NULL,
		NumVersion			INT NULL,
		IdPlanCarga			INT NULL,
		IdBoleta			INT NULL,
		IdTipoConcepto		INT NULL,
		IdTabular			INT NULL,
		IdMovEntSal			INT,
		IdFactura			INT NULL,
		IdOrdenEnvioCU66P1	INT NULL,
		PorcReal			NUMERIC(19,2) NULL,
		PorcCub				NUMERIC(19,2) NULL,
		Montacarguista		VARCHAR(500),
		ClaCliente			INT NULL, 
		NombreCliente		VARCHAR (250) NULL, 
		Ciudad				VARCHAR (250) NULL, 
		IdCertificado		INT NULL, 
		KgsTotal			NUMERIC (28, 3) NULL, 
		NumeroFactura		VARCHAR (250) NULL, 
		NomArticulo			VARCHAR (500) NULL, 
		NombreUbicacion		VARCHAR (50) NULL, 
		Nota				VARCHAR (500) NULL, 
		Direccion			VARCHAR (500) NULL, 
		ClaTipoImpresion	INT NULL, 
		IdFabricacion		INT NULL, 
		NomUnidad			VARCHAR (100) NULL,
		psClaIdioma			VARCHAR (5) NULL,
		ClavesRollo			VARCHAR(8000) NULL,
		NomIsoIdioma		VARCHAR(3) NULL,
		ClaPais				INT NULL,
		cultureName		    VARCHAR (5) NULL,
		ClaIdioma			VARCHAR (5) NULL,
		EsVistaPrevia		INT NULL,
		IdOpm				INT  NULL,
		Cantidad			NUMERIC (28, 3) NULL,
		Factura				VARCHAR (250) NULL  ,  
		Diametro			VARCHAR(250)NULL,
		Longitud			VARCHAR(250)NULL,
		Especificacion		VARCHAR(250)NULL,
		Tipo				VARCHAR(250)NULL,
		ClaFactura			INT,
		RemisionSN			INT,
		EnPlanta			INT,
		CopiaTranspSN		INT,
		ClaViaje			INT,
		ClaFabricacion		INT,
		EsStayTuff			INT,
		Idioma				VARCHAR(2),
		EsExportarPDF		INT,
		EsLandscape			INT,
		Grado				VARCHAR(250),
		Construccion		VARCHAR(250),
		Lubrication			VARCHAR(250),
		CoreType			VARCHAR(250),
		Torcido				VARCHAR(250),
		Acabado				VARCHAR(250),
		TipoConstruccion	VARCHAR(250),
		Firma				VARBINARY(MAX),
		NombreUsuario		VARCHAR(250),
		Puesto				VARCHAR(250),
		LongitudTotal		VARCHAR(250),
		psIdioma			VARCHAR(10),
		ClaUbicacionOrigen	INT,
		ClaArticulo			INT,
		Observaciones		VARCHAR(1000),
		Colada				INT,
		DiamMM				INT,
		IdCertificadoR		INT,
		ClaIdiomaR			INT
	) 
                   
	--Certificados          
	CREATE TABLE #certenc(
		ClaUbicacion		INT, 
		IdCertificado		INT, 
		IdFactura			INT,
		ClaTipoCertificado	INT, 
		psClaIdioma			VARCHAR (5)
	)
		    
	CREATE TABLE #certdet (
		ClaCliente			INT NULL, 
		NombreCliente		VARCHAR (250) NULL, 
		NombreCiudad		VARCHAR (250) NULL, 
		FechaActual			DATETIME NULL, 
		ClaArticulo			INT NULL, 
		IdCertificado		INT NULL, 
		KgsTotal			NUMERIC (28, 3) NULL, 
		IdViaje				INT NULL, 
		IdPlanCarga			INT NULL, 
		NumeroFactura		VARCHAR (250) NULL, 
		NomArticulo			VARCHAR (500) NULL, 
		NombreUbicacion		VARCHAR (50) NULL, 
		Notas				VARCHAR (500) NULL, 
		Direccion			VARCHAR (500) NULL, 
		ClaTipoImpresion	INT NULL, 
		IdFabricacion		INT NULL, 
		IdOpm				INT NULL, 
		NomUnidad			VARCHAR (100) NULL,
		IdFactura			INT
	)

	--Facturas
	CREATE TABLE #tmpFabricacionFactura (
		Indice				INT IDENTITY(1,1), 
		ClaFormatoImpresion	INT, 
		IdFabricacion		INT, 
		EsNacional			BIT,
		NoCopias			INT,
		idFactura			INT
	)

	--Certificados alambron.	
	CREATE TABLE #tmpParametrosReporte (
		NumVersion			INT,
		ClaUbicacion		INT,
		ClaCliente			INT,
		Diametro			INT,
		NombreCliente		VARCHAR(100),
		IdCertificado		INT,
		NomUnidad			VARCHAR(100),
		Observaciones		VARCHAR(1),
		cultureName			VARCHAR(50),
		ClaIdioma			VARCHAR(50),
		Colada				INT,
		DiamMM				INT,
		IdFactura			INT
	)

	DECLARE @tClientes TABLE (
		ClaCliente INT,
		ClaEmpresa INT
	)

	CREATE TABLE #tmpMovEntSalISB (
		IdMovEntSal		INT,
		IdFabricacion	INT,
		IdViaje			INT
	)

	CREATE TABLE #tmpCfgMotivoFormatoImp (
		Indice				INT IDENTITY(1,1),
		ClaMotivoEntrada	INT, 
		ClaFormatoImpresion INT, 
		NomFormatoImpresion VARCHAR(50),
		NoCopias			INT
	)

	SELECT @nEsExportarPDF = 1 , @pnEsFacturacion = 1, @pnEsVistaPrevia = 0


	IF(@pnClaUbicacion NOT IN (65, 267))
	BEGIN
		SET @psIdioma = 'Spanish'
	END
	ELSE
	BEGIN
		SET @psIdioma = 'English'
	END

	---- Obtengo las facturas por digitalizar y los formatos 
	SELECT t1.IdFactura,
		   t1.Formato,
		   T1.Viaje
	INTO #TempReimpresionDigital  
	FROM OpeSch.OpeBitReimpresionDigital t1
	WHERE t1.IdRegitro = @pnIdOrderRemp

	IF @pnDebug >= 1
		SELECT '' AS '#TempReimpresionDigital', * FROM #TempReimpresionDigital

	SELECT @CountWh = COUNT(*) FROM #TempReimpresionDigital

	--IF @pnDebug = 1
	--	SELECT @CountWh AS '@CountWh' 


	-- Recorro las facturas por digitalizar
	WHILE @CountWh > 0
	BEGIN
		DELETE FROM #certenc
		DELETE FROM #certdet

		SELECT top 1 @nIdFactura = t1.IdFactura
			  ,@Formato = T1.Formato,
			   @pnIdPlanCargaFact = t2.IdPlanCarga,
			   @pnIdboleta = viaje.IdBoleta,
			   @nIdViaje = t1.Viaje 
		FROM #TempReimpresionDigital T1
		INNER JOIN OpeSch.OpeTraViaje viaje
				ON	viaje.ClaUbicacion = @pnClaUbicacion
				AND viaje.IdViaje = T1.Viaje
		INNER JOIN OpeSch.OpeTraPlanCarga t2 
				ON t2.IdBoleta = viaje.IdBoleta

		SET @nEsStayTuff = 0 --Por default la dejamos en cero

		SELECT @nEmpresaStayTuff = ISNULL(nValor1, -1)
		FROM  OpeSch.TiCatConfiguracionVw
		WHERE ClaSistema = 127
		AND ClaUbicacion = @pnClaUbicacion
		AND ClaConfiguracion = 45	


		IF EXISTS(SELECT 1 
				   FROM OPESch.TiCatConfiguracionVw WITH(NOLOCK)
				   WHERE ClaUbicacion = @pnClaUbicacion AND 
				   ClaSistema = 127 AND 
				   ClaConfiguracion = 1271066) AND
				   (SELECT BajaLogica 
					FROM OPESch.TiCatConfiguracionVw WITH(NOLOCK)
					WHERE ClaUbicacion = @pnClaUbicacion AND 
						  ClaSistema = 127 AND 
						  ClaConfiguracion = 1271066) = 0	
		BEGIN
				SET @nEsExportarPDF = 1
		END

		--IF  isnull(@pnEsFacturacion,0) = 3 goto Certificados
		
		IF EXISTS(SELECT 1 
				  FROM OpeSch.OpeTraBoleta WITH(NOLOCK) 
				  WHERE ClaUbicacion = @pnClaUbicacion AND 
				  IdBoleta = @pnIdboleta) 
		BEGIN 
				SET @nEsEntrada = 1 
			END 
		ELSE 
		BEGIN 
			SET @nEsEntrada = 0 
		END 

		SELECT	@nClaTipoPesajeSalida = ClaTipoPesajeSalida 
		FROM	OpeSch.OpeTraBoletaHis WITH(NOLOCK) 
		WHERE	IdBoleta = @pnIdBoleta 
		AND		ClaUbicacion = @pnClaUbicacion	
	
		--Si viene de Plan de Carga, trae la boleta y el motivo entrada no, obtener valor
		SELECT	@pnClaMotivoEntrada = ClaMotivoEntrada 
		FROM	OPESch.OPETraBoletaHis WITH(NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion 
		AND		IdBoleta = @pnIdBoleta
  

		IF(@pnClaMotivoEntrada IN (1,3))
		BEGIN
			IF(ISNULL(@pnIdPlanCargaFact, -1) < 1)
			BEGIN
				SELECT @pnIdPlanCargaFact = IdPlanCarga
				FROM OpeSch.OpeTraPlanCarga WITH(NOLOCK)
				WHERE ClaUbicacion =  @pnClaUbicacion AND
					IdBoleta = @pnIdBoleta
			END

			--IF Motivo de entrada es Camion por cargar 
			SELECT @pnIdBoleta = IdBoleta, 
				   @nIdViaje = IdViaje, 
					@nIdTabular = IdNumTabular 
			FROM OPESch.OpeTraViaje WITH(NOLOCK)
			WHERE ClaUbicacion =  @pnClaUbicacion AND
				IdPlanCarga = @pnIdPlanCargaFact

			IF(ISNULL(@nIdViaje, 0) <= 0)
			BEGIN
				SELECT @nIdViaje = IdViaje, @nIdTabular = IdNumTabular 
				FROM OPESch.OpeTraViaje WITH(NOLOCK)
				WHERE ClaUbicacion =  @pnClaUbicacion AND
					IdBoleta = @pnIdBoleta
			END

			SELECT @nClaTipoPesajeSalida = ClaTipoPesajeSalida 
			FROM OpeSch.OpeTraBoletaHis WITH(NOLOCK) 
			WHERE IdBoleta = @pnIdBoleta AND 
				ClaUbicacion = @pnClaUbicacion

			--Si viene de Plan de Carga, trae la boleta y el motivo entrada no, obtener valor
			SELECT @pnClaMotivoEntrada = ClaMotivoEntrada 
			FROM OpeSch.OpeTraBoleta WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacion AND 
				IdBoleta = @pnIdBoleta           

			IF(@pnClaMotivoEntrada = 3) --Entrada por Traspaso
			BEGIN
				SELECT @nIdViaje = IdViajeOrigen
				FROM OpeSch.OpeTraRecepTraspaso WITH(NOLOCK) 
				WHERE ClaUbicacion = @pnClaUbicacion AND 
					IdBoleta = @pnIdBoleta 
			END
	                          
			IF EXISTS(SELECT 1 
					FROM OpeSch.OpeTraBoleta WITH(NOLOCK) 
					WHERE ClaUbicacion = @pnClaUbicacion AND 
							IdBoleta = @pnIdboleta) 
			BEGIN 
				SET @nEsEntrada = 1 
			END 
			ELSE 
			BEGIN 
				SET @nEsEntrada = 0 
			END        

			SELECT TOP 1 @nIdMovEntSal = IdMovEntSal
				--@nIdFactura = IdFactura 
			FROM OpeSch.OpeTraMovEntSal WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacion AND 
				Idboleta = @pnIdBoleta 
				AND IdViaje = @nIdViaje 
			ORDER BY  1 DESC
	                    
			INSERT INTO #tmpMovEntSalISB(IdMovEntSal, IdFabricacion, IdViaje)
			SELECT IdMovEntSal, IdFabricacion, IdViaje
			FROM OpeSch.OpeTraMovEntSal WITH(NOLOCK)
			WHERE ClaUbicacion = @pnClaUbicacion AND 
				Idboleta = @pnIdBoleta 
				AND IdViaje = @nIdViaje 
	                    
			SET @nIdTipoConcepto = 0 --Así se manea actualmente en PLO
			SET @nNumVersion = 1
			--SET @nIdFactura = NULL
		
		END

		IF(@pnEsFacturacion = 1)
		BEGIN

			INSERT INTO #tmpCfgMotivoFormatoImp
				(ClaMotivoEntrada, ClaFormatoImpresion, NomFormatoImpresion, NoCopias)
			SELECT A.ClaMotivoEntrada, A.ClaFormatoImpresion, B.NomFormatoImpresion, A.NoCopias 
			FROM OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
			LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) ON
				  B.ClaFormatoImpresion = A.ClaFormatoImpresion
			WHERE A.ClaUbicacion = @pnClaUbicacion AND
				  A.ClaMotivoEntrada = @pnClaMotivoEntrada AND
				  A.BajaLogica = 0 AND
				  ISNULL(A.EsRequeridoAlFacturar, 0) = 1 AND
				  A.NoCopias > 0
				  AND NOT EXISTS (
					SELECT 1 FROM #tmpCfgMotivoFormatoImp aa WHERE A.ClaMotivoEntrada = aa.ClaMotivoEntrada AND A.ClaFormatoImpresion = aa.ClaFormatoImpresion
				  )	  
		END
		ELSE 
		IF(@pnEsFacturacion = 3)--solocertificados
		BEGIN
			INSERT INTO #tmpCfgMotivoFormatoImp
				(ClaMotivoEntrada, ClaFormatoImpresion, NomFormatoImpresion, NoCopias)
			SELECT A.ClaMotivoEntrada, A.ClaFormatoImpresion, B.NomFormatoImpresion, A.NoCopias 
			FROM OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
			LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) ON
				  B.ClaFormatoImpresion = A.ClaFormatoImpresion
			WHERE A.ClaUbicacion = @pnClaUbicacion AND
				  A.ClaMotivoEntrada = @pnClaMotivoEntrada AND
				  A.BajaLogica = 0 AND
				  ISNULL(A.EsRequeridoAlFacturar, 0) = 1 AND
				  A.NoCopias > 0 AND
				  A.ClaFormatoImpresion = 27	 
				  AND NOT EXISTS (
					SELECT 1 FROM #tmpCfgMotivoFormatoImp aa WHERE A.ClaMotivoEntrada = aa.ClaMotivoEntrada AND A.ClaFormatoImpresion = aa.ClaFormatoImpresion
				  )				  
		END
		ELSE
		BEGIN
			INSERT INTO #tmpCfgMotivoFormatoImp(ClaMotivoEntrada, ClaFormatoImpresion, NomFormatoImpresion, NoCopias)
			SELECT A.ClaMotivoEntrada, A.ClaFormatoImpresion, B.NomFormatoImpresion, A.NoCopias 
			FROM OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
			LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) ON
				  B.ClaFormatoImpresion = A.ClaFormatoImpresion
			WHERE A.ClaUbicacion = @pnClaUbicacion AND
				  A.ClaMotivoEntrada = @pnClaMotivoEntrada AND
				  A.BajaLogica = 0 AND
				  ISNULL(A.EsImprimirEnEntradas, 0) = (CASE WHEN @nEsEntrada = 1 THEN 1 ELSE ISNULL(A.EsImprimirEnEntradas, 0) END) AND
				  ISNULL(A.EsRequeridoEnSalida, 0) = (CASE WHEN @nEsEntrada = 0 THEN 1 ELSE ISNULL(A.EsRequeridoEnSalida, 0) END) AND
				  A.NoCopias > 0
				  AND NOT EXISTS (
					SELECT 1 FROM #tmpCfgMotivoFormatoImp aa WHERE A.ClaMotivoEntrada = aa.ClaMotivoEntrada AND A.ClaFormatoImpresion = aa.ClaFormatoImpresion
				  )
		END

		IF(@pnEsFacturacion = 0)
		BEGIN
			--Si el tipo de pesaje de salida es Sin movimiento, solo se imprime la boleta,  sin importar el motivo de entrada.
			IF(@nEsEntrada = 0 AND 
				  (@nClaTipoPesajeSalida = 5 OR --SaleSinCarga
					@nClaTipoPesajeSalida = 6)) --SaleTractor
			BEGIN
				  --Boleta no se borra.
				  DELETE FROM #tmpCfgMotivoFormatoImp
				  WHERE ClaFormatoImpresion IN (2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29)
			END
		END

		IF (@Formato = 32)
		BEGIN 
			--IMPRESION 32 Certificado Calidad de Alambrón.
			--Si el formato esta configurado para que se imprima.
			IF EXISTS(SELECT 1
					  FROM #tmpCfgMotivoFormatoImp
					  WHERE ClaFormatoImpresion = 32)
			BEGIN

				INSERT INTO #tmpParametrosReporte
							(NumVersion, ClaUbicacion, ClaCliente, Diametro, NombreCliente,
							IdCertificado, NomUnidad, Observaciones, cultureName, ClaIdioma,
							Colada, DiamMM, IdFactura)
				SELECT NumVersion = 1,
					   ClaUbicacion = A.ClaUbicacion,
					   ClaCliente = 0,
					   Diametro = B.IdDiametroMm,
					   NombreCliente = D.NombreCliente,
						--La colada se va a poner como el identificador para poder guardar el PDF, esto 
						--no afecta la generación del reporte. Anteriormente: IdCertificado = 0
					   IdCertificado = B.IdColada, 
					   NomUnidad = E.NomUnidadRT,
					   Observaciones = '',
					   cultureName = CASE WHEN @psIdioma = 'English' THEN 'En-Us'
										  WHEN @psIdioma = 'Spanish' THEN 'Es-Mx'
									 ELSE 'Es-Mx' END,
						ClaIdioma = CASE WHEN @psIdioma = 'English' THEN 'En-Us'
										 WHEN @psIdioma = 'Spanish' THEN 'Es-Mx'
									ELSE 'Es-Mx' END,
						Colada = B.IdColada,
						DiamMM = CONVERT(DECIMAL(9,2), B.IdDiametroMm)/100,
						ISNULL(G.IdFactura, G.IdEntSal) AS IdFactura
				FROM OpeSch.OpeTraPlanCargaColada A WITH(NOLOCK)
				INNER JOIN OpcSch.OpcTraPruebaRolloMP B WITH(NOLOCK)
						ON B.ClaUbicacion = A.ClaUbicacion
						AND B.IdColada = A.IdColada
						AND B.IdDiametroMm = A.IdDiametroMm
						AND ISNULL(B.Secuencia, -1) = ISNULL(A.Secuencia, -1)
						AND B.BajaLogica = 0
				LEFT JOIN OpeSch.OpeTraFabricacionVw C WITH(NOLOCK)
						ON C.IdFabricacion = A.IdFabricacion
				LEFT JOIN OpeSch.OPEVtaCatClienteVw D WITH(NOLOCK)
						ON D.ClaCliente = C.ClaCliente
				LEFT JOIN OpcSch.OpcCatUnidadRTVw E WITH (NOLOCK) 
						ON E.ClaUnidadRT = B.ClaUnidadRT
				LEFT JOIN OpcSch.OpcPloTraPlanCargaVw F WITH(NOLOCK)
						ON F.ClaUbicacion = A.ClaUbicacion
						AND F.IdPlanCarga = A.IdPlanCarga
				LEFT JOIN OpcSch.OpcTraMovEntSalVw G WITH(NOLOCK)
						ON G.ClaUbicacion = A.ClaUbicacion
						AND G.IdBoleta = F.IdBoleta
						AND G.IdFabricacion = A.IdFabricacion
				WHERE A.ClaUbicacion = @pnClaUbicacion
						AND A.IdPlanCarga = @pnIdPlanCargaFact			
			

				INSERT INTO #reportes
							(ClaFormatoImpresion, NombreReporte, NumVersion, ClaUbicacion, ClaCliente,
							Diametro, NombreCliente, IdCertificado, NomUnidad, Observaciones,
							cultureName, ClaIdioma, Colada, DiamMM, IdFactura, EsExportarPDF)	
				SELECT 32, 'OPE_CU70_Pag1_Rpt_CertAlambron', NumVersion, ClaUbicacion, ClaCliente,
							Diametro, NombreCliente, IdCertificado, NomUnidad, Observaciones,
							cultureName, ClaIdioma, Colada, DiamMM, IdFactura, @nEsExportarPDF
						FROM #tmpParametrosReporte
			END
		END


		IF (@Formato = 27)
		BEGIN
			INSERT INTO #certenc(ClaUbicacion, IdCertificado, IdFactura, ClaTipoCertificado, psClaIdioma)
			SELECT  Certif.ClaUbicacion,
					Certif.IdCertificado,
					Certif.IdFactura,
					Certif.ClaTipoCertificado,
				   CASE WHEN ( @pnClaUbicacion = 65 OR ( @pnClaUbicacion = 20 AND OpeSch.OpeTraFabricacionVw.ClaCliente = 47720 ) ) THEN 'en-Us' ELSE 
							 (  CASE WHEN ciudadpedido.ClaPais = 1 THEN 'es-Mx' ELSE 'en-Us' END) 
				   END
				FROM OpeSch.OpeTraViaje Viaje WITH(NOLOCK)
				INNER JOIN OPMSch.PloTraCertificado Certif WITH ( NOLOCK )
				ON      viaje.IdViaje = Certif.IdViaje
				AND     certif.Claubicacion = Viaje.ClaUbicacion
				INNER JOIN OpeSch.OpeTraFabricacionVw WITH(NOLOCK)
				ON      OpeSch.OpeTraFabricacionVw.IdFabricacion = Certif.IdFabricacion
				INNER JOIN  OpeSch.OpeVtaCatCiudadVw ciudadpedido(nolock)
				ON      ciudadpedido.ClaCiudad = OpeSch.OpeTraFabricacionVw.ClaCiudad
				WHERE   Viaje.ClaUbicacion = @pnClaUbicacion
				AND		Viaje.IdPlanCarga = @pnIdPlanCargaFact
				AND		Certif.IdFactura = IdFactura

			IF @pnDebug > 1
				SELECT @nIdFactura AS '@nIdFactura', '' AS '#certenc', * FROM #certenc ORDER BY IdCertificado ASC

			SELECT	@cert = MIN(IdCertificado) 
			FROM	#certenc
			
			WHILE @cert IS NOT NULL
			BEGIN
				SELECT	@psClaIdioma = psClaIdioma
				FROM	#certenc
				WHERE	idCertificado = @cert
				AND		claUbicacion = @pnClaUbicacion
	     
				SELECT	@sUnidadEsp = NomUnidad
				FROM	OPeSch.opeArtCatUnidadVw UnidEsp (nolock)
				WHERE	ClaTipoInventario = 1
				AND		ClaUnidad = 1
				--Unidad de Libras
				SELECT	@sUnidadIng = NomUnidad
				FROM	OPeSch.opeArtCatUnidadVw UnidEsp (nolock)
				WHERE	ClaTipoInventario = 1
				AND		ClaUnidad = 15 
	     
				INSERT INTO #certdet(ClaCliente, NombreCliente, NombreCiudad, FechaActual, ClaArticulo, IdCertificado, KgsTotal, 
									   IdViaje, IdPlanCarga, NumeroFactura, NomArticulo, NombreUbicacion, Notas, 
									   Direccion, ClaTipoImpresion, IdFabricacion, IdOpm, NomUnidad, IdFactura)
				SELECT ptc.ClaCliente,
				   CASE WHEN @pnEsVistaPrevia = 0 THEN  NombreCliente
						WHEN @pnEsVistaPrevia = 1 THEN  '' END AS NombreCliente,
				   CASE WHEN @pnEsVistaPrevia = 0 THEN(vccvw.NombreCiudad + ' ' + vccvw.NombreEstado) 
						WHEN @pnEsVistaPrevia = 1 THEN '' END AS NombreCiudad,
				   GETDATE() AS FechaActual,
				   ptc.ClaArticulo,
				   IdCertificado,
				   CASE WHEN @pnEsVistaPrevia = 0 THEN 
						CASE WHEN ciudadpedido.ClaPais = 1 THEN 
								KgsTotal
							ELSE
								KgsTotal * 2.2046 -- Convertir a Libras
						END

						WHEN @pnEsVistaPrevia = 1 THEN 0 END AS KgsTotal,
				   IdViaje,
				   IdPlanCarga,
					CASE WHEN @pnEsVistaPrevia = 0 THEN CASE WHEN NumeroFactura IS NOT NULL THEN NumeroFactura ELSE CAST(ISNULL(IdEntSal, '') AS VARCHAR) END
						 WHEN @pnEsVistaPrevia = 1 THEN '' END AS NumeroFactura,
				   (ClaveArticulo + ' - ' + NomArticulo) AS NomArticulo,
				   CASE @psClaIdioma
						WHEN 'es-MX' THEN UPPER(NombreUbicacion)
						ELSE  CASE @pnClaUbicacion
									WHEN 12 THEN 'CELAYA INDUSTRIAL PLANT'
									WHEN 20 THEN 'MORELIA INDUSTRIAL PLANT I '
									WHEN 54 THEN 'LEON INDUSTRIAL PLANT I'
									WHEN 59 THEN 'QUERETARO INDUSTRIAL PLANT I'
									WHEN 61 THEN 'QUERETARO INDUSTRIAL PLANT II'
									WHEN 65 THEN 'HOUSTON INDUSTRIAL PLANT'
									ELSE UPPER(NombreUbicacion)
							  END
				   END AS NombreUbicacion,
				   ISNULL(notas1.Nota, isnull(notas2.Nota, isnull(notas3.Nota, '') ) ) AS Notas,
				   (RTRIM(ISNULL(tcuv.Direccion,'')) + ' ' + 
				  RTRIM(ISNULL(tcuv.Colonia,'')) + ' ' + 
	
			   CASE @psClaIdioma WHEN 'es-MX' THEN 'CP. ' ELSE 'ZP. ' END + RTRIM(ISNULL(CodigoPostal,'')) + ', ' + 
				   RTRIM(Poblacion) + ' ' +
				   CASE @psClaIdioma WHEN 'es-MX' THEN 'Tel: ' ELSE CASE @pnClaUbicacion WHEN 65 THEN 'Ph: ' ELSE 'Ph: +52 ' END END + RTRIM(ISNULL(Telefonos, '')) +
				   CASE LEN(RTRIM(LTRIM(ISNULL(Fax, '')))) WHEN 0 THEN '' ELSE ' Fax: ' + RTRIM(LTRIM(Fax)) END
				   ) AS Direccion,
				   ClaTipoImpresion = 1,
				   ptc.IdFabricacion,
				   IdOPM AS IdOpm,
				   CASE WHEN ciudadpedido.ClaPais = 1 THEN @sUnidadEsp ELSE @sUnidadIng END AS NomUnidad
					,IdFactura
				FROM  OPMSch.PloTraCertificado AS ptc WITH(nolock)
				JOIN  OPMSch.ArtCatArticuloVw AS acav WITH(nolock)ON ptc.ClaArticulo = acav.ClaArticulo
				AND   ClaTipoInventario = 1
				LEFT JOIN 	OPeSch.opeTraFabricacionVw a WITH(NOLOCK)
				ON		a.IdFabricacion = ptc.IdFabricacion
				LEFT JOIN OPeSch.opeVtaCatCiudadVw ciudadpedido(nolock)
				ON		ciudadpedido.ClaCiudad = a.ClaCiudad	
				LEFT JOIN  OPMSch.VtaCatClienteVw AS vccv WITH(nolock)ON ptc.ClaCliente = vccv.ClaCliente
				LEFT JOIN  OPeSch.opeVtaCatCiudadVw vccvw WITH(nolock)ON vccvw.ClaCiudad = ptc.ClaCiudad
				JOIN  OPMSch.TiCatUbicacionVw AS tcuv WITH(nolock)ON ptc.ClaUbicacion = tcuv.ClaUbicacion
				LEFT   JOIN OPMSch.PloCfgNotaCliente AS notas1 WITH(nolock)ON notas1.ClaUbicacion = ptc.ClaUbicacion 
				AND		notas1.ClaCliente = ptc.ClaCliente
				AND		notas1.ClaArticulo = ptc.ClaArticulo
				AND		isnull(notas1.BajaLogica,0) = 0
				LEFT   JOIN OPMSch.PloCfgNotaCliente AS notas2 WITH(nolock)ON notas2.ClaUbicacion = ptc.ClaUbicacion
				AND		notas2.ClaCliente = -1
				AND		notas2.ClaArticulo = ptc.ClaArticulo
				AND		isnull(notas2.BajaLogica,0) = 0
				LEFT   JOIN OPMSch.PloCfgNotaCliente AS notas3 WITH(nolock)ON notas3.ClaUbicacion = ptc.ClaUbicacion
				AND		notas3.ClaCliente = -1
				AND		notas3.ClaArticulo = -1	
				AND		isnull(notas3.BajaLogica,0) = 0
				WHERE	ptc.ClaUbicacion  = @pnClaUbicacion
				AND		ptc.IdCertificado = @cert
				AND		ptc.IdFactura = @nIdFactura

				SELECT	@cert = min(IdCertificado) 
				FROM	#certenc 
				WHERE	idCertificado > @cert
			END	
	
			IF @pnDebug > 1
				SELECT @nIdFactura AS '@nIdFactura', '' AS '#certdet', * FROM #certdet ORDER BY IdCertificado ASC

			--- Imprime los diferente tipos de Certificaciones	
			IF(@pnEsFacturacion = 1 or @pnEsFacturacion = 3)
			BEGIN
				/*para certificados = 1*/
				INSERT INTO #reportes
					(NombreReporte, 
					pnNumVersion,NumVersion, pnClaUbicacion, ClaUbicacion, ClaCliente, NombreCliente,
					NumeroFactura, IdCertificado, Ciudad, KgsTotal, NombreUbicacion, 
					NomArticulo, NomUnidad, IdViaje, IdPlanCarga, Nota,
					psClaIdioma, cultureName, ClaIdioma, Direccion, ClaTipoImpresion,
					IdFabricacion, ClavesRollo, ClaFormatoImpresion, IdFactura, EsExportarPDF,
					EsLandscape)
				SELECT CASE WHEN a.psClaIdioma = 'es-mx' THEN 'OPE_CU70_Pag1_Rpt_CertificadoCalidad' ELSE 'OPE_CU70_Pag1_Rpt_CertificadoCalidad' END,
					1, 1, a.claubicacion, a.claubicacion, b.ClaCliente, b.NombreCliente,
					b.NumeroFactura, a.IdCertificado, b.NombreCiudad, b.KgsTotal, b.NombreUbicacion,
					b.NomArticulo, b.NomUnidad, b.IdViaje, b.IdPlanCarga, b.Notas,
					a.psClaIdioma, a.psClaIdioma, a.psClaIdioma, b.Direccion, b.ClaTipoImpresion,
					b.IdFabricacion, '', 27, a.IdFactura, @nEsExportarPDF,
					1
				FROM #certenc a
				INNER JOIN #certdet b 
				ON a.idcertificado = b.idcertificado AND a.IdFactura =b.IdFactura
				WHERE a.ClaTipoCertificado = 1
				ORDER BY a.idCertificado
	
 				/*para certificados = 2*/
				INSERT INTO #reportes
					(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, ClaUbicacion, IdCertificado,
					psClaIdioma, cultureName, ClaIdioma, EsVistaPrevia, IdOpm,
					ClavesRollo, NombreCliente, Cantidad, NomUnidad, Factura,
					ClaFormatoImpresion, IdFactura, EsExportarPDF, EsLandscape)
				SELECT 'OPE_CU70_Pag1_Rpt_CertificadoMono', 1, 1, a.claubicacion, a.claubicacion, a.IdCertificado, 
					a.psClaIdioma, a.psClaIdioma, a.psClaIdioma, 0, b.IdOpm,
					'', b.NombreCliente, b.KgsTotal, b.NomUnidad, b.NumeroFactura,
					27, a.IdFactura, @nEsExportarPDF, 0
				FROM #certenc a
				INNER JOIN #certdet b 
				ON a.idcertificado = b.idcertificado AND a.IdFactura =b.IdFactura
				WHERE a.ClaTipoCertificado = 2
				ORDER BY a.idCertificado

				/*para certificados = 3*/
				INSERT INTO #reportes
					(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, ClaUbicacion, IdCertificado,
					psClaIdioma, cultureName, ClaIdioma, EsVistaPrevia, IdOpm,
					ClavesRollo, NombreCliente, Cantidad, NomUnidad, Factura,
					ClaFormatoImpresion, IdFactura, EsExportarPDF, EsLandscape)
				SELECT 'OPE_CU70_Pag1_Rpt_CertificadoMulti', 1, 1, a.claubicacion, a.claubicacion, a.IdCertificado,
					a.psClaIdioma, a.psClaIdioma, a.psClaIdioma, 1, b.IdOpm,
					'', b.NombreCliente, b.KgsTotal, b.NomUnidad, b.NumeroFactura,
					27, a.IdFactura, @nEsExportarPDF, 0
				FROM #certenc a
				INNER JOIN #certdet b 
				ON a.idcertificado = b.idcertificado AND a.IdFactura =b.IdFactura
				WHERE a.ClaTipoCertificado = 3
				ORDER BY a.idCertificado

				/*para certificados = 4*/
				INSERT INTO #reportes
					(NombreReporte, NumVersion, pnNumVersion, pnClaUbicacion, ClaUbicacion, ClaCliente,
					NombreCliente, NumeroFactura, IdCertificado, Ciudad, KgsTotal,
					NombreUbicacion, NomArticulo, NomUnidad, IdViaje, IdPlanCarga,
					Nota, psClaIdioma, cultureName, ClaIdioma, Direccion,
					ClaTipoImpresion, IdFabricacion, ClavesRollo, ClaFormatoImpresion, IdFactura,
					EsExportarPDF, EsLandscape)
				SELECT 'OPE_CU70_Pag1_Rpt_CertificadoHou', 1, 1, a.claubicacion, a.claubicacion, b.ClaCliente,
					b.NombreCliente, b.NumeroFactura, a.IdCertificado, b.NombreCiudad, b.KgsTotal,
					b.NombreUbicacion, b.NomArticulo, b.NomUnidad, b.IdViaje, b.IdPlanCarga,
					b.Notas, a.psClaIdioma, a.psClaIdioma, a.psClaIdioma, b.Direccion,
					b.ClaTipoImpresion, b.IdFabricacion, '', 27, a.IdFactura,
					@nEsExportarPDF, 1
				FROM #certenc a
				INNER JOIN #certdet b 
				ON a.idcertificado = b.idcertificado AND a.IdFactura =b.IdFactura
				WHERE a.ClaTipoCertificado = 4
				ORDER BY a.idCertificado

				/*para certificados = 5*/
				INSERT INTO #reportes
					(NombreReporte,
					NumVersion, pnNumVersion, pnClaUbicacion, ClaUbicacion, ClaCliente, NombreCliente,
					NumeroFactura, IdCertificado, Ciudad, KgsTotal, NombreUbicacion, 
					NomArticulo, NomUnidad, IdViaje, IdPlanCarga, Nota,
					psClaIdioma, cultureName, ClaIdioma, Direccion, ClaTipoImpresion,
					IdFabricacion, ClavesRollo, ClaFormatoImpresion, IdFactura, EsExportarPDF,
					EsLandscape)
				SELECT CASE WHEN a.psClaIdioma = 'es-mx' THEN 'OPE_CU70_Pag1_Rpt_CertificadoCalidad' ELSE  'OPE_CU70_Pag1_Rpt_CertificadoCalidad' END,
					1, 1, a.claubicacion, a.claubicacion, b.ClaCliente, b.NombreCliente,
					b.NumeroFactura, a.IdCertificado, b.NombreCiudad, b.KgsTotal, b.NombreUbicacion,
					b.NomArticulo, b.NomUnidad, b.IdViaje, b.IdPlanCarga, b.Notas,
					a.psClaIdioma, a.psClaIdioma, a.psClaIdioma, b.Direccion, 2/*b.ClaTipoImpresion*/,
					b.IdFabricacion, '', 27, a.IdFactura, @nEsExportarPDF,
					1
				FROM #certenc a
				INNER JOIN #certdet b 
				ON a.idcertificado = b.idcertificado AND a.IdFactura =b.IdFactura
				WHERE a.ClaTipoCertificado = 5
				ORDER BY a.idCertificado

				/*para certificados = 6*/
				INSERT INTO #reportes
					(NombreReporte,
					pnNumVersion, NumVersion, pnClaUbicacion, ClaUbicacion, ClaCliente, NombreCliente,
					NumeroFactura, IdCertificado, Ciudad, KgsTotal, NombreUbicacion,
					NomArticulo, NomUnidad, IdViaje, IdPlanCarga, Nota,
					psClaIdioma, cultureName, ClaIdioma, Direccion, ClaTipoImpresion,
					IdFabricacion, ClavesRollo, ClaFormatoImpresion, IdFactura, EsExportarPDF,
					EsLandscape)
				SELECT CASE WHEN a.psClaIdioma = 'es-mx' THEN 'OPE_CU70_Pag1_Rpt_CertificadoEstrobo' ELSE 'OPE_CU70_Pag1_Rpt_CertificadoEstrobo' END,
					1, 1, a.claubicacion, a.claubicacion, b.ClaCliente, b.NombreCliente,
					b.NumeroFactura, a.IdCertificado, b.NombreCiudad, b.KgsTotal, b.NombreUbicacion,
					b.NomArticulo, b.NomUnidad, b.IdViaje, b.IdPlanCarga, b.Notas,
					a.psClaIdioma, a.psClaIdioma, a.psClaIdioma, b.Direccion, 0/*b.ClaTipoImpresion*/,
					b.IdFabricacion, '', 27, a.IdFactura, @nEsExportarPDF,
					1
				FROM #certenc a
				INNER JOIN #certdet b 
				ON a.idcertificado = b.idcertificado AND a.IdFactura =b.IdFactura
				WHERE a.ClaTipoCertificado = 6
				ORDER BY a.idCertificado
			END
		END

		IF @pnDebug = 1
			SELECT @nIdFactura AS '@nIdFactura', '' AS '#reportes', * FROM #reportes

		IF(@Formato = 11)
		BEGIN
			--11-Bill of Lading -- Orden de envio Siempre es 0 ??
			IF (@pnClaUbicacion != 65 )
			BEGIN

						IF((SELECT ClaTipoViaje
							FROM OpeSch.OpeTraViaje WITH(NOLOCK)
							WHERE ClaUbicacion = @pnClaUbicacion
								AND IdViaje = @nIdViaje) = 4) --Exportación
						BEGIN
							INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, Idviaje, pnIdViaje, pnNumVersion, NumVersion, ClaPais, IdFactura, ClaFormatoImpresion, EsExportarPDF, EsStayTuff)
							SELECT 'OPE_CU71_Pag1_Rpt_ImpBillLadingUSA', @pnClaUbicacion, @pnClaUbicacion, @nIdViaje, @nIdViaje, 1, 1, 2, @nIdFactura, 11, @nEsExportarPDF, @nEsStayTuff		
						END
						ELSE
						BEGIN
							INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, IdViaje, pnIdViaje, ClaFormatoImpresion, Idioma, IdFactura, EsExportarPDF)
							SELECT 'OPE_CU71_Pag1_Rpt_ImpBillLadingEsp', @pnClaUbicacion, @pnClaUbicacion, @nIdViaje, @nIdViaje, 11, 'es', @nIdFactura, @nEsExportarPDF
						END

			END
			ELSE
			BEGIN
				 INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, Idviaje, pnIdViaje, pnNumVersion, NumVersion, ClaPais, IdFactura, ClaFormatoImpresion, EsExportarPDF, EsStayTuff)
				 SELECT 'OPE_CU71_Pag1_Rpt_ImpBillLadingUSA', @pnClaUbicacion, @pnClaUbicacion, @nIdViaje, @nIdViaje, 1,1, 2, @nIdFactura, 11, @nEsExportarPDF, @nEsStayTuff
			END 
		END

		IF(@Formato = 8)
		BEGIN
			--8-Packing List
			IF((SELECT ClaTipoViaje
						FROM OpeSch.OpeTraViaje WITH(NOLOCK)
						WHERE ClaUbicacion = @pnClaUbicacion
							AND IdViaje = @nIdViaje) = 4)
			BEGIN
				INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, IdViaje, ClaIdioma, psClaIdioma, pnNumVersion, NumVersion, ClaFormatoImpresion, IdFactura, EsExportarPDF)
				SELECT 'OPE_CU71_Pag1_Rpt_ImpPackingListEsp', @pnClaUbicacion, @pnClaUbicacion, @nIdViaje, 'es-MX' AS ClaIdioma, 'es-MX' AS psClaIdioma, 1, 1, 8, @nIdFactura, @nEsExportarPDF
			END
		END

		DELETE #certenc
		DELETE #tmpMovEntSalISB
		DELETE TOP (1) FROM #TempReimpresionDigital 
		
		SELECT @CountWh = Count(*) 
		FROM   #TempReimpresionDigital 
	END		-- FIN WHILE

	IF @pnDebug = 1
	BEGIN
		SELECT '' AS '#tmpCfgMotivoFormatoImp', * FROM #tmpCfgMotivoFormatoImp
		SELECT '' AS '#reportes Fin', * FROM #reportes
	END

	SELECT distinct t1.*--,t2.NoCopias
    FROM #reportes t1
    INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
          t1.ClaFormatoImpresion = t2.ClaFormatoImpresion 
    WHERE t1.ClaFormatoImpresion in (2,13,10,14,27,20,21,22,23)
    UNION ALL
    SELECT distinct t1.*--,t2.NoCopias
    FROM #reportes t1
    INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
          t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
    WHERE t1.ClaFormatoImpresion Not in (18,19,20,21,22,23) -- las remisiones traen su propio proceso arriba
    and t2.NoCopias > 1 and NoCopias < 1000 -- segundo juego de copias
    UNION ALL
    SELECT  distinct t1.*--,t2.NoCopias
    FROM #reportes t1
    INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
          t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
    WHERE t1.ClaFormatoImpresion Not in (18,19,20,21,22,23) -- las remisiones traen su propio proceso arriba
    and t2.NoCopias > 2 and NoCopias < 1000 -- tercer juego de copias
    UNION  ALL
    SELECT distinct t1.*--,t2.NoCopias
    FROM #reportes t1
    INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
          t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
    WHERE t1.ClaFormatoImpresion Not in (18,19,20,21,22,23) -- las remisiones traen su propio proceso arriba
    and t2.NoCopias > 3 and NoCopias < 1000 -- cuarto juego de copias
    --ORDER BY orden 

	DROP TABLE #reportes
	DROP TABLE #tmpParametrosReporte
	DROP TABLE #certenc
	DROP TABLE #certdet
	DROP TABLE #tmpFabricacionFactura
	DROP TABLE #tmpMovEntSalISB
	DROP TABLE #TempReimpresionDigital
	DROP TABLE #tmpCfgMotivoFormatoImp 

	SET NOCOUNT OFF
END
