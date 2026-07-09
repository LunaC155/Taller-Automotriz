<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Factura" %>
<%
    Factura factura = (Factura) request.getAttribute("factura");
    Long diasDesdeEmision = (Long) request.getAttribute("diasDesdeEmision");
    Boolean esVencida = (Boolean) request.getAttribute("esVencida");
    
    // Inicializar valores para evitar nulls
    if (diasDesdeEmision == null) diasDesdeEmision = 0L;
    if (esVencida == null) esVencida = false;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle de Factura</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
</head>
<body class="cliente">
    <%@include file="../../shared/header.jsp" %>
    <%@include file="../../shared/sidebar-cliente.jsp" %>
    <%@include file="../../shared/messages.jsp" %>
    
    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header no-print">
                <h1>🧾 Detalle de Factura</h1>
                <p>Información completa de tu factura</p>
            </div>

            <% if (factura != null) { %>
                <div class="invoice-detail">
                    <!-- Encabezado de la Factura -->
                    <div class="invoice-header">
                        <h1 class="invoice-title">FACTURA</h1>
                        <p class="invoice-subtitle">Taller Automotriz Especializado</p>
                        <div class="invoice-status">
                            <%= factura.getIDEstadoFactura() != null ? 
                                factura.getIDEstadoFactura().getNombreEstado() : "PENDIENTE" %>
                            <% if (esVencida) { %>
                                ⚠️ VENCIDA
                            <% } %>
                        </div>
                    </div>

                    <div class="invoice-content">
                        <!-- Banner de Advertencia para Facturas Vencidas -->
                        <% if (esVencida) { %>
                            <div class="warning-banner expired no-print">
                                <div class="warning-icon">⚠️</div>
                                <div>
                                    <strong>Factura Vencida</strong>
                                    <p>Esta factura tiene <%= diasDesdeEmision %> días de retraso. Por favor, contacte con nosotros para regularizar su situación.</p>
                                </div>
                            </div>
                        <% } else if (factura.getIDEstadoFactura() != null && 
                                    "PENDIENTE".equalsIgnoreCase(factura.getIDEstadoFactura().getNombreEstado())) { %>
                            <div class="warning-banner no-print">
                                <div class="warning-icon">💡</div>
                                <div>
                                    <strong>Factura Pendiente de Pago</strong>
                                    <p>Esta factura tiene <%= diasDesdeEmision %> días desde su emisión.</p>
                                </div>
                            </div>
                        <% } %>

                        <!-- Información de la Factura -->
                        <div class="invoice-grid">
                            <!-- Información del Cliente -->
                            <div class="invoice-section">
                                <h3>Información del Cliente</h3>
                                <div class="detail-item">
                                    <strong>Cliente:</strong>
                                    <span>
                                        <% 
                                            String nombreCliente = "N/A";
                                            if (factura.getIDOrdenServicio() != null && 
                                                factura.getIDOrdenServicio().getIDVehiculo() != null &&
                                                factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) {
                                                String nombre = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getNombre();
                                                String apellido = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getApellido();
                                                nombreCliente = (nombre != null ? nombre : "") + " " + (apellido != null ? apellido : "");
                                            }
                                        %>
                                        <%= nombreCliente.trim().isEmpty() ? "N/A" : nombreCliente %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Email:</strong>
                                    <span>
                                        <% 
                                            String emailCliente = "N/A";
                                            if (factura.getIDOrdenServicio() != null && 
                                                factura.getIDOrdenServicio().getIDVehiculo() != null &&
                                                factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) {
                                                emailCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getEmail();
                                            }
                                        %>
                                        <%= emailCliente != null ? emailCliente : "N/A" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Teléfono:</strong>
                                    <span>
                                        <% 
                                            String telefonoCliente = "N/A";
                                            if (factura.getIDOrdenServicio() != null && 
                                                factura.getIDOrdenServicio().getIDVehiculo() != null &&
                                                factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) {
                                                telefonoCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getTelefono();
                                            }
                                        %>
                                        <%= telefonoCliente != null ? telefonoCliente : "N/A" %>
                                    </span>
                                </div>
                            </div>

                            <!-- Información de la Factura -->
                            <div class="invoice-section">
                                <h3>Información de la Factura</h3>
                                <div class="detail-item">
                                    <strong>Número de Factura:</strong>
                                    <span>#<%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : factura.getIDFactura() %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha de Emisión:</strong>
                                    <span><%= factura.getFechaEmision() != null ? factura.getFechaEmision() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Orden de Servicio:</strong>
                                    <span>#<%= factura.getIDOrdenServicio() != null ? 
                                        factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Estado:</strong>
                                    <span class="status-badge 
                                        <%= "PAGADA".equalsIgnoreCase(factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "") ? "completed" : 
                                           ("PENDIENTE".equalsIgnoreCase(factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "") ? "pending" : "warning") %>">
                                        <%= factura.getIDEstadoFactura() != null ? factura.getIDEstadoFactura().getNombreEstado() : "Pendiente" %>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Información del Vehículo y Servicio -->
                        <div class="invoice-grid">
                            <!-- Información del Vehículo -->
                            <div class="invoice-section">
                                <h3>Información del Vehículo</h3>
                                <div class="detail-item">
                                    <strong>Vehículo:</strong>
                                    <span>
                                        <%= factura.getIDOrdenServicio() != null && 
                                            factura.getIDOrdenServicio().getIDVehiculo() != null ?
                                            factura.getIDOrdenServicio().getIDVehiculo().getPlaca() : "N/A" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Marca/Modelo:</strong>
                                    <span>
                                        <% 
                                            String marcaModelo = "N/A / N/A";
                                            if (factura.getIDOrdenServicio() != null && 
                                                factura.getIDOrdenServicio().getIDVehiculo() != null) {
                                                String marca = "N/A";
                                                String modelo = "N/A";
                                                if (factura.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null) {
                                                    marca = factura.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca();
                                                }
                                                if (factura.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null) {
                                                    modelo = factura.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo();
                                                }
                                                marcaModelo = marca + " / " + modelo;
                                            }
                                        %>
                                        <%= marcaModelo %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Color:</strong>
                                    <span>
                                        <%= factura.getIDOrdenServicio() != null && 
                                            factura.getIDOrdenServicio().getIDVehiculo() != null ?
                                            (factura.getIDOrdenServicio().getIDVehiculo().getColor() != null ? 
                                             factura.getIDOrdenServicio().getIDVehiculo().getColor() : "N/A") : "N/A" %>
                                    </span>
                                </div>
                            </div>

                            <!-- Información del Servicio -->
                            <div class="invoice-section">
                                <h3>Información del Servicio</h3>
                                <div class="detail-item">
                                    <strong>Problema Reportado:</strong>
                                    <span>
                                        <%= factura.getIDOrdenServicio() != null ?
                                            (factura.getIDOrdenServicio().getProblemaReportado() != null ? 
                                             factura.getIDOrdenServicio().getProblemaReportado() : "N/A") : "N/A" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha de Entrada:</strong>
                                    <span>
                                        <%= factura.getIDOrdenServicio() != null ?
                                            factura.getIDOrdenServicio().getFechaEntrada() : "N/A" %>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha de Salida:</strong>
                                    <span>
                                        <%= factura.getIDOrdenServicio() != null ?
                                            factura.getIDOrdenServicio().getFechaRealSalida() : "N/A" %>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Detalles de la Factura -->
                        <div class="invoice-section">
                            <h3>Detalles de la Factura</h3>
                            <table class="invoice-table">
                                <thead>
                                    <tr>
                                        <th>Descripción</th>
                                        <th class="text-center">Cantidad</th>
                                        <th class="text-right">Precio Unitario</th>
                                        <th class="text-right">Subtotal</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Servicio Principal -->
                                    <tr>
                                        <td>
                                            <strong>Servicio de Reparación</strong><br>
                                            <small>
                                                <%= factura.getIDOrdenServicio() != null &&
                                                    factura.getIDOrdenServicio().getProblemaReportado() != null ?
                                                    factura.getIDOrdenServicio().getProblemaReportado() : "Reparación general" %>
                                            </small>
                                        </td>
                                        <td class="text-center">1</td>
                                        <td class="text-right">$<%= factura.getSubtotal() != null ? 
                                            String.format("%.2f", factura.getSubtotal()) : "0.00" %></td>
                                        <td class="text-right">$<%= factura.getSubtotal() != null ? 
                                            String.format("%.2f", factura.getSubtotal()) : "0.00" %></td>
                                    </tr>
                                    
                                    <!-- Repuestos (si los hay) -->
                                    <% if (factura.getTotal() != null && factura.getSubtotal() != null && 
                                          factura.getTotal().doubleValue() > factura.getSubtotal().doubleValue()) { %>
                                        <tr>
                                            <td>
                                                <strong>Repuestos y Materiales</strong><br>
                                                <small>Materiales utilizados en la reparación</small>
                                            </td>
                                            <td class="text-center">1</td>
                                            <td class="text-right">$<%= String.format("%.2f", factura.getTotal().doubleValue() - factura.getSubtotal().doubleValue()) %></td>
                                            <td class="text-right">$<%= String.format("%.2f", factura.getTotal().doubleValue() - factura.getSubtotal().doubleValue()) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>

                        <!-- Totales -->
                        <div class="total-section">
                            <div class="total-row">
                                <strong>Subtotal:</strong>
                                <span>$<%= factura.getSubtotal() != null ? String.format("%.2f", factura.getSubtotal()) : "0.00" %></span>
                            </div>
                            <div class="total-row">
                                <strong>IVA (12%):</strong>
                                <span>$<%= factura.getIva() != null ? String.format("%.2f", factura.getIva()) : "0.00" %></span>
                            </div>
                            <div class="total-row grand-total">
                                <strong>TOTAL:</strong>
                                <span>$<%= factura.getTotal() != null ? String.format("%.2f", factura.getTotal()) : "0.00" %></span>
                            </div>
                        </div>

                        <!-- Observaciones -->
                        <% if (factura.getIDOrdenServicio() != null && 
                              factura.getIDOrdenServicio().getObservaciones() != null && 
                              !factura.getIDOrdenServicio().getObservaciones().trim().isEmpty()) { %>
                            <div class="invoice-section">
                                <h3>Observaciones</h3>
                                <p><%= factura.getIDOrdenServicio().getObservaciones() %></p>
                            </div>
                        <% } %>

                        <!-- Información de Contacto -->
                        <div class="invoice-section print-only">
                            <h3>Información de Contacto</h3>
                            <p><strong>Taller Automotriz Especializado</strong><br>
                            Teléfono: (04) 234-5678<br>
                            Email: contacto@tallerautomotriz.com<br>
                            Dirección: Av. Principal 123, Ciudad</p>
                        </div>

                        <!-- Acciones -->
                        <div class="invoice-actions no-print">
                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=descargar&id=<%= factura.getIDFactura() %>" 
                               class="btn btn-success">📥 Descargar PDF</a>
                            <button onclick="window.print()" class="btn btn-info">🖨️ Imprimir</button>
                            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" 
                               class="btn btn-secondary">↩️ Volver a Facturas</a>
                        </div>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la factura solicitada.</p>
                    <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" class="btn btn-secondary">Volver a Facturas</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="../../shared/footer.jsp" %>
</body>
</html>