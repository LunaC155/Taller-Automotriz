<%@page import="com.upec.model.Cliente"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio" %>
<%@page import="java.util.Date" %>
<%
    // Verificar sesión de recepcionista
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
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
    <title>Detalle de Cita - Recepcionista</title>
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
                <h1>📅 Detalle de Cita</h1>
                <p>Información completa de la cita - Vista Recepcionista</p>
            </div>

            <% if (cita != null) { 
                String estadoClase = "upcoming";
                String estadoTexto = "Próxima";
                
                if (cita.getFechaRealSalida() != null) {
                    estadoClase = "completed";
                    estadoTexto = "Completada";
                } else if (cita.getIDEstadoTrabajo() != null && "CANCELADA".equals(cita.getIDEstadoTrabajo().getNombreEstado())) {
                    estadoClase = "cancelled";
                    estadoTexto = "Cancelada";
                } else if (cita.getFechaEntrada() != null && cita.getFechaEntrada().before(new Date())) {
                    estadoClase = "in-progress";
                    estadoTexto = "En Proceso";
                }
            %>
                <div class="appointment-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <div>
                            <h2>Cita #<%= cita.getIDOrdenServicio() %></h2>
                            <p class="text-muted">
                                Creada el: <%= cita.getFechaEntrada() != null ? 
                                    new java.text.SimpleDateFormat("dd/MM/yyyy 'a las' HH:mm").format(cita.getFechaEntrada()) : "Fecha no disponible" %>
                            </p>
                        </div>
                        <span class="status-badge <%= estadoClase %>">
                            <%= estadoTexto %>
                        </span>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información del Cliente -->
                        <div class="detail-card">
                            <h3>👤 Información del Cliente</h3>
                            <% if (cita.getIDVehiculo() != null && cita.getIDVehiculo().getIDCliente() != null) { 
                                Cliente cliente = cita.getIDVehiculo().getIDCliente();
                            %>
                                <div class="detail-item">
                                    <strong>Nombre:</strong>
                                    <span><%= cliente.getNombre() %> <%= cliente.getApellido() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Email:</strong>
                                    <span><%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Teléfono:</strong>
                                    <span><%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Dirección:</strong>
                                    <span><%= cliente.getDireccion() != null ? cliente.getDireccion() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha Registro:</strong>
                                    <span><%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %></span>
                                </div>
                            <% } else { %>
                                <p class="text-muted">Información del cliente no disponible</p>
                            <% } %>
                        </div>

                        <!-- Información del Vehículo -->
                        <div class="detail-card">
                            <h3>🚗 Información del Vehículo</h3>
                            <% if (cita.getIDVehiculo() != null) { %>
                                <div class="detail-item">
                                    <strong>Placa:</strong>
                                    <span><%= cita.getIDVehiculo().getPlaca() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Marca/Modelo:</strong>
                                    <span>
                                        <%= cita.getIDVehiculo().getIDMarca() != null ? cita.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                        <%= cita.getIDVehiculo().getIDModelo() != null ? cita.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Color:</strong>
                                    <span><%= cita.getIDVehiculo().getColor() != null ? cita.getIDVehiculo().getColor() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Año:</strong>
                                    <span><%= cita.getIDVehiculo().getAnioVehiculo() != null ? cita.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Kilometraje:</strong>
                                    <span><%= cita.getIDVehiculo().getKilometraje() != null ? cita.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Número Chasis:</strong>
                                    <span><%= cita.getIDVehiculo().getNumeroChasis() != null ? cita.getIDVehiculo().getNumeroChasis() : "N/A" %></span>
                                </div>
                            <% } else { %>
                                <p class="text-muted">Información del vehículo no disponible</p>
                            <% } %>
                        </div>

                        <!-- Información de la Cita -->
                        <div class="detail-card">
                            <h3>📅 Información de la Cita</h3>
                            <div class="detail-item">
                                <strong>Fecha de Entrada:</strong>
                                <span>
                                    <%= cita.getFechaEntrada() != null ? 
                                        new java.text.SimpleDateFormat("dd/MM/yyyy 'a las' HH:mm").format(cita.getFechaEntrada()) : "N/A" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Estimada Salida:</strong>
                                <span>
                                    <%= cita.getFechaEstimadaSalida() != null ? 
                                        new java.text.SimpleDateFormat("dd/MM/yyyy").format(cita.getFechaEstimadaSalida()) : "Por definir" %>
                                    <% if (cita.getFechaEstimadaSalida() != null && cita.getFechaEstimadaSalida().before(new Date())) { %>
                                        <span class="urgent-badge">Atrasada</span>
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Real Salida:</strong>
                                <span>
                                    <%= cita.getFechaRealSalida() != null ? 
                                        new java.text.SimpleDateFormat("dd/MM/yyyy 'a las' HH:mm").format(cita.getFechaRealSalida()) : "Pendiente" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado del Trabajo:</strong>
                                <span><%= cita.getIDEstadoTrabajo() != null ? cita.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Recepcionista:</strong>
                                <span>
                                    <%= cita.getIDEmpleadoRecepcion() != null ? 
                                        "Empleado #" + cita.getIDEmpleadoRecepcion().getIDEmpleado() : "No asignado" %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Descripción del Servicio -->
                    <div class="detail-card full-width">
                        <h3>🔧 Descripción del Servicio</h3>
                        <div class="detail-item full-width">
                            <strong>Problema Reportado:</strong>
                            <span style="white-space: pre-wrap;"><%= cita.getProblemaReportado() != null ? cita.getProblemaReportado() : "N/A" %></span>
                        </div>
                        <div class="detail-item full-width">
                            <strong>Observaciones:</strong>
                            <span style="white-space: pre-wrap;"><%= cita.getObservaciones() != null ? cita.getObservaciones() : "Ninguna" %></span>
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
                                    <p><%= cita.getFechaEntrada() != null ? 
                                        new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(cita.getFechaEntrada()) : "Pendiente" %></p>
                                    <p>Vehículo recibido en el taller</p>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= cita.getFechaRealSalida() != null ? "completed" : 
                                                       (cita.getFechaEntrada() != null && cita.getFechaEntrada().before(new Date()) ? "active" : "") %>">
                                <div class="step-icon">2</div>
                                <div class="step-info">
                                    <h4>Diagnóstico y Reparación</h4>
                                    <p>En proceso</p>
                                    <p>Vehículo en diagnóstico/reparación</p>
                                    <% if (cita.getIDEstadoTrabajo() != null) { %>
                                        <span class="status-indicator"><%= cita.getIDEstadoTrabajo().getNombreEstado() %></span>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="timeline-step <%= cita.getFechaRealSalida() != null ? "completed" : "" %>">
                                <div class="step-icon">3</div>
                                <div class="step-info">
                                    <h4>Completado</h4>
                                    <p><%= cita.getFechaRealSalida() != null ? 
                                        new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(cita.getFechaRealSalida()) : 
                                        (cita.getFechaEstimadaSalida() != null ? 
                                         "Estimado: " + new java.text.SimpleDateFormat("dd/MM/yyyy").format(cita.getFechaEstimadaSalida()) : "Por definir") %></p>
                                    <p>Vehículo listo para entrega</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Factura Asociada -->
                    <% if (cita.getFechaRealSalida() != null) { %>
                        <div class="invoice-section">
                            <h3>🧾 Factura Asociada</h3>
                            <p>Esta cita ya ha sido completada y puede generar la factura asociada.</p>
                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/generar?orden=<%= cita.getIDOrdenServicio() %>" 
                               class="btn btn-success">Generar Factura</a>
                        </div>
                    <% } %>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/recepcionista/citas/editar?id=<%= cita.getIDOrdenServicio() %>" 
                           class="btn btn-warning">✏️ Editar Cita</a>
                        
                        <% if (cita.getFechaRealSalida() == null) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/diagnosticos/crear?orden=<%= cita.getIDOrdenServicio() %>" 
                               class="btn btn-info">🔧 Asignar Diagnóstico</a>
                            
                            <% if (cita.getFechaEntrada() != null && cita.getFechaEntrada().after(new Date())) { %>
                                <form action="${pageContext.request.contextPath}/recepcionista/citas/cancelar" method="post" style="display: inline;">
                                    <input type="hidden" name="id" value="<%= cita.getIDOrdenServicio() %>">
                                    <button type="submit" class="btn btn-danger"
                                       onclick="return confirm('¿Está seguro de cancelar esta cita?')">❌ Cancelar Cita</button>
                                </form>
                            <% } %>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/recepcionista/citas" class="btn btn-secondary">↩️ Volver al Listado</a>
                        
                        <% if (cita.getFechaRealSalida() != null) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/historial/ver?id=<%= cita.getIDOrdenServicio() %>" 
                               class="btn btn-primary">📋 Ver en Historial</a>
                        <% } %>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la cita solicitada.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>