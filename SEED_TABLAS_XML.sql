
-- ============================================================
-- Script todo-en-uno: cargar datos desde XML inline
-- ============================================================

-- 1) Catalogos
DECLARE @xmlCatalogos XML = N'<Datos><Puestos><Puesto Nombre="Cajero" SalarioxHora="11.0" /><Puesto Nombre="Camarero" SalarioxHora="10.0" /><Puesto Nombre="Cuidador" SalarioxHora="13.5" /><Puesto Nombre="Conductor" SalarioxHora="15.0" /><Puesto Nombre="Asistente" SalarioxHora="11.0" /><Puesto Nombre="Recepcionista" SalarioxHora="12.0" /><Puesto Nombre="Fontanero" SalarioxHora="13.0" /><Puesto Nombre="Niñera" SalarioxHora="12.0" /><Puesto Nombre="Conserje" SalarioxHora="11.0" /><Puesto Nombre="Albañil" SalarioxHora="10.5" /></Puestos><TiposEvento><TipoEvento Id="1" Nombre="Login Exitoso" /><TipoEvento Id="2" Nombre="Login No Exitoso" /><TipoEvento Id="3" Nombre="Login deshabilitado" /><TipoEvento Id="4" Nombre="Logout" /><TipoEvento Id="5" Nombre="Insercion no exitosa" /><TipoEvento Id="6" Nombre="Insercion exitosa" /><TipoEvento Id="7" Nombre="Update no exitoso" /><TipoEvento Id="8" Nombre="Update exitoso" /><TipoEvento Id="9" Nombre="Intento de borrado" /><TipoEvento Id="10" Nombre="Borrado exitoso" /><TipoEvento Id="11" Nombre="Consulta con filtro de nombre" /><TipoEvento Id="12" Nombre="Consulta con filtro de cedula" /><TipoEvento Id="13" Nombre="Intento de insertar movimiento" /><TipoEvento Id="14" Nombre="Insertar movimiento exitoso" /></TiposEvento><TiposMovimientos><TipoMovimiento Id="1" Nombre="Cumplir mes" TipoAccion="Credito" /><TipoMovimiento Id="2" Nombre="Bono vacacional" TipoAccion="Credito" /><TipoMovimiento Id="3" Nombre="Reversion Debito" TipoAccion="Credito" /><TipoMovimiento Id="4" Nombre="Disfrute de vacaciones" TipoAccion="Debito" /><TipoMovimiento Id="5" Nombre="Venta de vacaciones" TipoAccion="Debito" /><TipoMovimiento Id="6" Nombre="Reversion de Credito" TipoAccion="Debito" /></TiposMovimientos><Error><error Codigo="50001" Descripcion="Username no existe" /><error Codigo="50002" Descripcion="Password no existe" /><error Codigo="50003" Descripcion="Login deshabilitado" /><error Codigo="50004" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en inserción" /><error Codigo="50005" Descripcion="Empleado con mismo nombre ya existe en inserción" /><error Codigo="50006" Descripcion="Empleado con ValorDocumentoIdentidad ya existe en actualización" /><error Codigo="50007" Descripcion="Empleado con mismo nombre ya existe en actualización" /><error Codigo="50008" Descripcion="Error de base de datos" /><error Codigo="50009" Descripcion="Nombre de empleado no alfabético" /><error Codigo="50010" Descripcion="Valor de documento de identidad no alfabético" /><error Codigo="50011" Descripcion="Monto del movimiento rechazado pues si se aplicar el saldo seria negativo." /></Error></Datos>';
DECLARE @hCatalogos INT;
EXEC sp_xml_preparedocument @hCatalogos OUTPUT, @xmlCatalogos;

INSERT INTO dbo.Puesto (Nombre, SalarioxHora)
SELECT Nombre, SalarioxHora
FROM OPENXML(@hCatalogos, '/Datos/Puestos/Puesto', 2)
WITH (
    Nombre VARCHAR(100) '@Nombre',
    SalarioxHora DECIMAL(10,2) '@SalarioxHora'
);

SET IDENTITY_INSERT dbo.TipoEvento ON;
INSERT INTO dbo.TipoEvento (id, Nombre)
SELECT Id, Nombre
FROM OPENXML(@hCatalogos, '/Datos/TiposEvento/TipoEvento', 2)
WITH (
    Id INT '@Id',
    Nombre VARCHAR(50) '@Nombre'
);
SET IDENTITY_INSERT dbo.TipoEvento OFF;

SET IDENTITY_INSERT dbo.TipoMovimiento ON;
INSERT INTO dbo.TipoMovimiento (id, Nombre, TipoAccion)
SELECT Id, Nombre, TipoAccion
FROM OPENXML(@hCatalogos, '/Datos/TiposMovimientos/TipoMovimiento', 2)
WITH (
    Id INT '@Id',
    Nombre VARCHAR(50) '@Nombre',
    TipoAccion VARCHAR(10) '@TipoAccion'
);
SET IDENTITY_INSERT dbo.TipoMovimiento OFF;

