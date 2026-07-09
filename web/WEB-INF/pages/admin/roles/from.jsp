<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Roles" %>
<%
    Roles rol = (Roles) request.getAttribute("rol");
    boolean isEdit = rol != null && rol.getIDRol() != null;
    String title = isEdit ? "Editar Rol" : "Nuevo Rol";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
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
                <h1><%= title %></h1>
                <p><%= isEdit ? "Modifica la información del rol" : "Crea un nuevo rol en el sistema" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/admin/roles/<%= isEdit ? "editar" : "crear" %>" 
                      method="post" class="admin-form">
                    
                    <% if (isEdit) { %>
                        <input type="hidden" name="idRol" value="<%= rol.getIDRol() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="nombreRol">Nombre del Rol *</label>
                        <input type="text" id="nombreRol" name="nombreRol" 
                               value="<%= rol != null ? rol.getNombreRol() : "" %>" 
                               class="form-control" required
                               placeholder="Ej: Administrador, Mecánico, Recepcionista">
                    </div>

                    <div class="form-group">
                        <label for="descripcion">Descripción</label>
                        <textarea id="descripcion" name="descripcion" class="form-control" 
                                  rows="4" placeholder="Describe las funciones y permisos de este rol"><%= rol != null && rol.getDescripcion() != null ? rol.getDescripcion() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="estado">Estado</label>
                        <select id="estado" name="estado" class="form-control">
                            <option value="true" <%= rol != null && rol.getEstado() != null && rol.getEstado() ? "selected" : "" %>>Activo</option>
                            <option value="false" <%= rol != null && rol.getEstado() != null && !rol.getEstado() ? "selected" : "" %>>Inactivo</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Actualizar Rol" : "🔐 Crear Rol" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/roles" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>

            <!-- Información sobre roles del sistema -->
            <div class="info-card">
                <h3>📋 Roles del Sistema</h3>
                <p>Los siguientes roles están predefinidos en el sistema y no pueden ser eliminados:</p>
                <ul>
                    <li><strong>Administrador</strong> - Acceso completo al sistema</li>
                    <li><strong>Mecánico</strong> - Gestión de diagnósticos y reparaciones</li>
                    <li><strong>Recepcionista</strong> - Gestión de clientes y vehículos</li>
                    <li><strong>Cliente</strong> - Acceso limitado a su información</li>
                </ul>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>