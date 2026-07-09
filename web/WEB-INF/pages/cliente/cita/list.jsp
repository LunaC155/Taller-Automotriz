<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 4) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> citas = (List<OrdenServicio>) request.getAttribute("citas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Citas - Taller Automotriz</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
</head>
<body class="cliente">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-cliente.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>📅 Mis Citas</h1>
                <p>Gestiona todas tus citas programadas en el taller</p>
            </div>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/CitaServlet?action=nueva" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Nueva Cita
                    </a>
                    <a href="${pageContext.request.contextPath}/cliente/servicios/mis-servicios" class="btn btn-info">
                        <span class="btn-icon">🔧</span> Mis Servicios
                    </a>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/CitaServlet" method="get" class="search-form">
                        <input type="hidden" name="action" value="buscar">
                        <input type="text" name="buscar" placeholder="Buscar por vehículo o problema..." class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Tabla de citas -->
            <div class="table-container">
                <% if (citas == null || citas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📅</div>
                        <h3>No hay citas registradas</h3>
                        <p>No tienes citas programadas en este momento.</p>
                        <a href="${pageContext.request.contextPath}/CitaServlet?action=nueva" class="btn btn-primary">
                            Programar Primera Cita
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Vehículo</th>
                                <th>Problema</th>
                                <th>Fecha Entrada</th>
                                <th>Fecha Est. Salida</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio cita : citas) { %>
                                <tr>
                                    <td>#<%= cita.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (cita.getIDVehiculo() != null) { %>
                                            <strong><%= cita.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= cita.getIDVehiculo().getIDMarca() != null ? cita.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= cita.getIDVehiculo().getIDModelo() != null ? cita.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td><%= cita.getProblemaReportado() != null ? 
                                           (cita.getProblemaReportado().length() > 50 ? 
                                            cita.getProblemaReportado().substring(0, 50) + "..." : 
                                            cita.getProblemaReportado()) : "N/A" %></td>
                                    <td><%= cita.getFechaEntrada() != null ? cita.getFechaEntrada() : "N/A" %></td>
                                    <td><%= cita.getFechaEstimadaSalida() != null ? cita.getFechaEstimadaSalida() : "Por definir" %></td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "Pendiente";
                                            
                                            if (cita.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "Completada";
                                            } else if (cita.getIDEstadoTrabajo() != null) {
                                                estadoTexto = cita.getIDEstadoTrabajo().getNombreEstado();
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
                                            <a href="${pageContext.request.contextPath}/CitaServlet?action=ver&id=<%= cita.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            
                                            <% if (cita.getFechaRealSalida() == null && 
                                                   (cita.getFechaEntrada() == null || cita.getFechaEntrada().after(new java.util.Date()))) { %>
                                                <form action="${pageContext.request.contextPath}/CitaServlet?action=cancelar" 
                                                      method="post" style="display: inline;">
                                                    <input type="hidden" name="id" value="<%= cita.getIDOrdenServicio() %>">
                                                    <button type="submit" class="btn btn-sm btn-danger" 
                                                            title="Cancelar cita"
                                                            onclick="return confirm('¿Está seguro de cancelar esta cita?')">
                                                        ❌ Cancelar
                                                    </button>
                                                </form>
                                            <% } %>
                                            
                                            <% if (cita.getFechaRealSalida() != null) { %>
                                                <a href="${pageContext.request.contextPath}/cliente/facturaclientes/ver?orden=<%= cita.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-success" title="Ver factura">
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
                        <p>Total de citas: <strong><%= citas.size() %></strong></p>
                        <p>
                            <span class="badge badge-warning">Pendientes: <%= citas.stream().filter(c -> c.getFechaRealSalida() == null).count() %></span>
                            <span class="badge badge-success">Completadas: <%= citas.stream().filter(c -> c.getFechaRealSalida() != null).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>