SET IDENTITY_INSERT dbo.Error ON;
INSERT INTO dbo.Error (id, Codigo, Descripcion)
SELECT Codigo, Codigo, Descripcion
FROM OPENXML(@hCatalogos, '/Datos/Error/error', 2)
WITH (
    Codigo INT '@Codigo',
    Descripcion TEXT '@Descripcion'
);
SET IDENTITY_INSERT dbo.Error OFF;

EXEC sp_xml_removedocument @hCatalogos;

-- 2) Usuarios
DECLARE @xmlUsuarios XML = N'<Datos><Usuarios><usuario Id="1" Nombre="UsuarioScripts" Pass="UsuarioScripts" /><usuario Id="2" Nombre="mgarrison" Pass=")*2LnSr^lk" /><usuario Id="3" Nombre="jgonzalez" Pass="3YSI0Hti&amp;I" /><usuario Id="4" Nombre="zkelly" Pass="X4US4aLam@" /><usuario Id="5" Nombre="andersondeborah" Pass="732F34xo%S" /><usuario Id="6" Nombre="hardingmicheal" Pass="himB9Dzd%_" /></Usuarios></Datos>';
DECLARE @hUsuarios INT;
EXEC sp_xml_preparedocument @hUsuarios OUTPUT, @xmlUsuarios;

SET IDENTITY_INSERT dbo.Usuario ON;
INSERT INTO dbo.Usuario (id, Username, Password)
SELECT Id, Nombre, Pass
FROM OPENXML(@hUsuarios, '/Datos/Usuarios/usuario', 2)
WITH (
    Id INT '@Id',
    Nombre VARCHAR(50) '@Nombre',
    Pass VARCHAR(100) '@Pass'
);
SET IDENTITY_INSERT dbo.Usuario OFF;

EXEC sp_xml_removedocument @hUsuarios;

-- 3) Empleados
DECLARE @xmlEmpleados XML = N'<Datos><Empleados><empleado Puesto="Cajero" ValorDocumentoIdentidad="6000194" Nombre="Kaitlyn Jensen" FechaContratacion="2020-01-10" /><empleado Puesto="Camarero" ValorDocumentoIdentidad="6001851" Nombre="Robert Buchanan" FechaContratacion="2019-07-20" /><empleado Puesto="Cuidador" ValorDocumentoIdentidad="6002665" Nombre="Christina Ward" FechaContratacion="2021-01-30" /><empleado Puesto="Conductor" ValorDocumentoIdentidad="6003528" Nombre="Bradley Wright" FechaContratacion="2019-06-29" /><empleado Puesto="Asistente" ValorDocumentoIdentidad="6004145" Nombre="Robert Singh" FechaContratacion="2018-05-30" /><empleado Puesto="Recepcionista" ValorDocumentoIdentidad="6005023" Nombre="Ryan Mitchell" FechaContratacion="2020-07-01" /><empleado Puesto="Fontanero" ValorDocumentoIdentidad="6006004" Nombre="Candace Fox" FechaContratacion="2017-01-31" /><empleado Puesto="Niñera" ValorDocumentoIdentidad="6007535" Nombre="Allison Murillo" FechaContratacion="2018-03-14" /><empleado Puesto="Conserje" ValorDocumentoIdentidad="6008129" Nombre="Jessica Murphy" FechaContratacion="2017-05-06" /><empleado Puesto="Albañil" ValorDocumentoIdentidad="6009600" Nombre="Nancy Newton PhD" FechaContratacion="2019-09-17" /></Empleados></Datos>';
DECLARE @hEmpleados INT;
EXEC sp_xml_preparedocument @hEmpleados OUTPUT, @xmlEmpleados;

INSERT INTO dbo.Empleado (
    idPuesto, ValorDocumentoIdentidad, Nombre, FechaContratacion,
    SaldoVacaciones, EsActivo, PostBy, PostInIP, PostTime
)
SELECT
    P.id,
    e.ValorDocumentoIdentidad,
    e.Nombre,
    e.FechaContratacion,
    0.0,
    1,
    'UsuarioScripts',
    '127.0.0.1',
    GETDATE()
FROM OPENXML(@hEmpleados, '/Datos/Empleados/empleado', 2)
WITH (
    Puesto VARCHAR(100) '@Puesto',
    ValorDocumentoIdentidad VARCHAR(20) '@ValorDocumentoIdentidad',
    Nombre VARCHAR(100) '@Nombre',
    FechaContratacion DATE '@FechaContratacion'
) AS e
JOIN dbo.Puesto AS P ON P.Nombre = e.Puesto;

