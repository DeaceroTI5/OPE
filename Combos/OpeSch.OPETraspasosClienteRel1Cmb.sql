USE Operacion
GO
-- 'OpeSch.OPETraspasosClienteRel1Cmb'
GO
ALTER PROCEDURE OpeSch.OPETraspasosClienteRel1Cmb
    @psValor                VARCHAR(100),   -- Texto a Buscar
	@pnTipo                 INT,		    -- 1 = Buscar poe la Clave
--	@pnIncluirTodosSN       INT = 0,    
	@pnBajasSn	            INT = 0,
	@pnDebug				TINYINT = 0
AS
BEGIN

	SET NOCOUNT ON
    
	IF @psValor IS NULL OR @psValor = ''              
    BEGIN              
		SELECT	TOP 500
				ClaCliente = ClaCliente,          
				NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
		FROM	OpeSch.OpeVtaCatClienteVw a
		WHERE	ClaCliente IN (
					SELECT	DISTINCT ClaClienteFilial 
					FROM	OpeSch.OpeVtaCatClienteFilialVw
				)       
	END              
    ELSE IF @PnTipo IN (1,99)                
	BEGIN                      
		SELECT	TOP 500
				ClaCliente = ClaCliente,          
				NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
		FROM	OpeSch.OpeVtaCatClienteVw a     
		WHERE	ClaCliente = CONVERT(INT,@psValor) 
		AND		ClaCliente IN (
					SELECT	DISTINCT ClaClienteFilial 
					FROM	OpeSch.OpeVtaCatClienteFilialVw
				)       
	END              
	ELSE            
	BEGIN                          
		SELECT	TOP 500
				ClaCliente = ClaCliente,          
				NomCliente = CONVERT(VARCHAR(10),ClaCliente) + ' - '  + LTRIM(RTRIM(NomCliente))    
		FROM	OpeSch.OpeVtaCatClienteVw a     
		WHERE	NomCliente LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'    
		AND		ClaCliente IN (
					SELECT	DISTINCT ClaClienteFilial 
					FROM	OpeSch.OpeVtaCatClienteFilialVw
				)       
	END           
	
	SET NOCOUNT OFF
END