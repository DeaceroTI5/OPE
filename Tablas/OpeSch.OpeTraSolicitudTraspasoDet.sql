USE Operacion
GO
CREATE TABLE OpeSch.OpeTraSolicitudTraspasoDet (
	  ClaUbicacion			INT NOT NULL
	, IdSolicitud			INT NOT NULL
	, ClaProducto			INT NOT NULL
	, IdRenglon				INT NOT NULL
	, ClaUnidad				INT NULL
	, CantidadPedida		NUMERIC(22,4) NULL
	, KilosPedidos			NUMERIC(22,4) NULL
	, CantidadSurtida		NUMERIC(22,4) NULL
	, KilosSurtidos			NUMERIC(22,4) NULL
	, PrecioLista			NUMERIC(22,4) NULL
	, ClaEstatus			INT NULL
	, ClaMotivoRechazo		INT NULL
	, BajaLogica			TINYINT NOT NULL
	, FechaBajaLogica		DATETIME NULL
	, ClaUsuarioMod			INT NOT NULL
	, FechaUltimaMod		DATETIME NOT NULL
	, NombrePcMod			VARCHAR(64) NOT NULL,
 CONSTRAINT PK_OpeTraSolicitudTraspasoDet PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdSolicitud] ASC,
	[ClaProducto] ASC,
	[IdRenglon] ASC	
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE OpeSch.OpeTraSolicitudTraspasoDet ADD  DEFAULT ((0)) FOR BajaLogica
GO

ALTER TABLE OpeSch.OpeTraSolicitudTraspasoDet ADD  DEFAULT (GETDATE()) FOR FechaUltimaMod
GO

ALTER TABLE OpeSch.OpeTraSolicitudTraspasoDet ADD  DEFAULT (HOST_NAME()) FOR NombrePcMod
GO

