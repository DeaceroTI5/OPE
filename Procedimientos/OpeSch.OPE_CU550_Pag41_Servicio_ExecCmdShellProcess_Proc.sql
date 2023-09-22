USE Operacion
GO
-- EXEC SP_HELPTEXT 'OpeSch.OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc'
GO
ALTER PROCEDURE OpeSch.OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc
    @psNombreJob				VARCHAR(500),
	@psSubSistema				VARCHAR(60),
	@psComando					VARCHAR(8000),
	@pnDebug					TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @job NVARCHAR(100) ;
	SET @job = @psNombreJob + ' - ' + CONVERT(NVARCHAR, GETDATE(), 121) ; 

    EXECUTE AS LOGIN = 'SpJobUser';

	EXEC msdb..sp_add_job @job_name = @job,
		@description = 'Automated job to execute command shell script',
		@owner_login_name = 'sa', @delete_level = 3 ;	--/*0 - do not delete job; 1 - delete when job succeeds; 2 - delete when job fails; 3 - delete when job completes*/

	EXEC msdb..sp_add_jobstep @job_name = @job, @step_id = 1,
		@step_name = 'Command Shell Execution', @subsystem = @psSubSistema,
		@command = @psComando, @database_name = 'Operacion',
		@on_success_action = 1 ; 

	EXEC msdb..sp_add_jobserver @job_name = @job ; 

	EXEC msdb..sp_start_job @job_name = @job ; 

	------------------------------
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
			IF @pnDebug = 1 BEGIN SELECT @nCont AS Cont, @job as '@job' END
			WAITFOR DELAY '00:00:01'
		END
		ELSE
		BEGIN	/*NO está en ejecución*/
			IF @pnDebug = 1 BEGIN SELECT 'Finalizó Job' END
			GOTO FIN
		END
		SELECT @nCont = @nCont + 1
	END

	----------------------------------------------------
	IF EXISTS(
		SELECT 1 
		FROM	msdb.dbo.sysjobs J 
		WHERE J.name =  @job
	)
	BEGIN
		IF @pnDebug = 1 SELECT 'DELETE JOB'
		EXEC msdb..sp_delete_job @job_name = @job
	END
	
	FIN:
	-----------------------------------------------------
	REVERT;

	SET NOCOUNT OFF
END