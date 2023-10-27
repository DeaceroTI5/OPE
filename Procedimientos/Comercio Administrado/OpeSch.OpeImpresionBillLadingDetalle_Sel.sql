USE Operacion
-- EXEC SP_HELPTEXT 'OpeSch.OpeImpresionBillLadingDetalle_Sel'
GO
ALTER PROCEDURE OpeSch.OpeImpresionBillLadingDetalle_Sel
	@pnClaUbicacion		INT,
	@pnIdViaje			INT, 
	@pnClaFabricacion	INT,	
	@psClaveArticulo	VARCHAR(20),
	@psIdioma			VARCHAR(10)
AS
BEGIN
	DECLARE	@nPlanCarga				INT,
			@nFactorConversionLbKg	NUMERIC(22,4) = 0.4536,
			@nFactorConversionKgLb	NUMERIC(22,4) = 2.2046

	SELECT	@nPlanCarga		= IdPlanCarga
	FROM	OpeSch.OpeTraViaje T0 WITH(NOLOCK)
	WHERE	ClaUbicacion	= @pnClaUbicacion	
	AND		IdViaje			= @pnIdViaje;
	
	;WITH	DetalleDocumentadoASA	AS 
	(
		SELECT	Planta					= T0.ClaUbicacion,
				PlanCarga				= T0.IdPlanCarga,
				Fabricacion				= T1.IdFabricacion,
				ClaveArticulo			= T1.ClaveArticulo,
				NombreArticulo			= T1.NombreArticulo,
				UnidadMedida			= T3.NomUnidad,
				ControlCode				= T1.ControlCode,
				OrderId					= T1.OrderId,
				ProductDescription		= T1.ProductDescription,
				Diameter				= T1.Diameter,
				Grade					= T1.Grade,
				WeightKgs				= SUM(ROUND(T1.WeightKgs,2)),
				DocumentedWeightKgs		= SUM(ROUND(T1.DocumentedWeightKgs,2)),
				StraightItems			= ISNULL(ROUND(T1.StraightItems,2),0),
				StraightPieces			= ISNULL(ROUND(T1.StraightPieces,2),0),
				StraightLength			= ISNULL(ROUND(T1.StraightLength,2),0),
				StraightKgs				= ISNULL(ROUND(T1.StraightKgs,2),0),
				BentItems				= ISNULL(ROUND(T1.BentItems,2),0),
				BentPieces				= ISNULL(ROUND(T1.BentPieces,2),0),
				BentLength				= ISNULL(ROUND(T1.BentLength,2),0),
				BentKgs					= ISNULL(ROUND(T1.BentKgs,2),0)
		FROM	OpeSch.OpeRelPlanCargaShipID T0 WITH(NOLOCK)
		INNER JOIN	OpeSch.OpeRelPlanCargaShipIDDet T1 WITH(NOLOCK)
			ON	T0.ClaUbicacion			= T1.ClaUbicacion
			AND T0.IdPlanCarga			= T1.IdPlanCarga
		INNER JOIN	OpeSch.OpeArtCatArticuloVw T2 WITH(NOLOCK)
			ON	T2.ClaTipoInventario	= 1
			AND T1.ClaArticulo			= T2.ClaArticulo
		INNER JOIN	OpeSch.OpeArtCatUnidadVw T3 WITH(NOLOCK)
			ON	T3.ClaTipoInventario	= 1
			AND T2.ClaUnidadBase		= T3.ClaUnidad
		WHERE	T0.ClaUbicacion		= @pnClaUbicacion
		AND		T0.IdPlanCarga		= @nPlanCarga
		AND		T1.IdFabricacion	= @pnClaFabricacion
		AND		T1.ClaveArticulo	= @psClaveArticulo
		GROUP BY 
				T0.ClaUbicacion, T0.IdPlanCarga, T1.IdFabricacion, T1.ClaveArticulo, T1.NombreArticulo, T3.NomUnidad,
				T1.ControlCode, T1.OrderId, T1.ProductDescription, T1.Diameter, T1.Grade, 				
				T1.StraightItems, T1.StraightPieces, T1.StraightLength, T1.StraightKgs, 
				T1.BentItems, T1.BentPieces, T1.BentLength, T1.BentKgs
	)
	
	SELECT	T0.ClaveArticulo,
			T0.ControlCode,
			T0.ProductDescription,
			T0.Diameter, 
			T0.Grade,
			StraightItems	= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * StraightItems,
			StraightPieces	= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * StraightPieces,
			StraightLength	= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * StraightLength,
			Straightkgs		= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * StraightKgs,
			StraightLb		= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * (StraightKgs * @nFactorConversionKgLb),
			BentItems		= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * BentItems,
			BentPieces		= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * BentPieces,
			BentLength		= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * BentLength,
			BentKgs			= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * BentKgs,
			BentLb			= ISNULL((T0.DocumentedWeightKgs / T0.WeightKgs),0) * (BentKgs * @nFactorConversionKgLb),
			Clasificacion	=	
								CASE 
									WHEN	NombreArticulo LIKE '%BENT%'
									THEN	1
									WHEN	NombreArticulo LIKE '%STRAIGHT%' 
									THEN	2
									ELSE	0
								END, --0 Mixto, 1 Bent, 2 Straight
			UnidadMedida	=	
								CASE 
									WHEN	UnidadMedida = 'LBS'
									THEN	1
									ELSE	0
								END  --0 kgs, 1 lbs
	FROM	DetalleDocumentadoASA T0
END