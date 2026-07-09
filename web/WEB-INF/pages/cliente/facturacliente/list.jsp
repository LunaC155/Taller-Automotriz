<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="java.util.Date" %>
<%@page import="com.upec.model.Factura" %>
<%
    List<Factura> facturas = (List<Factura>) request.getAttribute("facturas");
    List<Factura> facturasRecientes = (List<Factura>) request.getAttribute("facturasRecientes");
    String tipoVista = (String) request.getAttribute("tipoVista");
    
    Double totalFacturado = (Double) request.getAttribute("totalFacturado");
    Long facturasPagadas = (Long) request.getAttribute("facturasPagadas");
    Long facturasPendientes = (Long) request.getAttribute("facturasPendientes");
    Long facturasVencidas = (Long) request.getAttribute("facturasVencidas");
    
    // CORRECCIÓN: Inicializar todas las variables
    if (facturas == null) facturas = java.util.Collections.emptyList();
    if (facturasRecientes == null) facturasRecientes = java.util.Collections.emptyList();
    if (tipoVista == null) tipoVista = "todas";
    if (totalFacturado == null) totalFacturado = 0.0;
    if (facturasPagadas == null) facturasPagadas = 0L;
    if (facturasPendientes == null) facturasPendientes = 0L;
    if (facturasVencidas == null) facturasVencidas = 0L;
    
    // Parámetros de búsqueda
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mis Facturas</title>
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
                <h1>🧾 Mis Facturas</h1>
                <p>Gestiona y consulta todas tus facturas</p>
            </div>

            <!-- Métricas -->
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon">🧾</div>
                    <div class="metric-info">
                        <h3><%= facturas.size() %></h3>
                        <p>Total Facturas</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">✅</div>
                    <div class="metric-info">
                        <h3><%= facturasPagadas %></h3>
                        <p>Pagadas</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">⏳</div>
                    <div class="metric-info">
                        <h3><%= facturasPendientes %></h3>
                        <p>Pendientes</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">⚠️</div>
                    <div class="metric-info">
                        <h3><%= facturasVencidas %></h3>
                        <p>Vencidas</p>
                    </div>
                </div>
            </div>

            <!-- Resumen Financiero -->
            <div class="summary-card financial">
                <h3>💰 Resumen Financiero</h3>
                <div class="summary-grid">
                    <div class="summary-item">
                        <strong>Total Facturado:</strong>
                        <span class="amount">$<%= String.format("%.2f", totalFacturado) %></span>
                    </div>
                    <div class="summary-item">
                        <strong>Saldo Pendiente:</strong>
                        <span class="amount pending">$<%= calcularSaldoPendiente(facturas) %></span>
                    </div>
                    <div class="summary-item">
                        <strong>Facturas Pagadas:</strong>
                        <span><%= facturasPagadas %> (<%= calcularPorcentaje(facturasPagadas, facturas.size()) %>%)</span>
                    </div>
                    <div class="summary-item">
                        <strong>Promedio por Factura:</strong>
                        <span>$<%= facturas.size() > 0 ? String.format("%.2f", totalFacturado / facturas.size()) : "0.00" %></span>
                    </div>
                </div>
            </div>

            <!-- Barra de acciones -->
            <div class="action-bar">
                <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=estados-pago" class="btn btn-info">
                    💰 Estados de Pago
                </a>
                <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" class="btn btn-warning">
                    📊 Todas las Facturas
                </a>
            </div>

            <!-- Barra de búsqueda -->
            <div class="search-section">
                <form action="${pageContext.request.contextPath}/FacturaClientesServlet" method="get" class="search-form">
                    <input type="hidden" name="action" value="buscar">
                    <div class="search-group">
                        <select name="criterio" class="form-control">
                            <option value="numero" <%= "numero".equals(criterio) ? "selected" : "" %>>Número de Factura</option>
                            <option value="orden" <%= "orden".equals(criterio) ? "selected" : "" %>>Número de Orden</option>
                        </select>
                        <input type="text" name="valor" placeholder="Buscar facturas..." 
                               value="<%= valor != null ? valor : "" %>" class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                        <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" class="btn btn-secondary">🔄 Limpiar</a>
                    </div>
                </form>
            </div>

            <!-- Información de búsqueda -->
            <% if ("busqueda".equals(tipoVista) && valor != null && !valor.isEmpty()) { %>
                <div class="search-info">
                    <p>Resultados para: "<strong><%= valor %></strong>" 
                       <% if (criterio != null) { %>en <strong><%= criterio %></strong><% } %>
                    </p>
                    <p><strong><%= facturas.size() %></strong> facturas encontradas</p>
                </div>
            <% } %>

            <!-- Facturas Recientes -->
            <% if (facturasRecientes != null && !facturasRecientes.isEmpty() && !"busqueda".equals(tipoVista)) { %>
                <div class="recent-section">
                    <h2 class="section-title">🕒 Facturas Recientes</h2>
                    <div class="cards-grid">
                        <% for (Factura factura : facturasRecientes) { 
                            String estado = factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "";
                            String estadoClass = "";
                            if ("PAGADA".equalsIgnoreCase(estado)) {
                                estadoClass = "paid";
                            } else if ("PENDIENTE".equalsIgnoreCase(estado)) {
                                estadoClass = "pending";
                            } else {
                                estadoClass = "other";
                            }
                        %>
                            <div class="invoice-card <%= estadoClass %>">
                                <div class="invoice-header">
                                    <h3>Factura #<%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : factura.getIDFactura() %></h3>
                                    <span class="status-badge 
                                        <%= "PAGADA".equalsIgnoreCase(estado) ? "completed" : 
                                           ("PENDIENTE".equalsIgnoreCase(estado) ? "pending" : "warning") %>">
                                        <%= estado.isEmpty() ? "Pendiente" : estado %>
                                    </span>
                                </div>
                                <div class="invoice-body">
                                    <p><strong>Orden:</strong> #<%= factura.getIDOrdenServicio() != null ? factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></p>
                                    <p><strong>Vehículo:</strong> <%= factura.getIDOrdenServicio() != null && 
                                        factura.getIDOrdenServicio().getIDVehiculo() != null ? 
                                        factura.getIDOrdenServicio().getIDVehiculo().getPlaca() : "N/A" %></p>
                                    <p><strong>Fecha:</strong> <%= factura.getFechaEmision() != null ? factura.getFechaEmision() : "N/A" %></p>
                                    <p class="invoice-total"><strong>Total: $<%= factura.getTotal() != null ? String.format("%.2f", factura.getTotal()) : "0.00" %></strong></p>
                                </div>
                                <div class="invoice-actions">
                                    <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=ver&id=<%= factura.getIDFactura() %>" 
                                       class="btn btn-sm btn-info">Ver</a>
                                    <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=descargar&id=<%= factura.getIDFactura() %>" 
                                       class="btn btn-sm btn-success">Descargar</a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>

            <!-- Lista Completa de Facturas -->
            <div class="invoices-section">
                <h2 class="section-title">
                    <%= "busqueda".equals(tipoVista) ? "📋 Resultados de Búsqueda" : 
                        "todas".equals(tipoVista) ? "📋 Todas las Facturas" : "📋 Mis Facturas" %>
                </h2>
                
                <% if (facturas != null && !facturas.isEmpty()) { %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Factura #</th>
                                    <th>Orden #</th>
                                    <th>Vehículo</th>
                                    <th>Fecha Emisión</th>
                                    <th>Subtotal</th>
                                    <th>IVA</th>
                                    <th>Total</th>
                                    <th>Estado</th>
                                    <th>Vencimiento</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Factura factura : facturas) { 
                                    boolean esVencida = esFacturaVencida(factura);
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
                                        <td>$<%= factura.getSubtotal() != null ? String.format("%.2f", factura.getSubtotal()) : "0.00" %></td>
                                        <td>$<%= factura.getIva() != null ? String.format("%.2f", factura.getIva()) : "0.00" %></td>
                                        <td><strong>$<%= factura.getTotal() != null ? String.format("%.2f", factura.getTotal()) : "0.00" %></strong></td>
                                        <td>
                                            <span class="status-badge 
                                                <%= "PAGADA".equalsIgnoreCase(factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "") ? "completed" : 
                                                   ("PENDIENTE".equalsIgnoreCase(factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "") ? 
                                                   (esVencida ? "delayed" : "pending") : "warning") %>">
                                                <%= factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "Pendiente" %>
                                                <%= esVencida ? " ⚠️" : "" %>
                                            </span>
                                        </td>
                                        <td>
                                            <%= esVencida ? "Vencida" : 
                                               (factura.getFechaEmision() != null ? 
                                               calcularDiasVencimiento(factura.getFechaEmision()) + " días" : "N/A") %>
                                        </td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=ver&id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-info" title="Ver factura">👁️</a>
                                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=descargar&id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-success" title="Descargar PDF">📥</a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Resumen por Estado -->
                    <div class="status-summary">
                        <h3>📊 Resumen por Estado</h3>
                        <div class="status-cards">
                            <div class="status-card paid">
                                <h4>Pagadas</h4>
                                <p class="count"><%= facturasPagadas %></p>
                                <p class="amount">$<%= calcularTotalPorEstado(facturas, "PAGADA") %></p>
                            </div>
                            <div class="status-card pending">
                                <h4>Pendientes</h4>
                                <p class="count"><%= facturasPendientes %></p>
                                <p class="amount">$<%= calcularTotalPorEstado(facturas, "PENDIENTE") %></p>
                            </div>
                            <div class="status-card expired">
                                <h4>Vencidas</h4>
                                <p class="count"><%= facturasVencidas %></p>
                                <p class="amount">$<%= calcularTotalPorEstado(facturas, "VENCIDA") %></p>
                            </div>
                        </div>
                    </div>

                <% } else { %>
                    <div class="no-data">
                        <% if ("busqueda".equals(tipoVista)) { %>
                            <p>🔍 No se encontraron facturas que coincidan con tu búsqueda.</p>
                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" class="btn btn-primary">Ver Todas las Facturas</a>
                        <% } else { %>
                            <p>🧾 No hay facturas registradas.</p>
                            <p>Las facturas aparecerán aquí una vez que se completen tus servicios.</p>
                        <% } %>
                    </div>
                <% } %>
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
        
        private long calcularDiasVencimiento(Date fechaEmision) {
            if (fechaEmision == null) return 0;
            long diasTranscurridos = calcularDiasDesdeEmision(fechaEmision);
            long diasRestantes = 30 - diasTranscurridos;
            return diasRestantes > 0 ? diasRestantes : 0;
        }
        
        private String calcularSaldoPendiente(List<Factura> facturas) {
            if (facturas == null || facturas.isEmpty()) return "0.00";
            
            double saldo = facturas.stream()
                .filter(f -> f.getIDEstadoFactura() != null && 
                            "PENDIENTE".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .filter(f -> f.getTotal() != null)
                .mapToDouble(f -> f.getTotal().doubleValue())
                .sum();
            
            return String.format("%.2f", saldo);
        }
        
        private String calcularTotalPorEstado(List<Factura> facturas, String estado) {
            if (facturas == null || facturas.isEmpty()) return "0.00";
            
            double total = 0.0;
            for (Factura f : facturas) {
                if (f.getIDEstadoFactura() != null && f.getTotal() != null) {
                    if (estado.equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado())) {
                        total += f.getTotal().doubleValue();
                    } else if ("VENCIDA".equalsIgnoreCase(estado) && esFacturaVencida(f)) {
                        total += f.getTotal().doubleValue();
                    }
                }
            }
            
            return String.format("%.2f", total);
        }
        
        private String calcularPorcentaje(Long parte, int total) {
            if (total == 0) return "0";
            if (parte == null) return "0";
            double porcentaje = (parte.doubleValue() / total) * 100;
            return String.format("%.1f", porcentaje);
        }
    %>
</body>
</html>