<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico, com.upec.model.OrdenServicio" %>
<%@page import="java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
    List<Diagnostico> diagnosticos = (List<Diagnostico>) request.getAttribute("diagnosticos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Diagnósticos por Orden - Taller Automotriz</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudmecanico.css">
  
</head>
<body class="mecanico">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-mecanico.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>📋 Diagnósticos por Orden</h1>
                <p>Diagnósticos técnicos asociados a una orden de servicio específica</p>
            </div>

            <% if (orden != null) { %>
                <!-- Información de la Orden -->
                <div class="order-header">
                    <div class="order-title">
                        <h2>Orden de Servicio #<%= orden.getIDOrdenServicio() %></h2>
                        <span class="order-status">
                            <%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "PENDIENTE" %>
                        </span>
                    </div>
                    
                    <div class="order-details-grid">
                        <div class="order-detail-item">
                            <strong>Vehículo</strong>
                            <span>
                                <% if (orden.getIDVehiculo() != null) { %>
                                    <%= orden.getIDVehiculo().getPlaca() %> - 
                                    <%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                    <%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                <% } else { %>
                                    N/A
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="order-detail-item">
                            <strong>Cliente</strong>
                            <span>
                                <% if (orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null) { %>
                                    <%= orden.getIDVehiculo().getIDCliente().getNombre() %> 
                                    <%= orden.getIDVehiculo().getIDCliente().getApellido() %>
                                <% } else { %>
                                    N/A
                                <% } %>
                            </span>
                        </div>
                        
                        <div class="order-detail-item">
                            <strong>Fecha de Entrada</strong>
                            <span><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></span>
                        </div>
                        
                        <div class="order-detail-item">
                            <strong>Fecha Estimada Salida</strong>
                            <span><%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %></span>
                        </div>
                    </div>
                    
                    <div class="order-detail-item">
                        <strong>Problema Reportado</strong>
                        <span><%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "No especificado" %></span>
                    </div>
                    
                    <% if (orden.getObservaciones() != null && !orden.getObservaciones().isEmpty()) { %>
                        <div class="order-detail-item">
                            <strong>Observaciones</strong>
                            <span><%= orden.getObservaciones() %></span>
                        </div>
                    <% } %>
                </div>

                <!-- Acciones Globales -->
                <div class="action-buttons-global">
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/crear" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Nuevo Diagnóstico para esta Orden
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/mis-diagnosticos" class="btn btn-info">
                        <span class="btn-icon">👤</span> Mis Diagnósticos
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-secondary">
                        <span class="btn-icon">📋</span> Todos los Diagnósticos
                    </a>
                </div>

                <!-- Lista de Diagnósticos -->
                <div class="diagnostics-list">
                    <% if (diagnosticos == null || diagnosticos.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">🔍</div>
                            <h3>No hay diagnósticos para esta orden</h3>
                            <p>No se han registrado diagnósticos técnicos para esta orden de servicio.</p>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/crear" class="btn btn-primary">
                                Crear Primer Diagnóstico
                            </a>
                        </div>
                    <% } else { %>
                        <% for (Diagnostico diagnostico : diagnosticos) { %>
                            <div class="diagnostic-card">
                                <div class="diagnostic-header">
                                    <div class="diagnostic-title">
                                        <h3>Diagnóstico #<%= diagnostico.getIDDiagnostico() %></h3>
                                        <div class="diagnostic-meta">
                                            Realizado por: 
                                            <% if (diagnostico.getIDEmpleadoMecanico() != null) { %>
                                                <strong><%= diagnostico.getIDEmpleadoMecanico().getNombre() %> 
                                                <%= diagnostico.getIDEmpleadoMecanico().getApellido() %></strong>
                                            <% } else { %>
                                                <em>Mecánico no asignado</em>
                                            <% } %>
                                            • 
                                            <%= diagnostico.getFechaDiagnostico() != null ? 
                                                new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(diagnostico.getFechaDiagnostico()) : 
                                                "Fecha no especificada" %>
                                        </div>
                                    </div>
                                    <span class="diagnostic-status <%= diagnostico.getFechaDiagnostico() != null ? "status-completed" : "status-pending" %>">
                                        <%= diagnostico.getFechaDiagnostico() != null ? "Completado" : "Pendiente" %>
                                    </span>
                                </div>
                                
                                <div class="diagnostic-content">
                                    <h4>🔍 Descripción del Diagnóstico</h4>
                                    <div class="diagnostic-description">
                                        <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                            diagnostico.getDescripcionDiagnostico() : 
                                            "<em>No se ha registrado una descripción del diagnóstico.</em>" %>
                                    </div>
                                    
                                    <% if (diagnostico.getRecomendaciones() != null && !diagnostico.getRecomendaciones().isEmpty()) { %>
                                        <div class="diagnostic-recommendations">
                                            <h4>💡 Recomendaciones y Reparaciones</h4>
                                            <div class="recommendations-content">
                                                <%= diagnostico.getRecomendaciones() %>
                                            </div>
                                        </div>
                                    <% } else { %>
                                        <div class="no-recommendations">
                                            No se han registrado recomendaciones para este diagnóstico.
                                        </div>
                                    <% } %>
                                </div>
                                
                                <div class="diagnostic-actions">
                                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/ver?id=<%= diagnostico.getIDDiagnostico() %>" 
                                       class="btn btn-sm btn-info">
                                        👁️ Ver Detalles
                                    </a>
                                    
                                    <% if (diagnostico.getIDEmpleadoMecanico() != null && 
                                           diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(session.getAttribute("idEmpleado"))) { %>
                                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/editar?id=<%= diagnostico.getIDDiagnostico() %>" 
                                           class="btn btn-sm btn-warning">
                                            ✏️ Editar
                                        </a>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                        
                        <!-- Resumen -->
                        <div class="table-info" style="margin-top: 20px;">
                            <p>Total de diagnósticos para esta orden: <strong><%= diagnosticos.size() %></strong></p>
                            <p>
                                <span class="badge badge-success">Completados: <%= diagnosticos.stream().filter(d -> d.getFechaDiagnostico() != null).count() %></span>
                                <span class="badge badge-warning">Pendientes: <%= diagnosticos.stream().filter(d -> d.getFechaDiagnostico() == null).count() %></span>
                                <span class="badge badge-info">Mecánicos diferentes: <%= diagnosticos.stream().map(d -> d.getIDEmpleadoMecanico()).distinct().count() %></span>
                            </p>
                        </div>
                    <% } %>
                </div>

            <% } else { %>
                <div class="empty-state">
                    <div class="empty-icon">❌</div>
                    <h3>Orden no encontrada</h3>
                    <p>No se pudo encontrar la orden de servicio solicitada.</p>
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-secondary">
                        Volver a Diagnósticos
                    </a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>