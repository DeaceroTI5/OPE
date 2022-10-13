USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelFacturasSumDirecto]    Script Date: 04/10/2022 09:39:52 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelFacturasSumDirecto](
	[ClaUbicacion] [int] NOT NULL,
	[NumFacturaFilial] [varchar](20) NOT NULL,
	[IdFacturaFilial] [int] NOT NULL,
	[ClaUbicacionOrigen] [int] NOT NULL,
	[NumFacturaOrigen] [varchar](20) NOT NULL,
	[IdFacturaOrigen] [int] NULL,
	[ClaEstatus] [tinyint] NULL,
	[MensajeError] [varchar](250) NULL,
	[IdCertificado] [int] NULL,
	[NumCertificado] [varchar](50) NULL,
	[ArchivoCertificado] [varbinary](1) NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](50) NULL,
	[FechaUltimaMod] [datetime] NULL,
 CONSTRAINT [PK_OpeRelFacturasSumDirecto] PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[NumFacturaFilial] ASC,
	[IdFacturaFilial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


