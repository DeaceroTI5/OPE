USE [Operacion]
GO

/****** Object:  Table [AGSch].[AgTraSolicitudTraspasoDet]    Script Date: 27/07/2022 04:15:53 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [AGSch].[AgTraSolicitudTraspasoDet](
	[IdSolicitudTraspaso] [int] NOT NULL,
	[ClaProducto] [int] NOT NULL,
	[IdRenglon] [int] NOT NULL,
	[CantidadPedida] [numeric](22, 4) NULL,
	[FechaUltimaMod] [datetime] NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](60) NULL,
	[ClaEstatus] [int] NULL,
	[ClaMotivoRechazo] [int] NULL,
	[ClaMotivoAutomatico] [int] NULL,
	[Existencia] [float] NULL,
	[Transito] [float] NULL,
	[PorEmbarcar] [float] NULL,
	[Deuda] [float] NULL,
	[PoliticaInv] [float] NULL,
 CONSTRAINT [PK_AgTraSolicitudTraspasoDet] PRIMARY KEY CLUSTERED 
(
	[IdSolicitudTraspaso] ASC,
	[ClaProducto] ASC,
	[IdRenglon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


