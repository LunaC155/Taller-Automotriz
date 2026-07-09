<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="java.util.Date" %>
<%@page import="com.upec.model.Factura" %>
<%
    // CORRECCIÓN: Usar los atributos directamente sin casting problemático
    List<Factura> facturasPagadas = (List<Factura>) request.getAttribute("facturasPagadas");
    List<Factura> facturasPendientes = (List<Factura>) request.getAttribute("facturasPendientes");
    List<Factura> facturasVencidas = (List<Factura>) request.getAttribute("facturasVencidas");
    
    // CORRECCIÓN: Inicializar para evitar nulls
    if (facturasPagadas == null) facturasPagadas = java.util.Collections.emptyList();
    if (facturasPendientes == null) facturasPendientes = java.util.Collections.emptyList();
    if (facturasVencidas == null) facturasVencidas = java.util.Collections.emptyList();
    
    // CORRECCIÓN: Usar Double en lugar de double primitivo
    Double totalPagado = (Double) request.getAttribute("totalPagado");
    Double totalPendiente = (Double) request.getAttribute("totalPendiente");
    Double totalVencido = (Double) request.getAttribute("totalVencido");
    Double saldoPendiente = (Double) request.getAttribute("saldoPendiente");
    Integer totalFacturas = (Integer) request.getAttribute("totalFacturas");
    
    // CORRECCIÓN: Valores por defecto
    if (totalPagado == null) totalPagado = 0.0;
    if (totalPendiente == null) totalPendiente = 0.0;
    if (totalVencido == null) totalVencido = 0.0;
    if (saldoPendiente == null) saldoPendiente = 0.0;
    if (totalFacturas == null) totalFacturas = 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Estados de Pago</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
 <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
</head>
<body class="cliente">
   <%@include file="../../shared/header.jsp" %>
