USE [Operacion]
GO

/****** Object:  Table [OpeSch].[OpeRelFacturaSuministroDirecto]    Script Date: 04/07/2023 01:08:42 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Crear tabla de respaldo
CREATE TABLE [OpeSch].[OpeRelFacturaSuministroDirecto_Hv2](
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
)

--Insertar registros de respaldo
INSERT INTO [OpeSch].[OpeRelFacturaSuministroDirecto_Hv2]
SELECT	  ClaUbicacion
		, NumFacturaFilial
		, IdFacturaFilial
		, ClaUbicacionOrigen
		, NumFacturaOrigen
		, IdFacturaOrigen
		, ClaEstatus
		, MensajeError
		, IdCertificado
		, NumCertificado
		, ArchivoCertificado
		, BajaLogica
		, FechaBajaLogica
		, ClaUsuarioMod
		, NombrePcMod
		, FechaUltimaMod
		, NumError
FROM	OpeSch.OpeRelFacturaSuministroDirecto WITH(NOLOCK)

--- 
BEGIN TRAN
	DROP TABLE OpeSch.OpeRelFacturaSuministroDirecto

	SET ANSI_NULLS ON
	GO

	SET QUOTED_IDENTIFIER ON
	GO

	CREATE TABLE [OpeSch].[OpeRelFacturaSuministroDirecto](
		[ClaUbicacion] [int] NOT NULL,
		[IdRelFactura] [int] NOT NULL,
		[NumFacturaFilial] [varchar](20) NOT NULL,
		[IdFacturaFilial] [int] NOT NULL,
		[ClaUbicacionOrigen] [int] NOT NULL,
		[NumFacturaOrigen] [varchar](20) NOT NULL,
		[IdFacturaOrigen] [int] NULL,
		[ClaEstatus] [tinyint] NULL,
		[MensajeError] [varchar](250) NULL,
		[IdCertificado] [int] NULL,
		[NumCertificado] [varchar](50) NULL,
		[ClaAceriaOrigen] [int] NULL,		
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
		[IdRelFactura] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	GO

	ALTER TABLE [OpeSch].[OpeRelFacturaSuministroDirecto] ADD  DEFAULT ((0)) FOR [BajaLogica]
	GO

	ALTER TABLE [OpeSch].[OpeRelFacturaSuministroDirecto] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
	GO

	ALTER TABLE [OpeSch].[OpeRelFacturaSuministroDirecto] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
	GO

	-----------------------------------------------
	-- Regresar el respaldo
	INSERT INTO OpeSch.OpeRelFacturaSuministroDirecto(
			  ClaUbicacion
			, IdRelFactura
			, NumFacturaFilial
			, IdFacturaFilial
			, ClaUbicacionOrigen
			, NumFacturaOrigen
			, IdFacturaOrigen
			, ClaEstatus
			, MensajeError
			, IdCertificado
			, NumCertificado
			, ClaAceriaOrigen
			, ArchivoCertificado
			, BajaLogica
			, FechaBajaLogica
			, ClaUsuarioMod
			, NombrePcMod
			, FechaUltimaMod
			, NumError	
	)
	SELECT	  ClaUbicacion
			, IdRelFactura = ROW_NUMBER() OVER (PARTITION BY ClaUbicacion ORDER BY FechaUltimaMod ASC) 
			, NumFacturaFilial
			, IdFacturaFilial
			, ClaUbicacionOrigen
			, NumFacturaOrigen
			, IdFacturaOrigen
			, ClaEstatus
			, MensajeError
			, IdCertificado
			, NumCertificado
			, ClaAceriaOrigen		= NULL
			, ArchivoCertificado
			, BajaLogica
			, FechaBajaLogica
			, ClaUsuarioMod
			, NombrePcMod
			, FechaUltimaMod
			, NumError
	FROM	OpeSch.OpeRelFacturaSuministroDirecto_Hv2 WITH(NOLOCK)

	UPDATE	a
			SET ClaAceriaOrigen = b.ClaUbicacionOrigen
	FROM	OpeSch.OpeRelFacturaSuministroDirecto a WITH(NOLOCK)
	INNER JOIN DEAOFINET04.Operacion.ACESch.AceTraCertificado b WITH(NOLOCK)
	ON		a.ClaUbicacion		= b.ClaUbicacion
	AND		a.IdCertificado		= b.IdCertificado
	WHERE	a.IdCertificado IS NOT NULL


COMMIT TRAN

		
