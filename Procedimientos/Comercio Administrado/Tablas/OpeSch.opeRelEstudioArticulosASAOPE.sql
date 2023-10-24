USE [Operacion]
GO


SELECT	
		  Product
		, ClaArticulo		= ISNULL(ClaArticulo,0)
		, BajaLogica		= 0
		, FechaBajaLogica	= NULL
		, FechaUltimaMod	= GETDATE()
		, NombrePcMod		= 'CargaInicial'
		, ClaUsuarioMod		= 1
INTO	#opeRelEstudioArticulosASAOPE
FROM	[OpeSch].[opeRelEstudioArticulosASAOPE]


BEGIN TRAN

DROP TABLE [OpeSch].[opeRelEstudioArticulosASAOPE]

	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	CREATE TABLE [OpeSch].[opeRelEstudioArticulosASAOPE](
		[Product] [varchar](100) NOT NULL,
		[ClaArticulo] [int] NOT NULL,
		[BajaLogica] [int] NULL,
		[FechaBajaLogica] [datetime] NULL,
		[FechaUltimaMod] [datetime] NULL,
		[NombrePcMod] [varchar](64) NULL,
		[ClaUsuarioMod] [int] NULL,
	PRIMARY KEY CLUSTERED 
	(
		[Product] ASC,
		[ClaArticulo] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
	) ON [PRIMARY]
	GO

	INSERT INTO [OpeSch].[opeRelEstudioArticulosASAOPE]
	SELECT * FROM #opeRelEstudioArticulosASAOPE

	ROLLBACK TRAN
COMMIT TRAN
