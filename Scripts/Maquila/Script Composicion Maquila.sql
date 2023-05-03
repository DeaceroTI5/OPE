	SELECT	d.ClaveArticulo, a.PorcComposicion, a.Cantidad, c.* 
	FROM	OpeSch.OpeTraArticuloComposicionDet a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraArticuloComposicion c WITH(NOLOCK)
	ON		a.ClaUbicacion			= c.ClaUbicacion
	AND		a.IdArticuloComposicion = c.IdArticuloComposicion
	AND		c.BajaLogica			= 0
	INNER JOIN Opesch.OpeArtCatArticuloVw b
	ON		a.ClaArticuloComp		= b.ClaArticulo
	INNER JOIN Opesch.OpeArtCatArticuloVw d
	ON		c.ClaArticulo			= d.ClaArticulo
	WHERE	a.ClaUbicacion			= 326
	AND		b.ClaveArticulo			in ('3728','2525','2530') 


	-- DETALLE DE DEDUCCION
	select * from OpeSch.OpeTraArticuloComposicion where claubicacion = 326 and claarticulo in (1628, 1633, 3848,250590)
	select * from OpeSch.OpeTraArticuloComposicionDet  where claubicacion = 326 and idarticulocomposicion IN (30, 37, 41, 45)




	select * from Opesch.OpeArtCatArticuloVw where ClaveArticulo in ('14901') 
	select * from Opesch.OpeArtCatArticuloVw where claarticulo in (1628, 1633, 3848)
	
	14901-'BEND WIRE MAT VAR VAR D5 D11 1.84m 3.20m'
	-- revisar contratos de maquilas para los articulos que da recepcion
	-- odm 
	--de donde sale esa cantidad a pagar?
	--enviar mensaje 
	--orden de maquila esta asociado a producto, 
	--este producto esta asociado con este contrato vigen
	--contrato, ordn y recepcion
	--¿revisar si contrato en cero?

	--por que regresa ese mensaje, mandando datos informativos del servicio que esta ocupando para detrmianr lo que sucede.
	


	--OPESch.OpeTraOrdenMaquilaDet