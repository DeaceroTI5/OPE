GO
ALTER PROCEDURE OpeSch.OPETraspasosEstatusCmb
    @psValor                    VARCHAR(100),   -- Texto a Buscar
	@pnTipo                     INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN           INT = 0,    
	@pnBajasSn	                INT = 0
AS
BEGIN

	SET NOCOUNT ON

	IF @pnIncluirTodosSN  = 0              
	BEGIN                 
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN              
			SELECT	ClaEstatus = ClaEstatus,          
					NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
			FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
			WHERE	ClaClasificacionEstatus = 1270105
			AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
		END              
        ELSE                 
	        IF @PnTipo IN (1,99)                
			BEGIN                      
				SELECT	ClaEstatus = ClaEstatus,          
						NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
				FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
				WHERE	ClaEstatus = CONVERT(INT,@psValor)                                                                                
				AND		ClaClasificacionEstatus = 1270105
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
			END              
			ELSE            
			BEGIN                          
				SELECT	ClaEstatus = ClaEstatus,          
						NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
				FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
				WHERE	NombreEstatus LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'                                  
                AND		ClaClasificacionEstatus = 1270105
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
			END                  
	END              
    ELSE -- @pnIncluirTodosSN  = 1             
    BEGIN              
		IF (@psValor IS NULL OR @psValor = '')    
        BEGIN                                      
 			SELECT	ClaEstatus = ClaEstatus,          
					NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
			FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
            WHERE	ClaClasificacionEstatus = 1270105
 			AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
            UNION              
            SELECT -1, 'Todos'                                 
		END              
        ELSE                 
			IF (@PnTipo IN (99))    
			BEGIN                       
 				SELECT	ClaEstatus = ClaEstatus,          
						NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
				FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
				WHERE	ClaEstatus = CONVERT(INT,@psValor)                  
                AND		ClaClasificacionEstatus = 1270105
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
 			--	UNION              
				--SELECT -1, 'Todos'                                             
			END
			ELSE
			IF (@PnTipo IN (1))    
			BEGIN                       
 				SELECT	ClaEstatus = ClaEstatus,          
						NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
				FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
				WHERE	ClaEstatus = CONVERT(INT,@psValor)                  
                AND		ClaClasificacionEstatus = 1270105
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
 				UNION              
				SELECT -1, 'Todos'                                             
			END
			ELSE                  
			BEGIN                 
 				SELECT	ClaEstatus = ClaEstatus,          
						NomEstatus = CONVERT(VARCHAR(10),ClaEstatus) + ' - '  + LTRIM(RTRIM(NombreEstatus))    
				FROM	TiCatalogo.dbo.TiCatEstatus  x WITH(NOLOCK)               
				WHERE	NombreEstatus LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'                          
                AND		ClaClasificacionEstatus = 1270105
				AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  
				UNION              
				SELECT -1, 'Todos'                                                   
			END                       
	END               

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosEstatusCmb) no puede ser procesado.', 16, 1)        

END