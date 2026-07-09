
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Diagnostico diagnostico = (Diagnostico) request.getAttribute("diagnostico");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Diagnóstico - Taller Automotriz</title>
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
                <h1>🔍 Detalle de Diagnóstico</h1>
                <p>Información completa del diagnóstico técnico</p>
            </div>

            <% if (diagnostico != null) { %>
                <div class="diagnostic-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <h2>Diagnóstico #<%= diagnostico.getIDDiagnostico() %></h2>
                        <span class="status-badge <%= diagnostico.getFechaDiagnostico() != null ? "completed" : "pending" %>">
                            <%= diagnostico.getFechaDiagnostico() != null ? "Completado" : "Pendiente" %>
                        </span>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información de la Orden -->
                        <div class="detail-card">
                            <h3>📋 Información de la Orden</h3>
                            <div class="detail-item">
                                <strong>Orden #:</strong>
                                <span><%= diagnostico.getIDOrdenServicio() != null ? diagnostico.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado:</strong>
                                <span>
                                    <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDEstadoTrabajo() != null) { %>
                                        <span class="badge badge-info"><%= diagnostico.getIDOrdenServicio().getIDEstadoTrabajo().getNombreEstado() %></span>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Problema Reportado:</strong>
                                <span><%= diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getProblemaReportado() != null ? 
                                       diagnostico.getIDOrdenServicio().getProblemaReportado() : "N/A" %></span>
                            </div>
                        </div>

                        <!-- Información del Vehículo -->
                        <div class="detail-card">
                            <h3>🚗 Información del Vehículo</h3>
                            <div class="detail-item">
                                <strong>Vehículo:</strong>
                                <span>
                                    <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDVehiculo() != null) { %>
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getPlaca() %> - 
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null ? 
                                            diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null ? 
                                            diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Cliente:</strong>
                                <span>
                                    <% if (diagnostico.getIDOrdenServicio() != null && 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo() != null && 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) { %>
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getNombre() %> 
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getApellido() %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                        </div>

                        <!-- Información del Diagnóstico -->
                        <div class="detail-card">
                            <h3>👤 Información del Diagnóstico</h3>
                            <div class="detail-item">
                                <strong>Mecánico:</strong>
                                <span>
                                    <% if (diagnostico.getIDEmpleadoMecanico() != null) { %>
                                        <%= diagnostico.getIDEmpleadoMecanico().getNombre() %> 
                                        <%= diagnostico.getIDEmpleadoMecanico().getApellido() %>
                                    <% } else { %>
                                        No asignado
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Diagnóstico:</strong>
                                <span>
                                    <%= diagnostico.getFechaDiagnostico() != null ? 
                                        new SimpleDateFormat("dd/MM/yyyy HH:mm").format(diagnostico.getFechaDiagnostico()) : 
                                        "Pendiente" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha de Creación:</strong>
                                <span>Registro en sistema</span>
                            </div>
                        </div>
                    </div>

                    <!-- Descripción del Diagnóstico -->
                    <div class="content-section">
                        <h3>🔍 Descripción del Diagnóstico</h3>
                        <% if (diagnostico.getDescripcionDiagnostico() != null && !diagnostico.getDescripcionDiagnostico().isEmpty()) { %>
                            <div class="diagnostic-content">
                                <%= diagnostico.getDescripcionDiagnostico() %>
                            </div>
                            
                            <!-- Análisis de la Descripción -->
                            <div style="margin-top: 15px; padding: 15px; background: #f8f9fa; border-radius: 6px;">
                                <h4>📊 Análisis del Diagnóstico</h4>
                                <div class="detail-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 15px 0;">
                                    <div class="detail-item">
                                        <strong>Longitud:</strong>
                                        <span><%= diagnostico.getDescripcionDiagnostico().length() %> caracteres</span>
                                    </div>
                                    <div class="detail-item">
                                        <strong>Palabras:</strong>
                                        <span><%= diagnostico.getDescripcionDiagnostico().split("\\s+").length %> palabras</span>
                                    </div>
                                    <div class="detail-item">
                                        <strong>Líneas:</strong>
                                        <span><%= diagnostico.getDescripcionDiagnostico().split("\r\n|\r|\n").length %> líneas</span>
                                    </div>
                                </div>
                            </div>
                        <% } else { %>
                            <div class="no-content">
                                <p>No se ha registrado una descripción del diagnóstico.</p>
                            </div>
                        <% } %>
                    </div>

                    <!-- Recomendaciones -->
                    <div class="content-section">
                        <h3>💡 Recomendaciones y Reparaciones</h3>
                        <% if (diagnostico.getRecomendaciones() != null && !diagnostico.getRecomendaciones().isEmpty()) { %>
                            <div class="recommendations-content">
                                <%= diagnostico.getRecomendaciones() %>
                            </div>
                            
                            <!-- Timeline de Reparaciones Sugeridas -->
                            <div style="margin-top: 20px;">
                                <h4>⏱️ Proceso de Reparación Sugerido</h4>
                                <div class="timeline">
                                    <div class="timeline-item">
                                        <strong>Diagnóstico Completo</strong>
                                        <p>Análisis técnico realizado y problemas identificados</p>
                                    </div>
                                    <div class="timeline-item">
                                        <strong>Reparaciones Prioritarias</strong>
                                        <p>Actividades críticas para la seguridad y funcionamiento</p>
                                    </div>
                                    <div class="timeline-item">
                                        <strong>Mantenimiento Preventivo</strong>
                                        <p>Servicios recomendados para prevención futura</p>
                                    </div>
                                    <div class="timeline-item">
                                        <strong>Verificación Final</strong>
                                        <p>Pruebas y controles de calidad post-reparación</p>
                                    </div>
                                </div>
                            </div>
                        <% } else { %>
                            <div class="no-content">
                                <p>No se han registrado recomendaciones para este diagnóstico.</p>
                            </div>
                        <% } %>
                    </div>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <% if (diagnostico.getIDEmpleadoMecanico() != null && 
                               diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(session.getAttribute("idEmpleado"))) { %>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/editar?id=<%= diagnostico.getIDDiagnostico() %>" 
                               class="btn btn-warning">✏️ Editar Diagnóstico</a>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/por-orden?idOrden=<%= diagnostico.getIDOrdenServicio() != null ? diagnostico.getIDOrdenServicio().getIDOrdenServicio() : "" %>" 
                           class="btn btn-info">📋 Ver Diagnósticos de la Orden</a>
                        
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-secondary">↩️ Volver a Mis Diagnósticos</a>
                        
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-primary">📊 Ver Todos los Diagnósticos</a>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el diagnóstico solicitado.</p>
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/mis-diagnosticos" class="btn btn-secondary">Volver a Mis Diagnósticos</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>