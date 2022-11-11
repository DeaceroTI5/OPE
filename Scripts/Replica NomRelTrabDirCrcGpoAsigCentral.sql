DECLARE @tbNomRelTrabDirCrcGpoAsigCentral TABLE (
	  Id				INT IDENTITY(1,1)
	, ClaTrabajadorEUN	INT				
	, ClallaveEUN		INT			
	, ClaDireccion		VARCHAR(4)		
	, ClaCrc			INT			
	, PtjeCRC			NUMERIC(22,4)
	, EsDefault			INT				
	, BajaLogica		TINYINT		
	, FechaBajaLogica	DATETIME	
	, FechaUltimaMod	DATETIME	
	, ClaUsuarioMod		INT				
	, NombrePcMod		VARCHAR(64)	
)

DECLARE @tbEliminar TABLE (
	  Id				INT IDENTITY(1,1)
	, ClaTrabajadorEUN	INT 
	, ClaDireccion		VARCHAR(4) 
	, ClaCrc			INT		
)

---/*Universo*/
INSERT INTO @tbNomRelTrabDirCrcGpoAsigCentral(
		  ClaTrabajadorEUN
		, ClallaveEUN
		, ClaDireccion
		, ClaCrc
		, PtjeCRC
		, EsDefault
		, BajaLogica
		, FechaBajaLogica
		, FechaUltimaMod
		, ClaUsuarioMod
		, NombrePcMod 		
)
SELECT	  ClaTrabajadorEUN
		, ClallaveEUN
		, ClaDireccion
		, ClaCrc
		, PtjeCRC
		, EsDefault
		, BajaLogica
		, FechaBajaLogica
		, FechaUltimaMod
		, ClaUsuarioMod
		, NombrePcMod 
FROM	TICentral.TiCatalogo.dbo.NomRelTrabDirCrcGpoAsigCentral  WITH(NOLOCK) -- ClaTrabajadorEUN, ClaDireccion, ClaCrc


--- ELIMINA 
INSERT INTO @tbEliminar
SELECT	  a.ClaTrabajadorEUN	
		, a.ClaDireccion		
		, a.ClaCrc			
FROM	TiCatalogo.dbo.NomRelTrabDirCrcGpoAsigCentral a WITH(NOLOCK) -- ClaTrabajadorEUN, ClaDireccion, ClaCrc
LEFT JOIN @tbNomRelTrabDirCrcGpoAsigCentral b
ON		a.ClaTrabajadorEUN	= b.ClaTrabajadorEUN
AND		a.ClaDireccion		= b.ClaDireccion
AND		a.ClaCrc			= b.ClaCrc
WHERE	b.ClallaveEUN IS NULL



DELETE
FROM	TiCatalogo.dbo.NomRelTrabDirCrcGpoAsigCentral WITH(ROWLOCK)
WHERE	EXISTS (
		SELECT	1
		FROM	@tbEliminar b
		WHERE	ClaTrabajadorEUN	= b.ClaTrabajadorEUN
		AND		ClaDireccion		= b.ClaDireccion
		AND		ClaCrc				= b.ClaCrc	
)

--- ACTUALIZA 
UPDATE	a
SET		  ClallaveEUN	= b.ClallaveEUN
		, PtjeCRC		= b.PtjeCRC
		, EsDefault		= b.EsDefault
		, FechaUltimaMod= b.FechaUltimaMod
		, ClaUsuarioMod	= b.ClaUsuarioMod
		, NombrePcMod	= b.NombrePcMod 
FROM	TiCatalogo.dbo.NomRelTrabDirCrcGpoAsigCentral a WITH(NOLOCK) -- ClaTrabajadorEUN, ClaDireccion, ClaCrc
INNER JOIN @tbNomRelTrabDirCrcGpoAsigCentral b
ON		a.ClaTrabajadorEUN	= b.ClaTrabajadorEUN
AND		a.ClaDireccion		= b.ClaDireccion
AND		a.ClaCrc			= b.ClaCrc
WHERE	(a.ClallaveEUN	<> b.ClallaveEUN
OR		a.PtjeCRC		<> b.PtjeCRC
OR		a.EsDefault		<> b.EsDefault
OR		a.FechaUltimaMod<> b.FechaUltimaMod
OR		a.ClaUsuarioMod	<> b.ClaUsuarioMod
OR		a.NombrePcMod	<> b.NombrePcMod)


--- INSERT Registros Nuevos
INSERT INTO dbo.NomRelTrabDirCrcGpoAsigCentral(
	  ClaTrabajadorEUN
	, ClallaveEUN
	, ClaDireccion
	, ClaCrc
	, PtjeCRC
	, EsDefault
	, BajaLogica
	, FechaBajaLogica
	, FechaUltimaMod
	, ClaUsuarioMod
	, NombrePcMod		
)
SELECT	  a.ClaTrabajadorEUN
		, a.ClallaveEUN
		, a.ClaDireccion
		, a.ClaCrc
		, a.PtjeCRC
		, a.EsDefault
		, a.BajaLogica
		, a.FechaBajaLogica
		, a.FechaUltimaMod
		, a.ClaUsuarioMod
		, a.NombrePcMod
FROM	@tbNomRelTrabDirCrcGpoAsigCentral a 
LEFT JOIN TiCatalogo.dbo.NomRelTrabDirCrcGpoAsigCentral  b
ON		a.ClaTrabajadorEUN	= b.ClaTrabajadorEUN
AND		a.ClaDireccion		= b.ClaDireccion
AND		a.ClaCrc			= b.ClaCrc
WHERE	b.ClaTrabajadorEUN IS NULL
