<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenesAsignadas = (List<OrdenServicio>) request.getAttribute("ordenesAsignadas");
    Double horasTrabajadas = (Double) request.getAttribute("horasTrabajadas");
    Double horasPromedioPorOrden = (Double) request.getAttribute("horasPromedioPorOrden");
    Long ordenesCompletadas = (Long) request.getAttribute("ordenesCompletadas");
    Long ordenesPendientes = (Long) request.getAttribute("ordenesPendientes");
    
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
    String criterio = (String) request.getAttribute("criterio");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Horas - Mecánico</title>
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
                <h1>⏰ Gestión de Horas</h1>
                <p>Administra y registra las horas trabajadas en las órdenes de servicio</p>
            </div>

            <!-- Estadísticas -->
            <div class="stats-grid">
                <div class="stat-card horas">
                    <span class="stat-number"><%= String.format("%.1f", horasTrabajadas != null ? horasTrabajadas : 0.0) %></span>
                    <span class="stat-label">Horas Trabajadas</span>
                </div>
                <div class="stat-card">
                    <span class="stat-number"><%= String.format("%.1f", horasPromedioPorOrden != null ? horasPromedioPorOrden : 0.0) %></span>
                    <span class="stat-label">Horas Promedio/Orden</span>
                </div>
                <div class="stat-card completadas">
                    <span class="stat-number"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></span>
                    <span class="stat-label">Órdenes Completadas</span>
                </div>
                <div class="stat-card pendientes">
                    <span class="stat-number"><%= ordenesPendientes != null ? ordenesPendientes : 0 %></span>
                    <span class="stat-label">Órdenes Pendientes</span>
                </div>
            </div>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/mecanico/horas/registrar" class="btn btn-primary">
                        <span class="btn-icon">⏱️</span> Registrar Horas
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/horas/reportar" class="btn btn-info">
                        <span class="btn-icon">📊</span> Reportar Productividad
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/horas/mis-horas" class="btn btn-success">
                        <span class="btn-icon">👤</span> Mis Horas
                    </a>
                </div>
            </div>

            <!-- Filtros -->
            <div class="filter-section">
                <h3>🔍 Filtros de Búsqueda</h3>
                <form action="${pageContext.request.contextPath}/mecanico/horas/buscar" method="get" class="filter-grid">
                    <div class="form-group">
                        <label for="fechaInicio">Fecha Inicio</label>
                        <input type="date" id="fechaInicio" name="fechaInicio" 
                               value="<%= fechaInicio != null ? fechaInicio : "" %>" class="form-control">
                    </div>
                    <div class="form-group">
                        <label for="fechaFin">Fecha Fin</label>
                        <input type="date" id="fechaFin" name="fechaFin" 
                               value="<%= fechaFin != null ? fechaFin : "" %>" class="form-control">
                    </div>
                    <div class="form-group">
                        <label for="criterio">Estado</label>
                        <select id="criterio" name="criterio" class="form-control">
                            <option value="">Todos</option>
                            <option value="completadas" <%= "completadas".equals(criterio) ? "selected" : "" %>>Completadas</option>
                            <option value="pendientes" <%= "pendientes".equals(criterio) ? "selected" : "" %>>Pendientes</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                        <a href="${pageContext.request.contextPath}/mecanico/horas" class="btn btn-outline">🔄 Limpiar</a>
                    </div>
                </form>
            </div>

            <!-- Tabla de órdenes -->
            <div class="table-container">
                <% if (ordenesAsignadas == null || ordenesAsignadas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔧</div>
                        <h3>No hay órdenes asignadas</h3>
                        <p>No tienes órdenes de servicio asignadas en este momento.</p>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID Orden</th>
                                <th>Vehículo</th>
                                <th>Problema Reportado</th>
                                <th>Fecha Entrada</th>
                                <th>Fecha Est. Salida</th>
                                <th>Estado</th>
                                <th>Horas Trabajadas</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio orden : ordenesAsignadas) { 
                                double horasOrden = 0.0;
                                if (orden.getFechaEntrada() != null && orden.getFechaRealSalida() != null) {
                                    long diff = orden.getFechaRealSalida().getTime() - orden.getFechaEntrada().getTime();
                                    horasOrden = diff / (1000.0 * 60 * 60);
                                }
                            %>
                                <tr>
                                    <td>#<%= orden.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (orden.getIDVehiculo() != null) { %>
                                            <strong><%= orden.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= orden.getProblemaReportado() != null ? 
                                            (orden.getProblemaReportado().length() > 50 ? 
                                             orden.getProblemaReportado().substring(0, 50) + "..." : 
                                             orden.getProblemaReportado()) : "N/A" %>
                                    </td>
                                    <td><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></td>
                                    <td><%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %></td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "Pendiente";
                                            
                                            if (orden.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "Completada";
                                            } else if (orden.getIDEstadoTrabajo() != null) {
                                                estadoTexto = orden.getIDEstadoTrabajo().getNombreEstado();
                                                if ("EN PROCESO".equals(estadoTexto)) {
                                                    estadoClase = "badge-info";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-danger";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td>
                                        <span class="hours-badge"><%= String.format("%.1f", horasOrden) %> hrs</span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <% if (orden.getFechaRealSalida() == null) { %>
                                                <a href="${pageContext.request.contextPath}/mecanico/horas/registrar" 
                                                   class="btn btn-sm btn-primary" title="Registrar horas">
                                                    ⏱️ Registrar
                                                </a>
                                                <a href="${pageContext.request.contextPath}/mecanico/horas/justificar?idOrden=<%= orden.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-warning" title="Justificar horas">
                                                    📝 Justificar
                                                </a>
                                            <% } else { %>
                                                <span class="text-muted">Completada</span>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de órdenes: <strong><%= ordenesAsignadas.size() %></strong></p>
                        <p>Horas totales trabajadas: <strong><%= String.format("%.1f", horasTrabajadas != null ? horasTrabajadas : 0.0) %> horas</strong></p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>