USE operacion
GO

SELECT @@SERVERNAME
--- DataSets plantilla Master
EXEC SP_HELPTEXT 'OpeSch.OpeRepUrlLogoSel'
EXEC SP_HELPTEXT 'OpeSch.OPE_CU74_Pag1_ImpresionMasterBillLadSel'

--- DataSets plantilla Bill of Lading
EXEC SP_HELPTEXT 'OpeSch.OPE_CU74_Pag1_ImpresionBillLadSel'

EXEC [OpeSch].[OPE_CU74_Pag1_ImpresionMasterBillLadSel]
 @pnNumVersion		= 1
 ,@pnClaUbicacion	= 197
 ,@pnIdViaje		= 32335
 ,@pnClaCliente		= 114850
 ,@pnClaConsignado	= NULL
 



-- Revisión Master Bill of Lading
-- Obtengo los pedidos por Viaje

	;WITH H AS (	
		SELECT	a.ClaUbicacion, a.IdViaje, c.IdFabricacion, d.ClaCliente
		FROM	OpeSch.OpeTraViaje a WITH(NOLOCK)
		INNER JOIN OpeSch.OpeTraMovEntSal b WITH(NOLOCK) 
		ON		a.ClaUbicacion	= b.ClaUbicacion  
		AND		a.IdViaje		= b.IdViaje  
		AND		a.IdBoleta		= b.IdBoleta  
		INNER JOIN OpeSch.OpeTraMovEntSalDet c WITH(NOLOCK) 
		ON		b.ClaUbicacion	= c.ClaUbicacion  
		AND		b.IdMovEntSal	= c.IdMovEntSal  
		INNER JOIN OpeSch.OpeTraFabricacionVw d WITH(NOLOCK)
		ON		c.ClaUbicacion	= d.ClaPlanta  
		AND		c.IdFabricacion = d.IdFabricacion  
	--	WHERE	a.ClaUbicacion = 369
		GROUP BY a.ClaUbicacion, a.IdViaje, c.IdFabricacion, d.ClaCliente
	--	ORDER BY a.IdViaje DESC
	)	
	SELECT	ClaUbicacion, IdViaje, ClaCliente, COUNT(1) AS Pedidos
	FROM	H
	GROUP BY ClaUbicacion, IdViaje, ClaCliente
	HAVING COUNT(1)>1 -- más de un pedido


	SELECT	a.ClaUbicacion, a.IdViaje, c.IdFabricacion, d.ClaCliente, b.IdFactura
	FROM	OpeSch.OpeTraViaje a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTraMovEntSal b WITH(NOLOCK) 
	ON		a.ClaUbicacion	= b.ClaUbicacion  
	AND		a.IdViaje		= b.IdViaje  
	AND		a.IdBoleta		= b.IdBoleta  
	INNER JOIN OpeSch.OpeTraMovEntSalDet c WITH(NOLOCK) 
	ON		b.ClaUbicacion	= c.ClaUbicacion  
	AND		b.IdMovEntSal	= c.IdMovEntSal 
	INNER JOIN OpeSch.OpeTraFabricacionVw d WITH(NOLOCK)
	ON		c.ClaUbicacion	= d.ClaPlanta  
	AND		c.IdFabricacion = d.IdFabricacion  
	WHERE	a.ClaUbicacion = 197
	AND		a.IdViaje = 32335
	ORDER BY IdViaje DESC, b.IdFactura ASC


		-- Logo
 	SELECT 	*
	FROM 	opesch.OPETiCatConfiguracionVw WITH(NOLOCK)
	WHERE 	ClaUbicacion 		= 197
			AND	ClaSistema 		= 127
			AND	ClaConfiguracion	= 2