USE Operacion
GO
ALTER PROCEDURE OpeSch.OPETraspasosClienteCmb
    @psValor                VARCHAR(100),   -- Texto a Buscar
	@pnTipo                 INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN       INT = 0,    
	@pnBajasSn	            INT = 0,
    @pnClaTipoTraspaso	    INT = 0,        -- 0: No Muestra Resultados / 1: Escenario Traspaso Muestra El Cliente Declarado para Ubicacion Pide 
    @pnCmbPlantaPide	    INT = 0,			-- / 2: Escenario Compra Filial para MP Muestra Los Clientes Declarados para Relación Filial 
    @pnCmbPlantaSurte	    INT = 0,			-- / 3: Escenario Compra Filial para SM Muestra Los Clientes Declarados para Relación Filial
	@pnDebug				TINYINT = 0
AS
BEGIN

	SET NOCOUNT ON
    
-- exec OPESch.OPETraspasosClienteCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=1,@pnBajasSn=default,@pnClaTipoTraspaso=0,@pnCmbPlantaPide=NULL,@pnCmbPlantaSurte=NULL, @pnDebug = 0
-- exec OPESch.OPETraspasosClienteCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=1,@pnBajasSn=default,@pnClaTipoTraspaso=1,@pnCmbPlantaPide=7,@pnCmbPlantaSurte=NULL, @pnDebug = 0
-- exec OPESch.OPETraspasosClienteCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=0,@pnBajasSn=default,@pnClaTipoTraspaso=2,@pnCmbPlantaPide=324,@pnCmbPlantaSurte=7, @pnDebug = 0



	DECLARE @tbTempClientesIngetek TABLE (
		  Id			INT IDENTITY(1,1)
		, ClaCliente	INT
		, NomCliente	VARCHAR(80)
	)

	IF @pnIncluirTodosSN  = 1 AND @pnTipo <> 99            
	BEGIN
		INSERT INTO @tbTempClientesIngetek SELECT -1, 'Todos' 
	END

	IF @pnClaTipoTraspaso = 0		-- General
	BEGIN
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN
			INSERT INTO @tbTempClientesIngetek (ClaCliente, NomCliente)
			SELECT	TOP 500
					ClaCliente = ClaCliente,          
					NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NombreCliente))    
			FROM	OpeSch.OpeVtaCatClienteVw WITH(NOLOCK)        
		END              
        ELSE IF @PnTipo IN (1,99)                
		BEGIN 
			INSERT INTO @tbTempClientesIngetek (ClaCliente, NomCliente)
			SELECT	TOP 500
					ClaCliente = ClaCliente,          
					NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NombreCliente))    
			FROM	OpeSch.OpeVtaCatClienteVw x WITH(NOLOCK)               
			WHERE	ClaCliente = CONVERT(INT,@psValor)    
		END              
		ELSE            
		BEGIN
			INSERT INTO @tbTempClientesIngetek (ClaCliente, NomCliente)
			SELECT	TOP 500
					ClaCliente = ClaCliente,          
					NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NombreCliente))    
			FROM	OpeSch.OpeVtaCatClienteVw WITH(NOLOCK)               
			WHERE	NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
		END

		SELECT ClaCliente, NomCliente FROM @tbTempClientesIngetek

		RETURN	-- Termina
	END			-- @pnClaTipoTraspaso = 0		-- General

    ELSE IF ( @pnClaTipoTraspaso = 1 AND @pnCmbPlantaPide > 0 )
    BEGIN
        INSERT INTO @tbTempClientesIngetek
		SELECT	a.ClaCliente,
                a.NomCliente        
        FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
        INNER JOIN  OpeSch.OpeTiCatUbicacionVw b WITH(NOLOCK)  
            ON  a.ClaCliente = b.ClaCliente
        WHERE	b.ClaUbicacion = @pnCmbPlantaPide
    END
    ELSE IF ( @pnClaTipoTraspaso IN (2,3) AND @pnCmbPlantaPide > 0 AND @pnCmbPlantaSurte > 0 )
    BEGIN
        INSERT INTO @tbTempClientesIngetek
		SELECT	a.ClaCliente,
                a.NomCliente     
        FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
        INNER JOIN  OpeSch.OpeCatClienteFilialVw b WITH(NOLOCK)  
            ON  a.ClaCliente = b.ClaClienteFilial
        WHERE	b.ClaUbicacionOrigen = @pnCmbPlantaSurte
        AND     b.ClaUbicacionDestino = @pnCmbPlantaPide
    END

	IF @pnDebug = 1
		SELECT '' AS '@pnDebug', * FROM @tbTempClientesIngetek
	-----------------------------------------------------------------------------------

	IF @psValor IS NULL OR @psValor = ''              
    BEGIN              
		SELECT	TOP 500
				ClaCliente = ClaCliente,          
				NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
		FROM	@tbTempClientesIngetek x        
	END              
    ELSE IF @PnTipo IN (1,99)                
	BEGIN                      
		SELECT	TOP 500
				ClaCliente = ClaCliente,          
				NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
		FROM	@tbTempClientesIngetek x              
		WHERE	ClaCliente = CONVERT(INT,@psValor)    
	END              
	ELSE            
	BEGIN                          
		SELECT	TOP 500
				ClaCliente = ClaCliente,          
				NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
		FROM	@tbTempClientesIngetek x          
		WHERE	NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
	END   
	
	SET NOCOUNT OFF
END