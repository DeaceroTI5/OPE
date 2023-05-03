CREATE PROCEDURE OPESch.OPE_CU445_Pag16_Boton_BtnEncabezado_Proc
 @pnClaUbicacion		INT
,@pnClaMaquilador		INT
,@pnIdRecepOrdenMaquila	INT =null
,@pnClaTipoRecepcion	INT =2
,@pnClaEstatus			INT
,@pnIdBoletaODS			INT
,@psObservaciones		VARCHAR(200)
,@psNombrePcMod			VARCHAR(64)
,@pnClaUsuarioMod		INT
,@pnClaCliente			INT = NULL
,@pnIdRecepResultado		INT			=NULL
,@pnCerrarRecepcion		INT
AS 
BEGIN
SET NOCOUNT ON
 
 
IF  NOT EXISTS (SELECT * FROM tempdb.sys.objects WHERE name ='##tmp_ODM' AND type in (N'U'))
	BEGIN
	 
		CREATE  TABLE dbo.##tmp_ODM(
		ClaUbicacion INT,
		ODM INT,
		NombrePcMod varchar(64),
		EsIncluir INT
		)
	END 
ELSE 
	BEGIN
		DELETE dbo.##tmp_ODM where NombrePcMod = @psNombrePcMod
	END 	
 
 
 
--* Declaracion de variables locales
	DECLARE	 @nNumError					INT
			,@nRecProductoMaquilado		INT
			,@nRecMaterialMaquila		INT			
			,@dFechaActual				DATETIME
			,@nEstatusRecibido			INT
			,@nEstatusCerrado			INT
			,@nValidaUPD				INT
			,@nClaEstatus				INT
	
	SELECT @nClaEstatus = ClaEstatus
	FROM OpeSch.OpeTraRecepOrdenMaquila WITH(NOLOCK) 
	WHERE ClaUbicacion = @pnClaUbicacion AND 
		IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila
		
		
		
		
 
	SET @nRecProductoMaquilado	= 2
	SET @nRecMaterialMaquila 	= 1
	SET @dFechaActual			= GETDATE()
	SET @nEstatusRecibido		= 2
	SET @nEstatusCerrado		= 3
 
	IF ISNULL(@pnClaEstatus,0) = 0
	SELECT @pnClaEstatus = @nEstatusRecibido
		
	IF  ISNULL(@pnCerrarRecepcion,0) =	0 and ISNULL(@pnClaEstatus,0) = @nEstatusCerrado
	SELECT @pnClaEstatus   =@nEstatusRecibido
	
	IF  ISNULL(@pnCerrarRecepcion,0) =	1 
	SELECT @pnClaEstatus   =@nEstatusCerrado
	
	
	
