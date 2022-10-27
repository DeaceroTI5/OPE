ALTER PROCEDURE OpeSch.OPETraspasosProductoCmb
    @psValor                    VARCHAR(100),   -- Texto a Buscar
	@pnTipo                     INT,		    -- 1 = Buscar poe la Clave
	@pnIncluirTodosSN           INT = 0,
	@pnClaFamilia               INT = -1,
	@pnClaSubFamilia            INT = -1,  	    
	@pnBajasSn	                INT = 0,
    @pnClaSolicitud             INT = 0
AS
BEGIN

	SET NOCOUNT ON

  --  IF OBJECT_ID('TEMPDB..@tbTempProductoSolicitud') IS NOT NULL
		--DROP TABLE @tbTempProductoSolicitud

	DECLARE @tbTempProductoSolicitud TABLE(
		  Id				INT IDENTITY(1,1)
		, ColProducto		INT
		, ColNomProducto	VARCHAR(300)
	)

	IF ISNULL(@pnIncluirTodosSN,0) = 1 AND @pnTipo <> 99
		INSERT INTO @tbTempProductoSolicitud (ColProducto,ColNomProducto) VALUES (-1,'Todos')

	--exec OPESch.OPETraspasosProductoCmb @psValor='',@pnTipo=2,@pnIncluirTodosSN=default,@pnClaFamilia=default,@pnClaSubFamilia=default,@pnBajasSn=default,@pnClaSolicitud=37
              
	IF @psValor IS NULL OR @psValor = ''              
    BEGIN              
		INSERT INTO @tbTempProductoSolicitud(ColProducto, ColNomProducto)
		SELECT	TOP 500 ColProducto = ClaArticulo,          
				ColNomProducto = CONVERT(VARCHAR(10),ClaveArticulo) + ' - '  + LTRIM(RTRIM(NomArticulo))  
		FROM	OpeSch.OpeArtCatArticuloVw WITH(NOLOCK)  
		WHERE	( ClaFamilia = ISNULL( @pnClaFamilia,-1 ) OR ISNULL( @pnClaFamilia,-1 ) = -1 )
		AND     ( ClaSubFamilia = ISNULL( @pnClaSubFamilia,-1 ) OR ISNULL( @pnClaSubFamilia,-1 ) = -1 )
		AND		NomArticulo NOT LIKE '%Varilla%C5%'
		AND     ( ClaArticulo NOT IN (  SELECT  ClaProducto
										FROM    OpeSch.OpeTraSolicitudTraspasoDetVw
										WHERE   IdSolicitudTraspaso = @pnClaSolicitud ) )		
		AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 ) 
	END
    ELSE                 
	IF @PnTipo IN (1)                
	BEGIN
		INSERT INTO @tbTempProductoSolicitud(ColProducto, ColNomProducto)
		SELECT	TOP 500 ColProducto = ClaArticulo,          
				ColNomProducto = CONVERT(VARCHAR(10),ClaveArticulo) + ' - '  + LTRIM(RTRIM(NomArticulo))  
		FROM	OpeSch.OpeArtCatArticuloVw WITH(NOLOCK)  
		WHERE	( ClaFamilia = ISNULL( @pnClaFamilia,-1 ) OR ISNULL( @pnClaFamilia,-1 ) = -1 )
		AND     ( ClaSubFamilia = ISNULL( @pnClaSubFamilia,-1 ) OR ISNULL( @pnClaSubFamilia,-1 ) = -1 )
		AND		NomArticulo NOT LIKE '%Varilla%C5%'
		AND     ( ClaArticulo NOT IN (  SELECT  ClaProducto
										FROM    OpeSch.OpeTraSolicitudTraspasoDetVw
										WHERE   IdSolicitudTraspaso = @pnClaSolicitud ) )		
		AND		(ClaveArticulo LIKE '%' + LTRIM(RTRIM(@psValor)) + '%')                                                                      
		AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  	
	END  	
    ELSE                 
	IF @PnTipo IN (99)                
	BEGIN
		INSERT INTO @tbTempProductoSolicitud(ColProducto, ColNomProducto)
		SELECT	TOP 500 ColProducto = ClaArticulo,          
				ColNomProducto = CONVERT(VARCHAR(10),ClaveArticulo) + ' - '  + LTRIM(RTRIM(NomArticulo))  
		FROM	OpeSch.OpeArtCatArticuloVw WITH(NOLOCK)  
		WHERE	( ClaFamilia = ISNULL( @pnClaFamilia,-1 ) OR ISNULL( @pnClaFamilia,-1 ) = -1 )
		AND     ( ClaSubFamilia = ISNULL( @pnClaSubFamilia,-1 ) OR ISNULL( @pnClaSubFamilia,-1 ) = -1 )
		AND		NomArticulo NOT LIKE '%Varilla%C5%'
		AND     ( ClaArticulo NOT IN (  SELECT  ClaProducto
										FROM    OpeSch.OpeTraSolicitudTraspasoDetVw
										WHERE   IdSolicitudTraspaso = @pnClaSolicitud ) )		
		AND		ClaArticulo = @psValor                                                                       
		AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  	
	END              
	ELSE            
	BEGIN
		INSERT INTO @tbTempProductoSolicitud(ColProducto, ColNomProducto)
		SELECT	TOP 500 ColProducto = ClaArticulo,          
				ColNomProducto = CONVERT(VARCHAR(10),ClaveArticulo) + ' - '  + LTRIM(RTRIM(NomArticulo))  
		FROM	OpeSch.OpeArtCatArticuloVw WITH(NOLOCK)  
		WHERE	( ClaFamilia = ISNULL( @pnClaFamilia,-1 ) OR ISNULL( @pnClaFamilia,-1 ) = -1 )
		AND     ( ClaSubFamilia = ISNULL( @pnClaSubFamilia,-1 ) OR ISNULL( @pnClaSubFamilia,-1 ) = -1 )
		AND		NomArticulo NOT LIKE '%Varilla%C5%'
		AND     ( ClaArticulo NOT IN (  SELECT  ClaProducto
										FROM    OpeSch.OpeTraSolicitudTraspasoDetVw
										WHERE   IdSolicitudTraspaso = @pnClaSolicitud ) )		
		AND		((ClaveArticulo LIKE '%' + LTRIM(RTRIM(@psValor)) + '%') 
					OR (NomArticulo LIKE '%' + LTRIM(RTRIM(@psValor)) + '%'))
        AND		( ISNULL(BajaLogica, 0) != 1 OR ISNULL(@pnBajasSn,0) = 1 )  	

	END

	SELECT ColProducto, ColNomProducto  FROM @tbTempProductoSolicitud

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT: 
    RAISERROR('El SP (OPETraspasosProductoCmb) no puede ser procesado.', 16, 1)        

END