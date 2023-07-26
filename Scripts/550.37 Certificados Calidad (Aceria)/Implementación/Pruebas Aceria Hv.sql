
BEGIN TRAN
	DECLARE   @pnClaUbicacion		INT
			, @pnIdFactura			INT
			, @pnClaUbicacionOrigen INT
			, @pnIdFacturaOrigen	INT
			, @nClaAceria			INT

	 /* CASO 1 se identifica que factura origen de aceria 7 no existe pero ya esta registrado; Omite registro no existente e inserta dato faltante */
	--SELECT	  
	--		  @pnClaUbicacion		= 323
	--		, @pnIdFactura			= 1033000476
	--		, @pnClaUbicacionOrigen	= 275
	--		, @pnIdFacturaOrigen	= 989067852

	 /* CASO 2 se actualiza correctamente e Inserta registro faltante*/
	--SELECT	
	--		  @pnClaUbicacion		= 324
	--		, @pnIdFactura			= 1034002643
	--		, @pnClaUbicacionOrigen	= 55
	--		, @pnIdFacturaOrigen	= 725057312

	 /* CASO 3 Actualiza registro aceria e inserta faltante*/
	--SELECT	
	--		  @pnClaUbicacion		= 324
	--		, @pnIdFactura			= 1034005068
	--		, @pnClaUbicacionOrigen	= 39
	--		, @pnIdFacturaOrigen	= 129016866

	 /* CASO 4 Actualiza registros aceria e Inserta*/
	--SELECT	
	--		  @pnClaUbicacion		= 324
	--		, @pnIdFactura			= 1034004948
	--		, @pnClaUbicacionOrigen	= 158
	--		, @pnIdFacturaOrigen	= 58072581

	 /* CASO 5 Actualiza registros aceria e Inserta Mensaje Error Itk*/
	SELECT	
			  @pnClaUbicacion		= 362
			, @pnIdFactura			= 1036001050
			, @pnClaUbicacionOrigen	= 39
			, @pnIdFacturaOrigen	= 129016853


	DECLARE @sIdCertificado			VARCHAR(100) = NULL
			,@nClaEstatus			INT = NULL
			,@sMensajeError			VARCHAR(500) = ''

		SELECT	ClaUbicacion, NumFacturaOrigen = NumFactura, CaAceria = ClaUbicacionOrigen, IdCertificado, NumCertificado, Archivo = CASE WHEN Archivo IS NULL THEN 0 ELSE 1 END 
		FROM	AceSch.AceTraCertificado a WITH(NOLOCK)
		WHERE	ClaUbicacion				= @pnClaUbicacionOrigen
		AND		IdFactura					= @pnIdFacturaOrigen
			
		SELECT	ClaUbicacion, NumFacturaOrigen = NumFactura, CaAceria = ClaUbicacionOrigen, IdCertificado, NumCertificado, Archivo = CASE WHEN Archivo IS NULL THEN 0 ELSE 1 END 
		FROM	AceSch.AceTraCertificado b WITH(NOLOCK)
		WHERE	b.ClaUbicacion			= @pnClaUbicacion
		AND		b.IdFactura				= @pnIdFactura


	EXEC ACESch.AceGeneraCertificadoPuntoLogisticoSrv_Hv
		  @pnClaUbicacion					= @pnClaUbicacion
		, @pnIdFactura						= @pnIdFactura
		, @pnClaUbicacionOrigen				= @pnClaUbicacionOrigen
		, @pnIdFacturaOrigen				= @pnIdFacturaOrigen
		, @pnEsRegeneraCertificado			= 1
		, @psNombrePcMod					= 'Prueba'
		, @pnClaUsuarioMod					= 1
		, @psIdCertificado					= @sIdCertificado	OUT
		, @pnClaEstatus						= @nClaEstatus		OUTPUT
		, @psMensajeError					= @sMensajeError	OUTPUT
		, @pnClaAceria						= NULL
		, @pnDebug							= 1

	SELECT @sIdCertificado AS '@sIdCertificado'

ROLLBACK TRAN
