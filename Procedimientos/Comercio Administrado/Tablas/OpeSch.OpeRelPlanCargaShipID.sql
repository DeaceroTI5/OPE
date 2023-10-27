USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelPlanCargaShipID]    Script Date: 25/10/2023 04:46:21 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OpeSch].[OpeRelPlanCargaShipID](
	[ClaUbicacion] [int] NOT NULL,
	[IdPlanCarga] [int] NOT NULL,
	[IdViaje] [int] NULL,
	[ShipId] [varchar](30) NOT NULL,
	[ClaUsuarioMod] [int] NULL,
	[NombrePcMod] [varchar](65) NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdPlanCarga] ASC,
	[ShipId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IndexOpeRelPlanCargaShipIDII] UNIQUE NONCLUSTERED 
(
	[ClaUbicacion] ASC,
	[ShipId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaShipID] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO

ALTER TABLE [OpeSch].[OpeRelPlanCargaShipID] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO


