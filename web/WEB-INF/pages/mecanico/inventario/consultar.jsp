<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Repuesto" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Repuesto repuesto = (Repuesto) request.getAttribute("repuesto");
    String estadoStock = (String) request.getAttribute("estadoStock");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultar Repuesto - Taller Automotriz</title>
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
                <h1>🔍 Consultar Repuesto</h1>
                <p>Información detallada y disponibilidad del repuesto</p>
            </div>

            <% if (repuesto != null) { 
                String statusClass = "status-available";
                String fillClass = "fill-available";
                int porcentajeStock = 100;
                
                if (repuesto.getStockMinimo() != null && repuesto.getStock() != null) {
                    if (repuesto.getStock() == 0) {
                        statusClass = "status-out";
                        fillClass = "fill-out";
                        porcentajeStock = 0;
                    } else if (repuesto.getStock() <= repuesto.getStockMinimo() / 2) {
                        statusClass = "status-critical";
                        fillClass = "fill-critical";
                        porcentajeStock = (repuesto.getStock() * 100) / repuesto.getStockMinimo();
                    } else if (repuesto.getStock() <= repuesto.getStockMinimo()) {
                        statusClass = "status-low";
                        fillClass = "fill-low";
                        porcentajeStock = (repuesto.getStock() * 100) / repuesto.getStockMinimo();
                    } else {
                        porcentajeStock = 100;
                    }
                }
            %>
                <div class="detail-container">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <h2><%= repuesto.getNombreRepuesto() %></h2>
                        <span class="stock-status-large <%= statusClass %>">
                            <%= estadoStock != null ? estadoStock : "DISPONIBLE" %>
                        </span>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información Básica -->
                        <div class="detail-card">
                            <h3>📋 Información Básica</h3>
                            <div class="detail-item">
                                <strong>ID:</strong>
                                <span>#<%= repuesto.getIDRepuesto() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Nombre:</strong>
                                <span><%= repuesto.getNombreRepuesto() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Descripción:</strong>
                                <span><%= repuesto.getDescripcion() != null ? repuesto.getDescripcion() : "Sin descripción" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado:</strong>
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
                        <div class="detail-card">
                            <h3>📦 Información de Stock</h3>
                            <div class="detail-item">
                                <strong>Stock Actual:</strong>
                                <span><%= repuesto.getStock() != null ? repuesto.getStock() : 0 %> unidades</span>
                            </div>
                            <div class="detail-item">
                                <strong>Stock Mínimo:</strong>
                                <span><%= repuesto.getStockMinimo() != null ? repuesto.getStockMinimo() : "N/A" %> unidades</span>
                            </div>
                            <div class="detail-item">
                                <strong>Disponibilidad:</strong>
                                <span>
                                    <% if (repuesto.getStock() == null || repuesto.getStock() == 0) { %>
                                        <span style="color: #dc3545; font-weight: bold;">❌ Agotado</span>
                                    <% } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo()) { %>
                                        <span style="color: #ffc107; font-weight: bold;">⚠️ Stock Bajo</span>
                                    <% } else { %>
                                        <span style="color: #28a745; font-weight: bold;">✅ Disponible</span>
                                    <% } %>
                                </span>
                            </div>

                            <!-- Indicador de Stock -->
                            <div class="stock-indicator">
                                <strong>Nivel de Stock:</strong>
                                <div class="stock-bar">
                                    <div class="stock-fill <%= fillClass %>" 
                                         style="width: <%= porcentajeStock %>%"></div>
                                </div>
                                <small>
                                    <% if (repuesto.getStockMinimo() != null) { %>
                                        Stock actual: <%= repuesto.getStock() %> / Mínimo requerido: <%= repuesto.getStockMinimo() %>
                                    <% } else { %>
                                        Stock actual: <%= repuesto.getStock() != null ? repuesto.getStock() : 0 %> unidades
                                    <% } %>
                                </small>
                            </div>
                        </div>

                        <!-- Información de Precios -->
                        <div class="detail-card">
                            <h3>💰 Información de Precios</h3>
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
                        </div>
                    </div>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                           class="btn btn-primary">
                            📋 Solicitar Este Repuesto
                        </a>
                        <a href="${pageContext.request.contextPath}/mecanico/inventario/ver?id=<%= repuesto.getIDRepuesto() %>" 
                           class="btn btn-info">
                            👁️ Ver Detalles Completos
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