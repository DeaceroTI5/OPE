USE Operacion
GO
--exec OPESch.OPE_CU445_Pag4_Sel @pnClaUbicacion=326
--exec OPESch.OPE_CU445_Pag4_Grid_ArticuloComposicion_Sel @pnClaUbicacion=326,@pnClaArticulo=1628
--exec OPESch.OPE_CU445_Pag4_Grid_ProductosResiduo_Sel @pnClaUbicacion=326,@pnIdArticuloComposicionAux=37,@pnClaArticulo=1628
--exec OPESch.OPE_CU445_Pag4_Grid_ProductosEquivalentes_Sel @pnClaUbicacion=326,@pnClaArticulo=1628
---- '[OpeSch].[OPE_CU445_Pag18_EnviarTramiteCxP_Proc]'
-- OPESch.OPE_CU445_Pag16_Boton_BuscarBoletaODS_Proc -- Recepción de Producto Maquilado

DECLARE  @pnClaUbicacion	INT = 326
		,@pnIdBoleta		INT = 230540014 

SELECT	a.IdRecepOrdenMaquila, b.IdContrato , b.IdOrdenMaquila, b.IdOrdenSalidaMaquila,c.ClaMaquilador, c.ClaArticulo, e.ClaveArticulo
		,ROUND(b.CantRecibida, 2) CantRecibida
		,ROUND(b.PesoRecibido, 2) PesoRecibido
		, c.FactorConversion
		,ROUND(b.CantRecibida * isnull(c.FactorConversion,1), 2)  AS CantidadPagar
		,c.PrecioNegociado AS Precio
		,ROUND(ROUND(b.CantRecibida * isnull(c.FactorConversion,1), 2) * c.PrecioNegociado, 2) AS TotalSinIVA
		,ROUND(ROUND(ROUND(b.CantRecibida * isnull(c.FactorConversion,1), 2) * c.PrecioNegociado, 2) * (d.PorcIVA / 100), 2) AS IVA
		,ROUND(ROUND(ROUND(b.CantRecibida * isnull(c.FactorConversion,1), 2) * c.PrecioNegociado, 2) * (1 + (d.PorcIVA / 100)), 2) AS TotalConIVA
FROM	OPesch.OPETraRecepOrdenMaquila a WITH(NOLOCK)
INNER  JOIN Opesch.OpeTraRecepOrdenMaquilaDet b WITH(NOLOCK)	
ON		a.ClaUbicacion			= b.ClaUbicacion 
AND		a.IdRecepOrdenMaquila	= b.IdRecepOrdenMaquila 
INNER  JOIN Opesch.OpeTraContratoMaquila c WITH(NOLOCK)	
ON		b.ClaUbicacion			= c.ClaUbicacion
AND		b.IdContrato			= c.IdContrato
INNER	JOIN Opesch.OpeCatMaquilador d WITH(NOLOCK)	
ON		c.ClaUbicacion			= d.ClaUbicacion
AND		c.ClaMaquilador			= d.ClaMaquilador  
LEFT JOIN OpeSch.OpeArtCatArticuloVw e
ON		b.ClaArticulo			= e.ClaArticulo
WHERE	a.ClaUbicacion			= @pnClaUbicacion
AND		a.IdBoleta				= @pnIdBoleta
AND		a.ClaEstatus			IN (2,3)


SELECT * FROM OpeSch.OpeTraArticuloComposicionDet WHERE ClaArticuloComp = 534417


--SP_BUSCATETXO '%INSERT%OpeTraRecepOrdenMaquilaDet%'



--SELECT * FROM dbo.TiCatClasificacionEstatusVw where NombreClasificacionEstatus like '%recepc%'
--SELECT * FROM OpeSch.OpeTiCatestatusVw where ClaClasificacionEstatus = 1270023

/*	Estatus Recepción
					,CASE WHEN isnull(t4.ClaEstatus,-1)  = -1	THEN  'Nuevo' 
						  WHEN isnull(t4.ClaEstatus,-1)  = 1	THEN  'PorRecibir'
						  WHEN isnull(t4.ClaEstatus,-1)  = 2	THEN  'Recibido'
						  WHEN isnull(t4.ClaEstatus,-1)  = 3	THEN  'Cerrado'
						  WHEN isnull(t4.ClaEstatus,-1)  = 4	THEN  'Cancelado'
						  ELSE 	  convert (varchar,t4.ClaEstatus)
					END	  AS NomEstatus
*/


exec OPESch.OPE_CU445_Pag16_Boton_BuscarBoletaODS_Proc @pnClaUbicacion=326,@pnIdBoletaODS=230540014
exec OPESch.OPE_CU445_Pag16_Grid_ConsultaODM_Sel @pnClaUbicacion=326,@pnClaMaquilador=5,@pnIdRecepOrdenMaquila=356,@pnIdBoletaODS=230540014,@psIdioma='Spanish',@pnClaIdioma=default,@pnClaArticulo=NULL
exec OPESch.OPE_CU445_Pag16_Grid_ConsultaODMDet_Sel @pnClaUbicacion=326,@pnIdRecepOrdenMaquila=356,@pnIdOrdenMaquila=60,@pnIdBoletaODS=230540014,@psIdioma='Spanish',@pnClaIdioma=default

'OPESch.OPE_CU445_Pag16_Grid_ConsultaODMDet_Sel'