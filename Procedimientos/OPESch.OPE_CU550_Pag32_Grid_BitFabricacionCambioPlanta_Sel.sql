USE Operacion
GO
-- 'OPESch.OPE_CU550_Pag32_Grid_BitFabricacionCambioPlanta_Sel'
GO
ALTER PROCEDURE OPESch.OPE_CU550_Pag32_Grid_BitFabricacionCambioPlanta_Sel
	@pnClaPedidoBit	INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT DISTINCT 
			  IdFabricacionBit		= a.IdFabricacion
			, IdFabricacionNuevaBit	= a.IdFabricacionNueva
			, NomUbicacionBit		= CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + b.NomUbicacion
			, NomUbicacionNuevoBit	= CONVERT(VARCHAR(10),a.ClaUbicacionNuevo) + ' - ' + c.NomUbicacion
			, NombreMotivoBit		= d.NombreMotivo
			, FechaUltimaModBit		= MIN(a.FechaUltimaMod)
			, NombrePcModBit		= a.NombrePcMod
	FROM	OpeSch.OpeVtaBitFabricacionCambioPlanta a WITH(NOLOCK)
	INNER JOIN OpeSch.OpeTiCatUbicacionVw b
	ON		a.ClaUbicacion	= b.ClaUbicacion
	INNER JOIN OpeSch.OpeTiCatUbicacionVw c
	ON		a.ClaUbicacionNuevo	= c.ClaUbicacion
	LEFT JOIN DEAOFINET05.Ventas.VtaSch.VtaCatMotivoVw d
	ON		a.ClaMotivoCambio = d.ClaMotivo
	WHERE	(@pnClaPedidoBit IS NULL 
			OR(IdFabricacion = @pnClaPedidoBit ) OR (IdFabricacionNueva = @pnClaPedidoBit))
	GROUP BY a.IdFabricacion
			, a.IdFabricacionNueva
			, CONVERT(VARCHAR(10),a.ClaUbicacion) + ' - ' + b.NomUbicacion
			, CONVERT(VARCHAR(10),a.ClaUbicacionNuevo) + ' - ' + c.NomUbicacion
			, d.NombreMotivo
			, a.NombrePcMod



	SET NOCOUNT OFF
END