ALTER PROCEDURE OpeSch.OpeImpresionBillLadingDetalle_Sel(
	@pnClaUbicacion int,
	@pnIdViaje int, 
	@psIdioma varchar(2),
	@psClaveArticulo VARCHAR(10))
AS
BEGIN
	IF (@psClaveArticulo = 'ITKSC60')
	BEGIN
		SELECT 'ITKSC60'	AS ClaveArticulo,
			'JTLW'		AS	ControlCode,
			'ASTM GR60 #5' AS ProductDescription,
			5			AS Diameter,
			60			AS Grade,
			2			AS StraightItems,
			48			AS StraightPieces,
			707			AS Straightkgs,
			10			AS StraightLength,
			2			AS BentItems,
			48			AS BentPieces,
			707			AS Bentkgs,
			10			AS BentLength,
			0			AS Clasificacion,
			1			AS UnidadMedida
		UNION ALL
		SELECT 'ITKSC60'	AS ClaveArticulo,
				'JTLW'		AS	ControlCode,
				'ASTM GR60 #6' AS ProductDescription,
				6			AS Diameter,
				60			AS Grade,
				2			AS StraightItems,
				24			AS StraightPieces,
				273			AS Straightkgs,
				10			AS StraightLength,
				2			AS BentItems,
				24			AS BentPieces,
				273			AS Bentkgs,
				10			AS BentLength,
				0			AS Clasificacion,
				1			AS UnidadMedida
	END
	ELSE
	BEGIN
		SELECT 'ITKFB60'	AS ClaveArticulo,
			'JTLX'		AS	ControlCode,
			'ASTM GR60 5' AS ProductDescription,
			5			AS Diameter,
			60			AS Grade,
			4			AS StraightItems,
			461			AS StraightPieces,
			1823		AS Straightkgs,
			10			AS StraightLength,
			4			AS BentItems,
			461			AS BentPieces,
			1823		AS Bentkgs,
			10			AS BentLength,
			0			AS Clasificacion,
			1			AS UnidadMedida
		UNION ALL
		SELECT 'ITKFB60'	AS ClaveArticulo,
				'JTLX'		AS	ControlCode,
				'ASTM GR60 #6' AS ProductDescription,
				6			AS Diameter,
				60			AS Grade,
				4			AS StraightItems,
				161			AS StraightPieces,
				1128		AS Straightkgs,
				10			AS StraightLength,
				4			AS BentItems,
				161			AS BentPieces,
				1128		AS Bentkgs,
				10			AS BentLength,
				0			AS Clasificacion,
				1			AS UnidadMedida
		UNION ALL
		SELECT 'ITKFB60'	AS ClaveArticulo,
				'JTLX'		AS	ControlCode,
				'ASTM GR60 #9' AS ProductDescription,
				9			AS Diameter,
				60			AS Grade,
				4			AS StraightItems,
				196			AS StraightPieces,
				10900		AS Straightkgs,
				10			AS StraightLength,
				4			AS BentItems,
				196			AS BentPieces,
				10900		AS Bentkgs,
				10			AS BentLength,
				0			AS Clasificacion,
				1			AS UnidadMedida
	END
END