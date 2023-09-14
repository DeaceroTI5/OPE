Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [OpeSch].[OPE_CU550_Pag41_Servicio_ExecCmdShellProcess_Proc]
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
		@owner_login_name = 'sa', @delete_level = 1 ; 

	EXEC msdb..sp_add_jobstep @job_name = @job, @step_id = 1,
		@step_name = 'Command Shell Execution', @subsystem = @psSubSistema,
		@command = @psComando, @database_name = 'Operacion',
		@on_success_action = 1 ; 

	EXEC msdb..sp_add_jobserver @job_name = @job ; 

	EXEC msdb..sp_start_job @job_name = @job ; 

	REVERT;

	--IF @pnDebug = 1
	--	SELECT @job AS '@job', * FROM msdb.dbo.sysjobs J WHERE J.name = @job

	WAITFOR DELAY '00:00:10'

--	EXEC msdb..sp_delete_job @job_name = @job

	SET NOCOUNT OFF
END


Completion time: 2023-09-14T13:30:54.4410738-06:00
