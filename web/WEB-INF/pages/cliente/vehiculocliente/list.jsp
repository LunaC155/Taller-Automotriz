<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.Vehiculo" %>
<%
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    List<Vehiculo> vehiculosActivos = (List<Vehiculo>) request.getAttribute("vehiculosActivos");
    List<Vehiculo> vehiculosInactivos = (List<Vehiculo>) request.getAttribute("vehiculosInactivos");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mis Vehículos - Lista</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
</head>
<body class="cliente">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-cliente.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>📋 Lista de Mis Vehículos</h1>
                <p>Gestiona todos tus vehículos registrados</p>
            </div>

            <!-- Barra de acciones -->
            <div class="action-bar">
                <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=registrar" class="btn btn-primary">
                    ➕ Nuevo Vehículo
                </a>
                <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=dashboard" class="btn btn-secondary">
                    📊 Dashboard
                </a>
            </div>

            <!-- Filtros -->
            <div class="filter-section">
                <div class="filter-tabs">
                    <button class="filter-tab active" data-filter="all">Todos (<%= vehiculos != null ? vehiculos.size() : 0 %>)</button>
                    <button class="filter-tab" data-filter="active">Activos (<%= vehiculosActivos != null ? vehiculosActivos.size() : 0 %>)</button>
                    <button class="filter-tab" data-filter="inactive">Inactivos (<%= vehiculosInactivos != null ? vehiculosInactivos.size() : 0 %>)</button>
                </div>
            </div>

            <!-- Tabla de vehículos -->
            <div class="table-container">
                <% if (vehiculos != null && !vehiculos.isEmpty()) { %>
                    <table class="data-table">
                        <thead>
                            <tr>
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
                            <% for (Vehiculo vehiculo : vehiculos) { %>
                                <tr class="vehicle-row" data-status="<%= vehiculo.getEstado() ? "active" : "inactive" %>">
                                    <td><strong><%= vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "N/A" %></strong></td>
                                    <td><%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %></td>
                                    <td><%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %></td>
                                    <td><%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></td>
                                    <td><%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></td>
                                    <td><%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></td>
                                    <td>
                                        <span class="status-badge <%= vehiculo.getEstado() ? "active" : "inactive" %>">
                                            <%= vehiculo.getEstado() ? "Activo" : "Inactivo" %>
                                        </span>
                                    </td>
                                    <td class="actions">
                                        <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=ver&id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn btn-sm btn-info" title="Ver detalles">👁️</a>
                                        <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=editar&id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn btn-sm btn-warning" title="Editar">✏️</a>
                                        <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=historial&id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn btn-sm btn-secondary" title="Historial">📋</a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div class="no-data">
                        <p>🚗 No tienes vehículos registrados.</p>
                        <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=registrar" class="btn btn-primary">
                            ➕ Registrar Primer Vehículo
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const filterTabs = document.querySelectorAll('.filter-tab');
            const vehicleRows = document.querySelectorAll('.vehicle-row');
            
            filterTabs.forEach(tab => {
                tab.addEventListener('click', function() {
                    // Remover active de todos los tabs
                    filterTabs.forEach(t => t.classList.remove('active'));
                    // Agregar active al tab clickeado
                    this.classList.add('active');
                    
                    const filter = this.getAttribute('data-filter');
                    
                    // Filtrar filas
                    vehicleRows.forEach(row => {
                        if (filter === 'all') {
                            row.style.display = '';
                        } else if (filter === 'active') {
                            row.style.display = row.getAttribute('data-status') === 'active' ? '' : 'none';
                        } else if (filter === 'inactive') {
                            row.style.display = row.getAttribute('data-status') === 'inactive' ? '' : 'none';
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>