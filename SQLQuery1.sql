CREATE TABLE Puesto (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    SalarioxHora DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Usuario (
    Id INT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Password VARCHAR(100) NOT NULL
);

CREATE TABLE Empleado (
    Id INT PRIMARY KEY,
    IdPuesto INT NOT NULL,
    ValorDocumentoIdentidad VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    FechaContratacion DATE NOT NULL,
    SaldoVacaciones DECIMAL(5, 2) NOT NULL,
    EsActivo BIT NOT NULL,
    FOREIGN KEY (IdPuesto) REFERENCES Puesto(Id)
);

CREATE TABLE TipoMovimiento (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    TipoAccion VARCHAR(10) NOT NULL
);

CREATE TABLE Movimiento (
    Id INT PRIMARY KEY,
    IdEmpleado INT NOT NULL,
    IdTipoMovimiento INT NOT NULL,
    Fecha DATETIME NOT NULL,
    Monto DECIMAL(5, 2) NOT NULL,
    NuevoSaldo DECIMAL(5, 2) NOT NULL,
    IdPostByUser INT NOT NULL,
    PostInIP VARCHAR(50),
    PostTime DATETIME NOT NULL,
    FOREIGN KEY (IdEmpleado) REFERENCES Empleado(Id),
    FOREIGN KEY (IdTipoMovimiento) REFERENCES TipoMovimiento(Id),
    FOREIGN KEY (IdPostByUser) REFERENCES Usuario(Id)
);

CREATE TABLE TipoEvento (
    Id INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE BitacoraEvento (
    Id INT PRIMARY KEY,
    IdTipoEvento INT NOT NULL,
    Descripcion TEXT,
    IdPostByUser INT NOT NULL,
    PostInIP VARCHAR(50),
    PostTime DATETIME NOT NULL,
    FOREIGN KEY (IdTipoEvento) REFERENCES TipoEvento(Id),
    FOREIGN KEY (IdPostByUser) REFERENCES Usuario(Id)
);

CREATE TABLE DBError (
    ID INT PRIMARY KEY,
    UserName VARCHAR(50),
    Number INT,
    State INT,
    Severity INT,
    Line INT,
    [Procedure] VARCHAR(50), 
    Message TEXT,
    DateTime DATETIME
);


CREATE TABLE Error (
    Id INT PRIMARY KEY,
    Codigo INT NOT NULL,
    Descripcion TEXT
);
