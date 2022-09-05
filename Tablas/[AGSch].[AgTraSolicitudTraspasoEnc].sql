USE [Operacion]
GO

/****** Object:  Table [AGSch].[AgTraSolicitudTraspasoEnc]    Script Date: 27/07/2022 04:29:09 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [AGSch].[AgTraSolicitudTraspasoEnc](
	[IdSolicitudTraspaso] [int] IDENTITY(1,1) NOT NULL,
	[ClaUbicacionSolicita] [int] NOT NULL,
	[ClaUbicacionSurte] [int] NOT NULL,
	[FechaDesea] [datetime] NULL,
	[ClaEstatus] [int] NULL,
	[Observaciones] [varchar](max) NULL,
	[ComentariosRechazo] [varchar](800) NULL,
	[ClaMotivoRechazo] [int] NULL,
	[ClaPedido] [int] NULL,
	[FechaAutorizacion] [datetime] NULL,
	[FechaIns] [datetime] NULL,
	[EsEnviadoVtas] [tinyint] NULL,
	[EsEnviadoPta] [tinyint] NULL,
	[ClaPedidoNeg] [int] NULL,
	[ClaUsuarioIns] [int] NULL,
	[FechaUltimaMod] [datetime] NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](60) NULL,
	[ClaPeticion] [int] NULL,
	[EsAceptaAntes] [tinyint] NULL,
	[EsAceptaParcial] [tinyint] NULL,
	[ClaUsuarioAprob] [int] NULL,
	[EsPorServicioExterno] [tinyint] NULL,
	[EsMaquila] [int] NULL,
	[EsConsumoInterno] [int] NULL,
	[EsPPC] [tinyint] NULL,
	[NumeroCable] [int] NULL,
	[ClaPedidoCliente] [int] NULL,
 CONSTRAINT [PK_AgTraSolicitudTraspasoEnc] PRIMARY KEY CLUSTERED 
(
	[IdSolicitudTraspaso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [AGSch].[AgTraSolicitudTraspasoEnc] ADD  DEFAULT ((0)) FOR [EsPorServicioExterno]
GO

ALTER TABLE [AGSch].[AgTraSolicitudTraspasoEnc] ADD  DEFAULT ((0)) FOR [EsMaquila]
GO


