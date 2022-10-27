---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--*----
--*Objeto:		PloImprimeFacturaSrv
--*Autor:	   	Luis F Verastegui
--*Fecha:		27 ABR 2010
--*Objetivo:	
--*Entrada:		@pnFormato	smallint,
--*				@pnClaUbicacion	int,
--*				@pnIdViaje	int,
--*				@pnIdRemision	int,
--*				@psRutaImpresora1	varchar(50),
--*				@psCopiasRemision	varchar(6),
--*				@psCopiasEntSalBodegas	varchar(6) = null,
--*Salida:		@pnResultado - Parametro de Resultado
--*Precondiciones:
--*Revisiones:  
--*                  Creacion de Procedimiento - /001 - 27 ABR 2010
--*					 SCH - Se cambia el nombre del srv y parametros
--*----	
 
CREATE PROCEDURE OpeSch.OpeImprimeFacturaSrv
		@pnFormato	smallint,
		@pnClaUbicacion	int,
		@pnIdViaje	int,
		@pnIdRemision	int,
		@psRutaImpresora1	varchar(50),
		@psCopiasRemision	varchar(6),
		@psCopiasEntSalBodegas	varchar(6) = null,
		@pnResultado	int = null output
As
--* Declaracion de variables locales 
DECLARE @sConexionRemota		VARCHAR(1000),
--	@pnClaUbicacion			INT,
	@pnClaSistema			INT,
	@psNombreClave			VARCHAR(50),
	@psObjetoRemoto			VARCHAR(50)
 
--SET @pnClaUbicacion = 5
SET @pnClaSistema = 19
SET @psNombreClave = 'VTA'
SET @psObjetoRemoto = 'VtaImprimeRemisionSrv'
 
--* Obtener conexion remota de InvIntInsertaMovEncSrv para ejecucion 
	SET @sConexionRemota = OpeSch.OpeConexionRemotaFn(@pnClaUbicacion, @pnClaSistema, @psNombreClave, @psObjetoRemoto)
 
--* Declaracion de variables Para Ejecucion Remota
--* N/A
 

 	-- Ubicacion de Ventas
	DECLARE @nClaUbicacionVentas INT
	
	SELECT	@nClaUbicacionVentas = ClaUbicacionVentas 
	FROM	OpeSch.OpeTiCatUbicacionVw 
	WHERE	ClaUbicacion		= @pnClaUbicacion


--* Se Executa para Select de Vista Remota
                EXEC @sConexionRemota 						
						@pnFormato	= @pnFormato,
						@pnClaUbicacion	= @nClaUbicacionVentas,--@pnClaUbicacion,
						@pnIdViaje	= @pnIdViaje,
						@pnIdRemision =	@pnIdRemision,
						@psRutaImpresora1 =	@psRutaImpresora1,
						@psCopiasRemision = @psCopiasRemision,
						@psCopiasEntSalBodegas	 = @psCopiasEntSalBodegas,
						@pnResultado	 = @pnResultado output
				