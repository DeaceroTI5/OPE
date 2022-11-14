USE Operacion
GO
	-- 'OpeSch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel
@pnClaUbicacion INT,
@pnIdViajeAux INT,
@pnShipIDAux VARCHAR(25)
AS
BEGIN
	SET NOCOUNT ON
	
		--SELECT  											
		--	c.[Order], c.ControlCode, c.[Status], 												
		--	c.Product, c.ProductDescr, c.Diameter, c.Grade, c.Texture, c.Material, c.Coating, 												
		--	c.TotalItems, c.TotalPieces, c.TotalKgs, 												
		--	c.StraightItems, c.StraightPieces, c.StraightKgs,												
		--	c.BentItems, c.BentPieces, c.BentKgs												
		--	FROM opesch.OPEASAControlCodeSummary c													
		--	INNER JOIN (SELECT DISTINCT bb.orderID, bb.CtrlCode, bb.Product, bb.ShipId													
		--				FROM OpeSch.OpeRelViajeShipID aa
		--				INNER JOIN opesch.OPEASAShippingTicketDet bb
		--				ON aa.ShipID = bb.ShipID										
		--				WHERE aa.ClaUbicacion = @pnClaUbicacion AND aa.IdViaje = @pnIdViajeAux) b										
		--	on c.[order] = b.orderID													
		--	and c.ControlCode = b.CtrlCode													
		--	and c.Product = b.Product													
	
	
			SELECT  											
				c.[Order], c.ControlCode, c.[Status], 												
				c.Product, c.ProductDescr, c.Diameter, c.Grade, c.Texture, c.Material, c.Coating
				, TotalItems	= CONVERT(NUMERIC(18,4),ISNULL(c.TotalItems,'0'))
				, TotalPieces	= CONVERT(NUMERIC(18,4),ISNULL(c.TotalPieces,'0')) 
				, SUM(CONVERT(numeric(18,4), ISNULL(b.Weight,'0'))) AS TotalKgs
				, StraightItems	= CONVERT(NUMERIC(18,4),ISNULL(c.StraightItems,'0')) 
				, StraightPieces= CONVERT(NUMERIC(18,4),ISNULL(c.StraightPieces,'0')) 
				, StraightKgs	= CONVERT(NUMERIC(18,4),ISNULL(c.StraightKgs,'0')) 
				, BentItems		= CONVERT(NUMERIC(18,4),ISNULL(c.BentItems,'0')) 
				, BentPieces	= CONVERT(NUMERIC(18,4),ISNULL(c.BentPieces,'0')) 
				, BentKgs		= CONVERT(NUMERIC(18,4),ISNULL(c.BentKgs,'0')) 												
			FROM opesch.OPEASAControlCodeSummary c													
				INNER JOIN opesch.OPEASAShippingTicketDet b										
				on c.[order] = b.orderID													
				and c.ControlCode = b.CtrlCode													
				and c.Product = b.Product			
			WHERE	b.ShipID = @pnShipIDAux
			GROUP BY
				c.[Order], c.ControlCode, c.[Status], 												
				c.Product, c.ProductDescr, c.Diameter, c.Grade, c.Texture, c.Material, c.Coating, 												
				c.TotalItems, c.TotalPieces, 												
				c.StraightItems, c.StraightPieces, c.StraightKgs,												
				c.BentItems, c.BentPieces, c.BentKgs	
			
	SET NOCOUNT OFF
END
