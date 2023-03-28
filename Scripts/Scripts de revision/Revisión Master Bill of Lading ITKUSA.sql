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
 ,@pnClaUbicacion	= 369
 ,@pnIdViaje		= 737
 ,@pnClaCliente		= 827488
 ,@pnClaConsignado	= NULL

-------------------------------------------------------------------------

-- Revisión Master Bill of Lading
-- Obtengo los pedidos por Viaje

	;WITH H AS (	
		SELECT	DISTINCT a.ClaUbicacion, a.IdViaje, c.IdFabricacion, d.ClaCliente, b.IdFactura, b.IdFacturaAlfanumerico
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
		WHERE	b.IdFactura IS NOT NULL
	--	AND		a.ClaUbicacion = 369
	--	ORDER BY a.IdViaje DESC
	)	
	SELECT	ClaUbicacion, IdViaje, ClaCliente, COUNT(1) AS Pedidos
	INTO #Viajes
	FROM	H
	WHERE	IdFactura IS NOT NULL
	GROUP BY ClaUbicacion, IdViaje, ClaCliente
	HAVING COUNT(1)>1 -- más de un pedido

	SELECT * FROM #Viajes

	DROP TABLE #Viajes

	SELECT	a.ClaUbicacion, a.IdViaje, c.IdFabricacion, d.ClaCliente, b.IdFactura, b.IdFacturaAlfanumerico
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
	WHERE	a.ClaUbicacion = 323
	AND		a.IdViaje = 128
	ORDER BY IdViaje DESC, b.IdFactura ASC
-------------------------------------------------------------------------
	-- Logo
 	SELECT 	*
	FROM 	opesch.OPETiCatConfiguracionVw WITH(NOLOCK)
	WHERE 	ClaUbicacion 		= 369
			AND	ClaSistema 		= 127
			AND	ClaConfiguracion	= 2

--http://APPITKUSANET01:2243/Common/Images/WebToolImages/ItkLogo.png