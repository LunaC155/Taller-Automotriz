<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Roles" %>
<%@page import="com.upec.model.Usuarios" %>
<%@page import="java.util.List" %>
<%
    Roles rol = (Roles) request.getAttribute("rol");
    List<String> permisos = (List<String>) request.getAttribute("permisos");
    List<Usuarios> usuarios = (List<Usuarios>) request.getAttribute("usuarios");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Rol</title>
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
                <h1>Detalle del Rol</h1>
                <p>Información completa del rol y sus permisos</p>
            </div>

            <% if (rol != null) { %>
                <!-- Información del rol -->
                <div class="detail-section">
                    <div class="detail-card">
                        <h2>🔐 Información del Rol</h2>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>ID:</strong>
                                <span><%= rol.getIDRol() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Nombre:</strong>
                                <span><strong><%= rol.getNombreRol() %></strong></span>
                            </div>
                            <div class="detail-item">
                                <strong>Descripción:</strong>
                                <span><%= rol.getDescripcion() != null ? rol.getDescripcion() : "Sin descripción" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado:</strong>
                                <span class="badge <%= rol.getEstado() != null && rol.getEstado() ? "badge-success" : "badge-danger" %>">
                                    <%= rol.getEstado() != null && rol.getEstado() ? "Activo" : "Inactivo" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Usuarios Asignados:</strong>
                                <span class="badge badge-info">
                                    <%= usuarios != null ? usuarios.size() : 0 %> usuarios
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Permisos del rol -->
                    <div class="detail-card">
                        <h2>🔑 Permisos Asignados</h2>
                        <% if (permisos != null && !permisos.isEmpty()) { %>
                            <div class="permissions-grid">
                                <% for (String permiso : permisos) { %>
                                    <div class="permission-item">
                                        <span class="permission-icon">✅</span>
                                        <span class="permission-name"><%= permiso %></span>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <p class="no-data">Este rol no tiene permisos asignados.</p>
                        <% } %>
                        <div class="permission-actions">
                            <a href="${pageContext.request.contextPath}/admin/roles/asignar-permisos?id=<%= rol.getIDRol() %>" 
                               class="btn btn-primary">? Gestionar Permisos</a>
                        </div>
                    </div>

                    <!-- Usuarios con este rol -->
                    <div class="detail-card">
                        <h2>👥 Usuarios con este Rol</h2>
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
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Usuarios usuario : usuarios) { %>
                                            <tr>
                                                <td><%= usuario.getIDUsuario() %></td>
                                                <td><%= usuario.getUsuario() %></td>
                                                <td><%= usuario.getEmail() != null ? usuario.getEmail() : "N/A" %></td>
                                                <td>
                                                    <span class="badge <%= usuario.getEstado() != null && usuario.getEstado() ? "badge-success" : "badge-danger" %>">
                                                        <%= usuario.getEstado() != null && usuario.getEstado() ? "Activo" : "Inactivo" %>
                                                    </span>
                                                </td>
                                                <td><%= usuario.getFechaCreacion() != null ? usuario.getFechaCreacion() : "N/A" %></td>
                                                <td class="actions">
                                                    <a href="#" class="btn-action btn-view" title="Ver Usuario">👁️</a>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } else { %>
                            <p class="no-data">No hay usuarios asignados a este rol.</p>
                        <% } %>
                    </div>
                </div>

                <!-- Acciones -->
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/admin/roles/editar?id=<%= rol.getIDRol() %>" 
                       class="btn btn-primary">✏️ Editar Rol</a>
                    <a href="${pageContext.request.contextPath}/admin/roles/asignar-permisos?id=<%= rol.getIDRol() %>" 
                       class="btn btn-warning">🔑 Gestionar Permisos</a>
                    <a href="${pageContext.request.contextPath}/admin/roles/usuarios?id=<%= rol.getIDRol() %>" 
                       class="btn btn-info">👥 Ver Todos los Usuarios</a>
                    <a href="${pageContext.request.contextPath}/admin/roles" class="btn btn-secondary">↩️ Volver al Listado</a>
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