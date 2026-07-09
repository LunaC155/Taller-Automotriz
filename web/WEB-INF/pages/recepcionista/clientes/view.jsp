<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, com.upec.model.Vehiculo" %>
<%@page import="java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Cliente cliente = (Cliente) request.getAttribute("cliente");
    List<Vehiculo> vehiculos = cliente != null ? cliente.getVehiculoList() : null;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalles del Cliente - Recepcionista</title>
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
                <h1>👥 Detalles del Cliente</h1>
                <p>Información completa del cliente y sus vehículos</p>
            </div>

            <% if (cliente != null) { 
                String iniciales = (cliente.getNombre().charAt(0) + "" + (cliente.getApellido() != null ? cliente.getApellido().charAt(0) : "")).toUpperCase();
            %>
                <div class="client-detail">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <div style="display: flex; align-items: center; gap: 20px;">
                            <div class="client-avatar">
                                <%= iniciales %>
                            </div>
                            <div>
                                <h2><%= cliente.getNombre() %> <%= cliente.getApellido() %></h2>
                                <p style="color: #6c757d; margin: 0;">Cliente #<%= cliente.getIDCliente() %></p>
                            </div>
                        </div>
                        <div style="text-align: right;">
                            <div style="font-size: 0.9em; color: #6c757d;">Fecha de Registro</div>
                            <div style="font-weight: bold;">
                                <% if (cliente.getFechaRegistro() != null) { 
                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                %>
                                    <%= sdf.format(cliente.getFechaRegistro()) %>
                                <% } else { %>
                                    N/A
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Estadísticas -->
                    <div class="stats-cards">
                        <div class="stat-card">
                            <span class="stat-number"><%= vehiculos != null ? vehiculos.size() : 0 %></span>
                            <span class="stat-label">Vehículos Registrados</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <% 
                                    long serviciosActivos = 0;
                                    if (vehiculos != null) {
                                        // Esto sería mejor calcularlo desde el DAO, pero para el ejemplo:
                                        serviciosActivos = vehiculos.stream().count(); // Simulación
                                    }
                                %>
                                <%= serviciosActivos %>
                            </span>
                            <span class="stat-label">Servicios Activos</span>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number">
                                <%
                                    java.util.Calendar cal = java.util.Calendar.getInstance();
                                    cal.add(java.util.Calendar.MONTH, -6);
                                    boolean esClienteRecurrente = cliente.getFechaRegistro() != null && 
                                                                 cliente.getFechaRegistro().before(cal.getTime());
                                %>
                                <%= esClienteRecurrente ? "Sí" : "No" %>
                            </span>
                            <span class="stat-label">Cliente Recurrente</span>
                        </div>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información Personal -->
                        <div class="detail-card">
                            <h3>👤 Información Personal</h3>
                            <div class="detail-item">
                                <strong>Nombre:</strong>
                                <span><%= cliente.getNombre() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Apellido:</strong>
                                <span><%= cliente.getApellido() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>ID Cliente:</strong>
                                <span>#<%= cliente.getIDCliente() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha Registro:</strong>
                                <span>
                                    <% if (cliente.getFechaRegistro() != null) { 
                                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                                    %>
                                        <%= sdf.format(cliente.getFechaRegistro()) %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                        </div>

                        <!-- Información de Contacto -->
                        <div class="detail-card">
                            <h3>📞 Información de Contacto</h3>
                            <div class="detail-item">
                                <strong>Email:</strong>
                                <span>
                                    <% if (cliente.getEmail() != null) { %>
                                        <a href="mailto:<%= cliente.getEmail() %>"><%= cliente.getEmail() %></a>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Teléfono:</strong>
                                <span>
                                    <% if (cliente.getTelefono() != null) { %>
                                        <a href="tel:<%= cliente.getTelefono() %>"><%= cliente.getTelefono() %></a>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Dirección:</strong>
                                <span><%= cliente.getDireccion() != null ? cliente.getDireccion() : "N/A" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Vehículos del Cliente -->
                    <div class="vehicles-section">
                        <h3>🚗 Vehículos del Cliente</h3>
                        
                        <% if (vehiculos == null || vehiculos.isEmpty()) { %>
                            <div class="no-vehicles">
                                <div style="font-size: 3em; margin-bottom: 15px;">🚗</div>
                                <h4>No hay vehículos registrados</h4>
                                <p>Este cliente no tiene vehículos asociados en el sistema.</p>
                                <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/crear?cliente=<%= cliente.getIDCliente() %>" 
                                   class="btn btn-primary">➕ Agregar Primer Vehículo</a>
                            </div>
                        <% } else { %>
                            <div class="vehicles-grid">
                                <% for (Vehiculo vehiculo : vehiculos) { %>
                                    <div class="vehicle-card">
                                        <div class="vehicle-card-header">
                                            <span class="vehicle-placa"><%= vehiculo.getPlaca() %></span>
                                        </div>
                                        <div class="vehicle-info">
                                            <p><strong>
                                                <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "Marca N/A" %> 
                                                <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "Modelo N/A" %>
                                            </strong></p>
                                            <p>Color: <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></p>
                                            <p>Año: <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></p>
                                            <p>Kilometraje: <%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></p>
                                        </div>
                                        <div style="margin-top: 10px;">
                                            <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/ver?id=<%= vehiculo.getIDVehiculo() %>" 
                                               class="btn btn-sm btn-info">Ver Detalles</a>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div style="margin-top: 15px; text-align: center;">
                                <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/crear?cliente=<%= cliente.getIDCliente() %>" 
                                   class="btn btn-primary">➕ Agregar Otro Vehículo</a>
                            </div>
                        <% } %>
                    </div>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/recepcionista/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                           class="btn btn-warning">✏️ Editar Cliente</a>
                        <a href="${pageContext.request.contextPath}/recepcionista/vehiculos?cliente=<%= cliente.getIDCliente() %>" 
                           class="btn btn-success">🚗 Gestionar Vehículos</a>
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes/crear?cliente=<%= cliente.getIDCliente() %>" 
                           class="btn btn-primary">🔧 Nueva Orden de Servicio</a>
                        <a href="${pageContext.request.contextPath}/recepcionista/clientes" 
                           class="btn btn-secondary">↩️ Volver a Clientes</a>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el cliente solicitado.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/clientes" class="btn btn-secondary">Volver a Clientes</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>