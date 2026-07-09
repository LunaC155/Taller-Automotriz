<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Repuesto, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Repuesto> repuestosBajoStock = (List<Repuesto>) request.getAttribute("repuestosBajoStock");
    List<Repuesto> repuestosStockCritico = (List<Repuesto>) request.getAttribute("repuestosStockCritico");
    List<Repuesto> repuestosAgotados = (List<Repuesto>) request.getAttribute("repuestosAgotados");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alertas de Stock - Taller Automotriz</title>
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
                <h1>⚠️ Alertas de Stock</h1>
                <p>Monitoreo de repuestos con stock bajo, crítico o agotado</p>
            </div>

            <!-- Resumen de Alertas -->
            <div class="summary-grid">
                <div class="summary-card summary-critical">
                    <div class="summary-number" style="color: #dc3545;">
                        <%= repuestosStockCritico != null ? repuestosStockCritico.size() : 0 %>
                    </div>
                    <div class="summary-label">Stock Crítico</div>
                </div>
                
                <div class="summary-card summary-warning">
                    <div class="summary-number" style="color: #ffc107;">
                        <%= repuestosBajoStock != null ? repuestosBajoStock.size() : 0 %>
                    </div>
                    <div class="summary-label">Stock Bajo</div>
                </div>
                
                <div class="summary-card summary-out">
                    <div class="summary-number" style="color: #6c757d;">
                        <%= repuestosAgotados != null ? repuestosAgotados.size() : 0 %>
                    </div>
                    <div class="summary-label">Agotados</div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-number" style="color: #007bff;">
                        <%= (repuestosStockCritico != null ? repuestosStockCritico.size() : 0) + 
                            (repuestosBajoStock != null ? repuestosBajoStock.size() : 0) + 
                            (repuestosAgotados != null ? repuestosAgotados.size() : 0) %>
                    </div>
                    <div class="summary-label">Total Alertas</div>
                </div>
            </div>

            <!-- Alertas de Stock Crítico -->
            <div class="alert-section alert-critical">
                <div class="alert-header">
                    <div class="alert-icon">🚨</div>
                    <h2 class="alert-title">Stock Crítico</h2>
                    <div class="alert-count">
                        <%= repuestosStockCritico != null ? repuestosStockCritico.size() : 0 %>
                    </div>
                </div>
                
                <% if (repuestosStockCritico == null || repuestosStockCritico.isEmpty()) { %>
                    <div class="empty-alert">
                        <div class="empty-icon">✅</div>
                        <h3>Sin Alertas Críticas</h3>
                        <p>No hay repuestos con stock crítico en este momento.</p>
                    </div>
                <% } else { %>
                    <div class="table-container">
                        <table class="crud-table">
                            <thead>
                                <tr>
                                    <th>Repuesto</th>
                                    <th>Stock Actual</th>
                                    <th>Stock Mínimo</th>
                                    <th>Déficit</th>
                                    <th>Prioridad</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Repuesto repuesto : repuestosStockCritico) { 
                                    int deficit = repuesto.getStockMinimo() - repuesto.getStock();
                                    int porcentaje = (repuesto.getStock() * 100) / repuesto.getStockMinimo();
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= repuesto.getNombreRepuesto() %></strong><br>
                                            <small style="color: #6c757d;"><%= repuesto.getDescripcion() != null ? 
                                                (repuesto.getDescripcion().length() > 50 ? 
                                                 repuesto.getDescripcion().substring(0, 50) + "..." : 
                                                 repuesto.getDescripcion()) : "Sin descripción" %></small>
                                        </td>
                                        <td>
                                            <span style="color: #dc3545; font-weight: bold;">
                                                <%= repuesto.getStock() %> unidades
                                            </span>
                                        </td>
                                        <td><%= repuesto.getStockMinimo() %> unidades</td>
                                        <td>
                                            <span style="color: #dc3545; font-weight: bold;">-<%= deficit %></span>
                                        </td>
                                        <td>
                                            <span class="priority-badge priority-high">ALTA</span>
                                        </td>
                                        <td>
                                            <div class="stock-indicator">
                                                <div class="stock-bar">
                                                    <div class="stock-fill fill-critical" 
                                                         style="width: <%= porcentaje %>%"></div>
                                                </div>
                                                <span style="font-size: 0.85em; color: #dc3545;">
                                                    <%= porcentaje %>%
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                                   class="btn btn-sm btn-danger">
                                                    🚨 Solicitar Urgente
                                                </a>
                                                <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                                                   class="btn btn-sm btn-info">
                                                    🔍 Ver
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

            <!-- Alertas de Stock Bajo -->
            <div class="alert-section alert-warning">
                <div class="alert-header">
                    <div class="alert-icon">⚠️</div>
                    <h2 class="alert-title">Stock Bajo</h2>
                    <div class="alert-count">
                        <%= repuestosBajoStock != null ? repuestosBajoStock.size() : 0 %>
                    </div>
                </div>
                
                <% if (repuestosBajoStock == null || repuestosBajoStock.isEmpty()) { %>
                    <div class="empty-alert">
                        <div class="empty-icon">✅</div>
                        <h3>Sin Alertas de Stock Bajo</h3>
                        <p>No hay repuestos con stock bajo en este momento.</p>
                    </div>
                <% } else { %>
                    <div class="table-container">
                        <table class="crud-table">
                            <thead>
                                <tr>
                                    <th>Repuesto</th>
                                    <th>Stock Actual</th>
                                    <th>Stock Mínimo</th>
                                    <th>Déficit</th>
                                    <th>Prioridad</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Repuesto repuesto : repuestosBajoStock) { 
                                    int deficit = repuesto.getStockMinimo() - repuesto.getStock();
                                    int porcentaje = (repuesto.getStock() * 100) / repuesto.getStockMinimo();
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= repuesto.getNombreRepuesto() %></strong><br>
                                            <small style="color: #6c757d;"><%= repuesto.getDescripcion() != null ? 
                                                (repuesto.getDescripcion().length() > 50 ? 
                                                 repuesto.getDescripcion().substring(0, 50) + "..." : 
                                                 repuesto.getDescripcion()) : "Sin descripción" %></small>
                                        </td>
                                        <td>
                                            <span style="color: #ffc107; font-weight: bold;">
                                                <%= repuesto.getStock() %> unidades
                                            </span>
                                        </td>
                                        <td><%= repuesto.getStockMinimo() %> unidades</td>
                                        <td>
                                            <span style="color: #ffc107; font-weight: bold;">-<%= deficit %></span>
                                        </td>
                                        <td>
                                            <span class="priority-badge priority-medium">MEDIA</span>
                                        </td>
                                        <td>
                                            <div class="stock-indicator">
                                                <div class="stock-bar">
                                                    <div class="stock-fill fill-warning" 
                                                         style="width: <%= porcentaje %>%"></div>
                                                </div>
                                                <span style="font-size: 0.85em; color: #ffc107;">
                                                    <%= porcentaje %>%
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                                   class="btn btn-sm btn-warning">
                                                    📋 Solicitar
                                                </a>
                                                <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                                                   class="btn btn-sm btn-info">
                                                    🔍 Ver
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

            <!-- Repuestos Agotados -->
            <div class="alert-section alert-info">
                <div class="alert-header">
                    <div class="alert-icon">❌</div>
                    <h2 class="alert-title">Repuestos Agotados</h2>
                    <div class="alert-count">
                        <%= repuestosAgotados != null ? repuestosAgotados.size() : 0 %>
                    </div>
                </div>
                
                <% if (repuestosAgotados == null || repuestosAgotados.isEmpty()) { %>
                    <div class="empty-alert">
                        <div class="empty-icon">✅</div>
                        <h3>Sin Repuestos Agotados</h3>
                        <p>No hay repuestos completamente agotados en este momento.</p>
                    </div>
                <% } else { %>
                    <div class="table-container">
                        <table class="crud-table">
                            <thead>
                                <tr>
                                    <th>Repuesto</th>
                                    <th>Stock Actual</th>
                                    <th>Stock Mínimo</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Repuesto repuesto : repuestosAgotados) { %>
                                    <tr>
                                        <td>
                                            <strong><%= repuesto.getNombreRepuesto() %></strong><br>
                                            <small style="color: #6c757d;"><%= repuesto.getDescripcion() != null ? 
                                                (repuesto.getDescripcion().length() > 50 ? 
                                                 repuesto.getDescripcion().substring(0, 50) + "..." : 
                                                 repuesto.getDescripcion()) : "Sin descripción" %></small>
                                        </td>
                                        <td>
                                            <span style="color: #6c757d; font-weight: bold;">
                                                0 unidades
                                            </span>
                                        </td>
                                        <td><%= repuesto.getStockMinimo() != null ? repuesto.getStockMinimo() : "N/A" %> unidades</td>
                                        <td>
                                            <span class="priority-badge priority-low">AGOTADO</span>
                                        </td>
                                        <td>
                                            <div class="stock-indicator">
                                                <div class="stock-bar">
                                                    <div class="stock-fill fill-out" style="width: 0%"></div>
                                                </div>
                                                <span style="font-size: 0.85em; color: #6c757d;">0%</span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                                   class="btn btn-sm btn-secondary">
                                                    📋 Solicitar
                                                </a>
                                                <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                                                   class="btn btn-sm btn-info">
                                                    🔍 Ver
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

            <!-- Acciones Globales -->
            <div class="action-buttons" style="margin-top: 30px; text-align: center;">
                <a href="${pageContext.request.contextPath}/mecanico/inventario" class="btn btn-secondary">
                    ↩️ Volver al Inventario
                </a>
                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar" class="btn btn-primary">
                    📋 Nueva Solicitud
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>