USE Operacion
GO

INSERT INTO OpeSch.OpeCfgImpresoraPc (
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
SELECT   ClaUbicacion       = 267
       , NomPc              = '100-Hvalle'
       , RutaImpresora1     = 'TOSHIBA2'
       , RutaImpresora2     = 'TOSHIBA2'
       , BajaLogica         = 0
       , FechaBajaLogica    = NULL
       , FechaUltimaMod     = GETDATE()
       , NombrePcMod        = 'Carga Inicial'
       , ClaUsuarioMod      = 1

 

EXEC OPESch.OPEPrinterSel 267, '422-VAguirre'

begin tran
	UPDATE	a
	SET		RutaImpresora1	= '\\DEAWWRNET01\TOSHIBA5'
			,RutaImpresora2 = '\\DEAWWRNET01\TOSHIBA5'
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	ClaUbicacion = 267 
	AND		NomPc = '100-Hvalle'
commit tran
begin tran
	UPDATE	a
	SET		RutaImpresora1	= 'TOSHIBA5'
			,RutaImpresora2 = 'TOSHIBA5'
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	ClaUbicacion = 267 
	AND		NomPc = '100-Hvalle'
commit tran



EXEC OPESch.OPEPrinterSel 267, '100-Hvalle'

EXEC OPESch.OPEPrinterSel 267, '422-VAguirre'

----------------------------
-- Trace Victo Aguirre
exec OPESch.OPE_CU71_Pag1_ImprimirSrvBack_Proc 
		@pnClaUbicacion=267,@pnIdBoletaMod711=230480002,@pnClaIdioma=default,@psNombrePcMod='422-VAguirre',@pnIdOrdenEnvio=default
go
exec OPESch.OPEPrinterSel 
		@pnClaUbicacion=267,@psNombrePcMod='422-VAguirre'
go


