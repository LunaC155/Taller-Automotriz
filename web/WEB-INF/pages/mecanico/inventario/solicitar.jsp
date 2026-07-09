<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Repuesto, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Repuesto> repuestosDisponibles = (List<Repuesto>) request.getAttribute("repuestosDisponibles");
    Repuesto repuestoSeleccionado = (Repuesto) request.getAttribute("repuestoSeleccionado");
    
    Integer idMecanico = (Integer) session.getAttribute("idEmpleado");
    String nombreMecanico = (String) session.getAttribute("nombreUsuario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitar Repuesto - Taller Automotriz</title>
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
                <h1>📋 Solicitar Repuesto</h1>
                <p>Completa el formulario para solicitar repuestos del inventario</p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/mecanico/inventario/solicitar" method="post" class="crud-form" id="solicitudForm">
                    <div class="form-grid">
                        <!-- Selección de Repuesto -->
                        <div class="form-section">
                            <h3>🔧 Selección de Repuesto</h3>
                            
                            <div class="form-group">
                                <label for="idRepuesto">Repuesto Solicitado *</label>
                                <select id="idRepuesto" name="idRepuesto" required class="form-control">
                                    <option value="">Seleccione un repuesto</option>
                                    <% if (repuestosDisponibles != null) { 
                                        for (Repuesto repuesto : repuestosDisponibles) { %>
                                        <option value="<%= repuesto.getIDRepuesto() %>" 
                                                data-stock="<%= repuesto.getStock() != null ? repuesto.getStock() : 0 %>"
                                                data-minimo="<%= repuesto.getStockMinimo() != null ? repuesto.getStockMinimo() : 0 %>"
                                                data-precio="<%= repuesto.getPrecioCompra() != null ? repuesto.getPrecioCompra() : 0 %>"
                                                <%= (repuestoSeleccionado != null && 
                                                     repuestoSeleccionado.getIDRepuesto().equals(repuesto.getIDRepuesto())) ? "selected" : "" %>>
                                            <%= repuesto.getNombreRepuesto() %> 
                                            (Stock: <%= repuesto.getStock() != null ? repuesto.getStock() : 0 %>)
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Seleccione el repuesto que necesita solicitar</small>
                            </div>

                            <!-- Información del Repuesto Seleccionado -->
                            <div id="repuestoInfo" class="repuesto-info" style="display: none;">
                                <h4>Información del Repuesto</h4>
                                <div class="repuesto-details">
                                    <div class="detail-box">
                                        <div class="detail-value" id="infoStock">-</div>
                                        <div class="detail-label">Stock Actual</div>
                                    </div>
                                    <div class="detail-box">
                                        <div class="detail-value" id="infoMinimo">-</div>
                                        <div class="detail-label">Stock Mínimo</div>
                                    </div>
                                    <div class="detail-box">
                                        <div class="detail-value" id="infoPrecio">-</div>
                                        <div class="detail-label">Precio Unitario</div>
                                    </div>
                                </div>
                                
                                <!-- Alertas de Stock -->
                                <div id="stockAlerts"></div>
                            </div>
                        </div>

                        <!-- Información de la Solicitud -->
                        <div class="form-section">
                            <h3>📝 Detalles de la Solicitud</h3>
                            
                            <div class="form-group">
                                <label for="cantidad">Cantidad Requerida *</label>
                                <input type="number" id="cantidad" name="cantidad" 
                                       min="1" max="100" value="1" required 
                                       class="form-control">
                                <small class="form-text">Ingrese la cantidad de unidades que necesita</small>
                            </div>

                            <div class="form-group">
                                <label for="urgencia">Nivel de Urgencia *</label>
                                <select id="urgencia" name="urgencia" required class="form-control">
                                    <option value="baja">Baja</option>
                                    <option value="normal" selected>Normal</option>
                                    <option value="alta">Alta</option>
                                    <option value="critica">Crítica</option>
                                </select>
                                <small class="form-text">Seleccione la urgencia de esta solicitud</small>
                            </div>

                            <div class="form-group">
                                <label for="fechaRequerida">Fecha Requerida</label>
                                <input type="date" id="fechaRequerida" name="fechaRequerida" 
                                       class="form-control" 
                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                                <small class="form-text">Fecha en la que necesita el repuesto</small>
                            </div>
                        </div>

                        <!-- Información Adicional -->
                        <div class="form-section full-width">
                            <h3>📋 Información Adicional</h3>
                            
                            <div class="form-group">
                                <label for="justificacion">Justificación de la Solicitud *</label>
                                <textarea id="justificacion" name="justificacion" 
                                          rows="4" required class="form-control" 
                                          placeholder="Describa por qué necesita este repuesto, para qué vehículo o servicio será utilizado..."></textarea>
                                <small class="form-text">Explique detalladamente el uso que le dará al repuesto</small>
                            </div>

                            <div class="form-group">
                                <label for="observaciones">Observaciones Adicionales</label>
                                <textarea id="observaciones" name="observaciones" 
                                          rows="3" class="form-control" 
                                          placeholder="Cualquier información adicional que considere importante..."></textarea>
                                <small class="form-text">Información adicional sobre la solicitud</small>
                            </div>
                        </div>
                    </div>

                    <!-- Información del Solicitante -->
                    <div class="form-section full-width">
                        <h3>👤 Información del Solicitante</h3>
                        <div class="repuesto-info">
                            <div class="repuesto-details">
                                <div class="detail-box">
                                    <div class="detail-value"><%= idMecanico != null ? idMecanico : "N/A" %></div>
                                    <div class="detail-label">ID Mecánico</div>
                                </div>
                                <div class="detail-box">
                                    <div class="detail-value"><%= nombreMecanico != null ? nombreMecanico : "No disponible" %></div>
                                    <div class="detail-label">Nombre</div>
                                </div>
                                <div class="detail-box">
                                    <div class="detail-value"><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></div>
                                    <div class="detail-label">Fecha de Solicitud</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Resumen de la Solicitud -->
                    <div class="summary-card">
                        <h3>📊 Resumen de la Solicitud</h3>
                        <div class="summary-item">
                            <span>Repuesto:</span>
                            <span id="resumenRepuesto">Seleccione un repuesto</span>
                        </div>
                        <div class="summary-item">
                            <span>Cantidad:</span>
                            <span id="resumenCantidad">1 unidad</span>
                        </div>
                        <div class="summary-item">
                            <span>Urgencia:</span>
                            <span id="resumenUrgencia">Normal</span>
                        </div>
                        <div class="summary-item">
                            <span>Stock Disponible:</span>
                            <span id="resumenStock">-</span>
                        </div>
                        <div class="summary-item summary-total">
                            <span>Disponibilidad:</span>
                            <span id="resumenDisponibilidad">Verifique disponibilidad</span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            📋 Enviar Solicitud
                        </button>
                        <button type="button" id="btnVerificarDisponibilidad" class="btn btn-info">
                            🔍 Verificar Disponibilidad
                        </button>
                        <a href="${pageContext.request.contextPath}/mecanico/inventario" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>

            <!-- Información Importante -->
            <div class="additional-info" style="margin-top: 30px;">
                <div class="info-card">
                    <h4>ℹ️ Información Importante</h4>
                    <ul>
                        <li><strong>Solicitudes Normales:</strong> Serán procesadas dentro de las 24 horas hábiles</li>
                        <li><strong>Solicitudes Urgentes:</strong> Serán procesadas inmediatamente si hay stock disponible</li>
                        <li><strong>Stock Insuficiente:</strong> Las solicitudes quedarán pendientes hasta nuevo stock</li>
                        <li><strong>Verificación:</strong> Siempre verifique la disponibilidad antes de enviar la solicitud</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Actualizar información cuando se selecciona un repuesto
        document.getElementById('idRepuesto').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const repuestoInfo = document.getElementById('repuestoInfo');
            const stockAlerts = document.getElementById('stockAlerts');
            
            if (this.value) {
                repuestoInfo.style.display = 'block';
                
                const stock = parseInt(selectedOption.dataset.stock);
                const minimo = parseInt(selectedOption.dataset.minimo);
                const precio = parseFloat(selectedOption.dataset.precio);
                
                // Actualizar información básica
                document.getElementById('infoStock').textContent = stock;
                document.getElementById('infoMinimo').textContent = minimo || 'N/A';
                document.getElementById('infoPrecio').textContent = precio ? '$' + precio.toFixed(2) : 'N/A';
                
                // Actualizar resumen
                document.getElementById('resumenRepuesto').textContent = selectedOption.text;
                document.getElementById('resumenStock').textContent = stock + ' unidades';
                
                // Generar alertas de stock
                stockAlerts.innerHTML = '';
                if (stock === 0) {
                    stockAlerts.innerHTML = '<div class="stock-critical">🚨 <strong>STOCK AGOTADO:</strong> Este repuesto no está disponible actualmente. La solicitud quedará pendiente.</div>';
                    document.getElementById('resumenDisponibilidad').innerHTML = '<span style="color: #dc3545;">❌ NO DISPONIBLE</span>';
                } else if (minimo && stock <= minimo / 2) {
                    stockAlerts.innerHTML = '<div class="stock-critical">⚠️ <strong>STOCK CRÍTICO:</strong> Solo quedan ' + stock + ' unidades. Considere solicitar con urgencia.</div>';
                    document.getElementById('resumenDisponibilidad').innerHTML = '<span style="color: #dc3545;">⚠️ STOCK CRÍTICO</span>';
                } else if (minimo && stock <= minimo) {
                    stockAlerts.innerHTML = '<div class="stock-warning">⚠️ <strong>STOCK BAJO:</strong> El stock está por debajo del mínimo. Quedan ' + stock + ' unidades.</div>';
                    document.getElementById('resumenDisponibilidad').innerHTML = '<span style="color: #ffc107;">⚠️ STOCK BAJO</span>';
                } else {
                    stockAlerts.innerHTML = '<div class="availability-check">✅ <strong>STOCK DISPONIBLE:</strong> Hay ' + stock + ' unidades en inventario.</div>';
                    document.getElementById('resumenDisponibilidad').innerHTML = '<span style="color: #28a745;">✅ DISPONIBLE</span>';
                }
                
                // Actualizar cantidad máxima
                document.getElementById('cantidad').max = stock;
                
            } else {
                repuestoInfo.style.display = 'none';
                document.getElementById('resumenRepuesto').textContent = 'Seleccione un repuesto';
                document.getElementById('resumenStock').textContent = '-';
                document.getElementById('resumenDisponibilidad').textContent = 'Verifique disponibilidad';
            }
        });

        // Actualizar resumen cuando cambia la cantidad
        document.getElementById('cantidad').addEventListener('input', function() {
            const cantidad = parseInt(this.value);
            document.getElementById('resumenCantidad').textContent = cantidad + ' unidad(es)';
            
            // Verificar disponibilidad en tiempo real
            const selectedOption = document.getElementById('idRepuesto').options[document.getElementById('idRepuesto').selectedIndex];
            if (selectedOption && selectedOption.value) {
                const stock = parseInt(selectedOption.dataset.stock);
                if (cantidad > stock) {
                    document.getElementById('resumenDisponibilidad').innerHTML = '<span style="color: #dc3545;">❌ STOCK INSUFICIENTE</span>';
                } else {
                    document.getElementById('resumenDisponibilidad').innerHTML = '<span style="color: #28a745;">✅ DISPONIBLE</span>';
                }
            }
        });

        // Actualizar resumen cuando cambia la urgencia
        document.getElementById('urgencia').addEventListener('change', function() {
            const urgenciaText = this.options[this.selectedIndex].text;
            document.getElementById('resumenUrgencia').textContent = urgenciaText;
        });

        // Verificar disponibilidad
        document.getElementById('btnVerificarDisponibilidad').addEventListener('click', function() {
            const idRepuesto = document.getElementById('idRepuesto').value;
            const cantidad = document.getElementById('cantidad').value;
            
            if (!idRepuesto) {
                alert('Por favor seleccione un repuesto primero');
                return;
            }
            
            if (!cantidad || cantidad < 1) {
                alert('Por favor ingrese una cantidad válida');
                return;
            }
            
            // Redirigir a la página de verificación de disponibilidad
            window.location.href = '${pageContext.request.contextPath}/mecanico/inventario/disponibilidad?idRepuesto=' + idRepuesto + '&cantidad=' + cantidad;
        });

        // Validación del formulario
        document.getElementById('solicitudForm').addEventListener('submit', function(e) {
            const idRepuesto = document.getElementById('idRepuesto').value;
            const cantidad = document.getElementById('cantidad').value;
            const justificacion = document.getElementById('justificacion').value.trim();
            
            if (!idRepuesto) {
                e.preventDefault();
                alert('Por favor seleccione un repuesto');
                document.getElementById('idRepuesto').focus();
                return false;
            }
            
            if (!cantidad || cantidad < 1) {
                e.preventDefault();
                alert('Por favor ingrese una cantidad válida');
                document.getElementById('cantidad').focus();
                return false;
            }
            
            if (!justificacion) {
                e.preventDefault();
                alert('Por favor ingrese la justificación de la solicitud');
                document.getElementById('justificacion').focus();
                return false;
            }
            
            return confirm('¿Está seguro de que desea enviar esta solicitud?');
        });

        // Inicializar si hay repuesto seleccionado
        window.addEventListener('load', function() {
            const repuestoSelect = document.getElementById('idRepuesto');
            if (repuestoSelect.value) {
                repuestoSelect.dispatchEvent(new Event('change'));
            }
            
            // Establecer fecha mínima para fecha requerida (hoy)
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('fechaRequerida').min = today;
        });
    </script>
</body>
</html>