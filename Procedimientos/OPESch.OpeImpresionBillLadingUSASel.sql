ALTER PROCEDURE [OPESch].[OpeImpresionBillLadingUSASel](@pnNumVersion	INT, @pnClaUbicacion int,@pnIdViaje INT, @pnClaPais INT, @pnIdFactura INT =NULL)
AS
BEGIN

	--FP #3818: determinar si se usa logo StayTuff
		DECLARE @tClientes TABLE (
		ClaCliente INT,
		ClaEmpresa INT
	)

	DECLARE @sTexto1 VARCHAR(400),
			@sTexto3 VARCHAR(400),
			@nMostrarDatosImport INT			

--PRINT 1

	INSERT	INTO @tClientes
	SELECT	DISTINCT Cli.ClaCliente, Cli.ClaEmpresa
	FROM	OpeSch.OpeTraViaje viaje WITH (NOLOCK)
	INNER	JOIN OpeSch.OpeTraMovEntSal  entSal WITH (NOLOCK) ON
			viaje.ClaUbicacion = entSal.ClaUbicacion AND
			viaje.IdViaje = entSal.IdViaje 
			--AND ISNULL(entSal.IdFactura, -1) > 0
	INNER	JOIN OpeSch.TiCatUbicacionVw ubi WITH (NOLOCK) ON 
			viaje.ClaUbicacion = ubi.ClaUbicacion
	INNER	JOIN OpeSch.OpeTraFabricacionVw fab WITH (NOLOCK) ON
			entSal.IdFabricacion = fab.IdFabricacion AND
			entSal.ClaUbicacion = fab.ClaPlanta
	LEFT	JOIN OpeSch.VtaCatClienteVw Cli
			ON Cli.ClaCliente = fab.ClaCliente
	WHERE	viaje.IdViaje = @pnIdViaje
			AND viaje.ClaUbicacion = @pnClaUbicacion 
			AND ((ISNULL(entSal.IdFactura,0)<>0 AND entSal.IdFactura= @pnIdFactura) OR (ISNULL(entSal.IdEntSal,0)<>0 AND entSal.IdEntSal=@pnIdFactura))

	DECLARE @nEmpresaStayTuff INT

--PRINT 10

	
	SELECT	@nEmpresaStayTuff = ISNULL(nValor1, -1)
	FROM	OpeSch.TiCatConfiguracionVw
	WHERE	ClaSistema = 127
			AND ClaUbicacion = @pnClaUbicacion
			AND ClaConfiguracion = 45
	
	DECLARE @nEsStayTuff INT
	SET @nEsStayTuff = 0 --Por default la dejamos en cero
	
	IF EXISTS (SELECT ClaCliente FROM @tClientes WHERE ClaEmpresa = @nEmpresaStayTuff)
	BEGIN
		SET @nEsStayTuff = 1 --Si al menos un cliente se le factura como StayTuff, entonces usar logo
	END
	--Termina FP #3818
	
	DECLARE @sPrepaidBy VARCHAR(400)


--PRINT 20

	SELECT @sTexto1 = sValor1
	FROM OpeSch.TiCatConfiguracionVw 
	WHERE	ClaSistema = 127
	AND ClaUbicacion = @pnClaUbicacion
	AND ClaConfiguracion = 56
	
	SELECT @sPrepaidBy = CASE WHEN @nEsStayTuff = 0 THEN sValor1 ELSE sValor2 END
	FROM OpeSch.TiCatConfiguracionVw 
	WHERE	ClaSistema = 127
	AND ClaUbicacion = @pnClaUbicacion
	AND ClaConfiguracion = 57

	SELECT  @sTexto3 = sValor1
	FROM OpeSch.TiCatConfiguracionVw 
	WHERE	ClaSistema = 127
	AND ClaUbicacion = @pnClaUbicacion
	AND ClaConfiguracion = 58

	SELECT  @nMostrarDatosImport = nValor1
	FROM OpeSch.TiCatConfiguracionVw 
	WHERE	ClaSistema = 127
	AND ClaUbicacion = @pnClaUbicacion
	AND ClaConfiguracion = 59

