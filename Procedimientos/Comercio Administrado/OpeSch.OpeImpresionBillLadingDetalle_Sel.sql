USE Operacion
-- EXEC SP_HELPTEXT 'OpeSch.OpeImpresionBillLadingDetalle_Sel'
GO
CREATE PROCEDURE OpeSch.OpeImpresionBillLadingDetalle_Sel (
	@pnClaUbicacion		int,
	@pnIdViaje			int, 
	@pnClaFabricacion	INT,
	@psIdioma			varchar(2),
	@psClaveArticulo VARCHAR(10))
AS
BEGIN
	DECLARE @nPlanCarga INT
			

	SELECT @nPlanCarga = IdPlanCarga
		FROM OpeSch.OpeTraViaje
		WHERE ClaUbicacion	= @pnClaUbicacion	
		AND IdViaje			= @pnIdViaje;
	
	;WITH Cte AS (
	SELECT ClaveArticulo,
			NombreArticulo,
			ControlCode,
			ProductDescription,
			Diameter,
			Grade,
			SUM(ROUND(DocumentedWeightKgs,2)) AS Prorrateo,
			ISNULL(ROUND(StraightItems,2) , 0) AS StraightItems,
			ISNULL(ROUND(StraightPieces,2) ,0) AS StraightPieces,
			ISNULL(ROUND(StraightKgs,2) ,0) AS StraightKgs,
			ISNULL(ROUND(StraightLength,2) , 0) AS StraightLength,
			ISNULL(ROUND(BentItems,2) , 0) AS BentItems,
			ISNULL(ROUND(BentPieces,2) , 0) AS BentPieces,
			ISNULL(ROUND(BentKgs,2) , 0) AS BentKgs,
			ISNULL(ROUND(BentLength,2) , 0) AS BentLength,
			TotalKgs
		FROM OpeSch.OpeRelPlanCargaShipID enc
		JOIN OpeSch.OpeRelPlanCargaShipIDDet det
			ON enc.ClaUbicacion = det.ClaUbicacion
			AND enc.IdPlanCarga = det.IdPlanCarga
		WHERE enc.ClaUbicacion = @pnClaUbicacion
			AND enc.IdPlanCarga = @nPlanCarga
			AND det.IdFabricacion = @pnClaFabricacion
			AND det.ClaveArticulo = @psClaveArticulo
		GROUP BY ClaveArticulo, NombreArticulo, ControlCode, ProductDescription, Diameter, Grade, StraightItems, StraightPieces, StraightKgs, StraightLength, BentItems, BentPieces, BentKgs, BentLength, TotalKgs)
	
	SELECT ClaveArticulo,
			ControlCode,
			ProductDescription,
			Diameter, 
			Grade,
			ISNULL((Prorrateo / TotalKgs), 0) * StraightItems AS StraightItems,
			ISNULL((Prorrateo / TotalKgs), 0) * StraightPieces AS StraightPieces,
			ISNULL((Prorrateo / TotalKgs), 0) * StraightKgs AS Straightkgs,
			ISNULL((Prorrateo / TotalKgs), 0) * StraightLength AS StraightLength,
			ISNULL((Prorrateo / TotalKgs), 0) * BentItems AS BentItems,
			ISNULL((Prorrateo / TotalKgs), 0) * BentPieces AS BentPieces,
			ISNULL((Prorrateo / TotalKgs), 0) * BentKgs AS BentKgs,
			ISNULL((Prorrateo / TotalKgs), 0) * BentLength AS BentLength,
			CASE WHEN NombreArticulo LIKE '%BENT%'
						THEN 1
					WHEN NombreArticulo LIKE '%STRAIGHT%' 
						THEN 2
					ELSE 0
				END	
			AS Clasificacion
		FROM Cte
END