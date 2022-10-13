 
	UPDATE	a
	SET		  NomConfiguracion	= 'Logo INGETEK USA'
			, sValor1			= NULL
			, sValor2			= '\\SRVDBDES01\WebSites\OPEITKUSA\Common\Images\WebToolImages\LOGO INGETEK USA.png'
			, FechaUltimaMod	= GETDATE()
			, NombrePcMod		= 'CargaInicial'
			, ClaUsuarioMod		= 100010318
	FROM 	opesch.OPETiCatConfiguracionVw a WITH(NOLOCK)
	WHERE 	ClaUbicacion 		IN (35, 369)
	AND		ClaSistema 			= 127
	AND		ClaConfiguracion	= 2

	EncabezadoRpt
	OpeSch.OpeRepUrlLogoSel

	EXEC SP_HELPTEXT 'OPESch.OpeImpresionRemisionSel'  -- no hay remisiones en LDO