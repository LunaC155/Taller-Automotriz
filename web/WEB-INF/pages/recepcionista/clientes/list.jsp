<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Clientes - Recepcionista</title>
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
                <h1>👥 Gestión de Clientes</h1>
                <p>Administra la información de los clientes del taller</p>
            </div>

            <!-- Estadísticas rápidas -->
            <div class="client-stats">
                <div class="stat-card">
                    <span class="stat-number"><%= clientes != null ? clientes.size() : 0 %></span>
                    <span class="stat-label">Total Clientes</span>
                </div>
                <div class="stat-card">
                    <span class="stat-number">
                        <%= clientes != null ? 
                            clientes.stream().filter(c -> c.getVehiculoList() != null && !c.getVehiculoList().isEmpty()).count() : 0 %>
                    </span>
                    <span class="stat-label">Con Vehículos</span>
                </div>
                <div class="stat-card">
                    <span class="stat-number">
                        <%= clientes != null ? 
                            clientes.stream().filter(c -> {
                                java.util.Calendar cal = java.util.Calendar.getInstance();
                                cal.add(java.util.Calendar.MONTH, -1);
                                return c.getFechaRegistro() != null && c.getFechaRegistro().after(cal.getTime());
                            }).count() : 0 %>
                    </span>
                    <span class="stat-label">Nuevos este Mes</span>
                </div>
            </div>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/clientes/crear" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Nuevo Cliente
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/vehiculos" class="btn btn-info">
                        <span class="btn-icon">🚗</span> Gestión de Vehículos
                    </a>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/recepcionista/clientes/buscar" method="get" class="search-form">
                        <div class="search-controls">
                            <select name="criterio" class="form-control">
                                <option value="nombre" <%= "nombre".equals(criterio) ? "selected" : "" %>>Nombre</option>
                                <option value="email" <%= "email".equals(criterio) ? "selected" : "" %>>Email</option>
                                <option value="telefono" <%= "telefono".equals(criterio) ? "selected" : "" %>>Teléfono</option>
                            </select>
                            <input type="text" name="valor" value="<%= valor != null ? valor : "" %>" 
                                   placeholder="Buscar clientes..." class="form-control">
                            <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                            <a href="${pageContext.request.contextPath}/recepcionista/clientes" class="btn btn-outline">🔄 Limpiar</a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Tabla de clientes -->
            <div class="table-container">
                <% if (clientes == null || clientes.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">👥</div>
                        <h3>No hay clientes registrados</h3>
                        <p>No se encontraron clientes en el sistema.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/clientes/crear" class="btn btn-primary">
                            Registrar Primer Cliente
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Cliente</th>
                                <th>Contacto</th>
                                <th>Dirección</th>
                                <th>Fecha Registro</th>
                                <th>Vehículos</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Cliente cliente : clientes) { %>
                                <tr>
                                    <td>#<%= cliente.getIDCliente() %></td>
                                    <td>
                                        <strong><%= cliente.getNombre() %> <%= cliente.getApellido() %></strong>
                                    </td>
                                    <td class="client-contact">
                                        <div>📧 <%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></div>
                                        <div>📞 <%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></div>
                                    </td>
                                    <td>
                                        <%= cliente.getDireccion() != null ? 
                                            (cliente.getDireccion().length() > 30 ? 
                                             cliente.getDireccion().substring(0, 30) + "..." : 
                                             cliente.getDireccion()) : "N/A" %>
                                    </td>
                                    <td>
                                        <% if (cliente.getFechaRegistro() != null) { 
                                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                        %>
                                            <%= sdf.format(cliente.getFechaRegistro()) %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="vehicle-count">
                                            <%= cliente.getVehiculoList() != null ? cliente.getVehiculoList().size() : 0 %> vehículos
                                        </span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/clientes/ver?id=<%= cliente.getIDCliente() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            <a href="${pageContext.request.contextPath}/recepcionista/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                                               class="btn btn-sm btn-warning" title="Editar cliente">
                                                ✏️ Editar
                                            </a>
                                            <a href="${pageContext.request.contextPath}/recepcionista/vehiculos?cliente=<%= cliente.getIDCliente() %>" 
                                               class="btn btn-sm btn-success" title="Ver vehículos">
                                                🚗 Vehículos
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de clientes: <strong><%= clientes.size() %></strong></p>
                        <% if (criterio != null && valor != null) { %>
                            <p>Filtrado por: <strong><%= criterio %> = "<%= valor %>"</strong></p>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <!-- Información útil -->
            <div class="additional-info">
                <h3>💡 Información Útil</h3>
                <div class="info-grid">
                    <div class="info-card">
                        <h4>📋 Flujo de Trabajo</h4>
                        <ul>
                            <li>Registra al cliente antes de agregar vehículos</li>
                            <li>Verifica que el email y teléfono sean correctos</li>
                            <li>Asocia vehículos al cliente para crear órdenes de servicio</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>🔍 Búsquedas Rápidas</h4>
                        <ul>
                            <li>Busca por nombre para clientes frecuentes</li>
                            <li>Usa el teléfono para verificar clientes existentes</li>
                            <li>El email ayuda a evitar duplicados</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>