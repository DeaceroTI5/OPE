/*
	SELECT *
	FROM	AMP_DEAPATNET02_LNKSVR.Operacion.AMPsch.AmpRelRegistroEntradaFactura a WITH(NOLOCK)
	LEFT JOIN OpeSch.OpeTraRemisionesDeAceroSD b WITH(NOLOCK)
	ON		a.NumFactura = b.IdFactura
	WHERE	a.ClaUbicacion	= 70
	AND		b.IdFactura IS NULL
	AND		YEAR(a.FechaUltimaMod) = 2022
	ORDER BY a.FechaUltimaMod DESC
*/

-- 'OpeSch.OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc'


exec OPESch.OPE_CU550_Pag41_Grid_GridRemisionDeAcero_Sel 
	 @pnClaUbicacion			= 324
	,@pnCmbUbicacionOrigen		= 70
	,@pnIdViajeOrigen			= default
	,@psIdFacturaAlfanumerica	= 'FB8714'
	,@pnClaUsuarioMod			= 100010318
	,@psNombrePcMod				= '100-Hvalle'
	,@pnDebug					= default

-- 'OpeSch.OPE_CU550_Pag41_Servicio_CargaRemisionDeAcero_Proc'
BEGIN TRAN
	EXEC OpeSch.OPE_CU550_Pag41_Servicio_CargaRemisionDeAcero_Proc
		@pnClaUbicacion				= 324,
		@pnClaUbicacionOrigen		= 70,
		@pnIdViajeOrigen			= 25477,
		@pnIdFactura				= 135008714,
		@pnEsImpresionPDF			= 0,
		@pnTipoGeneracion			= 1, --1: Patios / 2: Bodegas / , Alambres y Macrohub
		@pnClaUsuarioMod			= 100010318,
		@psNombrePcMod				= '100-Hvalle',
		@pnEsCargarArchivo			= 1,
		@pnEsCopiarArchivo			= 0,
		@pnDebug					= 1
ROLLBACK TRAN

BEGIN TRAN
	EXEC OpeSch.OPE_CU550_Pag41_Servicio_CargaRemisionDeAcero_ProcHv
		@pnClaUbicacion				= 324,
		@pnClaUbicacionOrigen		= 70,
		@pnIdViajeOrigen			= 25477,
		@pnIdFactura				= 135008714,
		@pnEsImpresionPDF			= 0,
		@pnTipoGeneracion			= 1, --1: Patios / 2: Bodegas / , Alambres y Macrohub
		@pnClaUsuarioMod			= 100010318,
		@psNombrePcMod				= '100-Hvalle',
		@pnEsCargarArchivo			= 1,
		@pnEsCopiarArchivo			= 0,
		@pnDebug					= 1
ROLLBACK TRAN