-- ============================================================
-- SP: SP_EliminarEmpleado
-- Descripción: Realiza un borrado lógico de un empleado y registra en bitácora
-- ============================================================
CREATE PROCEDURE dbo.SP_EliminarEmpleado
    @inIdEmpleado INT,
    @inIdUsuario INT,
    @inPostBy VARCHAR(50),
    @inPostInIP VARCHAR(50),
    @inConfirmar BIT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @docId VARCHAR(20);
    DECLARE @nombre VARCHAR(100);
    DECLARE @nombrePuesto VARCHAR(100);
    DECLARE @saldo DECIMAL(5,2);
    DECLARE @descripcion VARCHAR(300); -- <- Variable para la descripción

    BEGIN TRY
        SELECT 
    @docId = E.ValorDocumentoIdentidad,
    @nombre = E.Nombre,
    @saldo = E.SaldoVacaciones,
    @nombrePuesto = P.Nombre
FROM dbo.Empleado AS E
INNER JOIN dbo.Puesto AS P ON P.id = E.idPuesto
WHERE E.id = @inIdEmpleado;


        SET @descripcion = @docId + ' - ' + @nombre + ', ' + @nombrePuesto + ', Saldo: ' + CAST(@saldo AS VARCHAR);

        IF @inConfirmar = 0
        BEGIN
            -- No confirmó borrado, registrar intento
            EXEC dbo.SP_RegistrarEvento
                @inIdTipoEvento = 9, -- Intento de Borrado
                @inDescripcion = @descripcion,
                @inIdUsuario = @inIdUsuario,
                @inPostBy = @inPostBy,
                @inPostInIP = @inPostInIP,
                @outResultCode = @outResultCode OUTPUT;

            SET @outResultCode = 0;
            RETURN;
        END;

        -- Confirmado: marcar como inactivo
        UPDATE dbo.Empleado
        SET EsActivo = 0,
            PostBy = @inPostBy,
            PostInIP = @inPostInIP,
            PostTime = GETDATE()
        WHERE id = @inIdEmpleado;

        -- Registrar evento exitoso
        EXEC dbo.SP_RegistrarEvento
            @inIdTipoEvento = 10, -- Borrado Exitoso
            @inDescripcion = @descripcion,
            @inIdUsuario = @inIdUsuario,
            @inPostBy = @inPostBy,
            @inPostInIP = @inPostInIP,
            @outResultCode = @outResultCode OUTPUT;

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
