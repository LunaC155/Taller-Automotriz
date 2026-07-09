<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%@page import="com.upec.model.OrdenServicio" %>
<%@page import="java.util.List" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
    List<OrdenServicio> ordenes = vehiculo != null ? vehiculo.getOrdenServicioList() : null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Historial del Vehículo</title>
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
                <h1>Historial del Vehículo</h1>
                <p>Registro completo de servicios y mantenimientos</p>
            </div>

            <% if (vehiculo != null) { %>
                <!-- Información del vehículo -->
                <div class="vehicle-header">
                    <div class="vehicle-info">
                        <h2><%= vehiculo.getPlaca() %></h2>
                        <p>
                            <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %> 
                            <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %>
                            • <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %>
                            • <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %>
                        </p>
                        <p>
                            <strong>Propietario:</strong> 
                            <%= vehiculo.getIDCliente() != null ? 
                                vehiculo.getIDCliente().getNombre() + " " + vehiculo.getIDCliente().getApellido() : "N/A" %>
                        </p>
                    </div>
                    <div class="vehicle-stats">
                        <div class="stat-item">
                            <strong>Total Servicios:</strong>
                            <span><%= ordenes != null ? ordenes.size() : 0 %></span>
                        </div>
                        <div class="stat-item">
                            <strong>Kilometraje:</strong>
                            <span><%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></span>
                        </div>
                    </div>
                </div>

                <!-- Historial de servicios -->
                <div class="history-section">
                    <h3>📋 Historial de Servicios</h3>
                    
                    <% if (ordenes != null && !ordenes.isEmpty()) { %>
                        <div class="timeline">
                            <% for (OrdenServicio orden : ordenes) { %>
                                <div class="timeline-item">
                                    <div class="timeline-marker"></div>
                                    <div class="timeline-content">
                                        <div class="timeline-header">
                                            <h4>Orden #<%= orden.getIDOrdenServicio() %></h4>
                                            <span class="timeline-date">
                                                <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "Fecha no especificada" %>
                                            </span>
                                        </div>
                                        
                                        <div class="timeline-body">
                                            <% if (orden.getProblemaReportado() != null && !orden.getProblemaReportado().isEmpty()) { %>
                                                <p><strong>Problema Reportado:</strong> <%= orden.getProblemaReportado() %></p>
                                            <% } %>
                                            
                                            <% if (orden.getObservaciones() != null && !orden.getObservaciones().isEmpty()) { %>
                                                <p><strong>Observaciones:</strong> <%= orden.getObservaciones() %></p>
                                            <% } %>
                                            
                                            <div class="timeline-meta">
                                                <span class="status-badge <%= 
                                                    orden.getIDEstadoTrabajo() != null && 
                                                    orden.getIDEstadoTrabajo().getNombreEstado() != null ?
                                                    orden.getIDEstadoTrabajo().getNombreEstado().toLowerCase().replace(" ", "-") : 
                                                    "desconocido" %>">
                                                    <%= orden.getIDEstadoTrabajo() != null ? 
                                                        orden.getIDEstadoTrabajo().getNombreEstado() : "Estado desconocido" %>
                                                </span>
                                                
                                                <% if (orden.getFechaRealSalida() != null) { %>
                                                    <span class="completion-date">
                                                        Completado: <%= orden.getFechaRealSalida() %>
                                                    </span>
                                                <% } %>
                                            </div>
                                        </div>
                                        
                                        <div class="timeline-actions">
                                            <a href="#" class="btn-action btn-view" title="Ver Detalles">👁️</a>
                                            <a href="#" class="btn-action btn-print" title="Imprimir">🖨️</a>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="no-history">
                            <div class="no-history-icon">📭</div>
                            <h3>No hay historial de servicios</h3>
                            <p>Este vehículo no tiene órdenes de servicio registradas.</p>
                        </div>
                    <% } %>
                </div>

                <!-- Resumen estadístico -->
                <div class="stats-summary">
                    <h3>📊 Resumen Estadístico</h3>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <h4>Total de Servicios</h4>
                            <p class="stat-number"><%= ordenes != null ? ordenes.size() : 0 %></p>
                        </div>
                        <div class="stat-card">
                            <h4>Servicios Completados</h4>
                            <p class="stat-number">
                                <% 
                                    int completados = 0;
                                    if (ordenes != null) {
                                        for (OrdenServicio orden : ordenes) {
                                            if (orden.getFechaRealSalida() != null) {
                                                completados++;
                                            }
                                        }
                                    }
                                %>
                                <%= completados %>
                            </p>
                        </div>
                        <div class="stat-card">
                            <h4>Servicios Pendientes</h4>
                            <p class="stat-number">
                                <% 
                                    int pendientes = 0;
                                    if (ordenes != null) {
                                        for (OrdenServicio orden : ordenes) {
                                            if (orden.getFechaRealSalida() == null) {
                                                pendientes++;
                                            }
                                        }
                                    }
                                %>
                                <%= pendientes %>
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Acciones -->
                <div class="action-buttons">
                    <button onclick="window.print()" class="btn btn-secondary">🖨️ Imprimir Historial</button>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos/ver?id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-primary">↩️ Volver al Vehículo</a>
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