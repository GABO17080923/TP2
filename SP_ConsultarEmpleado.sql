
-- ============================================================
-- SP: SP_ConsultarEmpleado
-- Descripción: Devuelve los datos de un empleado específico
-- ============================================================
CREATE PROCEDURE dbo.SP_ConsultarEmpleado
    @inIdEmpleado INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            E.ValorDocumentoIdentidad,
            E.Nombre,
            P.Nombre AS NombrePuesto,
            E.SaldoVacaciones
        FROM dbo.Empleado AS E
        INNER JOIN dbo.Puesto AS P ON E.idPuesto = P.id
        WHERE E.id = @inIdEmpleado;

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

        SET @outResultCode = 50008;
    END CATCH;

    SET NOCOUNT OFF;
END;
