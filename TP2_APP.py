import pyodbc
import socket  # Para obtener la IP automáticamente
import os  # Para limpiar pantalla

# Datos de conexión a la base de datos
server = 'pastafari.database.windows.net'
database = 'PASTAFARI 2.0'
username = 'AdminBD@pastafari'
password = 'Bases123'
driver = '{ODBC Driver 17 for SQL Server}'

# Función para conectar a la base de datos
def conectar_db():
    conn = pyodbc.connect(
        f'DRIVER={driver};SERVER={server};PORT=1433;DATABASE={database};UID={username};PWD={password}'
    )
    return conn

# Establecer conexión inicial
conn = conectar_db()
cursor = conn.cursor()

# Obtener la IP automáticamente
def obtener_ip():
    return socket.gethostbyname(socket.gethostname())

# Variables de sesión
usuario_logueado = None
id_usuario_logueado = None
ip_actual = obtener_ip()

# Función para limpiar pantalla
def limpiar_pantalla():
    os.system('cls' if os.name == 'nt' else 'clear')

# Función para listar empleados
def listar_empleados():
    filtro = ''
    cursor.execute("EXEC dbo.SP_ListarEmpleados ?, ?", filtro, 0)
    empleados = cursor.fetchall()
    if empleados:
        # Filtrar empleados activos y ordenar por ID
        empleados_activos = [empleado for empleado in empleados if empleado.EsActivo]
        empleados_activos.sort(key=lambda e: e.idEmpleado)  # Ordenar por ID de empleado

        if empleados_activos:
            print("Lista de empleados activos:")
            print("-" * 80)
            print(f"{'ID Empleado':<15}{'Documento Identidad':<25}{'Nombre':<30}{'Puesto':<25}{'Saldo Vacaciones':<20}{'Activo'}")
            print("-" * 80)
            for empleado in empleados_activos:
                print(f"{empleado.idEmpleado:<15}{empleado.ValorDocumentoIdentidad:<25}{empleado.Nombre:<30} "
                      f"{empleado.NombrePuesto:<25}{empleado.SaldoVacaciones:<20}{'Sí' if empleado.EsActivo else 'No'}")
            print("-" * 80)
        else:
            print("No se encontraron empleados activos.")
    else:
        print("No se encontraron empleados.")


# Función para actualizar un empleado
def actualizar_empleado(id_empleado, valor_documento_identidad, nombre, id_puesto, id_usuario, post_by, post_in_ip):
    try:
        conn_local = conectar_db()
        cursor_local = conn_local.cursor()

        cursor_local.execute("""
            DECLARE @outResultCode INT;
            EXEC [dbo].[SP_ActualizarEmpleado] ?, ?, ?, ?, ?, ?, ?, @outResultCode OUTPUT;
            SELECT @outResultCode;
        """, 
        (id_empleado, valor_documento_identidad, nombre, id_puesto, id_usuario, post_by, post_in_ip))

        out_result_code = cursor_local.fetchone()[0]

        if out_result_code == 0:
            print(f"Empleado con ID {id_empleado} actualizado correctamente.")
        else:
            print(f"Error al actualizar el empleado. Código de error: {out_result_code}")

        conn_local.commit()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        conn_local.close()

# Función para insertar un empleado
def insertar_empleado(valor_documento_identidad, nombre, id_puesto, id_usuario, post_by, post_in_ip):
    try:
        cursor.execute("""
            DECLARE @outResultCode INT;
            EXEC dbo.SP_InsertarEmpleado 
                @inValorDocumentoIdentidad = ?, 
                @inNombre = ?, 
                @inIdPuesto = ?, 
                @inIdUsuario = ?, 
                @inPostBy = ?, 
                @inPostInIP = ?, 
                @outResultCode = @outResultCode OUTPUT;
            SELECT @outResultCode;
        """, valor_documento_identidad, nombre, id_puesto, id_usuario, post_by, post_in_ip)
        
        result_code = cursor.fetchone()[0]
        if result_code == 0:
            print("Empleado insertado exitosamente.")
        elif result_code == 50005:
            print("Error: Nombre duplicado.")
        elif result_code == 50004:
            print("Error: Documento duplicado.")
        else:
            print(f"Error: Código de error {result_code}")
    except Exception as e:
        print(f"Error al insertar empleado: {e}")
    finally:
        conn.commit()

