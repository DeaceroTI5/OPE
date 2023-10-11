USE Operacion
GO

-- bluetooth % devices

--SELECT * FROM OpeSch.OpeCfgImpresoraPc WHERE NomPc = '422-VAguirre' 
EXEC OPESch.OPEPrinterSel 267, '422-VAguirre' 
EXEC OPESch.OPEPrinterSel 267, '422-favilaltp' 

begin tran
	UPDATE	a
	SET		RutaImpresora1	= '\\DEAWWRNET01\TOSHIBAPrinter2'	-- \\DEAWWRNET01\TOSHIBA6
			,RutaImpresora2 = '\\DEAWWRNET01\TOSHIBAPrinter2'	-- \\DEAWWRNET01\TOSHIBA6
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	ClaUbicacion = 267 
	AND		NomPc = '422-VAguirre'
commit tran

begin tran
	UPDATE	a
	SET		RutaImpresora1	= '\\DEAWWRNET01\BrotherL6200DW'	-- \\422-favilaltp\brotherf
			,RutaImpresora2 = '\\DEAWWRNET01\BrotherL6200DW'	-- \\422-favilaltp\brotherf
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK)
	WHERE	ClaUbicacion = 267 
	AND		NomPc = '422-favilaltp'
commit tran



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
       , NomPc              = '422-favilaltp'
       , RutaImpresora1     = '\\DEAWWRNET01\BrotherL6200DW'
       , RutaImpresora2     = '\\DEAWWRNET01\BrotherL6200DW'
       , BajaLogica         = 0
       , FechaBajaLogica    = NULL
       , FechaUltimaMod     = GETDATE()
       , NombrePcMod        = 'Carga Inicial'
       , ClaUsuarioMod      = 1


