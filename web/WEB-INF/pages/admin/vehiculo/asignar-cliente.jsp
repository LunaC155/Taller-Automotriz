<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%@page import="com.upec.model.Cliente" %>
<%@page import="java.util.List" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    Cliente clienteActual = vehiculo != null ? vehiculo.getIDCliente() : null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Asignar Cliente a Vehículo</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudadmin.css">
</head>
<body class="admin">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-admin.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>Asignar Cliente a Vehículo</h1>
                <p>Cambia el propietario del vehículo</p>
            </div>

            <% if (vehiculo != null) { %>
                <div class="form-container">
                    <!-- Información del vehículo -->
                    <div class="info-card">
                        <h3>🚗 Vehículo Seleccionado</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>Placa:</strong>
                                <span><%= vehiculo.getPlaca() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Marca/Modelo:</strong>
                                <span>
                                    <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %> 
                                    <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Color:</strong>
                                <span><%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Propietario Actual:</strong>
                                <span>
                                    <% if (clienteActual != null) { %>
                                        <%= clienteActual.getNombre() %> <%= clienteActual.getApellido() %>
                                    <% } else { %>
                                        <em>Sin asignar</em>
                                    <% } %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Formulario de asignación -->
                    <form action="${pageContext.request.contextPath}/admin/vehiculos/asignar-cliente" method="post" class="admin-form">
                        <input type="hidden" name="idVehiculo" value="<%= vehiculo.getIDVehiculo() %>">
                        
                        <div class="form-group">
                            <label for="idCliente">Seleccionar Nuevo Propietario *</label>
                            <select id="idCliente" name="idCliente" class="form-control" required>
                                <option value="">Seleccionar un cliente</option>
                                <% if (clientes != null && !clientes.isEmpty()) { %>
                                    <% for (Cliente cliente : clientes) { %>
                                        <option value="<%= cliente.getIDCliente() %>" 
                                                <%= clienteActual != null && clienteActual.getIDCliente().equals(cliente.getIDCliente()) ? "selected" : "" %>>
                                            <%= cliente.getNombre() %> <%= cliente.getApellido() %>
                                            (<%= cliente.getEmail() != null ? cliente.getEmail() : "Sin email" %>)
                                        </option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="motivo">Motivo del Cambio (Opcional)</label>
                            <textarea id="motivo" name="motivo" class="form-control" 
                                      rows="3" placeholder="Ej: Venta del vehículo, corrección de datos, etc."></textarea>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">👤 Asignar Cliente</button>
                            <a href="${pageContext.request.contextPath}/admin/vehiculos/ver?id=<%= vehiculo.getIDVehiculo() %>" 
                               class="btn btn-secondary">↩️ Cancelar</a>
                        </div>
                    </form>
                </div>

                <!-- Información adicional -->
                <div class="info-grid">
                    <div class="info-card">
                        <h3>💡 Consideraciones</h3>
                        <ul>
                            <li>El cambio de propietario actualizará todos los registros asociados</li>
                            <li>El historial de servicios anteriores se mantendrá</li>
                            <li>Las nuevas órdenes de servicio se asociarán al nuevo propietario</li>
                            <li>Verifique que los datos del nuevo cliente sean correctos</li>
                        </ul>
                    </div>

                    <div class="info-card">
                        <h3>📋 Efectos del Cambio</h3>
                        <ul>
                            <li>El vehículo aparecerá en el listado del nuevo cliente</li>
                            <li>El cliente anterior perderá el acceso a este vehículo</li>
                            <li>Se mantendrá el historial completo del vehículo</li>
                            <li>Las facturas futuras se emitirán al nuevo propietario</li>
                        </ul>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el vehículo solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>