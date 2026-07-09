<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Vehiculo, com.upec.model.Cliente" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión de recepcionista
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio cita = (OrdenServicio) request.getAttribute("cita");
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    
    boolean esNuevo = cita == null || cita.getIDOrdenServicio() == null;
    String titulo = esNuevo ? "Agendar Nueva Cita" : "Editar Cita";
    String action = esNuevo ? "crear" : "actualizar";
%>
<%!
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
    <title><%= titulo %> - Recepcionista</title>
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
                <p><%= esNuevo ? "Agendar nueva cita para un cliente" : "Editar información de la cita existente" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/recepcionista/citas/<%= action %>" method="post" class="crud-form" id="citaForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idOrdenServicio" value="<%= cita.getIDOrdenServicio() %>">
                    <% } %>

                    <!-- Selección de Cliente y Vehículo -->
                    <div class="client-vehicle-section">
                        <div class="form-section">
                            <h3>👤 Selección de Cliente</h3>
                            
                            <div class="form-group">
                                <label for="idCliente">Cliente *</label>
                                <select id="idCliente" name="idCliente" required class="form-control" onchange="cargarVehiculosCliente()">
                                    <option value="">Seleccione un cliente</option>
                                    <% if (clientes != null) { 
                                        for (Cliente cliente : clientes) { %>
                                        <option value="<%= cliente.getIDCliente() %>">
                                            <%= cliente.getNombre() %> <%= cliente.getApellido() %> 
                                            <% if (cliente.getEmail() != null) { %>
                                                - <%= cliente.getEmail() %>
                                            <% } %>
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Seleccione el cliente para la cita</small>
                            </div>

                            <!-- Información del Cliente -->
                            <div id="clientInfo" class="client-info-card" style="display: none;">
                                <h4>Información del Cliente</h4>
                                <div class="info-details">
                                    <p><strong>Nombre:</strong> <span id="infoNombre">-</span></p>
                                    <p><strong>Email:</strong> <span id="infoEmail">-</span></p>
                                    <p><strong>Teléfono:</strong> <span id="infoTelefono">-</span></p>
                                    <p><strong>Dirección:</strong> <span id="infoDireccion">-</span></p>
                                    <p><strong>Fecha Registro:</strong> <span id="infoRegistro">-</span></p>
                                </div>
                            </div>
                        </div>

                        <div class="form-section">
                            <h3>🚗 Selección de Vehículo</h3>
                            
                            <div class="form-group">
                                <label for="idVehiculo">Vehículo *</label>
                                <select id="idVehiculo" name="idVehiculo" required class="form-control" onchange="mostrarInfoVehiculo()">
                                    <option value="">Primero seleccione un cliente</option>
                                </select>
                                <small class="form-text">Seleccione el vehículo para el servicio</small>
                            </div>

                            <!-- Información del Vehículo -->
                            <div id="vehicleInfo" class="vehicle-info-card" style="display: none;">
                                <h4>Información del Vehículo</h4>
                                <div class="info-details">
                                    <p><strong>Placa:</strong> <span id="infoPlaca">-</span></p>
                                    <p><strong>Marca/Modelo:</strong> <span id="infoMarcaModelo">-</span></p>
                                    <p><strong>Color:</strong> <span id="infoColor">-</span></p>
                                    <p><strong>Año:</strong> <span id="infoAnio">-</span></p>
                                    <p><strong>Kilometraje:</strong> <span id="infoKilometraje">-</span> km</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Información de la Cita -->
                    <div class="form-section full-width">
                        <h3>📅 Información de la Cita</h3>
                        
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="fechaEntrada">Fecha de Entrada *</label>
                                <input type="datetime-local" id="fechaEntrada" name="fechaEntrada" 
                                       value="<%= cita != null && cita.getFechaEntrada() != null ? 
                                               formatDateForInput(cita.getFechaEntrada()) + "T08:00" : "" %>" 
                                       required class="form-control">
                                <small class="form-text">Fecha y hora programada para la cita</small>
                            </div>

                            <div class="form-group">
                                <label for="fechaEstimadaSalida">Fecha Estimada de Salida</label>
                                <input type="date" id="fechaEstimadaSalida" name="fechaEstimadaSalida" 
                                       value="<%= cita != null && cita.getFechaEstimadaSalida() != null ? 
                                               formatDateForInput(cita.getFechaEstimadaSalida()) : "" %>" 
                                       class="form-control">
                                <small class="form-text">Fecha estimada para la entrega del vehículo</small>
                            </div>

                            <div class="form-group">
                                <label for="prioridad">Prioridad</label>
                                <select id="prioridad" name="prioridad" class="form-control">
                                    <option value="baja">Baja</option>
                                    <option value="media" selected>Media</option>
                                    <option value="alta">Alta</option>
                                </select>
                                <small class="form-text">Nivel de prioridad del servicio</small>
                            </div>
                        </div>
                    </div>

                    <!-- Descripción del Servicio -->
                    <div class="form-section full-width">
                        <h3>🔧 Descripción del Servicio</h3>
                        
                        <div class="form-group">
                            <label for="problemaReportado">Problema Reportado *</label>
                            <textarea id="problemaReportado" name="problemaReportado" 
                                      rows="4" required class="form-control" 
                                      placeholder="Descripción detallada del problema reportado por el cliente..."><%= cita != null && cita.getProblemaReportado() != null ? cita.getProblemaReportado() : "" %></textarea>
                            <small class="form-text">Describa el problema o servicio requerido</small>
                        </div>

                        <div class="form-group">
                            <label for="observaciones">Observaciones Internas</label>
                            <textarea id="observaciones" name="observaciones" 
                                      rows="3" class="form-control" 
                                      placeholder="Observaciones internas para el equipo de trabajo..."><%= cita != null && cita.getObservaciones() != null ? cita.getObservaciones() : "" %></textarea>
                            <small class="form-text">Información adicional para mecánicos y personal interno</small>
                        </div>
                    </div>

                    <!-- Servicios Sugeridos -->
                    <div class="form-section full-width">
                        <h3>🛠️ Tipo de Servicio</h3>
                        <div class="service-types">
                            <div class="form-check">
                                <input type="radio" id="tipoMantenimiento" name="tipoServicio" value="mantenimiento" class="form-check-input" checked>
                                <label for="tipoMantenimiento" class="form-check-label">
                                    <strong>Mantenimiento Preventivo</strong>
                                    <span>Cambio de aceite, filtros, revisión general</span>
                                </label>
                            </div>
                            <div class="form-check">
                                <input type="radio" id="tipoReparacion" name="tipoServicio" value="reparacion" class="form-check-input">
                                <label for="tipoReparacion" class="form-check-label">
                                    <strong>Reparación Correctiva</strong>
                                    <span>Reparación de fallas específicas</span>
                                </label>
                            </div>
                            <div class="form-check">
                                <input type="radio" id="tipoDiagnostico" name="tipoServicio" value="diagnostico" class="form-check-input">
                                <label for="tipoDiagnostico" class="form-check-label">
                                    <strong>Diagnóstico</strong>
                                    <span>Solo diagnóstico del problema</span>
                                </label>
                            </div>
                            <div class="form-check">
                                <input type="radio" id="tipoOtro" name="tipoServicio" value="otro" class="form-check-input">
                                <label for="tipoOtro" class="form-check-label">
                                    <strong>Otro Servicio</strong>
                                    <span>Lavado, detailing, etc.</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "📅 Agendar Cita" : "💾 Actualizar Cita" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/citas" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                        <% if (!esNuevo) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/citas/ver?id=<%= cita.getIDOrdenServicio() %>" 
                               class="btn btn-info">👁️ Ver Detalles</a>
                        <% } %>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Datos de clientes y vehículos
        const clientesData = {
            <% if (clientes != null) { 
                for (Cliente cliente : clientes) { %>
                    <%= cliente.getIDCliente() %>: {
                        nombre: '<%= cliente.getNombre() %>',
                        apellido: '<%= cliente.getApellido() %>',
                        email: '<%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %>',
                        telefono: '<%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %>',
                        direccion: '<%= cliente.getDireccion() != null ? cliente.getDireccion() : "N/A" %>',
                        fechaRegistro: '<%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %>'
                    },
            <% } } %>
        };

        const vehiculosData = {
            <% if (vehiculos != null) { 
                for (Vehiculo vehiculo : vehiculos) { %>
                    <%= vehiculo.getIDVehiculo() %>: {
                        placa: '<%= vehiculo.getPlaca() %>',
                        marca: '<%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %>',
                        modelo: '<%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>',
                        color: '<%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %>',
                        anio: '<%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %>',
                        kilometraje: '<%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : "N/A" %>',
                        idCliente: <%= vehiculo.getIDCliente().getIDCliente() %>
                    },
            <% } } %>
        };

        function cargarVehiculosCliente() {
            const idCliente = document.getElementById('idCliente').value;
            const vehiculoSelect = document.getElementById('idVehiculo');
            const clientInfo = document.getElementById('clientInfo');
            
            // Limpiar select de vehículos
            vehiculoSelect.innerHTML = '<option value="">Seleccione un vehículo</option>';
            
            if (idCliente) {
                // Mostrar información del cliente
                const cliente = clientesData[idCliente];
                if (cliente) {
                    document.getElementById('infoNombre').textContent = cliente.nombre + ' ' + cliente.apellido;
                    document.getElementById('infoEmail').textContent = cliente.email;
                    document.getElementById('infoTelefono').textContent = cliente.telefono;
                    document.getElementById('infoDireccion').textContent = cliente.direccion;
                    document.getElementById('infoRegistro').textContent = cliente.fechaRegistro;
                    clientInfo.style.display = 'block';
                }
                
                // Cargar vehículos del cliente
                for (const [idVehiculo, vehiculo] of Object.entries(vehiculosData)) {
                    if (vehiculo.idCliente == idCliente) {
                        const option = document.createElement('option');
                        option.value = idVehiculo;
                        option.textContent = vehiculo.placa + ' - ' + vehiculo.marca + ' ' + vehiculo.modelo;
                        option.dataset.info = JSON.stringify(vehiculo);
                        vehiculoSelect.appendChild(option);
                    }
                }
                
                // Ocultar info de vehículo
                document.getElementById('vehicleInfo').style.display = 'none';
            } else {
                clientInfo.style.display = 'none';
                document.getElementById('vehicleInfo').style.display = 'none';
            }
        }

        function mostrarInfoVehiculo() {
            const vehiculoSelect = document.getElementById('idVehiculo');
            const vehicleInfo = document.getElementById('vehicleInfo');
            
            if (vehiculoSelect.value) {
                const selectedOption = vehiculoSelect.options[vehiculoSelect.selectedIndex];
                const vehiculo = JSON.parse(selectedOption.dataset.info);
                
                document.getElementById('infoPlaca').textContent = vehiculo.placa;
                document.getElementById('infoMarcaModelo').textContent = vehiculo.marca + ' ' + vehiculo.modelo;
                document.getElementById('infoColor').textContent = vehiculo.color;
                document.getElementById('infoAnio').textContent = vehiculo.anio;
                document.getElementById('infoKilometraje').textContent = vehiculo.kilometraje;
                
                vehicleInfo.style.display = 'block';
            } else {
                vehicleInfo.style.display = 'none';
            }
        }

        // Validación del formulario
        document.getElementById('citaForm').addEventListener('submit', function(e) {
            const cliente = document.getElementById('idCliente').value;
            const vehiculo = document.getElementById('idVehiculo').value;
            const fecha = document.getElementById('fechaEntrada').value;
            const problema = document.getElementById('problemaReportado').value.trim();

            if (!cliente) {
                e.preventDefault();
                alert('Por favor seleccione un cliente');
                document.getElementById('idCliente').focus();
                return false;
            }

            if (!vehiculo) {
                e.preventDefault();
                alert('Por favor seleccione un vehículo');
                document.getElementById('idVehiculo').focus();
                return false;
            }

            if (!fecha) {
                e.preventDefault();
                alert('Por favor seleccione una fecha y hora');
                document.getElementById('fechaEntrada').focus();
                return false;
            }

            if (!problema) {
                e.preventDefault();
                alert('Por favor describa el problema o servicio requerido');
                document.getElementById('problemaReportado').focus();
                return false;
            }

            return confirm('¿Está seguro de que desea <%= esNuevo ? "agendar" : "actualizar" %> esta cita?');
        });

        // Inicializar si hay datos previos
        window.addEventListener('load', function() {
            <% if (cita != null && cita.getIDVehiculo() != null && cita.getIDVehiculo().getIDCliente() != null) { %>
                // Seleccionar cliente y vehículo si estamos editando
                const idCliente = <%= cita.getIDVehiculo().getIDCliente().getIDCliente() %>;
                const idVehiculo = <%= cita.getIDVehiculo().getIDVehiculo() %>;
                
                document.getElementById('idCliente').value = idCliente;
                cargarVehiculosCliente();
                
                // Esperar a que se carguen los vehículos
                setTimeout(() => {
                    document.getElementById('idVehiculo').value = idVehiculo;
                    mostrarInfoVehiculo();
                }, 100);
            <% } %>
        });
    </script>
</body>
</html>