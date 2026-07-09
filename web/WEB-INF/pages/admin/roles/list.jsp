<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Roles" %>
<%@page import="java.util.List" %>
<%
    List<Roles> roles = (List<Roles>) request.getAttribute("roles");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Roles</title>
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
                <h1>Gestión de Roles</h1>
                <p>Administra los roles y permisos del sistema</p>
            </div>

            <!-- Barra de herramientas -->
            <div class="toolbar">
                <a href="${pageContext.request.contextPath}/admin/roles/crear" class="btn btn-primary">
                    🔐 Nuevo Rol
                </a>
                
                <form action="${pageContext.request.contextPath}/admin/roles/buscar" method="get" class="search-form">
                    <select name="criterio" class="form-control">
                        <option value="nombre" <%= "nombre".equals(criterio) ? "selected" : "" %>>Nombre</option>
                        <option value="descripcion" <%= "descripcion".equals(criterio) ? "selected" : "" %>>Descripción</option>
                    </select>
                    <input type="text" name="valor" value="<%= valor != null ? valor : "" %>" 
                           placeholder="Buscar..." class="form-control">
                    <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                </form>
            </div>

            <!-- Tabla de roles -->
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre del Rol</th>
                            <th>Descripción</th>
                            <th>Usuarios Asignados</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (roles != null && !roles.isEmpty()) { %>
                            <% for (Roles rol : roles) { %>
                                <tr>
                                    <td><%= rol.getIDRol() %></td>
                                    <td><strong><%= rol.getNombreRol() %></strong></td>
                                    <td><%= rol.getDescripcion() != null ? rol.getDescripcion() : "Sin descripción" %></td>
                                    <td>
                                        <span class="badge badge-info">
                                            <%= rol.getUsuariosList() != null ? rol.getUsuariosList().size() : 0 %> usuarios
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= rol.getEstado() != null && rol.getEstado() ? "badge-success" : "badge-danger" %>">
                                            <%= rol.getEstado() != null && rol.getEstado() ? "Activo" : "Inactivo" %>
                                        </span>
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/admin/roles/editar?id=<%= rol.getIDRol() %>" 
                                           class="btn-action btn-edit" title="Editar">✏️</a>
                                        <a href="${pageContext.request.contextPath}/admin/roles/ver?id=<%= rol.getIDRol() %>" 
                                           class="btn-action btn-view" title="Ver">👁️</a>
                                        <a href="${pageContext.request.contextPath}/admin/roles/asignar-permisos?id=<%= rol.getIDRol() %>" 
                                           class="btn-action btn-permissions" title="Permisos">🔑</a>
                                        <a href="${pageContext.request.contextPath}/admin/roles/usuarios?id=<%= rol.getIDRol() %>" 
                                           class="btn-action btn-users" title="Usuarios">👥</a>
                                        <a href="${pageContext.request.contextPath}/admin/roles/eliminar?id=<%= rol.getIDRol() %>" 
                                           class="btn-action btn-delete" title="Eliminar" 
                                           onclick="return confirm('¿Está seguro de eliminar este rol?')">🗑️</a>
                                    </td>
                                </tr>
                            <% } %>
                        <% } else { %>
                            <tr>
                                <td colspan="6" class="no-data">No se encontraron roles</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Estadísticas -->
            <div class="stats-section">
                <div class="stat-card">
                    <h3>Total Roles</h3>
                    <p class="stat-number"><%= roles != null ? roles.size() : 0 %></p>
                </div>
                <div class="stat-card">
                    <h3>Roles Activos</h3>
                    <p class="stat-number">
                        <% 
                            int activos = 0;
                            if (roles != null) {
                                for (Roles rol : roles) {
                                    if (rol.getEstado() != null && rol.getEstado()) {
                                        activos++;
                                    }
                                }
                            }
                        %>
                        <%= activos %>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>