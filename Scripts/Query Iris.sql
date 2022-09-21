USE Operacion
GO

SELECT	  [Clave Producto]		= a.ClaveArticulo
		, Producto				= a.NomArticulo 
		, [Clave Familia]		= b.ClaveFamilia
		, Familia				= b.NomFamilia
		, [Clave SubFamilia]	= c.ClaveSubfamilia
		, [SubFamilia]			= c.NomSubfamilia
		, [Unidad Venta]		= d.NomUnidad
		, [Unidad Producción]	= e.NomUnidad
		, [Peso Teorico Kgs]	= CAST(a.PesoTeoricoKgs AS NUMERIC(22,4))
FROM	OpeSch.OpeArtCatArticuloVw a
INNER JOIN OpeSch.OpeArtCatFamiliaVw b 
ON		a.ClaFamilia	= b.ClaFamilia
INNER JOIN OpeSch.OpeArtCatSubfamiliaVw c
ON		a.ClaFamilia	= c.ClaFamilia
AND		a.ClaSubfamilia	= c.ClaSubfamilia
LEFT JOIN OpeSch.OpeArtCatUnidadVw d
ON		d.ClaTipoInventario	= 1
AND		a.ClaUnidadBase		= d.ClaUnidad
LEFT JOIN OpeSch.OpeArtCatUnidadVw e
ON		e.ClaTipoInventario	= 1
AND		a.ClaUnidadProd		= e.ClaUnidad
WHERE	a.NomArticulo LIKE '%Varilla%C1%' -- '%Varilla%C5%'
AND		a.BajaLogica = 0
ORDER BY ClaveArticulo ASC



SELECT    [Pedido]			= a.IdFabricacion
--		, [Pedido Cliente]	= NULL
		, [Orden Compra]	= a.ClaPedidoCliente
		, Cliente			= CONVERT(VARCHAR(10),b.ClaCliente) +' - '+ B.NomCliente
		, Consignado		= CONVERT(VARCHAR(10),c.ClaConsignado) + '- ' + c.NombreConsignado
		, [Fecha Pedido]	= a.FechaPedidoCliente
		, [Clave Producto]	= e.ClaveArticulo
		, [Producto]		= e.NomArticulo
		, [Cant. Solicitada]= d.CantidadPedida
		, [Cant. Surtida]	= d.CantidadSurtida
--		, [Numero Factura]	= d.NumeroRenglon
		, [Planta Surte]	= CONVERT(VARCHAR(10),a.ClaUbicacion) +' - '+ f.NombreUbicacion
--		, [Estatus pedido]	= a.ClaEstatusFabricacion
		, [Estatus pedido]	= g.Descripcion
--		, [Estatus partida]	= d.ClaEstatusFabricacion
		, [Estatus partida]	= h.Descripcion
FROM    deaofinet05.ventas.vtasch.vtatrafabricacion a WITH(NOLOCK)
INNER JOIN OpeSch.OpeVtaCatClienteVw b
ON		a.ClaCliente	= b.ClaCliente
INNER JOIN OpeSch.OpeTiCatUbicacionVw f
ON		a.ClaUbicacion	= f.ClaUbicacion
LEFT JOIN OpeSch.OpeVtaCatConsignadoVw c
ON		a.ClaConsignado	= c.ClaConsignado
LEFT JOIN deaofinet05.ventas.vtasch.vtatrafabricacionDet d
ON		a.IdFabricacion	= d.IdFabricacion
LEFT JOIN OpeSch.OpeArtCatArticuloVw e
ON		d.ClaArticulo	= e.ClaArticulo
LEFT JOIN deaofinet05.ventas.vtasch.vtacatestatusfabricacionVw g
ON		a.ClaEstatusFabricacion = g.ClaEstatus
LEFT JOIN deaofinet05.ventas.vtasch.vtacatestatusfabricacionVw h
ON		d.ClaEstatusFabricacion = h.ClaEstatus
WHERE   a.ClaCliente IN (818613,818138)
AND		a.FechaPedidoCliente BETWEEN '20210901' AND '20220831'
ORDER BY b.ClaCliente, a.IdFabricacion  ASC




--'%ope%estatus%'
----OpeSch.OpeTraEstatusFabricacion
--SELECT * FROM dbo.TiCatClasificacionEstatusVw WHERE ClaClasificacionEstatus = 1270004
----OpeSch.OpeTraEstatusFabricacion
--SELECT * FROM OpeSch.OpeTiCatestatusVw WHERE ClaClasificacionEstatus = 1270004