--PRINT 30	
	SELECT	ubi.NomUbicacion, entSal.IdFacturaAlfanumerico as IdFactura, 
			'*' + CASE WHEN  CONVERT(NUMERIC(18,0), '1' + CONVERT(VARCHAR(100), entSal.IdFactura)) % 2 > 0 
				THEN '10' + CONVERT(VARCHAR(100), entSal.IdFactura) 
				ELSE '1' + CONVERT(VARCHAR(100), entSal.IdFactura) END + '*' AS CodigoBarras,--entsal.FechaEntSal,
			convert(varchar,entsal.FechaEntSal,101) + ' ' +
			substring(convert(varchar(14),  entsal.FechaEntSal, 100), len(convert(varchar(14),  entsal.FechaEntSal, 100)) -1 , 2) + ':' + 
			substring(convert(varchar(17), entsal.FechaEntSal,100), len(convert(varchar(17), entsal.FechaEntSal,100))-1,2) +  ':' + 
			substring(convert(varchar(8), entsal.FechaEntSal,108), len(convert(varchar(8), entsal.FechaEntSal,108))-1,2) + ' ' + 
			substring(convert(varchar(50),entsal.FechaEntSal,100) ,len(convert(varchar(50),entsal.FechaEntSal,100)) - 1, 8) AS FechaEntSal,
			transp.Nombre AS NombreTransportista, viaje.Placa, viaje.PlacaCaja,
			CASE WHEN ISNULL(fab.ClaConsignado,0) > 0 
				THEN	CASE WHEN LEN(RTRIM(LTRIM(RTRIM(LTRIM(ISNULL(consig.NombreConsignado,''))) + ' ' + RTRIM(LTRIM(ISNULL(consig.Direccion, ''))) + ' ' + RTRIM(LTRIM(ISNULL(consig.Colonia, ''))) + ' ' + RTRIM(LTRIM(ISNULL(cddConsig.NombreCiudad, ''))) + ', ' + RTRIM
(LTRIM(ISNULL(edoConsig.NombreEstado, '')))))) = 1
							THEN NULL ELSE RTRIM(LTRIM(RTRIM(LTRIM(ISNULL(consig.NombreConsignado,''))) + ' ' + RTRIM(LTRIM(ISNULL(consig.Direccion, ''))) + ' ' + RTRIM(LTRIM(ISNULL(consig.Colonia, ''))) + ' ' + RTRIM(LTRIM(ISNULL(cddConsig.NombreCiudad, ''))) + ', ' + RTRIM(
LTRIM(ISNULL(edoConsig.NombreEstado, ''))))) END
				ELSE	CASE WHEN LEN(RTRIM(LTRIM(RTRIM(LTRIM(ISNULL(cte.NombreCliente,''))) + ' ' + RTRIM(LTRIM(ISNULL(cte.Direccion, ''))) + ' ' + RTRIM(LTRIM(ISNULL(cte.Colonia, ''))) + ' ' + RTRIM(LTRIM(ISNULL(cddCte.NombreCiudad, ''))) + ', ' + RTRIM(LTRIM(ISNULL(edoCte.NombreEstado, '')))))) = 1
							THEN NULL
							ELSE RTRIM(LTRIM(RTRIM(LTRIM(ISNULL(cte.NombreCliente,''))) + ' ' + RTRIM(LTRIM(ISNULL(cte.Direccion, ''))) + ' ' + RTRIM(LTRIM(ISNULL(cte.Colonia, ''))) + ' ' + RTRIM(LTRIM(ISNULL(cddCte.NombreCiudad, ''))) + ', ' + RTRIM(LTRIM(ISNULL(edoCte.NombreEstado, ''))))) END
				END AS NomConsignadoCte,
			CASE WHEN ISNULL(fab.ClaConsignado,0) > 0
				THEN consig.ZonaPostal
				ELSE cte.ZonaPostal
				END AS ZonaPostal,
			CASE WHEN ISNULL(fab.ClaConsignado,0) > 0
				THEN consig.Telefono
				ELSE cte.Telefono
				END AS Telefono,
			trab.NombreUsuario AS NombreTrabajador,
			agente.NomAgenteAduanal,
			fab.ClaPedidoCliente,
			fab.IdFabricacion,
			entSal.Comentarios,
			LTRIM(RTRIM(ISNULL(usuario.NombreUsuario, ''))) + ' ' + 
									LTRIM(RTRIM(ISNULL(usuario.ApellidoPaterno, ''))) + ' ' + 
									LTRIM(RTRIM(ISNULL(usuario.ApellidoMaterno, ''))) AS NomJefeEmbarques,
			viaje.NomChofer,
			viaje.IdViaje,
			viaje.IdPlanCarga,
			entSal.IdMovEntSal,
			CASE WHEN viaje.ClaTipoViaje = 5 THEN 'COLLECT'
				ELSE @sPrepaidBy END AS Leyenda1,
			@nEsStayTuff AS EsStayTuff, --Se regresa para usarlo en el reporte
			@sTexto1 AS Texto1,
			@sTexto3 AS Texto3,
			ISNULL(@nMostrarDatosImport,0) as MostrarDatosImport
	FROM 
