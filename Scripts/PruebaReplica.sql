CREATE TABLE #tablaOriginal (Col1 int, Col2 VARCHAR(1), Fecha DATE);
GO
CREATE TABLE #TablaReplica (Col1 int, Col2 VARCHAR(1), Fecha DATE);
GO
CREATE TABLE #Eliminar (Col1 INT)
---- Original
INSERT INTO #tablaOriginal VALUES (1,'X','20221108');
INSERT INTO #tablaOriginal VALUES (2,'Y','20221108');
INSERT INTO #tablaOriginal VALUES (3,'V','20221109'); -- Modificación
INSERT INTO #tablaOriginal VALUES (5,'A','20221110'); -- Alta


--- Replica
INSERT INTO #TablaReplica VALUES (1,'X','20221108');
INSERT INTO #TablaReplica VALUES (2,'Y','20221108');
INSERT INTO #TablaReplica VALUES (3,'Z','20221108');
INSERT INTO #TablaReplica VALUES (4,'H','20221109');	-- Eliminado

	SELECT ''AS'Antes',* FROM #TablaReplica
	
	--Bajas
	INSERT INTO #Eliminar
	SELECT	a.Col1
	FROM	#TablaReplica a
	LEFT JOIN #tablaOriginal b
	ON	a.Col1 = b.Col1
	WHERE b.Col1 IS NULL

	--SELECT * FROM #Eliminar

	DELETE
	FROM	#TablaReplica WITH(ROWLOCK)
	WHERE	EXISTS (
			SELECT 1
			FROM	#Eliminar b
			WHERE	Col1 = b.Col1	
	)			   
			   

	-- Cambios
	UPDATE	a
	SET		 Col2 = b.Col2
			,Fecha = b.Fecha 
	FROM	#TablaReplica a
	INNER JOIN #tablaOriginal b
	ON	a.Col1 = b.Col1
	WHERE (a.Fecha <> b.Fecha
	OR		a.Col2 < b.Col2)

	-- Altas
	INSERT INTO #TablaReplica
	SELECT	a.* 
	FROM	#tablaOriginal a
	LEFT JOIN #TablaReplica b
	ON	a.Col1 = b.Col1
	WHERE b.Col1 IS NULL


	SELECT * FROM #TablaReplica


	DROP TABLE #tablaOriginal, #TablaReplica, #Eliminar