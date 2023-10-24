USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelProyectoVtaProyectoASA]    Script Date: 13/10/2023 01:29:10 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelProyectoVtaProyectoASA](
	[ClaUbicacion] [int] NOT NULL,
	[ClaProyectoVta] [int] NOT NULL,
	[ClaProyectoAsa] [int] NOT NULL,
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
 CONSTRAINT [PK_OpeRelProyectoVtaProyectoASA_ClaUbicacion] PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[ClaProyectoVta] ASC,
	[ClaProyectoAsa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeRelProyectoVtaProyectoASA] ADD  CONSTRAINT [DF_OpeRelProyectoVtaProyectoASA_BajaLogica]  DEFAULT ((0)) FOR [BajaLogica]
GO

ALTER TABLE [OpeSch].[OpeRelProyectoVtaProyectoASA] ADD  CONSTRAINT [DF_OpeRelProyectoVtaProyectoASA_FechaUltimaMod]  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OpeSch].[OpeRelProyectoVtaProyectoASA] ADD  CONSTRAINT [DF_OpeRelProyectoVtaProyectoASA_NombrePcMod]  DEFAULT (host_name()) FOR [NombrePcMod]
GO

ALTER TABLE [OpeSch].[OpeRelProyectoVtaProyectoASA] ADD  CONSTRAINT [DF_OpeRelProyectoVtaProyectoASA_ClaUsuarioMod]  DEFAULT ((0)) FOR [ClaUsuarioMod]
GO


