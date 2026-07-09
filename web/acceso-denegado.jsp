<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Usuarios" %>
<%
    Usuarios usuario = (Usuarios) session.getAttribute("usuario");
    Integer idRol = (Integer) session.getAttribute("idRol");
    String nombreUsuario = (String) session.getAttribute("nombreUsuario");
    String rol = (String) session.getAttribute("rol");
    
    // Determinar el tema basado en el rol del usuario
    String tema = "admin-theme"; // Por defecto
    if (idRol != null) {
        switch (idRol) {
            case 1: tema = "admin-theme"; break;
            case 2: tema = "mecanico-theme"; break;
            case 3: tema = "recepcion-theme"; break;
            case 4: tema = "cliente-theme"; break;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso Denegado - Taller Automotriz Rápido</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles.css">
</head>
<body>
    <!-- Skip to content para accesibilidad -->
    <a href="#main-content" class="skip-to-content">Saltar al contenido</a>

    <!-- Encabezado consistente con otras páginas -->
    <header role="banner">
        <div class="container">
            <div class="header-content">
                <a href="${pageContext.request.contextPath}/index.html" class="logo">
                    🚗 Taller Automotriz Rápido
                </a>
                <nav role="navigation" aria-label="Navegación principal">
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/index.html">Inicio</a></li>
                        <% if (usuario != null) { %>
                            <li><a href="${pageContext.request.contextPath}/logout" class="nav-btn login">Cerrar Sesión</a></li>
                        <% } else { %>
                            <li><a href="${pageContext.request.contextPath}/login.jsp" class="nav-btn login">Iniciar Sesión</a></li>
                        <% } %>
                    </ul>
                </nav>
            </div>
        </div>
    </header>

    <!-- Contenido Principal -->
    <main id="main-content">
        <div class="acceso-denegado-container">
            <div class="acceso-denegado-card">
                <div class="acceso-icon">🚫</div>
                <h1>Acceso Denegado</h1>
                <p>No tienes los permisos necesarios para acceder a esta página.</p>
                
                <div class="btn-group">
                    <a href="javascript:history.back()" class="btn btn-secondary">Volver Atrás</a>
                    
                    <% if (usuario != null) { %>
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">Ir a Mi Dashboard</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-primary">Ir al Login</a>
                    <% } %>
                </div>
                
                <div class="info-adicional mt-lg">
                    <p>
                        <strong>Información:</strong> 
                        <% if (usuario != null) { %>
                            Estás autenticado como <strong><%= rol != null ? rol : "" %></strong>. 
                            Contacta al administrador si necesitas acceso a esta funcionalidad.
                        <% } else { %>
                            Debes iniciar sesión para acceder a esta página.
                        <% } %>
                    </p>
                </div>
            </div>
        </div>
    </main>

    <!-- Pie de página consistente -->
    <footer role="contentinfo">
        <div class="container">
            <div class="footer-content">
                <p>&copy; 2024 Taller Automotriz Rápido. Todos los derechos reservados.</p>
                <nav aria-label="Navegación del pie de página">
                    <div class="footer-links">
                        <a href="${pageContext.request.contextPath}/index.html">Inicio</a>
                        <a href="#privacidad">Política de Privacidad</a>
                        <a href="#terminos">Términos de Servicio</a>
                    </div>
                </nav>
            </div>
        </div>
    </footer>
</body>
</html>