/*
 select top 1 * from PloSch.TiCatUsuarioVw
 select top 1 * from OpeSch.TiCatUsuarioVw
*/	
		OpeSch.OpeTraViaje viaje WITH (NOLOCK)
		INNER JOIN OpeSch.OpeTraMovEntSal entSal WITH (NOLOCK) ON
			viaje.ClaUbicacion = entSal.ClaUbicacion AND
			viaje.IdViaje = entSal.IdViaje /*AND
			ISNULL(entSal.IdFactura, -1) > 0*/
		INNER JOIN OpeSch.TiCatUbicacionVw ubi WITH (NOLOCK) ON
			viaje.ClaUbicacion = ubi.ClaUbicacion
		INNER JOIN OpeSch.OpeTraFabricacionVw fab WITH (NOLOCK) ON
			entSal.IdFabricacion = fab.IdFabricacion AND
			entSal.ClaUbicacion = fab.ClaPlanta --AND
			--fab.ClaCiudad IN (SELECT ClaCiudad FROM PloSch.VtaCatCiudadVw WITH (NOLOCK) WHERE ClaPais = @pnClaPais)
		LEFT JOIN OpeSch.OpeTraPlanCarga planCarga WITH (NOLOCK) ON
			viaje.IdPlanCarga = planCarga.IdPlanCarga AND
			viaje.ClaUbicacion = planCarga.ClaUbicacion
		LEFT JOIN OpeSch.OpeTraPlanCargaExportaVw planCargaExp WITH (NOLOCK) ON
			viaje.IdPlanCarga = planCargaExp.IdPlanCarga AND
			viaje.ClaUbicacion = planCargaExp.ClaUbicacion
		LEFT JOIN OpeSch.FleCatTransportistaVw transp WITH (NOLOCK) ON
			viaje.ClaUbicacion = transp.ClaUbicacion AND
			viaje.ClaTransportista = transp.ClaTransportista
		LEFT JOIN OpeSch.OPeVtaCatConsignadoVw consig WITH (NOLOCK) ON
			fab.ClaConsignado = consig.ClaConsignado
		LEFT JOIN OpeSch.VtaCatClienteVw cte WITH (NOLOCK) ON
			fab.ClaCliente = cte.ClaCliente
		LEFT JOIN OpeSch.OpeVtaCatCiudadVw cddConsig WITH (NOLOCK) ON
			consig.ClaCiudad  = cddConsig.ClaCiudad
		LEFT JOIN OpeSch.OpeVtaCatEstadoVw edoConsig WITH (NOLOCK) ON
			cddConsig.ClaPais = edoConsig.ClaPais AND
			cddConsig.ClaEstado = edoConsig.ClaEstado
		LEFT JOIN OpeSch.OpeVtaCatCiudadVw cddCte WITH (NOLOCK) ON
			cte.ClaCiudad  = cddCte.ClaCiudad
		LEFT JOIN OpeSch.OpeVtaCatEstadoVw edoCte WITH (NOLOCK) ON
			cddCte.ClaPais = edoCte.ClaPais AND
			cddCte.ClaEstado = edoCte.ClaEstado
--		LEFT JOIN PloSch.NomCatTrabajadorVw trab WITH (NOLOCK) ON
--			planCarga.ClaOperador = trab.ClaTrabajador
		LEFT JOIN OpeSch.TiCatUsuarioVw trab WITH (NOLOCK) ON
			planCarga.ClaOperador = trab.IdUsuario
		LEFT JOIN PloSch.CexCatAgenteAduanalVw agente WITH (NOLOCK) ON
			planCargaExp.ClaAgenteAduanal = agente.ClaAgenteAduanal
		LEFT JOIN OpeSch.TiCatUsuarioVw usuario WITH (NOLOCK) ON 
			usuario.IdUsuario = viaje.ClaJefeEmbarque
	WHERE	viaje.ClaUbicacion = @pnClaUbicacion AND
			viaje.IdViaje = @pnIdViaje AND 
			((ISNULL(entSal.IdFactura,0)<>0 AND entSal.IdFactura= @pnIdFactura) OR (ISNULL(entSal.IdEntSal,0)<>0 AND entSal.IdEntSal=@pnIdFactura))
	GROUP BY ubi.NomUbicacion, entSal.IdFactura, entSal.IdFacturaAlfanumerico, entsal.FechaEntSal, transp.Nombre, viaje.Placa, viaje.PlacaCaja, fab.ClaConsignado, 
			 consig.NombreConsignado, consig.Direccion, consig.Colonia, cddConsig.NombreCiudad, edoConsig.NombreEstado, cte.NombreCliente,
			 cte.Direccion, cte.Colonia, cddCte.NombreCiudad, edoCte.NombreEstado, consig.ZonaPostal, cte.ZonaPostal, consig.Telefono, 
			 cte.Telefono, trab.NombreUsuario, agente.NomAgenteAduanal, fab.ClaPedidoCliente, fab.IdFabricacion, entSal.Comentarios, 
			 usuario.NombreUsuario, usuario.ApellidoPaterno, usuario.ApellidoMaterno, viaje.NomChofer, viaje.IdViaje, viaje.IdPlanCarga, entSal.IdMovEntSal, viaje.ClaTipoViaje
	ORDER BY entSal.IdFacturaAlfanumerico

--PRINT 40

END