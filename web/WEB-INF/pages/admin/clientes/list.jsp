<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.Cliente" %>
<%
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Clientes</title>
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
                <h1>👥 Gestión de Clientes</h1>
                <p>Administra y consulta la información de los clientes</p>
            </div>

            <!-- Barra de acciones -->
            <div class="action-bar">
                <a href="${pageContext.request.contextPath}/admin/clientes/crear" class="btn btn-primary">
                    ➕ Nuevo Cliente
                </a>
                <a href="${pageContext.request.contextPath}/admin/clientes/reportes" class="btn btn-info">
                    📊 Ver Reportes
                </a>
            </div>

            <!-- Formulario de búsqueda -->
            <div class="search-section">
                <form action="${pageContext.request.contextPath}/admin/clientes/buscar" method="get" class="search-form">
                    <div class="search-group">
                        <select name="criterio" class="form-control">
                            <option value="nombre" <%= "nombre".equals(criterio) ? "selected" : "" %>>Nombre</option>
                            <option value="email" <%= "email".equals(criterio) ? "selected" : "" %>>Email</option>
                            <option value="telefono" <%= "telefono".equals(criterio) ? "selected" : "" %>>Teléfono</option>
                        </select>
                        <input type="text" name="valor" placeholder="Buscar cliente..." 
                               value="<%= valor != null ? valor : "" %>" class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                        <a href="${pageContext.request.contextPath}/admin/clientes" class="btn btn-secondary">🔄 Limpiar</a>
                    </div>
                </form>
            </div>

            <!-- Tabla de clientes -->
            <div class="table-container">
                <% if (clientes != null && !clientes.isEmpty()) { %>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre Completo</th>
                                <th>Email</th>
                                <th>Teléfono</th>
                                <th>Dirección</th>
                                <th>Fecha Registro</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Cliente cliente : clientes) { %>
                                <tr>
                                    <td><%= cliente.getIDCliente() %></td>
                                    <td><%= cliente.getNombre() %> <%= cliente.getApellido() %></td>
                                    <td><%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></td>
                                    <td><%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></td>
                                    <td><%= cliente.getDireccion() != null ? cliente.getDireccion() : "N/A" %></td>
                                    <td><%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %></td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/admin/clientes/ver?id=<%= cliente.getIDCliente() %>" 
                                           class="btn btn-sm btn-info" title="Ver detalles">👁️</a>
                                        <a href="${pageContext.request.contextPath}/admin/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                                           class="btn btn-sm btn-warning" title="Editar">✏️</a>
                                        <a href="${pageContext.request.contextPath}/admin/clientes/eliminar?id=<%= cliente.getIDCliente() %>" 
                                           class="btn btn-sm btn-danger" title="Eliminar"
                                           onclick="return confirm('¿Está seguro de eliminar este cliente?')">🗑️</a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <div class="table-info">
                        <p>Total de clientes: <strong><%= clientes.size() %></strong></p>
                    </div>
                <% } else { %>
                    <div class="no-data">
                        <p>📋 No hay clientes registrados.</p>
                        <a href="${pageContext.request.contextPath}/admin/clientes/crear" class="btn btn-primary">
                            ➕ Registrar Primer Cliente
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>