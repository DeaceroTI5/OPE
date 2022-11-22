GO
-- 'OPESch.OPE_CU550_Pag25_Grid_ViajesPorRecibirDet_CambioValor_Kilos_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag25_Grid_ViajesPorRecibirDet_CambioValor_Kilos_Sel
@pnClaUbicacion		INT,
@psEstatusEntrega	VARCHAR(20),
@pnKilos			NUMERIC(22, 4),
@pnClaArticulo		INT
AS
BEGIN

	IF @psEstatusEntrega = 'No Entregado'
	BEGIN
		
		RAISERROR('No se puede modificar una factura que no trae evidencia. Favor de revisar.',16, 1)
		SELECT Kilos = 0
		RETURN
		
	END

	
	DECLARE @nPesoTeoricoKgs INT
	
	SELECT	@nPesoTeoricoKgs = PesoTeoricoKgs 
	FROM	OpeSch.OpeArtCatArticuloVw WITH(NOLOCK) 
	WHERE	ClaArticulo = @pnClaArticulo 
	AND		ClaTipoInventario = 1
	
	IF ISNULL(@nPesoTeoricoKgs,0) > 0
		SELECT Cantidad = @pnKilos / @nPesoTeoricoKgs


END