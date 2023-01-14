CREATE VIEW OpeSch.OpeTiCatUbicacionIngetekVw
AS
	SELECT    a.ClaUbicacion
			, a.NomUbicacion
			, a.BajaLogica
	FROM	OpeSch.OpeTiCatUbicacionVw a
	WHERE	ClaUbicacion IN (277, 278, 364)
	UNION
	SELECT    a.ClaUbicacion
			, a.NomUbicacion
			, a.BajaLogica
	FROM	OpeSch.OpeTiCatUbicacionVw a
	WHERE	ClaEmpresa	= 52

