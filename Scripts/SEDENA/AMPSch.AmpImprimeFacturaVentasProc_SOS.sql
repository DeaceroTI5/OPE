USE Operacion
GO
DECLARE @sFactura VARCHAR(10) = 'DC41296'


SELECT	DISTINCT a.ClaUbicacion, a.IdFacturaAlfanumerico AS Factura--, b.NombreUbicacion, c.NombreTipoUbicacion, 
FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFacturaVw a
--INNER JOIN OPESch.OPETiCatUbicacionVw b
--ON		a.ClaUbicacion = b.ClaUbicacion
--INNER JOIN OPESch.OPETiCatUbicacionVw  c
--ON		b.ClaTipoUbicacion = c.ClaTipoUbicacion
WHERE	a.IdFacturaAlfanumerico = @sFactura



IF EXISTS (	SELECT	1
			FROM	AMP_DEAPATNET02_LNKSVR.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
			WHERE	IdFacturaAlfanumerico = @sFactura 
)
BEGIN
	-- DEAPATNET02
	EXEC AMP_DEAPATNET02_LNKSVR.Operacion.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
	SELECT '\\deapatnet02\Docvtas' AS 'PATH'
END
ELSE
	IF EXISTS (	SELECT	1
				FROM	AMP_DEAPATNET03_LNKSVR.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
				WHERE	IdFacturaAlfanumerico = @sFactura 
	)
	BEGIN
		-- DEAPATNET03
		EXEC AMP_DEAPATNET03_LNKSVR.Operacion.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
		SELECT '\\deapatnet03\Docvtas' AS 'PATH'
	END
	ELSE
		IF EXISTS (	SELECT	1
					FROM	AMP_DEAPATNET04_LNKSVR.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
					WHERE	IdFacturaAlfanumerico = @sFactura 
		)
		BEGIN
			-- DEAPATNET04
			EXEC AMP_DEAPATNET04_LNKSVR.Operacion.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
			SELECT '\\deapatnet04\Docvtas' AS 'PATH'
		END
		ELSE
			IF EXISTS (	SELECT	1
						FROM	AMP_DEAPATNET05_LNKSVR.Operacion.AMPSch.AmpRelRegistroEntradaFactura WITH(NOLOCK) 
						WHERE	IdFacturaAlfanumerico = @sFactura 
			)
			BEGIN
				-- DEAPATNET05
				EXEC AMP_DEAPATNET05_LNKSVR.Operacion.AMPSch.AmpImprimeFacturaVentasProc_SOS @psFactura = @sFactura
				SELECT '\\deapatnet05\Docvtas' AS 'PATH'
			END
			ELSE
			BEGIN
				SELECT 'NO SE GENERÓ', 'http://appbodnet2/Reports/Pages/Report.aspx?ItemPath=%2fOPE%2fReportes%2fOPE_CU71_Pag1_Rpt_RemisionNacional&ViewMode=Detail' AS 'PATH'
			END

----------------------
/*
SELECT	DISTINCT ClaClienteUnico, NomClienteCuenta
FROM	OpeSch.OpeVtaCatClienteCuentaVw 
WHERE	ClaClienteUnico = 14064 
AND		NomClienteCuenta LIKE '%DESARROLLADORA DE INFRAESTRUCTURA PUERTO ESCONDIDO%'


					SELECT	nIdBoletaOrigen		=	a.IdBoleta,
							nIdFactura				= NumFactura,
							sFacturaAlfanumerica	= IdFacturaAlfanumerico,
							IdViajeOrigen			= IdViaje,
							a.ClaUbicacion			
					FROM	AMP_DEAPATNET03_LNKSVR.Operacion.AMPsch.AmpRelRegistroEntradaFactura a WITH(NOLOCK)
					LEFT JOIN AMP_DEAPATNET03_LNKSVR.Operacion.AMPSch.AmpTraViaje b WITH(NOLOCK)
					ON		a.ClaUbicacion			= b.ClaUbicacion		
					AND		a.IdBoleta				= b.IdBoleta
					WHERE	IdFacturaAlfanumerico	= 'PP25476'--@psIdFacturaAlfanumerica

exec OpeSch.OPE_CU550_Pag41_Boton_btnGenerarRemisionDeAcero_Proc
  @pnClaUbicacion			= 324
, @pnClaUbicacionOrigenDS	= 191
, @pnIdViajeOrigenDS		= 315300
, @pnIdFacturaDS			= 191025476
, @psFacturaAlfanumericaDS	= 'PP25476'
, @pnClaUsuarioMod			= 1
, @psNombrePcMod			= 'Prueba'
, @pnDebug					= 1

SELECT * FROM DEAOFINET05.Ventas.VtaSch.VtaCTraFactura WITH(NOLOCK) WHERE IdFacturaAlfanumerico IN ('PP25477','PP25476')
SELECT * FROM DEAOFINET05.Ventas.VtaSch.VtaCTraFacturaDET WITH(NOLOCK) WHERE IdFactura IN (191025476, 191025477)

SELECT * FROM OpeSch.OpetrasalidaComandoCmdshellprocess where SalidaComando LIKE '%PP25477%'
SELECT * FROM OpeSch.OpetrasalidaComandoCmdshellprocess where SalidaComando LIKE '%PP25476%'

*/



