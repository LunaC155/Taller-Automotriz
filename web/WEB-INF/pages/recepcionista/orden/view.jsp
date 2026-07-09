<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio" %>
<%@page import="java.util.Date" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Orden - Recepcionista</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
  
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>🔧 Detalle de Orden de Servicio</h1>
                <p>Información completa de la orden de servicio</p>
            </div>

            <% if (orden != null) { 
                String estadoClase = "pending";
                String estadoTexto = "PENDIENTE";
                
                if (orden.getFechaRealSalida() != null) {
                    estadoClase = "completed";
                    estadoTexto = "COMPLETADA";
                } else if (orden.getIDEstadoTrabajo() != null) {
                    estadoTexto = orden.getIDEstadoTrabajo().getNombreEstado();
                    if ("EN PROCESO".equals(estadoTexto)) {
                        estadoClase = "in-progress";
                    } else if ("CANCELADA".equals(estadoTexto)) {
                        estadoClase = "cancelled";
                    } else if ("CITA PROGRAMADA".equals(estadoTexto)) {
                        estadoClase = "pending";
                    }
                }
            %>
                <div class="order-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <h2>Orden #<%= orden.getIDOrdenServicio() %></h2>
                        <span class="status-badge <%= estadoClase %>">
                            <%= estadoTexto %>
                        </span>
                    </div>

                    <!-- Progreso del Servicio -->
                    <div class="progress-section">
                        <h3>📊 Progreso del Servicio</h3>
                        <div class="progress-timeline">
                            <div class="timeline-step <%= orden.getFechaEntrada() != null ? "completed" : "" %>">
                                <div class="step-icon">1</div>
                                <div class="step-info">
                                    <h4>Recepción</h4>
                                    <p><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "Pendiente" %></p>
                                    <p>Vehículo recibido en el taller</p>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= orden.getFechaRealSalida() != null ? "completed" : 
                                                       (orden.getFechaEntrada() != null && orden.getFechaEntrada().before(new Date()) ? "active" : "") %>">
                                <div class="step-icon">2</div>
                                <div class="step-info">
                                    <h4>Diagnóstico y Reparación</h4>
                                    <p>En proceso</p>
                                    <p>Vehículo en diagnóstico/reparación</p>
                                    <% if (orden.getIDEstadoTrabajo() != null) { %>
                                        <span class="status-indicator"><%= orden.getIDEstadoTrabajo().getNombreEstado() %></span>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= orden.getFechaRealSalida() != null ? "completed" : "" %>">
                                <div class="step-icon">3</div>
                                <div class="step-info">
                                    <h4>Completado</h4>
                                    <p><%= orden.getFechaRealSalida() != null ? orden.getFechaRealSalida() : 
                                          (orden.getFechaEstimadaSalida() != null ? "Estimado: " + orden.getFechaEstimadaSalida() : "Por definir") %></p>
                                    <p>Vehículo listo para entrega</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información del Vehículo -->
                        <div class="detail-card">
                            <h3>🚗 Información del Vehículo</h3>
                            <div class="detail-item">
                                <strong>Vehículo:</strong>
                                <span>
                                    <% if (orden.getIDVehiculo() != null) { %>
                                        <%= orden.getIDVehiculo().getPlaca() %> - 
                                        <%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                        <%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                    <% } else { %>
                                        <span class="badge badge-warning">Por asignar</span>
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Cliente:</strong>
                                <span>
                                    <% if (orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null) { %>
                                        <%= orden.getIDVehiculo().getIDCliente().getNombre() %> 
                                        <%= orden.getIDVehiculo().getIDCliente().getApellido() %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Color:</strong>
                                <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getColor() != null ? orden.getIDVehiculo().getColor() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Año:</strong>
                                <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getAnioVehiculo() != null ? orden.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Kilometraje:</strong>
                                <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getKilometraje() != null ? orden.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                            </div>
                        </div>

                        <!-- Información de la Orden -->
                        <div class="detail-card">
                            <h3>📅 Información de la Orden</h3>
                            <div class="detail-item">
                                <strong>Fecha de Entrada:</strong>
                                <span><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Estimada Salida:</strong>
                                <span><%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Real Salida:</strong>
                                <span><%= orden.getFechaRealSalida() != null ? orden.getFechaRealSalida() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado:</strong>
                                <span><%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Recepcionista:</strong>
                                <span>
                                    <% if (orden.getIDEmpleadoRecepcion() != null) { %>
                                        <%= orden.getIDEmpleadoRecepcion().getNombre() %> 
                                        <%= orden.getIDEmpleadoRecepcion().getApellido() %>
                                    <% } else { %>
                                        Por asignar
                                    <% } %>
                                </span>
                            </div>
                        </div>

                        <!-- Información del Servicio -->
                        <div class="detail-card">
                            <h3>🔧 Información del Servicio</h3>
                            <div class="detail-item">
                                <strong>Problema Reportado:</strong>
                                <span><%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Observaciones:</strong>
                                <span><%= orden.getObservaciones() != null ? orden.getObservaciones() : "Ninguna" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Diagnósticos -->
                    <% if (orden.getDiagnosticoList() != null && !orden.getDiagnosticoList().isEmpty()) { %>
                        <div class="diagnostic-section">
                            <h3>🔍 Diagnósticos Realizados</h3>
                            <% for (com.upec.model.Diagnostico diagnostico : orden.getDiagnosticoList()) { %>
                                <div class="detail-item">
                                    <strong>Diagnóstico:</strong>
                                    <span>
                                        <%= diagnostico.getDescripcionDiagnostico() != null ? diagnostico.getDescripcionDiagnostico() : "N/A" %>
                                        <% if (diagnostico.getIDEmpleadoMecanico() != null) { %>
                                            <br><small>Por: <%= diagnostico.getIDEmpleadoMecanico().getNombre() %> <%= diagnostico.getIDEmpleadoMecanico().getApellido() %></small>
                                        <% } %>
                                    </span>
                                </div>
                            <% } %>
                        </div>
                    <% } %>

                    <!-- Factura Asociada -->
                    <% if (orden.getFacturaList() != null && !orden.getFacturaList().isEmpty()) { %>
                        <div class="invoice-section">
                            <h3>🧾 Factura Asociada</h3>
                            <% for (com.upec.model.Factura factura : orden.getFacturaList()) { %>
                                <div class="detail-item">
                                    <strong>Factura #<%= factura.getIDFactura() %>:</strong>
                                    <span>
                                        Total: $<%= factura.getTotal() != null ? factura.getTotal() : "0.00" %>
                                        <a href="${pageContext.request.contextPath}/recepcionista/facturas/ver?id=<%= factura.getIDFactura() %>" 
                                           class="btn btn-sm btn-success">Ver Factura</a>
                                    </span>
                                </div>
                            <% } %>
                        </div>
                    <% } else if (orden.getFechaRealSalida() != null) { %>
                        <div class="invoice-section">
                            <h3>🧾 Facturación</h3>
                            <p>Esta orden está completada pero no tiene factura asociada.</p>
                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/crear?orden=<%= orden.getIDOrdenServicio() %>" 
                               class="btn btn-success">Generar Factura</a>
                        </div>
                    <% } %>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes/editar?id=<%= orden.getIDOrdenServicio() %>" 
                           class="btn btn-warning">✏️ Editar Orden</a>
                        
                        <% if (orden.getIDVehiculo() == null) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/asignar-vehiculo?id=<%= orden.getIDOrdenServicio() %>" 
                               class="btn btn-primary">🚗 Asignar Vehículo</a>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">↩️ Volver a Órdenes</a>
                        
                        <% if (orden.getFechaRealSalida() == null) { %>
                            <form action="${pageContext.request.contextPath}/recepcionista/ordenes/completar" method="post" style="display: inline;">
                                <input type="hidden" name="id" value="<%= orden.getIDOrdenServicio() %>">
                                <button type="submit" class="btn btn-success"
                                   onclick="return confirm('¿Marcar esta orden como completada?')">✅ Completar Orden</button>
                            </form>
                        <% } %>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la orden solicitada.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">Volver a Órdenes</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>