<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Vehículo</title>
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
                <h1>🚗 Detalle del Vehículo</h1>
                <p>Información completa de tu vehículo</p>
            </div>

            <% if (vehiculo != null) { %>
                <div class="detail-section">
                    <div class="detail-card">
                        <div class="detail-header">
                            <h2><%= vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "Vehículo Sin Placa" %></h2>
                            <span class="status-badge <%= vehiculo.getEstado() ? "active" : "inactive" %>">
                                <%= vehiculo.getEstado() ? "Activo" : "Inactivo" %>
                            </span>
                        </div>
                        
                        <div class="detail-grid">
                            <div class="detail-group">
                                <h3>Información Básica</h3>
                                <div class="detail-item">
                                    <strong>Placa:</strong>
                                    <span><%= vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "N/A" %></span>
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
                            </div>
                            
                            <div class="detail-group">
                                <h3>Especificaciones</h3>
                                <div class="detail-item">
                                    <strong>Año:</strong>
                                    <span><%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Kilometraje:</strong>
                                    <span><%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Número de Chasis:</strong>
                                    <span><%= vehiculo.getNumeroChasis() != null ? vehiculo.getNumeroChasis() : "N/A" %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=editar&id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-primary">✏️ Editar Vehículo</a>
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=historial&id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-info">📋 Ver Historial</a>
                    <a href="${pageContext.request.contextPath}/cliente/citas/crear" class="btn btn-success">📅 Agendar Cita</a>
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos" class="btn btn-secondary">↩️ Volver a la Lista</a>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el vehículo solicitado.</p>
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos" class="btn btn-secondary">Volver a la Lista</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>