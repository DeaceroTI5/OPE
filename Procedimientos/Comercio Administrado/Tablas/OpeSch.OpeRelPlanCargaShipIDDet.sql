USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelPlanCargaShipIDDet]    Script Date: 13/10/2023 11:45:07 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelPlanCargaShipIDDet](
	[ClaUbicacion] [int] NOT NULL,
	[IdPlanCarga] [int] NOT NULL,
	[IdFabricacion] [int] NOT NULL,
	[IdFabricacionDet] [int] NOT NULL,
	[ClaArticulo] [int] NOT NULL,
	[ClaveArticulo] [varchar](20) NULL,
	[NombreArticulo] [varchar](500) NULL,
	[CantidadEmbarcada] [numeric](22, 4) NULL,
	[PesoEmbarcado] [numeric](22, 4) NULL,
	[JobID] [varchar](20) NULL,
	[JobName] [varchar](500) NULL,
	[ControlCode] [varchar](20) NOT NULL,
	[OrderId] [varchar](20) NOT NULL,
	[ShipId] [varchar](20) NOT NULL,
	[ShipKey] [int] NOT NULL,
	[ShipItemAccumKey] [int] NOT NULL,
	[Product] [varchar](50) NOT NULL,
	[ProductDescription] [varchar](255) NULL,
	[ProductLongDescription] [varchar](500) NULL,
	[Diameter] [varchar](20) NULL,
	[Grade] [varchar](20) NULL,
	[WeightKgs] [numeric](22, 4) NULL,
	[DocumentedWeightKgs] [numeric](22, 4) NULL,
	[BentPieces] [numeric](22, 4) NULL,
	[BentItems] [int] NULL,
	[BentKgs] [numeric](22, 4) NULL,
	[BentLength] [numeric](22, 4) NULL,
	[StraightPieces] [numeric](22, 4) NULL,
	[StraightItems] [int] NULL,
	[StraightKgs] [numeric](22, 4) NULL,
	[StraightLength] [numeric](22, 4) NULL,
	[TotalPieces] [numeric](22, 4) NULL,
	[TotalItems] [int] NULL,
	[TotalKgs] [numeric](22, 4) NULL,
	[TotalLength] [numeric](22, 4) NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](65) NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdPlanCarga] ASC,
	[IdFabricacion] ASC,
	[IdFabricacionDet] ASC,
	[ShipId] ASC,
	[ShipItemAccumKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaShipIDDet] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaShipIDDet] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO


