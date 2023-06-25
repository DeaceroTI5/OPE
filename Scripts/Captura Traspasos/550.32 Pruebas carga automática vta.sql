--SELECT @@SERVERNAME
-- MSLABBD01\VTAPREPROD
BEGIN TRAN
	UPDATE	a
	SET		ClaEstatusFabricacion = 1 -- 3
--	SELECT	ClaEstatusFabricacion, * 
	FROM	VtaSch.VtaTraFabricacionVw a
	WHERE	IdFabricacion = 23047486	-- pedido origen
COMMIT TRAN

BEGIN TRAN	-- Coincidencias para otras solicitudes
	UPDATE	a
	SET		ClaEstatusFabricacion = 6 -- 3
--	SELECT	ClaEstatusFabricacion, * 
	FROM	VtaSch.vtatrafabricacionDetVw a
	WHERE	ClaArticulo IN (694805,694806,694810,694811)
	AND		IdFabricacion = 23070186	-- clapedido
COMMIT TRAN

	SELECT	* 
	FROM	DEAOFINET05.Ventas.VtaSch.vtatrafabricacionDetVw
	WHERE	ClaArticulo IN (694805,694806,694810,694811)
	AND		IdFabricacion = 23070186 -- clapedido