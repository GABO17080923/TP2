
-- ============================================================
-- SP: SP_ListarMovimientos
-- Descripción: Lista movimientos de un empleado, ordenados por fecha descendente
-- ============================================================
CREATE PROCEDURE dbo.SP_ListarMovimientos
    @inIdEmpleado INT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            M.Fecha,
            TM.Nombre AS TipoMovimiento,
            M.Monto,
            M.NuevoSaldo,
            U.Username AS RegistradoPor,
            M.PostInIP,
            M.PostTime
        FROM dbo.Movimiento AS M
        INNER JOIN dbo.TipoMovimiento AS TM ON M.idTipoMovimiento = TM.id
        INNER JOIN dbo.Usuario AS U ON M.idUsuario = U.id
        WHERE M.idEmpleado = @inIdEmpleado
        ORDER BY M.Fecha DESC;

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
