USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU441_Pag2_Grid_ConsultaModCR_Sel'
--begin tran
--exec OPESch.OPE_CU441_Pag2_Grid_ConsultaModCR_Sel @pnClaUbicacion=267,@pnIdPlanRecoleccion=843,@pnClaTipoInventario=default,@pnIdRmaModCR=240843,@pnClaClienteModCR=NULL,@pnClaConsignadoModCR=NULL,@psIdioma='Spanish'
--rollback tran
GO
/*
--Joel Coronado
--Fecha: 20141216
*/
ALTER PROCEDURE OpeSch.OPE_CU441_Pag2_Grid_ConsultaModCR_Sel
@pnClaUbicacion INT,
@pnIdPlanRecoleccion INT,
@pnClaTipoInventario INT = 1,
@pnIdRmaModCR INT,
@pnClaClienteModCR INT,
@pnClaConsignadoModCR INT,
@psIdioma VARCHAR(10) = 'Spanish'
AS
BEGIN
	SET NOCOUNT ON
	
	IF OBJECT_ID('TEMPDB..#Tmp') IS NOT NULL
		DROP TABLE #Tmp
	IF OBJECT_ID('TEMPDB..#Reclamaciones') IS NOT NULL
		DROP TABLE #Reclamaciones
	IF OBJECT_ID('TEMPDB..#Facturas') IS NOT NULL
		DROP TABLE #Facturas
	IF OBJECT_ID('TEMPDB..#Prefijos') IS NOT NULL
		DROP TABLE #Prefijos	
	IF OBJECT_ID('TEMPDB..#FacturasDet') IS NOT NULL
		DROP TABLE #FacturasDet
	IF OBJECT_ID('TEMPDB..#OpeTraReclamaciones_tmp') IS NOT NULL
		DROP TABLE #OpeTraReclamaciones_tmp	

	DECLARE @nClaUbicacionVentas INT
	
	SELECT @nClaUbicacionVentas = ClaUbicacionVentas FROM OpeSch.OpeTiCatUbicacionVw  WITH(NOLOCK) WHERE ClaUbicacion = @pnClaUbicacion 
	
	SELECT	t1.ClaUbicacion, t1.IdReclamacion, t1.ClaCliente, t1.ClaClienteConsignado
	INTO	#Tmp
	FROM	OpeSch.OpeTraReclamacionEnc t1 WITH(NOLOCK)
	WHERE	t1.ClaUbicacion = @pnClaUbicacion AND 
			t1.ClaEstatus = 1

	SELECT	t1.ClaUbicacion, t1.IdReclamacion, t1.ClaCliente, t1.ClaClienteConsignado AS ClaConsignado, t2.IdReclamacionDet, 
			t2.IdFactura, t2.IdFacturaDet, t2.IdViaje, t2.IdMovEntSal, t2.ClaArticulo, t2.Cantidad, t2.CantidadKg,
			 t2.IdFabricacion
	INTO	#Reclamaciones
	FROM	#Tmp t1 WITH(NOLOCK)
			INNER JOIN OpeSch.OpeTraReclamacionDet t2 WITH(NOLOCK)
	ON		t2.IdReclamacion = t1.IdReclamacion
	ORDER BY 1 DESC

	SELECT	t1.ClaUbicacion AS ClaUbicacion, t2.IdMovEntSal, t3.ClaCliente, t3.ClaConsignado, t2.IdFactura, 
			CONVERT (DATETIME, CONVERT(VARCHAR(8), t2.FechaEntSal, 112)) AS FechaFactura,
			t2.IdFacturaAlfanumerico AS IdFacturaAlfanumerico, 	t3.ClaCiudad AS ClaCiudad, t2.IdFabricacion
	INTO	#Facturas
	FROM	(SELECT DISTINCT IdMovEntSal, rec.ClaUbicacion, rec.IdFactura FROM #Reclamaciones rec) AS t1
			INNER JOIN OpeSch.OpeTraMovEntSal t2 WITH(NOLOCK)
	ON		t2.IdFactura = t1.IdFactura AND
			t2.ClaUbicacion = t1.ClaUbicacion
			INNER JOIN OpeSch.OpeTraFabricacionVw t3 WITH(NOLOCK)
	ON		t2.IdFabricacion = t3.IdFabricacion
	
	--UPDATE  t2
	--SET		t2.IdFacturaAlfanumerico = PRE.PrefijoStr + CONVERT( VARCHAR(6), t2.IdFactura % 1000000 )
	--FROM 	#Facturas t2
	--		INNER JOIN #Prefijos pre
	--ON		PRE.PrefijoNum = t2.IdFactura / 1000000 
	--AND		PRE.ClaUbicacion = t2.ClaUbicacion

	SELECT	t1.IdFactura, t1.IdFacturaDet AS IdFacturaDet, t2.IdFabricacion, t2.IdFabricacionDet, t2.ClaArticulo,
			t2.CantEmbarcada CantFacturada, t2.PesoEmbarcado PesoFacturado
	INTO	#FacturasDet
	FROM	#Reclamaciones t1
			INNER JOIN #Facturas t3
	ON		t3.ClaUbicacion = t1.ClaUbicacion AND
			t3.IdFactura = t1.IdFactura
			INNER JOIN OpeSch.OpeTraMovEntSalDet t2 WITH(NOLOCK)
	ON		t2.IdMovEntSal = t3.IdMovEntSal AND
			t2.IdFabricacion = t3.IdFabricacion AND
			t2.ClaArticulo= t1.ClaArticulo


	SELECT	0 AS Incluye, t2.ClaCliente, t2.ClaConsignado, t1.IdReclamacion AS IdRMA, t1.ClaArticulo, t6.PesoTeoricoKgs,  t2.IdFactura, 
			t2.FechaFactura, t2.ClaCiudad, t1.Cantidad AS CantRecolectar, t1.CantidadKg AS PesoRecolectar, t1.Cantidad AS CantRecoge,
			t2.IdFacturaAlfanumerico,
			t3.NombreCliente, 
			t7.IdFacturaDet, t7.CantFacturada, t7.PesoFacturado,
			LTRIM(RTRIM(t4.ClaConsignado)) + ' - ' + LTRIM(RTRIM(t4.NombreConsignado)) AS NombreConsignado,
			LTRIM(RTRIM(t5.ClaCiudad)) + ' - ' + LTRIM(RTRIM(t5.NombreCiudad)) AS NombreCiudad,
			LTRIM(RTRIM(t6.ClaveArticulo)) + ' - ' + LTRIM(RTRIM(t6.NomArticulo)) AS NomArticulo
	INTO	#OpeTraReclamaciones_tmp
	FROM	#Reclamaciones t1
			INNER JOIN #Facturas t2 WITH(NOLOCK)
	ON		t2.ClaUbicacion = t1.ClaUbicacion AND
			t2.IdFactura = t1.IdFactura AND
			t2.IdFabricacion = t1.IdFabricacion AND
			t2.ClaCliente = t1.ClaCliente AND
			(t2.ClaConsignado = t1.ClaConsignado OR ISNULL(t1.ClaConsignado,0) = -1)
			INNER JOIN #FacturasDet t7
	ON		t7.IdFactura = t1.IdFactura AND
			t7.IdFabricacion = t1.IdFabricacion AND
			t7.ClaArticulo = t1.ClaArticulo
			LEFT JOIN OpeSch.OpeVtaCatClienteVw t3 WITH(NOLOCK)
	ON		t3.ClaCliente = t2.ClaCliente
			LEFT JOIN OpeSch.OpeVtaCatConsignadoVw t4 WITH(NOLOCK)
	ON		t4.ClaConsignado = t2.ClaConsignado
			INNER JOIN OpeSch.OpeVtaCatCiudadVw t5 WITH(NOLOCK)
	ON		t5.ClaCiudad = t2.ClaCiudad
			INNER JOIN OpeSch.OpeArtCatArticuloVw t6 WITH(NOLOCK)
	ON		t6.ClaArticulo = t1.ClaArticulo
	WHERE	t2.IdFacturaAlfanumerico IS NOT NULL

	SELECT	Incluye,
			ClaCliente,
			ClaConsignado,
			IdRMA,
			ClaArticulo,
			PesoTeoricoKgs,
			IdFactura,
			FechaFactura,
			ClaCiudad,
			t1.CantRecolectar - ISNULL((SELECT SUM(PlanRec.CantRecolectar) 
										FROM OpeSch.OpeTraPlanRecoleccionDet PlanRec  WITH(NOLOCK)
										INNER JOIN OpeSch.OpeTraPlanRecoleccion PlanRecEnc
										ON		PlanRecEnc.IdPlanRecoleccion = PlanRec.IdPlanRecoleccion
										WHERE	t1.IdRMA = PlanRec.IdRMA AND
												PlanRecEnc.ClaEstatus <> 6), 0) AS CantRecolectar,
			t1.PesoRecolectar - ISNULL((SELECT SUM(PlanRec.PesoRecolectar) 
										FROM OpeSch.OpeTraPlanRecoleccionDet PlanRec 
										INNER JOIN OpeSch.OpeTraPlanRecoleccion PlanRecEnc  WITH(NOLOCK)
										ON		PlanRecEnc.IdPlanRecoleccion = PlanRec.IdPlanRecoleccion
										WHERE	t1.IdRMA = PlanRec.IdRMA AND
												PlanRecEnc.ClaEstatus <> 6), 0) AS PesoRecolectar,
			CantRecoge,
			IdFacturaAlfanumerico,
			t1.NombreCliente,
			--LTRIM(RTRIM(t1.NombreCliente)) + CASE WHEN ISNULL(t1.ClaConsignado, 0) = 0 THEN '' ELSE '' END + 
			--ISNULL(LTRIM(RTRIM(t1.ClaConsignado)) + ' - ' + LTRIM(RTRIM(t1.NombreConsignado)), '') AS NombreCliente,
			IdFacturaDet,
			CantFacturada,
			PesoFacturado,
			NombreConsignado,
			NombreCiudad,
			NomArticulo
	FROM	#OpeTraReclamaciones_tmp t1 
	WHERE	NOT EXISTS(	SELECT	1 
						FROM	OpeSch.OpeTraPlanRecoleccionDet t2  WITH(NOLOCK)
								INNER JOIN OpeSch.OpeTraPlanRecoleccion t3  WITH(NOLOCK)
						ON		t3.IdPlanRecoleccion = t2.IdPlanRecoleccion
						WHERE	t1.IdRMA = t2.IdRMA AND
								t3.ClaEstatus <> 6 AND
								t2.CantRecolectar >= t1.CantRecolectar) AND
			t1.IdRMA = ISNULL(@pnIdRmaModCR, t1.IdRMA) AND
			t1.ClaCliente = ISNULL(@pnClaClienteModCR, t1.ClaCliente) AND
			t1.ClaConsignado = ISNULL(@pnClaConsignadoModCR, t1.ClaConsignado)
	ORDER BY t1.CantFacturada DESC


	SET NOCOUNT OFF
END