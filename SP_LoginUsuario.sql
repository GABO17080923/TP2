
-- =============================================
-- SP: SP_LoginUsuario
-- Descripción: Valida credenciales de usuario y registra en bitácora
-- =============================================
CREATE PROCEDURE dbo.SP_LoginUsuario
    @inUsername VARCHAR(50),
    @inPassword VARCHAR(100),
    @inPostInIP VARCHAR(50),
    @outIdUsuario INT OUTPUT,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @intentos INT;
    DECLARE @idUsuario INT;

    BEGIN TRY
        -- Verificar si el usuario ha sido bloqueado (más de 5 fallos en 30 mins)
        SELECT @intentos = COUNT(*)
        FROM dbo.BitacoraEvento AS B
        INNER JOIN dbo.TipoEvento AS T ON T.id = B.idTipoEvento
        INNER JOIN dbo.Usuario AS U ON U.id = B.idUsuario
        WHERE T.Nombre = 'Login No Exitoso'
          AND U.Username = @inUsername
          AND B.PostInIP = @inPostInIP
          AND B.PostTime >= DATEADD(MINUTE, -30, GETDATE());

        IF @intentos >= 5
        BEGIN
            SET @outResultCode = 50003; -- Login deshabilitado
            SET @outIdUsuario = NULL;
            RETURN;
        END;

        -- Validar usuario y contraseña
        SELECT @idUsuario = id
        FROM dbo.Usuario
        WHERE Username = @inUsername
          AND Password = @inPassword;

        IF @idUsuario IS NOT NULL
        BEGIN
            EXEC dbo.SP_RegistrarEvento
                @inIdTipoEvento = 1, -- Login Exitoso
                @inDescripcion = NULL,
                @inIdUsuario = @idUsuario,
                @inPostBy = @inUsername,
                @inPostInIP = @inPostInIP,
                @outResultCode = @outResultCode OUTPUT;

            SET @outIdUsuario = @idUsuario;
            SET @outResultCode = 0;
        END
        ELSE
        BEGIN
            -- Registrar intento fallido
            SET @outResultCode = 50002; -- Password no existe o incorrecto
            SET @outIdUsuario = NULL;

            DECLARE @idFallidoUsuario INT;
            SELECT @idFallidoUsuario = id FROM dbo.Usuario WHERE Username = @inUsername;

            IF @idFallidoUsuario IS NOT NULL
            BEGIN
                EXEC dbo.SP_RegistrarEvento
                    @inIdTipoEvento = 2, -- Login No Exitoso
                    @inDescripcion = 'Login fallido',
                    @inIdUsuario = @idFallidoUsuario,
                    @inPostBy = @inUsername,
                    @inPostInIP = @inPostInIP,
                    @outResultCode = @outResultCode OUTPUT;
            END
        END
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

        SET @outIdUsuario = NULL;
        SET @outResultCode = 50008; -- Error base de datos
    END CATCH;

    SET NOCOUNT OFF;
END;
