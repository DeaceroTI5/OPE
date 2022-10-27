USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag32_Servicio_GeneracionConsignado_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag32_Servicio_GeneracionConsignado_Proc
    @pnFabricacionOrigen        INT,
    @pnClaClienteCuenta         INT, --Cuenta Cliente de Ubicación Pide
    @pnClaUsuarioMod            INT, --Usuario Autorizador
    @psNombrePcMod              VARCHAR(64),
    @pnClaConsignado            INT OUT,
	@psMensaje					VARCHAR(255) = '' OUTPUT
AS
BEGIN

	SET NOCOUNT ON

    DECLARE @ClaEstatus             INT,
		    @Mensaje                VARCHAR(255)

	DECLARE @ClaClienteCuentaFab    INT,
            @ClaConsignadoFab       INT,
            @ClaClienteUnicoFab     INT

	DECLARE @ClaClienteUnico        INT,
            @NomConsignado          VARCHAR(50),
            @ClaCiudadCons          INT,
            @ClaColoniaUnico        INT,
            @ClaCodigoPostal        INT,
            @Calle                  VARCHAR(50),
            @NumExterior            VARCHAR(15),
            @NumInterior            VARCHAR(15),
            @EntreCalles            VARCHAR(100),
            @ClaMedioEmbarque       INT,
            @ClaveInternacional     VARCHAR(5),
            @Lada                   VARCHAR(5),
            @Telefono               VARCHAR(20),
            @Contacto               VARCHAR(60), 
            @TaxId                  VARCHAR(50)

	DECLARE @NomColoniaFab	        VARCHAR(100)

	SET @psMensaje = ''
		
	--Validacion de la Existencia y Estatus de la Fabricacion
	IF NOT EXISTS (	SELECT	1
					FROM	[Ventas].[VtaSch].[VtaCTraFabricacionEnc]
					WHERE	IdFabricacion = @pnFabricacionOrigen)
	BEGIN
		SELECT @Mensaje = 'El pedido Origen '+ ISNULL(CONVERT(VARCHAR(10),@pnFabricacionOrigen),'') +' no existe. (OpeSch.OPE_CU550_Pag32_Servicio_GeneracionConsignado_Proc).'
		GOTO ABORT
	END

	SELECT	@ClaClienteUnico = ClaClienteUnico
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCatClienteCuentaVw WITH(NOLOCK)
	WHERE	ClaClienteCuenta = @pnClaClienteCuenta
	
	IF ISNULL( @ClaClienteUnico, 0) = 0
	BEGIN
		SELECT @Mensaje = 'No existe cliente unico para cuenta cliente ' +ISNULL(CONVERT(VARCHAR(10),@pnClaClienteCuenta),'0')+'. (OpeSch.OPE_CU550_Pag32_Servicio_GeneracionConsignado_Proc).'
		GOTO ABORT
	END

	--Verificando si existe el consignado.
	SELECT	@ClaClienteCuentaFab = f.ClaCliente,
			@ClaConsignadoFab = ISNULL(f.ClaConsignado, 0),
			@ClaClienteUnicoFab = cc.ClaClienteUnico
	FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFabricacion f WITH(NOLOCK)
	INNER JOIN  DEAOFINET05.Ventas.VtaSch.VtaCatClienteCuentaVw cc WITH(NOLOCK) 
        ON  cc.ClaClienteCuenta = f.ClaCliente
	WHERE   f.IdFabricacion = @pnFabricacionOrigen

   	--Vamos a Ventas a Traer el consignado
	SELECT	@ClaMedioEmbarque = ClaMedioEmbarque,
			@NomConsignado = NomConsignado,
			@Calle = Calle,
			@NumExterior = NumExterior,
			@NumInterior = NumInterior,
			@EntreCalles = EntreCalles,
			@ClaColoniaUnico = ClaColoniaUnico,
			@ClaCodigoPostal = ClaCodigoPostal,
			@Telefono = TelefonoNotificante,
			@ClaCiudadCons = ClaCiudadUnico,
			@ClaveInternacional = ClaveInternacionalNotificante,
			@Lada = LadaNotificante, 
			@Contacto = Contacto, 
			@TaxId = TaxId	
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCatConsignadoClienteVw WITH(NOLOCK)
	WHERE	ClaConsignado = @ClaConsignadoFab
	AND		ClaClienteUnico = @ClaClienteUnicoFab

	--Obtener Nombre de la Colonia
	SELECT	@NomColoniaFab = RTRIM(LTRIM(NomColonia))
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCatColoniaWtVw WITH(NOLOCK)
	WHERE	ClaColoniaUnico = @ClaColoniaUnico
	
	SET		@pnClaConsignado = NULL

	SELECT	@pnClaConsignado = cc.ClaConsignado
	FROM	DEAOFINET05.Ventas.VtaSch.VtaCatConsignadoClienteVw cc WITH(NOLOCK)
	LEFT JOIN DEAOFINET05.Ventas.VtaSch.VtaCatColoniaWtVw c WITH(NOLOCK) 
        ON  c.ClaColoniaUnico = cc.ClaColoniaUnico 
	WHERE	cc.ClaClienteUnico = @ClaClienteUnico
	AND		cc.BajaLogica = 0		
	AND		cc.NomConsignado = @NomConsignado
	AND (
			ISNULL(cc.ClaColoniaUnico, 0) = ISNULL(@ClaColoniaUnico, 0)
			OR ( @NomColoniaFab IN ('POR ASIGNAR', 'SIN ASIGNAR', '-') AND cc.ClaColoniaUnico IS NULL ) 
			OR ( c.NomColonia IN ('POR ASIGNAR', 'SIN ASIGNAR', '-') AND @ClaColoniaUnico IS NULL ) 
			)
	AND		cc.ClaCiudadUnico = @ClaCiudadCons
	AND		ISNULL(cc.ClaCodigoPostal, 0) = ISNULL(@ClaCodigoPostal, 0)
	AND		ISNULL(cc.NumExterior, '') = ISNULL(@NumExterior, '')
	AND		ISNULL(cc.NumInterior, '') = ISNULL(@NumInterior, '')
	AND		ISNULL(cc.EntreCalles, '') = ISNULL(@EntreCalles, '')
	ORDER BY	
            cc.ClaConsignado

	SELECT	@pnClaConsignado	'ClaConsignado',
			@ClaClienteUnico    'ClaClienteUnico', 
			@NomConsignado      'NomConsignado',
			@ClaCiudadCons      'ClaCiudadCons', 
			@ClaColoniaUnico    'ClaColoniaUnico', 
			@ClaCodigoPostal    'ClaCodigoPostal', 
			@Calle              'Calle', 
			@NumExterior        'NumExterior', 
			@NumInterior        'NumInterior', 
			@EntreCalles        'EntreCalles', 
			@ClaMedioEmbarque   'ClaMedioEmbarque', 
			@ClaveInternacional 'ClaveInternacional', 
			@Lada               'Lada', 
			@Telefono           'Telefono', 
			@pnClaUsuarioMod    'pnClaUsuarioMod', 
			@psNombrePcMod      'psNombrePcMod',
			@Contacto           'Contacto', 
			@TaxId              'TaxId'	

	-- Nueva Validacion Ver si Ya existe el consignado para el Cliente Unico
	IF ISNULL( @pnClaConsignado, 0 ) != 0
	BEGIN
		IF EXISTS (	SELECT	1 
                    FROM	DEAOFINET05.Ventas.VtaSch.VtaCatConsignadoClienteVw 
                    WHERE	claClienteUnico = @ClaClienteUnico
                    AND		claConsignado = @pnClaConsignado	)
		BEGIN
			SELECT @ClaEstatus = 0, @Mensaje = 'Consignado ya existe'
		END
		RETURN
	END

    EXEC    DEAOFINET05.Ventas.VtaSch.VtaCatConsignadoClienteIUProc 
            @ClaEstatus OUTPUT, 
            @Mensaje OUTPUT, 
            @ClaClienteUnico, 
            @pnClaConsignado OUTPUT, 
            @NomConsignado,
            NULL, 
            @ClaCiudadCons, 
            @ClaColoniaUnico, 
            @ClaCodigoPostal, 
            NULL, 
            @Calle, 
            @NumExterior, 
            @NumInterior, 
            @EntreCalles, 
            0, 0,
            @ClaMedioEmbarque, 
            NULL, NULL, NULL, NULL, 
            @ClaveInternacional, 
            @Lada, 
            @Telefono, 
            NULL, NULL, 
            @pnClaUsuarioMod, 
            @psNombrePcMod,
            @pnEsResultset = 0,
            @psContacto= @Contacto, 
            @psTaxId= @TaxId	

	IF ISNULL(@Mensaje,'') <> ''
		SELECT @psMensaje = ISNULL(@Mensaje,'') +  ' (VtaSch.VtaCatConsignadoClienteIUProc).'

	SET NOCOUNT OFF    

	RETURN            

	-- Manejo de Errores              
	ABORT:
	SELECT @psMensaje = ISNULL(@Mensaje,'')  

END