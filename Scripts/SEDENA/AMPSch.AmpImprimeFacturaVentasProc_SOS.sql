USE Operacion
GO
DECLARE @sFactura VARCHAR(10) = 'PP24920'


SELECT	a.ClaUbicacion, b.NombreUbicacion, c.NombreTipoUbicacion, a.IdFacturaAlfanumerico AS Factura
FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFacturaVw a
INNER JOIN AMPSch.TiCatUbicacionVw b
ON		a.ClaUbicacion = b.ClaUbicacion
INNER JOIN AMPSch.TiCatTipoUbicacionVw c
ON		b.ClaTipoUbicacion = c.ClaTipoUbicacion
WHERE	a.IdFacturaAlfanumerico = @sFactura


IF EXISTS (	SELECT	1
			FROM	DEAPATNET02.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
			WHERE	IdFacturaAlfanumerico = @sFactura 
)
BEGIN
	-- DEAPATNET02
	EXEC DEAPATNET02.OPERACION.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
	SELECT '\\deapatnet02\Docvtas' AS 'PATH'
END
ELSE
	IF EXISTS (	SELECT	1
				FROM	DEAPATNET03.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
				WHERE	IdFacturaAlfanumerico = @sFactura 
	)
	BEGIN
		-- DEAPATNET03
		EXEC DEAPATNET03.OPERACION.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
		SELECT '\\deapatnet03\Docvtas' AS 'PATH'
	END
	ELSE
		IF EXISTS (	SELECT	1
					FROM	DEAPATNET04.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
					WHERE	IdFacturaAlfanumerico = @sFactura 
		)
		BEGIN
			-- DEAPATNET04
			EXEC DEAPATNET04.OPERACION.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
			SELECT '\\deapatnet04\Docvtas' AS 'PATH'
		END
		ELSE
			IF EXISTS (	SELECT	1
						FROM	DEAPATNET05.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
						WHERE	IdFacturaAlfanumerico = @sFactura 
			)
			BEGIN
				-- DEAPATNET05
				EXEC DEAPATNET05.OPERACION.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
				SELECT '\\deapatnet05\Docvtas' AS 'PATH'
			END
			ELSE
			BEGIN
				SELECT 'NO SE GENERÓ', 'http://appbodnet2/Reports/Pages/Report.aspx?ItemPath=%2fOPE%2fReportes%2fOPE_CU71_Pag1_Rpt_RemisionNacional&ViewMode=Detail' AS 'PATH'
			END