<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Empleado" %>
<%@page import="java.util.List" %>
<%
    List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Empleados</title>
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
                <h1>Gestión de Empleados</h1>
                <p>Administra la información de todos los empleados del taller</p>
            </div>

            <!-- Barra de herramientas -->
            <div class="toolbar">
                <a href="${pageContext.request.contextPath}/admin/empleados/crear" class="btn btn-primary">
                    👨‍💼 Nuevo Empleado
                </a>
                
                <form action="${pageContext.request.contextPath}/admin/empleados/buscar" method="get" class="search-form">
                    <select name="criterio" class="form-control">
                        <option value="nombre" <%= "nombre".equals(criterio) ? "selected" : "" %>>Nombre</option>
                        <option value="cargo" <%= "cargo".equals(criterio) ? "selected" : "" %>>Cargo</option>
                    </select>
                    <input type="text" name="valor" value="<%= valor != null ? valor : "" %>" 
                           placeholder="Buscar..." class="form-control">
                    <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                </form>
            </div>

            <!-- Tabla de empleados -->
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Apellido</th>
                            <th>Email</th>
                            <th>Teléfono</th>
                            <th>Salario</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (empleados != null && !empleados.isEmpty()) { %>
                            <% for (Empleado empleado : empleados) { %>
                                <tr>
                                    <td><%= empleado.getIDEmpleado() %></td>
                                    <td><%= empleado.getNombre() %></td>
                                    <td><%= empleado.getApellido() %></td>
                                    <td><%= empleado.getEmail() != null ? empleado.getEmail() : "N/A" %></td>
                                    <td><%= empleado.getTelefono() != null ? empleado.getTelefono() : "N/A" %></td>
                                    <td>$<%= empleado.getSalario() != null ? empleado.getSalario() : "0.00" %></td>
                                    <td>
                                        <span class="badge <%= empleado.getEstado() != null && empleado.getEstado() ? "badge-success" : "badge-danger" %>">
                                            <%= empleado.getEstado() != null && empleado.getEstado() ? "Activo" : "Inactivo" %>
                                        </span>
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/admin/empleados/editar?id=<%= empleado.getIDEmpleado() %>" 
                                           class="btn-action btn-edit" title="Editar">✏️</a>
                                        <a href="${pageContext.request.contextPath}/admin/empleados/ver?id=<%= empleado.getIDEmpleado() %>" 
                                           class="btn-action btn-view" title="Ver">👁️</a>
                                        <a href="${pageContext.request.contextPath}/admin/empleados/eliminar?id=<%= empleado.getIDEmpleado() %>" 
                                           class="btn-action btn-delete" title="Eliminar" 
                                           onclick="return confirm('¿Está seguro de eliminar este empleado?')">🗑️</a>
                                    </td>
                                </tr>
                            <% } %>
                        <% } else { %>
                            <tr>
                                <td colspan="8" class="no-data">No se encontraron empleados</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Estadísticas -->
            <div class="stats-section">
                <div class="stat-card">
                    <h3>Total Empleados</h3>
                    <p class="stat-number"><%= empleados != null ? empleados.size() : 0 %></p>
                </div>
                <div class="stat-card">
                    <h3>Empleados Activos</h3>
                    <p class="stat-number">
                        <% 
                            int activos = 0;
                            if (empleados != null) {
                                for (Empleado emp : empleados) {
                                    if (emp.getEstado() != null && emp.getEstado()) {
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