# Función para eliminar un empleado
def eliminar_empleado(id_empleado, id_usuario, post_by, post_in_ip, confirmar):
    try:
        cursor.execute("""
            DECLARE @rc INT;
            EXEC dbo.SP_EliminarEmpleado 
                @inIdEmpleado = ?, 
                @inIdUsuario = ?, 
                @inPostBy = ?, 
                @inPostInIP = ?, 
                @inConfirmar = ?, 
                @outResultCode = @rc OUTPUT;
            SELECT @rc AS outResultCode;
        """, id_empleado, id_usuario, post_by, post_in_ip, int(confirmar))
        
        fila = cursor.fetchone()
        conn.commit()
        if fila:
            if fila.outResultCode == 0:
                print(f"Empleado con ID {id_empleado} eliminado exitosamente.")
            else:
                print(f"No se pudo eliminar el empleado. Código de resultado: {fila.outResultCode}")
        else:
            print("No se recibió respuesta del procedimiento almacenado.")
    except Exception as e:
        print(f"Error al eliminar empleado: {e}")

# Función para consultar un empleado y sus movimientos
def consultar_empleado(id_empleado):
    try:
        # Consultar los datos básicos del empleado
        cursor.execute("""
            DECLARE @outResultCode INT;
            EXEC dbo.SP_ConsultarEmpleado ?, @outResultCode = @outResultCode OUTPUT;
            SELECT @outResultCode;
        """, id_empleado)
        
        empleado = cursor.fetchone()
        
        if empleado and empleado.ValorDocumentoIdentidad:
            print("\nDatos del empleado:")
            print("=" * 60)
            print(f"Documento de Identidad : {empleado.ValorDocumentoIdentidad}")
            print(f"Nombre                  : {empleado.Nombre}")
            print(f"Puesto                  : {empleado.NombrePuesto}")
            print(f"Saldo Vacaciones        : {empleado.SaldoVacaciones}")
            print("=" * 60)

            # Listar los movimientos del empleado
            cursor.nextset()  # Saltar al siguiente conjunto de resultados
            cursor.execute("EXEC dbo.SP_ListarMovimientos ?, ?", id_empleado, 0)
            movimientos = cursor.fetchall()

            if movimientos:
                print(f"\nLista de movimientos del empleado ID: {id_empleado}")
                print("=" * 120)
                print(f"{'Fecha y Hora':<25}{'Tipo Movimiento':<30}{'Monto':<15}{'Nuevo Saldo':<20}{'Registrado Por':<25}{'IP':<20}")
                print("=" * 120)
                
                for movimiento in movimientos:
                    print(f"{str(movimiento.Fecha):<25}{str(movimiento.TipoMovimiento):<30}{movimiento.Monto:<15} "
                          f"{movimiento.NuevoSaldo:<20}{movimiento.RegistradoPor:<25}{movimiento.PostInIP:<20}")
                
                print("=" * 120)
            else:
                print("No se encontraron movimientos para este empleado.")
        else:
            print("Empleado no encontrado.")
    except Exception as e:
        print(f"Error al consultar empleado: {e}")

# Función para listar movimientos de un empleado
def listar_movimientos(id_empleado):
    cursor.execute("EXEC dbo.SP_ListarMovimientos ?, ?", id_empleado, 0)
    movimientos = cursor.fetchall()
    if movimientos:
        print(f"Lista de movimientos del empleado ID: {id_empleado}")
        for movimiento in movimientos:
            print(f"{str(movimiento.Fecha):<25}{str(movimiento.TipoMovimiento):<30}{movimiento.Monto:<15} "
                  f"{movimiento.NuevoSaldo:<20}{movimiento.RegistradoPor:<25}{movimiento.PostInIP:<20}")
    else:
        print(f"No se encontraron movimientos para el empleado ID {id_empleado}.")

# Función para insertar un movimiento
def insertar_movimiento(id_empleado, id_tipo_movimiento, monto, id_usuario, post_by, post_in_ip):
    try:
        cursor.execute("""
            DECLARE @outResultCode INT;
            EXEC dbo.SP_InsertarMovimiento ?, ?, ?, ?, ?, ?, @outResultCode OUTPUT;
            SELECT @outResultCode;
        """, id_empleado, id_tipo_movimiento, monto, id_usuario, post_by, post_in_ip)

        out_result_code = cursor.fetchone()[0]

        if out_result_code == 0:
            print("✅ Movimiento insertado correctamente.")
        elif out_result_code == 50011:
            print("⚠️ Error: Saldo insuficiente para realizar el movimiento.")
        elif out_result_code == 50008:
            print("❌ Error interno al insertar el movimiento. Se registró en DBError.")
        else:
            print(f"❓ Error desconocido. Código de resultado: {out_result_code}")

        conn.commit()

    except Exception as e:
        print(f"❌ Excepción al intentar insertar movimiento: {e}")

