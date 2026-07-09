<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Vehiculo" %>
<%@page import="java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asignar Vehículo - Recepcionista</title>
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
                <h1>🚗 Asignar Vehículo a Orden</h1>
                <p>Selecciona un vehículo para asociarlo a la orden de servicio</p>
            </div>

            <% if (orden != null) { %>
                <div class="assignment-container">
                    <!-- Información de la Orden -->
                    <div class="order-info">
                        <h3>📋 Información de la Orden</h3>
                        <div class="info-grid">
                            <div class="info-item">
                                <strong>Orden #</strong>
                                <span><%= orden.getIDOrdenServicio() %></span>
                            </div>
                            <div class="info-item">
                                <strong>Problema Reportado</strong>
                                <span><%= orden.getProblemaReportado() != null ? 
                                       (orden.getProblemaReportado().length() > 100 ? 
                                        orden.getProblemaReportado().substring(0, 100) + "..." : 
                                        orden.getProblemaReportado()) : "N/A" %></span>
                            </div>
                            <div class="info-item">
                                <strong>Fecha Entrada</strong>
                                <span><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></span>
                            </div>
                            <div class="info-item">
                                <strong>Estado</strong>
                                <span><%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Selección de Vehículo -->
                    <form action="${pageContext.request.contextPath}/recepcionista/ordenes/asignar-vehiculo" method="post" id="assignForm">
                        <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                        
                        <h3>🚗 Seleccionar Vehículo</h3>
                        <p>Selecciona un vehículo de la lista para asociarlo a esta orden:</p>

                        <% if (vehiculos != null && !vehiculos.isEmpty()) { %>
                            <div class="vehicles-grid" id="vehiclesContainer">
                                <% for (Vehiculo vehiculo : vehiculos) { 
                                    boolean disponible = true; // En una implementación real, verificarías disponibilidad
                                %>
                                    <div class="vehicle-card <%= disponible ? "available" : "unavailable" %>" 
                                         onclick="<%= disponible ? "selectVehicle(" + vehiculo.getIDVehiculo() + ")" : "" %>">
                                        <div class="vehicle-header">
                                            <span class="vehicle-placa"><%= vehiculo.getPlaca() %></span>
                                            <span class="availability-badge <%= disponible ? "badge-available" : "badge-unavailable" %>">
                                                <%= disponible ? "Disponible" : "No Disponible" %>
                                            </span>
                                        </div>
                                        
                                        <div class="vehicle-details">
                                            <p><strong>Marca:</strong> <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %></p>
                                            <p><strong>Modelo:</strong> <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %></p>
                                            <p><strong>Color:</strong> <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %></p>
                                            <p><strong>Año:</strong> <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></p>
                                            <p><strong>Kilometraje:</strong> <%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "N/A" %></p>
                                        </div>
                                        
                                        <div class="vehicle-client">
                                            <p><strong>Cliente:</strong> 
                                                <%= vehiculo.getIDCliente() != null ? 
                                                    vehiculo.getIDCliente().getNombre() + " " + vehiculo.getIDCliente().getApellido() : "N/A" %>
                                            </p>
                                            <p><strong>Teléfono:</strong> 
                                                <%= vehiculo.getIDCliente() != null && vehiculo.getIDCliente().getTelefono() != null ? 
                                                    vehiculo.getIDCliente().getTelefono() : "N/A" %>
                                            </p>
                                        </div>
                                        
                                        <% if (disponible) { %>
                                            <input type="radio" name="idVehiculo" value="<%= vehiculo.getIDVehiculo() %>" 
                                                   id="vehicle<%= vehiculo.getIDVehiculo() %>" style="display: none;">
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary" id="assignButton" disabled>
                                    🚗 Asignar Vehículo Seleccionado
                                </button>
                                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>" 
                                   class="btn btn-secondary">↩️ Cancelar</a>
                            </div>
                            
                        <% } else { %>
                            <div class="empty-state">
                                <div class="empty-icon">🚗</div>
                                <h3>No hay vehículos disponibles</h3>
                                <p>No se encontraron vehículos disponibles para asignar a esta orden.</p>
                                <a href="${pageContext.request.contextPath}/recepcionista/vehiculos/crear" class="btn btn-primary">
                                    ➕ Crear Nuevo Vehículo
                                </a>
                                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>" 
                                   class="btn btn-secondary">↩️ Volver</a>
                            </div>
                        <% } %>
                    </form>
                </div>
            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la orden solicitada.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">Volver a Órdenes</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        let selectedVehicleId = null;
        
        function selectVehicle(vehicleId) {
            // Deseleccionar todos los vehículos
            document.querySelectorAll('.vehicle-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            // Seleccionar el vehículo clickeado
            const selectedCard = document.querySelector(`.vehicle-card[onclick="selectVehicle(${vehicleId})"]`);
            if (selectedCard) {
                selectedCard.classList.add('selected');
                
                // Marcar el radio button
                const radioButton = document.getElementById(`vehicle${vehicleId}`);
                if (radioButton) {
                    radioButton.checked = true;
                }
                
                selectedVehicleId = vehicleId;
                document.getElementById('assignButton').disabled = false;
            }
        }
        
        // Validación del formulario
        document.getElementById('assignForm').addEventListener('submit', function(e) {
            if (!selectedVehicleId) {
                e.preventDefault();
                alert('Por favor seleccione un vehículo');
                return false;
            }
            
            return confirm('¿Está seguro de que desea asignar este vehículo a la orden?');
        });
        
        // Mensaje para vehículos no disponibles
        document.querySelectorAll('.vehicle-card.unavailable').forEach(card => {
            card.addEventListener('click', function() {
                alert('Este vehículo no está disponible para asignar en este momento.');
            });
        });
    </script>
</body>
</html>