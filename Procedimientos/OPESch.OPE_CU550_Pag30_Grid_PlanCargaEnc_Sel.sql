USE Operacion
GO
--- 'OPESch.OPE_CU550_Pag30_Grid_PlanCargaEnc_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag30_Grid_PlanCargaEnc_Sel
@pnClaUbicacion INT,
@pnIdPlanCargaFiltro INT,
@pnIdViajeFiltro INT,
@pnClaCliente INT,
@pdFechaInicio DATETIME,
@pdFechaFin DATETIME,
@psFacturas	VARCHAR(30) = ''
AS
BEGIN

	-- EXEC OPESch.OPE_CU550_Pag30_Grid_PlanCargaEnc_Sel @pnClaUbicacion=325,@pnIdPlanCargaFiltro=NULL,@pnIdViajeFiltro=NULL,@pnClaCliente=NULL,@pdFechaInicio='2022-10-01 00:00:00',@pdFechaFin='2023-01-16 00:00:00'

	SET NOCOUNT ON
	
	IF @pdFechaInicio > @pdFechaFin
	BEGIN
		RAISERROR('La fecha inicio no puede ser mayor a la fecha fin. Favor de verificar.',16,1)
		RETURN
	END

	SET @psFacturas = ISNULL(@psFacturas,'')

	DECLARE @tbUniverso TABLE(
			  IdPlanCarga		INT
			, IdViaje			INT
			, IdBoleta			INT
			, ClaTransportista	INT	
			, NomTransportista	VARCHAR(200)
			, NomTransporte		VARCHAR(200)
			, Placas			VARCHAR(12)
			, NomChofer			VARCHAR(100)
			, TonEmbarcadas		NUMERIC(22,4)
			, FechaViaje		DATETIME
			, KmRecorridos		NUMERIC(22,4)
			, DestinoFinal		VARCHAR(30)
			, NombreEstatus		VARCHAR(150)
	)

	DECLARE @tbViajeFactura TABLE(
			  IdViaje		INT
			, Facturas		VARCHAR(1000)
	)

	INSERT INTO @tbUniverso (
		  IdPlanCarga		, IdViaje			, IdBoleta			, ClaTransportista	
		, NomTransportista	, NomTransporte		, Placas			, NomChofer			
		, TonEmbarcadas		, FechaViaje		, KmRecorridos		, DestinoFinal		
		, NombreEstatus		
	)
	SELECT 
		--'' AS ShippingTicketImg,
		--'' AS Certificado,
		--NULL AS ShipID,
		t1.IdPlanCarga,
		t2.IdViaje,
		t1.IdBoleta,
		t1.ClaTransportista,
		t4.NomTransportista,
		t5.NomTransporte,
		t1.Placa AS Placas,
		t3.NomChofer,
		t1.PesoRealEmbarcado AS TonEmbarcadas,
		--NULL AS DuracionPta,
		t2.FechaViaje,
		t6.KmsReal AS KmRecorridos,
		t8.NomCiudad AS DestinoFinal,
		t9.NombreEstatus
	FROM OpeSch.OpeTraPlanCarga t1 WITH(NOLOCK)
		LEFT JOIN opeSch.OpeTraViaje t2 WITH(NOLOCK)
		ON t2.ClaUbicacion = t1.ClaUbicacion
		AND t2.IdPlanCarga = t1.IdPlanCarga
		LEFT JOIN OpeSch.OpeTraBoletaHis	t3 WITH(NOLOCK)
		ON	t3.ClaUbicacion = t1.ClaUbicacion
		AND t3.IdBoleta = t1.IdBoleta
		LEFT JOIN FleSch.FLECatTransportistaVw	t4 WITH(NOLOCK)
		ON	t4.ClaUbicacion = t1.ClaUbicacion
		AND t4.ClaTransportista = t1.ClaTransportista
		LEFT JOIN FleSch.FLECatTransporteVw t5 WITH(NOLOCK)
		ON	t5.ClaTransporte = t1.ClaTransporte
		LEFT JOIN fleSch.FleTraTabular t6 WITH(NOLOCK)
		ON	t6.ClaUbicacion = t1.ClaUbicacion
		AND t6.ClaTipoTabular = 1
		AND t6.Referencia1 = t2.IdViaje
		--LEFT JOIN OpeSch.OpeRelViajeShipID t7 WITH(NOLOCK)
		--ON t7.ClaUbicacion = t1.ClaUbicacion 
		--AND t7.IdViaje = t2.IdViaje
		LEFT JOIN OpeSch.OpeVtaCatCiudadVw t8
		ON	t8.ClaCiudad = t6.ClaCiudadDestino
		LEFT JOIN	OpeSch.OpeTiCatEstatusPlanCargaVw t9
		ON	t1.ClaEstatusPlanCarga = t9.ClaEstatus
	WHERE t1.ClaUbicacion = @pnClaUbicacion
	AND	t1.ClaEstatusPlanCarga IN (2,3)
	AND (( t1.IdPlanCarga = @pnIdPlanCargaFiltro
	OR  t2.IdViaje = @pnIdViajeFiltro)
	OR  
		(@pnIdViajeFiltro IS NULL AND @pnIdPlanCargaFiltro IS NULL AND (CONVERT(VARCHAR(8), t2.FechaViaje, 112) >= @pdFechaInicio AND CONVERT(VARCHAR(8), t2.FechaViaje, 112) <= @pdFechaFin))
	)
	--ORDER BY t7.ShipID
	UNION

	SELECT 
		--'' AS ShippingTicketImg,
		--'' AS Certificado,
		--NULL AS ShipID,
		t1.IdPlanCarga,
		NULL AS IdViaje,
		t1.IdBoleta,
		t1.ClaTransportista,
		t4.NomTransportista,
		t5.NomTransporte,
		t1.Placa AS Placas,
		t3.NomChofer,
		t1.PesoRealEmbarcado AS TonEmbarcadas,
		--NULL AS DuracionPta,
		t1.FechaPlan AS FechaViaje,
		NULL AS KmRecorridos,
		NULL AS DestinoFinal,
		t9.NombreEstatus
	FROM OpeSch.OpeTraPlanCarga t1 WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraBoleta	t3 WITH(NOLOCK)
		ON	t1.ClaUbicacion = t3.ClaUbicacion
		AND t1.IdBoleta = t3.IdBoleta
		LEFT JOIN FleSch.FLECatTransportistaVw	t4 WITH(NOLOCK)
		ON	t4.ClaUbicacion = t1.ClaUbicacion
		AND t4.ClaTransportista = t1.ClaTransportista
		LEFT JOIN FleSch.FLECatTransporteVw t5 WITH(NOLOCK)
		ON	t5.ClaTransporte = t1.ClaTransporte
		LEFT JOIN	OpeSch.OpeTiCatEstatusPlanCargaVw t9
		ON	t1.ClaEstatusPlanCarga = t9.ClaEstatus	
	WHERE t1.ClaUbicacion = @pnClaUbicacion
	AND	t1.ClaEstatusPlanCarga IN (1)
	AND (  ( t1.IdPlanCarga = @pnIdPlanCargaFiltro)
		OR  
		(@pnIdViajeFiltro IS NULL AND @pnIdPlanCargaFiltro IS NULL AND (CONVERT(VARCHAR(8), t1.FechaPlan, 112) >= @pdFechaInicio AND CONVERT(VARCHAR(8), t1.FechaPlan, 112) <= @pdFechaFin))
		)

	INSERT INTO @tbViajeFactura(
		IdViaje, Facturas
	)
	SELECT	  IdViaje	
			, Facturas		= 	STUFF(
										(
											SELECT	', ' + RTRIM(LTRIM(b.IdFacturaAlfanumerico)) 
											FROM	OpeSch.OpeTraMovEntSal b
											where	b.ClaUbicacionOrigen = @pnClaUbicacion
											AND		a.IdViaje = b.IdViaje
											FOR XML PATH ('')
										)
								, 1, 1, '')
	FROM	@tbUniverso a
	





	SELECT	  ''			AS ShippingTicketImg
			, ''			AS Certificado
			, NULL			AS ShipID
			, IdPlanCarga		
			, a.IdViaje			
			, IdBoleta			
			, ClaTransportista	
			, NomTransportista	
			, NomTransporte		
			, Placas			
			, NomChofer			
			, TonEmbarcadas		
			, NULL			AS DuracionPta
			, FechaViaje		
			, KmRecorridos		
			, DestinoFinal		
			, Facturas
			, NombreEstatus	
	FROM	@tbUniverso a
	LEFT JOIN @tbViajeFactura b
	ON		a.IdViaje = b.IdViaje
	WHERE	(@psFacturas = '' OR (Facturas LIKE '%'+@psFacturas+'%'))
		
	SET NOCOUNT OFF
END