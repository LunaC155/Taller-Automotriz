<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Iniciar sesión en Taller Automotriz Rápido - Accede a tu cuenta para gestionar tus servicios.">
    <meta name="theme-color" content="#c8102e">
    <title>Iniciar Sesión - Taller Automotriz Rápido</title>
    <link rel="stylesheet" href="resources/css/styles.css">
    <link rel="icon" type="image/x-icon" href="resources/img/favicon.ico">
</head>
<body>
    <!-- Skip to content para accesibilidad -->
    <a href="#main-content" class="skip-to-content">Saltar al contenido</a>

    <!-- Encabezado simplificado para páginas de autenticación -->
    <header role="banner">
        <div class="container">
            <div class="header-content">
                <a href="index.html" class="logo" aria-label="Volver al inicio">
                    🚗 Taller Automotriz Rápido
                </a>
                <nav role="navigation" aria-label="Navegación principal">
                    <ul>
                        <li><a href="index.html">Volver al Inicio</a></li>
                    </ul>
                </nav>
            </div>
        </div>
    </header>

    <!-- Contenido Principal -->
    <main id="main-content">
        <div class="auth-container">
            <div class="form-container">
                <div class="auth-header">
                    <h1 class="form-title">Iniciar Sesión</h1>
                    <p>Bienvenido de nuevo. Ingresa tus credenciales para continuar.</p>
                </div>
                
                <!-- Mostrar mensaje de error si existe -->
                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-message" role="alert">
                        <span aria-hidden="true">⚠</span>
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <!-- Mostrar mensaje de éxito si existe -->
                <% if (request.getParameter("success") != null) { %>
                    <div class="success-message" role="alert">
                        <span aria-hidden="true">✓</span>
                        <%= request.getParameter("success") %>
                    </div>
                <% } %>
                
                <form action="login" method="post" aria-label="Formulario de inicio de sesión">
                    <div class="form-group">
                        <label for="usuario">Usuario</label>
                        <input 
                            type="text" 
                            id="usuario" 
                            name="usuario" 
                            class="form-control"
                            placeholder="Ingresa tu nombre de usuario"
                            value="<%= request.getAttribute("usuarioIntentado") != null ? request.getAttribute("usuarioIntentado") : "" %>" 
                            required
                            autocomplete="username"
                            aria-required="true">
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Contraseña</label>
                        <input 
                            type="password" 
                            id="password" 
                            name="password" 
                            class="form-control"
                            placeholder="Ingresa tu contraseña"
                            required
                            autocomplete="current-password"
                            aria-required="true">
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary" style="width: 100%;">
                            Iniciar Sesión
                        </button>
                    </div>
                </form>
                
                <div class="auth-footer">
                    <p>
                        ¿No tienes cuenta? 
                        <a href="register.jsp" class="form-link">Regístrate aquí</a>
                    </p>
                </div>
                
                <!-- Información adicional -->
                <div class="alert alert-info mt-lg" style="font-size: 0.9rem;">
                    <strong>💡 Consejo:</strong> Después de iniciar sesión podrás acceder a todos nuestros servicios automotrices.
                </div>
            </div>
        </div>
    </main>

    <!-- Pie de página simplificado -->
    <footer role="contentinfo" style="margin-top: 0;">
        <div class="container">
            <div class="footer-content">
                <p>&copy; 2024 Taller Automotriz Rápido. Todos los derechos reservados.</p>
                <nav aria-label="Navegación del pie de página">
                    <div class="footer-links">
                        <a href="index.html">Inicio</a>
                        <a href="index.html#servicios">Servicios</a>
                        <a href="#privacidad">Política de Privacidad</a>
                    </div>
                </nav>
            </div>
        </div>
    </footer>

    <script src="resources/js/script.js"></script>
</body>
</html>