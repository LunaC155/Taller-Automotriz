<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Cliente cliente = (Cliente) request.getAttribute("cliente");
    Cliente clienteConVehiculos = (Cliente) request.getAttribute("clienteConVehiculos");
    List<OrdenServicio> historialOrdenes = (List<OrdenServicio>) request.getAttribute("historialOrdenes");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial del Cliente - Atención al Cliente</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
    
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <% if (cliente == null) { %>
                <div class="empty-state">
                    <div class="empty-icon">❌</div>
                    <h3>Cliente no encontrado</h3>
                    <p>No se pudo encontrar la información del cliente solicitado.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion/clientes" class="btn btn-secondary">
                        Volver a Gestión de Clientes
                    </a>
                </div>
            <% } else { %>
                <div class="page-header">
                    <h1>📊 Historial del Cliente</h1>
                    <p>Información completa y historial de servicios de <%= cliente.getNombre() %> <%= cliente.getApellido() %></p>
                </div>

                <!-- Perfil del Cliente -->
                <div class="customer-profile">
                    <div class="profile-header">
                        <div class="customer-info">
                            <h2><%= cliente.getNombre() %> <%= cliente.getApellido() %></h2>
                            <div class="customer-contact">
                                📞 <strong>Teléfono:</strong> <%= cliente.getTelefono() != null ? cliente.getTelefono() : "No registrado" %> | 
                                📧 <strong>Email:</strong> <%= cliente.getEmail() != null ? cliente.getEmail() : "No registrado" %> |
                                📍 <strong>Dirección:</strong> <%= cliente.getDireccion() != null ? 
                                    (cliente.getDireccion().length() > 50 ? 
                                     cliente.getDireccion().substring(0, 50) + "..." : 
                                     cliente.getDireccion()) : "No registrada" %>
                            </div>
                            <div class="customer-meta">
                                <small>
                                    <strong>Cliente desde:</strong> <%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "Fecha no disponible" %> | 
                                    <strong>ID Cliente:</strong> #<%= cliente.getIDCliente() %>
                                </small>
                            </div>
                        </div>
                        <div class="profile-actions">
                            <a href="${pageContext.request.contextPath}/recepcionista/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                               class="btn btn-primary">✏️ Editar Cliente</a>
                            <a href="${pageContext.request.contextPath}/recepcionista/atencion" 
                               class="btn btn-secondary">↩️ Volver</a>
                        </div>
                    </div>

                    <!-- Estadísticas del Cliente -->
                    <div class="customer-stats">
                        <div class="stat-item">
                            <span class="stat-number"><%= historialOrdenes != null ? historialOrdenes.size() : 0 %></span>
                            <span class="stat-label">Total Órdenes</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number"><%= historialOrdenes != null ? 
                                  historialOrdenes.stream().filter(o -> o.getFechaRealSalida() == null).count() : 0 %></span>
                            <span class="stat-label">Órdenes Activas</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number"><%= clienteConVehiculos != null && clienteConVehiculos.getVehiculoList() != null ? 
                                  clienteConVehiculos.getVehiculoList().size() : 0 %></span>
                            <span class="stat-label">Vehículos</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number">
                                <% if (historialOrdenes != null && !historialOrdenes.isEmpty()) { 
                                    long completadas = historialOrdenes.stream().filter(o -> o.getFechaRealSalida() != null).count();
                                    double porcentaje = (completadas * 100.0) / historialOrdenes.size();
                                %>
                                    <%= String.format("%.1f", porcentaje) %>%
                                <% } else { %>
                                    0%
                                <% } %>
                            </span>
                            <span class="stat-label">Tasa de Completación</span>
                        </div>
                    </div>

                    <!-- Acciones Rápidas -->
                    <div class="quick-actions">
                        <button class="btn btn-success" onclick="nuevaOrden(<%= cliente.getIDCliente() %>)">
                            ➕ Nueva Orden
                        </button>
                        <button class="btn btn-info" onclick="contactarCliente(<%= cliente.getIDCliente() %>)">
                            📞 Contactar
                        </button>
                        <button class="btn btn-warning" onclick="enviarRecordatorio(<%= cliente.getIDCliente() %>)">
                            💬 Recordatorio
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/nuevo?clienteId=<%= cliente.getIDCliente() %>" 
                           class="btn btn-outline-primary">
                            🚗 Agregar Vehículo
                        </a>
                    </div>
                </div>

                <!-- Vehículos del Cliente -->
                <% if (clienteConVehiculos != null && clienteConVehiculos.getVehiculoList() != null && 
                      !clienteConVehiculos.getVehiculoList().isEmpty()) { %>
                    <div class="vehicles-section">
                        <h3>🚗 Vehículos del Cliente</h3>
                        <% for (com.upec.model.Vehiculo vehiculo : clienteConVehiculos.getVehiculoList()) { %>
                            <div class="vehicle-card">
                                <div class="vehicle-header">
                                    <div class="vehicle-info">
                                        <h4><%= vehiculo.getPlaca() %></h4>
                                        <div class="vehicle-details">
                                            <strong>Marca:</strong> <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %> | 
                                            <strong>Modelo:</strong> <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %> | 
                                            <strong>Color:</strong> <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %> | 
                                            <strong>Año:</strong> <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %> | 
                                            <strong>Kilometraje:</strong> <%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %>
                                        </div>
                                    </div>
                                    <div class="vehicle-actions">
                                        <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/detalle?id=<%= vehiculo.getIDVehiculo() %>" 
                                           class="btn btn-sm btn-primary">Ver Detalles</a>
                                    </div>
                                </div>
                                
                                <!-- Órdenes activas del vehículo -->
                                <% if (vehiculo.getOrdenServicioList() != null) { 
                                    List<com.upec.model.OrdenServicio> ordenesActivas = vehiculo.getOrdenServicioList().stream()
                                        .filter(o -> o.getFechaRealSalida() == null)
                                        .toList();
                                    
                                    if (!ordenesActivas.isEmpty()) { %>
                                        <div class="active-orders">
                                            <strong>Órdenes Activas:</strong>
                                            <% for (com.upec.model.OrdenServicio orden : ordenesActivas) { %>
                                                <span class="badge badge-warning">
                                                    #<%= orden.getIDOrdenServicio() %> - 
                                                    <%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %>
                                                </span>
                                            <% } %>
                                        </div>
                                    <% } %>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-icon">🚗</div>
                        <h3>No hay vehículos registrados</h3>
                        <p>Este cliente no tiene vehículos registrados en el sistema.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/nuevo?clienteId=<%= cliente.getIDCliente() %>" 
                           class="btn btn-primary">Registrar Primer Vehículo</a>
                    </div>
                <% } %>

                <!-- Historial de Órdenes -->
                <div class="history-timeline">
                    <h3>📋 Historial de Órdenes de Servicio</h3>
                    
                    <% if (historialOrdenes == null || historialOrdenes.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">📝</div>
                            <h3>No hay historial de órdenes</h3>
                            <p>Este cliente no tiene órdenes de servicio registradas.</p>
                        </div>
                    <% } else { %>
                        <% for (OrdenServicio orden : historialOrdenes) { 
                            String estadoClase = "order-completed";
                            String estadoIcon = "✅";
                            String estadoTexto = "Completada";
                            
                            if (orden.getFechaRealSalida() == null) {
                                estadoClase = "order-pending";
                                estadoIcon = "⏳";
                                estadoTexto = "En Proceso";
                            }
                            
                            if (orden.getIDEstadoTrabajo() != null && "CANCELADA".equals(orden.getIDEstadoTrabajo().getNombreEstado())) {
                                estadoClase = "order-cancelled";
                                estadoIcon = "❌";
                                estadoTexto = "Cancelada";
                            }
                        %>
                            <div class="timeline-item <%= estadoClase %>">
                                <div class="timeline-icon">
                                    <%= estadoIcon %>
                                </div>
                                <div class="timeline-content">
                                    <div class="timeline-header">
                                        <h4 class="timeline-title">
                                            Orden #<%= orden.getIDOrdenServicio() %> - 
                                            <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "Vehículo no disponible" %>
                                        </h4>
                                        <span class="timeline-date">
                                            <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "Fecha no disponible" %>
                                        </span>
                                    </div>
                                    <div class="timeline-details">
                                        <p><strong>Problema Reportado:</strong> 
                                           <%= orden.getProblemaReportado() != null ? 
                                               (orden.getProblemaReportado().length() > 100 ? 
                                                orden.getProblemaReportado().substring(0, 100) + "..." : 
                                                orden.getProblemaReportado()) : "Sin descripción" %>
                                        </p>
                                        
                                        <% if (orden.getObservaciones() != null) { %>
                                            <p><strong>Observaciones:</strong> 
                                               <%= orden.getObservaciones().length() > 80 ? 
                                                   orden.getObservaciones().substring(0, 80) + "..." : 
                                                   orden.getObservaciones() %>
                                            </p>
                                        <% } %>
                                        
                                        <p>
                                            <strong>Estado:</strong> 
                                            <span class="badge badge-<%= obtenerClaseBadgeEstado(orden) %>">
                                                <%= estadoTexto %>
                                            </span> | 
                                            <strong>Entrada:</strong> <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %> | 
                                            <% if (orden.getFechaRealSalida() != null) { %>
                                                <strong>Salida:</strong> <%= orden.getFechaRealSalida() %>
                                            <% } else if (orden.getFechaEstimadaSalida() != null) { %>
                                                <strong>Estimada:</strong> <%= orden.getFechaEstimadaSalida() %>
                                            <% } %>
                                        </p>
                                        
                                        <div class="timeline-actions">
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/detalle?id=<%= orden.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-primary">Ver Detalles</a>
                                            <% if (orden.getFechaRealSalida() != null) { %>
                                                <a href="${pageContext.request.contextPath}/recepcionista/facturas/ver?orden=<%= orden.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-success">Ver Factura</a>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                        
                        <!-- Resumen del Historial -->
                        <div class="table-info">
                            <p>Resumen del historial: 
                                <span class="badge badge-success">Completadas: <%= historialOrdenes.stream().filter(o -> o.getFechaRealSalida() != null).count() %></span>
                                <span class="badge badge-warning">En Proceso: <%= historialOrdenes.stream().filter(o -> o.getFechaRealSalida() == null).count() %></span>
                                <span class="badge badge-danger">Canceladas: <%= historialOrdenes.stream().filter(o -> 
                                    o.getIDEstadoTrabajo() != null && "CANCELADA".equals(o.getIDEstadoTrabajo().getNombreEstado())).count() %></span>
                            </p>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function nuevaOrden(idCliente) {
            window.location.href = '${pageContext.request.contextPath}/recepcionista/ordenes/nueva?clienteId=' + idCliente;
        }
        
        function contactarCliente(idCliente) {
            if (confirm('¿Desea contactar a este cliente?')) {
                // Implementar lógica de contacto
                alert('Iniciando contacto con el cliente #' + idCliente);
            }
        }
        
        function enviarRecordatorio(idCliente) {
            if (confirm('¿Enviar recordatorio de servicio al cliente?')) {
                // Implementar envío de recordatorio
                alert('Recordatorio enviado al cliente #' + idCliente);
            }
        }
    </script>
</body>
</html>

<%!
    // Método helper para obtener clase de badge según estado
    private String obtenerClaseBadgeEstado(OrdenServicio orden) {
        if (orden.getFechaRealSalida() != null) {
            return "success";
        } else if (orden.getIDEstadoTrabajo() != null && "CANCELADA".equals(orden.getIDEstadoTrabajo().getNombreEstado())) {
            return "danger";
        } else {
            return "warning";
        }
    }
%>