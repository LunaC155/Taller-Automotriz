<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Generar Reporte Técnico - Taller Automotriz</title>
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
                <h1>🔧 Generar Reporte Técnico</h1>
                <p>Documenta el diagnóstico y recomendaciones para la orden de servicio</p>
            </div>

            <% if (error != null) { %>
                <div class="alert alert-danger">
                    <strong>Error:</strong> <%= error %>
                </div>
            <% } %>

            <div class="report-form-container">
                <form action="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/generar" method="post" class="crud-form" id="reporteForm">
                    
                    <!-- Selección de Orden de Servicio -->
                    <div class="form-section">
                        <h3>📋 Seleccionar Orden de Servicio</h3>
                        
                        <div class="form-group">
                            <label for="idOrdenServicio">Orden de Servicio *</label>
                            <select id="idOrdenServicio" name="idOrdenServicio" required class="form-control">
                                <option value="">Seleccione una orden de servicio</option>
                                <% if (ordenes != null) { 
                                    for (OrdenServicio orden : ordenes) { %>
                                        <option value="<%= orden.getIDOrdenServicio() %>"
                                                data-problema="<%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "" %>"
                                                data-vehiculo="<%= orden.getIDVehiculo() != null ? 
                                                    orden.getIDVehiculo().getPlaca() + " - " + 
                                                    (orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                                    (orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "" %>"
                                                data-cliente="<%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null ? 
                                                    orden.getIDVehiculo().getIDCliente().getNombre() + " " + 
                                                    orden.getIDVehiculo().getIDCliente().getApellido() : "" %>"
                                                data-fecha="<%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "" %>">
                                            Orden #<%= orden.getIDOrdenServicio() %> - 
                                            <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %> - 
                                            <%= orden.getProblemaReportado() != null && orden.getProblemaReportado().length() > 50 ? 
                                                orden.getProblemaReportado().substring(0, 50) + "..." : 
                                                (orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "Sin descripción") %>
                                        </option>
                                <% } } %>
                            </select>
                            <small class="form-text">Seleccione la orden de servicio para la cual está generando el reporte</small>
                        </div>

                        <!-- Información de la Orden Seleccionada -->
                        <div id="orderInfo" class="order-info-card" style="display: none;">
                            <h4>Información de la Orden Seleccionada</h4>
                            <div class="order-details">
                                <div class="order-detail-item">
                                    <strong>Vehículo:</strong>
                                    <span id="infoVehiculo">-</span>
                                </div>
                                <div class="order-detail-item">
                                    <strong>Cliente:</strong>
                                    <span id="infoCliente">-</span>
                                </div>
                                <div class="order-detail-item">
                                    <strong>Fecha Entrada:</strong>
                                    <span id="infoFecha">-</span>
                                </div>
                                <div class="order-detail-item">
                                    <strong>Problema Reportado:</strong>
                                    <span id="infoProblema">-</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Diagnóstico Técnico -->
                    <div class="form-section">
                        <h3>🔍 Diagnóstico Técnico</h3>
                        
                        <div class="form-group">
                            <label for="descripcionDiagnostico">Descripción del Diagnóstico *</label>
                            <textarea id="descripcionDiagnostico" name="descripcionDiagnostico" 
                                      class="form-control diagnostico-textarea" 
                                      rows="8" required
                                      placeholder="Describa detalladamente el diagnóstico técnico realizado. Incluya:
• Problemas encontrados
• Componentes revisados
• Pruebas realizadas
• Resultados de las pruebas
• Causa raíz identificada"></textarea>
                            <small class="form-text">
                                Describa de manera técnica y detallada el diagnóstico. Sea específico sobre los problemas encontrados.
                            </small>
                        </div>

                        <div class="form-group">
                            <label for="recomendaciones">Recomendaciones y Observaciones</label>
                            <textarea id="recomendaciones" name="recomendaciones" 
                                      class="form-control recomendaciones-textarea" 
                                      rows="5"
                                      placeholder="Incluya recomendaciones como:
• Reparaciones necesarias
• Partes a reemplazar
• Mantenimiento preventivo recomendado
• Observaciones importantes para el cliente"></textarea>
                            <small class="form-text">
                                Recomendaciones técnicas y observaciones importantes para el cliente y el recepcionista.
                            </small>
                        </div>
                    </div>

                    <!-- Vista Previa -->
                    <div class="form-preview">
                        <h3>👁️ Vista Previa del Reporte</h3>
                        
                        <div class="preview-section">
                            <h4>Diagnóstico:</h4>
                            <div id="previewDiagnostico" class="preview-content">
                                <em>El diagnóstico aparecerá aquí...</em>
                            </div>
                        </div>
                        
                        <div class="preview-section">
                            <h4>Recomendaciones:</h4>
                            <div id="previewRecomendaciones" class="preview-content">
                                <em>Las recomendaciones aparecerán aquí...</em>
                            </div>
                        </div>
                    </div>

                    <!-- Acciones del Formulario -->
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            📄 Generar Reporte Técnico
                        </button>
                        <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/mis-reportes" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                        <button type="button" id="btnLimpiar" class="btn btn-outline-secondary">
                            🗑️ Limpiar Formulario
                        </button>
                    </div>
                </form>
            </div>

            <!-- Información de Ayuda -->
            <div class="additional-info" style="margin-top: 30px;">
                <h3>💡 Consejos para un Buen Reporte Técnico</h3>
                <div class="info-cards" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
                    <div class="info-card" style="background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;">
                        <h4>📝 Estructura Recomendada</h4>
                        <ul>
                            <li>Problema principal identificado</li>
                            <li>Síntomas observados</li>
                            <li>Pruebas realizadas</li>
                            <li>Componentes afectados</li>
                            <li>Causa raíz del problema</li>
                        </ul>
                    </div>
                    <div class="info-card" style="background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;">
                        <h4>🔧 Lenguaje Técnico</h4>
                        <ul>
                            <li>Use terminología técnica apropiada</li>
                            <li>Sea específico con códigos de error</li>
                            <li>Mencione valores de mediciones</li>
                            <li>Incluya referencias a manuales técnicos</li>
                        </ul>
                    </div>
                    <div class="info-card" style="background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;">
                        <h4>⚠️ Consideraciones</h4>
                        <ul>
                            <li>Verifique la precisión de la información</li>
                            <li>Documente todos los hallazgos</li>
                            <li>Incluya recomendaciones de seguridad</li>
                            <li>Sea claro y conciso</li>
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
                document.getElementById('infoVehiculo').textContent = selectedOption.dataset.vehiculo || '-';
                document.getElementById('infoCliente').textContent = selectedOption.dataset.cliente || '-';
                document.getElementById('infoFecha').textContent = selectedOption.dataset.fecha || '-';
                document.getElementById('infoProblema').textContent = selectedOption.dataset.problema || '-';
            } else {
                orderInfo.style.display = 'none';
            }
        });

        // Actualizar vista previa en tiempo real
        document.getElementById('descripcionDiagnostico').addEventListener('input', function() {
            const preview = document.getElementById('previewDiagnostico');
            if (this.value.trim()) {
                preview.innerHTML = this.value.replace(/\n/g, '<br>');
            } else {
                preview.innerHTML = '<em>El diagnóstico aparecerá aquí...</em>';
            }
        });

        document.getElementById('recomendaciones').addEventListener('input', function() {
            const preview = document.getElementById('previewRecomendaciones');
            if (this.value.trim()) {
                preview.innerHTML = this.value.replace(/\n/g, '<br>');
            } else {
                preview.innerHTML = '<em>Las recomendaciones aparecerán aquí...</em>';
            }
        });

        // Limpiar formulario
        document.getElementById('btnLimpiar').addEventListener('click', function() {
            if (confirm('¿Está seguro de que desea limpiar todo el formulario? Se perderán todos los datos ingresados.')) {
                document.getElementById('reporteForm').reset();
                document.getElementById('orderInfo').style.display = 'none';
                document.getElementById('previewDiagnostico').innerHTML = '<em>El diagnóstico aparecerá aquí...</em>';
                document.getElementById('previewRecomendaciones').innerHTML = '<em>Las recomendaciones aparecerán aquí...</em>';
            }
        });

        // Validación del formulario
        document.getElementById('reporteForm').addEventListener('submit', function(e) {
            const orden = document.getElementById('idOrdenServicio').value;
            const diagnostico = document.getElementById('descripcionDiagnostico').value.trim();

            if (!orden) {
                e.preventDefault();
                alert('Por favor seleccione una orden de servicio');
                document.getElementById('idOrdenServicio').focus();
                return false;
            }

            if (!diagnostico) {
                e.preventDefault();
                alert('Por favor ingrese la descripción del diagnóstico');
                document.getElementById('descripcionDiagnostico').focus();
                return false;
            }

            if (diagnostico.length < 50) {
                if (!confirm('El diagnóstico parece muy breve. ¿Está seguro de que contiene suficiente información técnica?')) {
                    e.preventDefault();
                    document.getElementById('descripcionDiagnostico').focus();
                    return false;
                }
            }

            return confirm('¿Está seguro de que desea generar este reporte técnico? Esta acción no se puede deshacer.');
        });

        // Inicializar si hay datos previos
        window.addEventListener('load', function() {
            const ordenSelect = document.getElementById('idOrdenServicio');
            if (ordenSelect.value) {
                ordenSelect.dispatchEvent(new Event('change'));
            }
        });
    </script>
</body>
</html>