# Función de Login
def login_usuario():
    global usuario_logueado, id_usuario_logueado
    print("\n===== LOGIN =====")
    username = input("Usuario: ")
    password = input("Contraseña: ")

    try:
        conn_local = conectar_db()
        cursor_local = conn_local.cursor()

        cursor_local.execute("""
            DECLARE @outIdUsuario INT, @outResultCode INT;
            EXEC dbo.SP_LoginUsuario ?, ?, ?, @outIdUsuario OUTPUT, @outResultCode OUTPUT;
            SELECT @outIdUsuario, @outResultCode;
        """, username, password, ip_actual)

        resultado = cursor_local.fetchone()

        if resultado:
            out_id_usuario, out_result_code = resultado
            if out_result_code == 0:
                usuario_logueado = username
                id_usuario_logueado = out_id_usuario
                print(f"✅ Bienvenido, {usuario_logueado}!")
            elif out_result_code == 50002:
                print("❌ Usuario o contraseña incorrectos.")
            elif out_result_code == 50003:
                print("🚫 Usuario bloqueado por múltiples intentos fallidos.")
            else:
                print(f"⚠️ Error desconocido. Código: {out_result_code}")
        else:
            print("❌ No se pudo procesar el login.")
        
    except Exception as e:
        print(f"❌ Error al intentar login: {e}")
    finally:
        conn_local.close()

# Función de Logout
def logout_usuario():
    global usuario_logueado, id_usuario_logueado
    usuario_logueado = None
    id_usuario_logueado = None
    print("🔒 Sesión cerrada correctamente.")

# Menú principal
def menu():
    global usuario_logueado, id_usuario_logueado
    while True:
        if not usuario_logueado:
            login_usuario()
            if not usuario_logueado:
                continue  # Si no se loguea correctamente, vuelve a intentar
        print("\nMenú de opciones:")
        print("1. Listar empleados")
        print("2. Insertar empleado")
        print("3. Actualizar empleado")
        print("4. Eliminar empleado")
        print("5. Consultar empleado")
        print("6. Listar movimientos")
        print("7. Insertar movimiento")
        print("8. Logout")
        print("9. Salir")
        opcion = input("Elige una opción: ")
        limpiar_pantalla()
        if opcion == '1':
            listar_empleados()
        elif opcion == '2':
            valor_documento_identidad = input("Valor documento identidad: ")
            nombre = input("Nombre: ")
            id_puesto = int(input("ID puesto: "))
            post_by = usuario_logueado
            insertar_empleado(valor_documento_identidad, nombre, id_puesto, id_usuario_logueado, post_by, ip_actual)
        elif opcion == '3':
            id_empleado = int(input("ID del empleado a actualizar: "))
            valor_documento_identidad = input("Nuevo documento de identidad: ")
            nombre = input("Nuevo nombre: ")
            id_puesto = int(input("Nuevo ID puesto: "))
            post_by = usuario_logueado
            actualizar_empleado(id_empleado, valor_documento_identidad, nombre, id_puesto, id_usuario_logueado, post_by, ip_actual)
        elif opcion == '4':
            id_empleado = int(input("ID del empleado a eliminar: "))
            post_by = usuario_logueado
            confirmar = input("¿Confirmar eliminación? (s/n): ").lower() == 's'
            eliminar_empleado(id_empleado, id_usuario_logueado, post_by, ip_actual, confirmar)
        elif opcion == '5':
            id_empleado = int(input("ID del empleado a consultar: "))
            consultar_empleado(id_empleado)
        elif opcion == '6':
            id_empleado = int(input("ID del empleado para listar movimientos: "))
            listar_movimientos(id_empleado)
        elif opcion == '7':
            id_empleado = int(input("ID del empleado: "))
            id_tipo_movimiento = int(input("ID del tipo de movimiento: "))
            monto = float(input("Monto: "))
            post_by = usuario_logueado
            insertar_movimiento(id_empleado, id_tipo_movimiento, monto, id_usuario_logueado, post_by, ip_actual)
        elif opcion == '8':
            logout_usuario()
        elif opcion == '9':
            print("Saliendo...")
            break
        else:
            print("Opción no válida. Intenta de nuevo.")


# Ejecutar el menú
menu()

# Cerrar la conexión inicial
conn.close()

