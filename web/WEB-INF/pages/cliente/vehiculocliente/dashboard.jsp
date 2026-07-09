<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.Vehiculo" %>
<%
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    Integer totalVehiculos = (Integer) request.getAttribute("totalVehiculos");
    Integer vehiculosActivos = (Integer) request.getAttribute("vehiculosActivos");
    Integer vehiculosConServiciosActivos = (Integer) request.getAttribute("vehiculosConServiciosActivos");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mis Vehículos - Dashboard</title>
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
                <h1>🚗 Mis Vehículos</h1>
                <p>Gestiona y consulta la información de tus vehículos</p>
            </div>

            <!-- Métricas -->
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon">🚗</div>
                    <div class="metric-info">
                        <h3><%= totalVehiculos != null ? totalVehiculos : 0 %></h3>
                        <p>Total Vehículos</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">✅</div>
                    <div class="metric-info">
                        <h3><%= vehiculosActivos != null ? vehiculosActivos : 0 %></h3>
                        <p>Vehículos Activos</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">🔧</div>
                    <div class="metric-info">
                        <h3><%= vehiculosConServiciosActivos != null ? vehiculosConServiciosActivos : 0 %></h3>
                        <p>En Servicio</p>
                    </div>
                </div>
            </div>

            <!-- Acciones Rápidas -->
            <div class="quick-actions">
                <h2 class="section-title">Acciones Rápidas</h2>
                <div class="actions-grid">
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=registrar" class="action-card">
                        <div class="action-icon">➕</div>
                        <h3>Registrar Vehículo</h3>
                        <p>Agregar un nuevo vehículo a tu cuenta</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos" class="action-card">
                        <div class="action-icon">📋</div>
                        <h3>Ver Todos</h3>
                        <p>Lista completa de tus vehículos</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/cliente/citas/crear" class="action-card">
                        <div class="action-icon">📅</div>
                        <h3>Agendar Cita</h3>
                        <p>Programar servicio para un vehículo</p>
                    </a>
                </div>
            </div>

            <!-- Vehículos Recientes -->
            <div class="table-container">
                <h2 class="section-title">Mis Vehículos</h2>
                <% if (vehiculos != null && !vehiculos.isEmpty()) { %>
                    <div class="cards-grid">
                        <% for (Vehiculo vehiculo : vehiculos) { %>
                            <div class="card">
                                <div class="card-header">
                                    <h3><%= vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "Sin Placa" %></h3>
                                    <span class="status-badge <%= vehiculo.getEstado() ? "active" : "inactive" %>">
                                        <%= vehiculo.getEstado() ? "Activo" : "Inactivo" %>
                                    </span>
                                </div>
                                <div class="card-body">
                                    <p><strong>Marca:</strong> <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %></p>
                                    <p><strong>Modelo:</strong> <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %></p>
                                    <p><strong>Color:</strong> <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></p>
                                    <p><strong>Año:</strong> <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></p>
                                    <p><strong>Kilometraje:</strong> <%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></p>
                                </div>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=ver&id=<%= vehiculo.getIDVehiculo() %>" 
                                       class="btn btn-sm btn-info">Ver Detalles</a>
                                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=historial&id=<%= vehiculo.getIDVehiculo() %>" 
                                       class="btn btn-sm btn-secondary">Historial</a>
                                </div>
                            </div>
                        <% } %>
                    </div>
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
</body>
</html>