<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio" %>
<%@page import="java.util.Date" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 4) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio cita = (OrdenServicio) request.getAttribute("cita");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Cita</title>
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
                <h1>📅 Detalle de Cita</h1>
                <p>Información completa de tu cita programada</p>
            </div>

            <% if (cita != null) { 
                String estadoClase = "upcoming";
                String estadoTexto = "Próxima";
                
                if (cita.getFechaRealSalida() != null) {
                    estadoClase = "completed";
                    estadoTexto = "Completada";
                } else if (cita.getFechaEntrada() != null && cita.getFechaEntrada().before(new Date())) {
                    estadoClase = "in-progress";
                    estadoTexto = "En Proceso";
                }
            %>
                <div class="appointment-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <h2>Cita #<%= cita.getIDOrdenServicio() %></h2>
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
                                    <%= cita.getIDVehiculo() != null ? 
                                        cita.getIDVehiculo().getPlaca() + " - " + 
                                        (cita.getIDVehiculo().getIDMarca() != null ? cita.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                        (cita.getIDVehiculo().getIDModelo() != null ? cita.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "N/A" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Color:</strong>
                                <span><%= cita.getIDVehiculo() != null && cita.getIDVehiculo().getColor() != null ? cita.getIDVehiculo().getColor() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Año:</strong>
                                <span><%= cita.getIDVehiculo() != null && cita.getIDVehiculo().getAnioVehiculo() != null ? cita.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Kilometraje:</strong>
                                <span><%= cita.getIDVehiculo() != null && cita.getIDVehiculo().getKilometraje() != null ? cita.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                            </div>
                        </div>

                        <!-- Información de la Cita -->
                        <div class="detail-card">
                            <h3>📅 Información de la Cita</h3>
                            <div class="detail-item">
                                <strong>Fecha de Entrada:</strong>
                                <span><%= cita.getFechaEntrada() != null ? cita.getFechaEntrada() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Estimada Salida:</strong>
                                <span><%= cita.getFechaEstimadaSalida() != null ? cita.getFechaEstimadaSalida() : "Por definir" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Real Salida:</strong>
                                <span><%= cita.getFechaRealSalida() != null ? cita.getFechaRealSalida() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado del Trabajo:</strong>
                                <span><%= cita.getIDEstadoTrabajo() != null ? cita.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                        </div>

                        <!-- Información del Servicio -->
                        <div class="detail-card">
                            <h3>🔧 Información del Servicio</h3>
                            <div class="detail-item">
                                <strong>Problema Reportado:</strong>
                                <span><%= cita.getProblemaReportado() != null ? cita.getProblemaReportado() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Observaciones:</strong>
                                <span><%= cita.getObservaciones() != null ? cita.getObservaciones() : "Ninguna" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Recepcionista:</strong>
                                <span><%= cita.getIDEmpleadoRecepcion() != null ? "Asignado" : "Por asignar" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Mecánico:</strong>
                                <span><%= cita.getIDEmpleadoMecanico() != null ? "Asignado" : "Por asignar" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Progreso del Servicio -->
                    <div class="progress-section">
                        <h3>📊 Progreso del Servicio</h3>
                        <div class="progress-timeline">
                            <div class="timeline-step <%= cita.getFechaEntrada() != null ? "completed" : "" %>">
                                <div class="step-icon">1</div>
                                <div class="step-info">
                                    <h4>Recepción</h4>
                                    <p><%= cita.getFechaEntrada() != null ? cita.getFechaEntrada() : "Pendiente" %></p>
                                    <p>El vehículo ha sido recibido en el taller</p>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= cita.getFechaRealSalida() != null ? "completed" : 
                                                       (cita.getFechaEntrada() != null && cita.getFechaEntrada().before(new Date()) ? "active" : "") %>">
                                <div class="step-icon">2</div>
                                <div class="step-info">
                                    <h4>Diagnóstico y Reparación</h4>
                                    <p>En proceso</p>
                                    <p>El vehículo está siendo diagnosticado y reparado</p>
                                    <% if (cita.getIDEstadoTrabajo() != null) { %>
                                        <span class="status-indicator"><%= cita.getIDEstadoTrabajo().getNombreEstado() %></span>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= cita.getFechaRealSalida() != null ? "completed" : "" %>">
                                <div class="step-icon">3</div>
                                <div class="step-info">
                                    <h4>Completado</h4>
                                    <p><%= cita.getFechaRealSalida() != null ? cita.getFechaRealSalida() : 
                                          (cita.getFechaEstimadaSalida() != null ? "Estimado: " + cita.getFechaEstimadaSalida() : "Por definir") %></p>
                                    <p>El vehículo está listo para ser entregado</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Factura Asociada -->
                    <% if (cita.getFechaRealSalida() != null) { %>
                        <div class="invoice-section">
                            <h3>🧾 Factura Asociada</h3>
                            <div class="invoice-info">
                                <p>Esta cita ya ha sido completada y tiene una factura asociada.</p>
                                <a href="${pageContext.request.contextPath}/cliente/facturaclientes/ver?orden=<%= cita.getIDOrdenServicio() %>" 
                                   class="btn btn-success">Ver Factura</a>
                            </div>
                        </div>
                    <% } %>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <% if (cita.getFechaRealSalida() == null) { %>
                            <a href="${pageContext.request.contextPath}/cliente/servicios/estado-reparacion?idOrden=<%= cita.getIDOrdenServicio() %>" 
                               class="btn btn-info">📊 Estado de Reparación</a>
                            
                            <!-- Solo permitir cancelar citas futuras -->
                            <% if (cita.getFechaEntrada() != null && cita.getFechaEntrada().after(new Date())) { %>
                                <form action="${pageContext.request.contextPath}/CitaServlet?action=cancelar" method="post" style="display: inline;">
                                    <input type="hidden" name="id" value="<%= cita.getIDOrdenServicio() %>">
                                    <button type="submit" class="btn btn-danger"
                                       onclick="return confirm('¿Está seguro de cancelar esta cita?')">❌ Cancelar Cita</button>
                                </form>
                            <% } %>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/cliente/citas/mis-citas" class="btn btn-secondary">↩️ Volver a Mis Citas</a>
                        
                        <% if (cita.getFechaRealSalida() != null) { %>
                            <a href="${pageContext.request.contextPath}/cliente/historial/ver?id=<%= cita.getIDOrdenServicio() %>" 
                               class="btn btn-warning">📋 Ver en Historial</a>
                        <% } %>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la cita solicitada.</p>
                    <a href="${pageContext.request.contextPath}/cliente/citas/mis-citas" class="btn btn-secondary">Volver a Mis Citas</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>