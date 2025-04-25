-- TABLA Puesto
CREATE TABLE dbo.Puesto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    SalarioxHora DECIMAL(10,2) NOT NULL
);

-- TABLA Usuario
CREATE TABLE dbo.Usuario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Password VARCHAR(100) NOT NULL
);

-- TABLA Empleado
CREATE TABLE dbo.Empleado (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idPuesto INT NOT NULL,
    ValorDocumentoIdentidad VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    FechaContratacion DATE NOT NULL,
    SaldoVacaciones DECIMAL(5,2) NOT NULL,
    EsActivo BIT NOT NULL,
    PostBy VARCHAR(50),
    PostInIP VARCHAR(50),
    PostTime DATETIME,
    FOREIGN KEY (idPuesto) REFERENCES dbo.Puesto(id)
);

-- TABLA TipoMovimiento
CREATE TABLE dbo.TipoMovimiento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    TipoAccion VARCHAR(10) NOT NULL
);

-- TABLA Movimiento
CREATE TABLE dbo.Movimiento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idEmpleado INT NOT NULL,
    idTipoMovimiento INT NOT NULL,
    Fecha DATETIME NOT NULL,
    Monto DECIMAL(5,2) NOT NULL,
    NuevoSaldo DECIMAL(5,2) NOT NULL,
    idUsuario INT NOT NULL,
    PostBy VARCHAR(50),
    PostInIP VARCHAR(50),
    PostTime DATETIME NOT NULL,
    FOREIGN KEY (idEmpleado) REFERENCES dbo.Empleado(id),
    FOREIGN KEY (idTipoMovimiento) REFERENCES dbo.TipoMovimiento(id),
    FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(id)
);

-- TABLA TipoEvento
CREATE TABLE dbo.TipoEvento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

-- TABLA BitacoraEvento
CREATE TABLE dbo.BitacoraEvento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idTipoEvento INT NOT NULL,
    Descripcion TEXT,
    idUsuario INT NOT NULL,
    PostBy VARCHAR(50),
    PostInIP VARCHAR(50),
    PostTime DATETIME NOT NULL,
    FOREIGN KEY (idTipoEvento) REFERENCES dbo.TipoEvento(id),
    FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(id)
);

-- TABLA DBError
CREATE TABLE dbo.DBError (
    id INT IDENTITY(1,1) PRIMARY KEY,
    UserName VARCHAR(50),
    Number INT,
    State INT,
    Severity INT,
    Line INT,
    ProcedureName VARCHAR(50),
    Message TEXT,
    DateTime DATETIME
);

-- TABLA Error
CREATE TABLE dbo.Error (
    id INT IDENTITY(1,1) PRIMARY KEY,
    Codigo INT NOT NULL,
    Descripcion TEXT
);