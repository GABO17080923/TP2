
-- =============================================
-- SP: SP_ObtenerError
-- Descripción: Devuelve la descripción de error por código
-- =============================================


CREATE PROCEDURE dbo.SP_ObtenerError
    @inCodigoError INT,
    @outDescripcion TEXT OUTPUT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT @outDescripcion = E.Descripcion
        FROM dbo.Error AS E
        WHERE E.Codigo = @inCodigoError;

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

        SET @outResultCode = 50008; -- Error de base de datos
        SET @outDescripcion = 'Error al obtener descripción';
    END CATCH;

    SET NOCOUNT OFF;
END;
