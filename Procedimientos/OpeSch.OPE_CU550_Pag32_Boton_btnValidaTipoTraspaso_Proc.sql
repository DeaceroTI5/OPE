USE  Operacion
GO
--	'OpeSch.OPE_CU550_Pag32_Boton_btnValidaTipoTraspaso_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Boton_btnValidaTipoTraspaso_Proc
    @pnClaUbicacion         INT,	
    @pnClaPedidoOrigen	    INT = 0,
    @pnCmbPlantaPide	    INT = 0,
    @pnCmbPlantaSurte	    INT = 0, 
    @pnChkSuministroDirecto	INT = 0,
	@pnChkDoorToDoor		INT = 0,
    @ptFechaDefault         DATETIME,
    @pnClaTipoTraspaso	    INT OUT, -- 0: No Muestra Resultados / 1: Escenario Traspaso Muestra El Cliente Declarado para Ubicacion Pide / 2: Escenario Compra Filial para MP Muestra Los Clientes Declarados para Relación Filial / 3: Escenario Compra Filial para SM Muestra Los Clientes Declarados para Relación Filial
    @ptFechaDesea           DATETIME OUT
AS
BEGIN

	SET NOCOUNT ON

    DECLARE @nClaEmpresaPide    INT = 0,
            @nClaEmpresaSurte   INT = 0

    SELECT  @pnCmbPlantaPide        = ISNULL( @pnCmbPlantaPide,0 ),
            @pnCmbPlantaSurte       = ISNULL( @pnCmbPlantaSurte,0 ),
            @pnChkSuministroDirecto = ISNULL( @pnChkSuministroDirecto,0 ),
            @pnClaTipoTraspaso      = ISNULL( @pnClaTipoTraspaso,0 ),
			@pnChkDoorToDoor		= ISNULL( @pnChkDoorToDoor,0 )

    IF ( @pnCmbPlantaPide > 0 AND @pnCmbPlantaSurte > 0 ) 
    BEGIN
        SELECT  @nClaEmpresaPide = ClaEmpresa
        FROM    OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
        WHERE   ClaUbicacion = @pnCmbPlantaPide

        SELECT  @nClaEmpresaSurte = ClaEmpresa
        FROM    OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
        WHERE   ClaUbicacion = @pnCmbPlantaSurte

        IF ( @nClaEmpresaPide = @nClaEmpresaSurte )
        BEGIN
            SELECT  @pnClaTipoTraspaso = 1
        END 
        ELSE IF ( @nClaEmpresaPide != @nClaEmpresaSurte AND @pnChkSuministroDirecto = 0 AND @pnChkDoorToDoor = 0 )
        BEGIN
            SELECT  @pnClaTipoTraspaso = 2
        END 
        ELSE IF ( @nClaEmpresaPide != @nClaEmpresaSurte AND @pnChkSuministroDirecto = 1 )
        BEGIN
            SELECT  @pnClaTipoTraspaso = 3
            
			IF ( @pnClaPedidoOrigen > 0 )
            BEGIN
                SELECT  @ptFechaDesea = (CASE
                                            WHEN    ISNULL( ClaEstatus,0 ) = 1 AND @pnClaTipoTraspaso = 3 AND @ptFechaDefault <= FechaPromesaOrigen
                                            THEN    FechaPromesaOrigen
                                            ELSE    @ptFechaDesea 
                                        END)
                FROM    OpeSch.OpeTraFabricacionVw WITH(NOLOCK)  
                WHERE   IdFabricacion = @pnClaPedidoOrigen
            END
        END 
        ELSE IF ( @nClaEmpresaPide != @nClaEmpresaSurte AND @pnChkDoorToDoor = 1 )
        BEGIN
            SELECT  @pnClaTipoTraspaso = 4
        
			--IF ( @pnClaPedidoOrigen > 0 )
   --         BEGIN
   --             SELECT  @ptFechaDesea = (CASE
   --                                         WHEN    ISNULL( ClaEstatus,0 ) = 1 AND @pnClaTipoTraspaso = 3 AND @ptFechaDefault <= FechaPromesaOrigen
   --                                         THEN    FechaPromesaOrigen
   --                                         ELSE    @ptFechaDesea 
   --                                     END)
   --             FROM    OpeSch.OpeTraFabricacionVw WITH(NOLOCK)  
   --             WHERE   IdFabricacion = @pnClaPedidoOrigen
   --         END
        END 
        ELSE 
        BEGIN
            SELECT  @pnClaTipoTraspaso = 0
        END 
    END  

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPE_CU550_Pag32_Boton_btnValidaTipoTraspaso_Proc) no puede ser procesado.', 16, 1)        

END