<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%@page import="java.util.Date" %>
<%
    // Verificar sesión de recepcionista
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> citas = (List<OrdenServicio>) request.getAttribute("citas");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Citas - Recepcionista</title>
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
                <h1>📅 Gestión de Citas</h1>
                <p>Administra todas las citas programadas en el taller</p>
            </div>

            <!-- Tarjetas de Estadísticas -->
            <div class="stats-cards">
                <div class="stat-card">
                    <span class="stat-number"><%= citas != null ? citas.size() : 0 %></span>
                    <span class="stat-label">Total Citas</span>
                </div>
                <div class="stat-card pendientes">
                    <span class="stat-number">
                        <%= citas != null ? citas.stream().filter(c -> c.getFechaRealSalida() == null && 
                               (c.getIDEstadoTrabajo() == null || "PENDIENTE".equals(c.getIDEstadoTrabajo().getNombreEstado()))).count() : 0 %>
                    </span>
                    <span class="stat-label">Pendientes</span>
                </div>
                <div class="stat-card proceso">
                    <span class="stat-number">
                        <%= citas != null ? citas.stream().filter(c -> c.getFechaRealSalida() == null && 
                               c.getIDEstadoTrabajo() != null && "EN PROCESO".equals(c.getIDEstadoTrabajo().getNombreEstado())).count() : 0 %>
                    </span>
                    <span class="stat-label">En Proceso</span>
                </div>
                <div class="stat-card completadas">
                    <span class="stat-number">
                        <%= citas != null ? citas.stream().filter(c -> c.getFechaRealSalida() != null).count() : 0 %>
                    </span>
                    <span class="stat-label">Completadas</span>
                </div>
            </div>

            <!-- Acciones Principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <div class="quick-actions">
                        <a href="${pageContext.request.contextPath}/recepcionista/citas/crear" class="btn btn-primary">
                            <span class="btn-icon">➕</span> Nueva Cita
                        </a>
                        <a href="${pageContext.request.contextPath}/recepcionista/citas/calendario" class="btn btn-info">
                            <span class="btn-icon">📅</span> Vista Calendario
                        </a>
                        <a href="${pageContext.request.contextPath}/recepcionista/citas/buscar" class="btn btn-warning">
                            <span class="btn-icon">🔍</span> Búsqueda Avanzada
                        </a>
                    </div>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/recepcionista/citas/buscar" method="get" class="search-form">
                        <input type="text" name="valor" placeholder="Buscar citas..." 
                               value="<%= valor != null ? valor : "" %>" class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Filtros Rápidos -->
            <div class="search-advanced">
                <h4>🔍 Filtros Rápidos</h4>
                <div class="search-filters">
                    <a href="${pageContext.request.contextPath}/recepcionista/citas?estado=pending" class="btn btn-outline-warning btn-sm">
                        Pendientes
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas?estado=in-progress" class="btn btn-outline-info btn-sm">
                        En Proceso
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas?estado=completed" class="btn btn-outline-success btn-sm">
                        Completadas
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas?estado=today" class="btn btn-outline-primary btn-sm">
                        Citas de Hoy
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas" class="btn btn-outline-secondary btn-sm">
                        Ver Todas
                    </a>
                </div>
            </div>

            <!-- Tabla de Citas -->
            <div class="table-container">
                <% if (citas == null || citas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📅</div>
                        <h3>No hay citas registradas</h3>
                        <p>No se encontraron citas con los criterios de búsqueda actuales.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/citas/crear" class="btn btn-primary">
                            Agendar Primera Cita
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Cliente</th>
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
                                        <% if (cita.getIDVehiculo() != null && cita.getIDVehiculo().getIDCliente() != null) { %>
                                            <strong><%= cita.getIDVehiculo().getIDCliente().getNombre() %> <%= cita.getIDVehiculo().getIDCliente().getApellido() %></strong>
                                            <div class="client-info">
                                                <%= cita.getIDVehiculo().getIDCliente().getTelefono() != null ? cita.getIDVehiculo().getIDCliente().getTelefono() : "Sin teléfono" %>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted">Cliente no disponible</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (cita.getIDVehiculo() != null) { %>
                                            <strong><%= cita.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= cita.getIDVehiculo().getIDMarca() != null ? cita.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= cita.getIDVehiculo().getIDModelo() != null ? cita.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            <span class="text-muted">Vehículo no disponible</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= cita.getProblemaReportado() != null ? 
                                           (cita.getProblemaReportado().length() > 50 ? 
                                            cita.getProblemaReportado().substring(0, 50) + "..." : 
                                            cita.getProblemaReportado()) : "N/A" %>
                                    </td>
                                    <td>
                                        <%= cita.getFechaEntrada() != null ? 
                                            new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(cita.getFechaEntrada()) : "N/A" %>
                                    </td>
                                    <td>
                                        <%= cita.getFechaEstimadaSalida() != null ? 
                                            new java.text.SimpleDateFormat("dd/MM/yyyy").format(cita.getFechaEstimadaSalida()) : "Por definir" %>
                                        <% if (cita.getFechaEstimadaSalida() != null && cita.getFechaEstimadaSalida().before(new Date())) { %>
                                            <span class="priority-badge priority-high">Atrasada</span>
                                        <% } %>
                                    </td>
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
                                                } else if ("DIAGNOSTICO".equals(estadoTexto)) {
                                                    estadoClase = "badge-primary";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/citas/ver?id=<%= cita.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/recepcionista/citas/editar?id=<%= cita.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-warning" title="Editar">
                                                ✏️
                                            </a>
                                            
                                            <% if (cita.getFechaRealSalida() == null) { %>
                                                <form action="${pageContext.request.contextPath}/recepcionista/citas/cancelar" 
                                                      method="post" style="display: inline;">
                                                    <input type="hidden" name="id" value="<%= cita.getIDOrdenServicio() %>">
                                                    <button type="submit" class="btn btn-sm btn-danger" 
                                                            title="Cancelar cita"
                                                            onclick="return confirm('¿Está seguro de cancelar esta cita?')">
                                                        ❌
                                                    </button>
                                                </form>
                                            <% } %>
                                            
                                            <% if (cita.getFechaRealSalida() != null) { %>
                                                <a href="${pageContext.request.contextPath}/recepcionista/facturas/generar?orden=<%= cita.getIDOrdenServicio() %>" 
                                                   class="btn btn-sm btn-success" title="Generar factura">
                                                    🧾
                                                </a>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información Adicional -->
                    <div class="table-info">
                        <p>Total de citas: <strong><%= citas.size() %></strong></p>
                        <p>
                            <span class="badge badge-warning">Pendientes: <%= citas.stream().filter(c -> c.getFechaRealSalida() == null && 
                                   (c.getIDEstadoTrabajo() == null || "PENDIENTE".equals(c.getIDEstadoTrabajo().getNombreEstado()))).count() %></span>
                            <span class="badge badge-info">En Proceso: <%= citas.stream().filter(c -> c.getFechaRealSalida() == null && 
                                   c.getIDEstadoTrabajo() != null && "EN PROCESO".equals(c.getIDEstadoTrabajo().getNombreEstado())).count() %></span>
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