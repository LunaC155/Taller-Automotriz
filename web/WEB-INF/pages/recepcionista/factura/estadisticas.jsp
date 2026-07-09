<%@page import="com.upec.model.Factura"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.text.SimpleDateFormat, java.math.BigDecimal" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Object[]> estadisticas = (List<Object[]>) request.getAttribute("estadisticas");
    List<Object[]> facturasPorEstado = (List<Object[]>) request.getAttribute("facturasPorEstado");
    BigDecimal totalFacturadoMes = (BigDecimal) request.getAttribute("totalFacturadoMes");
    List<Factura> facturasRecientes = (List<Factura>) request.getAttribute("facturasRecientes");
    String mesActual = (String) request.getAttribute("mesActual");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas de Facturación - Taller Automotriz</title>
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
                <h1>📈 Estadísticas de Facturación</h1>
                <p>Métricas y análisis del sistema de facturación</p>
            </div>

            <!-- Selector de Período -->
            <div class="periodo-selector">
                <h3>📅 Seleccionar Período</h3>
                <form action="${pageContext.request.contextPath}/recepcionista/facturas/estadisticas" method="get" class="selector-grid">
                    <div class="form-group">
                        <label for="fechaInicio">Fecha Inicio</label>
                        <input type="month" id="fechaInicio" name="fechaInicio" class="form-control">
                    </div>
                    <div class="form-group">
                        <label for="fechaFin">Fecha Fin</label>
                        <input type="month" id="fechaFin" name="fechaFin" class="form-control">
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Aplicar Filtro</button>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas/estadisticas" class="btn btn-secondary">Ver Todo</a>
                    </div>
                </form>
            </div>

            <!-- Tarjetas de Estadísticas Principales -->
            <div class="stats-grid">
                <div class="stat-card primary">
                    <div class="stat-icon">📊</div>
                    <div class="stat-number">
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { 
                            Object[] stats = estadisticas.get(0);
                            Long totalFacturas = (Long) stats[0];
                        %>
                            <%= totalFacturas != null ? totalFacturas : 0 %>
                        <% } else { %>
                            0
                        <% } %>
                    </div>
                    <div class="stat-label">Total Facturas</div>
                </div>
                
                <div class="stat-card success">
                    <div class="stat-icon">💰</div>
                    <div class="stat-number">
                        $<%= totalFacturadoMes != null ? String.format("%,.2f", totalFacturadoMes) : "0.00" %>
                    </div>
                    <div class="stat-label">Total Facturado <%= mesActual != null ? mesActual : "este mes" %></div>
                </div>
                
                <div class="stat-card warning">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-number">
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { 
                            Object[] stats = estadisticas.get(0);
                            BigDecimal totalPendiente = (BigDecimal) stats[4];
                        %>
                            $<%= totalPendiente != null ? String.format("%,.2f", totalPendiente) : "0.00" %>
                        <% } else { %>
                            $0.00
                        <% } %>
                    </div>
                    <div class="stat-label">Total Pendiente</div>
                </div>
                
                <div class="stat-card info">
                    <div class="stat-icon">📦</div>
                    <div class="stat-number">
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { 
                            Object[] stats = estadisticas.get(0);
                            Double promedioFactura = (Double) stats[2];
                        %>
                            $<%= promedioFactura != null ? String.format("%,.2f", promedioFactura) : "0.00" %>
                        <% } else { %>
                            $0.00
                        <% } %>
                    </div>
                    <div class="stat-label">Promedio por Factura</div>
                </div>
            </div>

            <!-- Gráficos y Distribución -->
            <div class="charts-grid">
                <!-- Distribución por Estado -->
                <div class="chart-container">
                    <h3>📋 Distribución por Estado</h3>
                    <div class="progress-chart">
                        <% if (facturasPorEstado != null && !facturasPorEstado.isEmpty()) { 
                            long totalFacturas = 0;
                            for (Object[] item : facturasPorEstado) {
                                Long count = (Long) item[1];
                                totalFacturas += count != null ? count : 0;
                            }
                            
                            for (Object[] item : facturasPorEstado) {
                                String estado = (String) item[0];
                                Long count = (Long) item[1];
                                double porcentaje = totalFacturas > 0 ? (count != null ? (count * 100.0 / totalFacturas) : 0) : 0;
                                
                                String estadoClase = "progress-pendiente";
                                if ("PAGADA".equals(estado)) estadoClase = "progress-pagada";
                                else if ("CANCELADA".equals(estado)) estadoClase = "progress-cancelada";
                                else if ("ANULADA".equals(estado)) estadoClase = "progress-anulada";
                        %>
                            <div class="progress-item">
                                <div class="progress-label">
                                    <span><%= estado %></span>
                                    <span><%= count != null ? count : 0 %> (<%= String.format("%.1f", porcentaje) %>%)</span>
                                </div>
                                <div class="progress-bar">
                                    <div class="progress-fill <%= estadoClase %>" style="width: <%= porcentaje %>%;"></div>
                                </div>
                            </div>
                        <% } 
                        } else { %>
                            <div class="empty-state">
                                <div class="empty-icon">📊</div>
                                <p>No hay datos de distribución disponibles</p>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Resumen Financiero -->
                <div class="chart-container">
                    <h3>💵 Resumen Financiero</h3>
                    <% if (estadisticas != null && !estadisticas.isEmpty()) { 
                        Object[] stats = estadisticas.get(0);
                        BigDecimal totalFacturado = (BigDecimal) stats[1];
                        BigDecimal totalPagado = (BigDecimal) stats[3];
                        BigDecimal totalPendiente = (BigDecimal) stats[4];
                    %>
                        <div class="progress-item">
                            <div class="progress-label">
                                <span>Total Facturado</span>
                                <span>$<%= totalFacturado != null ? String.format("%,.2f", totalFacturado) : "0.00" %></span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill progress-pagada" style="width: 100%;"></div>
                            </div>
                        </div>
                        
                        <div class="progress-item">
                            <div class="progress-label">
                                <span>Total Pagado</span>
                                <span>$<%= totalPagado != null ? String.format("%,.2f", totalPagado) : "0.00" %></span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill progress-pagada" 
                                     style="width: <%= totalFacturado != null && totalFacturado.doubleValue() > 0 ? 
                                     (totalPagado != null ? (totalPagado.doubleValue() * 100 / totalFacturado.doubleValue()) : 0) : 0 %>%;">
                                </div>
                            </div>
                        </div>
                        
                        <div class="progress-item">
                            <div class="progress-label">
                                <span>Total Pendiente</span>
                                <span>$<%= totalPendiente != null ? String.format("%,.2f", totalPendiente) : "0.00" %></span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill progress-pendiente"
                                     style="width: <%= totalFacturado != null && totalFacturado.doubleValue() > 0 ? 
                                     (totalPendiente != null ? (totalPendiente.doubleValue() * 100 / totalFacturado.doubleValue()) : 0) : 0 %>%;">
                                </div>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="empty-state">
                            <div class="empty-icon">💰</div>
                            <p>No hay datos financieros disponibles</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Facturas Recientes -->
            <div class="recent-facturas">
                <h3>🕒 Facturas Recientes</h3>
                <% if (facturasRecientes != null && !facturasRecientes.isEmpty()) { 
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                %>
                    <% for (Factura factura : facturasRecientes) { 
                        String estadoClase = "badge-pendiente";
                        String estadoTexto = "PENDIENTE";
                        
                        if (factura.getIDEstadoFactura() != null) {
                            estadoTexto = factura.getIDEstadoFactura().getNombreEstado();
                            if ("PAGADA".equals(estadoTexto)) {
                                estadoClase = "badge-pagada";
                            }
                        }
                    %>
                        <div class="factura-item">
                            <div class="factura-info">
                                <h4><%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : "N/A" %></h4>
                                <div class="factura-meta">
                                    <span>Orden #<%= factura.getIDOrdenServicio() != null ? factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></span>
                                    <span><%= factura.getFechaEmision() != null ? sdf.format(factura.getFechaEmision()) : "N/A" %></span>
                                    <span class="badge-estado <%= estadoClase %>"><%= estadoTexto %></span>
                                </div>
                            </div>
                            <div class="factura-monto">
                                $<%= factura.getTotal() != null ? String.format("%,.2f", factura.getTotal()) : "0.00" %>
                            </div>
                        </div>
                    <% } %>
                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-icon">🧾</div>
                        <p>No hay facturas recientes</p>
                    </div>
                <% } %>
            </div>

            <!-- Acciones -->
            <div class="action-buttons" style="margin-top: 30px;">
                <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-primary">
                    ↩️ Volver a Facturas
                </a>
                <button onclick="window.print()" class="btn btn-secondary">
                    🖨️ Imprimir Reporte
                </button>
                <a href="${pageContext.request.contextPath}/recepcionista/facturas/generar" class="btn btn-success">
                    ➕ Generar Factura
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Animación de las barras de progreso
        document.addEventListener('DOMContentLoaded', function() {
            const progressBars = document.querySelectorAll('.progress-fill');
            progressBars.forEach(bar => {
                const originalWidth = bar.style.width;
                bar.style.width = '0%';
                setTimeout(() => {
                    bar.style.width = originalWidth;
                }, 100);
            });
        });
        
        // Configurar fechas por defecto en el selector
        window.addEventListener('load', function() {
            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const currentMonth = `${year}-${month}`;
            
            document.getElementById('fechaInicio').value = currentMonth;
            document.getElementById('fechaFin').value = currentMonth;
        });
    </script>
</body>
</html>