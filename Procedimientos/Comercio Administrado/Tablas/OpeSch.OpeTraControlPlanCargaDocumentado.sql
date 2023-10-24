USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeTraControlPlanCargaDocumentado]    Script Date: 13/10/2023 11:43:45 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeTraControlPlanCargaDocumentado](
	[ClaUbicacion] [int] NOT NULL,
	[IdPlanCarga] [int] NOT NULL,
	[IdFabricacion] [int] NOT NULL,
	[IdFabricacionDet] [int] NOT NULL,
	[ClaArticulo] [int] NOT NULL,
	[ClaveArticulo] [varchar](20) NULL,
	[NombreArticulo] [varchar](500) NULL,
	[CantidadEmbarcada] [numeric](22, 4) NULL,
	[PesoEmbarcado] [numeric](22, 4) NULL,
	[PesoDocumentado] [numeric](22, 4) NULL,
	[PesoDocumentadoManual] [numeric](22, 4) NULL,
	[EsManual] [int] NULL,
	[EsPartidaDocumentada] [int] NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](65) NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdPlanCarga] ASC,
	[IdFabricacion] ASC,
	[IdFabricacionDet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeTraControlPlanCargaDocumentado] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO

ALTER TABLE [OpeSch].[OpeTraControlPlanCargaDocumentado] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO


