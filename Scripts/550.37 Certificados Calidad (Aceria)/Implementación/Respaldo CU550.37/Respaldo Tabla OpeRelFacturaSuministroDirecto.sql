USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelFacturaSuministroDirecto]    Script Date: 10/07/2023 10:22:39 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelFacturaSuministroDirecto](
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
	[ArchivoCertificado] [varbinary](max) NULL,
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](50) NULL,
	[FechaUltimaMod] [datetime] NULL,
	[NumError] [int] NULL,
 CONSTRAINT [PK_OpeRelFacturaSuministroDirecto] PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[NumFacturaFilial] ASC,
	[IdFacturaFilial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeRelFacturaSuministroDirecto] ADD  DEFAULT ((0)) FOR [BajaLogica]
GO

ALTER TABLE [OpeSch].[OpeRelFacturaSuministroDirecto] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO

ALTER TABLE [OpeSch].[OpeRelFacturaSuministroDirecto] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO


