<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%@page import="com.upec.model.Cliente" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
    Cliente cliente = vehiculo != null ? vehiculo.getIDCliente() : null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Vehículo</title>
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
                <h1>Detalle del Vehículo</h1>
                <p>Información completa del vehículo</p>
            </div>

            <% if (vehiculo != null) { %>
                <!-- Información del vehículo -->
                <div class="detail-section">
                    <div class="detail-card">
                        <h2>🚗 Información del Vehículo</h2>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>ID:</strong>
                                <span><%= vehiculo.getIDVehiculo() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Placa:</strong>
                                <span><%= vehiculo.getPlaca() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Marca:</strong>
                                <span><%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Modelo:</strong>
                                <span><%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Color:</strong>
                                <span><%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Año:</strong>
                                <span><%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Número de Chasis:</strong>
                                <span><%= vehiculo.getNumeroChasis() != null ? vehiculo.getNumeroChasis() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Kilometraje:</strong>
                                <span><%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado:</strong>
                                <span class="badge <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "badge-success" : "badge-danger" %>">
                                    <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "Activo" : "Inactivo" %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Información del propietario -->
                    <% if (cliente != null) { %>
                        <div class="detail-card">
                            <h2>👤 Propietario</h2>
                            <div class="detail-grid">
                                <div class="detail-item">
                                    <strong>Nombre:</strong>
                                    <span><%= cliente.getNombre() %> <%= cliente.getApellido() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Teléfono:</strong>
                                    <span><%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Email:</strong>
                                    <span><%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Acciones:</strong>
                                    <a href="${pageContext.request.contextPath}/admin/clientes/ver?id=<%= cliente.getIDCliente() %>" 
                                       class="btn-action btn-view">👁️ Ver Cliente</a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- Acciones -->
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/admin/vehiculos/editar?id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-primary">✏️ Editar Vehículo</a>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos/asignar-cliente?id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-warning">👤 Cambiar Propietario</a>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos/actualizar-kilometraje?id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-info">📊 Actualizar Kilometraje</a>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos/actualizar-estado?id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-secondary">🔄 Cambiar Estado</a>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos/historial?id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-info">📋 Ver Historial</a>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos" class="btn btn-secondary">↩️ Volver al Listado</a>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el vehículo solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>