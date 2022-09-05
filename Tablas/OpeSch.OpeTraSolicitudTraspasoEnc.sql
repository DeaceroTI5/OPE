USE Operacion
GO
CREATE TABLE OpeSch.OpeTraSolicitudTraspasoEnc (
	  ClaUbicacion			INT NOT NULL
	, IdSolicitud			INT NOT NULL
	, IdFabricacion			INT NULL
	, ClaUbicacionPide		INT NOT NULL
	, ClaUbicacionSurte		INT NOT NULL
	, ClaProyecto			INT NULL
	, ClaCliente			INT NULL
	, ClaConsignado			INT NULL
	, FechaDesea			DATETIME NULL
	, EsAceptaAntes			TINYINT NULL
	, EsAceptaParcial		TINYINT NULL
	, EsSurtirSinExcederse	TINYINT NULL
	, EsSuministroDirecto	TINYINT NULL
	, BajaLogica			TINYINT NOT NULL
	, FechaBajaLogica		DATETIME NULL
	, ClaUsuarioMod			INT NOT NULL
	, FechaUltimaMod		DATETIME NOT NULL
	, NombrePcMod			VARCHAR(64) NOT NULL,
 CONSTRAINT PK_OpeTraSolicitudTraspasoEnc PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdSolicitud] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE OpeSch.OpeTraSolicitudTraspasoEnc ADD  DEFAULT ((0)) FOR BajaLogica
GO

ALTER TABLE OpeSch.OpeTraSolicitudTraspasoEnc ADD  DEFAULT (GETDATE()) FOR FechaUltimaMod
GO

ALTER TABLE OpeSch.OpeTraSolicitudTraspasoEnc ADD  DEFAULT (HOST_NAME()) FOR NombrePcMod
GO

