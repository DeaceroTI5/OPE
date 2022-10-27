USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc
	  @pnClaPedidoOrigen	INT
	, @pnClaSolicitud		INT = NULL	
	, @pnClaArticulo		INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	-- EXEC OpeSch.OPE_CU550_Pag32_ValidaCantidadPedidoOrigenProc 24150954, NULL, 700391

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


	UPDATE	a
	SET		CantidadFabricacion	= c.CantidadPedida
	FROM	@tbOtrasSolicitudes a
	INNER JOIN DEAOFINET05.Ventas.VtaSch.vtatrafabricacionDetVw c
	ON		c.IdFabricacion			= @pnClaPedidoOrigen
	AND		a.ClaProducto			= c.ClaArticulo
	WHERE	c.ClaEstatusFabricacion IN (4,5,6)


	UPDATE	a
	SET		  ClaEstatus			= c.ClaEstatusFabricacion
			, CantidadSolicitada	= ISNULL(c.CantidadPedida,0)
			, CantidadDisponible	= a.CantidadFabricacion - ISNULL(c.CantidadPedida,0)
	FROM	@tbOtrasSolicitudes a
	INNER JOIN DEAOFINET05.Ventas.VtaSch.vtatrafabricacionDetVw c
	ON		a.ClaPedido				= c.IdFabricacion
	AND		a.ClaProducto			= c.ClaArticulo
	WHERE	c.ClaEstatusFabricacion IN (4,5,6)


	---Resultado
	SELECT    ClaPedido   
			, ClaProducto 
			, ClaEstatus  
			, CantidadFabricacion                          
			, CantidadSolicitada                      
			, CantidadDisponible
	FROM	@tbOtrasSolicitudes 
	WHERE	ClaEstatus > 0

	SET NOCOUNT OFF
END

