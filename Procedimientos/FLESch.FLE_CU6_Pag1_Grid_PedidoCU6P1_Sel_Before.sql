Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 
*/ 
CREATE PROCEDURE FLESch.FLE_CU6_Pag1_Grid_PedidoCU6P1_Sel_Before
	@pnClaUbicacion				INT OUTPUT,
	@pnNumEntSal				INT OUTPUT, 
	@pnNumViajeCU6P1			INT OUTPUT,
	@pnNumFactura				INT OUTPUT, 
	@psIdioma					VARCHAR(10) = 'Spanish' OUTPUT,
	@pnClaIdioma				INT			= 5	 OUTPUT,
	@pnContinuar					INT OUTPUT 
	
AS 
    BEGIN	
        SET NOCOUNT ON  
        
        
        IF ISNULL(@pnNumFactura,0) <> 0
        BEGIN	
			SELECT	facdet.ClaPedido		AS ClaPedido,
					facdet.Renglon			AS Renglon,
					art.ClaveArticulo+'-'+art.NomArticulo			AS NomArticulo,
					art.FactorCubicaje		AS FactorCubicaje,
					facdet.CantSurtida		AS CantSurtida,
					facdet.KgSurtidos		AS KgSurtidos,
					facdet.KgCubicados		AS KgCubicados,
					facdet.KgTaras			AS KgTaras
					,KgEnvTotal				= ISNULL(dt.KgsEnviados,0)
					,KgRecTotal				= ISNULL(dt.KgsRecibidos,0)
					,KgDevTotal				= NULL --ISNULL(vr.KgDevTotal,0)
					,KgDifTotal				= ISNULL(dt.KgsEnviados,0) - ISNULL(dt.KgsRecibidos,0)
					,ImpDifTotal			= ISNULL(dt.ImporteFaltanteMaterial,0)
					,PrecioVentaArt			= ISNULL(dt.PrecioVtaArt, 0)
					,dt.ImporteFleteDirecto + dt.importeFleteFalso AS ImporteSinIva
			FROM	FleSch.FleTraViajeFacturaDet facdet	WITH (NOLOCK)
			LEFT	JOIN FleSch.FleArtCatArticuloVw art		WITH (NOLOCK) ON art.ClaArticulo = facdet.ClaArticulo AND art.ClaTipoInventario = 1
			LEFT	JOIN FleSch.FleTraTabular	  t			WITH (NOLOCK) ON t.ClaUbicacion = facdet.ClaUbicacion AND t.Referencia1 = CONVERT(VARCHAR,facdet.NumViaje)
			LEFT	JOIN FleSch.FleTraTabularDet dt		WITH (NOLOCK) ON dt.ClaUbicacion = facdet.ClaUbicacion AND dt.IdTabular = t.IdTabular 
																AND facdet.ClaArticulo = dt.ClaArticulo	AND  facdet.Renglon = dt.ClaRenglonPedido
																AND dt.ClaPedido  = facdet.ClaPedido--Correcion de bug persistente
			
			--LEFT    JOIN FleSch.FleTraViajeReqKgRecibido vr (NOLOCK) ON vr.NumViaje  = facdet.NumViaje
			--		and vr.ClaUbicacion = facdet.ClaUbicacion 
			WHERE	facdet.ClaUbicacion	= @pnClaUbicacion AND
					facdet.NumViaje		= @pnNumViajeCU6P1 AND
					facdet.NumFactura	= @pnNumFactura
		END
			
		IF ISNULL(@pnNumEntSal,0) <> 0
		BEGIN  
			SELECT	entdet.ClaPedido		AS ClaPedido,
					entdet.Renglon			AS Renglon,
					art.ClaveArticulo+'-'+art.NomArticulo			AS NomArticulo,
					art.FactorCubicaje		AS FactorCubicaje,
					entdet.CantSurtida		AS CantSurtida,
					entdet.KgSurtidos		AS KgSurtidos,
					entdet.KgCubicados		AS KgCubicados,
					entdet.KgTaras			AS KgTaras
					,KgEnvTotal				= ISNULL(dt.KgsEnviados,0)
					,KgRecTotal				= ISNULL(dt.KgsRecibidos,0)
					,KgDevTotal				= NULL --ISNULL(vr.KgDevTotal,0)
					,KgDifTotal				= ISNULL(dt.KgsEnviados,0) - ISNULL(dt.KgsRecibidos,0)
					,ImpDifTotal			= ISNULL(dt.ImporteFaltanteMaterial,0)
					,PrecioVentaArt			= ISNULL(dt.PrecioVtaArt, 0)
					,dt.ImporteFleteDirecto + dt.importeFleteFalso AS ImporteSinIva 
			FROM	FleSch.FleTraViajeEntsalDet	entdet	WITH (NOLOCK)
			LEFT	JOIN FleSch.FleArtCatArticuloVw	art		WITH (NOLOCK) ON art.ClaArticulo = entdet.ClaArticulo AND art.ClaTipoInventario = 1
			LEFT	JOIN FleSch.FleTraTabular		t		WITH (NOLOCK) ON t.ClaUbicacion = entdet.ClaUbicacion AND t.Referencia1 = CONVERT(VARCHAR,entdet.NumViaje)
			LEFT	JOIN FleSch.FleTraTabularDet	dt		WITH (NOLOCK) ON dt.ClaUbicacion = entdet.ClaUbicacion AND dt.IdTabular = t.IdTabular 
																AND entdet.ClaArticulo = dt.ClaArticulo	AND  entdet.Renglon = dt.ClaRenglonPedido
										and entdet.ClaPedido = dt.ClaPedido
			--LEFT    JOIN FleSch.FleTraViajeReqKgRecibido vr (NOLOCK) ON vr.NumViaje  = entdet.NumViaje
			--		and vr.ClaUbicacion = entdet.ClaUbicacion 
			WHERE	entdet.ClaUbicacion	= @pnClaUbicacion AND
					entdet.NumViaje		= @pnNumViajeCU6P1 AND
					entdet.NumEntsal	= @pnNumEntSal
        END 
 
 
        SET @pnContinuar = 0
        
		SET NOCOUNT OFF
    END