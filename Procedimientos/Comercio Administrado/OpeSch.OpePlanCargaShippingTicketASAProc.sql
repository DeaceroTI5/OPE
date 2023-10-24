USE Operacion
-- EXEC SP_HELPTEXT 'OpeSch.OpePlanCargaShippingTicketASAProc'
GO
ALTER PROCEDURE OpeSch.OpePlanCargaShippingTicketASAProc
	  @pnClaUbicacion	INT  = NULL
	, @pnIdViaje		INT  = NULL	
	--, @pnClaCliente		INT  = NULL	
	--, @pnClaConsignado	INT  = NULL
	, @pnIdFactura		INT  = NULL
AS
BEGIN
	SET NOCOUNT ON

	-- exec OpeSch.OpePlanCargaShippingTicketASAProc @pnClaUbicacion=369,@pnIdViaje=N'3'
	-- exec OpeSch.OpePlanCargaShippingTicketASAProc @pnClaUbicacion=369,@pnIdViaje=N'3',@pnClaCliente=817882,@pnIdFactura=1079000016


;WITH H AS(
	SELECT	  a.ClaUbicacion
			, a.IdViaje
			, a.IdPlanCarga
			, c.IdFactura 
			, b.IdFabricacion
			, b.IdFabricacionDet
			, d.ClaCliente
			, d.ClaConsignado
			, b.NombreArticulo
			, b.ControlCode
			, b.ProductDescription
			, b.Diameter					
			, b.Grade	
			, Prorrateo			= SUM(ROUND(DocumentedWeightKgs,2))
			, StraightItems		= ISNULL(ROUND(StraightItems,2) , 0)
			, StraightPieces	= ISNULL(ROUND(StraightPieces,2) ,0)
			, StraightKgs		= ISNULL(ROUND(StraightKgs,2) ,0)
			, StraightLength	= ISNULL(ROUND(StraightLength,2) , 0)
			, BentItems			= ISNULL(ROUND(BentItems,2) , 0) 
			, BentPieces		= ISNULL(ROUND(BentPieces,2) , 0) 
			, BentKgs			= ISNULL(ROUND(BentKgs,2) , 0)
			, BentLength		= ISNULL(ROUND(BentLength,2) , 0)
			, TotalKgs
	FROM	OpeSch.OpeTraViaje a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeRelPlanCargaShipIDDet b WITH(NOLOCK)
	ON		a.ClaUbicacion		= b.ClaUbicacion
	AND		a.IdPlanCarga		= b.IdPlanCarga
	LEFT JOIN OpeSch.OpeTraMovEntSal c WITH(NOLOCK)  
	ON		a.ClaUbicacion		= c.ClaUbicacion  
	AND		b.IdFabricacion		= c.IdFabricacion
	AND		a.IdViaje			= c.IdViaje  
	LEFT JOIN OpeSch.OpeTraFabricacionVw d WITH(NOLOCK)   
	ON		b.ClaUbicacion		= d.ClaPlanta  
	AND		b.IdFabricacion		= d.IdFabricacion               
	LEFT JOIN OpeSch.OpeTraFabricacionDetVw e WITH(NOLOCK)
	ON		b.IdFabricacion		= e.IdFabricacion
	AND		b.IdFabricacionDet	= e.IdFabricacionDet
	WHERE	(@pnClaUbicacion IS NULL OR (a.ClaUbicacion		= @pnClaUbicacion ))
	AND		a.IdViaje			= @pnIdViaje  
--	AND		(@pnClaCliente IS NULL OR (t3.ClaCliente = @pnClaCliente))
--	AND		(@pnClaConsignado IS NULL OR (ISNULL(t3.ClaConsignado,0) = ISNULL(@pnClaConsignado, 0)))
	AND		(@pnIdFactura IS NULL OR (c.IdFactura = @pnIdFactura))
	GROUP BY   a.ClaUbicacion 		 , a.IdViaje			 , a.IdPlanCarga		 , c.IdFactura 
			 , b.IdFabricacion		 , b.IdFabricacionDet	 , d.ClaCliente			 , d.ClaConsignado
			 , b.NombreArticulo		 , b.Diameter			 , b.Grade				 , b.StraightItems		
			 , b.StraightPieces		 , b.StraightKgs		 , b.StraightLength		 , b.BentItems			
			 , b.BentPieces			 , b.BentKgs			 , b.BentLength			 , b.TotalKgs
			 , b.ControlCode		 , b.ProductDescription
)			   
	SELECT	 
			  ClaCliente  
			, IdFactura  
			, ControlCode
			, ProductDescription
			, Diameter        
			, Grade               
			, StraightItems		= ISNULL((Prorrateo / TotalKgs), 0) * StraightItems
			, StraightPieces	= ISNULL((Prorrateo / TotalKgs), 0) * StraightPieces 
			, StraightKgs		= ISNULL((Prorrateo / TotalKgs), 0) * StraightKgs   
			, StraightLength    = ISNULL((Prorrateo / TotalKgs), 0) * StraightLength            
			, BentItems			= ISNULL((Prorrateo / TotalKgs), 0) * BentItems
			, BentPieces		= ISNULL((Prorrateo / TotalKgs), 0) * BentPieces 
			, BentKgs			= ISNULL((Prorrateo / TotalKgs), 0) * BentKgs
			, BentLength		= ISNULL((Prorrateo / TotalKgs), 0) * BentLength 
			, Clasificacion =
				CASE WHEN NombreArticulo LIKE '%BENT%'
						THEN 1
						WHEN NombreArticulo LIKE '%STRAIGHT%' 
							THEN 2
						ELSE 0
				END
	--		, ClaUbicacion 
	--		, IdViaje    
	--		, IdPlanCarga
	--		, IdFabricacion
	--		, IdFabricacionDet
	--		, ClaConsignado 
	--		, NombreArticulo 
	--		, Prorrateo                
	--		, TotalKgs   
	FROM	H



	SET NOCOUNT OFF
END