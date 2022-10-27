Use Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColProducto_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColProducto_Sel
    @pnClaUbicacion     INT,
    @pnCmbProyecto	    INT = 0,
    @pnColProducto	    INT = 0,
    @pnColCantPedida    INT = 0,
	@pnClaPedidoOrigen	INT = NULL,
	@pnDebug			TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	-- exec OPESch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColProducto_Sel @pnClaUbicacion=325,@pnCmbProyecto=21017,@pnColProducto=317,@pnColCantPedida=0,@pnClaTipoTraspaso=2,@pnDebug=1

	DECLARE @tbResultado TABLE(
		  Id					INT IDENTITY(1,1)
		, ClaArticulo			INT
		, ColUnidad				VARCHAR(20)
		, ColPesoTeorico		NUMERIC(22,7)
		, ColKilosPedidos		NUMERIC(22,4)
		, ColCantidadMinAgrup	NUMERIC(18,4)
		, ColEsMultiplo			INT
		, ColPrecioListaMP		NUMERIC(25,4)
	)

	DECLARE @tbPrecioMP	TABLE(
		  Id			INT IDENTITY(1,1)
		, ClaArticulo	INT
		, PrecioMP		NUMERIC(25,4)			
	)

	DECLARE @nPrecioLista NUMERIC(22,4)


	---- Universo
	INSERT INTO @tbResultado(
		  ClaArticulo
		, ColUnidad           
		, ColPesoTeorico      
		, ColKilosPedidos     
		, ColCantidadMinAgrup 
		, ColEsMultiplo       
	)
    SELECT    a.ClaArticulo
            , ColUnidad           = b.NomCortoUnidad
            , ColPesoTeorico      = ISNULL( a.PesoTeoricoKgs,1.00 )
            , ColKilosPedidos     = ISNULL( @pnColCantPedida,0.00 ) * ISNULL( a.PesoTeoricoKgs,1.00 )
            , ColCantidadMinAgrup = ISNULL( c.CantidadMinAgrup,0.00 )
            , ColEsMultiplo       = ISNULL( c.Multiplo,0 )
    FROM    OpeSch.OpeArtCatArticuloVw a WITH(NOLOCK)  
    LEFT JOIN   OpeSch.OpeArtCatUnidadVw b WITH(NOLOCK)  
    ON		a.ClaTipoInventario = b.ClaTipoInventario
	AND		a.ClaUnidadBase		= b.ClaUnidad
    LEFT JOIN   OpeSch.OpeManCatArticuloDimensionVw c WITH(NOLOCK)  
    ON		a.ClaArticulo		= c.ClaArticulo
    WHERE   a.ClaArticulo		= @pnColProducto

	---- PrecioMP
	INSERT INTO @tbPrecioMP (ClaArticulo, PrecioMP)
	SELECT DISTINCT
			  d.ValorLlaveCriterio
			, ISNULL( d.PrecioMP,0.00 )
	FROM	DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet d WITH(NOLOCK)	-- PK ClaProyecto, ClaTipoCriterio, ClaCriterio, ValorLlaveCriterio, AnioMes
	WHERE	d.ClaProyecto		 = @pnCmbProyecto
	AND		d.ValorLlaveCriterio = @pnColProducto


	---- PrecioMP
	IF  ISNULL(@pnClaPedidoOrigen,0) > 0
	AND	NOT EXISTS (
			SELECT	1
			FROM	@tbPrecioMP
	)
	BEGIN
		SELECT	@nPrecioLista	= PrecioLista
		FROM	OpeSch.OpeTraFabricacionDetVw 
		WHERE	IdFabricacion	= @pnClaPedidoOrigen 
		AND		ClaArticulo		= @pnColProducto

		INSERT INTO @tbPrecioMP (ClaArticulo, PrecioMP)
		SELECT DISTINCT
				  d.ValorLlaveCriterio
				, ISNULL( d.PrecioMP,0.00 )
		FROM	DEAOFINET05.Ventas.VtaSch.VtaTraControlProyectoDet d WITH(NOLOCK)	-- PK ClaProyecto, ClaTipoCriterio, ClaCriterio, ValorLlaveCriterio, AnioMes
		WHERE	d.ClaProyecto	= @pnCmbProyecto
		AND		d.Precio		= @nPrecioLista		
	END


	IF @pnDebug = 1
	BEGIN
		SELECT '' AS '@tbResultado', *	FROM @tbResultado
		SELECT '' AS '@tbPrecioMP', *	FROM @tbPrecioMP
	END


	UPDATE	a
	SET		ColPrecioListaMP = b.PrecioMP
	FROM	@tbResultado a
	INNER JOIN @tbPrecioMP b
	ON		a.ClaArticulo = b.ClaArticulo


	---- Resultado
	SELECT    ColUnidad           
			, ColPesoTeorico      
			, ColKilosPedidos     
			, ColCantidadMinAgrup 
			, ColEsMultiplo       
			, ColPrecioListaMP = ISNULL(ColPrecioListaMP,0.00)
	FROM	@tbResultado


	SET NOCOUNT OFF    
	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Grid_GridTraspasoManualDet_CambioValor_ColProducto_Sel) no puede ser procesado.', 16, 1)        

END
