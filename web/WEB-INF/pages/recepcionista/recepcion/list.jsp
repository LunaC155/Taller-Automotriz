<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> recepciones = (List<OrdenServicio>) request.getAttribute("recepciones");
    String filtro = (String) request.getAttribute("filtro");
    Integer totalRecepciones = (Integer) request.getAttribute("totalRecepciones");
    Integer recepcionesPendientes = (Integer) request.getAttribute("recepcionesPendientes");
    Integer recepcionesHoy = (Integer) request.getAttribute("recepcionesHoy");
    
    if (recepciones == null) {
        recepciones = java.util.Collections.emptyList();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Recepciones - Taller Automotriz</title>
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
                <h1>📋 Gestión de Recepciones</h1>
                <p>Administra todas las recepciones de vehículos en el taller</p>
            </div>

            <!-- Estadísticas -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon total">📊</div>
                    <div class="stat-info">
                        <h3><%= totalRecepciones != null ? totalRecepciones : 0 %></h3>
                        <p>Total Recepciones</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-card">
                        <div class="stat-icon pending">⏳</div>
                        <div class="stat-info">
                            <h3><%= recepcionesPendientes != null ? recepcionesPendientes : 0 %></h3>
                            <p>Pendientes</p>
                        </div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon today">📅</div>
                    <div class="stat-info">
                        <h3><%= recepcionesHoy != null ? recepcionesHoy : 0 %></h3>
                        <p>Recepciones Hoy</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon completed">✅</div>
                    <div class="stat-info">
                        <h3><%= totalRecepciones != null && recepcionesPendientes != null ? totalRecepciones - recepcionesPendientes : 0 %></h3>
                        <p>Completadas</p>
                    </div>
                </div>
            </div>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/recepcion/registrar" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Nueva Recepción
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/recepcion/hoy" class="btn btn-info">
                        <span class="btn-icon">📅</span> Recepciones de Hoy
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/recepcion/pendientes" class="btn btn-warning">
                        <span class="btn-icon">⏳</span> Pendientes
                    </a>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/recepcionista/recepcion/buscar" method="get" class="search-form">
                        <select name="criterio" class="form-control" style="width: auto;">
                            <option value="placa">Placa</option>
                            <option value="problema">Problema</option>
                            <option value="cliente">Cliente</option>
                        </select>
                        <input type="text" name="valor" placeholder="Buscar..." class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Indicador de filtro activo -->
            <% if (filtro != null) { %>
                <div class="filter-indicator">
                    <strong>Filtro activo:</strong>
                    <% 
                        String filtroTexto = "";
                        switch(filtro) {
                            case "hoy": filtroTexto = "Recepciones de hoy"; break;
                            case "pendientes": filtroTexto = "Recepciones pendientes"; break;
                            default: filtroTexto = filtro;
                        }
                    %>
                    <span class="badge badge-info"><%= filtroTexto %></span>
                    <a href="${pageContext.request.contextPath}/recepcionista/recepcion" class="btn btn-sm btn-outline">❌ Quitar filtro</a>
                </div>
            <% } %>

            <!-- Tabla de recepciones -->
            <div class="table-container">
                <% if (recepciones.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📋</div>
                        <h3>No hay recepciones registradas</h3>
                        <p>No se encontraron recepciones con los criterios actuales.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/recepcion/registrar" class="btn btn-primary">
                            Registrar Primera Recepción
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Vehículo</th>
                                <th>Cliente</th>
                                <th>Problema Reportado</th>
                                <th>Fecha Entrada</th>
                                <th>Fecha Est. Salida</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                for (OrdenServicio recepcion : recepciones) { 
                            %>
                                <tr>
                                    <td>#<%= recepcion.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (recepcion.getIDVehiculo() != null) { %>
                                            <strong><%= recepcion.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= recepcion.getIDVehiculo().getIDMarca() != null ? recepcion.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= recepcion.getIDVehiculo().getIDModelo() != null ? recepcion.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (recepcion.getIDVehiculo() != null && recepcion.getIDVehiculo().getIDCliente() != null) { %>
                                            <%= recepcion.getIDVehiculo().getIDCliente().getNombre() %> 
                                            <%= recepcion.getIDVehiculo().getIDCliente().getApellido() %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= recepcion.getProblemaReportado() != null ? 
                                           (recepcion.getProblemaReportado().length() > 50 ? 
                                            recepcion.getProblemaReportado().substring(0, 50) + "..." : 
                                            recepcion.getProblemaReportado()) : "N/A" %>
                                    </td>
                                    <td><%= recepcion.getFechaEntrada() != null ? sdf.format(recepcion.getFechaEntrada()) : "N/A" %></td>
                                    <td>
                                        <%= recepcion.getFechaEstimadaSalida() != null ? 
                                            sdf.format(recepcion.getFechaEstimadaSalida()) : "Por definir" %>
                                    </td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "Pendiente";
                                            
                                            if (recepcion.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "Completada";
                                            } else if (recepcion.getIDEstadoTrabajo() != null) {
                                                estadoTexto = recepcion.getIDEstadoTrabajo().getNombreEstado();
                                                if ("EN PROCESO".equals(estadoTexto)) {
                                                    estadoClase = "badge-info";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-danger";
                                                } else if ("COMPLETADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-success";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/recepcion/ver?id=<%= recepcion.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            <a href="${pageContext.request.contextPath}/recepcionista/recepcion/editar?id=<%= recepcion.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-warning" title="Editar">
                                                ✏️ Editar
                                            </a>
                                            
                                            <% if (recepcion.getFechaRealSalida() == null) { %>
                                                <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/nuevo?orden=<%= recepcion.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-primary" title="Crear diagnóstico">
                                                    🔧 Diagnóstico
                                                </a>
                                            <% } %>
                                            
                                            <% if (recepcion.getFechaRealSalida() != null) { %>
                                                <a href="${pageContext.request.contextPath}/facturacion/generar?orden=<%= recepcion.getIDOrdenServicio() %>" 
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
                        <p>Total de recepciones: <strong><%= recepciones.size() %></strong></p>
                        <p>
                            <span class="badge badge-warning">Pendientes: <%= recepciones.stream().filter(r -> r.getFechaRealSalida() == null).count() %></span>
                            <span class="badge badge-success">Completadas: <%= recepciones.stream().filter(r -> r.getFechaRealSalida() != null).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>