USE Operacion
GO


exec OPESch.OPE_CU71_Pag1_Grid_ReimpresionDocumentosMod711_Sel @pnClaUbicacion=267,@pnIdViajeMod711=7918,@pnIdBoletaMod711=230470001,@pnClaMovEntSalMod711=NULL
go

exec OPESch.OPE_CU71_Pag1_Boton_ClaFacturasEntSal_Proc @pnClaUbicacion=267,@pnClaMovEntSalMod711=7
go
exec OPESch.OPE_CU71_Pag1_Grid_ReimpresionDocumentosMod711_Sel @pnClaUbicacion=267,@pnIdViajeMod711=7918,@pnIdBoletaMod711=230470001,@pnClaMovEntSalMod711=7
go

exec OPESch.OPE_CU71_Pag1_ImprimirSrvBack_Proc @pnClaUbicacion=267,@pnIdBoletaMod711=230470001,@pnClaIdioma=default,@psNombrePcMod='100-Hvalle',@pnIdOrdenEnvio=default
go
exec OPESch.OPEPrinterSel @pnClaUbicacion=267,@psNombrePcMod='100-Hvalle'
go

--exec OpeSch.OpeRepUrlLogoSel @pnClaUbicacion=267
--go
--exec OpeSch.OpeImpresionBoletaBasculaSel @pnNumVersion=1,@pnClaUbicacion=267,@pnIdBoleta=230470001







-- http://deawwrnet01:2243/Pages/OPE_CU440_Pag34.aspx?wu=267


-- Brother_HL_L2390DW
-- \\DEAWWRNET01\BROTHER
BEGIN TRAN
	UPDATE	a
	SET		RutaImpresora1 = 'BROTHER'
			,RutaImpresora2 = 'BROTHER'
	FROM	OpeSch.OpeCfgImpresoraPc a WITH(NOLOCK) 
	WHERE	ClaUbicacion = 267 AND
	NomPc = 'DEFAULT'
COMMIT TRAN


