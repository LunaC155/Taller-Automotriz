<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico, java.util.Date" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
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
    <title>Detalle de Reporte Técnico - Taller Automotriz</title>
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
                <h1>📄 Detalle de Reporte Técnico</h1>
                <p>Información completa del reporte técnico generado</p>
            </div>

            <% if (diagnostico != null) { %>
                <div class="report-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <h2>Reporte Técnico #<%= diagnostico.getIDDiagnostico() %></h2>
                        <span class="report-badge">
                            <%= diagnostico.getFechaDiagnostico() != null ? "COMPLETADO" : "PENDIENTE" %>
                        </span>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información de la Orden -->
                        <div class="detail-card">
                            <h3>📋 Información de la Orden</h3>
                            <div class="detail-item">
                                <strong>Número de Orden:</strong>
                                <span>#<%= diagnostico.getIDOrdenServicio().getIDOrdenServicio() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Problema Reportado:</strong>
                                <span><%= diagnostico.getIDOrdenServicio().getProblemaReportado() != null ? 
                                       diagnostico.getIDOrdenServicio().getProblemaReportado() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha de Entrada:</strong>
                                <span><%= diagnostico.getIDOrdenServicio().getFechaEntrada() != null ? 
                                       diagnostico.getIDOrdenServicio().getFechaEntrada() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado del Trabajo:</strong>
                                <span><%= diagnostico.getIDOrdenServicio().getIDEstadoTrabajo() != null ? 
                                       diagnostico.getIDOrdenServicio().getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                        </div>

                        <!-- Información del Vehículo -->
                        <div class="detail-card">
                            <h3>🚗 Información del Vehículo</h3>
                            <% if (diagnostico.getIDOrdenServicio().getIDVehiculo() != null) { %>
                                <div class="detail-item">
                                    <strong>Placa:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getPlaca() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Marca:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null ? 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Modelo:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null ? 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Color:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getColor() != null ? 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo().getColor() : "N/A" %></span>
                                </div>
                            <% } else { %>
                                <p>Información del vehículo no disponible</p>
                            <% } %>
                        </div>

                        <!-- Información del Cliente -->
                        <div class="detail-card">
                            <h3>👤 Información del Cliente</h3>
                            <% if (diagnostico.getIDOrdenServicio().getIDVehiculo() != null && 
                                  diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) { %>
                                <div class="detail-item">
                                    <strong>Cliente:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getNombre() %> 
                                          <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getApellido() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Teléfono:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getTelefono() != null ? 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getTelefono() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Email:</strong>
                                    <span><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getEmail() != null ? 
                                           diagnostico.getIDOrdenServicio().getIDVehiculo().getIDCliente().getEmail() : "N/A" %></span>
                                </div>
                            <% } else { %>
                                <p>Información del cliente no disponible</p>
                            <% } %>
                        </div>
                    </div>

                    <!-- Diagnóstico Técnico -->
                    <div class="content-section">
                        <h3>🔍 Diagnóstico Técnico</h3>
                        <div class="diagnostico-content">
                            <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                diagnostico.getDescripcionDiagnostico() : 
                                "No se ha registrado diagnóstico técnico." %>
                        </div>
                    </div>

                    <!-- Recomendaciones -->
                    <% if (diagnostico.getRecomendaciones() != null && !diagnostico.getRecomendaciones().trim().isEmpty()) { %>
                        <div class="content-section">
                            <h3>💡 Recomendaciones y Observaciones</h3>
                            <div class="recomendaciones-content">
                                <%= diagnostico.getRecomendaciones() %>
                            </div>
                        </div>
                    <% } %>

                    <!-- Información Técnica -->
                    <div class="technical-info">
                        <h4>📊 Información Técnica del Reporte</h4>
                        <div class="metadata-info">
                            <div class="metadata-item">
                                <strong>Mecánico Responsable:</strong>
                                <span>
                                    <%= diagnostico.getIDEmpleadoMecanico() != null ? 
                                        diagnostico.getIDEmpleadoMecanico().getNombre() + " " + 
                                        diagnostico.getIDEmpleadoMecanico().getApellido() : "No asignado" %>
                                </span>
                            </div>
                            <div class="metadata-item">
                                <strong>Fecha del Diagnóstico:</strong>
                                <span><%= diagnostico.getFechaDiagnostico() != null ? 
                                       diagnostico.getFechaDiagnostico() : "Pendiente" %></span>
                            </div>
                            <div class="metadata-item">
                                <strong>Recepcionista:</strong>
                                <span>
                                    <%= diagnostico.getIDOrdenServicio().getIDEmpleadoRecepcion() != null ? 
                                        diagnostico.getIDOrdenServicio().getIDEmpleadoRecepcion().getNombre() + " " + 
                                        diagnostico.getIDOrdenServicio().getIDEmpleadoRecepcion().getApellido() : "No asignado" %>
                                </span>
                            </div>
                            <div class="metadata-item">
                                <strong>Longitud del Diagnóstico:</strong>
                                <span><%= diagnostico.getDescripcionDiagnostico() != null ? 
                                       diagnostico.getDescripcionDiagnostico().length() + " caracteres" : "0 caracteres" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Sección de Impresión -->
                    <div class="print-section">
                        <button onclick="window.print()" class="btn btn-primary">
                            🖨️ Imprimir Reporte
                        </button>
                        <small class="form-text" style="display: block; margin-top: 10px;">
                            Use este botón para imprimir una versión formal del reporte técnico
                        </small>
                    </div>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/mis-reportes" 
                           class="btn btn-secondary">↩️ Volver a Mis Reportes</a>
                        
                        <% if (diagnostico.getIDEmpleadoMecanico() != null && 
                              diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(session.getAttribute("idEmpleado"))) { %>
                            <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/generar?orden=<%= diagnostico.getIDOrdenServicio().getIDOrdenServicio() %>" 
                               class="btn btn-warning">✏️ Editar Reporte</a>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/estadisticas" 
                           class="btn btn-info">📈 Ver Estadísticas</a>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el reporte técnico solicitado.</p>
                    <p>Es posible que el reporte no exista o no tenga permisos para verlo.</p>
                    <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/mis-reportes" class="btn btn-secondary">
                        Volver a Mis Reportes
                    </a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <!-- Estilos para impresión -->
    <style media="print">
        @media print {
            .main-content-with-sidebar, .report-detail {
                margin: 0;
                padding: 0;
                box-shadow: none;
            }
            
            .header, .sidebar-mecanico, .footer, .action-buttons, .print-section,
            .page-header, .messages {
                display: none !important;
            }
            
            .report-detail {
                border: none;
                padding: 20px;
            }
            
            .detail-header {
                border-bottom: 2px solid #000;
            }
            
            .detail-card {
                background: white;
                border: 1px solid #000;
                page-break-inside: avoid;
            }
            
            .content-section {
                background: white;
                border: 1px solid #000;
                page-break-inside: avoid;
            }
            
            .diagnostico-content, .recomendaciones-content {
                border: 1px solid #ccc;
            }
            
            .technical-info {
                background: #f0f0f0;
                border: 1px solid #ccc;
            }
            
            body {
                font-size: 12pt;
                line-height: 1.4;
            }
            
            h1, h2, h3 {
                color: #000 !important;
            }
        }
    </style>
</body>
</html>