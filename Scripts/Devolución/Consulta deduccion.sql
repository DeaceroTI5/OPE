USE Operacion
GO

exec OPESch.OPE_CU445_Pag18_Sel @pnClaUbicacion=326,@pnClaMaquilador=5,@psFacturaMaquilador=''
exec OPESch.OPE_CU445_Pag18_Grid_Boletas_Sel @pnClaUbicacion=326,@pnClaMaquilador=5,@pnIdRecepFacturaMaquilador=NULL
exec OPESch.OPE_CU445_Pag18_Grid_Deducciones_Sel @pnClaUbicacion=326,@pnIdRecepFacturaMaquilador=NULL,@pnClaMaquilador=5,@pnEsAutomatica=default
exec OPESch.OPE_CU445_Pag18_Grid_ODM_Sel @pnClaUbicacion=326,@pnClaMaquilador=5,@pnIdBoletaConsulta=230540014,@pnIdRecepFacturaMaquilador=NULL
