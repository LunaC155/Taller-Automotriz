<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Registro de Usuario - Crea tu cuenta en Taller Automotriz Rápido para acceder a nuestros servicios.">
    <meta name="theme-color" content="#c8102e">
    <title>Registro de Usuario - Taller Automotriz Rápido</title>
    <link rel="stylesheet" href="resources/css/styles.css">
    <link rel="icon" type="image/x-icon" href="resources/img/favicon.ico">
</head>
<body>
    <!-- Skip to content para accesibilidad -->
    <a href="#main-content" class="skip-to-content">Saltar al contenido</a>

    <!-- Encabezado simplificado -->
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
                    <h1 class="form-title">Crear Cuenta</h1>
                    <p>Únete a nuestra comunidad y disfruta de nuestros servicios profesionales.</p>
                </div>
                
                <!-- Mostrar mensaje de error si existe -->
                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-message" role="alert">
                        <span aria-hidden="true">⚠</span>
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <!-- Mostrar mensaje de éxito si viene por parámetro -->
                <% if (request.getParameter("success") != null) { %>
                    <div class="success-message" role="alert">
                        <span aria-hidden="true">✓</span>
                        <%= request.getParameter("success") %>
                    </div>
                <% } %>
                
                <form action="register" method="post" aria-label="Formulario de registro de usuario">
                    <div class="form-group">
                        <label for="usuario">Nombre de Usuario *</label>
                        <input 
                            type="text" 
                            id="usuario" 
                            name="usuario" 
                            class="form-control"
                            placeholder="Elige un nombre de usuario único"
                            required
                            autocomplete="username"
                            aria-required="true"
                            minlength="3"
                            maxlength="50">
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Correo Electrónico *</label>
                        <input 
                            type="email" 
                            id="email" 
                            name="email" 
                            class="form-control"
                            placeholder="tu@email.com"
                            required
                            autocomplete="email"
                            aria-required="true">
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Contraseña *</label>
                        <input 
                            type="password" 
                            id="password" 
                            name="password" 
                            class="form-control"
                            placeholder="Mínimo 6 caracteres"
                            required
                            autocomplete="new-password"
                            aria-required="true"
                            minlength="6">
                        <small style="display: block; margin-top: 5px; color: var(--text-secondary); font-size: 0.85rem;">
                            La contraseña debe tener al menos 6 caracteres
                        </small>
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirmar Contraseña *</label>
                        <input 
                            type="password" 
                            id="confirmPassword" 
                            name="confirmPassword" 
                            class="form-control"
                            placeholder="Repite tu contraseña"
                            required
                            autocomplete="new-password"
                            aria-required="true"
                            minlength="6">
                    </div>
                    
                    <div class="row">
                        <div class="col">
                            <div class="form-group">
                                <label for="nombre">Nombre *</label>
                                <input 
                                    type="text" 
                                    id="nombre" 
                                    name="nombre" 
                                    class="form-control"
                                    placeholder="Tu nombre"
                                    required
                                    autocomplete="given-name"
                                    aria-required="true">
                            </div>
                        </div>
                        
                        <div class="col">
                            <div class="form-group">
                                <label for="apellido">Apellido *</label>
                                <input 
                                    type="text" 
                                    id="apellido" 
                                    name="apellido" 
                                    class="form-control"
                                    placeholder="Tu apellido"
                                    required
                                    autocomplete="family-name"
                                    aria-required="true">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="telefono">Teléfono</label>
                        <input 
                            type="tel" 
                            id="telefono" 
                            name="telefono" 
                            class="form-control"
                            placeholder="+57 300 123 4567"
                            autocomplete="tel">
                    </div>
                    
                    <div class="form-group">
                        <label for="direccion">Dirección</label>
                        <input 
                            type="text" 
                            id="direccion" 
                            name="direccion" 
                            class="form-control"
                            placeholder="Tu dirección completa"
                            autocomplete="street-address">
                    </div>
                    
                    <!-- Términos y condiciones -->
                    <div class="form-group" style="margin-bottom: 20px;">
                        <label style="display: flex; align-items: start; gap: 10px; cursor: pointer; font-weight: normal;">
                            <input 
                                type="checkbox" 
                                id="terminos" 
                                name="terminos" 
                                required
                                style="margin-top: 3px;">
                            <span style="font-size: 0.9rem;">
                                Acepto los <a href="#terminos" class="form-link">términos y condiciones</a> 
                                y la <a href="#privacidad" class="form-link">política de privacidad</a>
                            </span>
                        </label>
                    </div>
                    
                    <!-- Newsletter opcional -->
                    <div class="form-group" style="margin-bottom: 20px;">
                        <label style="display: flex; align-items: start; gap: 10px; cursor: pointer; font-weight: normal;">
                            <input 
                                type="checkbox" 
                                id="newsletter" 
                                name="newsletter"
                                style="margin-top: 3px;">
                            <span style="font-size: 0.9rem;">
                                Deseo recibir información sobre promociones y consejos de mantenimiento
                            </span>
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary" style="width: 100%;">
                            Crear Cuenta
                        </button>
                    </div>
                </form>
                
                <div class="auth-footer">
                    <p>
                        ¿Ya tienes cuenta? 
                        <a href="login.jsp" class="form-link">Inicia sesión aquí</a>
                    </p>
                </div>
                
                <!-- Beneficios de crear cuenta -->
                <div class="card mt-lg">
                    <div class="card-body">
                        <h3 style="font-size: 1.1rem; margin-bottom: 10px; color: var(--secondary-color);">
                            ✨ Beneficios de crear cuenta
                        </h3>
                        <ul style="list-style: none; padding: 0; margin: 0; font-size: 0.9rem;">
                            <li style="padding: 5px 0;">✓ Historial completo de servicios realizados</li>
                            <li style="padding: 5px 0;">✓ Agendamiento rápido y fácil de citas</li>
                            <li style="padding: 5px 0;">✓ Recordatorios automáticos de mantenimiento</li>
                            <li style="padding: 5px 0;">✓ Ofertas y promociones exclusivas</li>
                            <li style="padding: 5px 0;">✓ Seguimiento en tiempo real de reparaciones</li>
                            <li style="padding: 5px 0;">✓ Facturación electrónica y documentos digitales</li>
                            <li style="padding: 5px 0;">✓ Acceso a tu perfil de vehículo</li>
                            <li style="padding: 5px 0;">✓ Soporte prioritario</li>
                        </ul>
                    </div>
                </div>
                
                <!-- Información de seguridad -->
                <div class="alert alert-info mt-lg" style="font-size: 0.85rem;">
                    <strong>🔒 Tus datos están seguros:</strong> Utilizamos encriptación SSL para proteger tu información. 
                    Nunca compartiremos tus datos con terceros sin tu consentimiento.
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
                        <a href="#terminos">Términos de Servicio</a>
                        <a href="#contacto">Contacto</a>
                    </div>
                </nav>
            </div>
        </div>
    </footer>

    <script src="resources/js/script.js"></script>
    
    <!-- Script para validación del formulario -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('form');
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            const terminos = document.getElementById('terminos');
            
            // Validación de contraseñas coincidentes
            function validatePasswords() {
                if (password.value !== confirmPassword.value) {
                    confirmPassword.setCustomValidity('Las contraseñas no coinciden');
                    confirmPassword.style.borderColor = 'var(--danger-color)';
                } else {
                    confirmPassword.setCustomValidity('');
                    confirmPassword.style.borderColor = '';
                }
            }
            
            password.addEventListener('input', validatePasswords);
            confirmPassword.addEventListener('input', validatePasswords);
            
            // Validación de términos y condiciones
            form.addEventListener('submit', function(e) {
                // Validar longitud de contraseña
                if (password.value.length < 6) {
                    e.preventDefault();
                    alert('La contraseña debe tener al menos 6 caracteres');
                    password.focus();
                    return;
                }
                
                // Validar que las contraseñas coincidan
                if (password.value !== confirmPassword.value) {
                    e.preventDefault();
                    alert('Las contraseñas no coinciden. Por favor verifica.');
                    confirmPassword.focus();
                    return;
                }
                
                // Validar términos y condiciones
                if (!terminos.checked) {
                    e.preventDefault();
                    alert('Debes aceptar los términos y condiciones para continuar');
                    terminos.focus();
                    return;
                }
                
                // Mostrar indicador de carga
                const submitBtn = form.querySelector('button[type="submit"]');
                submitBtn.innerHTML = 'Creando Cuenta...';
                submitBtn.disabled = true;
                submitBtn.classList.add('loading');
            });
            
            // Mejorar la experiencia de usuario en campos de formulario
            const inputs = form.querySelectorAll('input');
            inputs.forEach(input => {
                // Agregar clase cuando el campo tiene contenido
                input.addEventListener('input', function() {
                    if (this.value) {
                        this.classList.add('has-value');
                    } else {
                        this.classList.remove('has-value');
                    }
                });
                
                // Validación en tiempo real para campos requeridos
                input.addEventListener('blur', function() {
                    if (this.hasAttribute('required') && !this.value) {
                        this.style.borderColor = 'var(--danger-color)';
                    } else {
                        this.style.borderColor = '';
                    }
                });
            });
            
            // Mejorar la experiencia en móviles
            if (window.innerWidth <= 768) {
                // Asegurar que el teclado no cubra los campos
                const focusedElement = document.activeElement;
                if (focusedElement && focusedElement.tagName === 'INPUT') {
                    setTimeout(() => {
                        focusedElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }, 300);
                }
            }
        });
    </script>
    
</body>
</html>