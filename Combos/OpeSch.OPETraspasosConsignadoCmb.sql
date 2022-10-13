USE Operacion
GO
ALTER PROCEDURE OpeSch.OPETraspasosConsignadoCmb
    @psValor                VARCHAR(100),   -- Texto a Buscar
	@pnTipo                 INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN       INT = 0,    
	@pnBajasSn	            INT = 0,
    @pnCmbCliente	        INT = 0,        
    @pnClaTipoTraspaso	    INT = 0,        -- 0: No Muestra Resultados / 1: Escenario Traspaso Muestra El Cliente Declarado para Ubicacion Pide 
    @pnCmbPlantaPide	    INT = 0,			-- / 2: Escenario Compra Filial para MP Muestra Los Clientes Declarados para Relación Filial 
    @pnCmbPlantaSurte	    INT = 0,			-- --/ 3: Escenario Compra Filial para SM Muestra Los Clientes Declarados para Relación Filial
    @pnClaSolicitud	        INT = 0,
	@pnwtk0					INT = NULL,
	@pnDebug				TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

-- exec OPESch.OPETraspasosConsignadoCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=1,@pnBajasSn=default,@pnCmbCliente=default,@pnClaTipoTraspaso=default,@pnCmbPlantaPide=NULL,@pnCmbPlantaSurte=NULL,@pnClaSolicitud=NULL,@pnwtk0=24, @pnDebug = 0
-- exec OPESch.OPETraspasosConsignadoCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=1,@pnBajasSn=default,@pnCmbCliente=114303,@pnClaTipoTraspaso=2,@pnCmbPlantaPide=7,@pnCmbPlantaSurte=11,@pnClaSolicitud=NULL,@pnwtk0=-2, @pnDebug = 0
-- exec OPESch.OPETraspasosConsignadoCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=1,@pnBajasSn=default,@pnCmbCliente=818613,@pnClaTipoTraspaso=3,@pnCmbPlantaPide=324,@pnCmbPlantaSurte=7,@pnClaSolicitud=5,@pnwtk0=-2, @pnDebug = 0
    
	DECLARE @tbTempConsignadoIngetek TABLE(
		  Id				INT IDENTITY(1,1)
		, ClaConsignado		INT
		, NomConsignado		VARCHAR(70)
	)

	IF @pnIncluirTodosSN  = 1 AND @pnTipo <> 99            
	BEGIN
		INSERT INTO @tbTempConsignadoIngetek SELECT -1, 'Todos' 
	END

	IF ISNULL(@pnwtk0,0) <> 0 AND ISNULL(@pnCmbCliente,0) = 0
		SELECT @pnCmbCliente = @pnwtk0

	IF @pnDebug = 1
		SELECT @pnCmbCliente AS '@pnCmbCliente', @pnwtk0 AS '@pnwtk0'
	
	-----------------------------------------------------------------------
	IF @pnClaTipoTraspaso = 0		-- General
	BEGIN	
		IF @psValor IS NULL OR @psValor = ''              
		BEGIN
			INSERT INTO @tbTempConsignadoIngetek (ClaConsignado, NomConsignado)
			SELECT	TOP 500
					ClaConsignado = ClaConsignado,          
					NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
			FROM	Opesch.OpeVtaRelClienteConsignadoVw a 
			WHERE	ClaCliente = @pnCmbCliente
		END              
		ELSE IF @PnTipo IN (1,99)                
		BEGIN
			INSERT INTO @tbTempConsignadoIngetek (ClaConsignado, NomConsignado)
			SELECT	TOP 500
					ClaConsignado = ClaConsignado,          
					NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
			FROM	Opesch.OpeVtaRelClienteConsignadoVw a               
			WHERE	ClaCliente = @pnCmbCliente
			AND		ClaConsignado = CONVERT(INT,@psValor)    
		END              
		ELSE            
		BEGIN
			INSERT INTO @tbTempConsignadoIngetek (ClaConsignado, NomConsignado)
			SELECT	TOP 500
					ClaConsignado = ClaConsignado,          
					NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
			FROM	Opesch.OpeVtaRelClienteConsignadoVw a              
			WHERE	ClaCliente = @pnCmbCliente
			AND		NombreConsignado LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
		END 
		
		SELECT ClaConsignado, NomConsignado FROM @tbTempConsignadoIngetek
		
		RETURN	---- Termina
	END			-- @pnClaTipoTraspaso = 0		-- General
	ELSE IF ( @pnClaTipoTraspaso = 2 AND @pnCmbCliente > 0 )
    BEGIN
        INSERT INTO	@tbTempConsignadoIngetek
		SELECT	a.ClaConsignado,
                a.NombreConsignado
        FROM	OpeSch.OpeVtaCatConsignadoVw a WITH(NOLOCK)  
        INNER JOIN  OpeSch.OpeCatClienteFilialVw b WITH(NOLOCK)  
            ON  a.ClaConsignado = b.ClaConsignado
        WHERE	b.ClaUbicacionOrigen = @pnCmbPlantaSurte
        AND     b.ClaUbicacionDestino = @pnCmbPlantaPide
        AND     b.ClaClienteFilial = @pnCmbCliente
    END
    ELSE IF ( @pnClaTipoTraspaso = 3 AND @pnClaSolicitud > 0)
    BEGIN
        INSERT INTO	@tbTempConsignadoIngetek
		SELECT	a.ClaConsignado,
                a.NombreConsignado
        FROM	OpeSch.OpeVtaCatConsignadoVw a WITH(NOLOCK)  
        INNER JOIN  OpeSch.OpeTraSolicitudTraspasoEncVw b WITH(NOLOCK)  
            ON  a.ClaConsignado = b.ClaConsignado
        WHERE	b.ClaUbicacionSurte = @pnCmbPlantaSurte
        AND     b.ClaUbicacionSolicita = @pnCmbPlantaPide
        AND     b.ClaCliente = @pnCmbCliente
        AND     b.IdSolicitudTraspaso = @pnClaSolicitud
    END
	
	IF @pnDebug = 1
		SELECT '' AS '@pnDebug', * FROM @tbTempConsignadoIngetek
	------------------------------------------------------------------------------------------------------
	
	IF @psValor IS NULL OR @psValor = ''              
    BEGIN              
		SELECT	ClaConsignado = ClaConsignado,          
				NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NomConsignado))    
		FROM	@tbTempConsignadoIngetek x        
	END              
    ELSE                 
	IF @PnTipo IN (1,99)                
	BEGIN                      
		SELECT	ClaConsignado = ClaConsignado,          
				NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NomConsignado))    
		FROM	@tbTempConsignadoIngetek x                
		WHERE	ClaConsignado = CONVERT(INT,@psValor)    
	END              
	ELSE            
	BEGIN                          
		SELECT	ClaConsignado = ClaConsignado,          
				NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NomConsignado))    
		FROM	@tbTempConsignadoIngetek x                
		WHERE	NomConsignado LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
	END                                  

	SET NOCOUNT OFF              
END