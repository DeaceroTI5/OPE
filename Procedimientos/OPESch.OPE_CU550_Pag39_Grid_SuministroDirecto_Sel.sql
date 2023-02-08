ALTER PROCEDURE OPESch.OPE_CU550_Pag39_Grid_SuministroDirecto_Sel
	  @pnClaUbicacionFilial	INT = 324
	, @pnClaUbicacionOrigen	INT
	, @psNumFacturaFilial	VARCHAR(20) = ''
	, @psNumFacturaOrigen	VARCHAR(20) = ''
AS
BEGIN
	SET NOCOUNT ON



	SELECT	  @psNumFacturaFilial = ISNULL(@psNumFacturaFilial,'')
			, @psNumFacturaOrigen = ISNULL(@psNumFacturaOrigen,'')

	DECLARE @tbFacturas TABLE(
		  ClaUbicacion			INT
		, NumFacturaFilial		VARCHAR(20)
		, IdFacturaFilial		INT
		, KilosSurtidosFilial	NUMERIC(22,4)
		, ClienteFilial			VARCHAR(100)
		, ConsignadoFilial		VARCHAR(100)
		, ClaUbicacionOrigen	INT
		, NumFacturaOrigen		VARCHAR(20)
		, IdFacturaOrigen		INT
		, KilosSurtidosOrigen	NUMERIC(22,4)
		, ClienteOrigen			VARCHAR(100)
		, ConsignadoOrigen		VARCHAR(100)
	)


	INSERT INTO @tbFacturas (
		  ClaUbicacion			, NumFacturaFilial	, IdFacturaFilial 
		, ClaUbicacionOrigen	, NumFacturaOrigen	, IdFacturaOrigen 
	)
	SELECT	  ClaUbicacion
			, NumFacturaFilial
			, IdFacturaFilial
			, ClaUbicacionOrigen
			, NumFacturaOrigen
			, IdFacturaOrigen 
	FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)
	WHERE	ClaUbicacion = @pnClaUbicacionFilial
	AND		(@pnClaUbicacionOrigen IS NULL OR (ClaUbicacionOrigen = @pnClaUbicacionOrigen))
	AND		(@psNumFacturaFilial = '' OR (NumFacturaFilial = @psNumFacturaFilial))
	AND		(@psNumFacturaOrigen = '' OR (NumFacturaOrigen = @psNumFacturaOrigen))


	-- FacturaOrigen
	UPDATE	a
	SET		  KilosSurtidosOrigen	= b.KilosSurtidos
			, ClienteOrigen			= CONVERT(VARCHAR(15), b.ClaCliente)+' - '+c.NomCliente
			, ConsignadoOrigen		= CONVERT(VARCHAR(15),b.ClaConsignado)+ ' - ' + d.NombreConsignado
	FROM	@tbFacturas a 
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaCTraFactura b WITH(NOLOCK)
	ON		a.NumFacturaOrigen			= b.IdFacturaAlfanumerico
	LEFT JOIN OpeSch.OpeVtaCatClienteVw c WITH(NOLOCK) 
	ON		b.ClaCliente			= c.ClaCliente
	LEFT JOIN OpeSch.OpeVtaCatConsignadoVw d
	ON		b.ClaConsignado			= d.ClaConsignado


	-- FacturaFilial
	UPDATE	a
	SET		  KilosSurtidosFilial	= ISNULL(b.KilosSurtidos,d.PesoEmbarcado)
			, ClienteFilial			= CONVERT(VARCHAR(15), b.ClaCliente)+' - '+ c.NomCliente
			, ConsignadoFilial		= CONVERT(VARCHAR(15), b.ClaConsignado)+' - '+ g.NombreConsignado
	FROM	@tbFacturas a
	LEFT JOIN DEAOFINET05.Ventas.VtaSch.VtaCTraFactura b
	ON		a.NumFacturaFilial		= b.IdFacturaAlfanumerico
	LEFT JOIN OpeSch.OpeVtaCatClienteVw c
	ON		b.ClaCliente			= c.ClaCliente
	LEFT JOIN  OpeSch.OpeTraMovEntSalVw  d
	ON		a.NumFacturaFilial		= d.IdFacturaAlfanumerico
	LEFT JOIN OpeSch.OpeVtaCatConsignadoVw g
	ON		b.ClaConsignado			= g.ClaConsignado

	-- FacturaFilial
	UPDATE	a
	SET		  ClienteFilial			= CASE WHEN a.ClienteFilial IS NULL THEN CONVERT(VARCHAR(15), e.ClaCliente)+' - '+ f.NomCliente ELSE a.ClienteFilial END
			, ConsignadoFilial		= CASE WHEN a.ConsignadoFilial IS NULL THEN CONVERT(VARCHAR(15), e.ClaCliente)+' - '+ h.NombreConsignado ELSE a.ConsignadoFilial END
	FROM	@tbFacturas a
	LEFT JOIN  OpeSch.OpeTraMovEntSalVw  d
	ON		a.NumFacturaFilial		= d.IdFacturaAlfanumerico
	LEFT JOIN DEAOFINET05.Ventas.VtaSch.VtaTraFabricacionVw e WITH(NOLOCK) -- Comercial
	ON		d.IdFabricacion			= e.IdFabricacion
	LEFT JOIN OpeSch.OpeVtaCatClienteVw f
	ON		e.ClaCliente			= f.ClaCliente
	LEFT JOIN OpeSch.OpeVtaCatConsignadoVw h
	ON		e.ClaConsignado			= h.ClaConsignado
	WHERE	(a.ClienteFilial IS NULL OR a.ConsignadoFilial IS NULL)



	SELECT	  UbicacionFilial		= CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + b.NombreUbicacion
			, NumFacturaFilial		
			, KilosSurtidosFilial	
			, ClienteFilial			
			, ConsignadoFilial		
			, UbicacionOrigen		= CONVERT(VARCHAR(10),a.ClaUbicacionOrigen) + ' - ' + c.NombreUbicacion
			, NumFacturaOrigen		
			, KilosSurtidosOrigen	
			, ClienteOrigen			
			, ConsignadoOrigen		
	FROM	@tbFacturas a
	INNER JOIN OpeSCH.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacion	= b.ClaUbicacion
	INNER JOIN OpeSch.OpeTiCatUbicacionVw c
	ON		a.ClaUbicacionOrigen	= c.ClaUbicacion




	SET NOCOUNT OFF
END