<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    Integer idEmpleado = (Integer) session.getAttribute("idEmpleado");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole) || idEmpleado == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Diagnostico> diagnosticos = (List<Diagnostico>) request.getAttribute("diagnosticos");
    Integer diagnosticosPendientes = (Integer) request.getAttribute("diagnosticosPendientes");
    Long totalDiagnosticos = (Long) request.getAttribute("totalDiagnosticos");
    List<Diagnostico> diagnosticosRecientes = (List<Diagnostico>) request.getAttribute("diagnosticosRecientes");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Diagnósticos - Taller Automotriz</title>
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
                <h1>👤 Mis Diagnósticos</h1>
                <p>Gestiona tus diagnósticos técnicos realizados en el taller</p>
            </div>

            <!-- Estadísticas del Dashboard -->
            <div class="dashboard-stats">
                <div class="stat-card primary">
                    <div class="stat-icon">📊</div>
                    <div class="stat-number"><%= totalDiagnosticos != null ? totalDiagnosticos : 0 %></div>
                    <div class="stat-description">Total de Diagnósticos</div>
                </div>
                
                <div class="stat-card warning">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-number"><%= diagnosticosPendientes != null ? diagnosticosPendientes : 0 %></div>
                    <div class="stat-description">Diagnósticos Pendientes</div>
                </div>
                
                <div class="stat-card success">
                    <div class="stat-icon">✅</div>
                    <div class="stat-number"><%= totalDiagnosticos != null && diagnosticosPendientes != null ? 
                                              totalDiagnosticos - diagnosticosPendientes : 0 %></div>
                    <div class="stat-description">Diagnósticos Completados</div>
                </div>
                
                <div class="stat-card danger">
                    <div class="stat-icon">🚗</div>
                    <div class="stat-number">
                        <%= diagnosticos != null ? 
                            diagnosticos.stream()
                                .filter(d -> d.getIDOrdenServicio() != null)
                                .map(d -> d.getIDOrdenServicio().getIDOrdenServicio())
                                .distinct()
                                .count() : 0 %>
                    </div>
                    <div class="stat-description">Órdenes Atendidas</div>
                </div>
            </div>

            <!-- Acciones Rápidas -->
            <div class="quick-actions">
                <div class="quick-action-card" onclick="location.href='${pageContext.request.contextPath}/mecanico/diagnosticos/crear'">
                    <div class="action-icon">➕</div>
                    <div class="action-title">Nuevo Diagnóstico</div>
                    <div class="action-description">Crear un nuevo diagnóstico técnico</div>
                </div>
                
                <div class="quick-action-card" onclick="location.href='${pageContext.request.contextPath}/mecanico/diagnosticos'">
                    <div class="action-icon">📋</div>
                    <div class="action-title">Todos los Diagnósticos</div>
                    <div class="action-description">Ver diagnósticos de todo el taller</div>
                </div>
                
                <div class="quick-action-card" onclick="location.href='${pageContext.request.contextPath}/mecanico/ordenes'">
                    <div class="action-icon">🔧</div>
                    <div class="action-title">Órdenes de Servicio</div>
                    <div class="action-description">Gestionar órdenes asignadas</div>
                </div>
                
                <div class="quick-action-card" onclick="location.href='${pageContext.request.contextPath}/mecanico/reportes'">
                    <div class="action-icon">📈</div>
                    <div class="action-title">Reportes</div>
                    <div class="action-description">Ver reportes y estadísticas</div>
                </div>
            </div>

            <!-- Diagnósticos Recientes -->
            <% if (diagnosticosRecientes != null && !diagnosticosRecientes.isEmpty()) { %>
                <div class="recent-section">
                    <h3>🕒 Diagnósticos Recientes</h3>
                    <div class="recent-grid">
                        <% for (Diagnostico diagnostico : diagnosticosRecientes) { %>
                            <div class="recent-item" onclick="location.href='${pageContext.request.contextPath}/mecanico/diagnosticos/ver?id=<%= diagnostico.getIDDiagnostico() %>'">
                                <div class="recent-header">
                                    <div class="recent-title">Diagnóstico #<%= diagnostico.getIDDiagnostico() %></div>
                                    <span class="diagnostic-status <%= diagnostico.getFechaDiagnostico() != null ? "status-completed" : "status-pending" %>">
                                        <%= diagnostico.getFechaDiagnostico() != null ? "Completado" : "Pendiente" %>
                                    </span>
                                </div>
                                <div class="recent-description">
                                    <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                        (diagnostico.getDescripcionDiagnostico().length() > 100 ? 
                                         diagnostico.getDescripcionDiagnostico().substring(0, 100) + "..." : 
                                         diagnostico.getDescripcionDiagnostico()) : "Sin descripción" %>
                                </div>
                                <div class="recent-vehicle">
                                    <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDVehiculo() != null) { %>
                                        🚗 <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getPlaca() %>
                                    <% } else { %>
                                        🚗 Vehículo no especificado
                                    <% } %>
                                </div>
                                <div class="recent-date">
                                    <%= diagnostico.getFechaDiagnostico() != null ? 
                                        new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(diagnostico.getFechaDiagnostico()) : 
                                        "Sin fecha" %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/crear" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Nuevo Diagnóstico
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-info">
                        <span class="btn-icon">📋</span> Todos los Diagnósticos
                    </a>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/mecanico/diagnosticos/buscar" method="get" class="search-form">
                        <input type="hidden" name="criterio" value="descripcion">
                        <input type="text" name="valor" placeholder="Buscar en mis diagnósticos..." class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Tabla de mis diagnósticos -->
            <div class="table-container">
                <% if (diagnosticos == null || diagnosticos.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔍</div>
                        <h3>No hay diagnósticos registrados</h3>
                        <p>Aún no has realizado ningún diagnóstico técnico.</p>
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/crear" class="btn btn-primary">
                            Crear Primer Diagnóstico
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Orden</th>
                                <th>Vehículo</th>
                                <th>Descripción</th>
                                <th>Fecha</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Diagnostico diagnostico : diagnosticos) { %>
                                <tr>
                                    <td>#<%= diagnostico.getIDDiagnostico() %></td>
                                    <td>
                                        <strong>#<%= diagnostico.getIDOrdenServicio() != null ? diagnostico.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></strong>
                                        <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDEstadoTrabajo() != null) { %>
                                            <br><small class="badge badge-info"><%= diagnostico.getIDOrdenServicio().getIDEstadoTrabajo().getNombreEstado() %></small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDVehiculo() != null) { %>
                                            <strong><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null ? 
                                                    diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null ? 
                                                    diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                            (diagnostico.getDescripcionDiagnostico().length() > 80 ? 
                                             diagnostico.getDescripcionDiagnostico().substring(0, 80) + "..." : 
                                             diagnostico.getDescripcionDiagnostico()) : "Sin descripción" %>
                                        <% if (diagnostico.getRecomendaciones() != null && !diagnostico.getRecomendaciones().isEmpty()) { %>
                                            <br><small class="text-success">💡 Con recomendaciones</small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= diagnostico.getFechaDiagnostico() != null ? 
                                            new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(diagnostico.getFechaDiagnostico()) : 
                                            "<span class='text-warning'>Pendiente</span>" %>
                                    </td>
                                    <td>
                                        <span class="diagnostic-status <%= diagnostico.getFechaDiagnostico() != null ? "status-completed" : "status-pending" %>">
                                            <%= diagnostico.getFechaDiagnostico() != null ? "Completado" : "Pendiente" %>
                                        </span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/ver?id=<%= diagnostico.getIDDiagnostico() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/editar?id=<%= diagnostico.getIDDiagnostico() %>" 
                                               class="btn btn-sm btn-warning" title="Editar diagnóstico">
                                                ✏️ Editar
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/por-orden?idOrden=<%= diagnostico.getIDOrdenServicio() != null ? diagnostico.getIDOrdenServicio().getIDOrdenServicio() : "" %>" 
                                               class="btn btn-sm btn-secondary" title="Ver por orden">
                                                📋 Orden
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de mis diagnósticos: <strong><%= diagnosticos.size() %></strong></p>
                        <p>
                            <span class="badge badge-success">Completados: <%= diagnosticos.stream().filter(d -> d.getFechaDiagnostico() != null).count() %></span>
                            <span class="badge badge-warning">Pendientes: <%= diagnosticos.stream().filter(d -> d.getFechaDiagnostico() == null).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>