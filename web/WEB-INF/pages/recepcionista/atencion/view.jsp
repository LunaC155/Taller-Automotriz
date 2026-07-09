<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, com.upec.model.OrdenServicio, com.upec.model.Vehiculo, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Cliente cliente = (Cliente) request.getAttribute("cliente");
    List<OrdenServicio> historialOrdenes = (List<OrdenServicio>) request.getAttribute("historialOrdenes");
    Cliente clienteConVehiculos = (Cliente) request.getAttribute("clienteConVehiculos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial del Cliente - Taller Automotriz</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
   
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <% if (cliente != null) { %>
                <!-- Perfil del Cliente -->
                <div class="client-profile">
                    <div class="profile-header">
                        <div class="profile-info">
                            <h2>👤 <%= cliente.getNombre() %> <%= cliente.getApellido() %></h2>
                            <div class="profile-contact">
                                <strong>📧 Email:</strong> <%= cliente.getEmail() != null ? cliente.getEmail() : "No especificado" %> | 
                                <strong>📞 Teléfono:</strong> <%= cliente.getTelefono() != null ? cliente.getTelefono() : "No especificado" %> | 
                                <strong>📅 Registro:</strong> <%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %>
                            </div>
                            <% if (cliente.getDireccion() != null && !cliente.getDireccion().trim().isEmpty()) { %>
                                <p><strong>🏠 Dirección:</strong> <%= cliente.getDireccion() %></p>
                            <% } %>
                        </div>
                        <div class="profile-actions">
                            <a href="mailto:<%= cliente.getEmail() != null ? cliente.getEmail() : "" %>" 
                               class="btn btn-secondary" 
                               <%= cliente.getEmail() == null ? "disabled" : "" %>>📧 Enviar Email</a>
                            <a href="tel:<%= cliente.getTelefono() != null ? cliente.getTelefono() : "" %>" 
                               class="btn btn-success"
                               <%= cliente.getTelefono() == null ? "disabled" : "" %>>📞 Llamar</a>
                        </div>
                    </div>

                    <!-- Estadísticas -->
                    <div class="profile-stats">
                        <div class="profile-stat">
                            <div class="stat-number"><%= historialOrdenes != null ? historialOrdenes.size() : 0 %></div>
                            <div>Total Órdenes</div>
                        </div>
                        <div class="profile-stat">
                            <div class="stat-number">
                                <%= historialOrdenes != null ? 
                                    historialOrdenes.stream().filter(o -> o.getFechaRealSalida() == null).count() : 0 %>
                            </div>
                            <div>Órdenes Pendientes</div>
                        </div>
                        <div class="profile-stat">
                            <div class="stat-number">
                                <%= clienteConVehiculos != null && clienteConVehiculos.getVehiculoList() != null ? 
                                    clienteConVehiculos.getVehiculoList().size() : 0 %>
                            </div>
                            <div>Vehículos</div>
                        </div>
                        <div class="profile-stat">
                            <div class="stat-number">
                                <%= historialOrdenes != null ? 
                                    historialOrdenes.stream().filter(o -> o.getFechaRealSalida() != null).count() : 0 %>
                            </div>
                            <div>Órdenes Completadas</div>
                        </div>
                    </div>
                </div>

                <!-- Vehículos del Cliente -->
                <div class="vehicles-section">
                    <div class="section-header">
                        <h3>🚗 Vehículos del Cliente</h3>
                    </div>
                    
                    <% if (clienteConVehiculos != null && clienteConVehiculos.getVehiculoList() != null && 
                          !clienteConVehiculos.getVehiculoList().isEmpty()) { %>
                        <div class="vehicles-grid">
                            <% for (Vehiculo vehiculo : clienteConVehiculos.getVehiculoList()) { %>
                                <div class="vehicle-card">
                                    <h4><%= vehiculo.getPlaca() %></h4>
                                    <div class="vehicle-details">
                                        <p><strong>Marca:</strong> 
                                            <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %>
                                        </p>
                                        <p><strong>Modelo:</strong> 
                                            <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %>
                                        </p>
                                        <p><strong>Color:</strong> <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></p>
                                        <p><strong>Año:</strong> <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></p>
                                        <p><strong>Kilometraje:</strong> <%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></p>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="empty-state">
                            <div class="empty-icon">🚗</div>
                            <p>El cliente no tiene vehículos registrados</p>
                        </div>
                    <% } %>
                </div>

                <!-- Historial de Órdenes -->
                <div class="history-section">
                    <div class="section-header">
                        <h3>📋 Historial de Órdenes de Servicio</h3>
                    </div>
                    
                    <% if (historialOrdenes != null && !historialOrdenes.isEmpty()) { %>
                        <div class="order-timeline">
                            <% for (OrdenServicio orden : historialOrdenes) { 
                                String statusClass = "pending";
                                String statusText = "Pendiente";
                                
                                if (orden.getFechaRealSalida() != null) {
                                    statusClass = "completed";
                                    statusText = "Completada";
                                } else if (orden.getIDEstadoTrabajo() != null && 
                                          "EN PROCESO".equals(orden.getIDEstadoTrabajo().getNombreEstado())) {
                                    statusClass = "in-progress";
                                    statusText = "En Proceso";
                                }
                            %>
                                <div class="timeline-item <%= statusClass %>">
                                    <div class="order-header">
                                        <div class="order-info">
                                            <h4>Orden #<%= orden.getIDOrdenServicio() %></h4>
                                            <div class="order-details">
                                                <strong>Vehículo:</strong> 
                                                <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %> | 
                                                <strong>Fecha Entrada:</strong> <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %> | 
                                                <strong>Fecha Estimada:</strong> <%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %>
                                                <% if (orden.getFechaRealSalida() != null) { %>
                                                    | <strong>Fecha Salida:</strong> <%= orden.getFechaRealSalida() %>
                                                <% } %>
                                            </div>
                                        </div>
                                        <span class="order-status status-<%= statusClass %>"><%= statusText %></span>
                                    </div>
                                    
                                    <% if (orden.getProblemaReportado() != null && !orden.getProblemaReportado().trim().isEmpty()) { %>
                                        <div class="problem-description">
                                            <strong>Problema Reportado:</strong> <%= orden.getProblemaReportado() %>
                                        </div>
                                    <% } %>
                                    
                                    <% if (orden.getObservaciones() != null && !orden.getObservaciones().trim().isEmpty()) { %>
                                        <p><strong>Observaciones:</strong> <%= orden.getObservaciones() %></p>
                                    <% } %>
                                    
                                    <% if (orden.getIDEmpleadoRecepcion() != null) { %>
                                        <p><strong>Recepcionista:</strong> <%= orden.getIDEmpleadoRecepcion().getNombre() %></p>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="empty-state">
                            <div class="empty-icon">📋</div>
                            <p>El cliente no tiene historial de órdenes de servicio</p>
                        </div>
                    <% } %>
                </div>

                <!-- Acciones -->
                <div class="action-buttons" style="text-align: center; margin-top: 30px;">
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion/clientes" 
                       class="btn btn-secondary">↩️ Volver a Clientes</a>
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion" 
                       class="btn btn-primary">🏠 Dashboard</a>
                </div>

            <% } else { %>
                <div class="empty-state">
                    <div class="empty-icon">❌</div>
                    <h3>Cliente no encontrado</h3>
                    <p>No se pudo encontrar la información del cliente solicitado.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion/clientes" 
                       class="btn btn-secondary">Volver a Clientes</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>