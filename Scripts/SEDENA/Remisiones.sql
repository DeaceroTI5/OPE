DECLARE   @pnClaUbicacionOrigen	INT	= 130
		, @pnIdViaje			INT = 5960

SELECT	a.NombreUbicacion, B.NombreTipoUbicacion 
FROM	OpeSch.OpeticatUbicacionVw a
INNER JOIN OpeSch.OpeTiCatTipoUbicacionVw b
ON		a.ClaTipoUbicacion = b.ClaTipoUbicacion
WHERE	ClaUbicacion = @pnClaUbicacionOrigen 


SELECT	IdFactura, IdFabricacion, IdViaje 
FROM	OpeSch.OpeTraMovEntSalVw 
WHERE	ClaUbicacionOrigen = @pnClaUbicacionOrigen 
AND		IdViaje = @pnIdViaje

SELECT	IdFactura, IdFabricacion, IdViaje 
FROM	OpeSch.OpeTraMovEntSalVw 
WHERE	IdFacturaAlfanumerico IN ('FB12023','FB12024','FB12025')

---------------------------------------------------

SELECT	a.claUbicacion, b.NombreUbicacion, c.NombreTipoUbicacion  
FROM	DEAOFINET05.Ventas.VtaSch.VtaTraFacturaVw a
INNER JOIN OpeSch.OpeticatUbicacionVw b
ON		a.ClaUbicacion = b.ClaUbicacion
INNER JOIN OpeSch.OpeTiCatTipoUbicacionVw c
ON		b.ClaTipoUbicacion = c.ClaTipoUbicacion
WHERE	a.IdFacturaAlfanumerico = 'EW17054'
