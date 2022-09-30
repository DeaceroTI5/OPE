	BULK INSERT OpeSch.OpeTraAcumuladoDeExistTmp
		FROM '\\APPALPNET03\WebSites\OPE\Nueva carpeta\tab2.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			ROWTERMINATOR ='\n'
		);