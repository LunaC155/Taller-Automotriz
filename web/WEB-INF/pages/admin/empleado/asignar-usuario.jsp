<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Empleado" %>
<%@page import="com.upec.model.Usuarios" %>
<%@page import="java.util.List" %>
<%
    Empleado empleado = (Empleado) request.getAttribute("empleado");
    List<Usuarios> usuariosDisponibles = (List<Usuarios>) request.getAttribute("usuariosDisponibles");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Asignar Usuario a Empleado</title>
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
                <h1>Asignar Usuario a Empleado</h1>
                <p>Vincula una cuenta de usuario existente con el empleado</p>
            </div>

            <% if (empleado != null) { %>
                <div class="form-container">
                    <!-- Información del empleado -->
                    <div class="info-card">
                        <h3>👨‍💼 Empleado Seleccionado</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>Nombre:</strong>
                                <span><%= empleado.getNombre() %> <%= empleado.getApellido() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Email:</strong>
                                <span><%= empleado.getEmail() != null ? empleado.getEmail() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado:</strong>
                                <span class="badge <%= empleado.getEstado() != null && empleado.getEstado() ? "badge-success" : "badge-danger" %>">
                                    <%= empleado.getEstado() != null && empleado.getEstado() ? "Activo" : "Inactivo" %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Formulario de asignación -->
                    <form action="${pageContext.request.contextPath}/admin/empleados/asignar-usuario" method="post" class="admin-form">
                        <input type="hidden" name="idEmpleado" value="<%= empleado.getIDEmpleado() %>">
                        
                        <div class="form-group">
                            <label for="idUsuario">Seleccionar Usuario *</label>
                            <select id="idUsuario" name="idUsuario" class="form-control" required>
                                <option value="">Seleccionar un usuario</option>
                                <% if (usuariosDisponibles != null && !usuariosDisponibles.isEmpty()) { %>
                                    <% for (Usuarios usuario : usuariosDisponibles) { %>
                                        <option value="<%= usuario.getIDUsuario() %>">
                                            <%= usuario.getUsuario() %> 
                                            (<%= usuario.getEmail() != null ? usuario.getEmail() : "Sin email" %>)
                                            - <%= usuario.getIDRol() != null ? usuario.getIDRol().getNombreRol() : "Sin rol" %>
                                        </option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>

                        <% if (usuariosDisponibles == null || usuariosDisponibles.isEmpty()) { %>
                            <div class="warning-message">
                                <p>⚠️ No hay usuarios disponibles para asignar. Todos los usuarios existentes ya están asignados a empleados.</p>
                                <a href="${pageContext.request.contextPath}/admin/usuarios/crear" class="btn btn-primary">
                                    👤 Crear Nuevo Usuario
                                </a>
                            </div>
                        <% } %>

                        <div class="form-actions">
                            <% if (usuariosDisponibles != null && !usuariosDisponibles.isEmpty()) { %>
                                <button type="submit" class="btn btn-primary">🔐 Asignar Usuario</button>
                            <% } %>
                            <a href="${pageContext.request.contextPath}/admin/empleados/ver?id=<%= empleado.getIDEmpleado() %>" 
                               class="btn btn-secondary">↩️ Cancelar</a>
                        </div>
                    </form>
                </div>

                <!-- Información adicional -->
                <div class="info-grid">
                    <div class="info-card">
                        <h3>💡 ¿Por qué asignar un usuario?</h3>
                        <ul>
                            <li>El empleado podrá acceder al sistema con sus credenciales</li>
                            <li>Se le asignarán permisos según el rol del usuario</li>
                            <li>Podrá realizar las operaciones correspondientes a su cargo</li>
                            <li>Se mantendrá un historial de actividades</li>
                        </ul>
                    </div>

                    <div class="info-card">
                        <h3>⚠️ Consideraciones</h3>
                        <ul>
                            <li>Un usuario solo puede estar asignado a un empleado</li>
                            <li>La asignación no puede ser modificada posteriormente</li>
                            <li>Verifique que el rol del usuario coincida con las funciones del empleado</li>
                            <li>El empleado debe conocer sus credenciales de acceso</li>
                        </ul>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el empleado solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/empleados" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>