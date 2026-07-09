<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenesAsignadas = (List<OrdenServicio>) request.getAttribute("ordenesAsignadas");
%>
<%!
    public String getCurrentDate() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new java.util.Date());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Horas - Mecánico</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
      <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudmecanico.css">
   
</head>
<body class="mecanico">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-mecanico.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>⏱️ Registrar Horas Trabajadas</h1>
                <p>Registra las horas dedicadas a las órdenes de servicio asignadas</p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/mecanico/horas/registrar" method="post" class="crud-form" id="registroForm">
                    <!-- Selección de Orden -->
                    <div class="order-selection">
                        <h3>🔧 Seleccionar Orden de Servicio</h3>
                        <div class="form-group">
                            <label for="idOrdenServicio">Orden de Servicio *</label>
                            <select id="idOrdenServicio" name="idOrdenServicio" required class="form-control">
                                <option value="">Seleccione una orden</option>
                                <% if (ordenesAsignadas != null) { 
                                    for (OrdenServicio orden : ordenesAsignadas) { %>
                                    <option value="<%= orden.getIDOrdenServicio() %>"
                                            data-placa="<%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "" %>"
                                            data-marca="<%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %>"
                                            data-modelo="<%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>"
                                            data-problema="<%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "" %>"
                                            data-fecha-entrada="<%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "" %>">
                                        Orden #<%= orden.getIDOrdenServicio() %> - 
                                        <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %> - 
                                        <%= orden.getProblemaReportado() != null && orden.getProblemaReportado().length() > 30 ? 
                                            orden.getProblemaReportado().substring(0, 30) + "..." : 
                                            (orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "N/A") %>
                                    </option>
                                <% } } %>
                            </select>
                            <small class="form-text">Selecciona la orden de servicio en la que trabajaste</small>
                        </div>

                        <!-- Información de la Orden Seleccionada -->
                        <div id="orderInfo" class="order-info">
                            <h4>Información de la Orden</h4>
                            <div class="order-details">
                                <div class="detail-item">
                                    <strong>Vehículo:</strong>
                                    <span id="infoVehiculo">-</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Marca/Modelo:</strong>
                                    <span id="infoMarcaModelo">-</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Problema:</strong>
                                    <span id="infoProblema">-</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha Entrada:</strong>
                                    <span id="infoFechaEntrada">-</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Registro de Horas -->
                    <div class="form-section">
                        <h3>⏰ Registro de Horas</h3>
                        
                        <div class="form-group">
                            <label for="fechaTrabajo">Fecha del Trabajo *</label>
                            <input type="date" id="fechaTrabajo" name="fechaTrabajo" 
                                   value="<%= getCurrentDate() %>" required class="form-control">
                            <small class="form-text">Fecha en la que realizaste el trabajo</small>
                        </div>

                        <div class="form-group">
                            <label for="horasTrabajadas">Horas Trabajadas *</label>
                            <div class="hours-input-group">
                                <input type="number" id="horasTrabajadas" name="horasTrabajadas" 
                                       min="0.5" max="24" step="0.5" required 
                                       class="form-control hours-input" placeholder="0.0">
                                <span>horas</span>
                            </div>
                            <small class="form-text">Ingresa las horas trabajadas (mínimo 0.5, máximo 24)</small>
                            
                            <!-- Sugerencias rápidas -->
                            <div class="hours-suggestions">
                                <button type="button" class="suggestion-btn" data-hours="1">1 hora</button>
                                <button type="button" class="suggestion-btn" data-hours="2">2 horas</button>
                                <button type="button" class="suggestion-btn" data-hours="4">4 horas</button>
                                <button type="button" class="suggestion-btn" data-hours="8">8 horas</button>
                                <button type="button" class="suggestion-btn" data-hours="0.5">30 min</button>
                                <button type="button" class="suggestion-btn" data-hours="1.5">1.5 horas</button>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="descripcionTrabajo">Descripción del Trabajo Realizado *</label>
                            <textarea id="descripcionTrabajo" name="descripcionTrabajo" 
                                      rows="4" required class="form-control work-description"
                                      placeholder="Describe detalladamente el trabajo que realizaste..."></textarea>
                            <small class="form-text">Incluye detalles específicos de las reparaciones o servicios realizados</small>
                        </div>
                    </div>

                    <!-- Confirmación -->
                    <div class="confirmation-card">
                        <h3>📋 Resumen del Registro</h3>
                        <div class="confirmation-item">
                            <strong>Orden:</strong>
                            <span id="confOrden">Seleccione una orden</span>
                        </div>
                        <div class="confirmation-item">
                            <strong>Fecha:</strong>
                            <span id="confFecha"><%= getCurrentDate() %></span>
                        </div>
                        <div class="confirmation-item">
                            <strong>Horas:</strong>
                            <span id="confHoras">0.0 horas</span>
                        </div>
                        <div class="confirmation-item">
                            <strong>Trabajo:</strong>
                            <span id="confTrabajo">Describa el trabajo</span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            💾 Registrar Horas
                        </button>
                        <a href="${pageContext.request.contextPath}/mecanico/horas" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>

            <!-- Información Adicional -->
            <div class="additional-info" style="margin-top: 30px;">
                <h3>ℹ️ Instrucciones para el Registro</h3>
                <div class="info-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                    <div class="info-item">
                        <h4>⏱️ Precisión en Horas</h4>
                        <ul>
                            <li>Registra solo el tiempo real trabajado</li>
                            <li>Usa decimales para medias horas (0.5)</li>
                            <li>No incluyes tiempos de descanso</li>
                            <li>Registra inmediatamente después de terminar</li>
                        </ul>
                    </div>
                    <div class="info-item">
                        <h4>📝 Descripción Detallada</h4>
                        <ul>
                            <li>Describe todas las tareas realizadas</li>
                            <li>Incluye piezas reemplazadas</li>
                            <li>Menciona problemas encontrados</li>
                            <li>Detalla pruebas realizadas</li>
                        </ul>
                    </div>
                    <div class="info-item">
                        <h4>✅ Buenas Prácticas</h4>
                        <ul>
                            <li>Registra diariamente tu trabajo</li>
                            <li>Revisa la orden antes de registrar</li>
                            <li>Verifica que la información sea correcta</li>
                            <li>Comunica variaciones significativas</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Actualizar información de la orden seleccionada
        document.getElementById('idOrdenServicio').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const orderInfo = document.getElementById('orderInfo');
            
            if (this.value) {
                orderInfo.style.display = 'block';
                document.getElementById('infoVehiculo').textContent = selectedOption.dataset.placa || '-';
                document.getElementById('infoMarcaModelo').textContent = 
                    (selectedOption.dataset.marca || '') + ' ' + (selectedOption.dataset.modelo || '');
                document.getElementById('infoProblema').textContent = selectedOption.dataset.problema || '-';
                document.getElementById('infoFechaEntrada').textContent = selectedOption.dataset.fechaEntrada || '-';
                
                // Actualizar resumen
                document.getElementById('confOrden').textContent = 'Orden #' + this.value;
            } else {
                orderInfo.style.display = 'none';
                document.getElementById('confOrden').textContent = 'Seleccione una orden';
            }
        });

        // Sugerencias rápidas de horas
        document.querySelectorAll('.suggestion-btn').forEach(button => {
            button.addEventListener('click', function() {
                const hours = this.getAttribute('data-hours');
                document.getElementById('horasTrabajadas').value = hours;
                document.getElementById('horasTrabajadas').dispatchEvent(new Event('input'));
            });
        });

        // Actualizar resumen de horas
        document.getElementById('horasTrabajadas').addEventListener('input', function() {
            document.getElementById('confHoras').textContent = this.value + ' horas';
        });

        // Actualizar resumen de fecha
        document.getElementById('fechaTrabajo').addEventListener('change', function() {
            document.getElementById('confFecha').textContent = this.value;
        });

        // Actualizar resumen de trabajo
        document.getElementById('descripcionTrabajo').addEventListener('input', function() {
            const texto = this.value.trim();
            document.getElementById('confTrabajo').textContent = 
                texto.length > 50 ? texto.substring(0, 50) + '...' : texto || 'Describa el trabajo';
        });

        // Validación del formulario
        document.getElementById('registroForm').addEventListener('submit', function(e) {
            const orden = document.getElementById('idOrdenServicio').value;
            const horas = document.getElementById('horasTrabajadas').value;
            const descripcion = document.getElementById('descripcionTrabajo').value.trim();

            if (!orden) {
                e.preventDefault();
                alert('Por favor seleccione una orden de servicio');
                document.getElementById('idOrdenServicio').focus();
                return false;
            }

            if (!horas || parseFloat(horas) <= 0) {
                e.preventDefault();
                alert('Por favor ingrese un número válido de horas trabajadas');
                document.getElementById('horasTrabajadas').focus();
                return false;
            }

            if (!descripcion) {
                e.preventDefault();
                alert('Por favor describa el trabajo realizado');
                document.getElementById('descripcionTrabajo').focus();
                return false;
            }

            return confirm('¿Está seguro de registrar ' + horas + ' horas para esta orden?');
        });

        // Inicializar
        window.addEventListener('load', function() {
            const horasInput = document.getElementById('horasTrabajadas');
            if (horasInput.value) {
                horasInput.dispatchEvent(new Event('input'));
            }
            
            const fechaInput = document.getElementById('fechaTrabajo');
            if (fechaInput.value) {
                fechaInput.dispatchEvent(new Event('change'));
            }
        });
    </script>
</body>
</html>