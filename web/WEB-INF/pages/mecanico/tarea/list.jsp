<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Servicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenesAsignadas = (List<OrdenServicio>) request.getAttribute("ordenesAsignadas");
    List<Servicio> serviciosActivos = (List<Servicio>) request.getAttribute("serviciosActivos");
    Integer totalOrdenesAsignadas = (Integer) request.getAttribute("totalOrdenesAsignadas");
    Long ordenesPendientes = (Long) request.getAttribute("ordenesPendientes");
    Long ordenesCompletadas = (Long) request.getAttribute("ordenesCompletadas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Tareas - Taller Automotriz</title>
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
                <h1>🔧 Mis Tareas</h1>
                <p>Gestiona las órdenes de servicio asignadas a ti</p>
            </div>

            <!-- Dashboard de Estadísticas -->
            <div class="dashboard-cards">
                <div class="dashboard-card total">
                    <div class="card-icon">📋</div>
                    <div class="card-number"><%= totalOrdenesAsignadas != null ? totalOrdenesAsignadas : 0 %></div>
                    <div class="card-title">Total de Tareas</div>
                </div>
                <div class="dashboard-card pending">
                    <div class="card-icon">⏳</div>
                    <div class="card-number"><%= ordenesPendientes != null ? ordenesPendientes : 0 %></div>
                    <div class="card-title">Tareas Pendientes</div>
                </div>
                <div class="dashboard-card completed">
                    <div class="card-icon">✅</div>
                    <div class="card-number"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></div>
                    <div class="card-title">Tareas Completadas</div>
                </div>
            </div>

            <!-- Búsqueda -->
            <div class="search-section">
                <form action="${pageContext.request.contextPath}/mecanico/tareas/buscar" method="get" class="search-form">
                    <div class="form-group">
                        <label for="criterio">Buscar por:</label>
                        <select id="criterio" name="criterio" class="form-control">
                            <option value="problema">Problema</option>
                            <option value="vehiculo">Vehículo</option>
                            <option value="estado">Estado</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="valor">Término de búsqueda:</label>
                        <input type="text" id="valor" name="valor" class="form-control" placeholder="Ingrese su búsqueda...">
                    </div>
                    <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                </form>
            </div>

            <!-- Lista de Tareas -->
            <div class="section-header">
                <h2>📋 Órdenes Asignadas</h2>
                <p>Gestiona las tareas que te han sido asignadas</p>
            </div>

            <% if (ordenesAsignadas == null || ordenesAsignadas.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-icon">🔧</div>
                    <h3>No hay tareas asignadas</h3>
                    <p>No tienes órdenes de servicio asignadas en este momento.</p>
                    <p>Las nuevas tareas aparecerán aquí cuando te sean asignadas.</p>
                </div>
            <% } else { %>
                <div class="task-grid">
                    <% for (OrdenServicio orden : ordenesAsignadas) { 
                        boolean estaCompletada = orden.getFechaRealSalida() != null;
                        String estadoClase = estaCompletada ? "status-completed" : "status-pending";
                        String estadoTexto = estaCompletada ? "COMPLETADA" : "PENDIENTE";
                    %>
                        <div class="task-card">
                            <div class="task-header">
                                <div class="task-title">
                                    <h3><%= orden.getProblemaReportado() != null && orden.getProblemaReportado().length() > 50 ? 
                                          orden.getProblemaReportado().substring(0, 50) + "..." : 
                                          (orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "Sin descripción") %></h3>
                                    <div class="task-id">Orden #<%= orden.getIDOrdenServicio() %></div>
                                </div>
                                <span class="task-status <%= estadoClase %>"><%= estadoTexto %></span>
                            </div>
                            
                            <div class="task-details">
                                <div class="detail-row">
                                    <span class="detail-label">Fecha Entrada:</span>
                                    <span class="detail-value"><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></span>
                                </div>
                                
                                <div class="detail-row">
                                    <span class="detail-label">Fecha Estimada:</span>
                                    <span class="detail-value"><%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %></span>
                                </div>
                                
                                <% if (orden.getIDVehiculo() != null) { %>
                                    <div class="vehicle-info">
                                        <div class="detail-row">
                                            <span class="detail-label">Vehículo:</span>
                                            <span class="detail-value">
                                                <strong><%= orden.getIDVehiculo().getPlaca() %></strong><br>
                                                <%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </span>
                                        </div>
                                        <div class="detail-row">
                                            <span class="detail-label">Color:</span>
                                            <span class="detail-value"><%= orden.getIDVehiculo().getColor() != null ? orden.getIDVehiculo().getColor() : "N/A" %></span>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <% if (orden.getObservaciones() != null && !orden.getObservaciones().trim().isEmpty()) { %>
                                    <div class="detail-row">
                                        <span class="detail-label">Observaciones:</span>
                                        <span class="detail-value" style="font-style: italic;">
                                            <%= orden.getObservaciones().length() > 100 ? 
                                                orden.getObservaciones().substring(0, 100) + "..." : orden.getObservaciones() %>
                                        </span>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="task-actions">
                                <a href="${pageContext.request.contextPath}/mecanico/tareas/ver?id=<%= orden.getIDOrdenServicio() %>" 
                                   class="btn btn-primary btn-sm">👁️ Ver Detalles</a>
                                
                                <% if (!estaCompletada) { %>
                                    <form action="${pageContext.request.contextPath}/mecanico/tareas/actualizar-progreso" method="post" style="display: inline;">
                                        <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                                        <button type="submit" class="btn btn-info btn-sm">📝 Actualizar Progreso</button>
                                    </form>
                                    
                                    <form action="${pageContext.request.contextPath}/mecanico/tareas/completar" method="post" style="display: inline;">
                                        <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                                        <button type="submit" class="btn btn-success btn-sm"
                                                onclick="return confirm('¿Marcar esta tarea como completada?')">✅ Completar</button>
                                    </form>
                                <% } else { %>
                                    <span class="btn btn-secondary btn-sm" disabled>✅ Completada</span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Servicios Activos Disponibles -->
            <% if (serviciosActivos != null && !serviciosActivos.isEmpty()) { %>
                <div class="services-section">
                    <div class="section-header">
                        <h2>🛠️ Servicios Activos</h2>
                        <p>Servicios disponibles que puedes realizar</p>
                    </div>
                    
                    <div class="service-grid">
                        <% for (Servicio servicio : serviciosActivos) { %>
                            <div class="service-card">
                                <h4><%= servicio.getNombreServicio() %></h4>
                                <p class="service-description">
                                    <%= servicio.getDescripcion() != null && servicio.getDescripcion().length() > 100 ? 
                                        servicio.getDescripcion().substring(0, 100) + "..." : 
                                        (servicio.getDescripcion() != null ? servicio.getDescripcion() : "Sin descripción") %>
                                </p>
                                <p class="service-price">
                                    $<%= servicio.getPrecioBase() != null ? servicio.getPrecioBase() : "0.00" %>
                                </p>
                                <p class="service-duration">
                                    ⏱️ <%= servicio.getDuracionEstimada() != null ? servicio.getDuracionEstimada() + " min" : "Duración no especificada" %>
                                </p>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>