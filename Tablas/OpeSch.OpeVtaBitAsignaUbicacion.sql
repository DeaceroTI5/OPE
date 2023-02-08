USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeVtaBitAsignaUbicacion]    Script Date: 03/02/2023 08:59:25 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeVtaBitAsignaUbicacion](
	[IdAsignaUbicacion] [int] NOT NULL,
	[IdFabricacion] [int] NULL,
	[ClaUbicacionSurte][int] NULL,
	[FechaDesea][datetime] NULL,
	[ClaConsignado][int] NULL,
	[AutorizadaSN] [smallint] NULL,
	[ClaMotivoRechazo] [int] NULL,
	[NombrePcMod] [varchar](64) NULL,
	[ClaUsuarioMod] [int] NULL,
	[EsActualiza][tinyint]NULL,
	[MensajeError] [varchar](1000) NULL,
	[FechaUltimaMod] [datetime] NULL,
 CONSTRAINT [PK_OpeVtaBitAsignaUbicacion] PRIMARY KEY CLUSTERED 
(
	[IdAsignaUbicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


