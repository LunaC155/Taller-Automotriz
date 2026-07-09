<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Diagnostico" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión por ID de rol numérico
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
    if (orden == null) {
        response.sendRedirect(request.getContextPath() + "/mecanico/ordenes");
        return;
    }
    
    String estado = orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "PENDIENTE";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orden #<%= orden.getIDOrdenServicio() %> - Detalles</title>
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
                <h1>🔧 Detalle de Orden #<%= orden.getIDOrdenServicio() %></h1>
                <p>Información completa de la orden de servicio</p>
            </div>

            <div class="order-detail">
                <!-- Encabezado -->
                <div class="detail-header">
                    <h2>Orden de Servicio #<%= orden.getIDOrdenServicio() %></h2>
                    <%
                        String estadoClase = "badge-warning";
                        switch(estado) {
                            case "EN PROCESO":
                                estadoClase = "badge-info";
                                break;
                            case "COMPLETADO":
                                estadoClase = "badge-success";
                                break;
                            case "CANCELADO":
                                estadoClase = "badge-danger";
                                break;
                        }
                    %>
                    <span class="status-badge-large <%= estadoClase %>"><%= estado %></span>
                </div>

                <!-- Información Principal -->
                <div class="detail-grid">
                    <!-- Información del Vehículo -->
                    <div class="detail-card">
                        <h3>🚗 Información del Vehículo</h3>
                        <div class="detail-item">
                            <strong>Placa:</strong>
                            <span><%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Marca:</strong>
                            <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDMarca() != null ? 
                                    orden.getIDVehiculo().getIDMarca().getNombreMarca() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Modelo:</strong>
                            <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDModelo() != null ? 
                                    orden.getIDVehiculo().getIDModelo().getNombreModelo() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Color:</strong>
                            <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getColor() != null ? 
                                    orden.getIDVehiculo().getColor() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Año:</strong>
                            <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getAnioVehiculo() != null ? 
                                    orden.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Kilometraje:</strong>
                            <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getKilometraje() != null ? 
                                    orden.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Cliente:</strong>
                            <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null ? 
                                    orden.getIDVehiculo().getIDCliente().getNombre() + " " + orden.getIDVehiculo().getIDCliente().getApellido() : "N/A" %></span>
                        </div>
                    </div>

                    <!-- Información de la Orden -->
                    <div class="detail-card">
                        <h3>📅 Información de la Orden</h3>
                        <div class="detail-item">
                            <strong>Fecha Entrada:</strong>
                            <span><%= orden.getFechaEntrada() != null ? 
                                    new SimpleDateFormat("dd/MM/yyyy HH:mm").format(orden.getFechaEntrada()) : "N/A" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Fecha Estimada Salida:</strong>
                            <span><%= orden.getFechaEstimadaSalida() != null ? 
                                    new SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEstimadaSalida()) : "Por definir" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Fecha Real Salida:</strong>
                            <span><%= orden.getFechaRealSalida() != null ? 
                                    new SimpleDateFormat("dd/MM/yyyy HH:mm").format(orden.getFechaRealSalida()) : "Pendiente" %></span>
                        </div>
                        <div class="detail-item">
                            <strong>Recepcionista:</strong>
                            <span><%= orden.getIDEmpleadoRecepcion() != null ? 
                                    orden.getIDEmpleadoRecepcion().getNombre() + " " + orden.getIDEmpleadoRecepcion().getApellido() : "N/A" %></span>
                        </div>
                    </div>

                    <!-- Problema Reportado -->
                    <div class="detail-card">
                        <h3>🔧 Problema Reportado</h3>
                        <div class="problem-description">
                            <%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "No especificado" %>
                        </div>
                    </div>
                </div>

                <!-- Progreso del Servicio -->
                <div class="progress-section">
                    <h3>📊 Progreso del Servicio</h3>
                    <div class="progress-timeline">
                        <div class="timeline-step <%= orden.getFechaEntrada() != null ? "completed" : "" %>">
                            <div class="step-icon">1</div>
                            <div class="step-info">
                                <h4>Recepción</h4>
                                <p><%= orden.getFechaEntrada() != null ? 
                                        new SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEntrada()) : "Pendiente" %></p>
                                <p>Vehículo recibido en taller</p>
                            </div>
                        </div>
                        
                        <div class="timeline-step <%= "EN PROCESO".equals(estado) || "COMPLETADO".equals(estado) ? "completed" : 
                                                   ("PENDIENTE".equals(estado) ? "active" : "") %>">
                            <div class="step-icon">2</div>
                            <div class="step-info">
                                <h4>Diagnóstico</h4>
                                <p><%= orden.getDiagnosticoList() != null && !orden.getDiagnosticoList().isEmpty() ? 
                                        "Realizado" : "Pendiente" %></p>
                                <p>Diagnóstico del problema</p>
                            </div>
                        </div>
                        
                        <div class="timeline-step <%= "EN PROCESO".equals(estado) ? "active" : 
                                                   ("COMPLETADO".equals(estado) ? "completed" : "") %>">
                            <div class="step-icon">3</div>
                            <div class="step-info">
                                <h4>Reparación</h4>
                                <p><%= "EN PROCESO".equals(estado) ? "En Proceso" : 
                                       ("COMPLETADO".equals(estado) ? "Completado" : "Pendiente") %></p>
                                <p>Reparación del vehículo</p>
                            </div>
                        </div>
                        
                        <div class="timeline-step <%= "COMPLETADO".equals(estado) ? "completed" : "" %>">
                            <div class="step-icon">4</div>
                            <div class="step-info">
                                <h4>Completado</h4>
                                <p><%= orden.getFechaRealSalida() != null ? 
                                        new SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaRealSalida()) : 
                                        (orden.getFechaEstimadaSalida() != null ? 
                                         "Estimado: " + new SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEstimadaSalida()) : 
                                         "Por definir") %></p>
                                <p>Vehículo listo para entrega</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Diagnósticos -->
                <% if (orden.getDiagnosticoList() != null && !orden.getDiagnosticoList().isEmpty()) { %>
                    <div class="diagnosticos-section">
                        <h3>🔍 Diagnósticos Realizados</h3>
                        <% for (Diagnostico diagnostico : orden.getDiagnosticoList()) { %>
                            <div class="diagnostico-card">
                                <div class="diagnostico-header">
                                    <strong>Diagnóstico #<%= diagnostico.getIDDiagnostico() != null ? diagnostico.getIDDiagnostico() : "" %></strong>
                                    <small><%= diagnostico.getFechaDiagnostico() != null ? 
                                            new SimpleDateFormat("dd/MM/yyyy HH:mm").format(diagnostico.getFechaDiagnostico()) : "" %></small>
                                </div>
                                <div class="diagnostico-body">
                                    <p><strong>Descripción:</strong> <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                            diagnostico.getDescripcionDiagnostico() : "No especificado" %></p>
                                    <% if (diagnostico.getRecomendaciones() != null) { %>
                                        <p><strong>Recomendaciones:</strong> <%= diagnostico.getRecomendaciones() %></p>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>

                <!-- Observaciones y Avances -->
                <div id="avances" class="avances-section">
                    <h3>📝 Observaciones y Avances</h3>
                    
                    <% if (orden.getObservaciones() != null && !orden.getObservaciones().trim().isEmpty()) { %>
                        <div class="observaciones-content">
                            <%= orden.getObservaciones() %>
                        </div>
                    <% } else { %>
                        <p>No hay observaciones registradas.</p>
                    <% } %>
                    
                    <!-- Formulario para registrar avance -->
                    <% if (!"COMPLETADO".equals(estado) && !"CANCELADO".equals(estado)) { %>
                        <form action="${pageContext.request.contextPath}/mecanico/ordenes/registrar-avance" method="post" class="avance-form" style="margin-top: 20px;">
                            <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                            <div class="form-group">
                                <label for="observaciones"><strong>Registrar Nuevo Avance:</strong></label>
                                <textarea id="observaciones" name="observaciones" rows="4" 
                                          class="form-control" 
                                          placeholder="Describe el avance en el trabajo, partes reparadas, problemas encontrados, etc..."
                                          required></textarea>
                                <small class="form-text">Esta información será visible para el cliente y el recepcionista.</small>
                            </div>
                            <button type="submit" class="btn btn-primary">💾 Registrar Avance</button>
                        </form>
                    <% } %>
                </div>

                <!-- Acciones -->
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/mecanico/ordenes" class="btn btn-secondary">
                        ↩️ Volver a Mis Órdenes
                    </a>
                    
                    <% if (!"COMPLETADO".equals(estado) && !"CANCELADO".equals(estado)) { %>
                        <a href="${pageContext.request.contextPath}/mecanico/ordenes/actualizar-estado?id=<%= orden.getIDOrdenServicio() %>" 
                           class="btn btn-warning">🔄 Actualizar Estado</a>
                    <% } %>
                    
                    <% if ("EN PROCESO".equals(estado)) { %>
                        <a href="#avances" class="btn btn-primary">📝 Registrar Avance</a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>