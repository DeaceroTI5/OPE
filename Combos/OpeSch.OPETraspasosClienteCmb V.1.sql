USE Operacion
GO
ALTER PROCEDURE OpeSch.OPETraspasosClienteCmb
    @psValor                VARCHAR(100),   -- Texto a Buscar
	@pnTipo                 INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN       INT = 0,    
	@pnBajasSn	            INT = 0,
    @pnClaTipoTraspaso	    INT = 0,        -- 0: No Muestra Resultados / 1: Escenario Traspaso Muestra El Cliente Declarado para Ubicacion Pide 
    @pnCmbPlantaPide	    INT = 0,			-- / 2: Escenario Compra Filial para MP Muestra Los Clientes Declarados para Relación Filial 
    @pnCmbPlantaSurte	    INT = 0				-- / 3: Escenario Compra Filial para SM Muestra Los Clientes Declarados para Relación Filial
AS
BEGIN

	SET NOCOUNT ON
    
    IF OBJECT_ID('TEMPDB..#TempClientesIngetek') IS NOT NULL
		DROP TABLE #TempClientesIngetek
	
	-- exec OPESch.OPETraspasosClienteCmb @psValor='h',@pnTipo=2,@pnIncluirTodosSN=1,@pnBajasSn=default,@pnClaTipoTraspaso=default,@pnCmbPlantaPide=NULL,@pnCmbPlantaSurte=NULL

	CREATE TABLE #TempClientesIngetek(
		  Id			INT IDENTITY(1,1)
		, ClaCliente	INT
		, NomCliente	VARCHAR(60)
	)

	IF @pnClaTipoTraspaso = 0		-- General
	BEGIN
		IF @pnIncluirTodosSN  = 1 
			INSERT INTO #TempClientesIngetek SELECT -1, 'Todos' 
		

		IF @PnTipo NOT IN (1,99) 
		BEGIN
			INSERT INTO #TempClientesIngetek
			SELECT	TOP 500
					a.ClaCliente,
					a.NomCliente
			FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
			WHERE	(	(ISNULL(@psValor,'')= '' )
						OR (@pnTipo NOT IN (1,99) AND NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'  ))
			AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
		END
		ELSE IF @PnTipo IN (1,99) 
		BEGIN
			INSERT INTO #TempClientesIngetek
			SELECT	TOP 500
					a.ClaCliente,
					a.NomCliente
			FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
			WHERE	(	(ISNULL(@psValor,'')= '' )
						OR (@pnTipo IN (1,99) AND ClaCliente = CONVERT(INT,@psValor))
					)
			AND		(ISNULL(BajaLogica, 0) != 1  OR ISNULL(@pnBajasSn,0) = 1) 
		END




		SELECT ClaCliente,NomCliente  FROM #TempClientesIngetek ORDER BY ClaCliente
		RETURN
	END

    IF ( @pnClaTipoTraspaso = 1 AND @pnCmbPlantaPide > 0 )
    BEGIN
        INSERT INTO #TempClientesIngetek
		SELECT	a.ClaCliente,
                a.NomCliente        
        FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
        INNER JOIN  OpeSch.OpeTiCatUbicacionVw b WITH(NOLOCK)  
            ON  a.ClaCliente = b.ClaCliente
        WHERE	b.ClaUbicacion = @pnCmbPlantaPide
    END
    ELSE IF ( @pnClaTipoTraspaso IN (2,3) AND @pnCmbPlantaPide > 0 AND @pnCmbPlantaSurte > 0 )
    BEGIN
        INSERT INTO #TempClientesIngetek
		SELECT	a.ClaCliente,
                a.NomCliente     
        FROM	OpeSch.OpeVtaCatClienteVw a WITH(NOLOCK)  
        INNER JOIN  OpeSch.OpeCatClienteFilialVw b WITH(NOLOCK)  
            ON  a.ClaCliente = b.ClaClienteFilial
        WHERE	b.ClaUbicacionOrigen = @pnCmbPlantaSurte
        AND     b.ClaUbicacionDestino = @pnCmbPlantaPide
    END

	IF @pnIncluirTodosSN  = 0              
	BEGIN                 
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN              
			SELECT	ClaCliente = ClaCliente,          
					NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
			FROM	#TempClientesIngetek x WITH(NOLOCK)        
		END              
        ELSE                 
	        IF @PnTipo IN (1,99)                
			BEGIN                      
				SELECT	ClaCliente = ClaCliente,          
						NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
				FROM	#TempClientesIngetek x WITH(NOLOCK)               
				WHERE	ClaCliente = CONVERT(INT,@psValor)    
			END              
			ELSE            
			BEGIN                          
				SELECT	ClaCliente = ClaCliente,          
						NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
				FROM	#TempClientesIngetek x WITH(NOLOCK)               
				WHERE	NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
			END                  
	END              
    ELSE	-- @pnIncluirTodosSN  = 1        
    BEGIN              
		IF (@psValor IS NULL OR @psValor = '')    
        BEGIN                                      
 			SELECT	ClaCliente = ClaCliente,          
					NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
			FROM	#TempClientesIngetek x WITH(NOLOCK)         
            UNION              
            SELECT -1, 'Todos'                                 
		END              
        ELSE                 
			IF (@PnTipo IN (99))    
			BEGIN                       
 				SELECT	ClaCliente = ClaCliente,          
						NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
				FROM	#TempClientesIngetek x WITH(NOLOCK)               
				WHERE	ClaCliente = CONVERT(INT,@psValor)         
 			--	UNION              
				--SELECT -1, 'Todos'                                             
			END   
			ELSE
			IF (@PnTipo IN (1))    
			BEGIN                       
 				SELECT	ClaCliente = ClaCliente,          
						NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
				FROM	#TempClientesIngetek x WITH(NOLOCK)               
				WHERE	ClaCliente = CONVERT(INT,@psValor)         
 				UNION              
				SELECT -1, 'Todos'                                             
			END   
			ELSE                  
			BEGIN                 
 				SELECT	ClaCliente = ClaCliente,          
						NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
				FROM	#TempClientesIngetek x WITH(NOLOCK)               
				WHERE	NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
				UNION              
				SELECT -1, 'Todos'                                                   
			END                       
	END               

	DROP TABLE #TempClientesIngetek
	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosClienteCmb) no puede ser procesado.', 16, 1)        

END