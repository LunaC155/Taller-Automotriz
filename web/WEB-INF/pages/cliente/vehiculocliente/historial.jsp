<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Historial del Vehículo</title>
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
                <h1>📋 Historial del Vehículo</h1>
                <p>Servicios y mantenimientos realizados a tu vehículo</p>
            </div>

            <% if (vehiculo != null) { %>
                <!-- Información del Vehículo -->
                <div class="vehicle-info-card">
                    <h3>Vehículo: <%= vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "Sin Placa" %></h3>
                    <p><strong>Marca/Modelo:</strong> <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %> / 
                       <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %></p>
                    <p><strong>Color:</strong> <%= vehiculo.getColor() != null ? vehiculo.getColor() : "N/A" %> | 
                       <strong>Año:</strong> <%= vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "N/A" %></p>
                </div>

                <!-- Estadísticas -->
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-icon">🔧</div>
                        <div class="metric-info">
                            <h3 id="total-servicios"><%= vehiculo.getOrdenServicioList() != null ? vehiculo.getOrdenServicioList().size() : 0 %></h3>
                            <p>Total Servicios</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">✅</div>
                        <div class="metric-info">
                            <h3 id="servicios-completados">
                                <%= vehiculo.getOrdenServicioList() != null ? 
                                    vehiculo.getOrdenServicioList().stream()
                                        .filter(o -> o.getFechaRealSalida() != null)
                                        .count() : 0 %>
                            </h3>
                            <p>Completados</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">💰</div>
                        <div class="metric-info">
                            <h3 id="total-gastado">$0.00</h3>
                            <p>Total Invertido</p>
                        </div>
                    </div>
                </div>

                <!-- Historial de Servicios -->
                <div class="table-container">
                    <h2 class="section-title">Historial de Servicios</h2>
                    <% if (vehiculo.getOrdenServicioList() != null && !vehiculo.getOrdenServicioList().isEmpty()) { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Fecha Entrada</th>
                                    <th>Fecha Salida</th>
                                    <th>Diagnóstico</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (com.upec.model.OrdenServicio orden : vehiculo.getOrdenServicioList()) { %>
                                    <tr>
                                        <td><%= orden.getIDOrden() %></td>
                                        <td><%= orden.getFechaEntrada() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEntrada()) : "N/A" %></td>
                                        <td><%= orden.getFechaRealSalida() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaRealSalida()) : "Pendiente" %></td>
                                        <td>
                                            <%= orden.getDiagnosticoList() != null && !orden.getDiagnosticoList().isEmpty() ? 
                                                orden.getDiagnosticoList().get(0).getDescripcionProblema() : "Sin diagnóstico" %>
                                        </td>
                                        <td>
                                            <span class="status-badge <%= orden.getFechaRealSalida() != null ? "active" : "inactive" %>">
                                                <%= orden.getFechaRealSalida() != null ? "Completado" : "En Proceso" %>
                                            </span>
                                        </td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/cliente/ordenes/ver?id=<%= orden.getIDOrden() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">👁️</a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <div class="no-data">
                            <p>📋 Este vehículo no tiene servicios registrados.</p>
                            <a href="${pageContext.request.contextPath}/cliente/citas/crear" class="btn btn-primary">
                                📅 Agendar Primera Cita
                            </a>
                        </div>
                    <% } %>
                </div>

                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=ver&id=<%= vehiculo.getIDVehiculo() %>" 
                       class="btn btn-info">👁️ Ver Detalles del Vehículo</a>
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos" 
                       class="btn btn-secondary">↩️ Volver a la Lista</a>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el vehículo solicitado.</p>
                    <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos" class="btn btn-secondary">Volver a la Lista</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Calcular total gastado sumando las facturas
            const vehiculoId = <%= vehiculo != null ? vehiculo.getIDVehiculo() : "null" %>;
            
            if (vehiculoId && <%= vehiculo != null && vehiculo.getOrdenServicioList() != null %>) {
                let totalGastado = 0;
                <% if (vehiculo != null && vehiculo.getOrdenServicioList() != null) {
                    for (com.upec.model.OrdenServicio orden : vehiculo.getOrdenServicioList()) {
                        if (orden.getFacturaList() != null) {
                            for (com.upec.model.Factura factura : orden.getFacturaList()) {
                                if (factura.getTotal() != null) { %>
                                    totalGastado += <%= factura.getTotal() %>;
                                <% }
                            }
                        }
                    }
                } %>
                
                document.getElementById('total-gastado').textContent = ' + totalGastado.toFixed(2);
            }
        });
    </script>
</body>
</html>