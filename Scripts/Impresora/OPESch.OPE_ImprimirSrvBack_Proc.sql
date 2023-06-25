--Respaldo 'OPESch.OPE_ImprimirSrvBack_Proc'
GO
ALTER PROCEDURE OPESch.OPE_ImprimirSrvBack_Proc
     @pnClaUbicacion   INT,
      @pnClaMotivoEntrada INT = 1,
      @pnIdboleta INT = NULL,
      @pnIdPlanCargaFact INT = NULL,
      @pnClaIdioma INT = 5,
      @pnEsFacturacion INT = 1, /* 1-Facturación, 0-Bascula,3-SoloCertificados*/
      @psNombrePcMod VARCHAR(64),
	  @pnIdOrdenEnvio INT = 0  --temporal
AS
BEGIN 
	SET NOCOUNT ON  

	--COMENTARIOS WTOOL
	-- EsLandscape -> Columna para imprimir en Landscape
	--PARA IMPRESION
	-- La ubicacion la toma de la sesion y la de este SP no la considera .
	-- El lenguaje lo toma de la sesion al igual que la ubicacion. 
	-- Los nombres de las columnas no deben de tener el prefijo (pn, ps, pt, etc)
	-- Las variables las toma en el siguiente orden: De este SP, del Excel y al final de la sesion.
	--PARA GUARDAR A PDF
	-- La ubicacion primero la toma del SELECT de este SP.

	--Variables para los reportes
	DECLARE @nIdViaje INT, @nIdBoleta INT, @sPlaca VARCHAR(12), @nIdTabular INT, @nIdTipoConcepto INT, @nClaCliente INT, 
		@nIdFabricacion INT, @nIdFabricacionDet INT, @nPorcReal NUMERIC(22,4), @nPorcCub NUMERIC(22,4), @sMontacarguista VARCHAR(250),
		@EmbReal numeric(22,2),@Embcub numeric(22,2),@CapCub numeric(22,2),@CapReal numeric(22,2), @nNumVersion INT, @nIdFactura INT,
		@nIdMovEntsal INT, @nEsEntrada INT,@nClaTipoPesajeSalida INT, @nNoCopias INT, @nEsExportarPDF INT, @nEmpresaStayTuff INT,
		@nEsStayTuff INT, @psIdioma VARCHAR(10), @pnEsValidarDigitalizacion INT
	                
	CREATE TABLE #reportes
		(orden INT IDENTITY(1,1),
		ClaFormatoImpresion INT,
		NombreReporte VARCHAR(500),
		pnClaUbicacion INT,
		ClaUbicacion INT NULL,
		IdViaje    INT NULL,
		pnIdViaje INT NULL,
		pnNumVersion INT NULL,
		NumVersion INT NULL,
		IdPlanCarga INT NULL,
		IdBoleta INT NULL,
		IdTipoConcepto INT NULL,
		IdTabular INT NULL,
		IdMovEntSal INT,
		IdFactura INT NULL,
		IdOrdenEnvioCU66P1 INT NULL,
		PorcReal NUMERIC(19,2) NULL,
		PorcCub NUMERIC(19,2) NULL,
		Montacarguista VARCHAR(500),
		ClaCliente INT null, 
		NombreCliente VARCHAR (250) null, 
		Ciudad VARCHAR (250) null, 
		IdCertificado INT null, 
		KgsTotal NUMERIC (28, 3) null, 
		NumeroFactura VARCHAR (250) null, 
		NomArticulo VARCHAR (500) null, 
		NombreUbicacion VARCHAR (50) null, 
		Nota VARCHAR (500) null, 
		Direccion VARCHAR (500) null, 
		ClaTipoImpresion INT null, 
		IdFabricacion INT null, 
		NomUnidad VARCHAR (100) NULL,
		psClaIdioma VARCHAR (5) NULL,
		ClavesRollo VARCHAR(8000) NULL,
		NomIsoIdioma VARCHAR(3) NULL,
		ClaPais INT NULL,
		cultureName VARCHAR (5) NULL,
		ClaIdioma VARCHAR (5) NULL,
		EsVistaPrevia INT NULL,
		IdOpm  INT  NULL,
		Cantidad nUMERIC (28, 3) null,
		Factura VARCHAR (250) null  ,  
		Diametro  VARCHAR(250)null,
		Longitud  VARCHAR(250)null,
		Especificacion  VARCHAR(250)null,
		Tipo  VARCHAR(250)null,
		ClaFactura INT,
		RemisionSN INT,
		EnPlanta INT,
		CopiaTranspSN INT,
		ClaViaje INT,
		ClaFabricacion INT,
		EsStayTuff INT,
		Idioma VARCHAR(2),
		EsExportarPDF INT,
		EsLandscape INT,
		Grado VARCHAR(250),
		Construccion VARCHAR(250),
		Lubrication VARCHAR(250),
		CoreType VARCHAR(250),
		Torcido VARCHAR(250),
		Acabado VARCHAR(250),
		TipoConstruccion VARCHAR(250),
		Firma VARBINARY(MAX),
		NombreUsuario VARCHAR(250),
		Puesto VARCHAR(250),
		LongitudTotal VARCHAR(250),
		psIdioma VARCHAR(10),
		ClaUbicacionOrigen INT,
		ClaArticulo INT,
		Observaciones VARCHAR(1000),
		Colada INT,
		DiamMM INT,
		IdCertificadoR INT,
		ClaIdiomaR INT,
		OmitirImpresion INT DEFAULT 0) 
                   
	--Certificados          
	CREATE TABLE #certenc
		(ClaUbicacion INT, 
		IdCertificado INT, 
		IdFactura INT,
		ClaTipoCertificado INT, 
		psClaIdioma VARCHAR (5))
		    
	CREATE TABLE #certdet
		(ClaCliente INT null, 
		NombreCliente VARCHAR (250) null, 
		NombreCiudad VARCHAR (250) null, 
		FechaActual DATETIME null, 
		ClaArticulo INT null, 
		IdCertificado INT null, 
		KgsTotal NUMERIC (28, 3) null, 
		IdViaje INT null, 
		IdPlanCarga INT null, 
		NumeroFactura VARCHAR (250) null, 
		NomArticulo VARCHAR (500) null, 
		NombreUbicacion		VARCHAR (50) null, 
		Notas VARCHAR (500) null, 
		Direccion VARCHAR (500) null, 
		ClaTipoImpresion INT null, 
		IdFabricacion INT null, 
		IdOpm INT null, 
		NomUnidad VARCHAR (100) NULL)

	--Facturas
	CREATE TABLE #tmpFabricacionFactura
		(Indice INT IDENTITY(1,1), 
		ClaFormatoImpresion INT, 
		IdFabricacion INT, 
		EsNacional BIT,
		NoCopias INT,
		idFactura INT)

	--Certificados alambron.	
	CREATE TABLE #tmpParametrosReporte
		(NumVersion INT,
		ClaUbicacion INT,
		ClaCliente INT,
		Diametro INT,
		NombreCliente VARCHAR(100),
		IdCertificado INT,
		NomUnidad VARCHAR(100),
		Observaciones VARCHAR(1),
		cultureName VARCHAR(50),
		ClaIdioma VARCHAR(50),
		Colada INT,
		DiamMM INT,
		IdFactura INT)

	DECLARE @tClientes TABLE
		(ClaCliente INT,
		ClaEmpresa INT)

	CREATE TABLE #tmpMovEntSalISB
		(IdMovEntSal INT,
		IdFabricacion INT,
		IdViaje INT)

	CREATE TABLE #tmpCertificadoABC
		(ClaFormatoImpresion INT,
		NombreReporte VARCHAR(500),
		ClaUbicacion INT NULL,
		IdFactura INT NULL,
		IdCertificadoR INT,
		IdCertificado INT null,
		ClaIdiomaR INT,
		FechaGeneracion DATETIME)

	CREATE TABLE #tmpCertificadoOtrasPlantas
		(ClaFormatoImpresion INT,
		NombreReporte VARCHAR(500),
		ClaUbicacion INT NULL,
		ClaUbicacionOrigen INT,
		ClaArticulo INT,
		ClavesRollo VARCHAR(8000) NULL,
		Nombrecliente VARCHAR (250) null,
		NombreUbicacion VARCHAR (50) null,
		KgsTotal NUMERIC (28, 3) null,
		Ciudad VARCHAR (250) null,
		NomArticulo VARCHAR (500) null,
		IdFabricacion INT null,
		IdViaje INT NULL,
		IdPlanCarga INT NULL,
		IdFactura INT NULL,
		NumeroFactura VARCHAR (250) null,
		Direccion VARCHAR (500) null,
		NomUnidad VARCHAR (100) NULL,
		Nota VARCHAR (500) null,
		ClaTipoImpresion INT null,
		CultureName VARCHAR (5) NULL,
		IdCertificado INT null,
		EsLandscape INT)
	
	SET @nEsStayTuff = 0 --Por default la dejamos en cero
	SET @pnEsValidarDigitalizacion = 0

	IF EXISTS(SELECT 1
				FROM OPESch.TiCatConfiguracionVw WITH(NOLOCK)
				WHERE @pnClaUbicacion = ClaUbicacion
				AND 127 = ClaSistema
				AND 1271148 = ClaConfiguracion
				AND 1 = nValor1
				AND 0 = BajaLogica)
	BEGIN
		SET @pnEsValidarDigitalizacion = 1
	END

	SELECT	@nEmpresaStayTuff = ISNULL(nValor1, -1)
	FROM	OpeSch.TiCatConfiguracionVw
	WHERE	ClaSistema = 127
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

	DECLARE @cert INT, @psClaIdioma VARCHAR(5)
	
	IF  isnull(@pnEsFacturacion,0) = 3 goto Certificados 
      
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

	SELECT @nClaTipoPesajeSalida = ClaTipoPesajeSalida 
	FROM OpeSch.OpeTraBoletaHis WITH(NOLOCK) 
	WHERE IdBoleta = @pnIdBoleta AND 
		ClaUbicacion = @pnClaUbicacion

	--Si viene de Plan de Carga, trae la boleta y el motivo entrada no, obtener valor
	SELECT @pnClaMotivoEntrada = ClaMotivoEntrada 
	FROM OpeSch.OpeTraBoleta WITH(NOLOCK)
	WHERE ClaUbicacion = @pnClaUbicacion AND 
		IdBoleta = @pnIdBoleta
      
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

		SELECT TOP 1 @nIdMovEntSal = IdMovEntSal,
			@nIdFactura = IdFactura 
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
	    
		--Datos para Reporte -> OPE_CU71_Pag1_Rpt_ImpOrdenCargaEsp
		SELECT  @EmbReal = ISNULL((SELECT SUM(ISNULL(AA.PesoEmbarcado,0))
								FROM  Opesch.OpeTraPlanCargaDetVw AA WITH(NOLOCK)
								WHERE AA.ClaUbicacion = @pnclaUbicacion AND
										AA.IdPlanCarga = a.idPlanCarga), 0),           
										@Embcub = ISNULL((SELECT SUM(ISNULL(BB.PesoCub,0))
														FROM  Opesch.OpeTraPlanCargaDetVw BB WITH(NOLOCK)
														WHERE BB.ClaUbicacion = @pnclaUbicacion AND
																	BB.IdPlanCarga = a.idPlanCarga), 0),
																	@CapCub = ISNULL(b.cubicaje,0),
																	@CapReal = CASE WHEN ISNULL(d.PesoBrutoMaximo,0) = 0 
																						   THEN ISNULL(b.capacidad,0) 
																						   ELSE ISNULL(d.PesoBrutoMaximo,0) END 
		FROM  OpeSch.OpeTraPlanCargaVw a WITH (nolock) 
					LEFT JOIN OpeSch.OpeFleCatTransporteVw b WITH (nolock) 
		ON          b.ClaTransporte = a.ClaTransporte
					LEFT JOIN OpeSch.OpeFleCatEjeTransporteVw d WITH (nolock)
		ON          d.ClaEjeTransporte = a.ClaEjeTransporte
					AND   d.ClaTransporte = a.ClaTransporte
		WHERE a.ClaUbicacion = @pnClaUbicacion
					AND a.idPlanCarga = @pnIdPlanCargaFact

		SELECT      @nPorcReal = CASE WHEN @CapReal = 0 THEN 0 ELSE @EmbReal/@CapReal *100.0 END,
					@nPorcCub = CASE WHEN @CapCub = 0 THEN 0 ELSE @EmbCub/@CapCub *100.0 END

		SELECT      @sMontacarguista = MC.NomMontacarga
		FROM		PleSch.PLETraPPlanDet pd WITH (NOLOCK) 
					LEFT JOIN PleSch.PLECatMontacargaVw mc WITH (NOLOCK) 
		ON          pd.ClaUbicacion  = mc.ClaUbicacion
					AND pd.ClaMontacarga = mc.ClaMontacarga
		WHERE		pd.ClaUbicacion = @pnClaUbicacion 
					AND pd.IdViaje = @nIdViaje
					AND pd.IdPPlanDet = 1
	            
		SELECT      @sMontacarguista = ISNULL(@sMontacarguista, '-----')
		
		INSERT	INTO @tClientes
		SELECT	DISTINCT Cli.ClaCliente, Cli.ClaEmpresa
		FROM	OpeSch.OpeTraViaje viaje WITH (NOLOCK)
		INNER	JOIN OpeSch.OpeTraMovEntSal entSal WITH (NOLOCK) ON
				viaje.ClaUbicacion = entSal.ClaUbicacion AND
				viaje.IdViaje = entSal.IdViaje AND
				ISNULL(entSal.IdFactura, -1) > 0
		INNER	JOIN OpeSch.TiCatUbicacionVw ubi WITH (NOLOCK) ON
				viaje.ClaUbicacion = ubi.ClaUbicacion
		INNER	JOIN OpeSch.OpeTraFabricacionVw fab WITH (NOLOCK) ON
				entSal.IdFabricacion = fab.IdFabricacion AND
				entSal.ClaUbicacion = fab.ClaPlanta
		LEFT	JOIN OpeSch.OpeVtaCatClienteVw Cli
				ON Cli.ClaCliente = fab.ClaCliente
		WHERE	viaje.IdViaje = @nIdViaje
				AND viaje.ClaUbicacion = @pnClaUbicacion

		IF EXISTS (SELECT ClaCliente FROM @tClientes WHERE ClaEmpresa = @nEmpresaStayTuff)
		BEGIN
			SET @nEsStayTuff = 1 --Si al menos un cliente se le factura como StayTuff, entonces usar logo
		END
	END

	Certificados: 

	/*******Obetener Formatos********/

	--1-Boleta
	--2-Tabular
	--4-Orden de Carga
	--5-Certificado de Origen
	--6-Orden de Descarga
	--7-Lista de Empaque
	--8-Packing List
	--9-Salida de Taras
	--10-Relacion de Embarques
	--11-Bill of Lading
	--12-Master Bill of Lading
	--13-Reporte de Carga
	--14-Hoja de Traspaso
	--15-Lista de Verificacion
	--16-CTPTA/CASCEM
	--17-Canada Custom Invoice
	--18-Factura Original Cliente
	--19-Factura Copia Agente
	--20-Factura Consecutivo
	--21-Factura Copia Cliente
	--22-Factura Copia Transportista
	--23-Factura Copia Bodega
	--24-Boleta Parcialidad
	--25-Bitacora de Carga de Exportacion
	--26-Orden de Descarga ODM
	--27-Certificado Calidad Industrial
	--28-Verificacion de Transporte
	--29-Localización de Producto
	--30-Disclaimer Cables DEACERO SAPI
	--31-Disclaimer Cables DEACERO USA
	--32-Certificado Calidad de Alambrón
	--33-Certificado ABC
	--34-Orden de salida de Maquila
	--35-Orden de entrada de Maquila

      
	SET @pnEsFacturacion = ISNULL(@pnEsFacturacion, 0)

	CREATE TABLE #tmpCfgMotivoFormatoImp 
		(Indice INT IDENTITY(1,1),
		ClaMotivoEntrada INT, 
		ClaFormatoImpresion INT, 
		NomFormatoImpresion VARCHAR(50),
		NoCopias INT)

	CREATE TABLE #tmpValidaImpresion
		(EsImpresionValida BIT)

	DECLARE @nIndice1 INT 
	DECLARE @nEsImpresionValida BIT
	DECLARE @nClaMotivoEntrada INT

	SET @nIndice1 = 1

	DECLARE @nClaFormatoImpresion INT

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
	END
	ELSE IF(@pnEsFacturacion = 3)--solocertificados
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
			  WHERE ClaFormatoImpresion IN (2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,34,35)
		END
	END

	--SE VALIDAN TOODOS LOS FORMATOS.
	SET @nIndice1 = (SELECT MIN(Indice) 
						 FROM #tmpCfgMotivoFormatoImp)

	WHILE(@nIndice1 IS NOT NULL)
	BEGIN
		DELETE FROM #tmpValidaImpresion
		SET @nEsImpresionValida = 0
		SET @nClaFormatoImpresion = NULL
		SET @nClaMotivoEntrada = NULL
	    
		SELECT @nClaFormatoImpresion = ClaFormatoImpresion,
			  @nClaMotivoEntrada = ClaMotivoEntrada
		FROM #tmpCfgMotivoFormatoImp 
		WHERE Indice = @nIndice1 
	    
		IF(@pnIdBoleta IS NOT NULL)
		BEGIN
			  INSERT INTO #tmpValidaImpresion(EsImpresionValida)
			  EXEC OpeSch.OpeValidarImpresionProc
					@pnNumVersion = 1,
					@ClaUbicacion = @pnClaUbicacion, 
					@IdBoleta = @pnIdBoleta, 
					@ClaFormatoImpresion = @nClaFormatoImpresion
	                
			  SELECT TOP 1 @nEsImpresionValida = EsImpresionValida
			  FROM #tmpValidaImpresion
	          
			  IF(@nEsImpresionValida = 0)
			  BEGIN
					DELETE FROM #tmpCfgMotivoFormatoImp
					WHERE ClaFormatoImpresion IN (@nClaFormatoImpresion)
			  END
		END

		SET @nIndice1 = (SELECT MIN(Indice)
							   FROM #tmpCfgMotivoFormatoImp
							   WHERE Indice > @nIndice1)
	END


	IF(@pnEsFacturacion = 1)
	BEGIN
		--Se quitan los motivos que no estan codificados en .NET para su impresion.
		--1-Boleta
		--5-Certificado de Origen
		--6-Orden de Descarga
		--7-Lista de Empaque
		--9-Salida de Taras
		--15-Lista de Verificacion
		--16-CTPTA/CASCEM
		--17-Canada Custom Invoice
		--24-Boleta Parcialidad
		--26-Orden de Descarga ODM
		--29-Localización de Producto
		DELETE FROM #tmpCfgMotivoFormatoImp
		WHERE ClaFormatoImpresion IN (1,5,6,7,9,15,16,17,24,26,29) 
		--Se quitan los que están dentro de un clico porque no esta prepara para iterar.
		--SET @nClaFormatoImpresion26 = NULL --27-Certificado Calidad Industrial
	END
	ELSE IF(@pnEsFacturacion = 3)
	BEGIN
	
		--Se quitan los motivos que no estan codificados en .NET para su impresion.
		--1-Boleta
		--4-Orden de Carga
		--5-Certificado de Origen
		--6-Orden de Descarga
		--7-Lista de Empaque
		--9-Salida de Taras
		--15-Lista de Verificacion
		--16-CTPTA/CASCEM
		--17-Canada Custom Invoice
		--24-Boleta Parcialidad
		--26-Orden de Descarga ODM
		--29-Localización de Producto
		DELETE FROM #tmpCfgMotivoFormatoImp
		WHERE ClaFormatoImpresion NOT IN (27) 
		
		GOTO  Certificados2
		--Se quitan los que están dentro de un clico porque no esta prepara para iterar.
		--SET @nClaFormatoImpresion26 = NULL --27-Certificado Calidad Industrial
	END
	ELSE
	BEGIN
		--Se quitan los motivos que no estan codificados en .NET para su impresion.
		--4-Orden de Carga
		--5-Certificado de Origen
		--7-Lista de Empaque
		--16-CTPTA/CASCEM
		--27-Certificado Calidad Industrial
		--28-Verificacion de Transporte
		--29-Localización de Producto
		DELETE FROM #tmpCfgMotivoFormatoImp
		WHERE ClaFormatoImpresion IN (4,5,7,16,27,28,29) 
	    
		--Se quitan los que están dentro de un ciclo porque no esta prepara para iterar.
		--9-Salida de Taras
		--DELETE FROM #tmpCfgMotivoFormatoImp
		--WHERE ClaFormatoImpresion IN (9)
	END
      
	/* FIN TRASPONER DATOS DE FORMATOS*/     

	IF(@pnClaUbicacion not in (267, 65))
	BEGIN
		SET @psIdioma = 'Spanish'
	END
	ELSE
	BEGIN
		SET @psIdioma = 'English'
	END
	    
	/*Se insertan reportes con sus parametros en la temporal*/
	IF @pnClaUbicacion not in (267, 65) AND ISNULL(@pnIdOrdenEnvio, 0) = 0
	BEGIN          
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, Idviaje, ClaFormatoImpresion, NomIsoIdioma)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpReporteCargaEsp', @pnClaUbicacion, @nIdViaje, 13, 'es'
		    
		INSERT INTO #reportes(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, IdPlanCarga, psClaIdioma, ClaIdioma, NomIsoIdioma, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpRelEmbarque' AS NombreReporte, 1, 1, @pnClaUbicacion, @pnIdPlanCargaFact,  '5', '5', 'en', 10

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, pnNumVersion, NumVersion, IdPlanCarga, PorcReal, PorcCub, Montacarguista, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpOrdenCargaEsp',  @pnClaUbicacion, @nNumVersion, @nNumVersion, @pnIdPlanCargaFact,  @nPorcReal, @nPorcCub, @sMontacarguista, 4
		    
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, ClaFormatoImpresion, pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpBoletaBasc1Esp' AS NombreReporte, @pnClaUbicacion AS pnClaUbicacion, @pnIdBoleta IdBoleta, 1, 1, 1

		IF ISNULL(@nIdTabular, 0) > 0
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdTabular,  IdTipoConcepto, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpTabular' AS NombreReporte, @pnClaUbicacion, @nIdTabular, @nIdTipoConcepto, 2

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, ClaFormatoImpresion, NomIsoIdioma, pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpOrdenDescargaEsp' AS NombreReporte, @pnClaUbicacion, @pnIdBoleta,6 ,'es', 1, 1

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, IdViaje, ClaIdioma, psClaIdioma, pnNumVersion, NumVersion, ClaFormatoImpresion, IdFactura, EsExportarPDF)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpPackingListEsp', @pnClaUbicacion, @pnClaUbicacion, @nIdViaje, 'es-MX' AS ClaIdioma, 'es-MX' AS psClaIdioma, 1, 1, 8, @nIdFactura, @nEsExportarPDF
		 
		--INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, IdViaje, IdMovEntSal, ClaFormatoImpresion, pnNumVersion, NumVersion)
		--SELECT 'OPE_CU71_Pag1_Rpt_ImpSalidaTaraEsp', @pnClaUbicacion, @pnIdBoleta, @nIdViaje, @nIdMovEntsal, 9, 1, 1
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, IdViaje, pnIdViaje, IdMovEntSal, ClaFormatoImpresion, pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpSalidaTaraEsp', @pnClaUbicacion, @pnIdBoleta, @nIdViaje, @nIdViaje, A.IdMovEntSal, 9, 1, 1
		FROM #tmpMovEntSalISB A	

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpVerificaTranspEsp', @pnClaUbicacion, 15

		INSERT INTO #reportes(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, IdViaje, pnIdViaje, ClaFormatoImpresion, ClaIdioma, psClaIdioma)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpHojaTraspasoEsp', 1, 1, @pnClaUbicacion, @nIdViaje, @nIdViaje, 14, '5', '5'
		
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
		
		INSERT INTO #reportes(NombreReporte, ClaUbicacion, IdViaje, pnIdViaje, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpMasterBillLad', @pnClaUbicacion, @nIdViaje, @nIdViaje, 12

		INSERT INTO #reportes(NombreReporte, ClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_DisclaimerCablesSAPI', @pnClaUbicacion, 30
		
		INSERT INTO #reportes(NombreReporte, ClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_DisclaimerCablesUSA', @pnClaUbicacion, 31
		
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, ClaFormatoImpresion, IdBoleta)
		SELECT 'OPE_CU71_Pag1_Rpt_OrdenSalidaMaquila', @pnClaUbicacion, @pnClaUbicacion, 34, @pnIdBoleta
		
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, ClaFormatoImpresion, IdBoleta)
		SELECT 'OPE_CU71_Pag1_Rpt_OrdenEntradaMaquila', @pnClaUbicacion, @pnClaUbicacion, 35, @pnIdBoleta
	END
      
	IF @pnClaUbicacion in (267, 65)  AND ISNULL(@pnIdOrdenEnvio, 0) = 0
	BEGIN       
	INSERT INTO #reportes(NombreReporte, pnClaUbicacion, Idviaje, ClaFormatoImpresion,pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpReporteCargaIng', @pnClaUbicacion, @nIdViaje, 13,1,1
		    
		INSERT INTO #reportes(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, IdPlanCarga, psClaIdioma, ClaIdioma,  ClaFormatoImpresion, EsStayTuff)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpRelEmbarqueIng' AS NombreReporte, 1, 1, @pnClaUbicacion, @pnIdPlanCargaFact,   'en','en', 10, @nEsStayTuff

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, pnNumVersion, NumVersion, IdPlanCarga, PorcReal, PorcCub, Montacarguista, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpOrdenCargaIng',  @pnClaUbicacion, @nNumVersion, @nNumVersion, @pnIdPlanCargaFact,  @nPorcReal, @nPorcCub, @sMontacarguista, 4
		    
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, ClaFormatoImpresion, pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpBoletaBasc1Ing' AS NombreReporte, @pnClaUbicacion AS pnClaUbicacion, @pnIdBoleta IdBoleta, 1, 1, 1
		--SELECT 'OPE_CU71_Pag1_Rpt_ImpBoletaBasc1Esp' AS NombreReporte, @pnClaUbicacion AS pnClaUbicacion, @pnIdBoleta IdBoleta, 1, 1, 1
		
		IF ISNULL(@nIdTabular, 0) > 0
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdTabular,  IdTipoConcepto, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpTabularEn' AS NombreReporte, @pnClaUbicacion, @nIdTabular, @nIdTipoConcepto, 2

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, ClaFormatoImpresion, NomIsoIdioma, pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpOrdenDescargaIng' AS NombreReporte, @pnClaUbicacion, @pnIdBoleta, 6, 'en', 1, 1

		/*INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdViaje, ClaIdioma, psClaIdioma, pnNumVersion, NumVersion, ClaFormatoImpresion, IdFactura, EsExportarPDF)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpPackingListIng', @pnClaUbicacion, @nIdViaje, 'en' AS ClaIdioma, 'en' AS psClaIdioma, 1, 1, 8, @nIdFactura, @nEsExportarPDF*/
		 
		--INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, IdViaje, IdMovEntSal, ClaFormatoImpresion, pnNumVersion, NumVersion)
		--SELECT 'OPE_CU71_Pag1_Rpt_ImpSalidaTaraIng', @pnClaUbicacion, @pnIdBoleta, @nIdViaje, @nIdMovEntsal, 9, 1, 1
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdBoleta, IdViaje, pnIdViaje, IdMovEntSal, ClaFormatoImpresion, pnNumVersion, NumVersion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpSalidaTaraEsp', @pnClaUbicacion, @pnIdBoleta, @nIdViaje, @nIdViaje, A.IdMovEntSal, 9, 1, 1
		FROM #tmpMovEntSalISB A	

		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpVerificaTranspIng', @pnClaUbicacion, 15

		INSERT INTO #reportes(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, IdViaje, ClaFormatoImpresion, ClaIdioma, psClaIdioma)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpHojaTraspasoIng', 1, 1, @pnClaUbicacion, @nIdViaje,14, 'en', 'en'
	
		--INSERT INTO #reportes(NombreReporte, pnClaUbicacion, pnNumVersion, IdPlanCarga)
		--SELECT  'OPE_CU71_Pag1_Rpt_ImpRelEmbarqueIng', @pnClaUbicacion,  1,          @pnIdPlanCargaFact
	    
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, Idviaje, pnIdViaje, pnNumVersion, NumVersion, ClaPais, IdFactura, ClaFormatoImpresion, EsExportarPDF, EsStayTuff)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpBillLadingUSA', @pnClaUbicacion, @pnClaUbicacion, @nIdViaje, @nIdViaje, 1,1, 2, @nIdFactura, 11, @nEsExportarPDF, @nEsStayTuff

		INSERT INTO #reportes(NombreReporte, ClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_DisclaimerCablesSAPI', @pnClaUbicacion, 30
		
		INSERT INTO #reportes(NombreReporte, ClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_DisclaimerCablesUSA', @pnClaUbicacion, 31
		
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, ClaFormatoImpresion, IdBoleta)
		SELECT 'OPE_CU71_Pag1_Rpt_OrdenSalidaMaquila', @pnClaUbicacion, @pnClaUbicacion, 34, @pnIdBoleta
		
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, ClaUbicacion, ClaFormatoImpresion, IdBoleta)
		SELECT 'OPE_CU71_Pag1_Rpt_OrdenEntradaMaquila', @pnClaUbicacion, @pnClaUbicacion, 35, @pnIdBoleta
	END
	
	
	IF ISNULL(@pnIdOrdenEnvio, 0) <> 0
	BEGIN
	
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdOrdenEnvioCU66P1, ClaFormatoImpresion, psIdioma)
		SELECT 'OPE_CU66_Pag1_Rpt_BillLading' AS NombreReporte, @pnClaUbicacion, @pnIdOrdenEnvio, 11, null
		
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdOrdenEnvioCU66P1, ClaFormatoImpresion, psIdioma)
		SELECT 'OPE_CU66_Pag1_Rpt_PackingList' AS NombreReporte, @pnClaUbicacion, @pnIdOrdenEnvio, 8, 'es-MX'

		INSERT INTO #reportes(NombreReporte, pnNumVersion, NumVersion, pnClaUbicacion, IdPlanCarga, psClaIdioma, ClaIdioma,  ClaFormatoImpresion, EsStayTuff)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpRelEmbarqueIng' AS NombreReporte, 1, 1, @pnClaUbicacion, @pnIdPlanCargaFact,   'en','en', 10, @nEsStayTuff

		IF ISNULL(@nIdTabular, 0) > 0
		INSERT INTO #reportes(NombreReporte, pnClaUbicacion, IdTabular,  IdTipoConcepto, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_ImpTabularEn' AS NombreReporte, @pnClaUbicacion, @nIdTabular, @nIdTipoConcepto, 2

		INSERT INTO #reportes(NombreReporte, ClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_DisclaimerCablesSAPI', @pnClaUbicacion, 30
		
		INSERT INTO #reportes(NombreReporte, ClaUbicacion, ClaFormatoImpresion)
		SELECT 'OPE_CU71_Pag1_Rpt_DisclaimerCablesUSA', @pnClaUbicacion, 31
	END

	Certificados2:
	/*Llenar certificados */

	INSERT INTO #certenc(ClaUbicacion, IdCertificado, IdFactura, ClaTipoCertificado, psClaIdioma)
	SELECT  Certif.ClaUbicacion,
		Certif.IdCertificado,
		Certif.IdFactura,
		Certif.ClaTipoCertificado,
   --CASE WHEN ( @pnClaUbicacion = 267 OR ( @pnClaUbicacion = 20 AND OpeSch.OpeTraFabricacionVw.ClaCliente = 47720 ) ) THEN 'en-Us' ELSE   
   --   (  CASE WHEN ciudadpedido.ClaPais = 1 THEN 'es-Mx' ELSE 'en-Us' END)   
   --END  
   CASE WHEN @pnClaUbicacion in (267, 65) THEN 'en-Us'   
     ELSE CASE WHEN ISNULL(CertCli.ClaIdioma,0) <> 0 THEN CertCli.NomIdiomaCorto  
     ELSE CASE WHEN CiudadPedido.ClaPais = 1 THEN 'es-Mx' ELSE 'en-Us' END END END  
 FROM OpeSch.OpeTraViaje Viaje WITH(NOLOCK)  
 INNER JOIN OpmSch.PloTraCertificado Certif WITH(NOLOCK)  
 ON  Certif.IdViaje = Viaje.IdViaje  
 AND     Certif.Claubicacion = Viaje.ClaUbicacion  
 AND  Certif.BajaLogica = 0  
 INNER JOIN OpeSch.OpeTraFabricacionVw WITH(NOLOCK)  
 ON  OpeSch.OpeTraFabricacionVw.IdFabricacion = Certif.IdFabricacion  
 INNER JOIN  OpeSch.OpeVtaCatCiudadVw CiudadPedido WITH(NOLOCK)  
 ON      CiudadPedido.ClaCiudad = OpeSch.OpeTraFabricacionVw.ClaCiudad  
 LEFT JOIN OpeSch.OpeRelCertificadoClienteRel1Vw CertCli WITH(NOLOCK)  
 ON  CertCli.ClaUbicacion = @pnClaUbicacion  
 AND  OpeSch.OpeTraFabricacionVw.ClaCliente = CertCli.ClaCliente  
 AND  CertCli.BajaLogica = 0 
	WHERE   Viaje.ClaUbicacion = @pnClaUbicacion
	AND  Viaje.IdPlanCarga = @pnIdPlanCargaFact


	SELECT @cert = min(IdCertificado) FROM #certenc
	WHILE @cert IS NOT NULL
	BEGIN
		SELECT @psClaIdioma = psClaIdioma
		FROM #certenc
		WHERE idCertificado = @cert
		AND   claUbicacion = @pnClaUbicacion
	                
		INSERT INTO #certdet(ClaCliente, NombreCliente, NombreCiudad, FechaActual, ClaArticulo, IdCertificado, KgsTotal, 
							   IdViaje, IdPlanCarga, NumeroFactura, NomArticulo, NombreUbicacion, Notas, 
							   Direccion, ClaTipoImpresion, IdFabricacion, IdOpm, NomUnidad)
		EXEC OpeSch.OpeCertificadoSel 1,@pnClaUbicacion, @cert, '',0,'',0,'',0,@psClaIdioma
	    
		SELECT @cert = min(IdCertificado) FROM #certenc WHERE idCertificado > @cert
	END
      
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
		ON a.idcertificado = b.idcertificado 
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
		ON a.idcertificado = b.idcertificado 
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
		ON a.idcertificado = b.idcertificado 
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
		ON a.idcertificado = b.idcertificado 
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
		ON a.idcertificado = b.idcertificado 
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
		ON a.idcertificado = b.idcertificado 
		WHERE a.ClaTipoCertificado = 6
		ORDER BY a.idCertificado                 
	END  

	--IMPRESION DE CERTIFICADOS DE OTRAS PLANTAS.
	--Se verifica que este prendida la configuracion.
	IF((SELECT nValor1
		FROM OPESch.TiCatConfiguracionVw WITH(NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacion
			AND ClaSistema = 127
			AND ClaConfiguracion = 1271091
			AND BajaLogica = 0) = 1)
	BEGIN
		--Si el formato esta configurado para que se imprima.
		IF EXISTS(SELECT 1
					FROM #tmpCfgMotivoFormatoImp
					WHERE ClaFormatoImpresion = 27)
		BEGIN
			INSERT INTO #tmpCertificadoOtrasPlantas
				(ClaFormatoImpresion, NombreReporte, ClaUbicacion, ClaUbicacionOrigen, ClaArticulo,
				ClavesRollo, Nombrecliente, NombreUbicacion, KgsTotal, Ciudad,
				NomArticulo, IdFabricacion, IdViaje, IdPlanCarga, IdFactura,
				NumeroFactura, Direccion, NomUnidad, Nota, ClaTipoImpresion,
				CultureName, IdCertificado, EsLandscape)
			EXEC OpeSch.OpeObtenParCertificadoEmbarqueProc
				@pnClaUbicacion = @pnClaUbicacion,
				@pnIdPlanCarga = @pnIdPlanCargaFact,
				@pnClaUsuarioMod = 1,
				@psNombrePcMod = @psNombrePcMod,
				@pnCantCopias = 1
	
			INSERT INTO #reportes
				(ClaFormatoImpresion, NombreReporte, ClaUbicacion, ClaUbicacionOrigen, ClaArticulo,
				ClavesRollo, Nombrecliente, NombreUbicacion, KgsTotal, Ciudad,
				NomArticulo, IdFabricacion, IdViaje, IdPlanCarga, IdFactura,
				NumeroFactura, Direccion, NomUnidad, Nota, ClaTipoImpresion,
				CultureName, IdCertificado, EsLandscape)
			SELECT ClaFormatoImpresion, NombreReporte, ClaUbicacion, ClaUbicacionOrigen, ClaArticulo,
				ClavesRollo, Nombrecliente, NombreUbicacion, KgsTotal, Ciudad,
				NomArticulo, IdFabricacion, IdViaje, IdPlanCarga, IdFactura,
				NumeroFactura, Direccion, NomUnidad, Nota, ClaTipoImpresion,
				CultureName, IdCertificado, EsLandscape
			FROM #tmpCertificadoOtrasPlantas	

			UPDATE #reportes
			SET EsExportarPDF = @nEsExportarPDF
			WHERE ClaFormatoImpresion = 27
		END
	END

	IF(@pnEsValidarDigitalizacion = 1 
		/*Si el fomato esta configurado para que se imprima ya sea en la salida o en la facturacion*/
		AND (SELECT COUNT(1)
		FROM OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) ON
			  B.ClaFormatoImpresion = A.ClaFormatoImpresion
		WHERE A.ClaUbicacion = @pnClaUbicacion
				AND A.ClaMotivoEntrada = @pnClaMotivoEntrada
				AND A.BajaLogica = 0
				AND (ISNULL(A.EsRequeridoAlFacturar, 0) = 1 OR ISNULL(A.EsRequeridoEnSalida, 0) = 1)
				AND A.NoCopias > 0 
				AND A.ClaFormatoImpresion = 27) > 0
		/*Si esta prendida la configuracion de digitalizacion*/
		AND @nEsExportarPDF = 1
		/*Solo si no se va a imprimir*/
		AND (SELECT COUNT(1)
				FROM #reportes
				WHERE ClaFormatoImpresion = 27) = 0)
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
			  A.NoCopias > 0 AND
			  A.ClaFormatoImpresion = 27
			  	
		IF((SELECT COUNT(1)
			FROM #tmpCertificadoOtrasPlantas) = 0)
		BEGIN		
			INSERT INTO #tmpCertificadoOtrasPlantas
				(ClaFormatoImpresion, NombreReporte, ClaUbicacion, ClaUbicacionOrigen, ClaArticulo,
				ClavesRollo, Nombrecliente, NombreUbicacion, KgsTotal, Ciudad,
				NomArticulo, IdFabricacion, IdViaje, IdPlanCarga, IdFactura,
				NumeroFactura, Direccion, NomUnidad, Nota, ClaTipoImpresion,
				CultureName, IdCertificado, EsLandscape)
			EXEC OpeSch.OpeObtenParCertificadoEmbarqueProc
				@pnClaUbicacion = @pnClaUbicacion,
				@pnIdPlanCarga = @pnIdPlanCargaFact,
				@pnClaUsuarioMod = 1,
				@psNombrePcMod = @psNombrePcMod,
				@pnCantCopias = 1
		END
	
		INSERT INTO #reportes
			(ClaFormatoImpresion, NombreReporte, ClaUbicacion, ClaUbicacionOrigen, ClaArticulo,
			ClavesRollo, Nombrecliente, NombreUbicacion, KgsTotal, Ciudad,
			NomArticulo, IdFabricacion, IdViaje, IdPlanCarga, IdFactura,
			NumeroFactura, Direccion, NomUnidad, Nota, ClaTipoImpresion,
			CultureName, IdCertificado, EsLandscape, OmitirImpresion)
		SELECT ClaFormatoImpresion, NombreReporte, ClaUbicacion, ClaUbicacionOrigen, ClaArticulo,
			ClavesRollo, Nombrecliente, NombreUbicacion, KgsTotal, Ciudad,
			NomArticulo, IdFabricacion, IdViaje, IdPlanCarga, IdFactura,
			NumeroFactura, Direccion, NomUnidad, Nota, ClaTipoImpresion,
			CultureName, IdCertificado, EsLandscape, 1
		FROM #tmpCertificadoOtrasPlantas	

		UPDATE #reportes
		SET EsExportarPDF = @nEsExportarPDF
		WHERE ClaFormatoImpresion = 27
	END
	
	--IMPRESION DE CERTIFICADOS DE ALAMBRON.
	--Si el formato esta configurado para que se imprima.
	IF EXISTS(SELECT 1
				FROM #tmpCfgMotivoFormatoImp
				WHERE ClaFormatoImpresion = 32)
	BEGIN
		INSERT INTO #tmpParametrosReporte
			(NumVersion, ClaUbicacion, ClaCliente, Diametro, NombreCliente,
			IdCertificado, NomUnidad, Observaciones, cultureName, ClaIdioma,
			Colada, DiamMM, IdFactura)
		EXEC OPCSch.OPCObtenerReporteCertificadoCalidadAlambronProc
			@pnClaUbicacion = @pnClaUbicacion,
			@pnIdPlanCarga = @pnIdPlanCargaFact,
			@psIdioma = @psIdioma

		INSERT INTO #reportes
			(ClaFormatoImpresion, NombreReporte, NumVersion, ClaUbicacion, ClaCliente,
			Diametro, NombreCliente, IdCertificado, NomUnidad, Observaciones,
			cultureName, ClaIdioma, Colada, DiamMM, IdFactura, EsExportarPDF)	
		SELECT 32, 'OPE_CU70_Pag1_Rpt_CertAlambron', NumVersion, ClaUbicacion, ClaCliente,
			Diametro, NombreCliente, IdCertificado, NomUnidad, Observaciones,
			cultureName, ClaIdioma, Colada, DiamMM, IdFactura, @nEsExportarPDF
		FROM #tmpParametrosReporte
	END

	IF(@pnEsValidarDigitalizacion = 1 
		/*Si el fomato esta configurado para que se imprima ya sea en la salida o en la facturacion*/
		AND (SELECT COUNT(1)
		FROM OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) ON
			  B.ClaFormatoImpresion = A.ClaFormatoImpresion
		WHERE A.ClaUbicacion = @pnClaUbicacion
				AND A.ClaMotivoEntrada = @pnClaMotivoEntrada
				AND A.BajaLogica = 0
				AND (ISNULL(A.EsRequeridoAlFacturar, 0) = 1 OR ISNULL(A.EsRequeridoEnSalida, 0) = 1)
				AND A.NoCopias > 0 
				AND A.ClaFormatoImpresion = 32) > 0
		/*Si esta prendida la configuracion de digitalizacion*/
		AND @nEsExportarPDF = 1
		/*Solo si no se va a imprimir*/
		AND (SELECT COUNT(1)
				FROM #reportes
				WHERE ClaFormatoImpresion = 32) = 0)
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
			  A.NoCopias > 0 AND
			  A.ClaFormatoImpresion = 32
	
		IF((SELECT COUNT(1)
			FROM #tmpParametrosReporte) = 0)
		BEGIN		
			INSERT INTO #tmpParametrosReporte
				(NumVersion, ClaUbicacion, ClaCliente, Diametro, NombreCliente,
				IdCertificado, NomUnidad, Observaciones, cultureName, ClaIdioma,
				Colada, DiamMM, IdFactura)
			EXEC OPCSch.OPCObtenerReporteCertificadoCalidadAlambronProc
				@pnClaUbicacion = @pnClaUbicacion,
				@pnIdPlanCarga = @pnIdPlanCargaFact,
				@psIdioma = @psIdioma
		END
	
		INSERT INTO #reportes
			(ClaFormatoImpresion, NombreReporte, NumVersion, ClaUbicacion, ClaCliente,
			Diametro, NombreCliente, IdCertificado, NomUnidad, Observaciones,
			cultureName, ClaIdioma, Colada, DiamMM, IdFactura, 
			EsExportarPDF, OmitirImpresion)	
		SELECT 32, 'OPE_CU70_Pag1_Rpt_CertAlambron', NumVersion, ClaUbicacion, ClaCliente,
			Diametro, NombreCliente, IdCertificado, NomUnidad, Observaciones,
			cultureName, ClaIdioma, Colada, DiamMM, IdFactura, 
			@nEsExportarPDF, 1
		FROM #tmpParametrosReporte
	END

	--IMPRESION DE CERTIFICADOS ABC.
	--Se verifica que este prendida la configuracion.
	IF((SELECT nValor1
		FROM OPESch.TiCatConfiguracionVw WITH(NOLOCK)
		WHERE ClaUbicacion = @pnClaUbicacion
			AND ClaSistema = 127
			AND ClaConfiguracion = 1271096
			AND BajaLogica = 0) = 1)
	BEGIN
		--Si el formato esta configurado para que se imprima.
		IF EXISTS(SELECT 1
				FROM #tmpCfgMotivoFormatoImp
				WHERE ClaFormatoImpresion = 33)
		BEGIN
			INSERT INTO #tmpCertificadoABC
				(ClaFormatoImpresion, NombreReporte, ClaUbicacion, IdFactura, IdCertificadoR,
				IdCertificado, ClaIdiomaR, FechaGeneracion)	
			EXEC OPESch.OPEObtenerCertificadoABCProc
				@pnClaUbicacion = @pnClaUbicacion,
				@pnIdPlanCarga = @pnIdPlanCargaFact,
				@pnClaUsuarioMod = 1,
				@psNombrePcMod = @psNombrePcMod

			INSERT INTO #reportes
				(ClaFormatoImpresion, NombreReporte, ClaUbicacion, IdFactura, IdCertificadoR,
				IdCertificado, ClaIdiomaR)	
			SELECT ClaFormatoImpresion, NombreReporte, ClaUbicacion, IdFactura, IdCertificadoR,
				IdCertificado, ClaIdiomaR
			FROM #tmpCertificadoABC
							
			UPDATE #reportes
			SET pnClaUbicacion = ClaUbicacion,
				EsLandscape = 1,
				EsExportarPDF = @nEsExportarPDF
			WHERE ClaFormatoImpresion = 33
		END
	END

	IF(@pnEsValidarDigitalizacion = 1 
		/*Si el fomato esta configurado para que se imprima ya sea en la salida o en la facturacion*/
		AND (SELECT COUNT(1)
		FROM OpeSch.OpeCfgMotivoFormatoImp A WITH(NOLOCK)
		LEFT JOIN OpeSch.OpeCatFormatoImpresion B WITH(NOLOCK) ON
			  B.ClaFormatoImpresion = A.ClaFormatoImpresion
		WHERE A.ClaUbicacion = @pnClaUbicacion
				AND A.ClaMotivoEntrada = @pnClaMotivoEntrada
				AND A.BajaLogica = 0
				AND (ISNULL(A.EsRequeridoAlFacturar, 0) = 1 OR ISNULL(A.EsRequeridoEnSalida, 0) = 1)
				AND A.NoCopias > 0 
				AND A.ClaFormatoImpresion = 33) > 0
		/*Si esta prendida la configuracion de digitalizacion*/
		AND @nEsExportarPDF = 1
		/*Solo si no se va a imprimir*/
		AND (SELECT COUNT(1)
				FROM #reportes
				WHERE ClaFormatoImpresion = 33) = 0)
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
			  A.NoCopias > 0 AND
			  A.ClaFormatoImpresion = 33
	
		IF((SELECT COUNT(1)
			FROM #tmpCertificadoABC) = 0)
		BEGIN		
			INSERT INTO #tmpCertificadoABC
				(ClaFormatoImpresion, NombreReporte, ClaUbicacion, IdFactura, IdCertificadoR,
				IdCertificado, ClaIdiomaR, FechaGeneracion)	
			EXEC OPESch.OPEObtenerCertificadoABCProc
				@pnClaUbicacion = @pnClaUbicacion,
				@pnIdPlanCarga = @pnIdPlanCargaFact,
				@pnClaUsuarioMod = 1,
				@psNombrePcMod = @psNombrePcMod
		END
	
		INSERT INTO #reportes
			(ClaFormatoImpresion, NombreReporte, ClaUbicacion, IdFactura, IdCertificadoR,
			IdCertificado, ClaIdiomaR, OmitirImpresion)	
		SELECT ClaFormatoImpresion, NombreReporte, ClaUbicacion, IdFactura, IdCertificadoR,
			IdCertificado, ClaIdiomaR, 1
		FROM #tmpCertificadoABC

		UPDATE #reportes
		SET pnClaUbicacion = ClaUbicacion,
			EsLandscape = 1,
			EsExportarPDF = @nEsExportarPDF
		WHERE ClaFormatoImpresion = 33		
	END
		
	--Impresion de facturas. Nueva forma a traves de Reporting Services.
	IF EXISTS(SELECT 1
				FROM #tmpCfgMotivoFormatoImp
				WHERE ClaFormatoImpresion IN (18,19,20,21,22,23))
	BEGIN
		INSERT INTO #tmpFabricacionFactura
			(ClaFormatoImpresion, 
			IdFabricacion, 
			EsNacional, 
			NoCopias,
			idFactura)
		SELECT A.ClaFormatoImpresion,
			B.IdFabricacion,
			(CASE WHEN C.ClaPais = 1 THEN 1 ELSE 0 END),
			A.NoCopias, b.idFactura
		FROM #tmpCfgMotivoFormatoImp A
		LEFT JOIN OpeSch.OpeTraMovEntSal B WITH(NOLOCK) ON 
			B.ClaUbicacion = @pnClaUbicacion AND 
			B.IdViaje = @nIdViaje
		LEFT JOIN OpeSch.OpeTraViaje C WITH(NOLOCK) ON 
			C.ClaUbicacion = B.ClaUbicacion AND 
			C.IdViaje = B.IdViaje
		WHERE ClaFormatoImpresion IN (18,19,20,21,22,23)
		AND B.IdFactura IS NOT NULL
		
		SET @nIndice1 = (SELECT MIN(Indice) 
						 FROM #tmpFabricacionFactura)

		WHILE(@nIndice1 IS NOT NULL)
		BEGIN
			--SET @nNoCopias = 0
			
			--SELECT @nNoCopias = NoCopias 
			--FROM #tmpFabricacionFactura 
			--WHERE Indice = @nIndice1

			--WHILE(@nNoCopias >= 1)
			--BEGIN
			--	INSERT INTO #reportes(ClaFormatoImpresion, NombreReporte, ClaFactura, RemisionSN, EnPlanta, CopiaTranspSN, ClaViaje, ClaFabricacion)
			--	SELECT ClaFormatoImpresion,
			--		NombreReporte = (CASE WHEN EsNacional = 1 THEN 'OPE_CU71_Pag1_Rpt_RemisionNacional' ELSE 'OPE_CU71_Pag1_Rpt_RemisionExportacion' END),
			--		ClaFactura = NULL,
			--		RemisionSN = 1,
			--		EnPlanta = 1,
			--		CopiaTranspSN = 0,
			--		ClaViaje = @nIdViaje, 
			--		ClaFabricacion = IdFabricacion
			--	FROM #tmpFabricacionFactura 
			--	WHERE Indice = @nIndice1
			
			--	SET @nNoCopias = (@nNoCopias - 1)
			--END
	
			--SET @nIndice1 = (SELECT MIN(Indice)
			--				   FROM #tmpFabricacionFactura
			--				   WHERE Indice > @nIndice1)


			--EL CODIGO ANTERIOR ES PARA IMPRIMIR TODAS LAS COPIAS DE FACTURAS DE UNA MISMA FABRICACION JUNTAS.
			--EL CODIGO SIGUIENTE ES PARA IMPRIMIR POR JUEGO DE COPIAS, POR EJEMPLO: SALEN TODAS LAS FACTURAS DEL AGENTE JUNTAS, LUEGO
			--SALEN TODAS LAS FACTURAS DEL CLIENTE Y LUEGO TODAS LAS FACTURAS DEL TRANSPORTISTA.
			
			--Si el formato tiene copia por imprimir.					
			INSERT INTO #reportes(ClaFormatoImpresion, NombreReporte, pnClaUbicacion, ClaUbicacion, ClaFactura, RemisionSN, EnPlanta, CopiaTranspSN, ClaViaje, ClaFabricacion, IdFactura)
			SELECT ClaFormatoImpresion,
				NombreReporte = (CASE WHEN EsNacional = 1 THEN 'OPE_CU71_Pag1_Rpt_RemisionNacional' ELSE 'OPE_CU71_Pag1_Rpt_RemisionExportacion' END),
				@pnClaUbicacion,
				@pnClaUbicacion,
				ClaFactura = NULL,
				RemisionSN = 1,
				EnPlanta = (CASE WHEN @pnClaUbicacion = 55 THEN (CASE WHEN EsNacional = 1 THEN 1 ELSE 0 END) ELSE 1 END),
				CopiaTranspSN = 0,
				ClaViaje = @nIdViaje, 
				ClaFabricacion = IdFabricacion,
				IdFactura
			FROM #tmpFabricacionFactura 
			WHERE Indice = @nIndice1 AND 
				NoCopias > 0
			
			--Se resta la copia impresa.
			UPDATE #tmpFabricacionFactura 
			SET NoCopias = (NoCopias - 1) 
			WHERE Indice = @nIndice1
				
			--Siguiente formato.
			SET @nIndice1 = (SELECT MIN(Indice)
							 FROM #tmpFabricacionFactura
							   WHERE Indice > @nIndice1)
			
			--Si ya se recorrio todos los formatos y hay juegos de copias pendientes por imptimir se sigue con el siguiente juego de copias empezando otra vez.
			IF(@nIndice1 IS NULL AND EXISTS(SELECT 1 FROM #tmpFabricacionFactura WHERE NoCopias > 0))
			BEGIN
				--Se vuelve a emepezar.
				SET @nIndice1 = (SELECT MIN(Indice) 
								FROM #tmpFabricacionFactura)
			END
		END
	END
	
	--LVR 
	Update #reportes set pnNumVersion = 1, NumVersion = 1


	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--JAJB 20220318: Ajustar el idioma del certificado segun la configuracion del cliente

	--27:Certificado Calidad Industrial, 32:Certificado Calidad de Alambron, Otras Ubicaciones (su formato de impresion se establece como 27)
	UPDATE t0
	SET t0.cultureName = CASE WHEN t0.cultureName IS NOT NULL AND ISNULL(t2.ClaIdioma,0) <> 0 THEN t2.NomIdiomaCorto ELSE t0.cultureName END,
		t0.ClaIdioma = CASE WHEN t0.ClaIdioma IS NOT NULL AND ISNULL(t2.ClaIdioma,0) <> 0 THEN t2.NomIdiomaCorto ELSE t0.ClaIdioma END
	FROM #reportes t0
	INNER JOIN OpeSch.OpeTraFabricacionVw t1 WITH(NOLOCK) ON t0.IdFabricacion = t1.IdFabricacion  
	INNER JOIN OpeSch.OpeRelCertificadoClienteRel1Vw t2 WITH(NOLOCK) ON t2.ClaUbicacion = @pnClaUbicacion AND t1.ClaCliente = t2.ClaCliente AND t2.BajaLogica = 0 
	AND t0.ClaFormatoImpresion IN (27,32)

	--33:Certificado ABC
	UPDATE t0
	SET t0.ClaIdiomaR = CASE WHEN t0.ClaIdiomaR IS NOT NULL AND ISNULL(t3.ClaIdioma,0) <> 0 THEN t3.ClaIdioma ELSE t0.ClaIdiomaR END
	FROM #reportes t0
	INNER JOIN CPASch.Certificado t1 WITH(NOLOCK) ON t0.ClaUbicacion = t1.ClaUbicacion AND  t0.IdCertificadoR = t1.id_Certificado
	INNER JOIN OpeSch.OpeTraFabricacionVw t2 WITH(NOLOCK) ON t1.cla_pedido = t2.IdFabricacion  
	INNER JOIN OpeSch.OpeRelCertificadoClienteRel1Vw t3 WITH(NOLOCK) ON t3.ClaUbicacion = @pnClaUbicacion AND t2.ClaCliente = t3.ClaCliente AND t3.BajaLogica = 0 
	AND t0.ClaFormatoImpresion IN (33)

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
--- Primer juego de copias (mexicanada): Codigo temporal - lperaza
	--SELECT FINAL
	SELECT t1.*--,t2.NoCopias
	FROM #reportes t1
	INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
		t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
	--WHERE t1.ClaFormatoImpresion in (2,13,10,14,27,20,21,22,23)
	UNION ALL
	SELECT t1.*--,t2.NoCopias
	FROM #reportes t1
	INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
		t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
	WHERE t1.ClaFormatoImpresion Not in (18,19,20,21,22,23) -- las remisiones traen su propio proceso arriba
	and t2.NoCopias > 1 and NoCopias < 1000 -- segundo juego de copias
	UNION ALL
	SELECT t1.*--,t2.NoCopias
	FROM #reportes t1
	INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
		t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
	WHERE t1.ClaFormatoImpresion Not in (18,19,20,21,22,23) -- las remisiones traen su propio proceso arriba
	and t2.NoCopias > 2 and NoCopias < 1000 -- tercer juego de copias
	UNION ALL
	SELECT t1.*--,t2.NoCopias
	FROM #reportes t1
	INNER JOIN #tmpCfgMotivoFormatoImp t2 ON 
		t1.ClaFormatoImpresion = t2.ClaFormatoImpresion
	WHERE t1.ClaFormatoImpresion Not in (18,19,20,21,22,23) -- las remisiones traen su propio proceso arriba
	and t2.NoCopias > 3 and NoCopias < 1000 -- cuarto juego de copias
	ORDER BY orden



	--Impresion de facturas anterior.
	--IF EXISTS(SELECT 1
	--			FROM #tmpCfgMotivoFormatoImp
	--			WHERE ClaFormatoImpresion IN (18,19,20,21,22,23))
	--BEGIN
	--	EXEC OpeSch.OpeImprimeFacturaVentasProc 1, @pnClaUbicacion, @nIdViaje, 0, '', @psNombrePcMod
	--END

	DROP TABLE #tmpCfgMotivoFormatoImp
	DROP TABLE #tmpValidaImpresion
	DROP TABLE #reportes
	DROP TABLE #certenc
	DROP TABLE #certdet
	DROP TABLE #tmpFabricacionFactura
	DROP TABLE #tmpMovEntSalISB
	DROP TABLE #tmpParametrosReporte
	DROP TABLE #tmpCertificadoABC
	DROP TABLE #tmpCertificadoOtrasPlantas

	SET NOCOUNT OFF
END