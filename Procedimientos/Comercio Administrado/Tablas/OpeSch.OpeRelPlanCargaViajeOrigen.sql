USE Operacion
GO

USE [Operacion]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [OpeSch].[OpeRelPlanCargaViajeOrigen](
	[ClaUbicacion] [int] NOT NULL,
	[IdPlanCargaViaje] [int] NOT NULL,
	[IdPlanCarga] [int] NOT NULL,
	[ClaUbicacionOrigen] [int] NOT NULL,
	[IdViajeOrigen]  [int] NOT NULL,
	[Placa] [varchar](12) NOT NULL,
	[PlacaOrigen] [varchar](12) NOT NULL,
	[EsRecepTraspaso] [tinyint],
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
 CONSTRAINT [PK_RelPlanCargaViaje] PRIMARY KEY CLUSTERED 
(
	[IdPlanCargaViaje] ASC,
	[ClaUbicacion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaViajeOrigen] ADD  DEFAULT ((0)) FOR [BajaLogica]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaViajeOrigen] ADD  DEFAULT (GETDATE()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaViajeOrigen] ADD  DEFAULT (HOST_NAME()) FOR [NombrePcMod]
GO
