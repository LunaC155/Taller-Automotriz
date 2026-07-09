<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    List<Cliente> clientesActivos = (List<Cliente>) request.getAttribute("clientesActivos");
    List<OrdenServicio> consultas = (List<OrdenServicio>) request.getAttribute("consultas");
    List<OrdenServicio> quejas = (List<OrdenServicio>) request.getAttribute("quejas");
    List<Cliente> clientesSeguimiento = (List<Cliente>) request.getAttribute("clientesSeguimiento");
    
    String tipo = (String) request.getAttribute("tipo");
    String tipoBusqueda = (String) request.getAttribute("tipoBusqueda");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
    
    String titulo = "Gestión de Clientes";
    String descripcion = "Administra la información de todos los clientes";
    
    if ("consultas".equals(tipo)) {
        titulo = "Consultas de Clientes";
        descripcion = "Gestiona las consultas y preguntas de los clientes";
    } else if ("quejas".equals(tipo)) {
        titulo = "Quejas y Reclamos";
        descripcion = "Atiende las quejas y reclamos de los clientes";
    } else if (clientesSeguimiento != null) {
        titulo = "Seguimiento de Clientes";
        descripcion = "Clientes que requieren seguimiento especial";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> - Taller Automotriz</title>
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
                <h1><%= titulo %></h1>
                <p><%= descripcion %></p>
            </div>

            <!-- Resultados de búsqueda -->
            <% if (tipoBusqueda != null) { %>
                <div class="search-results">
                    <h4>🔍 Resultados de Búsqueda</h4>
                    <p>
                        Búsqueda de <strong><%= tipoBusqueda %></strong> 
                        <% if (criterio != null && valor != null) { %>
                            con criterio "<strong><%= criterio %></strong>" 
                            y valor "<strong><%= valor %></strong>"
                        <% } %>
                    </p>
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion" class="btn btn-sm btn-secondary">
                        ↩️ Volver al Dashboard
                    </a>
                </div>
            <% } %>

            <!-- Estadísticas -->
            <% if (clientes != null && "consultas".equals(tipo)) { %>
                <div class="stats-cards">
                    <div class="stat-mini consultas">
                        <div class="stat-mini-number"><%= consultas != null ? consultas.size() : 0 %></div>
                        <div>Consultas Activas</div>
                    </div>
                </div>
            <% } else if (clientes != null && "quejas".equals(tipo)) { %>
                <div class="stats-cards">
                    <div class="stat-mini quejas">
                        <div class="stat-mini-number"><%= quejas != null ? quejas.size() : 0 %></div>
                        <div>Quejas Pendientes</div>
                    </div>
                </div>
            <% } else if (clientesSeguimiento != null) { %>
                <div class="stats-cards">
                    <div class="stat-mini">
                        <div class="stat-mini-number"><%= clientesSeguimiento != null ? clientesSeguimiento.size() : 0 %></div>
                        <div>Clientes con Seguimiento</div>
                    </div>
                </div>
            <% } else if (clientes != null) { %>
                <div class="stats-cards">
                    <div class="stat-mini clientes">
                        <div class="stat-mini-number"><%= clientes != null ? clientes.size() : 0 %></div>
                        <div>Total Clientes</div>
                    </div>
                    <div class="stat-mini activos">
                        <div class="stat-mini-number"><%= clientesActivos != null ? clientesActivos.size() : 0 %></div>
                        <div>Clientes Activos</div>
                    </div>
                </div>
            <% } %>

            <!-- Lista de contenido -->
            <div class="content-list">
                <!-- Clientes -->
                <% if (clientes != null && !"consultas".equals(tipo) && !"quejas".equals(tipo) && clientesSeguimiento == null) { %>
                    <% if (clientes.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">👥</div>
                            <h3>No hay clientes registrados</h3>
                            <p>No se encontraron clientes en el sistema.</p>
                        </div>
                    <% } else { %>
                        <% for (Cliente cliente : clientes) { %>
                            <div class="client-card">
                                <div class="client-header">
                                    <div class="client-info">
                                        <h3><%= cliente.getNombre() %> <%= cliente.getApellido() %></h3>
                                        <div class="client-details">
                                            <strong>Email:</strong> <%= cliente.getEmail() != null ? cliente.getEmail() : "No especificado" %> | 
                                            <strong>Teléfono:</strong> <%= cliente.getTelefono() != null ? cliente.getTelefono() : "No especificado" %> | 
                                            <strong>Registro:</strong> <%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %>
                                        </div>
                                    </div>
                                    <div class="client-actions">
                                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= cliente.getIDCliente() %>" 
                                           class="btn btn-sm btn-info">📋 Historial</a>
                                        <a href="mailto:<%= cliente.getEmail() != null ? cliente.getEmail() : "" %>" 
                                           class="btn btn-sm btn-secondary" 
                                           <%= cliente.getEmail() == null ? "disabled" : "" %>>📧 Email</a>
                                    </div>
                                </div>
                                <div class="client-body">
                                    <% if (cliente.getDireccion() != null && !cliente.getDireccion().trim().isEmpty()) { %>
                                        <p><strong>Dirección:</strong> <%= cliente.getDireccion() %></p>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                <% } %>

                <!-- Consultas -->
                <% if ("consultas".equals(tipo) && consultas != null) { %>
                    <% if (consultas.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">❓</div>
                            <h3>No hay consultas pendientes</h3>
                            <p>No se encontraron consultas de clientes.</p>
                        </div>
                    <% } else { %>
                        <% for (OrdenServicio consulta : consultas) { %>
                            <div class="order-card">
                                <div class="order-header">
                                    <div class="order-info">
                                        <h3>Consulta #<%= consulta.getIDOrdenServicio() %></h3>
                                        <div class="order-details">
                                            <strong>Cliente:</strong> 
                                            <% if (consulta.getIDVehiculo() != null && consulta.getIDVehiculo().getIDCliente() != null) { %>
                                                <%= consulta.getIDVehiculo().getIDCliente().getNombre() %> <%= consulta.getIDVehiculo().getIDCliente().getApellido() %>
                                            <% } else { %>
                                                No especificado
                                            <% } %> | 
                                            <strong>Fecha:</strong> <%= consulta.getFechaEntrada() != null ? consulta.getFechaEntrada() : "N/A" %>
                                        </div>
                                    </div>
                                    <div class="order-actions">
                                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= consulta.getIDVehiculo().getIDCliente().getIDCliente() %>" 
                                           class="btn btn-sm btn-info">👤 Cliente</a>
                                    </div>
                                </div>
                                <div class="order-body">
                                    <% if (consulta.getObservaciones() != null && !consulta.getObservaciones().trim().isEmpty()) { %>
                                        <div class="problem-description">
                                            <strong>Consulta:</strong> <%= consulta.getObservaciones() %>
                                        </div>
                                    <% } %>
                                    <% if (consulta.getProblemaReportado() != null && !consulta.getProblemaReportado().trim().isEmpty()) { %>
                                        <p><strong>Problema relacionado:</strong> <%= consulta.getProblemaReportado() %></p>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                <% } %>

                <!-- Quejas -->
                <% if ("quejas".equals(tipo) && quejas != null) { %>
                    <% if (quejas.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">⚠️</div>
                            <h3>No hay quejas pendientes</h3>
                            <p>No se encontraron quejas o reclamos de clientes.</p>
                        </div>
                    <% } else { %>
                        <% for (OrdenServicio queja : quejas) { %>
                            <div class="order-card">
                                <div class="order-header">
                                    <div class="order-info">
                                        <h3>Queja #<%= queja.getIDOrdenServicio() %></h3>
                                        <div class="order-details">
                                            <strong>Cliente:</strong> 
                                            <% if (queja.getIDVehiculo() != null && queja.getIDVehiculo().getIDCliente() != null) { %>
                                                <%= queja.getIDVehiculo().getIDCliente().getNombre() %> <%= queja.getIDVehiculo().getIDCliente().getApellido() %>
                                            <% } else { %>
                                                No especificado
                                            <% } %> | 
                                            <strong>Fecha:</strong> <%= queja.getFechaEntrada() != null ? queja.getFechaEntrada() : "N/A" %> |
                                            <strong>Estado:</strong> <span class="badge badge-danger">QUEJA</span>
                                        </div>
                                    </div>
                                    <div class="order-actions">
                                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= queja.getIDVehiculo().getIDCliente().getIDCliente() %>" 
                                           class="btn btn-sm btn-info">👤 Cliente</a>
                                        <button class="btn btn-sm btn-warning" onclick="marcarComoResuelta(<%= queja.getIDOrdenServicio() %>)">
                                            ✅ Resolver
                                        </button>
                                    </div>
                                </div>
                                <div class="order-body">
                                    <div class="problem-description">
                                        <strong>Problema reportado:</strong> <%= queja.getProblemaReportado() %>
                                    </div>
                                    <% if (queja.getObservaciones() != null && !queja.getObservaciones().trim().isEmpty()) { %>
                                        <p><strong>Observaciones adicionales:</strong> <%= queja.getObservaciones() %></p>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                <% } %>

                <!-- Seguimiento -->
                <% if (clientesSeguimiento != null) { %>
                    <% if (clientesSeguimiento.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon">📊</div>
                            <h3>No hay clientes con seguimiento</h3>
                            <p>Todos los clientes están al día con sus servicios.</p>
                        </div>
                    <% } else { %>
                        <% for (Cliente cliente : clientesSeguimiento) { %>
                            <div class="client-card">
                                <div class="client-header">
                                    <div class="client-info">
                                        <h3><%= cliente.getNombre() %> <%= cliente.getApellido() %> <span class="badge badge-warning">Requiere Seguimiento</span></h3>
                                        <div class="client-details">
                                            <strong>Contacto:</strong> <%= cliente.getEmail() != null ? cliente.getEmail() : "No email" %> | 
                                            <%= cliente.getTelefono() != null ? cliente.getTelefono() : "No teléfono" %>
                                        </div>
                                    </div>
                                    <div class="client-actions">
                                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= cliente.getIDCliente() %>" 
                                           class="btn btn-sm btn-info">📋 Historial</a>
                                        <a href="tel:<%= cliente.getTelefono() != null ? cliente.getTelefono() : "" %>" 
                                           class="btn btn-sm btn-success"
                                           <%= cliente.getTelefono() == null ? "disabled" : "" %>>📞 Llamar</a>
                                    </div>
                                </div>
                                <div class="client-body">
                                    <p><strong>Razón del seguimiento:</strong> Cliente con órdenes de servicio pendientes que requieren atención.</p>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function marcarComoResuelta(idOrden) {
            if (confirm('¿Está seguro de marcar esta queja como resuelta?')) {
                // Aquí iría la lógica para marcar la queja como resuelta
                alert('Queja marcada como resuelta. Esta funcionalidad se implementará próximamente.');
            }
        }
    </script>
</body>
</html>