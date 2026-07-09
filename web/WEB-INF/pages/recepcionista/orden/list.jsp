<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Órdenes - Recepcionista</title>
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
                <h1>🔧 Gestión de Órdenes de Servicio</h1>
                <p>Administra todas las órdenes de servicio del taller</p>
            </div>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes/crear" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Nueva Orden
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes/buscar" class="btn btn-info">
                        <span class="btn-icon">🔍</span> Buscar Órdenes
                    </a>
                </div>
                <div class="actions-right">
                    <div class="stats-badges">
                        <span class="badge badge-primary">Total: <%= ordenes != null ? ordenes.size() : 0 %></span>
                        <span class="badge badge-warning">Pendientes: <%= ordenes != null ? ordenes.stream().filter(o -> o.getFechaRealSalida() == null).count() : 0 %></span>
                        <span class="badge badge-success">Completadas: <%= ordenes != null ? ordenes.stream().filter(o -> o.getFechaRealSalida() != null).count() : 0 %></span>
                    </div>
                </div>
            </div>

            <!-- Resultados de búsqueda -->
            <% if (criterio != null && valor != null) { %>
                <div class="search-results-info">
                    <p>Resultados de búsqueda para: <strong>"<%= valor %>"</strong></p>
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-sm btn-secondary">
                        ↩️ Ver todas las órdenes
                    </a>
                </div>
            <% } %>

            <!-- Tabla de órdenes -->
            <div class="table-container">
                <% if (ordenes == null || ordenes.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔧</div>
                        <h3>No hay órdenes registradas</h3>
                        <p>No se encontraron órdenes de servicio en el sistema.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes/crear" class="btn btn-primary">
                            Crear Primera Orden
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Vehículo</th>
                                <th>Cliente</th>
                                <th>Problema</th>
                                <th>Fecha Entrada</th>
                                <th>Fecha Est. Salida</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio orden : ordenes) { %>
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
                                            <span class="badge badge-warning">Por asignar</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null) { %>
                                            <%= orden.getIDVehiculo().getIDCliente().getNombre() %> 
                                            <%= orden.getIDVehiculo().getIDCliente().getApellido() %>
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
                                    <td>
                                        <%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %>
                                        <% if (orden.getFechaEstimadaSalida() != null && orden.getFechaEstimadaSalida().before(new java.util.Date()) && orden.getFechaRealSalida() == null) { %>
                                            <br><span class="badge badge-danger">Atrasada</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "PENDIENTE";
                                            
                                            if (orden.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "COMPLETADA";
                                            } else if (orden.getIDEstadoTrabajo() != null) {
                                                estadoTexto = orden.getIDEstadoTrabajo().getNombreEstado();
                                                if ("EN PROCESO".equals(estadoTexto)) {
                                                    estadoClase = "badge-info";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-danger";
                                                } else if ("CITA PROGRAMADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-primary";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/editar?id=<%= orden.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-warning" title="Editar orden">
                                                ✏️ Editar
                                            </a>
                                            
                                            <% if (orden.getIDVehiculo() == null) { %>
                                                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/asignar-vehiculo?id=<%= orden.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-primary" title="Asignar vehículo">
                                                    🚗 Asignar
                                                </a>
                                            <% } %>
                                            
                                            <% if (orden.getFechaRealSalida() != null) { %>
                                                <a href="${pageContext.request.contextPath}/recepcionista/facturas/crear?orden=<%= orden.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-success" title="Generar factura">
                                                    🧾 Factura
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de órdenes: <strong><%= ordenes.size() %></strong></p>
                        <div class="status-summary">
                            <span class="badge badge-primary">Cita Programada: <%= ordenes.stream().filter(o -> o.getIDEstadoTrabajo() != null && "CITA PROGRAMADA".equals(o.getIDEstadoTrabajo().getNombreEstado())).count() %></span>
                            <span class="badge badge-warning">Pendientes: <%= ordenes.stream().filter(o -> o.getFechaRealSalida() == null && (o.getIDEstadoTrabajo() == null || "PENDIENTE".equals(o.getIDEstadoTrabajo().getNombreEstado()))).count() %></span>
                            <span class="badge badge-info">En Proceso: <%= ordenes.stream().filter(o -> o.getIDEstadoTrabajo() != null && "EN PROCESO".equals(o.getIDEstadoTrabajo().getNombreEstado())).count() %></span>
                            <span class="badge badge-success">Completadas: <%= ordenes.stream().filter(o -> o.getFechaRealSalida() != null).count() %></span>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>