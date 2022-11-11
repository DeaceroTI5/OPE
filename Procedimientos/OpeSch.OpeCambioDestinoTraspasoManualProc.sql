USE Operacion
GO
--- 'OpeSch.OpeCambioDestinoTraspasoManualProc'
GO
ALTER PROCEDURE OpeSch.OpeCambioDestinoTraspasoManualProc
	  @pnClaUbicacion	INT
	, @pnClaPedido		INT = NULL
	, @pnClaUsuarioMod	INT 
	, @psNombrePcMod	VARCHAR(64)
	, @pnDebug			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	--- EXEC OpeSch.OpeCambioDestinoTraspasoManualProc 325, 24271669, 1, 'Prueba Hv', 1

	DECLARE	  @dFechaUltimaMod		DATETIME
			, @dCfgFechaUltimaMod	DATETIME

	
	DECLARE @tbFabricacionCambioPlanta TABLE(
		  Id					INT IDENTITY(1,1)
		, IdFabricacion			INT
		, NumeroRenglon			INT
		, ClaUbicacion			INT
		, IdFabricacionNueva	INT
		, NumeroRenglonNuevo	INT
		, ClaUbicacionNuevo		INT
		, IdPeticion			INT
		, Estatus				INT
		, FechaUltimaMod		DATETIME
		, ClaUsuarioMod			INT
		, NombrePcMod			VARCHAR(64)
		, ClaMotivoCambio		INT
	)

		
	--- /*Asignacion de valor*/
	SELECT	  @dFechaUltimaMod	= GETDATE()
			, @pnDebug			= ISNULL(@pnDebug,0)
	
	--- Configuracion de fecha
	SELECT	@dCfgFechaUltimaMod  = dValor1
	FROM	OpeSch.OPETiCatConfiguracionVw b
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		ClaSistema			= 127 
	AND		ClaConfiguracion	= 1271230

	
	INSERT INTO @tbFabricacionCambioPlanta(
		  IdFabricacion
		, NumeroRenglon
		, ClaUbicacion
		, IdFabricacionNueva
		, NumeroRenglonNuevo
		, ClaUbicacionNuevo
		, IdPeticion
		, Estatus
		, FechaUltimaMod
		, ClaUsuarioMod
		, NombrePcMod
		, ClaMotivoCambio
	)
	SELECT	  a.IdFabricacion
			, a.NumeroRenglon
			, a.ClaUbicacion
			, a.IdFabricacionNueva
			, a.NumeroRenglonNuevo
			, a.ClaUbicacionNuevo
			, a.IdPeticion
			, a.Estatus
			, a.FechaUltimaMod
			, a.ClaUsuarioMod
			, a.NombrePcMod
			, a.ClaMotivoCambio		--(No esta actualizado desarrollo)
	FROM	DEAOFINET05.Ventas.VTASch.VtaTraFabricacionCambioPlanta a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraSolicitudTraspasoEnc b WITH(NOLOCK)
	ON		a.IdFabricacion		= b.ClaPedido
	AND		a.ClaUbicacion		= b.ClaUbicacionSurte
	WHERE	a.Estatus = 3
	AND		a.FechaUltimaMod	> @dCfgFechaUltimaMod
	AND		b.ClaEstatusSolicitud = 1
	AND		(@pnClaPedido IS NULL OR (ClaPedido = @pnClaPedido))


	--UPDATE	a
	--SET		ClaArticulo = b.ClaArticulo
	--FROM	@tbFabricacionCambioPlanta a
	--INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionDetVw b
	--ON		a.IdFabricacion = b.IdFabricacion
	--AND		a.NumeroRenglon	= b.NumeroRenglon


	IF @pnDebug = 1
		SELECT '' AS '@tbFabricacionCambioPlanta', * FROM @tbFabricacionCambioPlanta


	INSERT INTO OpeSch.OpeVtaBitFabricacionCambioPlanta(
		  IdFabricacion
		, NumeroRenglon
		, ClaUbicacion
		, IdFabricacionNueva
		, NumeroRenglonNuevo
		, ClaUbicacionNuevo
		, IdPeticion
		, Estatus
		, FechaUltimaMod
		, ClaUsuarioMod
		, NombrePcMod
		, ClaMotivoCambio
	)
	SELECT	  IdFabricacion
			, NumeroRenglon
			, ClaUbicacion
			, IdFabricacionNueva
			, NumeroRenglonNuevo
			, ClaUbicacionNuevo
			, IdPeticion
			, Estatus
			, FechaUltimaMod
			, ClaUsuarioMod
			, NombrePcMod
			, ClaMotivoCambio
	FROM	@tbFabricacionCambioPlanta



	IF @pnDebug = 1
	BEGIN
		SELECT	  a.IdSolicitudTraspaso, a.ClaPedido, b.IdFabricacionNueva
				, a.ClaUbicacionSurte	, b.ClaUbicacionNuevo , FechaUltimaMod = @dFechaUltimaMod
				, ClaUsuarioMod = @pnClaUsuarioMod, NombrePcMod = @psNombrePcMod
		FROM	OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)
		CROSS APPLY  
					(	SELECT	DISTINCT h.IdFabricacionNueva, h.ClaUbicacionNuevo
						FROM	@tbFabricacionCambioPlanta h
						WHERE	a.ClaPedido		= h.IdFabricacion
					) b
		WHERE	ClaEstatusSolicitud = 1
	--	AND		(@pnClaUbicacion IS NULL OR (ClaUbicacionSurte = @pnClaUbicacion))
	END

	IF @@SERVERNAME <> 'SRVDBDES01\ITKQA'
	BEGIN
		UPDATE	a
		SET		  ClaPedido			= b.IdFabricacionNueva
				, ClaUbicacionSurte	= b.ClaUbicacionNuevo
				, FechaUltimaMod	= @dFechaUltimaMod
				, ClaUsuarioMod		= @pnClaUsuarioMod
				, NombrePcMod		= @psNombrePcMod
		FROM	OpeSch.OpeTraSolicitudTraspasoEncVw a WITH(NOLOCK)
		CROSS APPLY  
					(	SELECT	DISTINCT h.IdFabricacionNueva, h.ClaUbicacionNuevo
						FROM	@tbFabricacionCambioPlanta h
						WHERE	a.ClaPedido		= h.IdFabricacion
					) b
		WHERE	ClaEstatusSolicitud = 1
	--	AND		(@pnClaUbicacion IS NULL OR (ClaUbicacionSurte = @pnClaUbicacion))
	END

	--- Actualizar configuración
	UPDATE	a
	SET		dValor1				= @dFechaUltimaMod
	FROM	OpeSch.OPETiCatConfiguracionVw a
	WHERE	ClaUbicacion		= @pnClaUbicacion
	AND		ClaSistema			= 127 
	AND		ClaConfiguracion	= 1271230

	SET NOCOUNT OFF
END