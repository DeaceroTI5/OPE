
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
exec OPESch.OPEPlacaParaDescargaCmb @psValor='548DV9',@PnTipo=99,@PnModoSel=default,@pnClaUbicacion=153
go
exec OPESch.OPE_CU444_Pag6_Grid_RecepcionTraspaso_Sel @pnClaUbicacion=153,@psPlaca='548DV9',@pnIdViajeOrigen=34797
, @pnClaAlmacen = 4
go
exec OPESch.OPE_CU444_Pag6_Grid_GridProductoReferencias_Sel @pnClaUbicacion=153,@psPlaca='548DV9',@pnIdViajeOrigen=34797,@pnClaArticuloAux=NULL
go
exec OPESch.OPE_CU444_Pag6_Boton_btnAnalizaFin_Proc @pnClaUbicacion=153,@psPlaca='548DV9'
go
exec OPESch.OPE_CU444_Pag6_Grid_RecepcionTraspaso_Sel @pnClaUbicacion=153,@psPlaca='548DV9',@pnIdViajeOrigen=34797
go
exec OPESch.OPE_CU444_Pag6_Grid_GridProductoReferencias_Sel @pnClaUbicacion=153,@psPlaca='548DV9',@pnIdViajeOrigen=34797,@pnClaArticuloAux=NULL
go


select * from sysobjects where name like '%Almacen%Cmb'


sp_helptext 'OPESch.OPE_CU444_Pag6_Grid_RecepcionTraspaso_Sel'
sp_helptext 'OpeSch.OPE_CU444_Pag7_Grid_GridProductoMultiAlmacen_Sel'


SELECT * FROM OpeSch.OPeTraRecepTraspasoProd WHERE ClaUbicacion = 153 AND IdViajeOrigen = 34797
SELECT * FROM OpeSch.OPeTraRecepTraspasoProdAux WHERE ClaUbicacion = 153 AND IdViajeOrigen = 34797
SELECT * FROM OpeSch.OPeTraRecepTraspasoProdRecibido WHERE ClaUbicacion = 153 AND IdViajeOrigen = 34797


exec OPESch.OPE_CU444_Pag6_Boton_FinalizarDescarga_Proc @pnClaUbicacion=153,@psPlaca='548DV9',@pnIdViajeOrigen=34797,@pnEsRecepcionTerminada=1,@psNombrePcMod='100VSALINAS',@pnClaUsuarioMod=4
go
exec OPESch.OPE_CU444_Pag6_Boton_btnAnalizaFin_Proc @pnClaUbicacion=153,@psPlaca='548DV9'
go

sp_helptext 'OPESch.OPE_CU444_Pag1_Boton_GrabaProdRecibidos_Proc'

*/

ALTER PROCEDURE OpeSch.OPE_CU444_Pag1_Boton_GrabaProdRecibidos_Proc
	@pnClaUbicacion			INT,
	@pnClaUbicacionOrigen	INT,
	@psPlaca				VARCHAR(20),
	@pnClaArticulo			INT,
	@pnIdBoleta				INT,
	@pnClaAlmacen			INT,
	@pnClaSubAlmacen		INT,
	@pnClaSubSubAlmacen		INT,
	@pnClaSeccion			INT,
	@pnIdViajeOrigen		INT,
	@pnClaTipoInventario	INT,
	@pnIdFabricacion		INT,
	@pnIdFabricacionDet		INT,
	@pnKilosTara			INT,
	@pnCantidad				NUMERIC(22,3),
	@pnKgs					NUMERIC(22,3),
	@psOpm					VARCHAR(500),
	@psRollo				VARCHAR(500),
	@psCarrete				VARCHAR(500),
	@psNombrePcMod			VARCHAR (64),	
	@pnClaUsuarioMod		INT

AS

