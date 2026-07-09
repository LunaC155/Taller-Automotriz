<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Factura, java.util.List, java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Factura> facturasPendientes = (List<Factura>) request.getAttribute("facturas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facturas Pendientes - Taller Automotriz</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
   
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <!-- Encabezado Especial para Pendientes -->
            <div class="pending-header">
                <h1>⏳ Facturas Pendientes de Pago</h1>
                <p>Gestiona las facturas que están esperando ser pagadas por los clientes</p>
            </div>

            <!-- Estadísticas de Pendientes -->
            <div class="pending-stats">
                <div class="stat-card">
                    <div class="stat-icon">📄</div>
                    <div class="stat-number"><%= facturasPendientes != null ? facturasPendientes.size() : 0 %></div>
                    <div class="stat-label">Total Facturas Pendientes</div>
                </div>
                
                <div class="stat-card total">
                    <div class="stat-icon">💰</div>
                    <div class="stat-number">
                        <% 
                            double totalPendiente = 0;
                            if (facturasPendientes != null) {
                                for (Factura factura : facturasPendientes) {
                                    if (factura.getTotal() != null) {
                                        totalPendiente += factura.getTotal().doubleValue();
                                    }
                                }
                            }
                        %>
                        $<%= String.format("%,.2f", totalPendiente) %>
                    </div>
                    <div class="stat-label">Monto Total Pendiente</div>
                </div>
                
                <div class="stat-card antiguas">
                    <div class="stat-icon">📅</div>
                    <div class="stat-number">
                        <% 
                            long facturasAntiguas = 0;
                            if (facturasPendientes != null) {
                                java.util.Date hace30Dias = new java.util.Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000));
                                for (Factura factura : facturasPendientes) {
                                    if (factura.getFechaEmision() != null && 
                                        factura.getFechaEmision().before(hace30Dias)) {
                                        facturasAntiguas++;
                                    }
                                }
                            }
                        %>
                        <%= facturasAntiguas %>
                    </div>
                    <div class="stat-label">Mayores a 30 días</div>
                </div>
                
                <div class="stat-card recientes">
                    <div class="stat-icon">🆕</div>
                    <div class="stat-number">
                        <% 
                            long facturasRecientes = 0;
                            if (facturasPendientes != null) {
                                java.util.Date hace7Dias = new java.util.Date(System.currentTimeMillis() - (7L * 24 * 60 * 60 * 1000));
                                for (Factura factura : facturasPendientes) {
                                    if (factura.getFechaEmision() != null && 
                                        factura.getFechaEmision().after(hace7Dias)) {
                                        facturasRecientes++;
                                    }
                                }
                            }
                        %>
                        <%= facturasRecientes %>
                    </div>
                    <div class="stat-label">Últimos 7 días</div>
                </div>
            </div>

            <!-- Acciones por Lotes -->
            <div class="batch-actions">
                <h4>🔄 Acciones por Lotes</h4>
                <div class="batch-buttons">
                    <button class="btn btn-warning btn-sm" onclick="enviarRecordatorios()">
                        📧 Enviar Recordatorios
                    </button>
                    <button class="btn btn-info btn-sm" onclick="generarReportePendientes()">
                        📊 Generar Reporte
                    </button>
                    <button class="btn btn-success btn-sm" onclick="marcarTodasPagadas()">
                        💰 Marcar Todas como Pagadas
                    </button>
                </div>
            </div>

            <!-- Recordatorio de Seguimiento -->
            <div class="reminder-section">
                <h4>💡 Recomendaciones de Seguimiento</h4>
                <p>Recuerda contactar a los clientes con facturas pendientes por más de 15 días.</p>
                <p>Facturas con más de 30 días de antigüedad requieren atención prioritaria.</p>
                
                <div class="reminder-actions">
                    <a href="${pageContext.request.contextPath}/recepcionista/clientes?filtro=deudores" 
                       class="btn btn-outline-primary btn-sm">
                        👥 Ver Clientes con Deudas
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/estadisticas" 
                       class="btn btn-outline-info btn-sm">
                        📈 Ver Estadísticas Completas
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas" 
                       class="btn btn-outline-secondary btn-sm">
                        📋 Ver Todas las Facturas
                    </a>
                </div>
            </div>

            <!-- Tabla de Facturas Pendientes -->
            <div class="table-container">
                <% if (facturasPendientes == null || facturasPendientes.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🎉</div>
                        <h3>¡No hay facturas pendientes!</h3>
                        <p>Todas las facturas han sido pagadas. ¡Buen trabajo!</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-primary">
                            Ver Todas las Facturas
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>N° Factura</th>
                                <th>Orden Servicio</th>
                                <th>Cliente</th>
                                <th>Contacto</th>
                                <th>Vehículo</th>
                                <th>Fecha Emisión</th>
                                <th>Días Transcurridos</th>
                                <th>Total</th>
                                <th>Prioridad</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                java.util.Date ahora = new java.util.Date();
                                double totalPendienteTabla = 0;
                            %>
                            <% for (Factura factura : facturasPendientes) { 
                                if (factura.getTotal() != null) {
                                    totalPendienteTabla += factura.getTotal().doubleValue();
                                }
                                
                                // Calcular días transcurridos
                                long diasTranscurridos = 0;
                                String urgencia = "urgency-low";
                                String urgenciaTexto = "Baja";
                                
                                if (factura.getFechaEmision() != null) {
                                    long diff = ahora.getTime() - factura.getFechaEmision().getTime();
                                    diasTranscurridos = diff / (1000 * 60 * 60 * 24);
                                    
                                    if (diasTranscurridos > 30) {
                                        urgencia = "urgency-high";
                                        urgenciaTexto = "Alta";
                                    } else if (diasTranscurridos > 15) {
                                        urgencia = "urgency-medium";
                                        urgenciaTexto = "Media";
                                    }
                                }
                                
                                String rowClass = "";
                                if (diasTranscurridos > 30) rowClass = "table-overdue";
                                else if (diasTranscurridos > 15) rowClass = "table-highlight";
                            %>
                                <tr class="<%= rowClass %>">
                                    <td>
                                        <strong><%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : "N/A" %></strong>
                                    </td>
                                    <td>#<%= factura.getIDOrdenServicio() != null ? factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></td>
                                    <td>
                                        <% if (factura.getIDOrdenServicio() != null && 
                                               factura.getIDOrdenServicio().getIDVehiculo() != null &&
                                               factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) { 
                                               String nombreCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getNombre();
                                               String apellidoCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getApellido();
                                        %>
                                            <strong><%= nombreCliente != null ? nombreCliente : "" %> <%= apellidoCliente != null ? apellidoCliente : "" %></strong>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (factura.getIDOrdenServicio() != null && 
                                               factura.getIDOrdenServicio().getIDVehiculo() != null &&
                                               factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) { 
                                               String telefono = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getTelefono();
                                               String email = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getEmail();
                                        %>
                                            <div class="contact-info">
                                                <% if (telefono != null) { %>
                                                    <p>📞 <%= telefono %></p>
                                                <% } %>
                                                <% if (email != null) { %>
                                                    <p>📧 <%= email %></p>
                                                <% } %>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted">No disponible</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (factura.getIDOrdenServicio() != null && 
                                               factura.getIDOrdenServicio().getIDVehiculo() != null) { %>
                                            <strong><%= factura.getIDOrdenServicio().getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= factura.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null ? 
                                                    factura.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= factura.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null ? 
                                                    factura.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td><%= factura.getFechaEmision() != null ? sdf.format(factura.getFechaEmision()) : "N/A" %></td>
                                    <td>
                                        <% if (factura.getFechaEmision() != null) { %>
                                            <span class="days-overdue"><%= diasTranscurridos %> días</span>
                                        <% } else { %>
                                            <span class="text-muted">N/A</span>
                                        <% } %>
                                    </td>
                                    <td class="monto">
                                        <strong>$<%= factura.getTotal() != null ? String.format("%,.2f", factura.getTotal()) : "0.00" %></strong>
                                    </td>
                                    <td>
                                        <span class="urgency-indicator <%= urgencia %>">
                                            <%= urgenciaTexto %>
                                        </span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons-group">
                                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/ver?id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️
                                            </a>
                                            <form action="${pageContext.request.contextPath}/recepcionista/facturas/cambiar-estado" 
                                                  method="post" style="display: inline;">
                                                <input type="hidden" name="idFactura" value="<%= factura.getIDFactura() %>">
                                                <input type="hidden" name="idEstadoFactura" value="2"> <!-- Asumiendo 2 = PAGADA -->
                                                <button type="submit" class="btn btn-sm btn-success" 
                                                        title="Marcar como pagada"
                                                        onclick="return confirm('¿Está seguro de marcar esta factura como PAGADA?')">
                                                    ✅
                                                </button>
                                            </form>
                                            <button class="btn btn-sm btn-warning" 
                                                    title="Enviar recordatorio"
                                                    onclick="enviarRecordatorio(<%= factura.getIDFactura() %>)">
                                                📧
                                            </button>
                                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/editar?id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-outline-secondary" title="Editar">
                                                ✏️
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            <!-- Fila de totales -->
                            <tr style="background: #f8f9fa; font-weight: bold;">
                                <td colspan="7"><strong>TOTAL PENDIENTE</strong></td>
                                <td class="monto"><strong>$<%= String.format("%,.2f", totalPendienteTabla) %></strong></td>
                                <td colspan="2"></td>
                            </tr>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>
                            <span class="badge badge-warning">Facturas pendientes: <%= facturasPendientes.size() %></span>
                            <span class="badge badge-danger">Vencidas (>30 días): 
                                <% 
                                    long vencidas = 0;
                                    if (facturasPendientes != null) {
                                        java.util.Date hace30Dias = new java.util.Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000));
                                        for (Factura factura : facturasPendientes) {
                                            if (factura.getFechaEmision() != null && 
                                                factura.getFechaEmision().before(hace30Dias)) {
                                                vencidas++;
                                            }
                                        }
                                    }
                                %>
                                <%= vencidas %>
                            </span>
                            <span class="badge badge-success">Por vencer (<15 días): <%= facturasPendientes.size() - vencidas %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function enviarRecordatorios() {
            if (confirm('¿Está seguro de enviar recordatorios a todos los clientes con facturas pendientes?')) {
                alert('Recordatorios enviados exitosamente');
                // Aquí se implementaría la lógica para enviar recordatorios
            }
        }
        
        function generarReportePendientes() {
            alert('Generando reporte de facturas pendientes...');
            // Aquí se implementaría la lógica para generar reportes
        }
        
        function marcarTodasPagadas() {
            if (confirm('¿Está seguro de marcar TODAS las facturas pendientes como PAGADAS?\n\nEsta acción no se puede deshacer.')) {
                alert('Todas las facturas han sido marcadas como pagadas');
                // Aquí se implementaría la lógica para marcar todas como pagadas
            }
        }
        
        function enviarRecordatorio(idFactura) {
            if (confirm('¿Enviar recordatorio de pago al cliente?')) {
                alert('Recordatorio enviado para la factura #' + idFactura);
                // Aquí se implementaría la lógica para enviar recordatorio individual
            }
        }
        
        // Resaltar filas según antigüedad
        document.addEventListener('DOMContentLoaded', function() {
            const rows = document.querySelectorAll('tr[class*="table-"]');
            rows.forEach(row => {
                row.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.01)';
                    this.style.transition = 'transform 0.2s';
                });
                
                row.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                });
            });
        });
    </script>
</body>
</html>