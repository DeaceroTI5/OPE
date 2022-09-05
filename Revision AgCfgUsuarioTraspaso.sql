USE Operacion
GO

--OPEROFIDB02
	-- AGSch.AG_CU205_Pag2_Boton_BuscaPedidoBtn_Proc
	--dbo.TiCatTipoUbicacionVw
	
   Select @nClaTipoUbiSolicita = ClaTipoUbicacion from TiCatUbicacionVw where ClaUbicacion = @nClaUbicacionPide  -- 22 Ene 2016

   IF NOT ( EXISTS (	SELECT	1 
						FROM	Agsch.AgCfgUsuarioTraspaso t1 
						WHERE	t1.ClaUsuario = @pnClaUsuarioMod 
						AND		t1.ClaUbicacion = @nClaUbicacionPide 
						AND		t1.BajaLogica = 0
					)
		OR EXISTS	(	SELECT	1 
						FROM	Agsch.AgCfgUsuarioTraspaso t2 
						WHERE	t2.ClaUsuario = @pnClaUsuarioMod 
						AND		t2.ClaUbicacion = -1 
						AND		t2.ClaTipoUbicacion = -1 
						AND		t2.BajaLogica = 0
					)
		OR EXISTS	(	SELECT	1 
						FROM	Agsch.AgCfgUsuarioTraspaso t3 
						WHERE	t3.ClaUsuario = @pnClaUsuarioMod 
						AND		t3.ClaUbicacion = -1 
						AND		t3.ClaTipoUbicacion = @nClaTipoUbiSolicita  
						AND		t3.BajaLogica = 0
					)
			)
   Begin
      Select	EstatusPedidoAp = '', FechaEstimadaAp = NULL, ClaPedidoAp = NULL, TipoTraspaso = NULL
      Select	@psEstatusPedidoAp = '', @ptFechaEstimadaAp = NULL, @pnClaPedidoAp = NULL, @psTipoTraspaso = NULL
      Raiserror ( 'Su usuario no tiene permisos para cancelar en esta ubicación', 16, 1 )
      Return
   End

	