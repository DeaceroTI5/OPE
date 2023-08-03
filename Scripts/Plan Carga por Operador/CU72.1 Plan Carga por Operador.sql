USE Operacion
GO

DECLARE   @nClaUbicacion	INT = 327
		, @pnClaPlanCarga	INT = 3577

---------------------------------------------------------------------------
DECLARE @tbDatos AS TABLE (
	  ClaUbicacion			INT					, IdPlanCarga			INT					, PlanCarga				INT					, PesoRealEmbarcado     NUMERIC(22,4)
	, Placa        			VARCHAR(12)			, ClaChofer   			INT					, ClaTransporte 		INT					, ClaTransportista 		INT
	, FechaPlan             DATETIME			, NomFleCatTransporte   VARCHAR(200)		, ClaCiudad   			INT					, Nombre                VARCHAR(200)
	, NombreCiudad          VARCHAR(100)		, NombreEstatus         VARCHAR(150)		, ImpPlan      			VARCHAR(20)			, EmbReal               NUMERIC(22,4)
	, EmbCub                NUMERIC(22,4)		, PorcCubGrd            NUMERIC(22,2)		, PorcRealGrd 			VARCHAR(20)/*int*/	, FechaCaptura			DATETIME
)

-- Universo 
INSERT INTO @tbDatos
exec OPESch.OPE_CU72_Pag1_Grid_PlanesCarga_Sel 
	  @pnClaUbicacion	= @nClaUbicacion
	, @pnClaPlanCarga	= @pnClaPlanCarga

-- Cosulta de datos
SELECT	  ClaUbicacion
		, IdPlanCarga
		, PorcReal = PorcRealGrd
		, PorcCub = PorcCubGrd  
FROM	@tbDatos

-- Actualizar estatus a Impreso
EXEC OpeSch.OPE_CU72_Pag1_Boton_ActualizarEstatus_Proc 
	@pnClaUbicacion		= @nClaUbicacion,
	@pnIdPlanCarga		= @pnClaPlanCarga,
	@pnClaUsuarioMod	= 1,
	@psNombrePcMod		= '100-hvalle' 