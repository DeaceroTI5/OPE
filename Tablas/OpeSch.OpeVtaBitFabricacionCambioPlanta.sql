USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeVtaBitFabricacionCambioPlanta]    Script Date: 03/11/2022 02:25:57 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeVtaBitFabricacionCambioPlanta](
	[IdFabricacion] [int] NOT NULL,
	[NumeroRenglon] [int] NOT NULL,
	[ClaUbicacion] [int] NULL,
	[IdFabricacionNueva] [int] NULL,
	[NumeroRenglonNuevo] [int] NULL,
	[ClaUbicacionNuevo] [int] NULL,
	[IdPeticion] [int] NULL,
	[Estatus] [int] NULL,
	[FechaUltimaMod] [datetime] NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](50) NULL,
	[ClaMotivoCambio] [int] NULL,
	[ClaArticulo][int] NULL,
 CONSTRAINT [pkOpeVtaBitFabricacionCambioPlanta] PRIMARY KEY NONCLUSTERED 
(
	[IdFabricacion] ASC,
	[NumeroRenglon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


