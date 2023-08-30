USE Operacion
GO

select *
    from OpeSch.OpeTiCatConfiguracionVw
    where claubicacion = 329
    and clasistema = 127
    and  ClaConfiguracion =1271229

update OpeSch.OpeTiCatConfiguracionVw
    set BajaLogica = 1
    where ClaUbicacion = 329
    and ClaSistema = 127
    and ClaConfiguracion = 1271229

	
update OpeSch.OpeTiCatConfiguracionVw
    set BajaLogica = 0
    where ClaUbicacion = 329
    and ClaSistema = 127
    and ClaConfiguracion = 1271229


--SELECT * FROM OpeSch.OpeticatUbicacionVw WHERE ClaUbicacion = 329