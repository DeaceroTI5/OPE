-- DEAITKNET04
USE Operacion
GO
BEGIN TRAN

	declare @p2 int
	set @p2=281
	exec OPESch.OPE_CU445_Pag18_IU					-- Executa: / OPESch.OPE_CU445_Pag19_Grid_Facturas_IU>Inserta espejo:OpeSch.OpeTraTramiteMaquilador
		@pnClaUbicacion=326
		,@pnIdRecepFacturaMaquilador=@p2 output
		,@pnClaMaquilador=5
		,@pnFacturaMaquilador=''
		,@ptFechaCaptura='2023-04-21 00:00:00'
		,@pnClaEstatus=NULL
		,@pnPorcentajeIva=16.0000
		,@pnKgsFacturados=7629.0000
		,@pnIncluirDeduccion=1
		,@psNombrePcMod='100-Hvalle'
		,@pnClaUsuarioMod=100010318
		,@pnSubTotalFactura=6789.8100
		,@ptFechaFactura='2023-04-21 00:00:00'
	select @p2 as '@pnIdRecepFacturaMaquilador'

	exec OPESch.OPE_CU445_Pag18_Grid_Boletas_IU 
		@pnClaUbicacion=326
		,@pnIdRecepFacturaMaquilador=281
		,@psNombrePcMod='100-Hvalle'
		,@pnClaUsuarioMod=100010318
		,@pnIdRecepOrdenMaquila=356
		,@pnIncluir=1

	exec OPESch.OPE_CU445_Pag18_Grid_Deducciones_IU 
		@pnIncluir=1
		,@pnClaUbicacion=326
		,@pnClaMaquilador=5
		,@pnIdDeduccionMaquilador=1
		,@pnClaTipoCobroMalaCalidad=1
		,@pnImporteTotal=6232.0000
		,@pnImportePorPagar=6232.0000
		,@psObservaciones=NULL
		,@pnIdRecepFacturaMaquilador=281
		,@pnClaTipoDeduccionMaquilador=default
		,@pnSaldoPendientePorPagar=6232.0000
		,@psReferencia='Devolución'
		,@pnClaEstatus=1
		,@pnClaEstatusRel=1
		,@psNombrePcMod='100-Hvalle'
		,@pnClaUsuarioMod=100010318
		,@pnAccionSp=2
		,@psIdioma='Spanish'
		,@pnClaIdioma=default
		,@pnEsDebug=default

	declare @p22 int
	set @p22=281
	declare @p3 varchar(12)
	set @p3='281'
	exec OPESch.OPE_CU445_Pag18_Boton_SAVE_Proc 
		@pnClaUbicacion=326
		,@pnIdRecepFacturaMaquilador=@p22 output
		,@psFacturaMaquilador=@p3 output
		,@pnClaMaquilador=5
		,@pnClaUsuarioMod=100010318
		,@psNombrePcMod='100-Hvalle'
		,@psIdioma='Spanish'
		,@pnClaIdioma=default
		,@nEsDebug=default
	select @p22, @p3

ROLLBACK TRAN

