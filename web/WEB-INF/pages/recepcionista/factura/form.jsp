<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Factura, com.upec.model.OrdenServicio, com.upec.model.EstadoFactura" %>
<%@page import="java.util.List, java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Factura factura = (Factura) request.getAttribute("factura");
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    List<EstadoFactura> estados = (List<EstadoFactura>) request.getAttribute("estados");
    String numeroFactura = (String) request.getAttribute("numeroFactura");
    
    boolean esNuevo = factura == null || factura.getIDFactura() == null;
    String titulo = esNuevo ? "Generar Nueva Factura" : "Editar Factura";
    String action = esNuevo ? "generar" : "editar";
%>
<%!
    // Método para formatear moneda
    public String formatMoneda(java.math.BigDecimal monto) {
        if (monto == null) return "0.00";
        return String.format("%,.2f", monto);
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
                <p><%= esNuevo ? "Genera una nueva factura para una orden de servicio" : "Modifica la información de la factura" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/recepcionista/facturas/<%= action %>" method="post" class="crud-form" id="facturaForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idFactura" value="<%= factura.getIDFactura() %>">
                    <% } %>

                    <div class="form-grid">
                        <!-- Información Básica -->
                        <div class="form-section">
                            <h3>📋 Información Básica</h3>
                            
                            <div class="form-group">
                                <label for="numeroFactura">Número de Factura *</label>
                                <input type="text" id="numeroFactura" name="numeroFactura" 
                                       value="<%= factura != null && factura.getNumeroFactura() != null ? 
                                               factura.getNumeroFactura() : (numeroFactura != null ? numeroFactura : "") %>" 
                                       required class="form-control" placeholder="Ej: FACT-000001">
                                <small class="form-text">Número único de identificación de la factura</small>
                            </div>

                            <div class="form-group">
                                <label for="idOrdenServicio">Orden de Servicio *</label>
                                <select id="idOrdenServicio" name="idOrdenServicio" required class="form-control" 
                                        <%= !esNuevo ? "disabled" : "" %>>
                                    <option value="">Seleccione una orden</option>
                                    <% if (ordenes != null) { 
                                        for (OrdenServicio orden : ordenes) { %>
                                        <option value="<%= orden.getIDOrdenServicio() %>" 
                                                data-problema="<%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "" %>"
                                                data-cliente="<%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null ? 
                                                    orden.getIDVehiculo().getIDCliente().getNombre() + " " + orden.getIDVehiculo().getIDCliente().getApellido() : "" %>"
                                                data-vehiculo="<%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "" %>"
                                                <%= (factura != null && factura.getIDOrdenServicio() != null && 
                                                    factura.getIDOrdenServicio().getIDOrdenServicio().equals(orden.getIDOrdenServicio())) ? "selected" : "" %>>
                                            Orden #<%= orden.getIDOrdenServicio() %> - 
                                            <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %>
                                        </option>
                                    <% } } %>
                                </select>
                                <small class="form-text">Seleccione la orden de servicio a facturar</small>
                            </div>

                            <div class="form-group">
                                <label for="idEstadoFactura">Estado de Factura *</label>
                                <select id="idEstadoFactura" name="idEstadoFactura" required class="form-control">
                                    <option value="">Seleccione un estado</option>
                                    <% if (estados != null) { 
                                        for (EstadoFactura estado : estados) { %>
                                        <option value="<%= estado.getIDEstadoFactura() %>"
                                                <%= (factura != null && factura.getIDEstadoFactura() != null && 
                                                    factura.getIDEstadoFactura().getIDEstadoFactura().equals(estado.getIDEstadoFactura())) ? "selected" : "" %>>
                                            <%= estado.getNombreEstado() %>
                                        </option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>

                        <!-- Información de la Orden -->
                        <div class="form-section">
                            <h3>📦 Información de la Orden</h3>
                            
                            <div id="orderInfo" class="order-info-card" style="display: none;">
                                <h4>Detalles de la Orden</h4>
                                <div class="order-details">
                                    <p><strong>Cliente:</strong> <span id="infoCliente">-</span></p>
                                    <p><strong>Vehículo:</strong> <span id="infoVehiculo">-</span></p>
                                    <p><strong>Problema Reportado:</strong> <span id="infoProblema">-</span></p>
                                    <p><strong>Fecha Entrada:</strong> <span id="infoFechaEntrada">-</span></p>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="fechaEmision">Fecha de Emisión</label>
                                <input type="date" id="fechaEmision" name="fechaEmision" 
                                       value="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" 
                                       class="form-control" readonly>
                                <small class="form-text">Fecha actual del sistema</small>
                            </div>
                        </div>
                    </div>

                    <!-- Cálculos de la Factura -->
                    <div class="form-section full-width">
                        <h3>💰 Cálculos de la Factura</h3>
                        
                        <div class="calculations-section">
                            <div class="form-group">
                                <label for="subtotal">Subtotal *</label>
                                <input type="number" id="subtotal" name="subtotal" 
                                       value="<%= factura != null && factura.getSubtotal() != null ? 
                                               formatMoneda(factura.getSubtotal()) : "0.00" %>" 
                                       step="0.01" min="0" required class="form-control monto-input" 
                                       onchange="calcularTotales()">
                                <small class="form-text">Monto base antes de impuestos</small>
                            </div>

                            <div class="form-group">
                                <label>Porcentaje de IVA</label>
                                <div class="iva-options">
                                    <div class="iva-option" data-iva="0.12" onclick="seleccionarIVA(0.12)">
                                        12%
                                    </div>
                                    <div class="iva-option" data-iva="0.14" onclick="seleccionarIVA(0.14)">
                                        14%
                                    </div>
                                    <div class="iva-option" data-iva="0.16" onclick="seleccionarIVA(0.16)">
                                        16%
                                    </div>
                                    <div class="iva-option" data-iva="0.19" onclick="seleccionarIVA(0.19)">
                                        19%
                                    </div>
                                    <div class="iva-option" data-iva="0.00" onclick="seleccionarIVA(0.00)">
                                        Exento
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="iva">IVA</label>
                                <input type="number" id="iva" name="iva" 
                                       value="<%= factura != null && factura.getIva() != null ? 
                                               formatMoneda(factura.getIva()) : "0.00" %>" 
                                       step="0.01" min="0" readonly class="form-control monto-input">
                            </div>

                            <div class="form-group">
                                <label for="total">Total *</label>
                                <input type="number" id="total" name="total" 
                                       value="<%= factura != null && factura.getTotal() != null ? 
                                               formatMoneda(factura.getTotal()) : "0.00" %>" 
                                       step="0.01" min="0" required class="form-control monto-input" readonly>
                            </div>

                            <!-- Resumen de Cálculos -->
                            <div class="calculation-summary">
                                <div class="calculation-row">
                                    <span>Subtotal:</span>
                                    <span id="resumenSubtotal">$0.00</span>
                                </div>
                                <div class="calculation-row">
                                    <span>IVA (<span id="porcentajeIVA">0%</span>):</span>
                                    <span id="resumenIVA">$0.00</span>
                                </div>
                                <div class="calculation-row total">
                                    <span>TOTAL:</span>
                                    <span id="resumenTotal">$0.00</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Vista Previa -->
                    <div class="preview-section">
                        <h3>👁️ Vista Previa</h3>
                        <div id="vistaPrevia">
                            <p><strong>Número:</strong> <span id="previewNumero"><%= factura != null && factura.getNumeroFactura() != null ? 
                                factura.getNumeroFactura() : (numeroFactura != null ? numeroFactura : "") %></span></p>
                            <p><strong>Orden:</strong> <span id="previewOrden">Seleccione una orden</span></p>
                            <p><strong>Cliente:</strong> <span id="previewCliente">-</span></p>
                            <p><strong>Total:</strong> <span id="previewTotal">$0.00</span></p>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "🧾 Generar Factura" : "💾 Actualizar Factura" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                        
                        <% if (!esNuevo) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/ver?id=<%= factura.getIDFactura() %>" 
                               class="btn btn-info">👁️ Ver Factura</a>
                        <% } %>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        let porcentajeIVA = 0.19; // Por defecto 19%
        
        // Inicializar IVA por defecto
        document.addEventListener('DOMContentLoaded', function() {
            seleccionarIVA(porcentajeIVA);
            calcularTotales();
            
            // Si hay una factura existente, calcular el porcentaje de IVA
            <% if (factura != null && factura.getSubtotal() != null && factura.getIva() != null && 
                   factura.getSubtotal().doubleValue() > 0) { 
                double ivaCalculado = factura.getIva().doubleValue() / factura.getSubtotal().doubleValue();
            %>
                porcentajeIVA = <%= ivaCalculado %>;
                seleccionarIVA(porcentajeIVA);
            <% } %>
        });
        
        function seleccionarIVA(porcentaje) {
            porcentajeIVA = porcentaje;
            
            // Actualizar selección visual
            document.querySelectorAll('.iva-option').forEach(option => {
                option.classList.remove('selected');
                if (parseFloat(option.dataset.iva) === porcentaje) {
                    option.classList.add('selected');
                }
            });
            
            document.getElementById('porcentajeIVA').textContent = (porcentaje * 100) + '%';
            calcularTotales();
        }
        
        function calcularTotales() {
            const subtotal = parseFloat(document.getElementById('subtotal').value) || 0;
            const iva = subtotal * porcentajeIVA;
            const total = subtotal + iva;
            
            document.getElementById('iva').value = iva.toFixed(2);
            document.getElementById('total').value = total.toFixed(2);
            
            // Actualizar resumen
            document.getElementById('resumenSubtotal').textContent = '$' + subtotal.toFixed(2);
            document.getElementById('resumenIVA').textContent = '$' + iva.toFixed(2);
            document.getElementById('resumenTotal').textContent = '$' + total.toFixed(2);
            
            // Actualizar vista previa
            document.getElementById('previewTotal').textContent = '$' + total.toFixed(2);
        }
        
        // Actualizar información de la orden
        document.getElementById('idOrdenServicio').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const orderInfo = document.getElementById('orderInfo');
            
            if (this.value) {
                orderInfo.style.display = 'block';
                document.getElementById('infoCliente').textContent = selectedOption.dataset.cliente || '-';
                document.getElementById('infoVehiculo').textContent = selectedOption.dataset.vehiculo || '-';
                document.getElementById('infoProblema').textContent = selectedOption.dataset.problema || '-';
                
                // Actualizar vista previa
                document.getElementById('previewOrden').textContent = 'Orden #' + this.value;
                document.getElementById('previewCliente').textContent = selectedOption.dataset.cliente || '-';
            } else {
                orderInfo.style.display = 'none';
                document.getElementById('previewOrden').textContent = 'Seleccione una orden';
                document.getElementById('previewCliente').textContent = '-';
            }
        });
        
        // Actualizar vista previa del número
        document.getElementById('numeroFactura').addEventListener('input', function() {
            document.getElementById('previewNumero').textContent = this.value || 'N/A';
        });
        
        // Validación del formulario
        document.getElementById('facturaForm').addEventListener('submit', function(e) {
            const numeroFactura = document.getElementById('numeroFactura').value.trim();
            const ordenServicio = document.getElementById('idOrdenServicio').value;
            const estadoFactura = document.getElementById('idEstadoFactura').value;
            const subtotal = parseFloat(document.getElementById('subtotal').value) || 0;
            
            if (!numeroFactura) {
                e.preventDefault();
                alert('Por favor ingrese el número de factura');
                document.getElementById('numeroFactura').focus();
                return false;
            }
            
            if (!ordenServicio) {
                e.preventDefault();
                alert('Por favor seleccione una orden de servicio');
                document.getElementById('idOrdenServicio').focus();
                return false;
            }
            
            if (!estadoFactura) {
                e.preventDefault();
                alert('Por favor seleccione un estado de factura');
                document.getElementById('idEstadoFactura').focus();
                return false;
            }
            
            if (subtotal <= 0) {
                e.preventDefault();
                alert('El subtotal debe ser mayor a cero');
                document.getElementById('subtotal').focus();
                return false;
            }
            
            return confirm('¿Está seguro de <%= esNuevo ? "generar" : "actualizar" %> esta factura?');
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