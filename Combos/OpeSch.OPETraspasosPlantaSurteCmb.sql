USE Operacion
GO
ALTER PROCEDURE OpeSch.OPETraspasosPlantaSurteCmb
    @psValor                    VARCHAR(100),   -- Texto a Buscar
	@pnTipo                     INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN           INT = 0,
	@pnClaTipoUbicacion         INT = 0,
	@pnClaValorUbicacionSurte   INT = 0,       
	@pnBajasSn	                INT = 0,
    @pnCmbPlantaPide	        INT = 0         -- Informado: Retira la Ubicación del Listado de Ubicaciones / No Informado: No Afecta el Listado de Ubicaciones
AS
BEGIN

	SET NOCOUNT ON

	IF ISNULL(@pnClaValorUbicacionSurte,0) > 0
	BEGIN
		SELECT	ClaUbicacion = ClaUbicacion,          
				NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
		FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
		WHERE	ClaUbicacion = @pnClaValorUbicacionSurte
        AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
		AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  

		RETURN
	END

	IF @pnIncluirTodosSN  = 0              
	BEGIN                 
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN              
			SELECT	ClaUbicacion = ClaUbicacion,          
					NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
			FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
			WHERE	( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
            AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
			AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
		END              
        ELSE                 
	        IF @PnTipo IN (1,99)                
			BEGIN                      
				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                                                                                
				AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
                AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
			END              
			ELSE            
			BEGIN                          
				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
				WHERE	NombreUbicacion LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'                                  
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
                AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
			END                  
	END              
    ELSE  -- @pnIncluirTodosSN  = 1                
    BEGIN              
		IF (@psValor IS NULL OR @psValor = '')    
        BEGIN                                      
 			SELECT	ClaUbicacion = ClaUbicacion,          
					NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
			FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
            WHERE	( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
            AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
 			AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
            UNION              
            SELECT -1, 'Todos'                                 
		END              
        ELSE                 
			IF (@PnTipo IN (99))    
			BEGIN                       
 				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                  
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
                AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
 			--	UNION              
				--SELECT -1, 'Todos'                                             
			END    
			ELSE 
			IF (@PnTipo IN (1))    
			BEGIN                       
 				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                  
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
                AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
 				UNION              
				SELECT -1, 'Todos'                                             
			END    
			ELSE                  
			BEGIN                 
 				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	OpeSch.OpeTiCatUbicacionVw  x WITH(NOLOCK)               
				WHERE	NombreUbicacion LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'                          
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
                AND     ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaPide,0))
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
				UNION              
				SELECT -1, 'Todos'                                                   
			END                       
	END               

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosPlantaSurteCmb) no puede ser procesado.', 16, 1)        

END