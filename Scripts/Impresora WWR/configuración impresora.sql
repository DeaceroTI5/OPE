SELECT * FROM OpeSch.OpeCfgImpresoraPc


INSERT INTO OpeSch.OpeCfgImpresoraPc(
	  ClaUbicacion
	, NomPc
	, RutaImpresora1
	, RutaImpresora2
	, BajaLogica
	, FechaBajaLogica
	, FechaUltimaMod
	, NombrePcMod
	, ClaUsuarioMod
)
SELECT	  ClaUbicacion		= 267
		, NomPc				= '100JRQUEVEDO'
		, RutaImpresora1	= '\\DEAWWRNET01\HPFAC9F3'
		, RutaImpresora2	= '\\DEAWWRNET01\HPFAC9F3'
		, BajaLogica		= 0
		, FechaBajaLogica	= NULL
		, FechaUltimaMod	= GETDATE()
		, NombrePcMod		= 'Carga Inicial'
		, ClaUsuarioMod		= 1


--BEGIN TRAN
	UPDATE	a
	SET		RutaImpresora1	= '\\DEAWWRNET01\TOSHIBA5'
			, RutaImpresora2	= '\\DEAWWRNET01\TOSHIBA5'
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	NomPC = '100-Hvalle'
--COMMIT
--BEGIN TRAN
	UPDATE	a
	SET		RutaImpresora1	= '\\DEAWWRNET01\TOSHIBA6'
			, RutaImpresora2	= '\\DEAWWRNET01\TOSHIBA6'
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	NomPC = '422-VAguirre'
--COMMIT
--BEGIN TRAN
	UPDATE	a
	SET		RutaImpresora1	= 'BrotherHLL6200DW'		-- 'BROTHER'
			, RutaImpresora2	= 'BrotherHLL6200DW'	-- 'BROTHER'
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	NomPC = 'DEFAULT'
--COMMIT


--delete from  OpeSch.OpeCfgImpresoraPc WHERE	NomPC = '422-favilaltp'

exec OPESch.OPEPrinterSel @pnClaUbicacion=267,@psNombrePcMod='422-favilaltp'

/*
	\\422-favilaltp\BROTHERF
	422-favilaltp\BROTHERF
	BROTHERF
*/


exec OPESch.OPE_CU71_Pag1_ImprimirSrvBack_Proc @pnClaUbicacion=267,@pnIdBoletaMod711=230480002,@pnClaIdioma=default,@psNombrePcMod='100-Hvalle',@pnIdOrdenEnvio=default
exec OPESch.OPEPrinterSel @pnClaUbicacion=267,@psNombrePcMod='100-Hvalle'


exec OPESch.OPE_CU71_Pag1_ImprimirSrvBack_Proc @pnClaUbicacion=267,@pnIdBoletaMod711=230880002,@pnClaIdioma=default,@psNombrePcMod='100-Hvalle',@pnIdOrdenEnvio=default


