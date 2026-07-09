<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Actualizar Estado del Vehículo</title>
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
                <h1>Actualizar Estado del Vehículo</h1>
                <p>Cambia el estado activo/inactivo del vehículo</p>
            </div>

            <% if (vehiculo != null) { %>
                <div class="form-container">
                    <!-- Información del vehículo -->
                    <div class="info-card">
                        <h3>🚗 Información del Vehículo</h3>
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
                                <strong>Propietario:</strong>
                                <span>
                                    <%= vehiculo.getIDCliente() != null ? 
                                        vehiculo.getIDCliente().getNombre() + " " + vehiculo.getIDCliente().getApellido() : "N/A" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Estado Actual:</strong>
                                <span class="badge <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "badge-success" : "badge-danger" %>">
                                    <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "Activo" : "Inactivo" %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Formulario de actualización -->
                    <form action="${pageContext.request.contextPath}/admin/vehiculos/actualizar-estado" method="post" class="admin-form">
                        <input type="hidden" name="idVehiculo" value="<%= vehiculo.getIDVehiculo() %>">
                        
                        <div class="form-group">
                            <label>Nuevo Estado *</label>
                            <div class="radio-group">
                                <label class="radio-option">
                                    <input type="radio" name="estado" value="true" 
                                           <%= vehiculo.getEstado() != null && vehiculo.getEstado() ? "checked" : "" %>>
                                    <span class="radio-label">
                                        <span class="status-indicator active"></span>
                                        Activo
                                    </span>
                                    <small>El vehículo puede recibir servicios</small>
                                </label>
                                
                                <label class="radio-option">
                                    <input type="radio" name="estado" value="false"
                                           <%= vehiculo.getEstado() != null && !vehiculo.getEstado() ? "checked" : "" %>>
                                    <span class="radio-label">
                                        <span class="status-indicator inactive"></span>
                                        Inactivo
                                    </span>
                                    <small>El vehículo no puede recibir servicios</small>
                                </label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="motivo">Motivo del Cambio *</label>
                            <select id="motivo" name="motivo" class="form-control" required>
                                <option value="">Seleccionar motivo</option>
                                <option value="mantenimiento">🚗 En Mantenimiento</option>
                                <option value="reparacion">🔧 En Reparación</option>
                                <option value="baja">📉 Dado de Baja</option>
                                <option value="venta">💰 Vendido</option>
                                <option value="otro">📝 Otro</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="observaciones">Observaciones Adicionales</label>
                            <textarea id="observaciones" name="observaciones" class="form-control" 
                                      rows="3" placeholder="Detalles adicionales sobre el cambio de estado..."></textarea>
                        </div>

                        <!-- Efectos del cambio -->
                        <div class="impact-section">
                            <h4>⚡ Efectos del Cambio</h4>
                            <div class="impact-grid">
                                <div class="impact-item">
                                    <strong>Si se marca como INACTIVO:</strong>
                                    <ul>
                                        <li>No se podrán crear nuevas órdenes de servicio</li>
                                        <li>No aparecerá en los listados de vehículos activos</li>
                                        <li>El historial existente se mantendrá</li>
                                    </ul>
                                </div>
                                <div class="impact-item">
                                    <strong>Si se marca como ACTIVO:</strong>
                                    <ul>
                                        <li>Podrá recibir nuevos servicios</li>
                                        <li>Aparecerá en los listados de vehículos</li>
                                        <li>Estará disponible para el cliente</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">🔄 Actualizar Estado</button>
                            <a href="${pageContext.request.contextPath}/admin/vehiculos/ver?id=<%= vehiculo.getIDVehiculo() %>" 
                               class="btn btn-secondary">↩️ Cancelar</a>
                        </div>
                    </form>
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