# Taller Automotriz Rápido 🚗

Bienvenido al repositorio del sistema de gestión para "Taller Automotriz Rápido", una aplicación web desarrollada en Java para la administración de servicios y mantenimientos de vehículos.

## 📌 Descripción del Proyecto
Este proyecto fue desarrollado como parte de una materia universitaria. Consiste en una plataforma web que permite gestionar los servicios mecánicos que ofrece un taller automotriz. La aplicación facilita la interacción entre los clientes y los servicios del taller, abarcando desde el mantenimiento preventivo hasta reparaciones especializadas.

### Servicios Destacados:
* Mantenimiento Preventivo
* Diagnóstico Computarizado
* Alineación y Balanceo
* Cambio de Aceite
* Reparación de Frenos
* Revisión del Sistema Eléctrico

## 🛠️ Tecnologías Utilizadas
* **Backend:** Java (Java EE, Servlets, JSP, JPA)
* **Frontend:** HTML5, CSS3, JavaScript
* **Base de Datos:** Configurada a través de un JTA Data Source (`jdbc/taller_automotriz`)
* **Entorno de Desarrollo:** Apache NetBeans IDE
* **Gestor de Construcción:** Apache Ant

## 🚀 Instalación y Despliegue
Para clonar y ejecutar este proyecto localmente, necesitas tener instalado Java JDK y un servidor de aplicaciones compatible con Java EE (como Payara Server, GlassFish o Apache Tomcat).

1. Clona este repositorio:
   ```bash
   git clone https://github.com/tu_usuario/taller-automotriz.git
   ```
2. Abre el proyecto en **Apache NetBeans**.
3. Configura el Pool de Conexiones (Connection Pool) y el Recurso JDBC (`jdbc/taller_automotriz`) en tu servidor de aplicaciones que apunte a tu base de datos local.
4. Construye y ejecuta el proyecto (`Run -> Run Project` en NetBeans).

## 🔒 Seguridad
Las credenciales de la base de datos y otras configuraciones sensibles no se encuentran en el código fuente de este repositorio por motivos de seguridad; deben configurarse a nivel del servidor de aplicaciones mediante un *Data Source*.

## ✒️ Autor
Proyecto universitario desarrollado por Cristopher Luna