<%@include file="../../shared/sidebar-cliente.jsp" %>
<%@include file="../../shared/messages.jsp" %>
    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>💰 Estados de Pago</h1>
                <p>Consulta el estado de tus pagos y facturas pendientes</p>
            </div>

            <!-- Resumen de Estados -->
            <div class="payment-overview">
                <div class="payment-cards">
                    <div class="payment-card paid">
                        <div class="payment-icon">✅</div>
                        <div class="payment-info">
                            <h3>$<%= totalPagado != null ? String.format("%.2f", totalPagado) : "0.00" %></h3>
                            <p>Total Pagado</p>
                            <span class="payment-count"><%= facturasPagadas != null ? facturasPagadas.size() : 0 %> facturas</span>
                        </div>
                    </div>
                    
                    <div class="payment-card pending">
                        <div class="payment-icon">⏳</div>
                        <div class="payment-info">
                            <h3>$<%= totalPendiente != null ? String.format("%.2f", totalPendiente) : "0.00" %></h3>
                            <p>Pendiente de Pago</p>
                            <span class="payment-count"><%= facturasPendientes != null ? facturasPendientes.size() : 0 %> facturas</span>
                        </div>
                    </div>
                    
                    <div class="payment-card expired">
                        <div class="payment-icon">⚠️</div>
                        <div class="payment-info">
                            <h3>$<%= totalVencido != null ? String.format("%.2f", totalVencido) : "0.00" %></h3>
                            <p>Vencido</p>
                            <span class="payment-count"><%= facturasVencidas != null ? facturasVencidas.size() : 0 %> facturas</span>
                        </div>
                    </div>
                    
                    <div class="payment-card total">
                        <div class="payment-icon">💰</div>
                        <div class="payment-info">
                            <h3>$<%= saldoPendiente != null ? String.format("%.2f", saldoPendiente) : "0.00" %></h3>
                            <p>Saldo Pendiente Total</p>
                            <span class="payment-count"><%= totalFacturas != null ? totalFacturas : 0 %> facturas totales</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Facturas Vencidas (Alerta) -->
            <% if (facturasVencidas != null && !facturasVencidas.isEmpty()) { %>
                <div class="alert-section">
                    <div class="alert alert-danger">
                        <h3>⚠️ Facturas Vencidas</h3>
                        <p>Tienes <strong><%= facturasVencidas.size() %></strong> facturas vencidas por un total de <strong>$<%= String.format("%.2f", totalVencido) %></strong>. 
                           Por favor, regulariza tu situación lo antes posible.</p>
                        <a href="${pageContext.request.contextPath}/cliente/contacto" class="btn btn-warning">📞 Contactar para Pago</a>
                    </div>
                </div>
            <% } %>

            <!-- Facturas Pendientes -->
            <div class="payment-section">
                <h2 class="section-title">⏳ Facturas Pendientes de Pago</h2>
                
                <% if (facturasPendientes != null && !facturasPendientes.isEmpty()) { %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Factura #</th>
                                    <th>Orden #</th>
                                    <th>Vehículo</th>
                                    <th>Fecha Emisión</th>
                                    <th>Total</th>
                                    <th>Días desde Emisión</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Factura factura : facturasPendientes) { 
                                    boolean esVencida = esFacturaVencida(factura);
                                    long dias = calcularDiasDesdeEmision(factura.getFechaEmision());
                                %>
                                    <tr class="<%= esVencida ? "expired" : "" %>">
                                        <td><strong>#<%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : factura.getIDFactura() %></strong></td>
                                        <td>
                                            <%= factura.getIDOrdenServicio() != null ? 
                                                "#" + factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %>
                                        </td>
                                        <td>
                                            <%= factura.getIDOrdenServicio() != null && 
                                                factura.getIDOrdenServicio().getIDVehiculo() != null ? 
                                                factura.getIDOrdenServicio().getIDVehiculo().getPlaca() : "N/A" %>
                                        </td>
                                        <td><%= factura.getFechaEmision() != null ? factura.getFechaEmision() : "N/A" %></td>
                                        <td><strong>$<%= factura.getTotal() != null ? String.format("%.2f", factura.getTotal()) : "0.00" %></strong></td>
                                        <td>
                                            <span class="<%= dias > 30 ? "text-danger" : "text-warning" %>">
                                                <%= dias %> días
                                                <%= esVencida ? " ⚠️" : "" %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="status-badge <%= esVencida ? "delayed" : "pending" %>">
                                                <%= esVencida ? "Vencida" : "Pendiente" %>
                                            </span>
                                        </td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=ver&id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-info">Ver</a>
                                            <a href="${pageContext.request.contextPath}/cliente/contacto" 
                                               class="btn btn-sm btn-warning">Pagar</a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div class="no-data success">
                        <p>✅ No tienes facturas pendientes de pago.</p>
                    </div>
                <% } %>
            </div>

            <!-- Facturas Pagadas -->
            <div class="payment-section">
                <h2 class="section-title">✅ Facturas Pagadas</h2>
                
                <% if (facturasPagadas != null && !facturasPagadas.isEmpty()) { %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Factura #</th>
                                    <th>Orden #</th>
                                    <th>Vehículo</th>
                                    <th>Fecha Emisión</th>
                                    <th>Fecha Pago</th>
                                    <th>Total</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Factura factura : facturasPagadas) { %>
                                    <tr>
                                        <td><strong>#<%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : factura.getIDFactura() %></strong></td>
                                        <td>
                                            <%= factura.getIDOrdenServicio() != null ? 
                                                "#" + factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %>
                                        </td>
                                        <td>
                                            <%= factura.getIDOrdenServicio() != null && 
                                                factura.getIDOrdenServicio().getIDVehiculo() != null ? 
                                                factura.getIDOrdenServicio().getIDVehiculo().getPlaca() : "N/A" %>
                                        </td>
                                        <td><%= factura.getFechaEmision() != null ? factura.getFechaEmision() : "N/A" %></td>
                                        <td>
                                            <%= factura.getFechaEmision() != null ? 
                                                calcularFechaPago(factura.getFechaEmision()) : "N/A" %>
                                        </td>
                                        <td><strong>$<%= factura.getTotal() != null ? String.format("%.2f", factura.getTotal()) : "0.00" %></strong></td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=ver&id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-info">Ver</a>
                                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=descargar&id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-success">Descargar</a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div class="no-data">
                        <p>📋 No hay facturas pagadas en tu historial.</p>
                    </div>
                <% } %>
            </div>

            <!-- Información de Pago -->
            <div class="payment-info">
                <h3>💳 Información de Pago</h3>
                <div class="info-cards">
                    <div class="info-card">
                        <h4>Métodos de Pago Aceptados</h4>
                        <ul>
                            <li>💵 Efectivo</li>
                            <li>💳 Tarjetas de Crédito/Débito</li>
                            <li>🏦 Transferencia Bancaria</li>
                            <li>📱 Pago Móvil</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>Instrucciones para el Pago</h4>
                        <ol>
                            <li>Selecciona la factura que deseas pagar</li>
                            <li>Haz clic en el botón "Pagar"</li>
                            <li>Sigue las instrucciones del sistema</li>
                            <li>Guarda tu comprobante de pago</li>
                        </ol>
                    </div>
                    <div class="info-card">
                        <h4>¿Necesitas Ayuda?</h4>
                        <p>Si tienes alguna duda sobre tus facturas o métodos de pago, no dudes en contactarnos:</p>
                        <div class="contact-info">
                            <p>📞 Teléfono: (04) 234-5678</p>
                            <p>📧 Email: facturacion@tallerautomotriz.com</p>
                            <p>🕒 Horario: Lunes a Viernes 8:00 - 18:00</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Navegación -->
            <div class="navigation-buttons">
                <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" class="btn btn-secondary">
                    ↩️ Volver a Facturas
                </a>
                <a href="${pageContext.request.contextPath}/cliente/historial/facturas" class="btn btn-info">
                    📊 Historial Completo
                </a>
                <a href="${pageContext.request.contextPath}/cliente/contacto" class="btn btn-warning">
                    📞 Contactar Facturación
                </a>
            </div>
        </div>
    </div>

    <%@include file="../../shared/footer.jsp" %>
    
    <%!
        // Métodos auxiliares
        private boolean esFacturaVencida(Factura factura) {
            if (factura == null || factura.getFechaEmision() == null) return false;
            if (factura.getIDEstadoFactura() == null) return false;
            
            String estado = factura.getIDEstadoFactura().getNombreEstado();
            if (!"PENDIENTE".equalsIgnoreCase(estado)) return false;
            
            long diff = new Date().getTime() - factura.getFechaEmision().getTime();
            long dias = diff / (1000 * 60 * 60 * 24);
            return dias > 30;
        }
        
        private long calcularDiasDesdeEmision(Date fechaEmision) {
            if (fechaEmision == null) return 0;
            long diff = new Date().getTime() - fechaEmision.getTime();
            return diff / (1000 * 60 * 60 * 24);
        }
        
        private String calcularFechaPago(Date fechaEmision) {
            if (fechaEmision == null) return "N/A";
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(fechaEmision);
            cal.add(java.util.Calendar.DAY_OF_MONTH, 15);
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
            return sdf.format(cal.getTime());
        }
    %>
</body>
</html>