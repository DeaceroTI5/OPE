
	/* -- Consulta de Facturas de Proformas que no existen en tabla de Facturas */
	SELECT	a.IdFacturaNueva, c.IdFacturaAlfanumerico
			--, Mes = MONTH(c.FechaUltimaMod), Anio = YEAR(c.FechaUltimaMod), c.FechaUltimaMod
			, c.FechaFactura
	FROM	Ventas.VtaSch.VtaTraProforma a WITH(NOLOCK) 
	LEFT JOIN Ventas.VtaSch.VtaCTraFactura b WITH(NOLOCK)
	ON		a.IdFacturaNueva = b.IdFactura
	INNER JOIN DEAOFINET05.Ventas.VtaSch.VtaCTraFactura c WITH(NOLOCK)
	ON		a.IdFacturaNueva = c.IdFactura 
	WHERE	a.IdFacturaNueva IS NOT NULL
	AND		b.IdFactura IS NULL
	AND		c.ClaUbicacion IN (277, 278, 322, 323, 324, 325, 326, 327, 328, 329, 360, 361, 362, 363, 364, 365, 366, 367, 368, 375, 424, 430, 431, 432, 433, 434, 435, 436, 437, 438, 470)
	AND		c.IdFacturaAlfanumerico LIKE 'QH%'
	ORDER BY c.FechaFactura ASC

USE Sincroniza
GO
SELECT * FROM sincroniza.dbo.transfer_estatus WHERE grupo = 'TF_OPE' AND sub_grupo = 'Estimaciones' AND tabla = 'TF_VtaCTraFactura'
SELECT 'INICIO'
BEGIN TRAN
	UPDATE	a
	SET		fuc = '2020-12-01 00:00:00.000'
			, fecha = '2020-12-01 00:00:00.000'
	FROM	sincroniza.dbo.transfer_estatus a 
	WHERE	grupo = 'TF_OPE' 
	AND		sub_grupo = 'Estimaciones' 
	AND		tabla = 'TF_VtaCTraFactura'
	
	EXEC dbo.sp_transferir @grupo= 'TF_OPE' ,@sub_grupo='Estimaciones', @tabla = 'TF_VtaCTraFactura'
COMMIT TRAN

SELECT 'FIN'
SELECT * FROM sincroniza.dbo.transfer_estatus WHERE grupo = 'TF_OPE' AND sub_grupo = 'Estimaciones' AND tabla = 'TF_VtaCTraFactura' 


SELECT * FROM sincroniza.dbo.transfer_campos WHERE tabla = 'TF_VtaCTraFactura'
 --insert into  Ventas.VtaSch.VtaCTraFactura ( ClaTransportista,IdViaje,getdate(),ClaMoneda,IdFacturaAlfanumerico,KilosSurtidos,ClaCiudad,IdFabricacion,ClaOrganizacion,TipoFlete,ObsJefeEmb,ClaCliente,IdFactura,FechaFactura,ClaConsignado,ClaUbicacion ) 
 --select ClaTransportista,IdViaje,getdate(),ClaMoneda,IdFacturaAlfanumerico,KilosSurtidos,ClaCiudad,IdFabricacion,ClaOrganizacion,TipoFlete,ObsJefeEmb,ClaCliente,IdFactura,FechaFactura,ClaConsignado,ClaUbicacion from   ##TF_OPE_Estimaciones_TF_DEAOFINET05  where upd_o_ins = 0
 
 
 
 
 --update  Ventas.VtaSch.VtaCTraFactura set ClaTransportista = b.ClaTransportista , IdViaje = b.IdViaje , FechaUltimaMod = getdate() , ClaMoneda = b.ClaMoneda , IdFacturaAlfanumerico = b.IdFacturaAlfanumerico , KilosSurtidos = b.KilosSurtidos , ClaCiudad = b.ClaCiudad , IdFabricacion = b.IdFabricacion , ClaOrganizacion = b.ClaOrganizacion , TipoFlete = b.TipoFlete , ObsJefeEmb = b.ObsJefeEmb , ClaCliente = b.ClaCliente , FechaFactura = b.FechaFactura , ClaConsignado = b.ClaConsignado , ClaUbicacion = b.ClaUbicacion from   Ventas.VtaSch.VtaCTraFactura a ,          ##TF_OPE_Estimaciones_TF_DEAOFINET05 b   where upd_o_ins = 1 and  a.IdFactura = b.IdFactura