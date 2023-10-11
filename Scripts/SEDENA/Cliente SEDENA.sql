SELECT	DISTINCT ClaClienteUnico, NoMClienteCuenta
FROM	OpeSch.OpeVtaCatClienteCuentaVw 
WHERE	NomClienteCuenta LIKE '%LAMINA Y PLACA COMERCIAL%'


SELECT	DISTINCT ClaClienteUnico, NoMClienteCuenta
FROM	OpeSch.OpeVtaCatClienteCuentaVw 
WHERE	ClaClienteUnico = 14064