EXEC sp_xml_removedocument @hEmpleados;

-- 4) Movimientos
DECLARE @xmlMovimientos XML = N'<Datos><Movimientos><movimiento ValorDocId="6000194" IdTipoMovimiento="Cumplir mes" Fecha="2024-06-16" Monto="3" PostByUser="hardingmicheal" PostInIP="136.103.23.170" PostTime="2024-06-16 00:00:00" /><movimiento ValorDocId="6000194" IdTipoMovimiento="Cumplir mes" Fecha="2024-02-27" Monto="5" PostByUser="zkelly" PostInIP="156.92.82.57" PostTime="2024-02-27 00:00:00" /><movimiento ValorDocId="6000194" IdTipoMovimiento="Cumplir mes" Fecha="2024-05-14" Monto="4" PostByUser="zkelly" PostInIP="218.213.110.232" PostTime="2024-05-14 00:00:00" /><movimiento ValorDocId="6001851" IdTipoMovimiento="Reversion Debito" Fecha="2024-03-03" Monto="4" PostByUser="hardingmicheal" PostInIP="218.213.110.232" PostTime="2024-03-03 00:00:00" /><movimiento ValorDocId="6001851" IdTipoMovimiento="Reversion Debito" Fecha="2024-03-07" Monto="2" PostByUser="hardingmicheal" PostInIP="156.92.82.57" PostTime="2024-03-07 00:00:00" /><movimiento ValorDocId="6001851" IdTipoMovimiento="Reversion de Credito" Fecha="2024-08-10" Monto="4" PostByUser="jgonzalez" PostInIP="218.213.110.232" PostTime="2024-08-10 00:00:00" /><movimiento ValorDocId="6002665" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-01-27" Monto="4" PostByUser="jgonzalez" PostInIP="156.92.82.57" PostTime="2024-01-27 00:00:00" /><movimiento ValorDocId="6002665" IdTipoMovimiento="Reversion Debito" Fecha="2024-04-15" Monto="3" PostByUser="mgarrison" PostInIP="150.250.94.62" PostTime="2024-04-15 00:00:00" /><movimiento ValorDocId="6003528" IdTipoMovimiento="Cumplir mes" Fecha="2024-12-16" Monto="1" PostByUser="andersondeborah" PostInIP="156.92.82.57" PostTime="2024-12-16 00:00:00" /><movimiento ValorDocId="6003528" IdTipoMovimiento="Reversion de Credito" Fecha="2024-12-16" Monto="1" PostByUser="andersondeborah" PostInIP="218.213.110.232" PostTime="2024-12-16 00:00:00" /><movimiento ValorDocId="6003528" IdTipoMovimiento="Bono vacacional" Fecha="2024-09-05" Monto="1" PostByUser="jgonzalez" PostInIP="150.250.94.62" PostTime="2024-09-05 00:00:00" /><movimiento ValorDocId="6004145" IdTipoMovimiento="Cumplir mes" Fecha="2024-09-22" Monto="1" PostByUser="jgonzalez" PostInIP="150.250.94.62" PostTime="2024-09-22 00:00:00" /><movimiento ValorDocId="6004145" IdTipoMovimiento="Reversion de Credito" Fecha="2024-08-13" Monto="3" PostByUser="andersondeborah" PostInIP="143.42.131.166" PostTime="2024-08-13 00:00:00" /><movimiento ValorDocId="6004145" IdTipoMovimiento="Bono vacacional" Fecha="2024-07-15" Monto="4" PostByUser="mgarrison" PostInIP="136.103.23.170" PostTime="2024-07-15 00:00:00" /><movimiento ValorDocId="6005023" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-10-04" Monto="1" PostByUser="andersondeborah" PostInIP="218.213.110.232" PostTime="2024-10-04 00:00:00" /><movimiento ValorDocId="6005023" IdTipoMovimiento="Bono vacacional" Fecha="2024-04-06" Monto="1" PostByUser="andersondeborah" PostInIP="218.213.110.232" PostTime="2024-04-06 00:00:00" /><movimiento ValorDocId="6006004" IdTipoMovimiento="Reversion de Credito" Fecha="2024-04-23" Monto="3" PostByUser="mgarrison" PostInIP="143.42.131.166" PostTime="2024-04-23 00:00:00" /><movimiento ValorDocId="6006004" IdTipoMovimiento="Reversion de Credito" Fecha="2024-09-13" Monto="3" PostByUser="jgonzalez" PostInIP="218.213.110.232" PostTime="2024-09-13 00:00:00" /><movimiento ValorDocId="6006004" IdTipoMovimiento="Reversion de Credito" Fecha="2024-08-15" Monto="5" PostByUser="mgarrison" PostInIP="218.213.110.232" PostTime="2024-08-15 00:00:00" /><movimiento ValorDocId="6007535" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-12-26" Monto="1" PostByUser="jgonzalez" PostInIP="143.42.131.166" PostTime="2024-12-26 00:00:00" /><movimiento ValorDocId="6007535" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-02-10" Monto="5" PostByUser="zkelly" PostInIP="136.103.23.170" PostTime="2024-02-10 00:00:00" /><movimiento ValorDocId="6008129" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-09-16" Monto="1" PostByUser="zkelly" PostInIP="143.42.131.166" PostTime="2024-09-16 00:00:00" /><movimiento ValorDocId="6008129" IdTipoMovimiento="Bono vacacional" Fecha="2024-09-28" Monto="5" PostByUser="zkelly" PostInIP="218.213.110.232" PostTime="2024-09-28 00:00:00" /><movimiento ValorDocId="6008129" IdTipoMovimiento="Disfrute de vacaciones" Fecha="2024-06-16" Monto="1" PostByUser="andersondeborah" PostInIP="156.92.82.57" PostTime="2024-06-16 00:00:00" /><movimiento ValorDocId="6009600" IdTipoMovimiento="Bono vacacional" Fecha="2024-04-27" Monto="2" PostByUser="jgonzalez" PostInIP="150.250.94.62" PostTime="2024-04-27 00:00:00" /><movimiento ValorDocId="6009600" IdTipoMovimiento="Venta de vacaciones" Fecha="2024-04-15" Monto="3" PostByUser="andersondeborah" PostInIP="156.92.82.57" PostTime="2024-04-15 00:00:00" /><movimiento ValorDocId="6009600" IdTipoMovimiento="Bono vacacional" Fecha="2024-12-08" Monto="4" PostByUser="mgarrison" PostInIP="150.250.94.62" PostTime="2024-12-08 00:00:00" /></Movimientos></Datos>';
DECLARE @hMovimientos INT;
EXEC sp_xml_preparedocument @hMovimientos OUTPUT, @xmlMovimientos;

