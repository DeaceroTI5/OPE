		SELECT	t1.IdBoleta,
				t1.Placa,
				t1.ClaMotivoEntrada, 
			--	t1.ClaSubMotivoEntrada, 
				t1.ClaTransporte, 
			--	t1.ClaEjeTransporte, 
			--	t1.claTransportista AS ClaTransportista, 
			--	t1.ClaChofer, 
				t1.NomChofer, 
				--ISNULL(@nPesoEntrada, 0) AS PesoEntrada, 
				t1.FechaHoraEntrada AS FechaEntrada, 
				t1.ClaTipoPesaje AS ClaTipoPesajeEnt, 
				4 AS ClaTipoPesajeSal, -- Camion con Movimiento
				t1.Comentarios AS Observaciones, 
				--ISNULL(@nPesoDocumentado,0) PesoDocumentado, 
				--t1.ClaEstatusPlaca, 
				t1.EsEntradaManual AS PesajeManualEnt,	
				--ISNULL(@nPesoTara, 0) PesoTara, 
				t3.NomEstatusBoleta AS EstatusPlaca, 
				--ISNULL(@nPesoDocParcial, 0) AS PesoDocParcial, 
				--ISNULL(@nEsPesajeParcial, 0) AS EsPesajeParcial, 
				--ISNULL(@nPesoNoDocumentado, 0) AS PesoNoDocumentado, 
				t1.NomTransportista, 
				t1.Referencia,
				t4.ClaTipoInventario,
				t4.ClaAlmacen			 
		FROM	OpeSch.OpeTraBoletaVw t1
	   	LEFT JOIN OpeSch.OPECatEstatusBoletaVw t3 ON   
		t3.BajaLogica = 0 AND
		t3.ClaEstatusBoleta = t1.ClaEstatusPlaca
		INNER JOIN OPESch.OpeCatMotivoEntrada t4 ON t4.ClaMotivoEntrada = t1.ClaMotivoEntrada 
		WHERE	t1.ClaUbicacion = 325
		AND		t1.ClaEstatusPlaca = 3