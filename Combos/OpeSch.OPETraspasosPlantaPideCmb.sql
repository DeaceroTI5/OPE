--'OpeSch.OPETraspasosPlantaPideCmb'
GO
ALTER PROCEDURE OpeSch.OPETraspasosPlantaPideCmb
    @psValor                    VARCHAR(100),   -- Texto a Buscar
	@pnTipo                     INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN           INT = 0,
	@pnClaTipoUbicacion         INT = 0,
	@pnClaValorUbicacionPide    INT = 0,   
	@pnClaUsuarioMod            INT,		    
	@pnBajasSn	                INT = 0,
    @pnCmbPlantaSurte	        INT = 0         -- Informado: Retira la Ubicación del Listado de Ubicaciones / No Informado: No Afecta el Listado de Ubicaciones
AS
BEGIN

	SET NOCOUNT ON

-- exec OPESch.OPETraspasosPlantaPideCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=0,@pnClaTipoUbicacion=default,@pnClaValorUbicacionPide=0,@pnClaUsuarioMod=100010318,@pnBajasSn=default,@pnCmbPlantaSurte=NULL

    IF OBJECT_ID('TEMPDB..#TempUbicacionesIngetek') IS NOT NULL
		DROP TABLE #TempUbicacionesIngetek

    SELECT	ClaUbicacion, NombreUbicacion, ClaTipoUbicacion, BajaLogica
	INTO	#TempUbicacionesIngetek
	FROM	OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
	WHERE	ClaUbicacion NOT IN (ISNULL(@pnCmbPlantaSurte,0))
--  AND     (ClaEmpresa IN (52) OR ClaUbicacion IN (277,278,364))

	IF ISNULL(@pnClaValorUbicacionPide,0) > 0
	BEGIN
		SELECT	ClaUbicacion = ClaUbicacion,          
				NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
		FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
		WHERE	ClaUbicacion = @pnClaValorUbicacionPide
		AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  

		RETURN
	END

	IF @pnIncluirTodosSN  = 0              
	BEGIN                 
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN              
			SELECT	ClaUbicacion = ClaUbicacion,          
					NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
			FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
			WHERE	( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
			AND		( ClaUbicacion IN ( SELECT t1.ClaUbicacion FROM OpeSch.OpeCfgUsuarioTraspaso t1 WHERE t1.ClaUsuario = @pnClaUsuarioMod AND t1.BajaLogica = 0 ) OR
					EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t2 WHERE t2.ClaUsuario = @pnClaUsuarioMod AND t2.ClaUbicacion = -1 AND t2.ClaTipoUbicacion = -1 AND t2.BajaLogica = 0 ) OR 
                    EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t3 WHERE t3.ClaUsuario = @pnClaUsuarioMod AND t3.ClaUbicacion = -1 AND t3.ClaTipoUbicacion = x.ClaTipoUbicacion AND t3.BajaLogica = 0 ) )
			AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
		END              
        ELSE
	        IF @PnTipo IN (99)                
			BEGIN                      
				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                                                                                
				AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )   
			END              
			ELSE 		
	        IF @PnTipo IN (1)                
			BEGIN                      
				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                                                                                
				AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
				AND		( ClaUbicacion IN ( SELECT t1.ClaUbicacion FROM OpeSch.OpeCfgUsuarioTraspaso t1 WHERE t1.ClaUsuario = @pnClaUsuarioMod AND t1.BajaLogica = 0 ) OR
	                    EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t2 WHERE t2.ClaUsuario = @pnClaUsuarioMod AND t2.ClaUbicacion = -1 AND t2.ClaTipoUbicacion = -1 AND t2.BajaLogica = 0 ) OR 
	                    EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t3 WHERE t3.ClaUsuario = @pnClaUsuarioMod AND t3.ClaUbicacion = -1 AND t3.ClaTipoUbicacion = x.ClaTipoUbicacion AND t3.BajaLogica = 0 ) )
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
			END              
			ELSE            
			BEGIN                          
				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
				WHERE	NombreUbicacion LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'                                  
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
                AND		( ClaUbicacion IN ( SELECT t1.ClaUbicacion FROM OpeSch.OpeCfgUsuarioTraspaso t1 WHERE t1.ClaUsuario = @pnClaUsuarioMod AND t1.BajaLogica = 0 ) OR
                        EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t2 WHERE t2.ClaUsuario = @pnClaUsuarioMod AND t2.ClaUbicacion = -1 AND t2.ClaTipoUbicacion = -1 AND t2.BajaLogica = 0) OR 
                        EXISTS ( SELECT 1 FROM OpeSch.OpeCfgUsuarioTraspaso t3 WHERE t3.ClaUsuario = @pnClaUsuarioMod AND t3.ClaUbicacion = -1 AND t3.ClaTipoUbicacion = x.ClaTipoUbicacion AND t3.BajaLogica = 0 ) )
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
			END                  
	END              
    ELSE        -- @pnIncluirTodosSN  = 1       
    BEGIN              
		IF (@psValor IS NULL OR @psValor = '')    
        BEGIN                                      
 			SELECT	ClaUbicacion = ClaUbicacion,          
					NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
			FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
            WHERE	( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
 			AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
            UNION              
            SELECT -1, 'Todos'                                 
		END              
        ELSE                 
			IF (@PnTipo IN (99))    
			BEGIN                       
 				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                  
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
 			--	UNION              
				--SELECT -1, 'Todos'                                             
			END
			ELSE
			IF (@PnTipo IN (1))    
			BEGIN                       
 				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
				WHERE	ClaUbicacion = CONVERT(INT,@psValor)                  
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
 				UNION              
				SELECT -1, 'Todos'                                             
			END 			
			ELSE                  
			BEGIN                 
 				SELECT	ClaUbicacion = ClaUbicacion,          
						NomUbicacion = CONVERT(VARCHAR(10),ClaUbicacion) + ' - '  + LTRIM(RTRIM(NombreUbicacion))    
				FROM	#TempUbicacionesIngetek x WITH(NOLOCK)               
				WHERE	NombreUbicacion LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'                          
                AND		( ISNULL(@pnClaTipoUbicacion,0) <= 0 OR ClaTipoUbicacion = @pnClaTipoUbicacion )
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
				UNION              
				SELECT -1, 'Todos'                                                   
			END                       
	END   
	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosPlantaPideCmb) no puede ser procesado.', 16, 1)        

END