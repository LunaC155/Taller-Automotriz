<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Integer totalClientes = (Integer) request.getAttribute("totalClientes");
    Integer clientesNuevosMes = (Integer) request.getAttribute("clientesNuevosMes");
    Integer ordenesPendientes = (Integer) request.getAttribute("ordenesPendientes");
    Integer ordenesHoy = (Integer) request.getAttribute("ordenesHoy");
    List<Cliente> clientesRecientes = (List<Cliente>) request.getAttribute("clientesRecientes");
    List<OrdenServicio> ordenesPendientesList = (List<OrdenServicio>) request.getAttribute("ordenesPendientesList");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard de Atención - Taller Automotriz</title>
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
                <h1>🎯 Dashboard de Atención al Cliente</h1>
                <p>Gestión integral de clientes y atención al cliente</p>
            </div>

            <!-- Estadísticas principales -->
            <div class="dashboard-stats">
                <div class="stat-card clientes">
                    <div class="stat-icon">👥</div>
                    <div class="stat-number"><%= totalClientes != null ? totalClientes : 0 %></div>
                    <div class="stat-label">Total Clientes</div>
                </div>
                
                <div class="stat-card nuevos">
                    <div class="stat-icon">🆕</div>
                    <div class="stat-number"><%= clientesNuevosMes != null ? clientesNuevosMes : 0 %></div>
                    <div class="stat-label">Clientes Nuevos Este Mes</div>
                </div>
                
                <div class="stat-card pendientes">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-number"><%= ordenesPendientes != null ? ordenesPendientes : 0 %></div>
                    <div class="stat-label">Órdenes Pendientes</div>
                </div>
                
                <div class="stat-card hoy">
                    <div class="stat-icon">📅</div>
                    <div class="stat-number"><%= ordenesHoy != null ? ordenesHoy : 0 %></div>
                    <div class="stat-label">Órdenes Hoy</div>
                </div>
            </div>

            <!-- Acciones rápidas -->
            <div class="quick-actions">
                <a href="${pageContext.request.contextPath}/recepcionista/atencion/clientes" class="action-card">
                    <div class="action-icon">👥</div>
                    <h4>Gestión de Clientes</h4>
                    <p>Administrar información de clientes</p>
                </a>
                
                <a href="${pageContext.request.contextPath}/recepcionista/atencion/consultas" class="action-card">
                    <div class="action-icon">❓</div>
                    <h4>Consultas</h4>
                    <p>Gestionar consultas de clientes</p>
                </a>
                
                <a href="${pageContext.request.contextPath}/recepcionista/atencion/quejas" class="action-card">
                    <div class="action-icon">⚠️</div>
                    <h4>Quejas y Reclamos</h4>
                    <p>Atender quejas y reclamos</p>
                </a>
                
                <a href="${pageContext.request.contextPath}/recepcionista/atencion/seguimiento" class="action-card">
                    <div class="action-icon">📊</div>
                    <h4>Seguimiento</h4>
                    <p>Seguimiento de clientes</p>
                </a>
            </div>

            <!-- Información reciente -->
            <div class="recent-section">
                <!-- Clientes recientes -->
                <div class="section-card">
                    <h3>👥 Clientes Recientes</h3>
                    <% if (clientesRecientes != null && !clientesRecientes.isEmpty()) { %>
                        <ul class="client-list">
                            <% for (Cliente cliente : clientesRecientes) { %>
                                <li class="client-item">
                                    <div class="client-info">
                                        <h4><%= cliente.getNombre() %> <%= cliente.getApellido() %></h4>
                                        <div class="client-details">
                                            <%= cliente.getEmail() != null ? cliente.getEmail() : "Sin email" %> | 
                                            <%= cliente.getTelefono() != null ? cliente.getTelefono() : "Sin teléfono" %>
                                        </div>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= cliente.getIDCliente() %>" 
                                       class="btn btn-sm btn-info">Ver</a>
                                </li>
                            <% } %>
                        </ul>
                    <% } else { %>
                        <div class="empty-state">
                            <div class="empty-icon">👥</div>
                            <p>No hay clientes recientes</p>
                        </div>
                    <% } %>
                </div>

                <!-- Órdenes pendientes -->
                <div class="section-card">
                    <h3>⏳ Órdenes Pendientes</h3>
                    <% if (ordenesPendientesList != null && !ordenesPendientesList.isEmpty()) { %>
                        <ul class="order-list">
                            <% for (OrdenServicio orden : ordenesPendientesList) { %>
                                <li class="order-item">
                                    <div class="order-info">
                                        <h4>Orden #<%= orden.getIDOrdenServicio() %></h4>
                                        <div class="order-details">
                                            <% if (orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null) { %>
                                                <%= orden.getIDVehiculo().getIDCliente().getNombre() %> - 
                                                <%= orden.getIDVehiculo().getPlaca() %>
                                            <% } %>
                                        </div>
                                    </div>
                                    <span class="badge badge-warning">Pendiente</span>
                                </li>
                            <% } %>
                        </ul>
                    <% } else { %>
                        <div class="empty-state">
                            <div class="empty-icon">✅</div>
                            <p>No hay órdenes pendientes</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Búsqueda rápida -->
            <div class="section-card" style="margin-top: 30px;">
                <h3>🔍 Búsqueda Rápida</h3>
                <form action="${pageContext.request.contextPath}/recepcionista/atencion/buscar" method="post" class="search-form">
                    <div style="display: grid; grid-template-columns: 1fr 2fr auto; gap: 10px; align-items: end;">
                        <div>
                            <label for="tipoBusqueda">Buscar por:</label>
                            <select id="tipoBusqueda" name="tipo" class="form-control">
                                <option value="cliente">Cliente</option>
                                <option value="orden">Orden</option>
                                <option value="consulta">Consulta</option>
                            </select>
                        </div>
                        <div>
                            <label for="valorBusqueda">Término de búsqueda:</label>
                            <input type="text" id="valorBusqueda" name="valor" class="form-control" 
                                   placeholder="Ingrese nombre, email, problema...">
                        </div>
                        <div>
                            <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>