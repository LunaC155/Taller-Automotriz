<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Vehiculo" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.Calendar" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 4) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio cita = (OrdenServicio) request.getAttribute("cita");
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
    
    boolean esNuevo = cita == null || cita.getIDOrdenServicio() == null;
    String titulo = esNuevo ? "Agendar Nueva Cita" : "Editar Cita";
    String action = esNuevo ? "crear" : "editar";
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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
    
</head>
<body class="cliente">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-cliente.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1><%= titulo %></h1>
                <p><%= esNuevo ? "Programa una nueva cita para el servicio de tu vehículo" : "Modifica la información de tu cita" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/CitaServlet?action=<%= action %>" method="post" class="crud-form" id="citaForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idOrdenServicio" value="<%= cita.getIDOrdenServicio() %>">
                    <% } %>

                    <div class="form-grid">
                        <div class="form-section">
                            <h3>🚗 Información del Vehículo</h3>
                            
                            <div class="form-group">
                                <label for="idVehiculo">Seleccionar Vehículo *</label>
                                <select id="idVehiculo" name="idVehiculo" required class="form-control">
                                    <option value="">Seleccione un vehículo</option>
                                    <% if (vehiculos != null) { 
                                        for (Vehiculo vehiculo : vehiculos) { %>
                                        <option value="<%= vehiculo.getIDVehiculo() %>" 
                                                data-marca="<%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %>"
                                                data-modelo="<%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>"
                                                data-color="<%= vehiculo.getColor() != null ? vehiculo.getColor() : "" %>"
                                                data-anio="<%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "" %>"
                                                data-kilometraje="<%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : "" %>"
                                                <%= (cita != null && cita.getIDVehiculo() != null && 
                                                    cita.getIDVehiculo().getIDVehiculo().equals(vehiculo.getIDVehiculo())) ? "selected" : "" %>>
                                            <%= vehiculo.getPlaca() %> - <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "" %> 
                                            <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "" %>
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Selecciona el vehículo que necesita servicio</small>
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
                        </div>

                        <div class="form-section">
                            <h3>📅 Información de la Cita</h3>
                            
                            <div class="form-group">
                                <label for="fechaEntrada">Fecha de la Cita *</label>
                                <input type="date" id="fechaEntrada" name="fechaEntrada" 
                                       value="<%= cita != null && cita.getFechaEntrada() != null ? 
                                               formatDateForInput(cita.getFechaEntrada()) : "" %>" 
                                       required class="form-control" min="<%= getTomorrowDate() %>">
                                <small class="form-text">Selecciona la fecha para tu cita (mínimo mañana)</small>
                            </div>

                            <div class="form-group">
                                <label for="fechaEstimadaSalida">Fecha Estimada de Entrega</label>
                                <input type="date" id="fechaEstimadaSalida" name="fechaEstimadaSalida" 
                                       value="<%= cita != null && cita.getFechaEstimadaSalida() != null ? 
                                               formatDateForInput(cita.getFechaEstimadaSalida()) : "" %>" 
                                       class="form-control" min="<%= getTomorrowDate() %>">
                                <small class="form-text">Fecha aproximada en que estará listo tu vehículo</small>
                            </div>

                            <div class="form-group">
                                <label for="horaPreferida">Hora Preferida</label>
                                <select id="horaPreferida" name="horaPreferida" class="form-control">
                                    <option value="">Selecciona una hora</option>
                                    <option value="08:00">8:00 AM</option>
                                    <option value="09:00">9:00 AM</option>
                                    <option value="10:00">10:00 AM</option>
                                    <option value="11:00">11:00 AM</option>
                                    <option value="12:00">12:00 PM</option>
                                    <option value="13:00">1:00 PM</option>
                                    <option value="14:00">2:00 PM</option>
                                    <option value="15:00">3:00 PM</option>
                                    <option value="16:00">4:00 PM</option>
                                    <option value="17:00">5:00 PM</option>
                                </select>
                                <small class="form-text">Horario de preferencia para tu cita</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-section full-width">
                        <h3>🔧 Descripción del Servicio</h3>
                        
                        <div class="form-group">
                            <label for="problemaReportado">Problema o Servicio Requerido *</label>
                            <textarea id="problemaReportado" name="problemaReportado" 
                                      rows="4" required class="form-control" 
                                      placeholder="Describe detalladamente el problema o servicio que necesitas..."><%= cita != null && cita.getProblemaReportado() != null ? cita.getProblemaReportado() : "" %></textarea>
                            <small class="form-text">Describe con el mayor detalle posible el problema o servicio que necesitas</small>
                        </div>

                        <div class="form-group">
                            <label for="observaciones">Observaciones Adicionales</label>
                            <textarea id="observaciones" name="observaciones" 
                                      rows="3" class="form-control" 
                                      placeholder="Cualquier información adicional que consideres importante..."><%= cita != null && cita.getObservaciones() != null ? cita.getObservaciones() : "" %></textarea>
                            <small class="form-text">Síntomas, sonidos, comportamientos extraños del vehículo, etc.</small>
                        </div>
                    </div>

                    <!-- Servicios Sugeridos -->
                    <div class="form-section full-width">
                        <h3>💡 Servicios Sugeridos</h3>
                        <div class="suggested-services">
                            <div class="service-suggestion">
                                <input type="checkbox" id="sugMantenimiento" name="serviciosSugeridos" value="mantenimiento">
                                <label for="sugMantenimiento">
                                    <strong>Mantenimiento Preventivo</strong>
                                    <span>Cambio de aceite, filtros y revisión general</span>
                                </label>
                            </div>
                            <div class="service-suggestion">
                                <input type="checkbox" id="sugFrenos" name="serviciosSugeridos" value="frenos">
                                <label for="sugFrenos">
                                    <strong>Revisión de Frenos</strong>
                                    <span>Pastillas, discos y líquido de frenos</span>
                                </label>
                            </div>
                            <div class="service-suggestion">
                                <input type="checkbox" id="sugAlineacion" name="serviciosSugeridos" value="alineacion">
                                <label for="sugAlineacion">
                                    <strong>Alineación y Balanceo</strong>
                                    <span>Alineación de dirección y balanceo de ruedas</span>
                                </label>
                            </div>
                            <div class="service-suggestion">
                                <input type="checkbox" id="sugElectrico" name="serviciosSugeridos" value="electrico">
                                <label for="sugElectrico">
                                    <strong>Sistema Eléctrico</strong>
                                    <span>Batería, alternador y sistema de carga</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Información de Confirmación -->
                    <div class="confirmation-info">
                        <h3>📋 Resumen de la Cita</h3>
                        <div class="confirmation-details">
                            <p><strong>Vehículo:</strong> <span id="confVehiculo">Seleccione un vehículo</span></p>
                            <p><strong>Fecha:</strong> <span id="confFecha">Seleccione una fecha</span></p>
                            <p><strong>Hora:</strong> <span id="confHora">Seleccione una hora</span></p>
                            <p><strong>Servicio:</strong> <span id="confServicio">Describa el servicio</span></p>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "📅 Agendar Cita" : "💾 Actualizar Cita" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/cliente/citas/mis-citas" class="btn btn-secondary">
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
                        <h4>🕒 Preparación para la Cita</h4>
                        <ul>
                            <li>Llega 15 minutos antes de tu cita programada</li>
                            <li>Trae tu vehículo limpio por dentro y por fuera</li>
                            <li>Ten a mano la documentación del vehículo</li>
                            <li>Prepara una lista de los problemas que has notado</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>⏱️ Tiempos de Espera</h4>
                        <ul>
                            <li><strong>Mantenimiento básico:</strong> 2-3 horas</li>
                            <li><strong>Reparaciones menores:</strong> 4-6 horas</li>
                            <li><strong>Reparaciones mayores:</strong> 1-2 días</li>
                            <li><strong>Diagnóstico complejo:</strong> 2-4 horas</li>
                        </ul>
                    </div>
                    <div class="info-card">
                        <h4>📞 Contacto</h4>
                        <p>Si necesitas modificar o cancelar tu cita:</p>
                        <p><strong>Teléfono:</strong> (04) 234-5678</p>
                        <p><strong>Email:</strong> citas@tallerautomotriz.com</p>
                        <p><strong>Horario:</strong> Lunes a Viernes 8:00-18:00</p>
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
            
            if (this.value) {
                vehicleInfo.style.display = 'block';
                document.getElementById('infoMarca').textContent = selectedOption.dataset.marca || '-';
                document.getElementById('infoModelo').textContent = selectedOption.dataset.modelo || '-';
                document.getElementById('infoColor').textContent = selectedOption.dataset.color || '-';
                document.getElementById('infoAnio').textContent = selectedOption.dataset.anio || '-';
                document.getElementById('infoKilometraje').textContent = selectedOption.dataset.kilometraje || '-';
                
                // Actualizar resumen
                document.getElementById('confVehiculo').textContent = selectedOption.text;
            } else {
                vehicleInfo.style.display = 'none';
                document.getElementById('confVehiculo').textContent = 'Seleccione un vehículo';
            }
        });

        // Actualizar resumen de fecha
        document.getElementById('fechaEntrada').addEventListener('change', function() {
            if (this.value) {
                const fecha = new Date(this.value + 'T00:00:00');
                document.getElementById('confFecha').textContent = fecha.toLocaleDateString('es-ES', {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });
            } else {
                document.getElementById('confFecha').textContent = 'Seleccione una fecha';
            }
        });

        // Actualizar resumen de hora
        document.getElementById('horaPreferida').addEventListener('change', function() {
            document.getElementById('confHora').textContent = this.value || 'Seleccione una hora';
        });

        // Actualizar resumen de servicio
        document.getElementById('problemaReportado').addEventListener('input', function() {
            const texto = this.value.trim();
            document.getElementById('confServicio').textContent = texto || 'Describa el servicio';
        });

        // Validación del formulario
        document.getElementById('citaForm').addEventListener('submit', function(e) {
            const vehiculo = document.getElementById('idVehiculo').value;
            const fecha = document.getElementById('fechaEntrada').value;
            const problema = document.getElementById('problemaReportado').value.trim();

            if (!vehiculo) {
                e.preventDefault();
                alert('Por favor seleccione un vehículo');
                document.getElementById('idVehiculo').focus();
                return false;
            }

            if (!fecha) {
                e.preventDefault();
                alert('Por favor seleccione una fecha');
                document.getElementById('fechaEntrada').focus();
                return false;
            }

            if (!problema) {
                e.preventDefault();
                alert('Por favor describa el problema o servicio requerido');
                document.getElementById('problemaReportado').focus();
                return false;
            }

            return confirm('¿Está seguro de que desea agendar esta cita?');
        });

        // Inicializar si hay datos previos
        window.addEventListener('load', function() {
            const vehiculoSelect = document.getElementById('idVehiculo');
            if (vehiculoSelect.value) {
                vehiculoSelect.dispatchEvent(new Event('change'));
            }
            
            const fechaInput = document.getElementById('fechaEntrada');
            if (fechaInput.value) {
                fechaInput.dispatchEvent(new Event('change'));
            }
            
            const horaInput = document.getElementById('horaPreferida');
            if (horaInput.value) {
                horaInput.dispatchEvent(new Event('change'));
            }
            
            const problemaInput = document.getElementById('problemaReportado');
            if (problemaInput.value) {
                problemaInput.dispatchEvent(new Event('input'));
            }
        });
    </script>
</body>
</html>