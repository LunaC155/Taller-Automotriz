<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Vehiculo, com.upec.model.Empleado" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.Calendar" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio recepcion = (OrdenServicio) request.getAttribute("recepcion");
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    List<Empleado> mecanicos = (List<Empleado>) request.getAttribute("mecanicos");
    
    boolean esNuevo = recepcion == null || recepcion.getIDOrdenServicio() == null;
    String titulo = esNuevo ? "Registrar Nueva Recepción" : "Editar Recepción";
    String action = esNuevo ? "registrar" : "editar";
%>
<%!
    // Método para formatear fecha para input
    public String formatDateForInput(java.util.Date date) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(date);
    }
    
    // Método para obtener la fecha de mañana
    public String getTomorrowDate() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, 1);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(cal.getTime());
    }
    
    // Método para obtener la fecha en 3 días
    public String getThreeDaysLater() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, 3);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(cal.getTime());
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
                <p><%= esNuevo ? "Registra una nueva recepción de vehículo en el taller" : "Modifica la información de la recepción" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/recepcionista/recepcion/<%= action %>" method="post" class="crud-form" id="recepcionForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idOrdenServicio" value="<%= recepcion.getIDOrdenServicio() %>">
                    <% } %>

                    <div class="form-grid">
                        <div class="form-section">
                            <h3>🚗 Selección del Vehículo</h3>
                            
                            <div class="form-group">
                                <label for="idVehiculo">Vehículo *</label>
                                <select id="idVehiculo" name="idVehiculo" required class="form-control">
                                    <option value="">Seleccione un vehículo</option>
                                    <% if (vehiculos != null) { 
                                        for (Vehiculo vehiculo : vehiculos) { 
                                            boolean selected = false;
                                            if (!esNuevo && recepcion.getIDVehiculo() != null && 
                                                recepcion.getIDVehiculo().getIDVehiculo().equals(vehiculo.getIDVehiculo())) {
                                                selected = true;
                                            }
                                    %>
                                        <option value="<%= vehiculo.getIDVehiculo() %>" 
                                                data-marca="<%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %>"
                                                data-modelo="<%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>"
                                                data-color="<%= vehiculo.getColor() != null ? vehiculo.getColor() : "" %>"
                                                data-anio="<%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "" %>"
                                                data-kilometraje="<%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : "" %>"
                                                data-cliente="<%= vehiculo.getIDCliente() != null ? 
                                                    vehiculo.getIDCliente().getNombre() + " " + vehiculo.getIDCliente().getApellido() : "" %>"
                                                data-telefono="<%= vehiculo.getIDCliente() != null && vehiculo.getIDCliente().getTelefono() != null ? 
                                                    vehiculo.getIDCliente().getTelefono() : "" %>"
                                                data-email="<%= vehiculo.getIDCliente() != null && vehiculo.getIDCliente().getEmail() != null ? 
                                                    vehiculo.getIDCliente().getEmail() : "" %>"
                                                <%= selected ? "selected" : "" %>>
                                            <%= vehiculo.getPlaca() %> - <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %> 
                                            <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Selecciona el vehículo que ingresa al taller</small>
                            </div>

                            <!-- Información del Vehículo Seleccionado -->
                            <div id="vehicleInfo" class="vehicle-info-card" style="display: none;">
                                <h4>Información del Vehículo</h4>
                                <div class="vehicle-details">
                                    <p><strong>Marca:</strong> <span id="infoMarca">-</span></p>
                                    <p><strong>Modelo:</strong> <span id="infoModelo">-</span></p>
                                    <p><strong>Color:</strong> <span id="infoColor">-</span></p>
                                    <p><strong>Año:</strong> <span id="infoAnio">-</span></p>
                                    <p><strong>Kilometraje:</strong> <span id="infoKilometraje">-</span> km</p>
                                </div>
                            </div>

                            <!-- Información del Cliente -->
                            <div id="clientInfo" class="client-info-card" style="display: none;">
                                <h4>📋 Información del Cliente</h4>
                                <div class="client-details">
                                    <p><strong>Cliente:</strong> <span id="infoCliente">-</span></p>
                                    <p><strong>Teléfono:</strong> <span id="infoTelefono">-</span></p>
                                    <p><strong>Email:</strong> <span id="infoEmail">-</span></p>
                                </div>
                            </div>
                        </div>

                        <div class="form-section">
                            <h3>📅 Información de la Recepción</h3>
                            
                            <% if (esNuevo) { %>
                                <div class="form-group">
                                    <label for="fechaEntrada">Fecha de Entrada *</label>
                                    <input type="date" id="fechaEntrada" name="fechaEntrada" 
                                           value="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" 
                                           required class="form-control" readonly>
                                    <small class="form-text">Fecha actual del sistema</small>
                                </div>
                            <% } else { %>
                                <div class="form-group">
                                    <label>Fecha de Entrada</label>
                                    <input type="text" value="<%= recepcion.getFechaEntrada() != null ? 
                                        new SimpleDateFormat("dd/MM/yyyy HH:mm").format(recepcion.getFechaEntrada()) : "N/A" %>" 
                                        class="form-control" readonly>
                                    <small class="form-text">Fecha de registro original</small>
                                </div>
                            <% } %>

                            <div class="form-group">
                                <label for="fechaEstimadaSalida">Fecha Estimada de Salida *</label>
                                <input type="date" id="fechaEstimadaSalida" name="fechaEstimadaSalida" 
                                       value="<%= recepcion != null && recepcion.getFechaEstimadaSalida() != null ? 
                                               formatDateForInput(recepcion.getFechaEstimadaSalida()) : getThreeDaysLater() %>" 
                                       required class="form-control" min="<%= getTomorrowDate() %>">
                                <small class="form-text">Fecha aproximada en que estará listo el vehículo</small>
                            </div>

                            <div class="form-group">
                                <label for="idMecanico">Mecánico Asignado</label>
                                <select id="idMecanico" name="idMecanico" class="form-control">
                                    <option value="">Seleccione un mecánico</option>
                                    <% if (mecanicos != null) { 
                                        for (Empleado mecanico : mecanicos) { %>
                                        <option value="<%= mecanico.getIDEmpleado() %>">
                                            <%= mecanico.getNombre() %> <%= mecanico.getApellido() %>
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Asigna un mecánico para el diagnóstico (opcional)</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-section full-width">
                        <h3>🔧 Descripción del Servicio</h3>
                        
                        <div class="form-group">
                            <label for="problemaReportado">Problema Reportado por el Cliente *</label>
                            <textarea id="problemaReportado" name="problemaReportado" 
                                      rows="4" required class="form-control" 
                                      placeholder="Describe detalladamente el problema reportado por el cliente..."><%= recepcion != null && recepcion.getProblemaReportado() != null ? recepcion.getProblemaReportado() : "" %></textarea>
                            <small class="form-text">Describe con el mayor detalle posible el problema reportado</small>
                        </div>

                        <div class="form-group">
                            <label for="observaciones">Observaciones del Recepcionista</label>
                            <textarea id="observaciones" name="observaciones" 
                                      rows="3" class="form-control" 
                                      placeholder="Observaciones adicionales del recepcionista..."><%= recepcion != null && recepcion.getObservaciones() != null ? recepcion.getObservaciones() : "" %></textarea>
                            <small class="form-text">Observaciones, síntomas adicionales, comportamientos extraños del vehículo, etc.</small>
                        </div>
                    </div>

                    <!-- Servicios Sugeridos -->
                    <div class="form-section full-width">
                        <h3>💡 Servicios Sugeridos</h3>
                        <div class="service-suggestions">
                            <p><strong>Servicios comunes basados en el problema reportado:</strong></p>
                            <div class="suggestion-item">
                                <input type="checkbox" id="sugMantenimiento" name="serviciosSugeridos" value="mantenimiento">
                                <label for="sugMantenimiento">
                                    <strong>Mantenimiento Preventivo</strong><br>
                                    <span>Cambio de aceite, filtros y revisión general</span>
                                </label>
                            </div>
                            <div class="suggestion-item">
                                <input type="checkbox" id="sugFrenos" name="serviciosSugeridos" value="frenos">
                                <label for="sugFrenos">
                                    <strong>Revisión de Frenos</strong><br>
                                    <span>Pastillas, discos y líquido de frenos</span>
                                </label>
                            </div>
                            <div class="suggestion-item">
                                <input type="checkbox" id="sugAlineacion" name="serviciosSugeridos" value="alineacion">
                                <label for="sugAlineacion">
                                    <strong>Alineación y Balanceo</strong><br>
                                    <span>Alineación de dirección y balanceo de ruedas</span>
                                </label>
                            </div>
                            <div class="suggestion-item">
                                <input type="checkbox" id="sugElectrico" name="serviciosSugeridos" value="electrico">
                                <label for="sugElectrico">
                                    <strong>Sistema Eléctrico</strong><br>
                                    <span>Batería, alternador y sistema de carga</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Información de Confirmación -->
                    <div class="confirmation-info">
                        <h3>📋 Resumen de la Recepción</h3>
                        <div class="confirmation-details">
                            <div class="confirmation-item">
                                <strong>Vehículo:</strong> <span id="confVehiculo">Seleccione un vehículo</span>
                            </div>
                            <div class="confirmation-item">
                                <strong>Cliente:</strong> <span id="confCliente">-</span>
                            </div>
                            <div class="confirmation-item">
                                <strong>Fecha Entrada:</strong> <span id="confFechaEntrada"><%= new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
                            </div>
                            <div class="confirmation-item">
                                <strong>Fecha Estimada Salida:</strong> <span id="confFechaSalida"><%= getThreeDaysLater() %></span>
                            </div>
                            <div class="confirmation-item">
                                <strong>Problema:</strong> <span id="confProblema">Describa el problema</span>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "📝 Registrar Recepción" : "💾 Actualizar Recepción" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/recepcion" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>

            <!-- Información Adicional -->
            <div class="additional-info">
                <h3>ℹ️ Información Importante</h3>
                <div class="info-cards">
                    <div class="info-card">
                        <h4>📋 Proceso de Recepción</h4>
                        <ul>
                            <li>Verificar documentación del vehículo</li>
                            <li>Inspeccionar visualmente el vehículo</li>
                            <li>Documentar daños existentes</li>
                            <li>Recopilar información completa del problema</li>
                            <li>Establecer expectativas con el cliente</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>⏱️ Tiempos Estimados</h4>
                        <ul>
                            <li><strong>Diagnóstico básico:</strong> 1-2 horas</li>
                            <li><strong>Mantenimiento preventivo:</strong> 2-3 horas</li>
                            <li><strong>Reparaciones menores:</strong> 4-6 horas</li>
                            <li><strong>Reparaciones mayores:</strong> 1-2 días</li>
                            <li><strong>Diagnóstico complejo:</strong> 2-4 horas</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>📞 Comunicación</h4>
                        <p><strong>Con el cliente:</strong></p>
                        <ul>
                            <li>Confirmar información de contacto</li>
                            <li>Explicar el proceso de trabajo</li>
                            <li>Establecer método de comunicación</li>
                            <li>Informar sobre autorizaciones necesarias</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Actualizar información del vehículo cuando se selecciona
        document.getElementById('idVehiculo').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const vehicleInfo = document.getElementById('vehicleInfo');
            const clientInfo = document.getElementById('clientInfo');
            
            if (this.value) {
                vehicleInfo.style.display = 'block';
                clientInfo.style.display = 'block';
                
                // Actualizar información del vehículo
                document.getElementById('infoMarca').textContent = selectedOption.dataset.marca || '-';
                document.getElementById('infoModelo').textContent = selectedOption.dataset.modelo || '-';
                document.getElementById('infoColor').textContent = selectedOption.dataset.color || '-';
                document.getElementById('infoAnio').textContent = selectedOption.dataset.anio || '-';
                document.getElementById('infoKilometraje').textContent = selectedOption.dataset.kilometraje || '-';
                
                // Actualizar información del cliente
                document.getElementById('infoCliente').textContent = selectedOption.dataset.cliente || '-';
                document.getElementById('infoTelefono').textContent = selectedOption.dataset.telefono || '-';
                document.getElementById('infoEmail').textContent = selectedOption.dataset.email || '-';
                
                // Actualizar resumen
                document.getElementById('confVehiculo').textContent = selectedOption.text;
                document.getElementById('confCliente').textContent = selectedOption.dataset.cliente || '-';
            } else {
                vehicleInfo.style.display = 'none';
                clientInfo.style.display = 'none';
                document.getElementById('confVehiculo').textContent = 'Seleccione un vehículo';
                document.getElementById('confCliente').textContent = '-';
            }
        });

        // Actualizar resumen de fecha estimada de salida
        document.getElementById('fechaEstimadaSalida').addEventListener('change', function() {
            if (this.value) {
                const fecha = new Date(this.value + 'T00:00:00');
                document.getElementById('confFechaSalida').textContent = fecha.toLocaleDateString('es-ES', {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });
            }
        });

        // Actualizar resumen de problema
        document.getElementById('problemaReportado').addEventListener('input', function() {
            const texto = this.value.trim();
            document.getElementById('confProblema').textContent = texto || 'Describa el problema';
        });

        // Validación del formulario
        document.getElementById('recepcionForm').addEventListener('submit', function(e) {
            const vehiculo = document.getElementById('idVehiculo').value;
            const fechaSalida = document.getElementById('fechaEstimadaSalida').value;
            const problema = document.getElementById('problemaReportado').value.trim();

            if (!vehiculo) {
                e.preventDefault();
                alert('Por favor seleccione un vehículo');
                document.getElementById('idVehiculo').focus();
                return false;
            }

            if (!fechaSalida) {
                e.preventDefault();
                alert('Por favor seleccione una fecha estimada de salida');
                document.getElementById('fechaEstimadaSalida').focus();
                return false;
            }

            if (!problema) {
                e.preventDefault();
                alert('Por favor describa el problema reportado por el cliente');
                document.getElementById('problemaReportado').focus();
                return false;
            }

            return confirm('<%= esNuevo ? "¿Está seguro de que desea registrar esta recepción?" : "¿Está seguro de que desea actualizar esta recepción?" %>');
        });

        // Inicializar si hay datos previos
        window.addEventListener('load', function() {
            const vehiculoSelect = document.getElementById('idVehiculo');
            if (vehiculoSelect.value) {
                vehiculoSelect.dispatchEvent(new Event('change'));
            }
            
            const fechaSalidaInput = document.getElementById('fechaEstimadaSalida');
            if (fechaSalidaInput.value) {
                fechaSalidaInput.dispatchEvent(new Event('change'));
            }
            
            const problemaInput = document.getElementById('problemaReportado');
            if (problemaInput.value) {
                problemaInput.dispatchEvent(new Event('input'));
            }
        });
    </script>
</body>
</html>