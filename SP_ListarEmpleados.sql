
-- ===================================================
-- SP: SP_ListarEmpleados
-- Descripción: Lista empleados con filtro por nombre o cédula
-- ===================================================
CREATE PROCEDURE dbo.SP_ListarEmpleados
    @inFiltro VARCHAR(100),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            E.id AS idEmpleado,
            E.ValorDocumentoIdentidad,
            E.Nombre,
            P.Nombre AS NombrePuesto,
            E.SaldoVacaciones,
            E.EsActivo
        FROM dbo.Empleado AS E
        INNER JOIN dbo.Puesto AS P ON E.idPuesto = P.id
        WHERE (
            @inFiltro IS NULL
            OR LTRIM(RTRIM(@inFiltro)) = ''
            OR (
                @inFiltro LIKE '%[^0-9]%' -- contiene letras
                AND E.Nombre LIKE '%' + @inFiltro + '%'
            )
            OR (
                @inFiltro NOT LIKE '%[^0-9]%' -- solo números
                AND E.ValorDocumentoIdentidad LIKE '%' + @inFiltro + '%'
            )
        )
        ORDER BY E.Nombre ASC;

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

        SET @outResultCode = 50008; -- Error general
    END CATCH;

    SET NOCOUNT OFF;
END;
