-- 'OpeSch.OPETraspasosProyectoCmb'
USE Operacion
GO
ALTER PROCEDURE OpeSch.OPETraspasosProyectoCmb
    @psValor                VARCHAR(100),   -- Texto a Buscar
	@pnTipo                 INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN       INT = 0,    
	@pnBajasSn	            INT = 0,
    @pnClaPedidoOrigen	    INT = 0        -- Informado: Filtra el Proyecto del Pedido Origen / No Informado: Abre la consulta a todos los Proyectos de Ingetek
AS
BEGIN

	SET NOCOUNT ON
    
    IF OBJECT_ID('TEMPDB..#TempUbicacionesIngetek') IS NOT NULL
		DROP TABLE #TempUbicacionesIngetek
    
    IF OBJECT_ID('TEMPDB..#TempProyectosIngetek') IS NOT NULL
		DROP TABLE #TempProyectosIngetek

    SELECT  @pnClaPedidoOrigen = ISNULL(@pnClaPedidoOrigen,0)

    SELECT	ClaUbicacion
	INTO	#TempUbicacionesIngetek
	FROM	OpeSch.OpeTiCatUbicacionVw WITH(NOLOCK)  
	WHERE	(ClaEmpresa IN (52)
	OR		ClaUbicacion IN (277,278,364))

    SELECT	DISTINCT
			a.ClaProyecto,
			a.NomProyecto
	INTO	#TempProyectosIngetek
	FROM	OpeSch.OpeVtaCatProyectoVw a WITH(NOLOCK)  
	INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw b WITH(NOLOCK)  
		ON	a.ClaProyecto = b.ClaProyecto
	INNER JOIN	OpeSch.OpeTraFabricacionVw c WITH(NOLOCK)  
		ON	b.IdFabricacion = c.IdFabricacion
	INNER JOIN	#TempUbicacionesIngetek d
		ON	c.ClaPlanta = d.ClaUbicacion
	WHERE	(c.IdFabricacion = @pnClaPedidoOrigen OR @pnClaPedidoOrigen = 0)
	AND		(@pnTipo=99 OR ( ISNULL(a.BajaLogica,0) != 1 OR ISNULL(@pnBajasSn,0) = 1 ))  

	IF @pnIncluirTodosSN  = 0              
	BEGIN                 
		IF @psValor IS NULL OR @psValor = ''              
        BEGIN              
			SELECT	ClaProyecto = ClaProyecto,          
					NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
			FROM	#TempProyectosIngetek x WITH(NOLOCK)        
		END              
        ELSE                 
	        IF @PnTipo IN (1,99)                
			BEGIN                      
				SELECT	ClaProyecto = ClaProyecto,          
						NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
				FROM	#TempProyectosIngetek x WITH(NOLOCK)               
				WHERE	ClaProyecto = CONVERT(INT,@psValor)    
			END              
			ELSE            
			BEGIN                          
				SELECT	ClaProyecto = ClaProyecto,          
						NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
				FROM	#TempProyectosIngetek x WITH(NOLOCK)               
				WHERE	NomProyecto LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
			END                  
	END              
    ELSE      -- @pnIncluirTodosSN  = 1            
    BEGIN              
		IF (@psValor IS NULL OR @psValor = '')    
        BEGIN                                      
 			SELECT	ClaProyecto = ClaProyecto,          
					NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
			FROM	#TempProyectosIngetek x WITH(NOLOCK)         
            UNION              
            SELECT -1, 'Todos'                                 
		END              
        ELSE                 
			IF (@PnTipo IN (99))    
			BEGIN                       
 				SELECT	ClaProyecto = ClaProyecto,          
						NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
				FROM	#TempProyectosIngetek x WITH(NOLOCK)               
				WHERE	ClaProyecto = CONVERT(INT,@psValor)         
 			--	UNION              
				--SELECT -1, 'Todos'                                             
			END    
			ELSE  
			IF (@PnTipo IN (1))    
			BEGIN                       
 				SELECT	ClaProyecto = ClaProyecto,          
						NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
				FROM	#TempProyectosIngetek x WITH(NOLOCK)               
				WHERE	ClaProyecto = CONVERT(INT,@psValor)         
 				UNION              
				SELECT -1, 'Todos'                                             
			END    
			ELSE                  
			BEGIN                 
 				SELECT	ClaProyecto = ClaProyecto,          
						NomProyecto = CONVERT(VARCHAR(10),ClaProyecto) + ' - '  + LTRIM(RTRIM(NomProyecto))    
				FROM	#TempProyectosIngetek x WITH(NOLOCK)               
				WHERE	NomProyecto LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
				UNION              
				SELECT -1, 'Todos'                                                   
			END                       
	END               

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosProyectoCmb) no puede ser procesado.', 16, 1)        

END