<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio recepcion = (OrdenServicio) request.getAttribute("recepcion");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Recepción</title>
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
                <h1>📋 Detalle de Recepción</h1>
                <p>Información completa de la recepción del vehículo</p>
            </div>

            <% if (recepcion != null) { 
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
                
                String estadoClase = "pending";
                String estadoTexto = "Pendiente";
                
                if (recepcion.getFechaRealSalida() != null) {
                    estadoClase = "completed";
                    estadoTexto = "Completada";
                } else if (recepcion.getIDEstadoTrabajo() != null) {
                    estadoTexto = recepcion.getIDEstadoTrabajo().getNombreEstado();
                    if ("EN PROCESO".equals(estadoTexto)) {
                        estadoClase = "in-progress";
                    } else if ("CANCELADA".equals(estadoTexto)) {
                        estadoClase = "cancelled";
                    } else if ("COMPLETADA".equals(estadoTexto)) {
                        estadoClase = "completed";
                    }
                }
            %>
                <div class="reception-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <h2>Recepción #<%= recepcion.getIDOrdenServicio() %></h2>
                        <span class="status-badge <%= estadoClase %>">
                            <%= estadoTexto %>
                        </span>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información del Vehículo -->
                        <div class="detail-card">
                            <h3>🚗 Información del Vehículo</h3>
                            <div class="detail-item">
                                <strong>Vehículo:</strong>
                                <span>
                                    <%= recepcion.getIDVehiculo() != null ? 
                                        recepcion.getIDVehiculo().getPlaca() + " - " + 
                                        (recepcion.getIDVehiculo().getIDMarca() != null ? recepcion.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                        (recepcion.getIDVehiculo().getIDModelo() != null ? recepcion.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "N/A" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Color:</strong>
                                <span><%= recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getColor() != null ? recepcion.getIDVehiculo().getColor() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Año:</strong>
                                <span><%= recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getAnioVehiculo() != null ? recepcion.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Kilometraje:</strong>
                                <span><%= recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getKilometraje() != null ? recepcion.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Número de Chasis:</strong>
                                <span><%= recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getNumeroChasis() != null ? recepcion.getIDVehiculo().getNumeroChasis() : "N/A" %></span>
                            </div>
                        </div>

                        <!-- Información del Cliente -->
                        <div class="detail-card">
                            <h3>👤 Información del Cliente</h3>
                            <% if (recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getIDCliente() != null) { %>
                                <div class="detail-item">
                                    <strong>Cliente:</strong>
                                    <span>
                                        <%= recepcion.getIDVehiculo().getIDCliente().getNombre() %> 
                                        <%= recepcion.getIDVehiculo().getIDCliente().getApellido() %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Teléfono:</strong>
                                    <span><%= recepcion.getIDVehiculo().getIDCliente().getTelefono() != null ? recepcion.getIDVehiculo().getIDCliente().getTelefono() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Email:</strong>
                                    <span><%= recepcion.getIDVehiculo().getIDCliente().getEmail() != null ? recepcion.getIDVehiculo().getIDCliente().getEmail() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Dirección:</strong>
                                    <span><%= recepcion.getIDVehiculo().getIDCliente().getDireccion() != null ? recepcion.getIDVehiculo().getIDCliente().getDireccion() : "N/A" %></span>
                                </div>
                            <% } else { %>
                                <div class="detail-item">
                                    <span>Información del cliente no disponible</span>
                                </div>
                            <% } %>
                        </div>

                        <!-- Información de la Recepción -->
                        <div class="detail-card">
                            <h3>📅 Información de la Recepción</h3>
                            <div class="detail-item">
                                <strong>Fecha de Entrada:</strong>
                                <span><%= recepcion.getFechaEntrada() != null ? sdf.format(recepcion.getFechaEntrada()) : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Estimada Salida:</strong>
                                <span><%= recepcion.getFechaEstimadaSalida() != null ? sdfDate.format(recepcion.getFechaEstimadaSalida()) : "Por definir" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Real Salida:</strong>
                                <span><%= recepcion.getFechaRealSalida() != null ? sdf.format(recepcion.getFechaRealSalida()) : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado del Trabajo:</strong>
                                <span><%= recepcion.getIDEstadoTrabajo() != null ? recepcion.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Recepcionista:</strong>
                                <span>
                                    <%= recepcion.getIDEmpleadoRecepcion() != null ? 
                                        recepcion.getIDEmpleadoRecepcion().getNombre() + " " + recepcion.getIDEmpleadoRecepcion().getApellido() : "N/A" %>
                                </span>
                            </div>
                        </div>

                        <!-- Información del Servicio -->
                        <div class="detail-card">
                            <h3>🔧 Información del Servicio</h3>
                            <div class="detail-item">
                                <strong>Problema Reportado:</strong>
                                <span><%= recepcion.getProblemaReportado() != null ? recepcion.getProblemaReportado() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Observaciones:</strong>
                                <span><%= recepcion.getObservaciones() != null ? recepcion.getObservaciones() : "Ninguna" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Información de Contacto del Cliente -->
                    <% if (recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getIDCliente() != null) { %>
                        <div class="client-contact">
                            <h3>📞 Información de Contacto</h3>
                            <div class="contact-info">
                                <div>
                                    <strong>Teléfono Principal:</strong><br>
                                    <%= recepcion.getIDVehiculo().getIDCliente().getTelefono() != null ? 
                                        recepcion.getIDVehiculo().getIDCliente().getTelefono() : "N/A" %>
                                </div>
                                <div>
                                    <strong>Email:</strong><br>
                                    <%= recepcion.getIDVehiculo().getIDCliente().getEmail() != null ? 
                                        recepcion.getIDVehiculo().getIDCliente().getEmail() : "N/A" %>
                                </div>
                                <div>
                                    <strong>Dirección:</strong><br>
                                    <%= recepcion.getIDVehiculo().getIDCliente().getDireccion() != null ? 
                                        recepcion.getIDVehiculo().getIDCliente().getDireccion() : "N/A" %>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <!-- Progreso del Servicio -->
                    <div class="progress-section">
                        <h3>📊 Progreso del Servicio</h3>
                        <div class="progress-timeline">
                            <div class="timeline-step <%= recepcion.getFechaEntrada() != null ? "completed" : "" %>">
                                <div class="step-icon">1</div>
                                <div class="step-info">
                                    <h4>Recepción</h4>
                                    <p><%= recepcion.getFechaEntrada() != null ? sdf.format(recepcion.getFechaEntrada()) : "Pendiente" %></p>
                                    <p>El vehículo ha sido recibido en el taller</p>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= recepcion.getFechaRealSalida() != null ? "completed" : 
                                                       (recepcion.getFechaEntrada() != null && recepcion.getFechaEntrada().before(new Date()) ? "active" : "") %>">
                                <div class="step-icon">2</div>
                                <div class="step-info">
                                    <h4>Diagnóstico y Reparación</h4>
                                    <p>En proceso</p>
                                    <p>El vehículo está siendo diagnosticado y reparado</p>
                                    <% if (recepcion.getIDEstadoTrabajo() != null) { %>
                                        <span class="status-indicator"><%= recepcion.getIDEstadoTrabajo().getNombreEstado() %></span>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= recepcion.getFechaRealSalida() != null ? "completed" : "" %>">
                                <div class="step-icon">3</div>
                                <div class="step-info">
                                    <h4>Completado</h4>
                                    <p><%= recepcion.getFechaRealSalida() != null ? sdf.format(recepcion.getFechaRealSalida()) : 
                                          (recepcion.getFechaEstimadaSalida() != null ? "Estimado: " + sdfDate.format(recepcion.getFechaEstimadaSalida()) : "Por definir") %></p>
                                    <p>El vehículo está listo para ser entregado</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Diagnósticos Asociados -->
                    <% if (recepcion.getDiagnosticoList() != null && !recepcion.getDiagnosticoList().isEmpty()) { %>
                        <div class="diagnostic-section">
                            <h3>🔍 Diagnósticos Asociados</h3>
                            <p>Esta recepción tiene <%= recepcion.getDiagnosticoList().size() %> diagnóstico(s) asociado(s).</p>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/ver?orden=<%= recepcion.getIDOrdenServicio() %>" 
                               class="btn btn-info">Ver Diagnósticos</a>
                        </div>
                    <% } else if (recepcion.getFechaRealSalida() == null) { %>
                        <div class="diagnostic-section">
                            <h3>🔍 Diagnósticos</h3>
                            <p>No se han realizado diagnósticos para esta recepción.</p>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/nuevo?orden=<%= recepcion.getIDOrdenServicio() %>" 
                               class="btn btn-primary">Crear Diagnóstico</a>
                        </div>
                    <% } %>

                    <!-- Factura Asociada -->
                    <% if (recepcion.getFacturaList() != null && !recepcion.getFacturaList().isEmpty()) { %>
                        <div class="invoice-section">
                            <h3>🧾 Factura Asociada</h3>
                            <p>Esta recepción ya ha sido facturada.</p>
                            <a href="${pageContext.request.contextPath}/facturacion/ver?orden=<%= recepcion.getIDOrdenServicio() %>" 
                               class="btn btn-success">Ver Factura</a>
                        </div>
                    <% } else if (recepcion.getFechaRealSalida() != null) { %>
                        <div class="invoice-section">
                            <h3>🧾 Facturación</h3>
                            <p>Esta recepción está lista para ser facturada.</p>
                            <a href="${pageContext.request.contextPath}/facturacion/generar?orden=<%= recepcion.getIDOrdenServicio() %>" 
                               class="btn btn-success">Generar Factura</a>
                        </div>
                    <% } %>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/recepcionista/recepcion/editar?id=<%= recepcion.getIDOrdenServicio() %>" 
                           class="btn btn-warning">✏️ Editar Recepción</a>
                        
                        <% if (recepcion.getFechaRealSalida() == null) { %>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/nuevo?orden=<%= recepcion.getIDOrdenServicio() %>" 
                               class="btn btn-primary">🔧 Crear Diagnóstico</a>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/recepcionista/recepcion" class="btn btn-secondary">↩️ Volver a Recepciones</a>
                        
                        <% if (recepcion.getFechaRealSalida() != null) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/reportes/recepcion?id=<%= recepcion.getIDOrdenServicio() %>" 
                               class="btn btn-info">📊 Generar Reporte</a>
                        <% } %>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la recepción solicitada.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/recepcion" class="btn btn-secondary">Volver a Recepciones</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>