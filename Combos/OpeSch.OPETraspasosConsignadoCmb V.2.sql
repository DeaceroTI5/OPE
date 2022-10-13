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
	@pnwtk0					INT = NULL
AS
BEGIN

	SET NOCOUNT ON
    
    IF OBJECT_ID('TEMPDB..#TempConsignadoIngetek') IS NOT NULL
		DROP TABLE #TempConsignadoIngetek


	CREATE TABLE #TempConsignadoIngetek(
		  Id				INT IDENTITY(1,1)
		, ClaConsignado		INT
		, NombreConsignado	VARCHAR(50)
	)

	IF @pnClaTipoTraspaso = 0		-- General
	BEGIN
		IF @pnIncluirTodosSN = 1
			INSERT INTO #TempConsignadoIngetek SELECT -1, 'Todos' 
		
		IF @PnTipo NOT IN (1,99) 
		BEGIN
			INSERT INTO #TempConsignadoIngetek
			SELECT	TOP 500 
					a.ClaConsignado, a.NombreConsignado
			FROM	Opesch.OpeVtaRelClienteConsignadoVw a
			WHERE	ClaCliente = @pnwtk0
			AND		(ISNULL(@psValor,'')= '' 
						OR (@pnTipo NOT IN (1,99) AND a.NombreConsignado LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'  ))
			AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
		END
		ELSE IF @PnTipo IN (1,99)
		BEGIN
		INSERT INTO #TempConsignadoIngetek
			SELECT	TOP 500 
					a.ClaConsignado, a.NombreConsignado
			FROM	Opesch.OpeVtaRelClienteConsignadoVw a
			WHERE	ClaCliente = @pnwtk0
			AND		(ISNULL(@psValor,'')= '' 
						OR (@pnTipo IN (1,99) AND a.ClaConsignado = CONVERT(INT,@psValor))
					)
			AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
		END 

		SELECT	ClaConsignado, NomConsignado = NombreConsignado FROM #TempConsignadoIngetek ORDER BY ClaConsignado
		RETURN
	END

    IF ( @pnClaTipoTraspaso = 2 AND @pnCmbCliente > 0 )
    BEGIN
        INSERT INTO	#TempConsignadoIngetek
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
        INSERT INTO	#TempConsignadoIngetek
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

	IF @pnIncluirTodosSN  = 0              
	BEGIN                 
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN              
			SELECT	ClaConsignado = ClaConsignado,          
					NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
			FROM	#TempConsignadoIngetek x WITH(NOLOCK)        
		END              
        ELSE                 
	        IF @PnTipo IN (1,99)                
			BEGIN                      
				SELECT	ClaConsignado = ClaConsignado,          
						NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
				FROM	#TempConsignadoIngetek x WITH(NOLOCK)               
				WHERE	ClaConsignado = CONVERT(INT,@psValor)    
			END              
			ELSE            
			BEGIN                          
				SELECT	ClaConsignado = ClaConsignado,          
						NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
				FROM	#TempConsignadoIngetek x WITH(NOLOCK)               
				WHERE	NombreConsignado LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
			END                  
	END              
    ELSE    -- @pnIncluirTodosSN  = 1              
    BEGIN              
		IF (@psValor IS NULL OR @psValor = '')    
        BEGIN                                      
 			SELECT	ClaConsignado = ClaConsignado,          
					NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
			FROM	#TempConsignadoIngetek x WITH(NOLOCK)         
            UNION              
            SELECT -1, 'Todos'                                 
		END              
        ELSE                 
			IF (@PnTipo IN (99))    
			BEGIN                       
 				SELECT	ClaConsignado = ClaConsignado,          
						NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
				FROM	#TempConsignadoIngetek x WITH(NOLOCK)               
				WHERE	ClaConsignado = CONVERT(INT,@psValor)         
 			--	UNION              
				--SELECT -1, 'Todos'                                             
			END    
			ELSE
			IF (@PnTipo IN (1))    
			BEGIN                       
 				SELECT	ClaConsignado = ClaConsignado,          
						NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
				FROM	#TempConsignadoIngetek x WITH(NOLOCK)               
				WHERE	ClaConsignado = CONVERT(INT,@psValor)         
 				UNION              
				SELECT -1, 'Todos'                                             
			END    
			ELSE                  
			BEGIN                 
 				SELECT	ClaConsignado = ClaConsignado,          
						NomConsignado = CONVERT(VARCHAR(10),ClaConsignado) + ' - '  + LTRIM(RTRIM(NombreConsignado))    
				FROM	#TempConsignadoIngetek x WITH(NOLOCK)               
				WHERE	NombreConsignado LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
				UNION              
				SELECT -1, 'Todos'                                                   
			END                       
	END           
	
	DROP TABLE #TempConsignadoIngetek
	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosConsignadoCmb) no puede ser procesado.', 16, 1)        

END