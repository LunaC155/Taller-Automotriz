<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Horas - Mecánico</title>
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
                <h1>📝 Justificar Horas Extra</h1>
                <p>Justifica horas adicionales trabajadas en órdenes de servicio</p>
            </div>

            <% if (orden != null) { %>
                <div class="form-container">
                    <!-- Información de la Orden -->
                    <div class="order-info-card">
                        <h3>🔧 Orden de Servicio #<%= orden.getIDOrdenServicio() %></h3>
                        <div class="order-details-grid">
                            <div class="detail-card">
                                <strong>Vehículo:</strong><br>
                                <%= orden.getIDVehiculo() != null ? 
                                    orden.getIDVehiculo().getPlaca() + " - " + 
                                    (orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                    (orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "N/A" %>
                            </div>
                            <div class="detail-card">
                                <strong>Problema:</strong><br>
                                <%= orden.getProblemaReportado() != null && orden.getProblemaReportado().length() > 50 ? 
                                    orden.getProblemaReportado().substring(0, 50) + "..." : 
                                    (orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "N/A") %>
                            </div>
                            <div class="detail-card">
                                <strong>Fecha Entrada:</strong><br>
                                <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %>
                            </div>
                            <div class="detail-card">
                                <strong>Estado:</strong><br>
                                <span class="badge <%= orden.getFechaRealSalida() != null ? "badge-success" : "badge-warning" %>">
                                    <%= orden.getFechaRealSalida() != null ? "Completada" : 
                                        (orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente") %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Alerta importante -->
                    <div class="warning-alert">
                        <strong>⚠️ Importante:</strong> 
                        Solo justifica horas extra cuando existan razones válidas como complicaciones técnicas, 
                        espera de repuestos, o situaciones imprevistas que hayan requerido tiempo adicional.
                    </div>

                    <form action="${pageContext.request.contextPath}/mecanico/horas/justificar" method="post" class="crud-form" id="justificacionForm">
                        <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">

                        <!-- Razones de Justificación -->
                        <div class="form-section">
                            <h3>📋 Selecciona la Razón Principal</h3>
                            <div class="justification-reasons">
                                <div class="reason-option" data-reason="complicacion">
                                    <span class="reason-icon">🔧</span>
                                    <strong>Complicación Técnica</strong>
                                    <p>Problemas técnicos no previstos durante la reparación</p>
                                </div>
                                <div class="reason-option" data-reason="repuestos">
                                    <span class="reason-icon">📦</span>
                                    <strong>Espera de Repuestos</strong>
                                    <p>Demora en la entrega de piezas o repuestos necesarios</p>
                                </div>
                                <div class="reason-option" data-reason="diagnostico">
                                    <span class="reason-icon">🔍</span>
                                    <strong>Diagnóstico Complejo</strong>
                                    <p>Problema requería diagnóstico más extenso de lo esperado</p>
                                </div>
                                <div class="reason-option" data-reason="otro">
                                    <span class="reason-icon">❓</span>
                                    <strong>Otra Razón</strong>
                                    <p>Otra situación que justifique las horas extra</p>
                                </div>
                            </div>
                            <input type="hidden" id="razonSeleccionada" name="razonSeleccionada">
                        </div>

                        <!-- Horas Extra -->
                        <div class="form-section">
                            <h3>⏰ Horas Extra a Justificar</h3>
                            <div class="form-group">
                                <label for="horasExtra">Horas Extra *</label>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <input type="number" id="horasExtra" name="horasExtra" 
                                           min="0.5" max="12" step="0.5" required 
                                           class="form-control hours-extra-input" placeholder="0.0">
                                    <span>horas</span>
                                </div>
                                <small class="form-text">Ingresa las horas extra trabajadas que necesitas justificar</small>
                                
                                <!-- Sugerencias rápidas -->
                                <div class="hours-suggestions" style="display: flex; gap: 10px; margin-top: 10px; flex-wrap: wrap;">
                                    <button type="button" class="suggestion-btn" data-hours="1">1 hora</button>
                                    <button type="button" class="suggestion-btn" data-hours="2">2 horas</button>
                                    <button type="button" class="suggestion-btn" data-hours="3">3 horas</button>
                                    <button type="button" class="suggestion-btn" data-hours="4">4 horas</button>
                                </div>
                            </div>
                        </div>

                        <!-- Descripción Detallada -->
                        <div class="form-section">
                            <h3>📝 Descripción Detallada</h3>
                            <div class="form-group">
                                <label for="justificacion">Justificación Detallada *</label>
                                <textarea id="justificacion" name="justificacion" 
                                          rows="5" required class="form-control justification-text"
                                          placeholder="Describe detalladamente por qué fueron necesarias las horas extra..."></textarea>
                                <small class="form-text">
                                    Incluye: problemas específicos encontrados, soluciones intentadas, 
                                    tiempo dedicado a cada tarea adicional, y cualquier información relevante.
                                </small>
                            </div>
                        </div>

                        <!-- Confirmación -->
                        <div class="confirmation-section">
                            <h3>📋 Resumen de la Justificación</h3>
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                                <div>
                                    <strong>Orden:</strong><br>
                                    #<%= orden.getIDOrdenServicio() %>
                                </div>
                                <div>
                                    <strong>Razón:</strong><br>
                                    <span id="confRazon">No seleccionada</span>
                                </div>
                                <div>
                                    <strong>Horas Extra:</strong><br>
                                    <span id="confHoras">0.0 horas</span>
                                </div>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-warning">
                                📝 Enviar Justificación
                            </button>
                            <a href="${pageContext.request.contextPath}/mecanico/horas" class="btn btn-secondary">
                                ↩️ Cancelar
                            </a>
                        </div>
                    </form>
                </div>

                <!-- Información Adicional -->
                <div class="additional-info" style="margin-top: 30px;">
                    <h3>ℹ️ Pautas para Justificación</h3>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                        <div>
                            <h4>✅ Justificaciones Aceptables</h4>
                            <ul>
                                <li>Complicaciones técnicas imprevistas</li>
                                <li>Espera de repuestos especiales</li>
                                <li>Diagnósticos complejos</li>
                                <li>Problemas de seguridad críticos</li>
                                <li>Fallas en equipos de diagnóstico</li>
                            </ul>
                        </div>
                        <div>
                            <h4>❌ Justificaciones No Aceptables</h4>
                            <ul>
                                <li>Falta de planificación</li>
                                <li>Errores del mecánico</li>
                                <li>Tiempos de descanso</li>
                                <li>Trabajos no autorizados</li>
                                <li>Horas no trabajadas realmente</li>
                            </ul>
                        </div>
                        <div>
                            <h4>📋 Proceso de Aprobación</h4>
                            <ul>
                                <li>Revisión por supervisor</li>
                                <li>Verificación con registros</li>
                                <li>Validación con cliente si es necesario</li>
                                <li>Aprobación final de gerencia</li>
                            </ul>
                        </div>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message" style="text-align: center; padding: 40px; background: #f8d7da; border-radius: 8px;">
                    <h3>❌ Orden No Encontrada</h3>
                    <p>No se pudo encontrar la orden de servicio especificada.</p>
                    <a href="${pageContext.request.contextPath}/mecanico/horas" class="btn btn-secondary">
                        Volver a Gestión de Horas
                    </a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Selección de razón
        document.querySelectorAll('.reason-option').forEach(option => {
            option.addEventListener('click', function() {
                // Remover selección anterior
                document.querySelectorAll('.reason-option').forEach(opt => {
                    opt.classList.remove('selected');
                });
                
                // Agregar selección actual
                this.classList.add('selected');
                
                // Actualizar campo oculto
                const reason = this.getAttribute('data-reason');
                document.getElementById('razonSeleccionada').value = reason;
                
                // Actualizar resumen
                const reasonText = this.querySelector('strong').textContent;
                document.getElementById('confRazon').textContent = reasonText;
            });
        });

        // Sugerencias rápidas de horas
        document.querySelectorAll('.suggestion-btn').forEach(button => {
            button.addEventListener('click', function() {
                const hours = this.getAttribute('data-hours');
                document.getElementById('horasExtra').value = hours;
                document.getElementById('horasExtra').dispatchEvent(new Event('input'));
            });
        });

        // Actualizar resumen de horas
        document.getElementById('horasExtra').addEventListener('input', function() {
            document.getElementById('confHoras').textContent = this.value + ' horas';
        });

        // Validación del formulario
        document.getElementById('justificacionForm').addEventListener('submit', function(e) {
            const razon = document.getElementById('razonSeleccionada').value;
            const horas = document.getElementById('horasExtra').value;
            const justificacion = document.getElementById('justificacion').value.trim();

            if (!razon) {
                e.preventDefault();
                alert('Por favor seleccione una razón para la justificación');
                return false;
            }

            if (!horas || parseFloat(horas) <= 0) {
                e.preventDefault();
                alert('Por favor ingrese un número válido de horas extra');
                document.getElementById('horasExtra').focus();
                return false;
            }

            if (!justificacion) {
                e.preventDefault();
                alert('Por favor describa detalladamente la justificación');
                document.getElementById('justificacion').focus();
                return false;
            }

            return confirm('¿Está seguro de enviar esta justificación de ' + horas + ' horas extra?');
        });

        // Inicializar
        window.addEventListener('load', function() {
            const horasInput = document.getElementById('horasExtra');
            if (horasInput.value) {
                horasInput.dispatchEvent(new Event('input'));
            }
        });
    </script>
</body>
</html>