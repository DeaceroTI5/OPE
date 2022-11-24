USE Operacion
GO


--SELECT COUNT(1) FROM [OpeSch].[OPEASAShippingTicketDet] WHERE ShipID = 'REM-09677'

	--SELECT	ShipWeight, * 
	--FROM	[OpeSch].[OPEASAShippingTicket] 
	--WHERE	ShipID = 'REM-09677'		-- 20169.6320
	
	SELECT	ShipID, SUM(CONVERT(NUMERIC(18,4),Weight)) 
	FROM	[OpeSch].[OPEASAShippingTicketDet] 
	WHERE	ShipID = 'REM-09677' 
	GROUP BY ShipID
	
	SELECT	CONVERT(NUMERIC(18,4),Weight), *
	FROM	[OpeSch].[OPEASAShippingTicketDet] 
	WHERE	ShipID = 'REM-09677' 
	order by Weight


	SELECT	  b.ShipID
			, a.ShipWeight 
			, SUM(CONVERT(numeric(18,4), ISNULL(b.Weight,'0'))) AS TotalKgs
			, CantidadDetale = COUNT(1)
			, b.Weight
			, SUM(CONVERT(numeric(18,4), ISNULL(c.TotalKgs,'0'))) AS TotalKgsCC
	FROM opesch.OPEASAControlCodeSummary c													
	INNER JOIN opesch.OPEASAShippingTicketDet b										
	on		c.[order]		= b.orderID													
	and		c.ControlCode	= b.CtrlCode													
	and		c.Product		= b.Product
	INNER JOIN [OpeSch].[OPEASAShippingTicket] a
	ON		b.ShipKey		= a.ShipKey
	WHERE	b.ShipID		= 'REM-09677'
	GROUP BY b.ShipID, a.ShipWeight,  b.Weight

	SELECT	  c.*
	FROM opesch.OPEASAControlCodeSummary c													
	INNER JOIN opesch.OPEASAShippingTicketDet b										
	on		c.[order]		= b.orderID													
	and		c.ControlCode	= b.CtrlCode													
	and		c.Product		= b.Product
	INNER JOIN [OpeSch].[OPEASAShippingTicket] a
	ON		b.ShipKey		= a.ShipKey
	WHERE	b.ShipID		='REM-09677'


--SELECT * FROM [OpeSch].[OPEASAShippingTicketHeatData] WHERE ShipID = 'REM-09677'