select @nClaEstatus,@pnClaEstatus,@pnClaTipoRecepcion,@pnIdRecepOrdenMaquila
	--Si ya esta cerrada ya no se puede guardar otra vez la recepción.
	IF(@pnClaEstatus = @nEstatusCerrado AND @nClaEstatus = @nEstatusCerrado)
	BEGIN 
		--EXEC CmqSch.ErrLanzaExcepcionNegocio 38, 'CmqTraRecepOrdenMaquilaIU'				
		--GOTO FINSP
		return
	END
	
	--Sí se abre la recepción se deshace la afectación de la cantidad recibida de la ODM
	IF(isnull(@pnClaEstatus,0) = @nEstatusRecibido AND @nClaEstatus = @nEstatusCerrado)
	BEGIN
		UPDATE A 
		SET A.CantidadRecibida = (ISNULL(A.CantidadRecibida, 0) - ISNULL(B.CantRecibida, 0)), 
			A.KilosRecibidos = (ISNULL(A.KilosRecibidos, 0) - ISNULL(B.PesoRecibido, 0)), 
			A.FechaUltimaMod = GETDATE(), 
			A.NombrePcMod = @psNombrePcMod,
			A.ClaUsuarioMod = @pnClaUsuarioMod
		FROM OpeSch.OpeTraOrdenMaquilaDet A WITH(UPDLOCK) 
		INNER JOIN OpeSch.OpeTraRecepOrdenMaquilaDet B WITH(NOLOCK) ON 
			B.ClaUbicacion = A.ClaUbicacion AND 
			B.IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila AND 
			B.IdFabricacion = A.IdFabricacion AND 
			B.IdOrdenMaquila = A.IdOrdenMaquila AND 
			B.ClaArticulo = A.ClaArticulo AND 
			B.ClaTipoInventario = A.ClaTipoInventario 
		WHERE A.ClaUbicacion = @pnClaUbicacion AND 
			A.ClaTipoInventario = 1	
	END
	
	SELECT @pnIdRecepOrdenMaquila = IdRecepOrdenMaquila 
	FROM OpeSch.OpeTraRecepOrdenMaquila (NOLOCK)
	WHERE ClaUbicacion = @pnClaUbicacion
		AND IdBoleta = @pnIdBoletaODS
	
	IF EXISTS (	SELECT	1 
				FROM	OpeSch.OpeTraRecepOrdenMaquila (NOLOCK)
				WHERE	ClaUbicacion		= @pnClaUbicacion 
				AND		IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila 
				AND		ClaEstatus			= @nEstatusCerrado )
	BEGIN
		SET @nValidaUPD = 1
	END
	ELSE
	BEGIN
		SET @nValidaUPD = 0
	END
	
	-- * Validaciones que aplican a recepcion de producto maquilado
	IF @pnClaTipoRecepcion = @nRecProductoMaquilado
	BEGIN
		--* RNA-MAQ-Recepción de producto maquilado se hace para un Maquilador contratado
		IF NOT EXISTS(SELECT 1 FROM Opesch.OpeCatMaquilador (NOLOCK) WHERE ClaMaquilador = @pnClaMaquilador AND BajaLogica = 0)
		 BEGIN
		
			     RAISERROR('Edb445.16.1', 16, 1)  		
			GOTO FINSP
		 END	
 
		--* RNA-MAQ-Validar el estatus de la Recepción modificada
		/*IF ISNULL(@pnIdRecepOrdenMaquila,-1) > -1
		 BEGIN
			-- Debe de existir
			IF NOT EXISTS(SELECT 1 FROM OpeSch.OpeTraRecepOrdenMaquila (NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion AND IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila)
			 BEGIN
				SET @nNumError = 12
			     RAISERROR('Edb445.16.1', 16, 1)  	
				GOTO FINSP			
			 END
			-- Su estatus debe ser Por recibir
			IF NOT EXISTS(	SELECT	1 
							FROM	CmqTraRecepOrdenMaquila (NOLOCK) 
							WHERE	ClaUbicacion		= @pnClaUbicacion 
							AND		IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila 
							AND		ClaEstatus			<> @nEstatusCerrado	)
			BEGIN
				SET @nNumError = 13
				EXEC ErrLanzaExcepcionNegocio @nNumError, 'CmqTraRecepOrdenMaquilaIU'				
				GOTO FINSP					
			END
		 END	*/
	END
	/*ELSE
	BEGIN
		IF @pnClaTipoRecepcion = @nRecMaterialMaquila
		BEGIN
			IF ISNULL(@pnIdRecepOrdenMaquila,-1) > -1
			 BEGIN
				-- Debe de existir
				IF NOT EXISTS(SELECT 1 FROM OpeSch.OpeTraRecepOrdenMaquila (NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion AND IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila)
				 BEGIN
					SET @nNumError = 12
					
					--EXEC ErrLanzaExcepcionNegocio @nNumError, 'CmqTraRecepOrdenMaquilaIU'				
					GOTO FINSP			
				 END
				-- Su estatus debe ser Por recibir
				IF NOT EXISTS(	SELECT	1 
								FROM	CmqTraRecepOrdenMaquila (NOLOCK) 
								WHERE	ClaUbicacion		= @pnClaUbicacion 
								AND		IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila 
								AND		ClaEstatus			<> @nEstatusCerrado	)
				BEGIN
					SET @nNumError = 13
					EXEC ErrLanzaExcepcionNegocio @nNumError, 'CmqTraRecepOrdenMaquilaIU'				
					GOTO FINSP					
				END
			 END 
		END
	END*/
	
	IF ISNULL(@pnIdRecepOrdenMaquila,-1) < 0
	 BEGIN
		SELECT	@pnIdRecepResultado = MAX(IdRecepOrdenMaquila) 
		FROM	OPESch.OpeTraRecepOrdenMaquila (NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion
		
		SET @pnIdRecepResultado = ISNULL(@pnIdRecepResultado,0) + 1
 
		INSERT INTO OPESch.OpeTraRecepOrdenMaquila 	(
											 ClaUbicacion
											,IdRecepOrdenMaquila
											,ClaTipoRecepcion
											,ClaEstatus
											,IdBoleta
											,Comentarios
											,FechaUltimaMod
											,NombrePcMod
											,ClaUsuarioMod
											,ClaCliente
											)
									VALUES	(
											 @pnClaUbicacion--ClaUbicacion
											,@pnIdRecepResultado--IdRecepOrdenMaquila
											,@pnClaTipoRecepcion--ClaTipoRecepcion
											,@pnClaEstatus--@nEstatusCerrado--ClaEstatus
											,@pnIdBoletaODS--IdBoleta
											,@psObservaciones--Comentarios
											,@dFechaActual--FechaUltimaMod
											,@psNombrePcMod--NombrePcMod
											,@pnClaUsuarioMod--ClaUsuarioMod  
											,@pnClaCliente												
											)
	 END
	ELSE
	 BEGIN			
		UPDATE	OPESch.OpeTraRecepOrdenMaquila  WITH(ROWLOCK,UPDLOCK)
		SET		 ClaEstatus		= @pnClaEstatus
				,IdBoleta		= @pnIdBoletaODS
				,Comentarios	= @psObservaciones
				,FechaUltimaMod = @dFechaActual
				,NombrePcMod	= @psNombrePcMod
				,ClaUsuarioMod	= @pnClaUsuarioMod
				,ClaCliente 	= @pnClaCliente
		WHERE	ClaUbicacion		= @pnClaUbicacion
		AND		IdRecepOrdenMaquila = @pnIdRecepOrdenMaquila
		
		SET @pnIdRecepResultado = @pnIdRecepOrdenMaquila
	 END
	 
	 
	IF (@pnClaEstatus = @nEstatusCerrado)
	BEGIN
		UPDATE	plosch.PloCTraBoletaVw  
		SET 	ClaEstatusPlaca = 2
		WHERE	IdBoleta = @pnIdBoletaODS
		AND		ClaUbicacion = @pnClaUbicacion
	END
	
	IF @nValidaUPD = 1 AND @pnClaEstatus = @nEstatusRecibido
	BEGIN 
		UPDATE	plosch.PloCTraBoletaVw  
		SET 	ClaEstatusPlaca = 1
		WHERE	IdBoleta = @pnIdBoletaODS
		AND		ClaUbicacion = @pnClaUbicacion
	END
	
 
	IF @@ERROR <> 0 SET @nNumError = @@ERROR
	FINSP:
	RETURN @@ERROR
 
SET NOCOUNT OFF
END