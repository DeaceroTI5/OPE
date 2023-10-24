USE [Operacion]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [OpeSch].[OpeCtsCatProyectoASA](
	[ClaProyectoAsa] [int] NOT NULL,
	[ClaveProyectoaSa] [varchar](100)  NULL,
	[NomProyectoaSa] [varchar](255)  NULL,
	[Cliente] [varchar](100)  NULL,
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
 CONSTRAINT [PK_OpeCtsCatProyectoASA] PRIMARY KEY CLUSTERED 
(
	[ClaProyectoAsa] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



CREATE VIEW OpeSch.OpeCtsCatProyectoASAVw
AS
SELECT 
		  ClaProyectoAsa
		, ClaveProyectoaSa
		, NomProyectoaSa
		, Cliente
		, BajaLogica
		, FechaBajaLogica
		, FechaUltimaMod
		, ClaUsuarioMod
		, NombrePcMod
FROM	OpeSch.OpeCtsCatProyectoASA WITH(NOLOCK)