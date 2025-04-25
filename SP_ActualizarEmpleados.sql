-- ============================================================
-- SP: SP_ActualizarEmpleado
-- Descripción: Actualiza los datos de un empleado con validación y bitácora
-- ============================================================
CREATE PROCEDURE dbo.SP_ActualizarEmpleado
    @inIdEmpleado INT,
    @inValorDocumentoIdentidad VARCHAR(20),
    @inNombre VARCHAR(100),
    @inIdPuesto INT,
    @inIdUsuario INT,
    @inPostBy VARCHAR(50),
    @inPostInIP VARCHAR(50),
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @existeNombre INT;
    DECLARE @existeDocId INT;

    DECLARE @nombreAntes VARCHAR(100);
    DECLARE @docIdAntes VARCHAR(20);
    DECLARE @idPuestoAntes INT;
    DECLARE @saldoAntes DECIMAL(5,2);
    DECLARE @descripcion VARCHAR(300); -- <- Variable para descripción

    BEGIN TRY
        -- Datos anteriores
        SELECT 
            @nombreAntes = Nombre,
            @docIdAntes = ValorDocumentoIdentidad,
            @idPuestoAntes = idPuesto,
            @saldoAntes = SaldoVacaciones
        FROM dbo.Empleado
        WHERE id = @inIdEmpleado;

        -- Validar que el nuevo nombre no exista en otro registro
        SELECT @existeNombre = COUNT(*)
        FROM dbo.Empleado
        WHERE Nombre = @inNombre AND id <> @inIdEmpleado;

        IF @existeNombre > 0
        BEGIN
            SET @outResultCode = 50007; -- Nombre duplicado en actualización
            RETURN;
        END;

        -- Validar que el nuevo documento no exista en otro registro
        SELECT @existeDocId = COUNT(*)
        FROM dbo.Empleado
        WHERE ValorDocumentoIdentidad = @inValorDocumentoIdentidad AND id <> @inIdEmpleado;

        IF @existeDocId > 0
        BEGIN
            SET @outResultCode = 50006; -- Documento duplicado en actualización
            RETURN;
        END;

        -- Actualizar empleado
        UPDATE dbo.Empleado
        SET ValorDocumentoIdentidad = @inValorDocumentoIdentidad,
            Nombre = @inNombre,
            idPuesto = @inIdPuesto,
            PostBy = @inPostBy,
            PostInIP = @inPostInIP,
            PostTime = GETDATE()
        WHERE id = @inIdEmpleado;

        -- Preparar descripción del evento
        SET @descripcion = 
            'Antes: ' + @docIdAntes + ', ' + @nombreAntes + ', Puesto: ' + CAST(@idPuestoAntes AS VARCHAR) + 
            ' -> Después: ' + @inValorDocumentoIdentidad + ', ' + @inNombre + ', Puesto: ' + CAST(@inIdPuesto AS VARCHAR) + 
            ', Saldo: ' + CAST(@saldoAntes AS VARCHAR);

        -- Registrar evento exitoso
        EXEC dbo.SP_RegistrarEvento
            @inIdTipoEvento = 8, -- Update exitoso
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
