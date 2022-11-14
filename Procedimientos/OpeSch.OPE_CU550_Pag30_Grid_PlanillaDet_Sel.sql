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
				c.Product, c.ProductDescr, c.Diameter, c.Grade, c.Texture, c.Material, c.Coating, 												
				c.TotalItems, c.TotalPieces, SUM(CONVERT(numeric(18,4), ISNULL(b.Weight,'0'))) AS TotalKgs, 												
				c.StraightItems, c.StraightPieces, c.StraightKgs,												
				c.BentItems, c.BentPieces, c.BentKgs												
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

/*

exec OPESch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel @pnClaUbicacion=325,@pnIdViajeAux=1230
exec OPESch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel @pnClaUbicacion=325,@pnIdViajeAux=1231

exec OPESch.OPE_CU550_Pag30_Grid_PlanillaDet_Sel @pnClaUbicacion=326,@pnIdViajeAux=230

	EXEC OPESch.OPE_CU550_Pag30_Grid_PlantillaDet_Sel @pnClaUbicacion = 326



	SELECT 													
	c.[Order], c.ControlCode, c.[Status], 												
	c.Product, c.ProductDescr, c.Diameter, c.Grade, c.Texture, c.Material, c.Coating, 												
	c.TotalItems, c.TotalPieces, c.TotalKgs, 												
	c.StraightItems, c.StraightPieces, c.StraightKgs,												
	c.BentItems, c.BentPieces, c.BentKgs												
FROM opesch.OPEASAControlCodeSummary c													
INNER JOIN (SELECT DISTINCT bb.orderID, bb.CtrlCode, bb.Product, bb.ShipId													
			FROM opesch.OPEASAShippingTicketDet bb										
			WHERE bb.ShipKey = 4720) b										
on c.[order] = b.orderID													
and c.ControlCode = b.CtrlCode													
and c.Product = b.Product													



*/



