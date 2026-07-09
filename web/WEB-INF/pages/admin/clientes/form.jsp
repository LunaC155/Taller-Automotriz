<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente" %>
<%
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 1) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Cliente cliente = (Cliente) request.getAttribute("cliente");
    Boolean esNuevo = (Boolean) request.getAttribute("esNuevo");
    
    if (cliente == null) {
        cliente = new Cliente();
    }
    if (esNuevo == null) {
        esNuevo = true;
    }
    
    String titulo = esNuevo ? "Nuevo Cliente" : "Editar Cliente";
    String action = esNuevo ? "crear" : "actualizar";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> - Taller Automotriz</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudadmin.css">
</head>
<body class="admin">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-admin.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1><%= titulo %></h1>
                <p><%= esNuevo ? "Registrar un nuevo cliente en el sistema" : "Modificar la información del cliente" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/ClienteServlet" method="post" class="crud-form">
                    <input type="hidden" name="action" value="<%= action %>">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="id" value="<%= cliente.getIDCliente() %>">
                    <% } %>

                    <div class="form-grid">
                        <div class="form-section">
                            <h3>Información Personal</h3>
                            
                            <div class="form-group">
                                <label for="nombre">Nombre *</label>
                                <input type="text" id="nombre" name="nombre" 
                                       value="<%= cliente.getNombre() != null ? cliente.getNombre() : "" %>" 
                                       required maxlength="50">
                            </div>

                            <div class="form-group">
                                <label for="apellido">Apellido *</label>
                                <input type="text" id="apellido" name="apellido" 
                                       value="<%= cliente.getApellido() != null ? cliente.getApellido() : "" %>" 
                                       required maxlength="50">
                            </div>

                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" id="email" name="email" 
                                       value="<%= cliente.getEmail() != null ? cliente.getEmail() : "" %>"
                                       maxlength="100">
                                <small class="form-text">Opcional: dirección de correo electrónico</small>
                            </div>

                            <div class="form-group">
                                <label for="telefono">Teléfono</label>
                                <input type="tel" id="telefono" name="telefono" 
                                       value="<%= cliente.getTelefono() != null ? cliente.getTelefono() : "" %>"
                                       maxlength="15">
                                <small class="form-text">Opcional: número de teléfono de contacto</small>
                            </div>
                        </div>

                        <div class="form-section">
                            <h3>Información de Contacto</h3>
                            
                            <div class="form-group">
                                <label for="direccion">Dirección</label>
                                <textarea id="direccion" name="direccion" rows="4" 
                                          maxlength="255"><%= cliente.getDireccion() != null ? cliente.getDireccion() : "" %></textarea>
                                <small class="form-text">Opcional: dirección completa del cliente</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "Crear Cliente" : "Actualizar Cliente" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/ClienteServlet?action=listar" class="btn btn-secondary">
                            Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('.crud-form');
            form.addEventListener('submit', function(e) {
                const nombre = document.getElementById('nombre').value.trim();
                const apellido = document.getElementById('apellido').value.trim();
                
                if (!nombre || !apellido) {
                    e.preventDefault();
                    alert('Los campos Nombre y Apellido son obligatorios');
                    return false;
                }
                
                const email = document.getElementById('email').value.trim();
                if (email && !isValidEmail(email)) {
                    e.preventDefault();
                    alert('Por favor ingrese un email válido');
                    return false;
                }
            });
            
            function isValidEmail(email) {
                const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return re.test(email);
            }
        });
    </script>
</body>
</html>