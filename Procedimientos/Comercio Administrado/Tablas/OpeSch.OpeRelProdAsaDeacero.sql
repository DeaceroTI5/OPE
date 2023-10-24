USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelProdAsaDeacero]    Script Date: 13/10/2023 12:41:21 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelProdAsaDeacero](
	[IdProductKey] [int] NOT NULL,
	[ProductName] [varchar](100) NOT NULL,
	[ProductDesc] [varchar](500) NOT NULL,
	[UnidadInv] [varchar](20) NOT NULL,
	[UnidadVenta] [varchar](20) NOT NULL,
	[ClaTipoProdAsa] [int] NULL,
	[EsSubProducto] [int] NULL,
	[ClaUbicacion] [int] NULL,
	[ClaProductoPF] [int] NULL,
	[ClaEstatus] [int] NULL,
	[ClaUsuarioAsocia] [int] NULL,
	[FechaAsocia] [datetime] NULL,
	[BajaLogica] [int] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[FechaRegistro] [datetime] NULL,
	[FechaUltReplica] [datetime] NULL,
	[Idioma] [varchar](64) NOT NULL,
 CONSTRAINT [PK_OpeRelProdAsaDeacero] PRIMARY KEY CLUSTERED 
(
	[IdProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeRelProdAsaDeacero] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OpeSch].[OpeRelProdAsaDeacero] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO


