USE Operacion
GO
--- 'OpeSch.OPE_CU550_Pag30_Grid_GridPlanCargaEnc_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag30_Grid_GridPlanCargaEnc_Sel
	@pnClaUbicacion         INT,
    @pnIdViajeMod3          INT,
    @pnIdPlanCargaMod3      INT
AS
BEGIN
	SELECT 
            t3.IdFabricacion AS ColFabricacion,
            t4.IdBoleta AS ColBoleta,
            t4.NomTransportista AS ColTransportista,
            t6.NomTransporte AS ColTransporte,
            t1.Placa AS ColPlaca,
            t4.NomChofer AS ColChofer,
            SUM(t3.PesoEmbarcado) AS ColPesoEmbarcado,
            t1.IdViaje AS ColViaje,
            t2.IdPlanCarga AS ColPlanCarga
    FROM
            OpeSch.OpeTraViaje t1 WITH(NOLOCK)
        INNER JOIN  OpeSch.OpeTraPlanCarga t2 WITH(NOLOCK)
                    ON t2.ClaUbicacion = t1.ClaUbicacion AND t2.IdPlanCarga = t1.IdPlanCarga
        INNER JOIN  OpeSch.OpeTraPlanCargaDet t3 WITH(NOLOCK)
                    ON t3.ClaUbicacion = t1.ClaUbicacion AND t3.IdPlanCarga = t2.IdPlanCarga
        INNER JOIN  OpeSch.OpeTraBoleta t4 WITH(NOLOCK)
                    ON t4.ClaUbicacion = t1.ClaUbicacion AND t4.IdBoleta = t1.IdBoleta
        LEFT JOIN   FleSch.FLECatTransportistaVw t5 WITH(NOLOCK)
                    ON t5.ClaUbicacion = t1.ClaUbicacion AND t5.ClaTransportista = t1.ClaTransportista
        LEFT JOIN   FleSch.FLECatTransporteVw t6 WITH(NOLOCK)
                    ON t6.ClaTransporte = t2.ClaTransporte
		LEFT JOIN	OpeSch.OpeTiCatEstatusPlanCargaVw t7
		ON			t2.ClaEstatusPlanCarga = t7.ClaEstatus
    WHERE   t1.IdViaje = @pnIdViajeMod3
    AND     t2.IdPlanCarga = @pnIdPlanCargaMod3
	AND		t1.ClaUbicacion = @pnClaUbicacion
	AND		t2.ClaEstatusPlanCarga = 2
	GROUP BY
			t1.IdViaje, t2.IdPlanCarga, t3.IdFabricacion, t4.IdBoleta, t4.NomTransportista, t6.NomTransporte, t1.Placa, t4.NomChofer

UNION
	-- AGREGAMOS ESCENARIO DE CAMIONES EN PLANTA NO FACTURADOS
	SELECT 
            t3.IdFabricacion AS ColFabricacion,
            t4.IdBoleta AS ColBoleta,
            t4.NomTransportista AS ColTransportista,
            t6.NomTransporte AS ColTransporte,
            t2.Placa AS ColPlaca,
            t4.NomChofer AS ColChofer,
            SUM(t3.PesoEmbarcado) AS ColPesoEmbarcado,
            NULL AS ColViaje,
            t2.IdPlanCarga AS ColPlanCarga
    FROM
            OpeSch.OpeTraPlanCarga t2 WITH(NOLOCK)
        INNER JOIN  OpeSch.OpeTraPlanCargaDet t3 WITH(NOLOCK)
                    ON t3.ClaUbicacion = t2.ClaUbicacion AND t3.IdPlanCarga = t2.IdPlanCarga
        INNER JOIN  OpeSch.OpeTraBoleta t4 WITH(NOLOCK)
                    ON t4.ClaUbicacion = t2.ClaUbicacion AND t4.IdBoleta = t2.IdBoleta
        LEFT JOIN   FleSch.FLECatTransportistaVw t5 WITH(NOLOCK)
                    ON t5.ClaUbicacion = t2.ClaUbicacion AND t5.ClaTransportista = t2.ClaTransportista
        LEFT JOIN   FleSch.FLECatTransporteVw t6 WITH(NOLOCK)
                    ON t6.ClaTransporte = t2.ClaTransporte
		LEFT JOIN	OpeSch.OpeTiCatEstatusPlanCargaVw t7
		ON			t2.ClaEstatusPlanCarga = t7.ClaEstatus
    WHERE   t2.IdPlanCarga = @pnIdPlanCargaMod3
	AND		t2.ClaUbicacion = @pnClaUbicacion
	AND		t2.ClaEstatusPlanCarga = 1
	GROUP BY
			t2.IdPlanCarga, t3.IdFabricacion, t4.IdBoleta, t4.NomTransportista, t6.NomTransporte, t2.Placa, t4.NomChofer


END