																						  

--SELECT * FROM OpeSch.OpeTiCatUsuarioVw WHERE NomUsuario like '%KATIA LORENA VILCHIS VALDEZ%' AND BajaLogica = 0			-- 100022582
--SELECT * FROM OpeSch.OpeTiCatUsuarioVw WHERE NomUsuario like '%EDUARDO DE JESUS BENITEZ HERNANDEZ%' AND BajaLogica = 0	-- 100022909

BEGIN TRAN
	
	INSERT INTO OpeSch.OpeCfgUsuarioTraspaso
	SELECT	  ClaUsuario				= 100022582
			, ClaTipoUbicacion
			, ClaUbicacion
			, EsUsuarioCancelaSolicitud	= 1
			, EsUsuarioCancelaPedido	= 1
			, EsUsuarioAutorizador		= 1
			, BajaLogica				= 0
			, FechaBajaLogica			= NULL
			, FechaIns					= GETDATE()
			, ClaUsuarioMod				= 1
			, NombrePcMod				= 'CargaInicial'
			, FechaUltimaMod			= GETDATE()
	FROM	OpeSch.OpeTiCatUbicacionVw a WITH(NOLOCK) 
	WHERE	BajaLogica = 0
	AND		NOT EXISTS (
					SELECT	1
					FROM	OpeSch.OpeCfgUsuarioTraspaso b WITH(NOLOCK)
					WHERE	a.ClaUbicacion = b.ClaUbicacion
					AND		b.ClaUsuario = 100022582
				)

	INSERT INTO OpeSch.OpeCfgUsuarioTraspaso
	SELECT	  ClaUsuario				= 100022909
			, ClaTipoUbicacion
			, ClaUbicacion
			, EsUsuarioCancelaSolicitud	= 1
			, EsUsuarioCancelaPedido	= 1
			, EsUsuarioAutorizador		= 1
			, BajaLogica				= 0
			, FechaBajaLogica			= NULL
			, FechaIns					= GETDATE()
			, ClaUsuarioMod				= 1
			, NombrePcMod				= 'CargaInicial'
			, FechaUltimaMod			= GETDATE()
	FROM	OpeSch.OpeTiCatUbicacionVw a WITH(NOLOCK) 
	WHERE	BajaLogica = 0
	AND		NOT EXISTS (
					SELECT	1
					FROM	OpeSch.OpeCfgUsuarioTraspaso b WITH(NOLOCK)
					WHERE	a.ClaUbicacion = b.ClaUbicacion
					AND		b.ClaUsuario = 100022909
				)

COMMIT TRAN

SELECT	*
FROM	OpeSch.OpeCfgUsuarioTraspaso 
WHERE	ClaUsuario IN (100022582, 100022909) 
AND		(ClaTipoUbicacion		= -1 -- Todos 
OR		ClaUbicacion		= -1) -- Todos