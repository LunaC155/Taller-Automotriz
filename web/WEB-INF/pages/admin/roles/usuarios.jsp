<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Roles" %>
<%@page import="com.upec.model.Usuarios" %>
<%@page import="java.util.List" %>
<%
    Roles rol = (Roles) request.getAttribute("rol");
    List<Usuarios> usuarios = (List<Usuarios>) request.getAttribute("usuarios");
    Long totalUsuarios = (Long) request.getAttribute("totalUsuarios");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Usuarios del Rol</title>
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
                <h1>Usuarios con Rol: <strong><%= rol != null ? rol.getNombreRol() : "N/A" %></strong></h1>
                <p>Listado de usuarios que tienen asignado este rol</p>
            </div>

            <% if (rol != null) { %>
                <!-- Información del rol -->
                <div class="role-header">
                    <div class="role-info">
                        <h2><%= rol.getNombreRol() %></h2>
                        <p><%= rol.getDescripcion() != null ? rol.getDescripcion() : "Sin descripción" %></p>
                        <div class="role-stats">
                            <span class="stat">
                                <strong>Total Usuarios:</strong> 
                                <%= totalUsuarios != null ? totalUsuarios : 0 %>
                            </span>
                            <span class="stat">
                                <strong>Estado:</strong>
                                <span class="badge <%= rol.getEstado() != null && rol.getEstado() ? "badge-success" : "badge-danger" %>">
                                    <%= rol.getEstado() != null && rol.getEstado() ? "Activo" : "Inactivo" %>
                                </span>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Lista de usuarios -->
                <div class="users-section">
                    <h3>👥 Usuarios Asignados</h3>
                    
                    <% if (usuarios != null && !usuarios.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Usuario</th>
                                        <th>Email</th>
                                        <th>Estado</th>
                                        <th>Fecha Creación</th>
                                        <th>Empleado Asociado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Usuarios usuario : usuarios) { %>
                                        <tr>
                                            <td><%= usuario.getIDUsuario() %></td>
                                            <td>
                                                <strong><%= usuario.getUsuario() %></strong>
                                            </td>
                                            <td><%= usuario.getEmail() != null ? usuario.getEmail() : "N/A" %></td>
                                            <td>
                                                <span class="badge <%= usuario.getEstado() != null && usuario.getEstado() ? "badge-success" : "badge-danger" %>">
                                                    <%= usuario.getEstado() != null && usuario.getEstado() ? "Activo" : "Inactivo" %>
                                                </span>
                                            </td>
                                            <td><%= usuario.getFechaCreacion() != null ? usuario.getFechaCreacion() : "N/A" %></td>
                                            <td>
                                                <% if (usuario.getEmpleadoList() != null && !usuario.getEmpleadoList().isEmpty()) { %>
                                                    <%= usuario.getEmpleadoList().get(0).getNombre() %> 
                                                    <%= usuario.getEmpleadoList().get(0).getApellido() %>
                                                <% } else { %>
                                                    <em>No asociado</em>
                                                <% } %>
                                            </td>
                                            <td class="actions">
                                                <a href="#" class="btn-action btn-view" title="Ver Usuario">👁️</a>
                                                <a href="#" class="btn-action btn-edit" title="Editar Usuario">✏️</a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>

                        <!-- Estadísticas de usuarios -->
                        <div class="users-stats">
                            <h4>📊 Estadísticas de Usuarios</h4>
                            <div class="stats-grid">
                                <div class="stat-card">
                                    <h5>Total Usuarios</h5>
                                    <p class="stat-number"><%= usuarios.size() %></p>
                                </div>
                                <div class="stat-card">
                                    <h5>Usuarios Activos</h5>
                                    <p class="stat-number">
                                        <% 
                                            int activos = 0;
                                            for (Usuarios usuario : usuarios) {
                                                if (usuario.getEstado() != null && usuario.getEstado()) {
                                                    activos++;
                                                }
                                            }
                                        %>
                                        <%= activos %>
                                    </p>
                                </div>
                                <div class="stat-card">
                                    <h5>Con Empleado</h5>
                                    <p class="stat-number">
                                        <% 
                                            int conEmpleado = 0;
                                            for (Usuarios usuario : usuarios) {
                                                if (usuario.getEmpleadoList() != null && !usuario.getEmpleadoList().isEmpty()) {
                                                    conEmpleado++;
                                                }
                                            }
                                        %>
                                        <%= conEmpleado %>
                                    </p>
                                </div>
                            </div>
                        </div>

                    <% } else { %>
                        <div class="no-users">
                            <div class="no-users-icon">👤</div>
                            <h3>No hay usuarios con este rol</h3>
                            <p>No se han asignado usuarios al rol <strong><%= rol.getNombreRol() %></strong>.</p>
                            <div class="suggestions">
                                <p>Puedes:</p>
                                <ul>
                                    <li>Asignar este rol a usuarios existentes</li>
                                    <li>Crear nuevos usuarios con este rol</li>
                                    <li>Verificar la configuración de roles</li>
                                </ul>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- Acciones -->
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/admin/roles/ver?id=<%= rol.getIDRol() %>" 
                       class="btn btn-primary">↩️ Volver al Rol</a>
                    <a href="${pageContext.request.contextPath}/admin/usuarios" class="btn btn-secondary">
                        👥 Gestionar Usuarios
                    </a>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el rol solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/roles" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>