Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OpeImpresionBillLadingDetalle_Sel(
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
			'ASTM GR60 #5' AS Product,
			5			AS Diam,
			60			AS Grade,
			2			AS StraightItems,
			48			AS StraightPieces,
			707			AS StraightKg,
			1560		AS StraightLb,
			1			AS StraightSN
		UNION ALL
		SELECT 'ITKSC60'	AS ClaveArticulo,
				'JTLW'		AS	ControlCode,
				'ASTM GR60 #6' AS Product,
				6			AS Diam,
				60			AS Grade,
				2			AS StraightItems,
				24			AS StraightPieces,
				273			AS StraightKg,
				603			AS StraightLb,
				1			AS StraightSN
	END
	ELSE
	BEGIN
		SELECT 'ITKFB60'	AS ClaveArticulo,
			'JTLX'		AS	ControlCode,
			'ASTM GR60 5' AS Product,
			5			AS Diam,
			60			AS Grade,
			4			AS StraightItems,
			461			AS StraightPieces,
			1823		AS StraightKg,
			4020		AS StraightLb,
			0			AS StraightSN
		UNION ALL
		SELECT 'ITKFB60'	AS ClaveArticulo,
				'JTLX'		AS	ControlCode,
				'ASTM GR60 #6' AS Product,
				6			AS Diam,
				60			AS Grade,
				4			AS StraightItems,
				161			AS StraightPieces,
				1128		AS StraightKg,
				2487		AS StraightLb,
				0			AS StraightSN
		UNION ALL
		SELECT 'ITKFB60'	AS ClaveArticulo,
				'JTLX'		AS	ControlCode,
				'ASTM GR60 #9' AS Product,
				9			AS Diam,
				60			AS Grade,
				4			AS StraightItems,
				196			AS StraightPieces,
				10900			AS StraightKg,
				24031		AS StraightLb,
				0			AS StraightSN
	END
END