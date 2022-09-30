BEGIN TRAN
	INSERT INTO OpeSch.OPETiCatConfiguracionVw
	SELECT	  ClaUbicacion
			, ClaSistema
			, ClaConfiguracion	= 1271224
			, NomConfiguracion	= 'Cuentas de correo para notificación de pedidos suministro directo'
			, sValor1			= REPLACE(sValor1,'dcabrerah','hvalle')
			, sValor2			= 'ejblanco@deacero.com; klvilchis@ingetek.com.mx; ejbenitez@ingetek.com.mx; lperaza@deacero.com; josmor@deacero.com; alobato@deacero.com'
			, nValor1			= NULL
			, nValor2			= NULL
			, dValor1
			, dValor2
			, BajaLogica		= 0
			, FechaBajaLogica	= NULL
			, FechaUltimaMod	= GETDATE()
			, NombrePcMod		= 'Carga Inicial'
			, ClaUsuarioMod		= 1
	FROM	OpeSch.OPETiCatConfiguracionVw b
	WHERE	ClaSistema = 127 
	AND		ClaConfiguracion = 1271221--1271224
	ORDER BY ClaUbicacion
COMMIT TRAN
BEGIN TRAN
	UPDATE  b
	SET		SValor2 = 'ejblanco@deacero.com; lperaza@deacero.com; josmor@deacero.com; alobato@deacero.com'
	FROM	OpeSch.OPETiCatConfiguracionVw b
	WHERE	ClaSistema = 127 
	AND		ClaConfiguracion = 1271224
	AND		sValor2 LIKE '%ejbenitez@ingetek.com.mx;%'
COMMIT TRAN