BEGIN
	SET NOCOUNT ON
	
	IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
		SELECT 'PROCEDIMIENTO OpeSch.OPE_CU444_Pag1_Boton_GrabaProdRecibidos_Proc'
	/*	
	DROP TABLE OPESch.OPE_CU444_Pag1_Boton_GrabaProdRecibidos_Proc_LOG
	CREATE TABLE OPESch.OPE_CU444_Pag1_Boton_GrabaProdRecibidos_Proc_LOG
	(
		pnClaUbicacion		INT,
		pnClaUbicacionOrigen INT,
		psPlaca			VARCHAR(20),
		pnClaArticulo		INT,
		pnIdBoleta			INT,
		pnClaAlmacen		INT,
		pnClaSubAlmacen	INT,
		pnClaSubSubAlmacen	INT,
		pnClaSeccion		INT,
		pnIdViajeOrigen	INT,
		pnClaTipoInventario INT,
		pnIdFabricacion INT,
		pnIdFabricacionDet INT,
		pnKilosTara		INT,
		pnCantidad	Numeric(22,3),
		pnKgs		Numeric(22,3),
		psOPM		VARCHAR(20),
		psRollo		VARCHAR(20),
		psNombrePcMod		VARCHAR (64),	
		pnClaUsuarioMod	INT,
		FechaUltimaMod	DATETIME
		
	)

		INSERT INTO 	OPESch.OPE_CU444_Pag1_Boton_GrabaProdRecibidos_Proc_LOG
		SELECT 
			@pnClaUbicacion, @pnClaUbicacionOrigen, @psPlaca, @pnClaArticulo, @pnIdBoleta, @pnClaAlmacen, @pnClaSubAlmacen, @pnClaSubSubAlmacen,
			@pnClaSeccion, @pnIdViajeOrigen, @pnClaTipoInventario, @pnIdFabricacion, @pnIdFabricacionDet, @pnKilosTara, @pnCantidad, @pnKgs,
			@psOPM, @psRollo, @psNombrePcMod, @pnClaUsuarioMod, GETDATE()

	*/

	
	DECLARE @pnIdRenglonRecepcion INT
	
	
	--Obtener Almacenes Default en base a Familia de Producto
	DECLARE @nClaAlmacenDefault			INT, 
			@nClaSubAlmacenDefault		INT, 
			@nClaSubSubAlmacenDefault	INT, 
			@nClaSeccionDefault			INT,
			@nClaUbicacionOrigen		INT 
 
        
    
    IF @pnClaAlmacen IS NULL
    BEGIN
		EXEC OpeSch.OpeObtenerAlmacenesDefaultProc 
			@pnVersion = 1, 
			@pnClaUbicacion = @pnClaUbicacion, 
			@pnClaTipoInventario = @pnClaTipoInventario, 
			@pnClaArticulo = @pnClaArticulo, 
			@pnClaAlmacenDefault = @nClaAlmacenDefault OUTPUT, 
			@pnClaSubAlmacenDefault = @nClaSubAlmacenDefault OUTPUT, 
			@pnClaSubSubAlmacenDefault = @nClaSubSubAlmacenDefault OUTPUT, 
			@pnClaSeccionDefault = @nClaSeccionDefault OUTPUT
    
		IF  @nClaAlmacenDefault IS NOT NULL
			BEGIN
				SELECT @pnClaAlmacen = @nClaAlmacenDefault , 
						@pnClaSubAlmacen = @nClaSubAlmacenDefault , 
						@pnClaSubSubAlmacen = @nClaSubSubAlmacenDefault , 
						@pnClaSeccion = @nClaSeccionDefault 
		END
		ELSE
		BEGIN 		
		
			--Obtener Almacenes Default por configuracion
			SELECT	@nClaAlmacenDefault  = nValor1, @nClaSubAlmacenDefault = nValor2 --LVR Pendiente
			FROM	OpeSch.TiCatConfiguracionVw WITH(NOLOCK)      
			WHERE	ClaUbicacion = @pnClaUbicacion AND
					ClaSistema = 127 AND
					ClaConfiguracion = 1271001      
	        			
			SELECT	@pnClaAlmacen = @nClaAlmacenDefault , 
					@pnClaSubAlmacen = @nClaSubAlmacenDefault , 
					@pnClaSubSubAlmacen = NULL , 
					@pnClaSeccion = NULL
			
		END
	END

	--Validar que no se sobrepase la cantidad del transpaso
	-- SÓLO SI NO TRAE REFERENCIAS ¿POR QUÉ? NNAVA
	IF (ISNULL(@psRollo, '') = '' AND ISNULL(@psCarrete,'') = '')
	BEGIN
	
		/*UPDATE*/	
		IF EXISTS(
			SELECT	1
			FROM   OpeSch.OpeTraRecepTraspasoProdRecibido TraspasoProdRecibido WITH (NOLOCK)
			Where	TraspasoProdRecibido.ClaUbicacion = @pnClaUbicacion AND
					TraspasoProdRecibido.IdViajeOrigen = @pnIdViajeOrigen AND
					TraspasoProdRecibido.ClaUbicacionOrigen = @pnClaUbicacionOrigen AND
					TraspasoProdRecibido.ClaArticuloRecibido = @pnClaArticulo AND
					TraspasoProdRecibido.IdFabricacion = @pnIdFabricacion AND
					TraspasoProdRecibido.IdFabricacionDet = @pnIdFabricacionDet
		)
		BEGIN
		
			UPDATE	TraspasoProdRecibido
			SET		TraspasoProdRecibido.CantRecibida = @pnCantidad, 
					TraspasoProdRecibido.PesoRecibido = @pnKgs,
					TraspasoProdRecibido.IdBoleta = @pnIdBoleta,
					TraspasoProdRecibido.ClaTipoInventario = @pnClaTipoInventario,
					TraspasoProdRecibido.FechaUltimaMod = GETDATE(),
					TraspasoProdRecibido.ClaUsuarioMod = @pnClaUsuarioMod,
					TraspasoProdRecibido.NombrePcMod = @psNombrePcMod
			FROM	OpeSch.OpeTraRecepTraspasoProdRecibido TraspasoProdRecibido WITH (NOLOCK)
			WHERE	TraspasoProdRecibido.ClaUbicacion = @pnClaUbicacion AND
					TraspasoProdRecibido.IdViajeOrigen = @pnIdViajeOrigen AND
					TraspasoProdRecibido.ClaUbicacionOrigen = @pnClaUbicacionOrigen AND
					TraspasoProdRecibido.ClaArticuloRecibido = @pnClaArticulo AND
					TraspasoProdRecibido.IdFabricacion = @pnIdFabricacion AND
					TraspasoProdRecibido.IdFabricacionDet = @pnIdFabricacionDet
			
			
			GOTO ActualizaTraspaso
		END				
	END 
	
	/*INSERT*/
	SELECT	@pnIdRenglonRecepcion = Max(IdRenglonRecepcion) + 1
	FROM	OpeSch.OpeTraRecepTraspasoProdRecibido TraspasoProdRecibido WITH (NOLOCK)
	WHERE	TraspasoProdRecibido.ClaUbicacion = @pnClaUbicacion AND
			TraspasoProdRecibido.IdViajeOrigen = @pnIdViajeOrigen AND
			TraspasoProdRecibido.ClaUbicacionOrigen = @pnClaUbicacionOrigen
									
	IF @pnIdRenglonRecepcion IS NULL SELECT @pnIdRenglonRecepcion = 1 

	INSERT INTO OpeSch.OpeTraRecepTraspasoProdRecibido
			(IdViajeOrigen, 
			ClaUbicacionOrigen, 
			ClaUbicacion, 
			IdFabricacion, 
			IdFabricacionDet, 
			IdRenglonRecepcion, 
			ClaAlmacen, 
			ClaSubAlmacen, 
			ClaSubSubAlmacen, 
			ClaSeccion, 
			Referencia1,
			Referencia2, 
			Referencia3, 
			Referencia4,
			Referencia5, 
			ClaArticuloRecibido, 
			CantRecibida, 
			PesoRecibido,
			PesoTaraRecibido, 
			ComentariosRecepcion, 
			FechaUltimaMod, 
			NombrePcMod, 
			ClaUsuarioMod,
			ClaTipoInventario, 
			EsPesajeParcial, 
			KilosReales, 
			IdBoleta, 
			PorcentajeMaterial)		
	SELECT	@pnIdViajeOrigen, 
			@pnClaUbicacionOrigen, 
			@pnClaUbicacion, 
			@pnIdFabricacion, 
			@pnIdFabricacionDet, 
			@pnIdRenglonRecepcion, 
			@pnClaAlmacen, 
			@pnClaSubAlmacen, 
			NULL, NULL, NULL, NULL, 
			NULLIF(@psOpm, ''),
			NULLIF(@psRollo, ''),	
			NULLIF(@psCarrete, ''),
			@pnClaArticulo, 
			@pnCantidad, 
			@pnKgs, 
			ISNULL(@pnKilosTara, 0), 
			'', GETDATE(), 
			@psNombrePcMod, 
			@pnClaUsuarioMod,
			@pnClaTipoInventario, NULL, NULL, 
			@pnIdBoleta, 
			NULL

	IF @@SERVERNAME = 'SRVDBDES01\ITKQA'
		SELECT '' AS 'OpeTraRecepTraspasoProdRecibido',* FROM  OpeSch.OpeTraRecepTraspasoProdRecibido WITH(NOLOCK)
		WHERE	ClaUbicacion = @pnClaUbicacion AND
			IdViajeOrigen = @pnIdViajeOrigen AND
			ClaUbicacionOrigen = @pnClaUbicacionOrigen

	ActualizaTraspaso:
															
	UPDATE	TraspasoFab
	SET 	TraspasoFab.EsRecibida = 1,
			TraspasoFab.FechaUltimaMod = GETDATE(),
			TraspasoFab.ClaUsuarioMod = @pnClaUsuarioMod,
			TraspasoFab.NombrePcMod = @psNombrePcMod			
	FROM	OpeSch.OPETraBoleta Boleta WITH (NOLOCK)
			INNER JOIN OpeSch.OpeTraRecepTraspaso Traspaso WITH (NOLOCK)
	ON		Boleta.IdBoleta = Traspaso.IdBoleta AND
			Boleta.ClaUbicacion = Traspaso.ClaUbicacion AND
			Boleta.ClaUbicacionOrigen = Traspaso.ClaUbicacionOrigen AND
			Boleta.IdViajeOrigen = Traspaso.IdViajeOrigen
			INNER JOIN OpeSch.OpeTraRecepTraspasoFab TraspasoFab WITH (NOLOCK)
	ON		Boleta.ClaUbicacion = TraspasoFab.ClaUbicacion AND
			Boleta.IdViajeOrigen= TraspasoFab.IdViajeOrigen
	Where	Boleta.Placa = @psPlaca AND
			Boleta.ClaUbicacion = @pnClaUbicacion AND
			TraspasoFab.IdFabricacion = @pnIdFabricacion

 
	-- SELECT 1

	SET NOCOUNT OFF
	
END