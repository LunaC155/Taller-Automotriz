<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> quejas = (List<OrdenServicio>) request.getAttribute("quejas");
    String tipo = (String) request.getAttribute("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Quejas - Atención al Cliente</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
   
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <<%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>⚠️ Gestión de Quejas y Reclamos</h1>
                <p>Atiende y da seguimiento a las quejas y reclamos de los clientes</p>
            </div>

            <!-- Estadísticas Rápidas -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon">⚠️</div>
                    <div class="stat-info">
                        <h3><%= quejas != null ? quejas.size() : 0 %></h3>
                        <p>Quejas Totales</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">🔴</div>
                    <div class="stat-info">
                        <h3><%= quejas != null ? quejas.stream().filter(q -> 
                            q.getProblemaReportado() != null && 
                            (q.getProblemaReportado().toLowerCase().contains("urgente") || 
                             q.getProblemaReportado().toLowerCase().contains("grave"))).count() : 0 %></h3>
                        <p>Quejas Urgentes</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-info">
                        <h3><%= quejas != null ? quejas.stream().filter(q -> q.getFechaRealSalida() != null).count() : 0 %></h3>
                        <p>Quejas Resueltas</p>
                    </div>
                </div>
            </div>

            <!-- Filtros y Búsqueda -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion" class="btn btn-secondary">
                        <span class="btn-icon">↩️</span> Volver al Dashboard
                    </a>
                    <div class="filter-buttons">
                        <button class="btn btn-outline-danger btn-sm" onclick="filtrarQuejas('alta')">🔴 Alta Prioridad</button>
                        <button class="btn btn-outline-warning btn-sm" onclick="filtrarQuejas('media')">🟡 Media Prioridad</button>
                        <button class="btn btn-outline-info btn-sm" onclick="filtrarQuejas('baja')">🔵 Baja Prioridad</button>
                        <button class="btn btn-outline-secondary btn-sm" onclick="filtrarQuejas('todas')">Todas</button>
                    </div>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/recepcionista/atencion/buscar" method="get" class="search-form">
                        <input type="hidden" name="tipo" value="consulta">
                        <input type="hidden" name="criterio" value="general">
                        <input type="text" name="valor" placeholder="Buscar en quejas..." class="form-control">
                        <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Tabla de Quejas -->
            <div class="table-container">
                <% if (quejas == null || quejas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">⚠️</div>
                        <h3>No hay quejas registradas</h3>
                        <p>No se han encontrado quejas o reclamos de clientes en el sistema.</p>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID Orden</th>
                                <th>Cliente</th>
                                <th>Vehículo</th>
                                <th>Queja/Reclamo</th>
                                <th>Fecha</th>
                                <th>Prioridad</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio queja : quejas) { 
                                String prioridad = determinarPrioridad(queja);
                                String prioridadClase = "priority-" + prioridad;
                            %>
                                <tr class="<%= prioridadClase %>">
                                    <td>#<%= queja.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (queja.getIDVehiculo() != null && queja.getIDVehiculo().getIDCliente() != null) { %>
                                            <strong><%= queja.getIDVehiculo().getIDCliente().getNombre() %> <%= queja.getIDVehiculo().getIDCliente().getApellido() %></strong><br>
                                            <small><%= queja.getIDVehiculo().getIDCliente().getTelefono() %></small><br>
                                            <small><%= queja.getIDVehiculo().getIDCliente().getEmail() %></small>
                                        <% } else { %>
                                            Cliente no disponible
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (queja.getIDVehiculo() != null) { %>
                                            <strong><%= queja.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= queja.getIDVehiculo().getIDMarca() != null ? queja.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= queja.getIDVehiculo().getIDModelo() != null ? queja.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            Vehículo no disponible
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="complaint-preview">
                                            <strong>Problema Reportado:</strong><br>
                                            <%= queja.getProblemaReportado() != null ? 
                                                (queja.getProblemaReportado().length() > 100 ? 
                                                 queja.getProblemaReportado().substring(0, 100) + "..." : 
                                                 queja.getProblemaReportado()) : "Sin descripción" %>
                                            
                                            <div class="complaint-tags">
                                                <%= generarEtiquetas(queja.getProblemaReportado()) %>
                                            </div>
                                            
                                            <% if (queja.getObservaciones() != null) { %>
                                                <br><strong>Observaciones:</strong><br>
                                                <small><%= queja.getObservaciones().length() > 60 ? 
                                                         queja.getObservaciones().substring(0, 60) + "..." : 
                                                         queja.getObservaciones() %></small>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td><%= queja.getFechaEntrada() != null ? queja.getFechaEntrada() : "N/A" %></td>
                                    <td>
                                        <% 
                                            String prioridadTexto = "Media";
                                            String prioridadBadge = "badge-warning";
                                            if ("alta".equals(prioridad)) {
                                                prioridadTexto = "Alta";
                                                prioridadBadge = "badge-danger";
                                            } else if ("baja".equals(prioridad)) {
                                                prioridadTexto = "Baja";
                                                prioridadBadge = "badge-info";
                                            }
                                        %>
                                        <span class="badge <%= prioridadBadge %>"><%= prioridadTexto %></span>
                                    </td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "Pendiente";
                                            
                                            if (queja.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "Resuelta";
                                            } else if (queja.getIDEstadoTrabajo() != null) {
                                                estadoTexto = queja.getIDEstadoTrabajo().getNombreEstado();
                                                if ("EN PROCESO".equals(estadoTexto)) {
                                                    estadoClase = "badge-info";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-danger";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= queja.getIDVehiculo() != null && queja.getIDVehiculo().getIDCliente() != null ? queja.getIDVehiculo().getIDCliente().getIDCliente() : "" %>" 
                                               class="btn btn-sm btn-info" title="Ver historial del cliente">
                                                📊 Historial
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/detalle?id=<%= queja.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-primary" title="Ver detalles de la orden">
                                                👁️ Detalles
                                            </a>
                                            
                                            <% if (queja.getFechaRealSalida() == null) { %>
                                                <button class="btn btn-sm btn-success" 
                                                        title="Marcar como resuelta"
                                                        onclick="marcarComoResuelta(<%= queja.getIDOrdenServicio() %>)">
                                                    ✅ Resolver
                                                </button>
                                                
                                                <button class="btn btn-sm btn-warning" 
                                                        title="Contactar al cliente"
                                                        onclick="contactarCliente(<%= queja.getIDOrdenServicio() %>)">
                                                    📞 Contactar
                                                </button>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de quejas: <strong><%= quejas.size() %></strong></p>
                        <p>
                            <span class="badge badge-danger">Alta: <%= quejas.stream().filter(q -> "alta".equals(determinarPrioridad(q))).count() %></span>
                            <span class="badge badge-warning">Media: <%= quejas.stream().filter(q -> "media".equals(determinarPrioridad(q))).count() %></span>
                            <span class="badge badge-info">Baja: <%= quejas.stream().filter(q -> "baja".equals(determinarPrioridad(q))).count() %></span>
                        </p>
                        <p>
                            <span class="badge badge-warning">Pendientes: <%= quejas.stream().filter(q -> q.getFechaRealSalida() == null).count() %></span>
                            <span class="badge badge-success">Resueltas: <%= quejas.stream().filter(q -> q.getFechaRealSalida() != null).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function marcarComoResuelta(idOrden) {
            if (confirm('¿Está seguro de marcar esta queja como resuelta?')) {
                window.location.href = '${pageContext.request.contextPath}/recepcionista/atencion/resolver-queja?id=' + idOrden;
            }
        }
        
        function contactarCliente(idOrden) {
            // Aquí podrías abrir un modal o redirigir a una página de contacto
            alert('Funcionalidad de contacto para la queja #' + idOrden);
        }
        
        function filtrarQuejas(prioridad) {
            const filas = document.querySelectorAll('.crud-table tbody tr');
            filas.forEach(fila => {
                if (prioridad === 'todas') {
                    fila.style.display = '';
                } else {
                    const tienePrioridad = fila.className.includes('priority-' + prioridad);
                    fila.style.display = tienePrioridad ? '' : 'none';
                }
            });
        }
    </script>
</body>
</html>

<%!
    // Método helper para determinar prioridad
    private String determinarPrioridad(OrdenServicio queja) {
        if (queja.getProblemaReportado() == null) return "media";
        
        String problema = queja.getProblemaReportado().toLowerCase();
        
        if (problema.contains("urgente") || problema.contains("grave") || 
            problema.contains("inmediato") || problema.contains("emergencia")) {
            return "alta";
        } else if (problema.contains("leve") || problema.contains("menor") || 
                  problema.contains("sugerencia")) {
            return "baja";
        }
        
        return "media";
    }
    
    // Método helper para generar etiquetas
    private String generarEtiquetas(String problema) {
        if (problema == null) return "";
        
        String html = "";
        String problemaLower = problema.toLowerCase();
        
        if (problemaLower.contains("queja")) html += "<span class='tag tag-queja'>Queja</span>";
        if (problemaLower.contains("reclamo")) html += "<span class='tag tag-reclamo'>Reclamo</span>";
        if (problemaLower.contains("problema")) html += "<span class='tag tag-problema'>Problema</span>";
        if (problemaLower.contains("insatisfecho")) html += "<span class='tag tag-insatisfecho'>Insatisfecho</span>";
        if (problemaLower.contains("mal servicio")) html += "<span class='tag tag-queja'>Mal Servicio</span>";
        if (problemaLower.contains("error")) html += "<span class='tag tag-problema'>Error</span>";
        
        return html;
    }
%>