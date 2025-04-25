-- ============================================================
-- SP: SP_InsertarEmpleado
-- Descripci�n: Inserta un nuevo empleado con validaci�n y bit�cora
-- ============================================================
CREATE PROCEDURE dbo.SP_InsertarEmpleado
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
    DECLARE @desc VARCHAR(200); -- <- Aqu� se declara la variable para la descripci�n

    BEGIN TRY
        -- Validar que el nombre no se repita
        SELECT @existeNombre = COUNT(*)
        FROM dbo.Empleado
        WHERE Nombre = @inNombre;

        IF @existeNombre > 0
        BEGIN
            SET @outResultCode = 50005; -- Nombre duplicado
            RETURN;
        END;

        -- Validar que el documento no se repita
        SELECT @existeDocId = COUNT(*)
        FROM dbo.Empleado
        WHERE ValorDocumentoIdentidad = @inValorDocumentoIdentidad;

        IF @existeDocId > 0
        BEGIN
            SET @outResultCode = 50004; -- Documento duplicado
            RETURN;
        END;

        -- Insertar empleado
        INSERT INTO dbo.Empleado (
            idPuesto,
            ValorDocumentoIdentidad,
            Nombre,
            FechaContratacion,
            SaldoVacaciones,
            EsActivo,
            PostBy,
            PostInIP,
            PostTime
        )
        VALUES (
            @inIdPuesto,
            @inValorDocumentoIdentidad,
            @inNombre,
            GETDATE(), -- Se asume contrataci�n hoy
            0.0,
            1,
            @inPostBy,
            @inPostInIP,
            GETDATE()
        );

        -- Concatenar descripci�n para el evento
        SET @desc = @inValorDocumentoIdentidad + ' - ' + @inNombre;

        -- Registrar evento exitoso
        EXEC dbo.SP_RegistrarEvento
            @inIdTipoEvento = 6, -- Inserci�n exitosa
            @inDescripcion = @desc,
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

        SET @outResultCode = 50008; -- Error general
    END CATCH;

    SET NOCOUNT OFF;
END;
