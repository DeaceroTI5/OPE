
    DECLARE
        @psNombreJob                VARCHAR(500),
        @psSubSistema               VARCHAR(60),
        @psComando                  VARCHAR(8000),
		@sCmd						VARCHAR(100)

    SELECT
        @psNombreJob    = 'xp_cmdshell replacement',
        @psSubSistema   = 'TSQL',
		@sCmd			= 'dir \\deapatnet03\Docvtas\'

   	SELECT @sCmd = @sCmd + ' /b | find "' + 'DC21371' + '"'

	SELECT   @psComando		=  'DECLARE @sCmd VARCHAR(8000) = ''' + @sCmd + ''' ' +
							'TRUNCATE TABLE [OpeSch].[OpeTraSalidaComandoCmdShellProcess] ' + 
							'INSERT	INTO [OpeSch].[OpeTraSalidaComandoCmdShellProcess] ( SalidaComando ) ' + 
							'EXEC	master.dbo.xp_cmdshell @sCmd'

    SET NOCOUNT ON

    DECLARE @job NVARCHAR(100) ;
    SET @job = @psNombreJob + ' - ' + CONVERT(NVARCHAR, GETDATE(), 121) ; 

    EXECUTE AS LOGIN = 'SpJobUser';

    EXEC msdb..sp_add_job @job_name = @job,
        @description = 'Automated job to execute command shell script',
        @owner_login_name = 'sa', @delete_level = 1 ; 
    EXEC msdb..sp_add_jobstep @job_name = @job, @step_id = 1,
        @step_name = 'Command Shell Execution', @subsystem = @psSubSistema,
        @command = @psComando, @database_name = 'Operacion',
        @on_success_action = 1 ;
    EXEC msdb..sp_add_jobserver @job_name = @job ; 
    EXEC msdb..sp_start_job @job_name = @job ; 

	SELECT * FROM	msdb.dbo.sysjobs J 	WHERE J.name =  @job
    REVERT;

	DECLARE @nCont INT = 0
	WHILE @nCont < 10
	BEGIN
		IF EXISTS(
			SELECT 1 
			FROM	msdb.dbo.sysjobs J 
			INNER JOIN msdb.dbo.sysjobactivity A 
			ON		A.job_id=J.job_id 
			WHERE J.name =  @job
			AND		A.run_requested_date IS NOT NULL 
			AND		A.stop_execution_date IS NULL
		)
		BEGIN /*Está en ejecución*/
			SELECT @nCont AS Cont, @job as '@job'
			WAITFOR DELAY '00:00:01'
		END
		ELSE
		BEGIN	/*NO está en ejecución*/
			SELECT 'Finalizó'
			GOTO FIN
		END
		SELECT @nCont = @nCont + 1
	END

	FIN:

	SELECT * FROM OpeSch.OpeTraSalidaComandoCmdShellProcess WITH(NOLOCK)


    SET NOCOUNT OFF
