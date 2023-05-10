ALTER PROCEDURE OpeSch.OPE_CU444_Pag44_Boton_LOAD_Proc
	@pnClaUbicacion		INT,
	@pnClaUsuarioMod 	INT = NULL
AS
BEGIN

	DECLARE @tDate DATETIME
	DECLARE @tmpInfoFacturacionExterna TABLE (Correo VARCHAR(500),ClaUbicacionUs INT, EsFacturacionExterna INT)

	INSERT INTO @tmpInfoFacturacionExterna (Correo,ClaUbicacionUs, EsFacturacionExterna)
	SELECT Correo,ClaUbicacionUs,EsFacturacionExterna FROM OPESch.OPE_CU444_Pag44_DatosUsuarioFacturacionExternaFn(@pnClaUsuarioMod,@pnClaUbicacion)
	
	SELECT @tDate = CONVERT(VARCHAR, GETDATE(),112)


	------------------------------------
	DECLARE	  @nUbicacionSumDir			INT
   			, @nClaTransportistaDefault INT = NULL

    SELECT  @nUbicacionSumDir = ISNULL(nValor1,0)
    FROM    OpeSch.OpeTiCatConfiguracionVw
    WHERE   ClaUbicacion = @pnClaUbicacion
    AND     ClaSistema = 127
    AND     ClaConfiguracion = 1271224

    IF ISNULL(@nUbicacionSumDir, 0) = 1
		SELECT @nClaTransportistaDefault = 99999
	ELSE
		SELECT @nClaTransportistaDefault = NULL
	------------------------------------

	SELECT	FechaDesde = DATEADD(MM, -1, @tDate),
			FechaHasta = @tDate,
			Correo = tmp.Correo,
			ClaUbicacionUs = tmp.ClaUbicacionUs,
			EsFacturacionExterna = tmp.EsFacturacionExterna,
			ClaTransportistaDefault = @nClaTransportistaDefault
	FROM	@tmpInfoFacturacionExterna tmp

END