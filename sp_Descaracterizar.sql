USE [NomeBancoDados]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Descaracterizar]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TABELA VARCHAR(500)
		,@COLUNA VARCHAR(500)
		,@FUNCAO VARCHAR(500)
		,@PARAMETRO VARCHAR(500)
		,@SQL VARCHAR(MAX);

	DECLARE db_cursor CURSOR
	FOR
	SELECT tabela
		,coluna
		,funcao
		,parametro
	FROM NomeBancoDados..Tabelauxdesc
	WHERE id = 1

	OPEN db_cursor;

	FETCH NEXT
	FROM db_cursor
	INTO @TABELA
		,@COLUNA
		,@FUNCAO
		,@PARAMETRO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQL = ' 
DECLARE @CONTADOR BIGINT 
SET @CONTADOR = 0 
WHILE (@CONTADOR <= (SELECT COUNT (' + @COLUNA + ' ) FROM ' + @TABELA + ' )) 
BEGIN 



UPDATE A 
SET A.' + @COLUNA + ' = (SELECT ' + @FUNCAO + ' (@CONTADOR' + IIF(@PARAMETRO IS NULL, '', ', ' + @PARAMETRO) + ')) 
FROM (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1) ) AS ID,' + @COLUNA + ' FROM ' + @TABELA + ' 
)A 
WHERE A.ID = @CONTADOR 
SET @CONTADOR = @CONTADOR + 1 
END'

		EXEC (@SQL);

		PRINT (@SQL);

		FETCH NEXT
		FROM db_cursor
		INTO @TABELA
			,@COLUNA
			,@FUNCAO
			,@PARAMETRO
	END;

	CLOSE db_cursor;

	DEALLOCATE db_cursor
END;
