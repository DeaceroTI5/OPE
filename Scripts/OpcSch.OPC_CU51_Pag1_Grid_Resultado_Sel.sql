USE Operacion
GO
ALTER PROCEDURE OpcSch.OPC_CU51_Pag1_Grid_Resultado_Sel
	@pnClaUbicacion INT,
	@pnIdPlanCargaFiltro INT,
	@pnIdViajeFiltro INT,
	@psNumeroFacturaFiltro VARCHAR(50),
	@psRemision VARCHAR(50),
	@pnIdFabricacionFiltro INT,
	@psNumCarrete VARCHAR(20),
	@psClaveRolloFiltro VARCHAR(20) = '',
	@pnNumCertificado INT,
	@psIdioma VARCHAR(10),
	@pnClaClienteFiltro INT,
	@pnDebug TINYINT = 0
AS 
BEGIN		
	-- exec opcSch.opc_CU51_Pag1_Grid_Resultado_SelHv @pnClaUbicacion=267,@pnIdPlanCargaFiltro=NULL,@pnIdViajeFiltro=NULL,@psNumeroFacturaFiltro='',@psRemision='',@pnIdFabricacionFiltro=NULL,@psNumCarrete='',@psClaveRolloFiltro='C03-0424',@pnNumCertificado=NULL,@psIdioma='Spanish',@pnClaClienteFiltro=NULL, @pnDebug = 0
	-- exec opcSch.opc_CU51_Pag1_Grid_Resultado_SelHv @pnClaUbicacion=267,@pnIdPlanCargaFiltro=NULL,@pnIdViajeFiltro=NULL,@psNumeroFacturaFiltro='',@psRemision='',@pnIdFabricacionFiltro=NULL,@psNumCarrete='',@psClaveRolloFiltro='',@pnNumCertificado=1,@psIdioma='Spanish',@pnClaClienteFiltro=NULL, @pnDebug = 0
    
	SET NOCOUNT ON
    
    IF @pnIdPlanCargaFiltro IS NULL
		AND @pnIdViajeFiltro IS NULL
		AND ISNULL(@psNumeroFacturaFiltro,'') = ''
		AND ISNULL(@psRemision,'') = ''
		AND @pnIdFabricacionFiltro IS NULL
		AND ISNULL(@psNumCarrete,'') = ''
		AND	ISNULL(@psClaveRolloFiltro,'') = ''
		AND @pnNumCertificado IS NULL
		AND @pnClaClienteFiltro IS NULL
	BEGIN
		RAISERROR('Favor de proporcionar al menos uno de los filtros',16,1)
		RETURN -1
	END
    
	SET @pnIdPlanCargaFiltro		=	ISNULL(@pnIdPlanCargaFiltro,-1)
	SET @pnIdViajeFiltro			=	ISNULL(@pnIdViajeFiltro,-1)
	SET @pnIdFabricacionFiltro	=	ISNULL(@pnIdFabricacionFiltro,-1)
	SET @psNumCarrete		=	ISNULL(@psNumCarrete,'')
	SET @pnNumCertificado	=	ISNULL(@pnNumCertificado,-1)
	SET @pnClaClienteFiltro		=	ISNULL(@pnClaClienteFiltro, 0)
	SET @psClaveRolloFiltro		= ISNULL(@psClaveRolloFiltro,'')

 
	DECLARE @sNomIsoIdiomaIngles varchar(2) 
	DECLARE	@sNomIsoIdiomaOtro varchar(2)
	declare @sRemisionCad varchar(50)
 
	--inicio CR Factura Remision
	DECLARE	@nFolio INT, @sFolio VARCHAR(50), @sSerie VARCHAR(5), @sPrefijo VARCHAR(50), @sRemNum VARCHAR(50)--,@nPrefijoNum INT
	DECLARE	@sChar VARCHAR(1), @nCont INT
 
	DECLARE @tCertificado TABLE(
			ClaUbicacion INT,
			PDF varchar(50),
			IdPlanCarga int,
			IdViaje int,
			IdFabricacion int,
			IdCertificado int,
			ClaArticulo int,
			ClaveArticulo varchar(20),
			NomArticulo varchar(500),
			KgsSurtidos numeric(12,4),
			KgsCertific numeric(12,4),
			ClaCliente int,
			NombreCliente varchar(200),
			NombreCiudad varchar(40),
			NumeroFactura varchar(20),
			ClaUnidad int,
			Factura varchar(20),
			Remision varchar(20)			
			)
	DECLARE @tCertificadoRolloCarrete table(			
			IdCertificado INT)
 
	SET @psNumeroFacturaFiltro= LTRIM(RTRIM(ISNULL(@psNumeroFacturaFiltro, '')))
	SET @psRemision		= LTRIM(RTRIM(ISNULL(@psRemision, '')))
 
	------- Obtener Serie y Folio de @psNumeroFacturaFiltro
	SELECT	@nCont = 1
	-- Obtener no numericos
	WHILE	(LEN(@psNumeroFacturaFiltro) >= @nCont)
	BEGIN
		SELECT	@sChar = SUBSTRING(@psNumeroFacturaFiltro, @nCont, 1)
		IF (ISNUMERIC(@sChar) = 0)
				SELECT	@sSerie = ISNULL(@sSerie,'') + @sChar
		ELSE
		BEGIN
				SELECT	@psNumeroFacturaFiltro = SUBSTRING(@psNumeroFacturaFiltro, @nCont, LEN(@psNumeroFacturaFiltro))
				SELECT	@nCont = 1
				SELECT	@sSerie = NULLIF(@sSerie,'')
				BREAK
		END
		SELECT	@nCont = @nCont + 1
	END
	-- Obtener numericos
	WHILE	(LEN(@psNumeroFacturaFiltro) >= @nCont)
	BEGIN
		SELECT	@sChar = SUBSTRING(@psNumeroFacturaFiltro, @nCont, 1)
		IF (ISNUMERIC(@sChar) = 1)
				SELECT	@sFolio = ISNULL(@sFolio,'') + @sChar
		ELSE
				BREAK
		SELECT	@nCont = @nCont + 1
	END
 
	BEGIN TRY
	SELECT	@nFolio = NULLIF(CONVERT(INT, ISNULL(@sFolio,0)),0)
	END TRY
	BEGIN CATCH
		SELECT	@nFolio = -1
	END CATCH
 
	IF @psRemision <> ''
	BEGIN
		------- Obtener Prefijo de @psRemision
		SELECT	@nCont = 1
		-- Obtener no numericos
		WHILE	(LEN(@psRemision) >= @nCont)
		BEGIN
			SELECT	@sChar = SUBSTRING(@psRemision, @nCont, 1)
			IF (ISNUMERIC(@sChar) = 0)
					SELECT	@sPrefijo = ISNULL(@sPrefijo,'') + @sChar
			ELSE
					BREAK
			SELECT	@nCont = @nCont + 1
		END
		SELECT	@sRemisionCad = SUBSTRING(@psRemision, @nCont, LEN(@psRemision))
		SELECT	@nCont = 1
		SELECT	@sPrefijo = NULLIF(@sPrefijo,'')
		-- Obtener numericos
		WHILE	(LEN(@sRemisionCad) >= @nCont)
		BEGIN
			SELECT	@sChar = SUBSTRING(@sRemisionCad, @nCont, 1)
			IF (ISNUMERIC(@sChar) = 0)
					BREAK
			SELECT	@nCont = @nCont + 1
		END
		SELECT	@sRemNum = SUBSTRING(@sRemisionCad, 1, @nCont-1)
 
		-- Reacomodar el numero de remision buscando prefijo
		SELECT	TOP 1 @sRemNum = ISNULL(CONVERT(VARCHAR,PrefijoNum),'') + ISNULL(@sRemNum,'')--@nPrefijoNum = PrefijoNum
		FROM	OpcSch.OpcVtaCatPrefijoVw
		WHERE	PrefijoStr = @sPrefijo
				AND ClaPlanta = @pnClaUbicacion
	
		SELECT	@sRemNum = ISNULL(NULLIF(@sRemNum,''), '-1')
	END
 
	BEGIN TRY
		SELECT	@sRemNum = NULLIF(CONVERT(INT, ISNULL(@sRemNum,0)),0)	
	END TRY
	BEGIN CATCH
		SELECT	@sRemNum = -1
	END CATCH
	--fin CR Factura Remision
 
	
	INSERT INTO @tCertificado
	SELECT	certif.ClaUbicacion,
			'Guardar PDF' [PDF],
			certif.IdPlanCarga,
			certif.IdViaje,
			certif.IdFabricacion,
			certif.IdCertificado,
			certif.ClaArticulo,
			art.ClaveArticulo,
			art.ClaveArticulo + ' - ' +(CASE
				WHEN @psIdioma = 'Spanish' THEN art.NomArticulo
				WHEN @psIdioma = 'English' THEN art.NomArticuloIngles
				ELSE art.NomArticuloOtroIdioma 
			END) AS NomArticulo,
			certif.KgsTotal as KgsSurtidos,
			certif.KgsTotal as KgsCertific,
			certif.ClaCliente,
			cte.NombreCliente,
			cd.NombreCiudad,
			isnull(certif.NumeroFactura,certif.idEntsal) as NumeroFactura,
			art.ClaUnidadBase as ClaUnidad,
			ISNULL(LTRIM(RTRIM(certif.Serie)),'') + ISNULL(CONVERT(VARCHAR(20),Folio), '')  AS Factura,
			isnull(certif.NumeroFactura,certif.idEntsal) as Remision
	FROM	OPCSch.OPCTraCertificado certif WITH(NOLOCK)
	INNER	JOIN OPCSch.OPCArtCatArticuloVw art WITH(NOLOCK) ON
			art.ClaArticulo=certif.ClaArticulo 
			AND art.ClaTipoInventario=1
	LEFT	JOIN OpcSch.OpcVtaCatClienteVw cte WITH(NOLOCK) ON
			cte.ClaCliente=certif.ClaCliente
	LEFT	JOIN OpcSch.OpcVtaCatCiudadVw cd WITH(NOLOCK) ON 
			cd.ClaCiudad=certif.ClaCiudad	
	WHERE	certif.ClaUbicacion	= @pnClaUbicacion 
			AND (@pnIdPlanCargaFiltro <= 0 OR (@pnIdPlanCargaFiltro > 0	AND certif.IdPlanCarga = @pnIdPlanCargaFiltro)) 
			AND (@pnIdViajeFiltro <= 0 OR (@pnIdViajeFiltro > 0 AND certif.IdViaje = @pnIdViajeFiltro)) 
			AND (@sSerie IS NULL OR certif.Serie = @sSerie) 
			AND (@nFolio IS NULL OR certif.Folio = @nFolio) 
			AND (@psRemision = '' OR certif.NumeroFactura = @psRemision)			
			AND (@pnIdFabricacionFiltro <= 0 OR (@pnIdFabricacionFiltro > 0 AND certif.IdFabricacion = @pnIdFabricacionFiltro)) 
			AND (@pnNumCertificado <=0 OR (@pnNumCertificado > 0 AND certif.IdCertificado = @pnNumCertificado))			
			AND	certif.IdCertificado > 0
			AND (@pnClaClienteFiltro  = 0 OR certif.ClaCliente = @pnClaClienteFiltro) 
			AND certif.BajaLogica = 0
 
	IF @psNumCarrete = '' AND @psClaveRolloFiltro = ''
		SELECT	*
		FROM	@tCertificado
		ORDER BY IdPlanCarga, IdViaje, IdFabricacion, IdCertificado
	ELSE
	BEGIN
		IF @psNumCarrete <> '' 
		BEGIN
			INSERT 	INTO @tCertificadoRolloCarrete 
			SELECT  Distinct IdCertificado
			FROM 	OPCSch.OPCTraRollo WITH(NOLOCK)
			WHERE	NumCarrete = @psNumCarrete
		END

		IF @psClaveRolloFiltro <> ''
		BEGIN
			INSERT 	INTO @tCertificadoRolloCarrete 
			SELECT  Distinct IdCertificado
			FROM 	OPCSch.OPCTraRollo WITH(NOLOCK)
			WHERE	ClaUbicacion = @pnClaUbicacion
			AND		ClaveRollo = @psClaveRolloFiltro
		END

		IF @pnDebug = 1
		BEGIN
			SELECT '@tCertificado', * FROM @tCertificado
			SELECT '@tCertificadoRolloCarrete', * FROM @tCertificadoRolloCarrete 
		END


		SELECT	*
		FROM	@tCertificado AS tCertificado
		INNER 	JOIN @tCertificadoRolloCarrete  AS tCertificadoCarrete
			ON	tCertificadoCarrete.IdCertificado = tCertificado.IdCertificado
	END
 
	SET NOCOUNT OFF
END

