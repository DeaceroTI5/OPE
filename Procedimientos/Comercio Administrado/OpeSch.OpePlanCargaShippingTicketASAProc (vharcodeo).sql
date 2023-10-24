Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE OpeSch.OpePlanCargaShippingTicketASAProc
	  @pnClaUbicacion	INT  = NULL
	, @pnIdViaje		INT  = NULL	
--	, @pnClaCliente		INT  = NULL	
--	, @pnClaConsignado	INT  = NULL
	, @pnIdFactura		INT  = NULL
AS
BEGIN
	SET NOCOUNT ON

	-- exec OpeSch.OpePlanCargaShippingTicketASAProc @pnClaUbicacion=365,@pnIdViaje=N'1133'
	-- exec OpeSch.OpePlanCargaShippingTicketASAProc @pnClaUbicacion=365,@pnIdViaje=N'1133',@pnClaCliente=NULL,@pnIdFactura=1039001758
	-- exec OpeSch.OpePlanCargaShippingTicketASAProc @pnClaUbicacion=365,@pnIdViaje=N'1133',@pnClaCliente=NULL,@pnIdFactura=1039001759
	-- exec OpeSch.OpePlanCargaShippingTicketASAProc @pnClaUbicacion=365,@pnIdViaje=N'1133',@pnClaCliente=NULL,@pnIdFactura=1039001760



	DECLARE @tbRelShippingTicket TABLE (
		  Id				INT IDENTITY(1,1)		, ControlCode		INT					, Product			VARCHAR(400)			, Diam				INT
		, Grade				INT						, StraightItems		INT					, StraightPieces	INT						, StraightLb		NUMERIC(22,2)			
		, BentItems			INT						, BentPieces		INT					, BentLb			NUMERIC(22,2)			, EsStraight		TINYINT, EsBent TINYINT
	)


	INSERT INTO @tbRelShippingTicket (ControlCode, Product, Diam, Grade, StraightItems, StraightPieces, StraightLb,BentItems,BentPieces,BentLb)
	VALUES	  ( 1,'ITKSC60 - ASTM GR60 #5 ST'	,5	,0	,2,	20,	56.00	,2	,20		,56.00)
			, ( 2,'ITKSC60 - ASTM GR60 #6 ST'	,6	,0	,3,	24,	53.00	,3	,24		,53.00)
			, ( 3,'ITKSC80 - ABNM GR80 #8 BN'	,7	,0	,5,	26,	73.00	,5	,26		,73.00)
			, ( 4,'ITKSC80 - ABNM GR80 #9 BN'	,8	,0	,6,	31,	86.00	,6	,31		,86.00)

	IF @pnIdFactura=1039001760
	DELETE FROM @tbRelShippingTicket WHERE Id IN (1,2)
 
	SELECT DISTINCT
			  Id = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
			, t1.ClaUbicacion
			, t1.IdViaje
			, t1.IdPlanCarga
			, t2.IdFactura
			, t2.IdFabricacion
			, t4.IdFabricacionDet
			, t3.ClaCliente
			, t3.ClaConsignado
			, t2.IdFacturaAlfanumerico
	INTO	#Facturas
	FROM  OpeSch.OpeTraViaje t1 WITH(NOLOCK)  
	LEFT JOIN OpeSch.OpeTraMovEntSal t2 WITH(NOLOCK)  
	ON		t1.ClaUbicacion		= t2.ClaUbicacion  
	AND		t1.IdViaje			= t2.IdViaje  
	LEFT JOIN OpeSch.OpeTraFabricacionVw t3 WITH(NOLOCK)   
	ON		t2.ClaUbicacion		= t3.ClaPlanta  
	AND		t2.IdFabricacion	= t3.IdFabricacion               
	LEFT JOIN OpeSch.OpeTraFabricacionDetVw t4 WITH(NOLOCK)
	ON		t2.IdFabricacion	= t4.IdFabricacion
	WHERE	(@pnClaUbicacion IS NULL OR (t1.ClaUbicacion		= @pnClaUbicacion ))
	AND		t1.IdViaje			= @pnIdViaje  
--	AND		(@pnClaCliente IS NULL OR (t3.ClaCliente = @pnClaCliente))
--	AND		(@pnClaConsignado IS NULL OR (ISNULL(t3.ClaConsignado,0) = ISNULL(@pnClaConsignado, 0)))
	AND		(@pnIdFactura IS NULL OR (t2.IdFactura = @pnIdFactura))



	UPDATE a
	SET		EsStraight	= CASE WHEN (SELECT COUNT(1) FROM @tbRelShippingTicket b INNER JOIN #Facturas c ON c.Id = b.Id WHERE b.Product LIKE '%ST%') >= 1 THEN 1 ELSE 0 END 
			,EsBent		= CASE WHEN (SELECT COUNT(1) FROM @tbRelShippingTicket b INNER JOIN #Facturas c ON c.Id = b.Id WHERE b.Product LIKE '%BN%') >= 1 THEN 1 ELSE 0 END 
	FROM	@tbRelShippingTicket a
	


	SELECT	  a.ClaCliente
			, a.IdFactura
			, ControlCode = a.IdFacturaAlfanumerico
			, b.Product		
			, b.Diam			
			, b.Grade			
			, b.StraightItems	
			, b.StraightPieces		
			, b.StraightLb
			, b.BentItems
			, b.BentPieces
			, b.BentLb
			, b.EsStraight	
			, b.EsBent		
	FROM	#Facturas a
	INNER JOIN @tbRelShippingTicket b
	ON		a.Id = b.Id


	SET NOCOUNT OFF
END