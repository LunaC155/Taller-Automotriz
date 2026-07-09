<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> consultas = (List<OrdenServicio>) request.getAttribute("consultas");
    String tipo = (String) request.getAttribute("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Consultas - Atención al Cliente</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>📋 Gestión de Consultas</h1>
                <p>Consulta y gestiona todas las consultas realizadas por los clientes</p>
            </div>

            <!-- Estadísticas Rápidas -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon">📝</div>
                    <div class="stat-info">
                        <h3><%= consultas != null ? consultas.size() : 0 %></h3>
                        <p>Consultas Totales</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-info">
                        <h3><%= consultas != null ? consultas.stream().filter(c -> c.getFechaRealSalida() == null).count() : 0 %></h3>
                        <p>Pendientes de Respuesta</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-info">
                        <h3><%= consultas != null ? consultas.stream().filter(c -> c.getFechaRealSalida() != null).count() : 0 %></h3>
                        <p>Consultas Atendidas</p>
                    </div>
                </div>
            </div>

            <!-- Filtros y Búsqueda -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion" class="btn btn-secondary">
                        <span class="btn-icon">↩️</span> Volver al Dashboard
                    </a>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/recepcionista/atencion/buscar" method="get" class="search-form">
                        <input type="hidden" name="tipo" value="consulta">
                        <input type="hidden" name="criterio" value="general">
                        <input type="text" name="valor" placeholder="Buscar en consultas..." class="form-control">
                        <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Tabla de Consultas -->
            <div class="table-container">
                <% if (consultas == null || consultas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📝</div>
                        <h3>No hay consultas registradas</h3>
                        <p>No se han encontrado consultas de clientes en el sistema.</p>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID Orden</th>
                                <th>Cliente</th>
                                <th>Vehículo</th>
                                <th>Consulta</th>
                                <th>Fecha Consulta</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio consulta : consultas) { %>
                                <tr>
                                    <td>#<%= consulta.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (consulta.getIDVehiculo() != null && consulta.getIDVehiculo().getIDCliente() != null) { %>
                                            <strong><%= consulta.getIDVehiculo().getIDCliente().getNombre() %> <%= consulta.getIDVehiculo().getIDCliente().getApellido() %></strong><br>
                                            <small><%= consulta.getIDVehiculo().getIDCliente().getTelefono() %></small>
                                        <% } else { %>
                                            Cliente no disponible
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (consulta.getIDVehiculo() != null) { %>
                                            <strong><%= consulta.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= consulta.getIDVehiculo().getIDMarca() != null ? consulta.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= consulta.getIDVehiculo().getIDModelo() != null ? consulta.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            Vehículo no disponible
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="consultation-preview">
                                            <strong>Observaciones:</strong><br>
                                            <%= consulta.getObservaciones() != null ? 
                                                (consulta.getObservaciones().length() > 80 ? 
                                                 consulta.getObservaciones().substring(0, 80) + "..." : 
                                                 consulta.getObservaciones()) : "Sin observaciones" %>
                                            <% if (consulta.getProblemaReportado() != null) { %>
                                                <br><strong>Problema:</strong><br>
                                                <%= consulta.getProblemaReportado().length() > 60 ? 
                                                     consulta.getProblemaReportado().substring(0, 60) + "..." : 
                                                     consulta.getProblemaReportado() %>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td><%= consulta.getFechaEntrada() != null ? consulta.getFechaEntrada() : "N/A" %></td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "Pendiente";
                                            
                                            if (consulta.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "Atendida";
                                            } else if (consulta.getIDEstadoTrabajo() != null) {
                                                estadoTexto = consulta.getIDEstadoTrabajo().getNombreEstado();
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
                                            <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= consulta.getIDVehiculo() != null && consulta.getIDVehiculo().getIDCliente() != null ? consulta.getIDVehiculo().getIDCliente().getIDCliente() : "" %>" 
                                               class="btn btn-sm btn-info" title="Ver historial del cliente">
                                                📊 Historial
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/detalle?id=<%= consulta.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-primary" title="Ver detalles de la orden">
                                                👁️ Detalles
                                            </a>
                                            
                                            <% if (consulta.getFechaRealSalida() == null) { %>
                                                <button class="btn btn-sm btn-success" 
                                                        title="Marcar como atendida"
                                                        onclick="marcarComoAtendida(<%= consulta.getIDOrdenServicio() %>)">
                                                    ✅ Atender
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
                        <p>Total de consultas: <strong><%= consultas.size() %></strong></p>
                        <p>
                            <span class="badge badge-warning">Pendientes: <%= consultas.stream().filter(c -> c.getFechaRealSalida() == null).count() %></span>
                            <span class="badge badge-success">Atendidas: <%= consultas.stream().filter(c -> c.getFechaRealSalida() != null).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function marcarComoAtendida(idOrden) {
            if (confirm('¿Está seguro de marcar esta consulta como atendida?')) {
                // Aquí puedes implementar la lógica para marcar como atendida
                // Por ejemplo, redirigir a un servlet que actualice el estado
                window.location.href = '${pageContext.request.contextPath}/recepcionista/atencion/atender-consulta?id=' + idOrden;
            }
        }
        
        // Filtro rápido por estado
        function filtrarConsultas(estado) {
            const filas = document.querySelectorAll('.crud-table tbody tr');
            filas.forEach(fila => {
                const estadoBadge = fila.querySelector('.badge').textContent.toLowerCase();
                if (estado === 'todos' || estadoBadge.includes(estado)) {
                    fila.style.display = '';
                } else {
                    fila.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>