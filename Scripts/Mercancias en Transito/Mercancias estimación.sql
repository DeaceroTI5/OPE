DECLARE @pnIdFabricacionEstimacion int = null    
	
	SELECT  
			  f.IdFabricacionEstimacion
			, a.ClaUbicacion                          
			, a.ClaUbicacionOrigen
			, a.NumViaje  
			, g.FacturaAlfanumericoVenta
			, b.ClaUbicacionDestino
			, b.ClaArticulo
			, e.ClaveArticulo
			, a.IdMovimiento
			, b.IdRenglon
			, a.PesoEntrada
			, a.PesoNeto
			, a.PesoSalida
			, b.CantidadEnviada 
			, b.CantidadRecibida
			, b.EntradaSalida
			, b.KilosPesados
			, b.KilosTeoricos
			, b.PesoTeorico
			, ManPesoTeoricoKgs = e.PesoTeoricoKgs
			, b.ReferenciaCompras
			, a.ClaTipoInventario
			, g.IdBoletaVenta
			, g.IdPlanCargaVenta
			, g.IdViajeVenta
			, g.FabricacionVenta
			, EsTardio				= 0
			, b.EstatusTransito
    FROM	OpeSch.OpeTraMovMciasTranEnc a WITH(NOLOCK)
    INNER JOIN OpeSch.OpeTraMovMciasTranDet  b WITH(NOLOCK)
    ON      a.ClaUbicacion              = b.ClaUbicacion              
    AND     a.ClaTipoInventario         = b.ClaTipoInventario 
    AND     a.IdMovimiento              = b.IdMovimiento
    INNER JOIN OpeSch.OpeBitFabricacionEstimacion f WITH(NOLOCK)
    ON      b.NumericoExtra2            = f.IdFabricacionEstimacion
    INNER JOIN OpeSch.OpeTiCatUbicacionVw c
    ON      a.ClaUbicacionOrigen        = c.ClaUbicacion
    INNER JOIN OpeSch.OpeTiCatUbicacionVw d
    ON      b.ClaUbicacionDestino       = d.ClaUbicacion
    INNER JOIN OpeSch.ArtCatArticuloVw e
    ON      e.ClaTipoInventario         = 1
    AND     b.ClaArticulo               = e.ClaArticulo      
	INNER JOIN OpeSch.OpeRelEmbarqueEstimacionVw g
    ON      a.ClaUbicacionOrigen        = g.PlantaEstimacion
    AND     a.NumViaje                  = g.IdViajeEstimacion     
	AND		b.NumericoExtra2            = g.FabricacionEstimacion  
    WHERE	(@pnIdFabricacionEstimacion IS NULL OR (b.NumericoExtra2 = @pnIdFabricacionEstimacion))
	AND		b.EstatusTransito			= 1


