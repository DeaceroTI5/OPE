USE Operacion
GO
-- 'OpeSch.OPE_CU550_Pag28_Sel'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag28_Sel
    @pnClaUbicacion         INT, 
    @pnCmbCliente           INT, 
    @pnCmbProyecto          INT, 

    @psVarAccionCmbCliente  VARCHAR(50),
    @psVarAccionCmbProyecto VARCHAR(50)
AS
BEGIN
    DECLARE @VarCmbCliente INT, @VarCmbProyecto INT, @CmbCliente INT, @CmbProyecto INT, @Relacion INT
    SELECT @VarCmbCliente = NULL, @VarCmbProyecto = NULL, @CmbCliente = NULL, @CmbProyecto = NULL, @Relacion = NULL

	;WITH	PedidosEstimaciones AS
	(SELECT	a.IdFabriacionUnificado, 365 AS ClaUbicacionVenta, a.IdFabricacionOriginal AS idFabricacionVenta, a.ClaUbicacion AS ClaUbicacionEstimacion, a.IdFabricacionEstimacion AS idFabricacionEstimacion
	 FROM	OpeSch.OpeRelFabricacionbUnificadasVw a WITH(NOLOCK)
	 WHERE	a.IdControlUnificacion IN (SELECT MAX(IdControlUnificacion)
											FROM OpeSch.OpeRelFabricacionbUnificadasVw 
											GROUP BY ClaUbicacion, IdFabricacionOriginal, IdFabricacionEstimacion)
	 UNION
	 SELECT DISTINCT
			NULL AS IdFabriacionUnificado, b.ClaUbicacionVenta, b.idFabricacionVenta, b.ClaUbicacionEstimacion, b.idFabricacionEstimacion
	 FROM	OpeSch.OpeTraFabricacionEspejoEstimacion b WITH(NOLOCK)
	 WHERE	b.idFabricacionVenta NOT IN (SELECT DISTINCT IdFabriacionUnificado
											FROM OpeSch.OpeRelFabricacionbUnificadasVw))
    
    SELECT  IdFabriacionUnificado, ClaUbicacionVenta, idFabricacionVenta, ClaUbicacionEstimacion, idFabricacionEstimacion
    INTO    #TempPedidosEstimacion
    FROM    PedidosEstimaciones

    IF EXISTS (    (SELECT		a.ClaProyecto AS ClaProyecto, a.ClaClienteCuenta AS ClaCliente
                    FROM		OpeSch.OpeVtaCatProyectoVw a
                    WHERE		( isnull(a.BajaLogica, 0) != 1 )  
					AND			a.ClaProyecto = @pnCmbProyecto 
					AND 		a.ClaClienteCuenta = @pnCmbCliente

                    UNION

                    SELECT		DISTINCT d.ClaProyecto AS ClaProyecto, e.ClaCliente AS ClaCliente
                    FROM		#TempPedidosEstimacion a 
                        INNER JOIN	OpeSch.OpeTraFabricacionVw b WITH(NOLOCK)
                                    ON b.IdFabricacion = a.idFabricacionVenta
                        INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw c WITH(NOLOCK)
                                    ON c.IdFabricacion = b.IdFabricacion
                        INNER JOIN	OpeSch.OpeVtaCatProyectoVw d WITH(NOLOCK)
                                    ON d.ClaProyecto = c.ClaProyecto
                        INNER JOIN	OpeSch.OpeVtaCatClienteVw e WITH(NOLOCK)
                                    ON e.ClaCliente = d.ClaClienteCuenta
                	WHERE 	d.ClaProyecto = @pnCmbProyecto 
					AND 	e.ClaCliente = @pnCmbCliente )	)
    BEGIN
        SET @Relacion = 1
    END

    ELSE
    BEGIN
        SET @Relacion = 0
    END


    SET @VarCmbCliente = (CASE
                            WHEN (@pnCmbCliente != -1 OR @pnCmbCliente != '-1' OR @pnCmbCliente IS NOT NULL) THEN 1
                            ELSE 0
                          END)

    SET @VarCmbProyecto = (CASE
                            WHEN (@pnCmbProyecto != -1 OR @pnCmbProyecto != '-1' OR @pnCmbProyecto IS NOT NULL) THEN 1
                            ELSE 0
                           END)

    IF ( @psVarAccionCmbCliente = 'N' AND @psVarAccionCmbProyecto = 'N' )
    BEGIN
        SET @CmbCliente = @pnCmbCliente
        SET @CmbProyecto = @pnCmbProyecto
    END

    ELSE IF ( @psVarAccionCmbCliente = 'I' AND @psVarAccionCmbProyecto = 'D' )
    BEGIN
        IF ( @VarCmbProyecto = 1 )
        BEGIN
            IF ( @Relacion = 1 )
            BEGIN
                SET @CmbCliente = @pnCmbCliente
                SET @CmbProyecto = @pnCmbProyecto
            END 

            ELSE IF ( @Relacion = 0 )
            BEGIN
                SET @CmbCliente = @pnCmbCliente
                SELECT @CmbProyecto = NULL
                SET @VarCmbProyecto = 0
            END
  END

       ELSE IF ( @VarCmbProyecto = 0 )
        BEGIN
            SET @CmbCliente = @pnCmbCliente
            SET @CmbProyecto = @pnCmbProyecto
        END
    END

    ELSE IF ( @psVarAccionCmbCliente = 'D' AND @psVarAccionCmbProyecto = 'I' )
    BEGIN
        IF ( @VarCmbCliente = 1 )
        BEGIN
            IF ( @Relacion = 1 )
            BEGIN
                SET @CmbCliente = @pnCmbCliente
                SET @CmbProyecto = @pnCmbProyecto
            END 

            ELSE IF ( @Relacion = 0 )
            BEGIN
                SET @CmbProyecto = @pnCmbProyecto

                ;WITH Proyectos AS
                (SELECT		a.ClaProyecto AS ClaProyecto, a.ClaClienteCuenta AS ClaCliente
                FROM		OpeSch.OpeVtaCatProyectoVw a
                WHERE		( isnull(a.BajaLogica, 0) != 1 )  

                UNION

                SELECT		DISTINCT d.ClaProyecto AS ClaProyecto, e.ClaCliente AS ClaCliente
                FROM		#TempPedidosEstimacion a 
                    INNER JOIN	OpeSch.OpeTraFabricacionVw b WITH(NOLOCK)
                                ON b.IdFabricacion = a.idFabricacionVenta
                    INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw c WITH(NOLOCK)
                                ON c.IdFabricacion = b.IdFabricacion
                    INNER JOIN	OpeSch.OpeVtaCatProyectoVw d WITH(NOLOCK)
                                ON d.ClaProyecto = c.ClaProyecto
                    INNER JOIN	OpeSch.OpeVtaCatClienteVw e WITH(NOLOCK)
                                ON e.ClaCliente = d.ClaClienteCuenta)
                
                SELECT @CmbCliente = ClaCliente FROM Proyectos a WHERE ClaProyecto = @pnCmbProyecto

                SET @VarCmbProyecto = 1
            END
        END

        ELSE IF ( @VarCmbCliente = 0 )
        BEGIN
            SET @CmbProyecto = @pnCmbProyecto

            ;WITH Proyectos AS
            (SELECT		a.ClaProyecto AS ClaProyecto, a.ClaClienteCuenta AS ClaCliente
            FROM		OpeSch.OpeVtaCatProyectoVw a
            WHERE		( isnull(a.BajaLogica, 0) != 1 )  

            UNION

            SELECT		DISTINCT d.ClaProyecto AS ClaProyecto, e.ClaCliente AS ClaCliente
            FROM		#TempPedidosEstimacion a 
                INNER JOIN	OpeSch.OpeTraFabricacionVw b WITH(NOLOCK)
                            ON b.IdFabricacion = a.idFabricacionVenta
                INNER JOIN	OpeSch.OpeVtaRelFabricacionProyectoVw c WITH(NOLOCK)
                            ON c.IdFabricacion = b.IdFabricacion
                INNER JOIN	OpeSch.OpeVtaCatProyectoVw d WITH(NOLOCK)
                            ON d.ClaProyecto = c.ClaProyecto
                INNER JOIN	OpeSch.OpeVtaCatClienteVw e WITH(NOLOCK)
                            ON e.ClaCliente = d.ClaClienteCuenta)
            
            SELECT @CmbCliente = ClaCliente FROM Proyectos a WHERE ClaProyecto = @pnCmbProyecto

            SET @VarCmbProyecto = 1
        END
    END

    ELSE
    BEGIN
        SET @CmbCliente = @pnCmbCliente
        SET @CmbProyecto = @pnCmbProyecto
    END

	IF ( ( @psVarAccionCmbCliente = 'I' AND @pnCmbCliente IS NULL ) OR ( @psVarAccionCmbProyecto = 'I' AND @pnCmbProyecto IS NULL ) )
	BEGIN
		SELECT 
			@VarCmbCliente AS VarCmbCliente, 
			@VarCmbProyecto AS VarCmbCliente
	END

	ELSE
	BEGIN
		SELECT 
			@CmbCliente AS CmbCliente,
			@VarCmbCliente AS VarCmbCliente, 
			@CmbProyecto AS CmbProyecto,
			@VarCmbProyecto AS VarCmbProyecto
			, FabricacionVenta=NULL
			, ViajeVenta=NULL
			, Remision=NULL
			, IdFabVentaDet=NULL
			, IdFabVentaDet=NULL
			, IdFabDetVentaDet=NULL
			, ArticuloDet=NULL
			, ViajeDet=NULL
			, RemisionDet=NULL
	END	

    DROP TABLE #TempPedidosEstimacion
END
