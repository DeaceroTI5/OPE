DECLARE		  @CantPedidaCPO		NUMERIC (22,4)	= 120.00 
			, @CantidadMinAgrupCPO	NUMERIC	(22,4)	= 7.55


	SELECT	@CantPedidaCPO % @CantidadMinAgrupCPO
	SELECT ( @CantPedidaCPO) - ( ( @CantPedidaCPO ) % @CantidadMinAgrupCPO )			


	SELECT	@CantPedidaCPO = CASE WHEN ( @CantPedidaCPO ) % @CantidadMinAgrupCPO = 0
									THEN @CantPedidaCPO 
									ELSE ( @CantPedidaCPO ) - ( @CantPedidaCPO  % @CantidadMinAgrupCPO )
								END

	SELECT @CantPedidaCPO AS '@CantPedidaCPO'
