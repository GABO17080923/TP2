
-- ============================================================
-- SP: SP_InsertarMovimiento
-- Descripción: Inserta un movimiento y actualiza el saldo en una transacción
-- ============================================================
CREATE PROCEDURE dbo.SP_InsertarMovimiento
    @inIdEmpleado INT,
    @inIdTipoMovimiento INT,
    @inMonto DECIMAL(5,2),
    @inIdUsuario INT,
    @inPostBy VARCHAR(50),
    @inPostInIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tipoAccion VARCHAR(10);
    DECLARE @saldoActual DECIMAL(5,2);
    DECLARE @nuevoSaldo DECIMAL(5,2);
    DECLARE @descripcionEvento VARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Obtener tipo de acción
        SELECT @tipoAccion = TipoAccion
        FROM dbo.TipoMovimiento
        WHERE id = @inIdTipoMovimiento;

        -- Obtener saldo actual
        SELECT @saldoActual = SaldoVacaciones
        FROM dbo.Empleado
        WHERE id = @inIdEmpleado;

        IF @tipoAccion = 'Credito'
            SET @nuevoSaldo = @saldoActual + @inMonto;
        ELSE IF @tipoAccion = 'Debito'
            SET @nuevoSaldo = @saldoActual - @inMonto;

        -- Validación: no permitir saldo negativo
        IF @nuevoSaldo < 0
        BEGIN
            SET @outResultCode = 50011; -- Saldo insuficiente
            ROLLBACK;
            RETURN;
        END;

        -- Insertar movimiento
        INSERT INTO dbo.Movimiento (
            idEmpleado,
            idTipoMovimiento,
            Fecha,
            Monto,
            NuevoSaldo,
            idUsuario,
            PostBy,
            PostInIP,
            PostTime
        )
        VALUES (
            @inIdEmpleado,
            @inIdTipoMovimiento,
            GETDATE(),
            @inMonto,
            @nuevoSaldo,
            @inIdUsuario,
            @inPostBy,
            @inPostInIP,
            GETDATE()
        );

        -- Actualizar saldo del empleado
        UPDATE dbo.Empleado
        SET SaldoVacaciones = @nuevoSaldo,
            PostBy = @inPostBy,
            PostInIP = @inPostInIP,
            PostTime = GETDATE()
        WHERE id = @inIdEmpleado;

        -- Registrar evento exitoso
        SELECT @descripcionEvento = E.ValorDocumentoIdentidad + ' - ' + E.Nombre + ', Nuevo Saldo: ' +
                                     CAST(@nuevoSaldo AS VARCHAR) + ', Monto: ' + CAST(@inMonto AS VARCHAR) +
                                     ', Tipo: ' + TM.Nombre
        FROM dbo.Empleado E
        JOIN dbo.TipoMovimiento TM ON TM.id = @inIdTipoMovimiento
        WHERE E.id = @inIdEmpleado;

        EXEC dbo.SP_RegistrarEvento
            @inIdTipoEvento = 14, -- Insertar movimiento exitoso
            @inDescripcion = @descripcionEvento,
            @inIdUsuario = @inIdUsuario,
            @inPostBy = @inPostBy,
            @inPostInIP = @inPostInIP,
            @outResultCode = @outResultCode OUTPUT;

        COMMIT;
        SET @outResultCode = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

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
