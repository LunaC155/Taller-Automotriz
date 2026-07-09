<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico, com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Diagnostico> diagnosticos = (List<Diagnostico>) request.getAttribute("diagnosticos");
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    String tipoVista = (String) request.getAttribute("tipoVista");
    Integer totalDiagnosticos = (Integer) request.getAttribute("totalDiagnosticos");
    Integer diagnosticosPendientes = (Integer) request.getAttribute("diagnosticosPendientes");
    
    String tipoFiltro = (String) request.getAttribute("tipoFiltro");
    String valorFiltro = (String) request.getAttribute("valorFiltro");
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes Técnicos - Taller Automotriz</title>
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
                <h1>📊 Reportes Técnicos</h1>
                <p>Gestiona y consulta todos tus reportes técnicos generados</p>
            </div>

            <!-- Tarjetas de Estadísticas -->
            <div class="stats-cards">
                <div class="stat-card total">
                    <div class="stat-icon">📄</div>
                    <div class="stat-number"><%= totalDiagnosticos != null ? totalDiagnosticos : 0 %></div>
                    <div class="stat-label">Total Reportes</div>
                </div>
                <div class="stat-card pendientes">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-number"><%= diagnosticosPendientes != null ? diagnosticosPendientes : 0 %></div>
                    <div class="stat-label">Diagnósticos Pendientes</div>
                </div>
                <div class="stat-card ordenes">
                    <div class="stat-icon">🔧</div>
                    <div class="stat-number"><%= ordenes != null ? ordenes.size() : 0 %></div>
                    <div class="stat-label">Órdenes Asignadas</div>
                </div>
            </div>

            <!-- Navegación entre vistas -->
            <div class="view-switcher">
                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/mis-reportes" 
                   class="view-btn <%= "mis-reportes".equals(tipoVista) ? "active" : "" %>">
                   👤 Mis Reportes
                </a>
                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico" 
                   class="view-btn <%= "todos".equals(tipoVista) ? "active" : "" %>">
                   👥 Todos los Reportes
                </a>
                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/generar" 
                   class="view-btn">
                   ➕ Nuevo Reporte
                </a>
                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/estadisticas" 
                   class="view-btn">
                   📈 Estadísticas
                </a>
            </div>

            <!-- Filtros -->
            <div class="filter-section">
                <h3>🔍 Filtrar Reportes</h3>
                <form action="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/filtrar" method="get" class="filter-form">
                    <input type="hidden" name="vista" value="<%= tipoVista %>">
                    
                    <div class="form-group">
                        <label for="tipoFiltro">Tipo de Filtro</label>
                        <select id="tipoFiltro" name="tipoFiltro" class="form-control">
                            <option value="">Seleccionar filtro...</option>
                            <option value="orden" <%= "orden".equals(tipoFiltro) ? "selected" : "" %>>Número de Orden</option>
                            <option value="descripcion" <%= "descripcion".equals(tipoFiltro) ? "selected" : "" %>>Descripción</option>
                            <option value="recomendaciones" <%= "recomendaciones".equals(tipoFiltro) ? "selected" : "" %>>Recomendaciones</option>
                            <option value="fecha" <%= "fecha".equals(tipoFiltro) ? "selected" : "" %>>Fecha específica</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="valorFiltro">Valor a Buscar</label>
                        <input type="text" id="valorFiltro" name="valorFiltro" 
                               value="<%= valorFiltro != null ? valorFiltro : "" %>" 
                               class="form-control" placeholder="Ingrese el valor a buscar...">
                    </div>
                    
                    <div class="form-group">
                        <label for="fechaInicio">Fecha Inicio</label>
                        <input type="date" id="fechaInicio" name="fechaInicio" 
                               value="<%= fechaInicio != null ? fechaInicio : "" %>" 
                               class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label for="fechaFin">Fecha Fin</label>
                        <input type="date" id="fechaFin" name="fechaFin" 
                               value="<%= fechaFin != null ? fechaFin : "" %>" 
                               class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">🔍 Aplicar Filtros</button>
                        <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/<%= "mis-reportes".equals(tipoVista) ? "mis-reportes" : "" %>" 
                           class="btn btn-secondary">🔄 Limpiar</a>
                    </div>
                </form>
            </div>

            <!-- Lista de Reportes -->
            <div class="table-container">
                <% if (diagnosticos == null || diagnosticos.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📄</div>
                        <h3>No hay reportes técnicos</h3>
                        <p><%= "mis-reportes".equals(tipoVista) ? 
                              "No has generado ningún reporte técnico aún." : 
                              "No se encontraron reportes técnicos." %></p>
                        <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/generar" class="btn btn-primary">
                            ➕ Generar Primer Reporte
                        </a>
                    </div>
                <% } else { %>
                    <!-- Información del filtro aplicado -->
                    <% if (tipoFiltro != null || fechaInicio != null) { %>
                        <div class="alert alert-info">
                            <strong>Filtros aplicados:</strong>
                            <% if (tipoFiltro != null && valorFiltro != null) { %>
                                <%= tipoFiltro %>: "<%= valorFiltro %>"
                            <% } %>
                            <% if (fechaInicio != null && fechaFin != null) { %>
                                | Rango de fechas: <%= fechaInicio %> a <%= fechaFin %>
                            <% } %>
                            | <strong>Resultados: <%= diagnosticos.size() %></strong>
                        </div>
                    <% } %>

                    <!-- Lista de reportes en formato tarjetas -->
                    <% for (Diagnostico diagnostico : diagnosticos) { 
                        boolean esReciente = false;
                        if (diagnostico.getFechaDiagnostico() != null) {
                            long diff = System.currentTimeMillis() - diagnostico.getFechaDiagnostico().getTime();
                            esReciente = diff < 24 * 60 * 60 * 1000; // Menos de 24 horas
                        }
                    %>
                        <div class="diagnostico-card">
                            <div class="diagnostico-header">
                                <div>
                                    <h3 class="diagnostico-title">
                                        Reporte #<%= diagnostico.getIDDiagnostico() %>
                                        <% if (esReciente) { %>
                                            <span class="badge-new">NUEVO</span>
                                        <% } %>
                                    </h3>
                                    <div class="diagnostico-meta">
                                        <span>Orden: #<%= diagnostico.getIDOrdenServicio().getIDOrdenServicio() %></span>
                                        <span>Vehículo: <%= diagnostico.getIDOrdenServicio().getIDVehiculo() != null ? 
                                                diagnostico.getIDOrdenServicio().getIDVehiculo().getPlaca() : "N/A" %></span>
                                        <span>Fecha: <%= diagnostico.getFechaDiagnostico() != null ? 
                                                diagnostico.getFechaDiagnostico() : "Pendiente" %></span>
                                    </div>
                                </div>
                                <div>
                                    <% if (diagnostico.getIDEmpleadoMecanico() != null) { %>
                                        <small>Mecánico: <%= diagnostico.getIDEmpleadoMecanico().getNombre() %> 
                                               <%= diagnostico.getIDEmpleadoMecanico().getApellido() %></small>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="diagnostico-content">
                                <div class="diagnostico-descripcion">
                                    <strong>Diagnóstico:</strong><br>
                                    <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                        (diagnostico.getDescripcionDiagnostico().length() > 300 ? 
                                         diagnostico.getDescripcionDiagnostico().substring(0, 300) + "..." : 
                                         diagnostico.getDescripcionDiagnostico()) : "Sin diagnóstico" %>
                                </div>
                                
                                <% if (diagnostico.getRecomendaciones() != null && !diagnostico.getRecomendaciones().trim().isEmpty()) { %>
                                    <div class="diagnostico-recomendaciones">
                                        <strong>Recomendaciones:</strong><br>
                                        <%= diagnostico.getRecomendaciones().length() > 200 ? 
                                            diagnostico.getRecomendaciones().substring(0, 200) + "..." : 
                                            diagnostico.getRecomendaciones() %>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="diagnostico-actions">
                                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/detalle?id=<%= diagnostico.getIDDiagnostico() %>" 
                                   class="btn btn-sm btn-info">👁️ Ver Detalle</a>
                                   
                                <% if ("mis-reportes".equals(tipoVista)) { %>
                                    <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/generar?orden=<%= diagnostico.getIDOrdenServicio().getIDOrdenServicio() %>" 
                                       class="btn btn-sm btn-warning">✏️ Editar</a>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de reportes mostrados: <strong><%= diagnosticos.size() %></strong></p>
                        <% if ("mis-reportes".equals(tipoVista)) { %>
                            <p>Tienes <strong><%= diagnosticosPendientes != null ? diagnosticosPendientes : 0 %></strong> diagnósticos pendientes</p>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Mostrar/ocultar campos de filtro según el tipo seleccionado
        document.getElementById('tipoFiltro').addEventListener('change', function() {
            const valorFiltro = document.getElementById('valorFiltro');
            const fechaInicio = document.getElementById('fechaInicio');
            const fechaFin = document.getElementById('fechaFin');
            
            if (this.value === 'fecha') {
                valorFiltro.style.display = 'none';
                valorFiltro.previousElementSibling.style.display = 'none';
                fechaInicio.style.display = 'block';
                fechaInicio.previousElementSibling.style.display = 'block';
                fechaFin.style.display = 'block';
                fechaFin.previousElementSibling.style.display = 'block';
            } else {
                valorFiltro.style.display = 'block';
                valorFiltro.previousElementSibling.style.display = 'block';
                fechaInicio.style.display = 'none';
                fechaInicio.previousElementSibling.style.display = 'none';
                fechaFin.style.display = 'none';
                fechaFin.previousElementSibling.style.display = 'none';
            }
        });

        // Inicializar estado de los filtros
        window.addEventListener('load', function() {
            document.getElementById('tipoFiltro').dispatchEvent(new Event('change'));
        });
    </script>
</body>
</html>