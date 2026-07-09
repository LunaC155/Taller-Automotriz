<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión por ID de rol numérico
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
    Integer idEmpleado = (Integer) session.getAttribute("idEmpleado");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Órdenes - Mecánico</title>
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
                <h1>🔧 Mis Órdenes de Trabajo</h1>
                <p>Gestiona las órdenes de servicio asignadas a ti</p>
                <% if (idEmpleado != null) { %>
                    <small>ID Empleado: <%= idEmpleado %></small>
                <% } %>
            </div>

            <!-- Filtros y Búsqueda -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/mecanico/ordenes" class="btn btn-secondary">
                        <span class="btn-icon">🔄</span> Actualizar
                    </a>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/mecanico/ordenes/buscar" method="get" class="search-form">
                        <div class="input-group">
                            <input type="text" name="valor" value="<%= valor != null ? valor : "" %>" 
                                   placeholder="Buscar por placa, cliente o problema..." class="form-control">
                            <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Estadísticas Rápidas -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">📋</div>
                    <div class="stat-info">
                        <h3><%= ordenes != null ? ordenes.size() : 0 %></h3>
                        <p>Total Órdenes</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-info">
                        <h3><%= ordenes != null ? ordenes.stream().filter(o -> "EN PROCESO".equals(o.getIDEstadoTrabajo() != null ? o.getIDEstadoTrabajo().getNombreEstado() : "")).count() : 0 %></h3>
                        <p>En Proceso</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-info">
                        <h3><%= ordenes != null ? ordenes.stream().filter(o -> "COMPLETADO".equals(o.getIDEstadoTrabajo() != null ? o.getIDEstadoTrabajo().getNombreEstado() : "")).count() : 0 %></h3>
                        <p>Completadas</p>
                    </div>
                </div>
            </div>

            <!-- Lista de Órdenes -->
            <div class="orders-container">
                <% if (ordenes == null || ordenes.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔧</div>
                        <h3>No hay órdenes asignadas</h3>
                        <p>No tienes órdenes de servicio asignadas en este momento.</p>
                        <p>Las nuevas órdenes aparecerán aquí cuando te sean asignadas.</p>
                    </div>
                <% } else { %>
                    <div class="orders-grid">
                        <% for (OrdenServicio orden : ordenes) { 
                            String estado = orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "PENDIENTE";
                            String estadoClase = "badge-warning";
                            String prioridad = "priority-medium";
                            
                            switch(estado) {
                                case "EN PROCESO":
                                    estadoClase = "badge-info";
                                    prioridad = "priority-high";
                                    break;
                                case "COMPLETADO":
                                    estadoClase = "badge-success";
                                    prioridad = "priority-low";
                                    break;
                                case "CANCELADO":
                                    estadoClase = "badge-danger";
                                    break;
                            }
                            
                            // Determinar urgencia por fecha
                            if (orden.getFechaEstimadaSalida() != null) {
                                java.util.Date hoy = new java.util.Date();
                                long diff = orden.getFechaEstimadaSalida().getTime() - hoy.getTime();
                                long dias = diff / (1000 * 60 * 60 * 24);
                                if (dias <= 1) {
                                    prioridad = "priority-high";
                                }
                            }
                        %>
                            <div class="order-card <%= prioridad %>">
                                <div class="order-header">
                                    <div class="order-title">
                                        <h4>Orden #<%= orden.getIDOrdenServicio() %></h4>
                                        <span class="status-badge <%= estadoClase %>"><%= estado %></span>
                                    </div>
                                    <div class="order-meta">
                                        <small>Entrada: <%= orden.getFechaEntrada() != null ? new SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEntrada()) : "N/A" %></small>
                                    </div>
                                </div>
                                
                                <div class="order-body">
                                    <div class="vehicle-info">
                                        <strong>🚗 <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %></strong>
                                        <% if (orden.getIDVehiculo() != null) { %>
                                            <br>
                                            <small>
                                                <%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                            <br>
                                            <small>Cliente: 
                                                <%= orden.getIDVehiculo().getIDCliente() != null ? 
                                                    orden.getIDVehiculo().getIDCliente().getNombre() + " " + orden.getIDVehiculo().getIDCliente().getApellido() : "N/A" %>
                                            </small>
                                        <% } %>
                                    </div>
                                    
                                    <div class="problem-preview">
                                        <strong>Problema:</strong>
                                        <%= orden.getProblemaReportado() != null ? 
                                            (orden.getProblemaReportado().length() > 100 ? 
                                             orden.getProblemaReportado().substring(0, 100) + "..." : 
                                             orden.getProblemaReportado()) : "No especificado" %>
                                    </div>
                                    
                                    <% if (orden.getFechaEstimadaSalida() != null) { %>
                                        <div class="delivery-info">
                                            <small><strong>Entrega estimada:</strong> 
                                                <%= new SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEstimadaSalida()) %>
                                            </small>
                                        </div>
                                    <% } %>
                                </div>
                                
                                <div class="order-actions">
                                    <a href="${pageContext.request.contextPath}/mecanico/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>" 
                                       class="btn btn-sm btn-info">👁️ Ver Detalles</a>
                                       
                                    <% if (!"COMPLETADO".equals(estado) && !"CANCELADO".equals(estado)) { %>
                                        <a href="${pageContext.request.contextPath}/mecanico/ordenes/actualizar-estado?id=<%= orden.getIDOrdenServicio() %>" 
                                           class="btn btn-sm btn-warning">🔄 Actualizar Estado</a>
                                    <% } %>
                                    
                                    <% if ("EN PROCESO".equals(estado)) { %>
                                        <a href="${pageContext.request.contextPath}/mecanico/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>#avances" 
                                           class="btn btn-sm btn-primary">📝 Registrar Avance</a>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    
                    <!-- Resumen -->
                    <div class="table-info">
                        <p>Total de órdenes: <strong><%= ordenes.size() %></strong></p>
                        <p>
                            <span class="badge badge-warning">Pendientes: <%= ordenes.stream().filter(o -> "PENDIENTE".equals(o.getIDEstadoTrabajo() != null ? o.getIDEstadoTrabajo().getNombreEstado() : "")).count() %></span>
                            <span class="badge badge-info">En Proceso: <%= ordenes.stream().filter(o -> "EN PROCESO".equals(o.getIDEstadoTrabajo() != null ? o.getIDEstadoTrabajo().getNombreEstado() : "")).count() %></span>
                            <span class="badge badge-success">Completadas: <%= ordenes.stream().filter(o -> "COMPLETADO".equals(o.getIDEstadoTrabajo() != null ? o.getIDEstadoTrabajo().getNombreEstado() : "")).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>