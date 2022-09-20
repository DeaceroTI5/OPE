USE [Operacion]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [OpeSch].[OpeCatMotivoRechazoSolTraspaso](
	[ClaMotivoRechazoSolTraspaso] [int] NOT NULL,
	[NomMotivoRechazoSolTraspaso] [varchar](300) NOT NULL,
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
 CONSTRAINT [PK_OpeCatMotivoRechazoSolTraspaso] PRIMARY KEY CLUSTERED 
(
	[ClaMotivoRechazoSolTraspaso] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [OpeSch].[OpeCatMotivoRechazoSolTraspaso] ADD  DEFAULT ((0)) FOR [BajaLogica]
GO

ALTER TABLE [OpeSch].[OpeCatMotivoRechazoSolTraspaso] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OpeSch].[OpeCatMotivoRechazoSolTraspaso] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO



CREATE VIEW OpeSch.OpeCatMotivoRechazoSolTraspasoVw
AS
	SELECT
			  ClaMotivoRechazoSolTraspaso
			, NomMotivoRechazoSolTraspaso
			, BajaLogica
			, FechaBajaLogica
			, ClaUsuarioMod
			, FechaUltimaMod
			, NombrePcMod
	FROM	OpeSch.OpeCatMotivoRechazoSolTraspaso WITH(NOLOCK)