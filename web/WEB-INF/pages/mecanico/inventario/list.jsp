<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Repuesto, java.util.List, java.math.BigDecimal" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Repuesto> repuestosDisponibles = (List<Repuesto>) request.getAttribute("repuestosDisponibles");
    List<Repuesto> repuestosBajoStock = (List<Repuesto>) request.getAttribute("repuestosBajoStock");
    List<Repuesto> repuestosStockCritico = (List<Repuesto>) request.getAttribute("repuestosStockCritico");
    Long totalRepuestosActivos = (Long) request.getAttribute("totalRepuestosActivos");
    Long repuestosConStockBajo = (Long) request.getAttribute("repuestosConStockBajo");
    Double valorTotalInventario = (Double) request.getAttribute("valorTotalInventario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario - Taller Automotriz</title>
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
                <h1>📦 Gestión de Inventario</h1>
                <p>Gestiona y consulta el stock de repuestos disponibles</p>
            </div>

            <!-- Estadísticas del Inventario -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number"><%= totalRepuestosActivos != null ? totalRepuestosActivos : 0 %></div>
                    <div class="stat-label">Repuestos Activos</div>
                </div>
                
                <div class="stat-card warning">
                    <div class="stat-number"><%= repuestosConStockBajo != null ? repuestosConStockBajo : 0 %></div>
                    <div class="stat-label">Con Stock Bajo</div>
                </div>
                
                <div class="stat-card danger">
                    <div class="stat-number"><%= repuestosStockCritico != null ? repuestosStockCritico.size() : 0 %></div>
                    <div class="stat-label">Stock Crítico</div>
                </div>
                
                <div class="stat-card success">
                    <div class="stat-number">$<%= valorTotalInventario != null ? 
                        String.format("%,.2f", valorTotalInventario) : "0.00" %></div>
                    <div class="stat-label">Valor Total Inventario</div>
                </div>
            </div>

            <!-- Acciones Rápidas -->
            <div class="quick-actions">
                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar" class="btn btn-primary">
                    📋 Solicitar Repuesto
                </a>
                <a href="${pageContext.request.contextPath}/mecanico/inventario/alertas" class="btn btn-warning">
                    ⚠️ Ver Alertas
                </a>
                <a href="${pageContext.request.contextPath}/mecanico/inventario/disponibilidad" class="btn btn-info">
                    🔍 Verificar Disponibilidad
                </a>
                
                <!-- Formulario de Búsqueda -->
                <form action="${pageContext.request.contextPath}/mecanico/inventario/buscar" method="get" class="search-form" style="margin-left: auto;">
                    <select name="criterio" class="form-control" style="width: auto;">
                        <option value="nombre">Por Nombre</option>
                        <option value="descripcion">Por Descripción</option>
                        <option value="stock_bajo">Stock Bajo</option>
                        <option value="disponibles">Disponibles</option>
                    </select>
                    <input type="text" name="valor" placeholder="Buscar repuestos..." class="form-control">
                    <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                </form>
            </div>

            <!-- Lista de Repuestos Disponibles -->
            <h3 class="section-title">📋 Repuestos Disponibles</h3>
            <div class="table-container">
                <% if (repuestosDisponibles == null || repuestosDisponibles.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📦</div>
                        <h3>No hay repuestos disponibles</h3>
                        <p>No se encontraron repuestos activos en el inventario.</p>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Descripción</th>
                                <th>Stock</th>
                                <th>Stock Mínimo</th>
                                <th>Precio Compra</th>
                                <th>Estado Stock</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Repuesto repuesto : repuestosDisponibles) { 
                                String estadoStock = "stock-available";
                                String estadoTexto = "DISPONIBLE";
                                
                                if (repuesto.getStock() == null || repuesto.getStock() == 0) {
                                    estadoStock = "stock-out";
                                    estadoTexto = "AGOTADO";
                                } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo() / 2) {
                                    estadoStock = "stock-critical";
                                    estadoTexto = "CRÍTICO";
                                } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo()) {
                                    estadoStock = "stock-low";
                                    estadoTexto = "BAJO";
                                }
                            %>
                                <tr>
                                    <td>#<%= repuesto.getIDRepuesto() %></td>
                                    <td><strong><%= repuesto.getNombreRepuesto() %></strong></td>
                                    <td>
                                        <%= repuesto.getDescripcion() != null ? 
                                            (repuesto.getDescripcion().length() > 50 ? 
                                             repuesto.getDescripcion().substring(0, 50) + "..." : 
                                             repuesto.getDescripcion()) : "Sin descripción" %>
                                    </td>
                                    <td><%= repuesto.getStock() != null ? repuesto.getStock() : 0 %></td>
                                    <td><%= repuesto.getStockMinimo() != null ? repuesto.getStockMinimo() : "N/A" %></td>
                                    <td>$<%= repuesto.getPrecioCompra() != null ? 
                                          String.format("%,.2f", repuesto.getPrecioCompra()) : "0.00" %></td>
                                    <td>
                                        <span class="stock-status <%= estadoStock %>">
                                            <%= estadoTexto %>
                                        </span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/mecanico/inventario/ver?id=<%= repuesto.getIDRepuesto() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                                               class="btn btn-sm btn-primary" title="Consultar disponibilidad">
                                                🔍 Consultar
                                            </a>
                                            <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                               class="btn btn-sm btn-success" title="Solicitar repuesto">
                                                📋 Solicitar
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <div class="table-info">
                        <p>Total de repuestos: <strong><%= repuestosDisponibles.size() %></strong></p>
                    </div>
                <% } %>
            </div>

            <!-- Alertas de Stock Bajo -->
            <% if (repuestosBajoStock != null && !repuestosBajoStock.isEmpty()) { %>
                <h3 class="section-title">⚠️ Repuestos con Stock Bajo</h3>
                <div class="table-container">
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Stock Actual</th>
                                <th>Stock Mínimo</th>
                                <th>Diferencia</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Repuesto repuesto : repuestosBajoStock) { 
                                int diferencia = repuesto.getStockMinimo() - repuesto.getStock();
                            %>
                                <tr>
                                    <td><strong><%= repuesto.getNombreRepuesto() %></strong></td>
                                    <td><span class="stock-status stock-low"><%= repuesto.getStock() %></span></td>
                                    <td><%= repuesto.getStockMinimo() %></td>
                                    <td><span style="color: #dc3545; font-weight: bold;">-<%= diferencia %></span></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                           class="btn btn-sm btn-warning">
                                            📋 Solicitar
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>