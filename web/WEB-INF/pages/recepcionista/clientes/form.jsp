<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Cliente cliente = (Cliente) request.getAttribute("cliente");
    boolean esNuevo = cliente == null || cliente.getIDCliente() == null;
    String titulo = esNuevo ? "Registrar Nuevo Cliente" : "Editar Cliente";
    String action = esNuevo ? "crear" : "editar";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> - Recepcionista</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
   
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1><%= titulo %></h1>
                <p><%= esNuevo ? "Registra un nuevo cliente en el sistema" : "Modifica la información del cliente" %></p>
            </div>

            <!-- Consejos del formulario -->
            <div class="form-tips">
                <h4>💡 Información Importante</h4>
                <ul>
                    <li>Los campos marcados con <span style="color: #dc3545;">*</span> son obligatorios</li>
                    <li>Verifica que el email y teléfono sean correctos para notificaciones</li>
                    <li>La dirección completa ayuda en servicios a domicilio</li>
                    <li>Un cliente puede tener múltiples vehículos asociados</li>
                </ul>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/recepcionista/clientes/<%= action %>" method="post" class="crud-form" id="clienteForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="id" value="<%= cliente.getIDCliente() %>">
                    <% } %>

                    <div class="form-section">
                        <h3>👤 Información Personal</h3>
                        
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="nombre" class="field-required">Nombre</label>
                                <input type="text" id="nombre" name="nombre" 
                                       value="<%= cliente != null && cliente.getNombre() != null ? cliente.getNombre() : "" %>" 
                                       required class="form-control" 
                                       placeholder="Ingrese el nombre del cliente">
                                <small class="form-text">Nombre del cliente (obligatorio)</small>
                            </div>

                            <div class="form-group">
                                <label for="apellido" class="field-required">Apellido</label>
                                <input type="text" id="apellido" name="apellido" 
                                       value="<%= cliente != null && cliente.getApellido() != null ? cliente.getApellido() : "" %>" 
                                       required class="form-control" 
                                       placeholder="Ingrese el apellido del cliente">
                                <small class="form-text">Apellido del cliente (obligatorio)</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h3>📞 Información de Contacto</h3>
                        
                        <div class="contact-info-grid">
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" 
                                       value="<%= cliente != null && cliente.getEmail() != null ? cliente.getEmail() : "" %>" 
                                       class="form-control" 
                                       placeholder="cliente@ejemplo.com">
                                <small class="form-text">Email para notificaciones y contacto</small>
                            </div>

                            <div class="form-group">
                                <label for="telefono">Teléfono</label>
                                <input type="tel" id="telefono" name="telefono" 
                                       value="<%= cliente != null && cliente.getTelefono() != null ? cliente.getTelefono() : "" %>" 
                                       class="form-control" 
                                       placeholder="+593 99 999 9999">
                                <small class="form-text">Número de contacto del cliente</small>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="direccion">Dirección</label>
                            <textarea id="direccion" name="direccion" 
                                      rows="3" class="form-control" 
                                      placeholder="Ingrese la dirección completa del cliente..."><%= cliente != null && cliente.getDireccion() != null ? cliente.getDireccion() : "" %></textarea>
                            <small class="form-text">Dirección completa para servicios o envíos</small>
                        </div>
                    </div>

                    <!-- Información del sistema (solo para edición) -->
                    <% if (!esNuevo && cliente.getFechaRegistro() != null) { 
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                    %>
                        <div class="form-section">
                            <h3>📊 Información del Sistema</h3>
                            <div class="readonly-info">
                                <div class="info-item">
                                    <strong>ID Cliente:</strong> #<%= cliente.getIDCliente() %>
                                </div>
                                <div class="info-item">
                                    <strong>Fecha de Registro:</strong> <%= sdf.format(cliente.getFechaRegistro()) %>
                                </div>
                                <div class="info-item">
                                    <strong>Vehículos Registrados:</strong> 
                                    <%= cliente.getVehiculoList() != null ? cliente.getVehiculoList().size() : 0 %> vehículos
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "➕ Registrar Cliente" : "💾 Actualizar Cliente" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/clientes" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                        <% if (!esNuevo) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/clientes/ver?id=<%= cliente.getIDCliente() %>" 
                               class="btn btn-info">👁️ Ver Detalles</a>
                        <% } %>
                    </div>
                </form>
            </div>

            <!-- Información adicional -->
            <div class="additional-info">
                <h3>ℹ️ Sobre el Registro de Clientes</h3>
                <div class="info-grid">
                    <div class="info-card">
                        <h4>📝 Datos Obligatorios</h4>
                        <ul>
                            <li><strong>Nombre y Apellido:</strong> Para identificación personal</li>
                            <li><strong>Contacto:</strong> Al menos email o teléfono es recomendado</li>
                            <li><strong>Datos básicos:</strong> Suficientes para crear una orden de servicio</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>🚗 Próximos Pasos</h4>
                        <ul>
                            <li>Después de registrar al cliente, agrega sus vehículos</li>
                            <li>Asocia el vehículo a órdenes de servicio</li>
                            <li>Mantén actualizada la información de contacto</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>🔔 Notificaciones</h4>
                        <ul>
                            <li>El cliente recibirá notificaciones por email</li>
                            <li>Se enviarán recordatorios de mantenimiento</li>
                            <li>Actualizaciones del estado de las reparaciones</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Validación del formulario
        document.getElementById('clienteForm').addEventListener('submit', function(e) {
            const nombre = document.getElementById('nombre').value.trim();
            const apellido = document.getElementById('apellido').value.trim();
            const email = document.getElementById('email').value.trim();
            const telefono = document.getElementById('telefono').value.trim();

            if (!nombre) {
                e.preventDefault();
                alert('Por favor ingrese el nombre del cliente');
                document.getElementById('nombre').focus();
                return false;
            }

            if (!apellido) {
                e.preventDefault();
                alert('Por favor ingrese el apellido del cliente');
                document.getElementById('apellido').focus();
                return false;
            }

            // Validación básica de email si se proporciona
            if (email && !isValidEmail(email)) {
                e.preventDefault();
                alert('Por favor ingrese un email válido');
                document.getElementById('email').focus();
                return false;
            }

            return confirm('¿Está seguro de <%= esNuevo ? "registrar" : "actualizar" %> este cliente?');
        });

        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        // Formatear teléfono mientras se escribe
        document.getElementById('telefono').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length > 0) {
                value = '+593 ' + value;
            }
            e.target.value = value;
        });
    </script>
</body>
</html>