<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%@page import="java.util.List" %>
<%
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Vehículos</title>
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
                <h1>Gestión de Vehículos</h1>
                <p>Administra el registro de vehículos de los clientes</p>
            </div>

            <!-- Barra de herramientas -->
            <div class="toolbar">
                <a href="${pageContext.request.contextPath}/admin/vehiculos/crear" class="btn btn-primary">
                    🚗 Nuevo Vehículo
                </a>
                
                <form action="${pageContext.request.contextPath}/admin/vehiculos/buscar" method="get" class="search-form">
                    <select name="criterio" class="form-control">
                        <option value="placa" <%= "placa".equals(criterio) ? "selected" : "" %>>Placa</option>
                        <option value="marca" <%= "marca".equals(criterio) ? "selected" : "" %>>Marca</option>
                        <option value="cliente" <%= "cliente".equals(criterio) ? "selected" : "" %>>Cliente</option>
                    </select>
                    <input type="text" name="valor" value="<%= valor != null ? valor : "" %>" 
                           placeholder="Buscar..." class="form-control">
                    <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                </form>
            </div>

            <!-- Tabla de vehículos -->
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Placa</th>
                            <th>Marca</th>
                            <th>Modelo</th>
                            <th>Color</th>
                            <th>Año</th>
                            <th>Kilometraje</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (vehiculos != null && !vehiculos.isEmpty()) { %>
                            <% for (Vehiculo vehiculo : vehiculos) { %>
                                <tr>
                                    <td><%= vehiculo.getIDVehiculo() %></td>
                                    <td><%= vehiculo.getPlaca() %></td>
                                    <td><%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %></td>
                                    <td><%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %></td>
                                    <td><%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></td>
                                    <td><%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></td>
                                    <td><%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></td>
                                    <td>
                                        <span class="badge <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "badge-success" : "badge-danger" %>">
                                            <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "Activo" : "Inactivo" %>
                                        </span>
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/admin/vehiculos/editar?id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn-action btn-edit" title="Editar">✏️</a>
                                        <a href="${pageContext.request.contextPath}/admin/vehiculos/ver?id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn-action btn-view" title="Ver">👁️</a>
                                        <a href="${pageContext.request.contextPath}/admin/vehiculos/eliminar?id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn-action btn-delete" title="Eliminar" 
                                           onclick="return confirm('¿Está seguro de eliminar este vehículo?')">🗑️</a>
                                    </td>
                                </tr>
                            <% } %>
                        <% } else { %>
                            <tr>
                                <td colspan="9" class="no-data">No se encontraron vehículos</td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Estadísticas -->
            <div class="stats-section">
                <div class="stat-card">
                    <h3>Total Vehículos</h3>
                    <p class="stat-number"><%= vehiculos != null ? vehiculos.size() : 0 %></p>
                </div>
                <div class="stat-card">
                    <h3>Vehículos Activos</h3>
                    <p class="stat-number">
                        <% 
                            int activos = 0;
                            if (vehiculos != null) {
                                for (Vehiculo veh : vehiculos) {
                                    if (veh.getEstado() != null && veh.getEstado()) {
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