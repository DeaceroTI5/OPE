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

CREATE TABLE [OpeSch].[OpeRelPlanCargaViajeOrigenDet](
	[ClaUbicacion] [int] NOT NULL,
	[IdPlanCargaViaje] [int] NOT NULL,
	[IdPlanCargaViajeDet] [int] NOT NULL,
	[IdPlanCarga] [int] NOT NULL,
	[ClaUbicacionOrigen] [int] NOT NULL,
	[IdViajeOrigen] [int] NOT NULL,
	[IdFabricacion] [int] NOT NULL,
	[IdFabricacionDet] [int] NOT NULL,
	[ClaArticulo] [int] NOT NULL,
	[CantRemisionada] [NUMERIC](22,4) NOT NULL,
	[PesoRemisionado] [NUMERIC](22,4) NOT NULL,
	[PesoTaraRemisionado] [NUMERIC](22,4) NOT NULL,
	[CantRecibida] [NUMERIC](22,4) NOT NULL,
	[PesoRecibido] [NUMERIC](22,4) NOT NULL,
	[CantDocumentada] [NUMERIC](22,4) NOT NULL,
	[PesoDocumentado] [NUMERIC](22,4) NOT NULL,
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
 CONSTRAINT [PK_RelPlanCargaViajeDet] PRIMARY KEY CLUSTERED 
(
	[IdPlanCargaViaje] ASC,
	[ClaUbicacion] ASC,
	[IdPlanCargaViajeDet] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaViajeOrigenDet] ADD  DEFAULT ((0)) FOR [BajaLogica]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaViajeOrigenDet] ADD  DEFAULT (GETDATE()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaViajeOrigenDet] ADD  DEFAULT (HOST_NAME()) FOR [NombrePcMod]
GO
