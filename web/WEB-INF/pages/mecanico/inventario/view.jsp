<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Repuesto, com.upec.model.DetalleFactura, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Repuesto repuesto = (Repuesto) request.getAttribute("repuesto");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Repuesto - Taller Automotriz</title>
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
                <h1>📦 Detalle de Repuesto</h1>
                <p>Información completa del repuesto en el inventario</p>
            </div>

            <% if (repuesto != null) { 
                String statusIcon = "✅";
                String statusText = "DISPONIBLE";
                String statusColor = "#28a745";
                
                if (repuesto.getStock() == null || repuesto.getStock() == 0) {
                    statusIcon = "❌";
                    statusText = "AGOTADO";
                    statusColor = "#dc3545";
                } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo() / 2) {
                    statusIcon = "🚨";
                    statusText = "STOCK CRÍTICO";
                    statusColor = "#dc3545";
                } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo()) {
                    statusIcon = "⚠️";
                    statusText = "STOCK BAJO";
                    statusColor = "#ffc107";
                }
            %>
                <div class="detail-container">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <div>
                            <h2><%= repuesto.getNombreRepuesto() %></h2>
                            <p style="color: #6c757d; margin: 5px 0 0 0;">
                                ID: #<%= repuesto.getIDRepuesto() %>
                                <% if (repuesto.getDescripcion() != null && !repuesto.getDescripcion().isEmpty()) { %>
                                    | <%= repuesto.getDescripcion() %>
                                <% } %>
                            </p>
                        </div>
                    </div>

                    <!-- Contenido Principal -->
                    <div class="detail-grid">
                        <!-- Información Principal -->
                        <div class="main-info">
                            <!-- Información Básica -->
                            <div class="info-card">
                                <h3>📋 Información General</h3>
                                <div class="detail-item">
                                    <strong>ID del Repuesto:</strong>
                                    <span>#<%= repuesto.getIDRepuesto() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Nombre:</strong>
                                    <span><%= repuesto.getNombreRepuesto() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Descripción:</strong>
                                    <span><%= repuesto.getDescripcion() != null ? repuesto.getDescripcion() : "Sin descripción disponible" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Estado en Sistema:</strong>
                                    <span>
                                        <% if (repuesto.getEstado() != null && repuesto.getEstado()) { %>
                                            <span style="color: #28a745; font-weight: bold;">● Activo</span>
                                        <% } else { %>
                                            <span style="color: #dc3545; font-weight: bold;">● Inactivo</span>
                                        <% } %>
                                    </span>
                                </div>
                            </div>

                            <!-- Información de Stock -->
                            <div class="info-card">
                                <h3>📦 Gestión de Inventario</h3>
                                <div class="detail-item">
                                    <strong>Stock Actual:</strong>
                                    <span><%= repuesto.getStock() != null ? repuesto.getStock() : 0 %> unidades</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Stock Mínimo:</strong>
                                    <span><%= repuesto.getStockMinimo() != null ? repuesto.getStockMinimo() : "No definido" %> unidades</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Nivel de Stock:</strong>
                                    <span>
                                        <% if (repuesto.getStock() == null || repuesto.getStock() == 0) { %>
                                            <span style="color: #dc3545; font-weight: bold;">❌ Agotado</span>
                                        <% } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo() / 2) { %>
                                            <span style="color: #dc3545; font-weight: bold;">🚨 Crítico (<%= repuesto.getStock() %>/<%= repuesto.getStockMinimo() %>)</span>
                                        <% } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo()) { %>
                                            <span style="color: #ffc107; font-weight: bold;">⚠️ Bajo (<%= repuesto.getStock() %>/<%= repuesto.getStockMinimo() %>)</span>
                                        <% } else { %>
                                            <span style="color: #28a745; font-weight: bold;">✅ Normal (<%= repuesto.getStock() %> unidades)</span>
                                        <% } %>
                                    </span>
                                </div>
                            </div>

                            <!-- Información de Precios -->
                            <div class="info-card">
                                <h3>💰 Información Económica</h3>
                                <div class="detail-item">
                                    <strong>Precio de Compra:</strong>
                                    <span>
                                        $<%= repuesto.getPrecioCompra() != null ? 
                                            String.format("%,.2f", repuesto.getPrecioCompra()) : "0.00" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Precio de Venta:</strong>
                                    <span>
                                        $<%= repuesto.getPrecioVenta() != null ? 
                                            String.format("%,.2f", repuesto.getPrecioVenta()) : "0.00" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Margen de Ganancia:</strong>
                                    <span>
                                        <% if (repuesto.getPrecioCompra() != null && repuesto.getPrecioVenta() != null && 
                                              repuesto.getPrecioCompra().compareTo(java.math.BigDecimal.ZERO) > 0) { 
                                            java.math.BigDecimal margen = repuesto.getPrecioVenta().subtract(repuesto.getPrecioCompra());
                                            double porcentaje = (margen.doubleValue() / repuesto.getPrecioCompra().doubleValue()) * 100;
                                        %>
                                            $<%= String.format("%,.2f", margen) %> (<%= String.format("%.1f", porcentaje) %>%)
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Valor en Inventario:</strong>
                                    <span>
                                        <% if (repuesto.getPrecioCompra() != null && repuesto.getStock() != null) { 
                                            java.math.BigDecimal valorTotal = repuesto.getPrecioCompra().multiply(
                                                new java.math.BigDecimal(repuesto.getStock()));
                                        %>
                                            $<%= String.format("%,.2f", valorTotal) %>
                                        <% } else { %>
                                            $0.00
                                        <% } %>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Barra Lateral -->
                        <div class="sidebar-info">
                            <!-- Estado Actual -->
                            <div class="status-card" style="border-color: <%= statusColor %>;">
                                <div class="status-icon"><%= statusIcon %></div>
                                <div class="status-text" style="color: <%= statusColor %>;">
                                    <%= statusText %>
                                </div>
                                <div class="stock-info">
                                    <%= repuesto.getStock() != null ? repuesto.getStock() : 0 %> unidades
                                </div>
                                <% if (repuesto.getStockMinimo() != null) { %>
                                    <small style="color: #6c757d;">
                                        Mínimo: <%= repuesto.getStockMinimo() %> unidades
                                    </small>
                                <% } %>
                            </div>

                            <!-- Acciones Rápidas -->
                            <div class="info-card">
                                <h3>🚀 Acciones Rápidas</h3>
                                <div class="quick-actions">
                                    <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                       class="btn btn-primary btn-block">
                                        📋 Solicitar Repuesto
                                    </a>
                                    <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                                       class="btn btn-info btn-block">
                                        🔍 Consultar Disponibilidad
                                    </a>
                                    <a href="${pageContext.request.contextPath}/mecanico/inventario/disponibilidad?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                       class="btn btn-warning btn-block">
                                        ⚠️ Verificar Stock
                                    </a>
                                </div>
                            </div>

                            <!-- Información de Uso -->
                            <div class="info-card">
                                <h3>📊 Estadísticas de Uso</h3>
                                <div class="detail-item">
                                    <strong>Total en Facturas:</strong>
                                    <span>
                                        <%= repuesto.getDetalleFacturaList() != null ? 
                                            repuesto.getDetalleFacturaList().size() : 0 %> veces
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Último Movimiento:</strong>
                                    <span>
                                        <% if (repuesto.getDetalleFacturaList() != null && 
                                              !repuesto.getDetalleFacturaList().isEmpty()) { 
                                            // Aquí podrías mostrar la fecha del último movimiento
                                        %>
                                            Reciente
                                        <% } else { %>
                                            Sin movimientos
                                        <% } %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Acciones Principales -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                           class="btn btn-primary">
                            📋 Solicitar Este Repuesto
                        </a>
                        <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                           class="btn btn-info">
                            🔍 Consultar Disponibilidad
                        </a>
                        <a href="${pageContext.request.contextPath}/mecanico/inventario" 
                           class="btn btn-secondary">
                            ↩️ Volver al Inventario
                        </a>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el repuesto solicitado.</p>
                    <a href="${pageContext.request.contextPath}/mecanico/inventario" class="btn btn-secondary">
                        Volver al Inventario
                    </a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>