--EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag30_Boton_BtnGenerarCertificado_Proc'
--EXEC SP_HELPTEXT 'OpeSch.OPE_CU74_Pag1_ObtenCertificadoAceriasCedis_Proc'

DECLARE
	@sMensajeError			VARCHAR(500),
	@nNumError				INT,
	@sIdCertificado			VARCHAR(1000)


	SELECT	a.ClaUbicacion AS ClaUbicacionFilial,
			NumFacturaFilial,
			IdFacturaFilial,
			ClaUbicacionOrigen,
			NumFacturaOrigen,
			IdFacturaOrigen,
			MensajeError,
			ClaTipoUbicacion
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	LEFT JOIN OPESch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacion = b.ClaUbicacion
	WHERE    NumFacturaFilial IN ('QM403','QN3611')

	SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado
	WHERE	IdFactura IN (50398820, 50399234)

	SELECT * FROM DEAOFINET04.Operacion.ACESch.AceTraCertificado
	WHERE	IdFactura IN (1033000403, 1034003611)

-------------------------

	SELECT  IdCertificado, ClaUbicacionAceria, IdFabricacion, ClaArticulo, IdColada, Secuencia, ClaMolino, ClaHorno, IdFactura, IdFacturaAlfanumerico--, SUM(CantEmbarcada), SUM(PesoEmbarcado )
	FROM	OpeSch.OpeTraPlanCargaColada CS WITH(NOLOCK)
	WHERE	CS.IdPlanCarga = 331053--@pnIdPlanCargaAux  

	SELECT  IdCertificado, ClaUbicacionAceria, IdFabricacion, ClaArticulo, IdColada, Secuencia, ClaMolino, ClaHorno, IdFactura, IdFacturaAlfanumerico--, SUM(CantEmbarcada), SUM(PesoEmbarcado )
	FROM	OpeSch.OpeTraPlanCargaColada CS WITH(NOLOCK)
	WHERE	CS.IdPlanCarga = 331449--@pnIdPlanCargaAux  

	SELECT  IdCertificado, ClaUbicacionAceria, IdFabricacion, ClaArticulo, IdColada, Secuencia, ClaMolino, ClaHorno, IdFactura, IdFacturaAlfanumerico--, SUM(CantEmbarcada), SUM(PesoEmbarcado )
	FROM	OpeSch.OpeTraPlanCargaColada CS WITH(NOLOCK)
	where	idfacturaalfanumerico in ('QM403','QN3611','H398820','H399234')


	select * from OpeSch.OpeTraViaje WITH(NOLOCK) where idviaje in (283632,283888)
	select * from OpeSch.OpeTraPlanCarga WITH(NOLOCK) where IdPlanCarga in (331053,331449)


--	EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoPuntoLogisticoSrv
--		 @pnClaUbicacion		= 323			--@nClaUbicacionFilial,
--		,@pnIdFactura			= 1033000403	--@nIdFacturaFilial,
--		,@pnClaUbicacionOrigen	= 150			--@nClaUbicacionOrigen,
--		,@pnIdFacturaOrigen		= 50398820		--@nIdFacturaOrigen,
--		,@pnEsRegeneraCertificado = 0			--@nEsRegeneraCertificado,
--		,@psNombrePcMod			= 'GeneraCertificadoFilial'
--		,@pnClaUsuarioMod		= 1
--		,@psIdCertificado		= @sIdCertificado	OUT
--		,@pnClaEstatus			= @nNumError		OUT
--		,@psMensajeError		= @sMensajeError	OUT


--	EXEC DEAOFINET04.Operacion.ACESch.AceGeneraCertificadoPuntoLogisticoSrv
--		 @pnClaUbicacion		= 324			--@nClaUbicacionFilial,
--		,@pnIdFactura			= 1034003611	--@nIdFacturaFilial,
--		,@pnClaUbicacionOrigen	= 150			--@nClaUbicacionOrigen,
--		,@pnIdFacturaOrigen		= 50399234		--@nIdFacturaOrigen,
--		,@pnEsRegeneraCertificado = 0			--@nEsRegeneraCertificado,
--		,@psNombrePcMod			= 'GeneraCertificadoFilial'
--		,@pnClaUsuarioMod		= 1
--		,@psIdCertificado		= @sIdCertificado	OUT
--		,@pnClaEstatus			= @nNumError		OUT
--		,@psMensajeError		= @sMensajeError	OUT

----DEAOFINET04
--begin tran
 
--    declare @pnError int
--    declare @psMensajeError varchar(5000)
 
--    -- LLAMA EL SERVICIO 
--    EXEC      /*LNK_ACE_CERT.*/Operacion.AceSch.AceRecibeDatosCertificadoPLSrv
--    @pnClaUbicacion      = 323  
--    ,@pnIdViaje           = 283632 
--    ,@pnIdFabricacion    = 24391558
--    ,@pnIdFactura         = 1033000403
--    ,@psNumFactura        = 'QM403'
--    ,@pnNumPlan           = 331053
--    ,@pdFechaViaje        = '2023-02-01 09:40:41.383'
--    ,@pnClaHornoFusion   = 23
--    ,@pnIdColada          = 62525
--    ,@pnClaMolino         = 7
--    ,@pnIdSecuencia       = 70362       
--    ,@pnClaUbicacionAce  = 22
--    ,@pnClaArticulo       = 716799      
--    ,@pnCantidad          = 12.0000
--    ,@pnPesoEmbarque      = 20411.6400
--    ,@psNombrePcMod       = ''     
--    ,@pnClausuarioMod    = -1
--    ,@pnError=@pnError      OUTPUT 
--    ,@psMensajeError=@psMensajeError      OUTPUT
                            
 
--    -- GENERA LOS CERTIFICADOS   
--    EXEC /*LNK_ACE_CERT.*/Operacion.AceSch.AceGeneraCertificadoPLSrv 
--    @pnClaUbicacion = 325      
--    ,@pnIdViaje    = 5859        
--    ,@pnIdFabricacion = 24393003
--    ,@psNombrePcMod       = ''     
--    ,@pnClausuarioMod    = -1
--    ,@pnError=@pnError      OUTPUT 
--    ,@psMensajeError=@psMensajeError      OUTPUT
 
--rollback tran

