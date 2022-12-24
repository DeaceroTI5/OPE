USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelFabricacionbUnificadas]    Script Date: 16/12/2022 08:54:15 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelFabricacionbUnificadas](
	[ClaUbicacion] [int] NOT NULL,
	[IdControlUnificacion] [int] NOT NULL,
	[IdFabriacionUnificado] [int] NOT NULL,
	[IdFabricacionOriginal] [int] NOT NULL,
	[IdFabricacionEstimacion] [int] NOT NULL,
	[FechaUltimaMod] [datetime] NULL,
	[NombrePcMod] [varchar](64) NULL,
	[ClaUsuarioMod] [int] NULL
) ON [PRIMARY]
GO


