<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico, java.util.List" %>
<%@page import="java.util.Arrays" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Diagnostico> diagnosticos = (List<Diagnostico>) request.getAttribute("diagnosticos");
    List<Object[]> estadisticas = (List<Object[]>) request.getAttribute("estadisticas");
    List<String> problemasComunes = (List<String>) request.getAttribute("problemasComunes");

    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Diagnósticos - Taller Automotriz</title>
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
                    <h1>🔍 Diagnósticos</h1>
                    <p>Gestiona todos los diagnósticos realizados en el taller</p>
                </div>

                <!-- Estadísticas -->
                <% if (estadisticas != null && !estadisticas.isEmpty()) {
                        Object[] stats = estadisticas.get(0);
                %>
                <div class="stats-grid">
                    <div class="stat-card">
                        <h3>Total Diagnósticos</h3>
                        <div class="stat-number"><%= stats[0] != null ? stats[0] : 0%></div>
                        <div class="stat-description">Registrados en el sistema</div>
                    </div>
                    <div class="stat-card">
                        <h3>Mecánicos Activos</h3>
                        <div class="stat-number"><%= stats[1] != null ? stats[1] : 0%></div>
                        <div class="stat-description">Realizando diagnósticos</div>
                    </div>
                    <div class="stat-card">
                        <h3>Órdenes con Diagnóstico</h3>
                        <div class="stat-number"><%= stats[2] != null ? stats[2] : 0%></div>
                        <div class="stat-description">Procesadas</div>
                    </div>
                    <div class="stat-card">
                        <h3>Long. Promedio</h3>
                        <div class="stat-number"><%= stats[3] != null ? String.format("%.0f", stats[3]) : 0%></div>
                        <div class="stat-description">Caracteres por diagnóstico</div>
                    </div>
                </div>
                <% } %>

                <!-- Problemas Comunes -->
                <% if (problemasComunes != null && !problemasComunes.isEmpty()) { %>
                <div class="problems-section">
                    <h3>🔧 Problemas Más Comunes</h3>
                    <div class="problems-grid">
                        <% for (int i = 0; i < Math.min(problemasComunes.size(), 6); i++) {
                                String problema = problemasComunes.get(i);
                                if (problema != null && !problema.trim().isEmpty()) {
                        %>
                        <div class="problem-item">
                            <span class="problem-icon">🔍</span>
                            <span><%= problema.length() > 60 ? problema.substring(0, 60) + "..." : problema%></span>
                        </div>
                        <% }
                } %>
                    </div>
                </div>
                <% } else { %>
                <div class="problems-section">
                    <h3>🔧 Información de Problemas</h3>
                    <p class="text-muted">No hay datos de problemas comunes disponibles en este momento.</p>
                </div>
                <% }%>

                <!-- Acciones principales -->
                <div class="crud-actions">
                    <div class="actions-left">
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/crear" class="btn btn-primary">
                            <span class="btn-icon">➕</span> Nuevo Diagnóstico
                        </a>
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/mis-diagnosticos" class="btn btn-info">
                            <span class="btn-icon">👤</span> Mis Diagnósticos
                        </a>
                    </div>
                    <div class="actions-right">
                        <form action="${pageContext.request.contextPath}/mecanico/diagnosticos/buscar" method="get" class="search-form">
                            <input type="text" name="valor" placeholder="Buscar diagnósticos..." 
                                   value="<%= valor != null ? valor : ""%>" class="form-control">
                            <select name="criterio" class="form-control">
                                <option value="descripcion" <%= "descripcion".equals(criterio) ? "selected" : ""%>>Descripción</option>
                                <option value="recomendaciones" <%= "recomendaciones".equals(criterio) ? "selected" : ""%>>Recomendaciones</option>
                                <option value="orden" <%= "orden".equals(criterio) ? "selected" : ""%>>N° Orden</option>
                            </select>
                            <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                        </form>
                    </div>
                </div>

                <!-- Búsqueda Avanzada -->
                <div class="search-advanced">
                    <h4>🔎 Búsqueda Avanzada</h4>
                    <form action="${pageContext.request.contextPath}/mecanico/diagnosticos/buscar" method="get" class="search-form-advanced">
                        <div class="form-group">
                            <label for="criterioAvanzado">Criterio de Búsqueda</label>
                            <select id="criterioAvanzado" name="criterio" class="form-control">
                                <option value="descripcion" <%= "descripcion".equals(criterio) ? "selected" : ""%>>Descripción del Diagnóstico</option>
                                <option value="recomendaciones" <%= "recomendaciones".equals(criterio) ? "selected" : ""%>>Recomendaciones</option>
                                <option value="orden" <%= "orden".equals(criterio) ? "selected" : ""%>>Número de Orden</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="valorBusqueda">Término de Búsqueda</label>
                            <input type="text" id="valorBusqueda" name="valor" 
                                   value="<%= valor != null ? valor : ""%>" 
                                   placeholder="Ingrese el término a buscar..." class="form-control">
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-secondary">🔄 Limpiar</a>
                        </div>
                    </form>
                </div>

                <!-- Tabla de diagnósticos -->
                <div class="table-container">
                    <% if (diagnosticos == null || diagnosticos.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔍</div>
                        <h3>No hay diagnósticos registrados</h3>
                        <p>No se encontraron diagnósticos que coincidan con tu búsqueda.</p>
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
                                <th>Mecánico</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Diagnostico diagnostico : diagnosticos) {%>
                            <tr>
                                <td>#<%= diagnostico.getIDDiagnostico()%></td>
                                <td>
                                    <strong>#<%= diagnostico.getIDOrdenServicio() != null ? diagnostico.getIDOrdenServicio().getIDOrdenServicio() : "N/A"%></strong>
                                    <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDEstadoTrabajo() != null) {%>
                                    <br><small class="badge badge-info"><%= diagnostico.getIDOrdenServicio().getIDEstadoTrabajo().getNombreEstado()%></small>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (diagnostico.getIDOrdenServicio() != null && diagnostico.getIDOrdenServicio().getIDVehiculo() != null) {%>
                                    <strong><%= diagnostico.getIDOrdenServicio().getIDVehiculo().getPlaca()%></strong><br>
                                    <small>
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null
                                                        ? diagnostico.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : ""%> 
                                        <%= diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null
                                                        ? diagnostico.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : ""%>
                                    </small>
                                    <% } else { %>
                                    N/A
                                    <% }%>
                                </td>
                                <td>
                                    <%= diagnostico.getDescripcionDiagnostico() != null
                                            ? (diagnostico.getDescripcionDiagnostico().length() > 80
                                            ? diagnostico.getDescripcionDiagnostico().substring(0, 80) + "..."
                                                : diagnostico.getDescripcionDiagnostico()) : "Sin descripción"%>
                                    <% if (diagnostico.getRecomendaciones() != null && !diagnostico.getRecomendaciones().isEmpty()) { %>
                                    <br><small class="text-muted">💡 Con recomendaciones</small>
                                    <% }%>
                                </td>
                                <td>
                                    <%= diagnostico.getFechaDiagnostico() != null
                                                ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(diagnostico.getFechaDiagnostico())
                                                : "Pendiente"%>
                                </td>
                                <td>
                                    <% if (diagnostico.getIDEmpleadoMecanico() != null) {%>
                                    <%= diagnostico.getIDEmpleadoMecanico().getNombre()%> 
                                    <%= diagnostico.getIDEmpleadoMecanico().getApellido()%>
                                    <% } else { %>
                                    <span class="text-muted">No asignado</span>
                                    <% }%>
                                </td>
                                <td class="actions-column">
                                    <div class="action-buttons">
                                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/ver?id=<%= diagnostico.getIDDiagnostico()%>" 
                                           class="btn btn-sm btn-info" title="Ver detalles">
                                            👁️ Ver
                                        </a>

                                        <% if (diagnostico.getIDEmpleadoMecanico() != null
                                                        && diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(session.getAttribute("idEmpleado"))) {%>
                                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/editar?id=<%= diagnostico.getIDDiagnostico()%>" 
                                           class="btn btn-sm btn-warning" title="Editar diagnóstico">
                                            ✏️ Editar
                                        </a>
                                        <% }%>

                                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/por-orden?idOrden=<%= diagnostico.getIDOrdenServicio() != null ? diagnostico.getIDOrdenServicio().getIDOrdenServicio() : ""%>" 
                                           class="btn btn-sm btn-secondary" title="Ver por orden">
                                            📋 Orden
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% }%>
                        </tbody>
                    </table>

                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de diagnósticos: <strong><%= diagnosticos.size()%></strong></p>
                        <% if (criterio != null && valor != null) {%>
                        <p>Filtrado por: <strong><%= criterio%></strong> = "<strong><%= valor%></strong>"</p>
                        <% } %>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>

        <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
    </body>
</html>