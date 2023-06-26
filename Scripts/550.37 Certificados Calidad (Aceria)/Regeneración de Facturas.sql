USE Operacion
GO
	-- Parámetros
	DECLARE @pnClaUbicacion INT = 267
	----------------------------------------------------------------------
	SET NOCOUNT ON
	
	CREATE TABLE #Facturas(
		  Id		INT IDENTITY(1,1)
		, IdFactura	INT
	)

	--- Inserto las Facturas que se van a regenerar
	INSERT #Facturas (IdFactura)
	VALUES
	 (1058000037)
	,(1058000038)
	
	------------------------------------------------------------------
	DECLARE @psFacturaFiltro VARCHAR(8000)

	SELECT @psFacturaFiltro = 
	STUFF(
		  (
      		SELECT ', ' + RTRIM(LTRIM(CONVERT(VARCHAR(20),IdFactura))) 
			FROM	#Facturas 
			GROUP BY IdFactura
			FOR XML PATH ('')
		  )
	, 1, 1, '')

	SELECT @psFacturaFiltro AS '@psFacturaFiltro'

	EXEC OpeSch.OpeBackDigitalizacionDocumentos
			  @pnClaUbicacion		= @pnClaUbicacion
			, @pnFechaIni			= NULL				-- Fecha puede ser nulo o en su caso requiere parámetro Fecha Fin
			, @pnFechaFin			= NULL				-- Fecha puede ser nulo o en su caso requiere parámetro Fecha Ini
			, @pnEsRegeneracion		= 1					-- 0 (default)- Proceso Original; 1 - Regeneración de Facturas ya existentes
			, @psFacturaFiltro		= @psFacturaFiltro	-- Se agregan desde la tabla temporal #Facturas; En caso de enviar '' procesara todos* los Registros de Reporte Facturas (ClaFormatoImpresion = 27)
			, @pnDebug				= 2					-- 0 - Actualiza tabla reporte Factura; 1- Modo Debug (Pruebas)
														-- 2 - Devuelve consulta (IdFactura, IdCertificado, Reporte)


	DROP TABLE #Facturas
	SET NOCOUNT OFF