BEGIN TRANSACTION;

INSERT INTO dbo.Movimiento (
    idEmpleado, idTipoMovimiento, Fecha, Monto,
    NuevoSaldo, idUsuario, PostBy, PostInIP, PostTime
)
SELECT
    emp.id,
    tm.id,
    m.Fecha,
    m.Monto,
    CASE 
        WHEN tm.TipoAccion = 'Credito' THEN emp.SaldoVacaciones + m.Monto
        ELSE emp.SaldoVacaciones - m.Monto
    END,
    usr.id,
    m.PostByUser,
    m.PostInIP,
    m.PostTime
FROM OPENXML(@hMovimientos, '/Datos/Movimientos/movimiento', 2)
WITH (
    ValorDocId VARCHAR(20) '@ValorDocId',
    IdTipoMovimiento VARCHAR(50) '@IdTipoMovimiento',
    Fecha DATETIME '@Fecha',
    Monto DECIMAL(5,2) '@Monto',
    PostByUser VARCHAR(50) '@PostByUser',
    PostInIP VARCHAR(50) '@PostInIP',
    PostTime DATETIME '@PostTime'
) AS m
JOIN dbo.Empleado emp ON emp.ValorDocumentoIdentidad = m.ValorDocId
JOIN dbo.TipoMovimiento tm ON tm.Nombre = m.IdTipoMovimiento
JOIN dbo.Usuario usr ON usr.Username = m.PostByUser;

-- Actualizar saldos de Empleado
UPDATE emp
SET 
    emp.SaldoVacaciones = CASE 
        WHEN tm.TipoAccion = 'Credito' THEN emp.SaldoVacaciones + m.Monto
        ELSE emp.SaldoVacaciones - m.Monto
    END,
    emp.PostBy = m.PostByUser,
    emp.PostInIP = m.PostInIP,
    emp.PostTime = m.PostTime
FROM dbo.Empleado emp
JOIN OPENXML(@hMovimientos, '/Datos/Movimientos/movimiento', 2)
WITH (
    ValorDocId VARCHAR(20) '@ValorDocId',
    IdTipoMovimiento VARCHAR(50) '@IdTipoMovimiento',
    Fecha DATETIME '@Fecha',
    Monto DECIMAL(5,2) '@Monto',
    PostByUser VARCHAR(50) '@PostByUser',
    PostInIP VARCHAR(50) '@PostInIP',
    PostTime DATETIME '@PostTime'
) AS m ON emp.ValorDocumentoIdentidad = m.ValorDocId
JOIN dbo.TipoMovimiento tm ON tm.Nombre = m.IdTipoMovimiento;

COMMIT;

EXEC sp_xml_removedocument @hMovimientos;
GO
