Sistema de Gestión de Empleados — Aplicación Web

Descripción General

Aplicación web desarrollada en Python utilizando el microframework Flask para la gestión de registros de empleados en una base de datos Microsoft SQL Server. Se implementa autenticación de usuarios, operaciones CRUD sobre empleados, y administración de movimientos asociados.

La comunicación con la base de datos se realiza mediante la biblioteca pyodbc utilizando procedimientos almacenados.

Dependencias del Sistema

Python 3.x

Flask

pyodbc

ODBC Driver 17 for SQL Server

Instalación de dependencias:

pip install Flask pyodbc

Instrucciones de Implementación

Clonar o extraer el proyecto en el entorno local.

Ingresar al directorio del proyecto.

Instalar dependencias mediante:

pip install -r requirements.txt

Configurar las credenciales de conexión a la base de datos en app.py.

Ejecutar el servidor Flask:

flask run

Acceder a la URL local:

http://127.0.0.1:5000

Arquitectura del Proyecto

proyecto_web/
├── app.py                  # Aplicación Flask (lógica de negocio y rutas)
├── requirements.txt         # Listado de dependencias de Python
├── static/
│   └── style.css            # Estilos CSS para frontend
├── templates/
│   ├── index.html           # Dashboard principal
│   ├── login.html           # Interfaz de autenticación de usuarios
│   ├── listar_empleados.html # Visualización de empleados activos
│   └── consultar_empleado.html # Consulta de datos y movimientos de empleados

Detalles Técnicos

Gestión de sesiones a través de Flask-Session nativo.

Conexiones a la base de datos mediante pyodbc y ejecución de procedimientos almacenados.

Manejo básico de errores y validaciones de respuesta.

Separación de capas: lógica de negocio (Python) y presentación (HTML con Jinja2).

Interfaz responsive básica utilizando CSS personalizado.

Notas

Las credenciales de acceso a la base de datos deben mantenerse en entornos seguros.

Para despliegue en producción, se recomienda configurar un servidor WSGI como Gunicorn o uWSGI y aplicar HTTPS.

Documento técnico generado para fines de implementación y despliegue.
