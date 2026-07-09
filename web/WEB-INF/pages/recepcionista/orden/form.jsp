<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Vehiculo, com.upec.model.EstadoTrabajo" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    List<EstadoTrabajo> estados = (List<EstadoTrabajo>) request.getAttribute("estados");
    
    boolean esNuevo = orden == null || orden.getIDOrdenServicio() == null;
    String titulo = esNuevo ? "Crear Nueva Orden" : "Editar Orden";
    String action = esNuevo ? "crear" : "editar";
%>
<%!
    // Método para formatear fecha para input
    public String formatDateForInput(java.util.Date date) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(date);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %></title>
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
                <p><%= esNuevo ? "Crea una nueva orden de servicio para un vehículo" : "Modifica la información de la orden" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/recepcionista/ordenes/<%= action %>" method="post" class="crud-form" id="ordenForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                    <% } %>

                    <div class="form-grid">
                        <div class="form-section">
                            <h3>🚗 Información del Vehículo</h3>
                            
                            <div class="form-group">
                                <label for="idVehiculo">Vehículo *</label>
                                <select id="idVehiculo" name="idVehiculo" required class="form-control">
                                    <option value="">Seleccione un vehículo</option>
                                    <% if (vehiculos != null) { 
                                        for (Vehiculo vehiculo : vehiculos) { %>
                                        <option value="<%= vehiculo.getIDVehiculo() %>" 
                                                data-marca="<%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %>"
                                                data-modelo="<%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>"
                                                data-color="<%= vehiculo.getColor() != null ? vehiculo.getColor() : "" %>"
                                                data-anio="<%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "" %>"
                                                data-cliente="<%= vehiculo.getIDCliente() != null ? 
                                                    vehiculo.getIDCliente().getNombre() + " " + vehiculo.getIDCliente().getApellido() : "" %>"
                                                <%= (orden != null && orden.getIDVehiculo() != null && 
                                                    orden.getIDVehiculo().getIDVehiculo().equals(vehiculo.getIDVehiculo())) ? "selected" : "" %>>
                                            <%= vehiculo.getPlaca() %> - <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %> 
                                            <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>
                                            (<%= vehiculo.getIDCliente() != null ? 
                                                vehiculo.getIDCliente().getNombre() + " " + vehiculo.getIDCliente().getApellido() : "Sin cliente" %>)
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Selecciona el vehículo que necesita servicio</small>
                            </div>

                            <!-- Información del Vehículo Seleccionado -->
                            <div id="vehicleInfo" class="vehicle-info-card" style="display: none;">
                                <h4>Información del Vehículo</h4>
                                <div class="vehicle-details">
                                    <p><strong>Cliente:</strong> <span id="infoCliente">-</span></p>
                                    <p><strong>Marca:</strong> <span id="infoMarca">-</span></p>
                                    <p><strong>Modelo:</strong> <span id="infoModelo">-</span></p>
                                    <p><strong>Color:</strong> <span id="infoColor">-</span></p>
                                    <p><strong>Año:</strong> <span id="infoAnio">-</span></p>
                                </div>
                            </div>
                        </div>

                        <div class="form-section">
                            <h3>📅 Información de la Orden</h3>
                            
                            <div class="form-group">
                                <label for="idEstadoTrabajo">Estado *</label>
                                <select id="idEstadoTrabajo" name="idEstadoTrabajo" required class="form-control">
                                    <option value="">Seleccione un estado</option>
                                    <% if (estados != null) { 
                                        for (EstadoTrabajo estado : estados) { %>
                                        <option value="<%= estado.getIDEstadoTrabajo() %>"
                                                <%= (orden != null && orden.getIDEstadoTrabajo() != null && 
                                                    orden.getIDEstadoTrabajo().getIDEstadoTrabajo().equals(estado.getIDEstadoTrabajo())) ? "selected" : "" %>>
                                            <%= estado.getNombreEstado() %>
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Estado actual de la orden</small>
                            </div>

                            <div class="form-group">
                                <label for="fechaEstimadaSalida">Fecha Estimada de Entrega</label>
                                <input type="date" id="fechaEstimadaSalida" name="fechaEstimadaSalida" 
                                       value="<%= orden != null && orden.getFechaEstimadaSalida() != null ? 
                                               formatDateForInput(orden.getFechaEstimadaSalida()) : "" %>" 
                                       class="form-control">
                                <small class="form-text">Fecha aproximada en que estará listo el vehículo</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-section full-width">
                        <h3>🔧 Descripción del Servicio</h3>
                        
                        <div class="form-group">
                            <label for="problemaReportado">Problema Reportado *</label>
                            <textarea id="problemaReportado" name="problemaReportado" 
                                      rows="4" required class="form-control" 
                                      placeholder="Describe detalladamente el problema reportado por el cliente..."><%= orden != null && orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "" %></textarea>
                            <small class="form-text">Describe con el mayor detalle posible el problema reportado</small>
                        </div>

                        <div class="form-group">
                            <label for="observaciones">Observaciones Internas</label>
                            <textarea id="observaciones" name="observaciones" 
                                      rows="3" class="form-control" 
                                      placeholder="Observaciones internas del recepcionista..."><%= orden != null && orden.getObservaciones() != null ? orden.getObservaciones() : "" %></textarea>
                            <small class="form-text">Observaciones para el equipo de mecánicos</small>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "💾 Crear Orden" : "💾 Actualizar Orden" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Actualizar información del vehículo cuando se selecciona
        document.getElementById('idVehiculo').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const vehicleInfo = document.getElementById('vehicleInfo');
            
            if (this.value) {
                vehicleInfo.style.display = 'block';
                document.getElementById('infoCliente').textContent = selectedOption.dataset.cliente || '-';
                document.getElementById('infoMarca').textContent = selectedOption.dataset.marca || '-';
                document.getElementById('infoModelo').textContent = selectedOption.dataset.modelo || '-';
                document.getElementById('infoColor').textContent = selectedOption.dataset.color || '-';
                document.getElementById('infoAnio').textContent = selectedOption.dataset.anio || '-';
            } else {
                vehicleInfo.style.display = 'none';
            }
        });

        // Validación del formulario
        document.getElementById('ordenForm').addEventListener('submit', function(e) {
            const vehiculo = document.getElementById('idVehiculo').value;
            const estado = document.getElementById('idEstadoTrabajo').value;
            const problema = document.getElementById('problemaReportado').value.trim();

            if (!vehiculo) {
                e.preventDefault();
                alert('Por favor seleccione un vehículo');
                document.getElementById('idVehiculo').focus();
                return false;
            }

            if (!estado) {
                e.preventDefault();
                alert('Por favor seleccione un estado');
                document.getElementById('idEstadoTrabajo').focus();
                return false;
            }

            if (!problema) {
                e.preventDefault();
                alert('Por favor describa el problema reportado');
                document.getElementById('problemaReportado').focus();
                return false;
            }

            return confirm('¿Está seguro de que desea <%= esNuevo ? "crear" : "actualizar" %> esta orden?');
        });

        // Inicializar si hay datos previos
        window.addEventListener('load', function() {
            const vehiculoSelect = document.getElementById('idVehiculo');
            if (vehiculoSelect.value) {
                vehiculoSelect.dispatchEvent(new Event('change'));
            }
        });
    </script>
</body>
</html>