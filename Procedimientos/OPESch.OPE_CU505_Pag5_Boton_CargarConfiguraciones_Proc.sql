---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--*==============================================================
--*Objeto:		'OPESch.OPE_CU505_Pag5_Boton_CargarConfiguraciones_Proc'
--*Autor:		Luis F Verastegui
--*Fecha:		14/12/2015
--*Objetivo:	
--*Entrada:
--*Salida:
--*Precondiciones:
--*Revisiones: 
--*==============================================================
USE Operacion
GO
ALTER PROCEDURE OPESch.OPE_CU505_Pag5_Boton_CargarConfiguraciones_Proc
	@pnClaUbicacion int,
	@pnEsInvocada INT
AS
Begin
	Set Nocount on

		Declare @pdFechaInicial datetime, @pdFechaFinal datetime, @pnClaTipoInventario  int, @pnClaFamiliaAlambron int, @nEsVisible tinyint, @nEsEstimacionActivo TINYINT
		Select @pdFechaInicial = Getdate() , @pdFechaFinal = getdate()
							
		--	Clave Familia Int.Alambron
		SELECT  @pnClaFamiliaAlambron  = NumValor1 
		FROM OpeSch.OpecfgParametroNeg WITH (NOLOCK)
		WHERE   ClaUbicacion = @pnClaUbicacion 
		AND ClaParametro = 17
		
		-- 	Tipo de Inventario de PT					
		SELECT @pnClaTipoInventario = nValor1
		from TiCatConfiguracionVw (NOLOCK)   
		where ClaSistema = 127 and    
		ClaUbicacion = @pnClaUbicacion and    
		ClaConfiguracion = 11   

		-- 	Ubicación utiliza el concepto de Ship ID				
		SELECT	@nEsVisible = nValor1
		from	OPESch.OpeTiCatConfiguracionVw (NOLOCK)   
		where	ClaSistema = 127 
		and		ClaUbicacion = @pnClaUbicacion 
		and		ClaConfiguracion = 1271222
		AND		BajaLogica = 0

		--*	Ubicación utiliza Módulo de Estimaciones
		SELECT	  @nEsEstimacionActivo	= nValor1
		from	OPESch.OpeTiCatConfiguracionVw (NOLOCK)   
		where	ClaSistema = 127 
		and		ClaUbicacion = @pnClaUbicacion 
		and		ClaConfiguracion = 1271221
		AND		BajaLogica = 0


		IF(@pnEsInvocada = 0)
		BEGIN
			Select @pdFechaInicial as FechaInicial, @pdFechaFinal as FechaFinal,
					@pnClaTipoInventario as ClaTipoInventario,
					@pnClaFamiliaAlambron as ClaFamiliaAlambron
					, EsVisible = isnull(@nEsVisible,0)
					, EsEstimacionActivo = ISNULL(@nEsEstimacionActivo,0)
		END
		ELSE
		BEGIN
			SELECT 1
		END
				
	Set Nocount off
End