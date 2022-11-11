USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc
	  @pnClaPedidoOrigen	INT
	, @pnClaSolicitud		INT = NULL	
	, @pnClaArticulo		INT = NULL
	, @pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- EXEC OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc 23416945, 151, null, 1

	SELECT @pnClaArticulo = ISNULL(@pnClaArticulo,0)
	
	DECLARE @tbOtrasSolicitudes TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaPedido				INT
		, ClaProducto			INT
		, ClaEstatus			INT
		, CantidadFabricacion	NUMERIC(22,4)
		, CantidadSolicitada	NUMERIC(22,4)
		, CantidadDisponible	NUMERIC(22,4)
	)


	INSERT INTO @tbOtrasSolicitudes (
		  ClaPedido
		, ClaProducto		
	)
	SELECT	  ClaPedido
			, b.ClaProducto
	FROM	OpeSch.OpeTraSolicitudTraspasoEnc a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraSolicitudTraspasoDet b WITH(NOLOCK)
	ON		a.IdSolicitudTraspaso	= b.IdSolicitudTraspaso
	WHERE	(@pnClaSolicitud IS NULL OR (a.IdSolicitudTraspaso <> @pnClaSolicitud))
	AND		a.ClaPedidoOrigen = @pnClaPedidoOrigen
	AND		(@pnClaArticulo = 0 OR(b.ClaProducto = @pnClaArticulo))
	GROUP BY a.ClaPedido, b.ClaProducto

	IF @pnDebug = 1
		SELECT '' AS '@tbOtrasSolicitudes', * FROM @tbOtrasSolicitudes ORDER BY ClaProducto ASC


	UPDATE	a
	SET		CantidadFabricacion		= ISNULL(c.CantidadPedida,0)
	FROM	@tbOtrasSolicitudes a
	INNER JOIN DEAOFINET05.Ventas.VtaSch.vtatrafabricacionDetVw c
	ON		c.IdFabricacion			= @pnClaPedidoOrigen
	AND		a.ClaProducto			= c.ClaArticulo
	WHERE	c.ClaEstatusFabricacion IN (4,5,6)

	IF @pnDebug = 1
		SELECT '' AS '@tbOtrasSolicitudes2', * FROM @tbOtrasSolicitudes ORDER BY ClaProducto ASC

	UPDATE	a
	SET		  ClaEstatus			= c.ClaEstatusFabricacion
			, CantidadSolicitada	= ISNULL(c.CantidadPedida,0)
	FROM	@tbOtrasSolicitudes a
	INNER JOIN DEAOFINET05.Ventas.VtaSch.vtatrafabricacionDetVw c
	ON		a.ClaPedido				= c.IdFabricacion
	AND		a.ClaProducto			= c.ClaArticulo
	WHERE	c.ClaEstatusFabricacion IN (4,5,6)

	IF @pnDebug = 1
		SELECT '' AS '@tbOtrasSolicitudes3', * FROM @tbOtrasSolicitudes ORDER BY ClaProducto ASC



	UPDATE	a
	SET		  CantidadDisponible	= (a.CantidadFabricacion - (SELECT SUM(ISNULL(h.CantidadSolicitada,0)) FROM @tbOtrasSolicitudes h WHERE a.ClaProducto = h.ClaProducto))
	FROM	@tbOtrasSolicitudes a

	--CantidadSolicitada	= (SELECT SUM(ISNULL(h.CantidadSolicitada,0)) FROM @tbOtrasSolicitudes h WHERE a.ClaProducto = h.ClaProducto)
			


	IF @pnDebug = 1
		SELECT '' AS '@tbOtrasSolicitudes', * FROM @tbOtrasSolicitudes ORDER BY ClaProducto ASC

	---Resultado
	SELECT    ClaPedido   
			, ClaProducto 
			, ClaEstatus  
			, CantidadFabricacion                          
			, CantidadSolicitada                      
			, CantidadDisponible = ISNULL(CantidadDisponible,0.00)
	FROM	@tbOtrasSolicitudes 
	WHERE	ClaEstatus > 0
	ORDER BY ClaProducto ASC

	SET NOCOUNT OFF
END

