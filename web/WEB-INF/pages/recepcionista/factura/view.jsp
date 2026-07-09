<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Factura, com.upec.model.DetalleFactura" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Factura factura = (Factura) request.getAttribute("factura");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfFull = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Detalle de Factura - Taller Automotriz</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
      
    </head>
    <body class="recepcionista">
        <%@include file="/WEB-INF/pages/shared/header.jsp" %>
        <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
        <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

        <div class="main-content-with-sidebar">
            <div class="container">
                <div class="page-header no-print">
                    <h1>🧾 Detalle de Factura</h1>
                    <p>Información completa de la factura</p>
                </div>

                <% if (factura != null) {
                        String estadoClase = "status-pendiente";
                        String estadoTexto = "PENDIENTE";

                        if (factura.getIDEstadoFactura() != null) {
                            estadoTexto = factura.getIDEstadoFactura().getNombreEstado();
                            if ("PAGADA".equals(estadoTexto)) {
                                estadoClase = "status-pagada";
                            } else if ("CANCELADA".equals(estadoTexto)) {
                                estadoClase = "status-cancelada";
                            } else if ("ANULADA".equals(estadoTexto)) {
                                estadoClase = "status-anulada";
                            }
                        }
                %>
                <div class="invoice-container">
                    <!-- Encabezado de la Factura -->
                    <div class="invoice-header">
                        <h1 class="invoice-title">FACTURA</h1>
                        <p class="invoice-subtitle">Taller Automotriz Especializado</p>
                        <div class="invoice-meta">
                            <h2><%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : "N/A"%></h2>
                            <p>Fecha: <%= factura.getFechaEmision() != null ? sdf.format(factura.getFechaEmision()) : "N/A"%></p>
                            <span class="status-badge <%= estadoClase%>"><%= estadoTexto%></span>
                        </div>
                    </div>

                    <div class="invoice-body">
                        <!-- Información Principal -->
                        <div class="invoice-grid">
                            <!-- Información del Taller -->
                            <div class="invoice-section">
                                <h3>🏢 Taller Automotriz</h3>
                                <div class="detail-item">
                                    <strong>Nombre:</strong>
                                    <span>Taller Automotriz Especializado</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Dirección:</strong>
                                    <span>Av. Principal 123, Ciudad</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Teléfono:</strong>
                                    <span>(04) 234-5678</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Email:</strong>
                                    <span>info@tallerautomotriz.com</span>
                                </div>
                                <div class="detail-item">
                                    <strong>RUC:</strong>
                                    <span>1234567890001</span>
                                </div>
                            </div>

                            <!-- Información del Cliente -->
                            <div class="invoice-section">
                                <h3>👤 Información del Cliente</h3>
                                <% if (factura.getIDOrdenServicio() != null
                                            && factura.getIDOrdenServicio().getIDVehiculo() != null
                                            && factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) {
                                        com.upec.model.Cliente cliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente();
                                        String nombreCliente = cliente.getNombre();
                                        String apellidoCliente = cliente.getApellido();
                                %>
                                <div class="detail-item">
                                    <strong>Cliente:</strong>
                                    <span><%= nombreCliente != null ? nombreCliente : ""%> <%= apellidoCliente != null ? apellidoCliente : ""%></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Identificación:</strong>
                                    <span>
                                        <%
                                            // Usar ID del cliente como identificación si no hay cédula
                                            String identificacion = "N/A";
                                            if (cliente.getIDCliente() != null) {
                                                identificacion = "CLI-" + cliente.getIDCliente();
                                            }
                                        %>
                                        <%= identificacion%>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Información de Contacto:</strong>
                                    <span>Consultar en sistema</span>
                                </div>
                                <% } else { %>
                                <div class="detail-item">
                                    <strong>Cliente:</strong>
                                    <span>Información no disponible</span>
                                </div>
                                <% }%>
                            </div>

                            <!-- Información de la Orden -->
                            <div class="invoice-section">
                                <h3>📦 Información de la Orden</h3>
                                <div class="detail-item">
                                    <strong>Orden de Servicio:</strong>
                                    <span>#<%= factura.getIDOrdenServicio() != null ? factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A"%></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Vehículo:</strong>
                                    <span>
                                        <% if (factura.getIDOrdenServicio() != null
                                                    && factura.getIDOrdenServicio().getIDVehiculo() != null) {%>
                                        <%= factura.getIDOrdenServicio().getIDVehiculo().getPlaca()%> - 
                                        <%= factura.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null
                                                ? factura.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : ""%> 
                                        <%= factura.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null
                                                ? factura.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : ""%>
                                        <% } else { %>
                                        N/A
                                        <% }%>
                                    </span>
                                </div>
                                <div class="detail-item">
                                    <strong>Problema Reportado:</strong>
                                        <span><%= factura.getIDOrdenServicio() != null && factura.getIDOrdenServicio().getProblemaReportado() != null
                                                ? factura.getIDOrdenServicio().getProblemaReportado() : "N/A"%></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha Entrada:</strong>
                                        <span><%= factura.getIDOrdenServicio() != null && factura.getIDOrdenServicio().getFechaEntrada() != null
                                                ? sdfFull.format(factura.getIDOrdenServicio().getFechaEntrada()) : "N/A"%></span>
                                </div>
                            </div>

                            <!-- Detalles de la Factura -->
                            <div class="invoice-section">
                                <h3>🔧 Detalles de la Factura</h3>

                                <% if (factura.getDetalleFacturaList() != null && !factura.getDetalleFacturaList().isEmpty()) { %>
                                <table class="items-table">
                                    <thead>
                                        <tr>
                                            <th>Descripción</th>
                                            <th class="text-right">Cantidad</th>
                                            <th class="text-right">Precio Unitario</th>
                                            <th class="text-right">Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (DetalleFactura detalle : factura.getDetalleFacturaList()) { %>
                                        <tr>
                                            <td>
                                                <% if (detalle.getIDServicio() != null) {%>
                                                Servicio: <%= detalle.getIDServicio().getNombreServicio() != null
                                                        ? detalle.getIDServicio().getNombreServicio() : "N/A"%>
                                                <% } else if (detalle.getIDRepuesto() != null) {%>
                                                Repuesto: <%= detalle.getIDRepuesto().getNombreRepuesto() != null
                                                        ? detalle.getIDRepuesto().getNombreRepuesto() : "N/A"%>
                                                <% } else { %>
                                                Item no especificado
                                                <% } %>
                                                <% if (detalle.getDescripcion() != null && !detalle.getDescripcion().isEmpty()) {%>
                                                <br><small><%= detalle.getDescripcion()%></small>
                                                <% }%>
                                            </td>
                                            <td class="text-right"><%= detalle.getCantidad() != null ? detalle.getCantidad() : 1%></td>
                                            <td class="text-right">$<%= detalle.getPrecioUnitario() != null
                                                        ? String.format("%,.2f", detalle.getPrecioUnitario()) : "0.00"%></td>
                                            <td class="text-right">$<%= detalle.getSubtotal() != null
                                                        ? String.format("%,.2f", detalle.getSubtotal()) : "0.00"%></td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                                <% } else { %>
                                <div class="empty-items">
                                    <div class="icon">📝</div>
                                    <h4>No hay detalles registrados</h4>
                                    <p>Esta factura no tiene items detallados</p>
                                </div>
                                <% }%>
                            </div>

                            <!-- Totales -->
                            <div class="totals-section">
                                <div class="total-row">
                                    <span>Subtotal:</span>
                                    <span>$<%= factura.getSubtotal() != null ? String.format("%,.2f", factura.getSubtotal()) : "0.00"%></span>
                                </div>
                                <div class="total-row">
                                    <span>IVA:</span>
                                    <span>$<%= factura.getIva() != null ? String.format("%,.2f", factura.getIva()) : "0.00"%></span>
                                </div>
                                <div class="total-row final">
                                    <span>TOTAL:</span>
                                    <span>$<%= factura.getTotal() != null ? String.format("%,.2f", factura.getTotal()) : "0.00"%></span>
                                </div>
                            </div>

                            <!-- Observaciones -->
                            <% if (factura.getIDOrdenServicio() != null
                                        && factura.getIDOrdenServicio().getObservaciones() != null
                                        && !factura.getIDOrdenServicio().getObservaciones().isEmpty()) {%>
                            <div class="invoice-section">
                                <h3>📝 Observaciones</h3>
                                <p><%= factura.getIDOrdenServicio().getObservaciones()%></p>
                            </div>
                            <% }%>
                        </div>
                    </div>

                    <!-- Acciones -->
                    <div class="action-buttons no-print">
                        <button onclick="window.print()" class="btn btn-primary">
                            🖨️ Imprimir Factura
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas/editar?id=<%= factura.getIDFactura()%>" 
                           class="btn btn-warning">✏️ Editar Factura</a>

                        <% if (!"PAGADA".equals(estadoTexto) && !"CANCELADA".equals(estadoTexto)) {%>
                        <form action="${pageContext.request.contextPath}/recepcionista/facturas/cambiar-estado" 
                              method="post" style="display: inline;">
                            <input type="hidden" name="idFactura" value="<%= factura.getIDFactura()%>">
                            <input type="hidden" name="idEstadoFactura" value="2"> <!-- Asumiendo 2 = PAGADA -->
                            <button type="submit" class="btn btn-success"
                                    onclick="return confirm('¿Está seguro de marcar esta factura como PAGADA?')">
                                💰 Marcar como Pagada
                            </button>
                        </form>
                        <% } %>

                        <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-secondary">
                            ↩️ Volver a Facturas
                        </a>
                    </div>

                    <% } else { %>
                    <div class="error-message">
                        <p>❌ No se encontró la factura solicitada.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-secondary">
                            Volver a Facturas
                        </a>
                    </div>
                    <% }%>
                </div>
            </div>

            <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
    </body>
</html>