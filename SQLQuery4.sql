
-- =============================================
-- SP: SP_RegistrarEvento
-- Descripción: Registra un evento en la bitácora de eventos
-- =============================================
CREATE PROCEDURE dbo.SP_RegistrarEvento
    @inIdTipoEvento INT,
    @inDescripcion TEXT,
    @inIdUsuario INT,
    @inPostBy VARCHAR(50),
    @inPostInIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.BitacoraEvento (
            idTipoEvento,
            Descripcion,
            idUsuario,
            PostBy,
            PostInIP,
            PostTime
        )
        VALUES (
            @inIdTipoEvento,
            @inDescripcion,
            @inIdUsuario,
            @inPostBy,
            @inPostInIP,
            GETDATE()
        );

        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.DBError (
            UserName,
            Number,
            State,
            Severity,
            Line,
            ProcedureName,
            Message,
            DateTime
        )
        VALUES (
            SYSTEM_USER,
            ERROR_NUMBER(),
            ERROR_STATE(),
            ERROR_SEVERITY(),
            ERROR_LINE(),
            ERROR_PROCEDURE(),
            ERROR_MESSAGE(),
            GETDATE()
        );

        SET @outResultCode = 50008; -- Código de error para fallo en base de datos
    END CATCH;

    SET NOCOUNT OFF;
END;
