USE Operacion
GO
-- 'OPESch.OpeImpresionCertificadoMultiSel'
GO
ALTER PROCEDURE OPESch.OpeImpresionCertificadoMultiSel
	@pnNumVersion		INT,
	@pnClaUbicacion		INT,
	@pnIdCertificado	INT,
	@psClaIdioma		VARCHAR(10),
	@pnEsEncabezado		TINYINT,
	@pnEsVistaPrevia	TINYINT,
	@psClienteDesc		VARCHAR(100) = NULL,
	@pnCantidad			NUMERIC(22,2) = NULL,
	@psNomUnidad		VARCHAR(20) = NULL,
	@psFactura			VARCHAR(20) = NULL,
	@pnIdOpm			INT,
	@psClaveRollo		VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE	@nClaIdioma INT
	DECLARE @nClaDepartamento INT
	DECLARE @nClaUsuario1 INT
	DECLARE @bFirmaUsuario1 VARBINARY(MAX)
	DECLARE @sNombreUsuario1 VARCHAR(100)
	DECLARE @sPuestoUsuario1 VARCHAR(250)
	DECLARE @bFirmaUsuario2 VARBINARY(MAX)
	DECLARE @sNombreUsuario2 VARCHAR(100)
	DECLARE @sPuestoUsuario2 VARCHAR(250)
	DECLARE @nUbicacionIndustrial INT
	DECLARE @sNombreUbicacion VARCHAR(400)
	DECLARE	@sNormaISO	VARCHAR(200)
	DECLARE @nMuestraLogDeaVerde INT,
			@sRutaLogo			VARCHAR(300),
			@nMuestraLogCIM		INT
			
	DECLARE @NombresCaracteristicas TABLE
	(
		ClaArticulo			INT,
		ClaFamilia			INT,
		ClaSubFamilia		INT,
		ClaCaracteristica	INT,
		ClaValor			INT,
		NomValor			VARCHAR(250)
	)
 
	IF (ISNULL(@psClaIdioma, '') = 'es-MX')
	BEGIN
		SELECT @nClaIdioma = 5
	END
	ELSE IF (ISNULL(@psClaIdioma, '') = 'en-US')
	BEGIN
		SELECT @nClaIdioma = 0
	END
	
	SELECT	@sNormaISO = UPPER(CASE WHEN @psClaIdioma = 'es-MX' THEN sValor1 ELSE sValor2 END)
	FROM	OpeSch.OpeTiCatConfiguracionVw
	WHERE	ClaUbicacion = @pnClaUbicacion
	AND		ClaSistema = 246
	AND		ClaConfiguracion = 246131
	
	SELECT	@sNombreUbicacion = (CASE WHEN @nClaIdioma = 0 THEN sValor2 ELSE sValor1 END) 
	FROM	OpeSch.OpeTiCatConfiguracionVw WITH(NOLOCK) 
	WHERE	ClaUbicacion = @pnClaUbicacion 
	AND		ClaSistema = 127 
	AND		ClaConfiguracion = 1270206
	
	SET		@nMuestraLogDeaVerde = OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271021, 1)	
	SELECT	@nMuestraLogDeaVerde = ISNULL(@nMuestraLogDeaVerde,0)
 
 	SET		@nMuestraLogCIM			= OpeSch.OpeObtenerConfigNumericaFn(@pnClaUbicacion, 1271022, 1)

	SELECT	@nClaIdioma = ISNULL(@nClaIdioma, 5)
	
	IF (@pnEsEncabezado = 1)
	BEGIN
		INSERT	INTO @NombresCaracteristicas
		SELECT	Cert.ClaArticulo,
				art.ClaFamilia,
				art.ClaSubFamilia,
				artVal.ClaCaracteristica,
				artCalVal.ClaValor,
				artCalVal.NomValor 
		FROM	OpeSch.OpeOpcTraCertificadoVw Cert (NOLOCK)
		LEFT JOIN OpeSch.OpeArtCatArticuloVw art 
		ON		Art.ClatipoInventario = 1
		AND		art.claArticulo = Cert.ClaArticulo
		INNER JOIN OpeSch.OpeArtRelArticuloCarValorVw artVal 
		ON		artVal.ClaArticulo = Cert.ClaArticulo 
		INNER JOIN OpeSch.OpeArtCatValorVw artCalVal 
		ON		artCalVal.ClaValor =  artVal.ClaValor 
		And		artCalVal.ClaCaracteristica =  artVal.ClaCaracteristica 
		And		artCalVal.ClaTipoInventario = 1
		WHERE	Cert.ClaUbicacion = @pnClaUbicacion 
		AND		Cert.IdCertificado = @pnIdCertificado
 
 
		SELECT	C.IdCertificado,
				RTRIM(@sNombreUbicacion) AS NombreUbicacion,
				CONVERT(VARCHAR(10), GETDATE(), 103) AS Fecha,
				C.ClaCliente,
				A.ClaveArticulo,
				CONVERT(VARCHAR, CAST(CASE @pnEsVistaPrevia WHEN 1 THEN @pnCantidad ELSE C.KgsTotal END AS MONEY), 1) + '  ' +
					CASE @pnEsVistaPrevia WHEN 1 THEN @psNomUnidad ELSE 'Kg' END AS Cantidad,
				CASE @pnEsVistaPrevia WHEN 1 THEN @psNomUnidad ELSE 'Kg' END AS NomUnidad,
				C.IdPlanCarga,
				C.IdViaje,
				CASE @pnEsVistaPrevia WHEN 1 THEN @psFactura ELSE C.NumeroFactura END AS Factura,
				CASE @pnEsVistaPrevia WHEN 1 THEN @psClienteDesc ELSE V.NombreCliente END AS NombreCliente,
				R.NumCarrete,
				CarAcabado.NomValor AS Acabado,
				CASE WHEN OpeSch.IsReallyNumeric(CPR.Valor) = 1 THEN CONVERT(INT, CONVERT(NUMERIC(22,4), CPR.Valor)) ELSE  CPR.Valor END AS CEM,--CP.CEM,
				CarCons.NomValor  AS Construccion,
				CarDiametro.NomValor AS Diametro,
				CarEspecificacion.NomValor AS Especificacion,
				CarGrado.NomValor AS Grado,
				CarLongitudTotal.NomValor AS LongitudTotal,
				CarTempMaxTrabajo.NomValor AS TempMaxTrabajo,
				CarTipoAislante.NomValor AS TipoAislante,
				CarTipoAlma.NomValor AS TipoAlma,
				CarTipoArmadura.NomValor AS TipoArmadura,
				CarTorcido.NomValor AS Torcido,
				CarTipoCable.NomValor AS TipoCable,
				C.IdFabricacion
		FROM	OpeSch.OpeOpcTraCertificadoVw C WITH(NOLOCK)
		INNER	JOIN OpeSch.OpeTiCatUbicacionVw U WITH(NOLOCK)
		ON		C.ClaUbicacionIndustrial = U.ClaUbicacion		
		INNER	JOIN OpeSch.OpeArtCatArticuloVw A WITH(NOLOCK)
		ON		C.ClaArticulo = A.ClaArticulo
		AND		A.ClaTipoInventario = 1
		INNER JOIN OpeSch.OpeOpcTraRolloVw R WITH(NOLOCK)
		ON		R.ClaUbicacion = C.ClaUbicacion
		AND		R.IdOPM = @pnIdOpm
		AND		R.ClaveRollo = @psClaveRollo
		LEFT JOIN OpeSch.OpeOpcCatConceptosCableFamiliaVw AS ptccp	WITH(NOLOCK) 
		ON		ptccp.ClaUbicacion = C.ClaUbicacion
		AND		ptccp.ClaFamilia = A.ClaFamilia 
		LEFT JOIN @NombresCaracteristicas CarEspecificacion  ON CarEspecificacion.ClaCaracteristica = ptccp.Especificacion 
		LEFT JOIN @NombresCaracteristicas CarDiametro		 ON CarDiametro.ClaCaracteristica = ptccp.Diametro 
		LEFT JOIN @NombresCaracteristicas CarLongitudTotal	 ON CarLongitudTotal.ClaCaracteristica = ptccp.LongitudTotal
		LEFT JOIN @NombresCaracteristicas CarTipoCable		 ON CarTipoCable.ClaCaracteristica = ptccp.TipoCable
		LEFT JOIN @NombresCaracteristicas CarCons			 ON CarCons.ClaCaracteristica = ptccp.Construccion 
		LEFT JOIN @NombresCaracteristicas CarGrado			 ON CarGrado.ClaCaracteristica = ptccp.Grado 
		LEFT JOIN @NombresCaracteristicas CarTipoAlma		 ON CarTipoAlma.ClaCaracteristica = ptccp.TipoAlma
		LEFT JOIN @NombresCaracteristicas CarTorcido		 ON CarTorcido.ClaCaracteristica = ptccp.Torcido
		LEFT JOIN @NombresCaracteristicas CarAcabado		 ON CarAcabado.ClaCaracteristica = ptccp.Acabado
		LEFT JOIN @NombresCaracteristicas CarTipoArmadura	 ON CarTipoArmadura.ClaCaracteristica = ptccp.TipoArmadura
		LEFT JOIN @NombresCaracteristicas CarLubricacion	 ON CarLubricacion.ClaCaracteristica = ptccp.Lubricacion
		LEFT JOIN @NombresCaracteristicas CarCasquillo	     ON CarCasquillo.ClaCaracteristica = ptccp.Casquillo 
		LEFT JOIN @NombresCaracteristicas CarArgolla	     ON CarArgolla.ClaCaracteristica = ptccp.Argolla
		LEFT JOIN @NombresCaracteristicas CarOjos	         ON CarOjos.ClaCaracteristica = ptccp.Ojos 
		LEFT JOIN @NombresCaracteristicas CarGuardacaboStd	 ON CarGuardacaboStd.ClaCaracteristica = ptccp.GuardacaboStd 
		LEFT JOIN @NombresCaracteristicas CarGuardacaboRef	 ON CarGuardacaboRef.ClaCaracteristica = ptccp.GuardacaboRef 
		LEFT JOIN @NombresCaracteristicas CarGanchoOjoFijo	 ON CarGanchoOjoFijo.ClaCaracteristica = ptccp.GanchoOjoFijo 
		LEFT JOIN @NombresCaracteristicas CarGanchoCorredizo ON CarGanchoCorredizo.ClaCaracteristica = ptccp.GanchoCorredizo
		LEFT JOIN @NombresCaracteristicas CarGanchoGiratorio ON CarGanchoGiratorio.ClaCaracteristica = ptccp.GanchoGiratorio
		LEFT JOIN @NombresCaracteristicas CarSeguros	     ON CarSeguros.ClaCaracteristica = ptccp.Seguros 
		LEFT JOIN @NombresCaracteristicas CarEslabonEslinga	 ON CarEslabonEslinga.ClaCaracteristica = ptccp.EslabonEslinga 
		LEFT JOIN @NombresCaracteristicas CarEslabonPera	 ON CarEslabonPera.ClaCaracteristica = ptccp.EslabonPera 
		LEFT JOIN @NombresCaracteristicas CarTipoAislante	 ON CarTipoAislante.ClaCaracteristica = ptccp.TipoAislante
		LEFT JOIN @NombresCaracteristicas CarTempMaxTrabajo	 ON CarTempMaxTrabajo.ClaCaracteristica = ptccp.TempMaxTrabajo
		LEFT JOIN OpeSch.OpeOpcTraCertificadoPruebaRolloVw CPR WITH(NOLOCK)
		ON		CPR.ClaUbicacion = C.ClaUbicacion
		AND		CPR.IdCertificado = C.IdCertificado
		AND		CPR.IdOpm = R.IdOpm
		AND		CPR.ClaveRollo = R.ClaveRollo
		AND		CPR.ClaConceptoLaboratorio = ptccp.CEM		
		LEFT JOIN OpeSch.OpeVtaCatClienteVw V WITH(NOLOCK)
		ON		C.ClaCliente = V.ClaCliente
		WHERE	C.ClaUbicacion = @pnClaUbicacion
		AND		C.IdCertificado = @pnIdCertificado
	END
	ELSE
	BEGIN
		--*Obtener las firmas de los usuarios configurados para el departamento
		SELECT	@nClaDepartamento = ClaDepartamento, @nUbicacionIndustrial = ClaUbicacionIndustrial
		FROM	OpeSch.OpeOpcTraCertificadoVw WITH (NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion
		AND		IdCertificado = @pnIdCertificado


		SELECT	@sRutaLogo = sValor1
		FROM	OpeSch.OpeTiCatConfiguracionVw
		WHERE	ClaUbicacion = @pnClaUbicacion
		AND		ClaSistema = 127
		AND		ClaConfiguracion = 1271235

		/*
		Logo_Deacero.png		-- Logo DeaAcero fondo Negro
		Logo_Deacero2.png		-- Logo DeaAcero fondo Blanco
		Logo_DeaceroSummit.png	-- Logo Summit
		*/

		IF @pnClaUbicacion = 300
			SET @sRutaLogo = @sRutaLogo + 'Logo_DeaceroSummit.png'
		ELSE
			SET @sRutaLogo = @sRutaLogo + 'Logo_Deacero2.png'
		
		--*Obtener el primer usuario de firmas
		SELECT	TOP 1
				@nClaUsuario1 = F.ClaUsuario,
				@bFirmaUsuario1 = F.Firma,
				@sNombreUsuario1 = RTRIM(U.NombreUsuario) + ' ' + RTRIM(U.ApellidoPaterno) + ' ' + RTRIM(U.ApellidoMaterno),
				@sPuestoUsuario1 = CASE @nClaIdioma WHEN 5 THEN F.PuestoDesc ELSE F.PuestoDescIngles END
		FROM	OpeSch.OpeOpcCatFirmasCertificadosVw F WITH(NOLOCK)
		INNER	JOIN OpeSch.OpeManCatDepartamentoVw D WITH(NOLOCK) ON D.ClaDepartamento = F.ClaDepartamento
		INNER	JOIN OpeSch.OpeTiCatUsuarioVw U WITH (NOLOCK) ON F.ClaUsuario = U.ClaUsuario
		WHERE	F.ClaUbicacion = @nUbicacionIndustrial
		AND		F.ClaDepartamento = @nClaDepartamento
		AND		D.BajaLogica = 0
		AND		F.BajaLogica = 0  
		AND		U.BajaLogica = 0
		ORDER	BY F.IdCertificadoUsuarioFirma
		
		--*Obtener el segundo usuario de firmas
		SELECT	@bFirmaUsuario2 = F.Firma,
				@sNombreUsuario2 = RTRIM(U.NombreUsuario) + ' ' + RTRIM(U.ApellidoPaterno) + ' ' + RTRIM(U.ApellidoMaterno),
				@sPuestoUsuario2 = CASE @nClaIdioma WHEN 5 THEN F.PuestoDesc ELSE F.PuestoDescIngles END
		FROM	OpeSch.OpeOpcCatFirmasCertificadosVw F WITH(NOLOCK)
		INNER	JOIN OpeSch.OpeManCatDepartamentoVw D WITH(NOLOCK) ON D.ClaDepartamento = F.ClaDepartamento
		INNER	JOIN OpeSch.OpeTiCatUsuarioVw U WITH(NOLOCK) ON F.ClaUsuario = U.ClaUsuario
		WHERE	F.ClaUbicacion = @nUbicacionIndustrial
		AND		F.ClaDepartamento = @nClaDepartamento
		AND		F.ClaUsuario != @nClaUsuario1
		AND		D.BajaLogica = 0
		AND		F.BajaLogica = 0  
		AND		U.BajaLogica = 0
		ORDER	BY F.IdCertificadoUsuarioFirma

		DECLARE  @sNombreUbicacionH VARCHAR(50)
				,@sDireccion1		VARCHAR(300)
				,@sDireccion2		VARCHAR(300)
		
		--*Regresar informacion del footer del reporte
		SELECT	@sNombreUbicacionH = 'DEACERO S.A.P.I. DE C.V. ' + RTRIM(@sNombreUbicacion), -- AS NombreUbicacion,
				@sDireccion1 = RTRIM(U.Direccion) + ' ' +
					RTRIM(U.Colonia) + ' ' +
					CASE @nClaIdioma WHEN 5 THEN 'CP. ' ELSE 'ZP. ' END + ISNULL(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(U.CodigoPostal,'CP.',''),'C.P.',''),'CP',''))),'') + ',',
				--	AS Direccion1,
				@sDireccion2 = RTRIM(U.Poblacion) + ' ' +
					CASE @nClaIdioma WHEN 5 THEN 'Tel: ' ELSE 'Ph: ' END + RTRIM(ISNULL(U.Telefonos, '')) +
					CASE LEN(RTRIM(LTRIM(ISNULL(U.Fax, '')))) WHEN 0 THEN '' ELSE ' Fax: ' + RTRIM(LTRIM(U.Fax)) END
				--	AS Direccion2,
		FROM	OpeSch.OpeTiCatUbicacionVw U WITH (NOLOCK)
		WHERE	U.ClaUbicacion = @nUbicacionIndustrial

		SELECT @nMuestraLogCIM = 1, @nMuestraLogDeaVerde = 1

		SELECT	@sNombreUbicacionH AS NombreUbicacion,
				@sDireccion1 AS Direccion1,
				@sDireccion2 AS Direccion2,
				@sNombreUsuario1 AS NombreUsuario1,
				@bFirmaUsuario1 AS FirmaUsuario1,
				@sPuestoUsuario1 AS PuestoUsuario1,
				@sNombreUsuario2 AS NombreUsuario2,
				@bFirmaUsuario2 AS FirmaUsuario2,
				@sPuestoUsuario2 AS PuestoUsuario2,
				@sNormaISO AS NormaISO,
				@nMuestraLogDeaVerde AS MuestraLogDeaVerde,
				@sRutaLogo		AS RutaLogo,
				@nMuestraLogCIM	AS MuestraLogCIM
				
	END
	
	SET NOCOUNT OFF
END