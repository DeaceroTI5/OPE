ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Grid_GridTraspasoManualDet_ColCantPedida_ActualizaValores_Sel
    @pnClaUbicacion         INT,
	@pnIdIndice				INT,
	@pnColIdIndice			INT,
    @pnAvisoValidacionDet   INT = 0,
    @pnEsValidaCantMinima   INT = 0,
    @pnEsValidaCantMaxima   INT = 0,
    @pnEsValidaCantMultiplo INT = 0,
    @pnEsMultiploFila       INT = 0,
    @pnValorMultiplo        NUMERIC(22,4),
    @pnColCantPedida        NUMERIC(22,4),
	@pnColKilosPedidos		NUMERIC(22,4),
    @pnColPesoTeorico       NUMERIC(22,4)
AS
BEGIN

	SET NOCOUNT ON

    SELECT  @pnValorMultiplo = ISNULL( @pnValorMultiplo,0 ),
            @pnColCantPedida = ISNULL( @pnColCantPedida,0 ),
			@pnColPesoTeorico   = ISNULL( @pnColPesoTeorico,0 )

    IF ( @pnAvisoValidacionDet = 1 AND ( @pnEsValidaCantMinima = 0 OR @pnEsValidaCantMaxima = 0 ) )
    BEGIN
        --SELECT  ColCantPedida		= 0.00
		--		, ColKilosPedidos	= 0.00
		SELECT	  ColCantPedida		= CASE WHEN @pnIdIndice = @pnColIdIndice THEN 0.00 ELSE @pnColCantPedida END
				, ColKilosPedidos	= CASE WHEN @pnIdIndice = @pnColIdIndice THEN 0.00 ELSE @pnColKilosPedidos END
    END    
    ELSE IF ( @pnAvisoValidacionDet = 1 AND @pnEsValidaCantMultiplo = 0 AND @pnEsMultiploFila = 1 )
    BEGIN
        --SELECT  ColCantPedida		= ISNULL( @pnValorMultiplo,0.00 )
		--		, ColKilosPedidos	= ISNULL( @pnValorMultiplo * ISNULL( @pnColPesoTeorico,1),0 )
		SELECT	  ColCantPedida		= CASE WHEN @pnIdIndice = @pnColIdIndice THEN ISNULL( @pnValorMultiplo,0.00 ) ELSE @pnColCantPedida END
				, ColKilosPedidos	= CASE WHEN @pnIdIndice = @pnColIdIndice THEN ISNULL( @pnValorMultiplo * ISNULL( @pnColPesoTeorico,1),0 ) ELSE @pnColKilosPedidos END
				
    END 
    ELSE
    BEGIN
        --SELECT  ColCantPedida		= @pnColCantPedida
		--		, ColKilosPedidos	= ISNULL( @pnColCantPedida * ISNULL( @pnColPesoTeorico,1),0 )
		SELECT	  ColCantPedida		= CASE WHEN @pnIdIndice = @pnColIdIndice THEN ISNULL( @pnColCantPedida,0.00 ) ELSE @pnColCantPedida END
				, ColKilosPedidos	= CASE WHEN @pnIdIndice = @pnColIdIndice THEN ISNULL( @pnValorMultiplo * ISNULL( @pnColPesoTeorico,1),0 ) ELSE @pnColKilosPedidos END
				
    END

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Grid_GridTraspasoManualDet_ColCantPedida_ActualizaValores_Sel) no puede ser procesado.', 16, 1)     

END