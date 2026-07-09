<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Factura, java.util.List, java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Factura> facturas = (List<Factura>) request.getAttribute("facturas");
    String filtro = (String) request.getAttribute("filtro");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
    
    Integer totalFacturas = (Integer) request.getAttribute("totalFacturas");
    Integer facturasPendientes = (Integer) request.getAttribute("facturasPendientes");
    Integer facturasHoy = (Integer) request.getAttribute("facturasHoy");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Facturas - Taller Automotriz</title>
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
                <h1>🧾 Gestión de Facturas</h1>
                <p>Administra todas las facturas del taller automotriz</p>
            </div>

            <!-- Tarjetas de Estadísticas -->
            <div class="stats-cards">
                <div class="stat-card total">
                    <div class="stat-icon">📊</div>
                    <div class="stat-number"><%= totalFacturas != null ? totalFacturas : 0 %></div>
                    <div class="stat-label">Total Facturas</div>
                </div>
                <div class="stat-card pendientes">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-number"><%= facturasPendientes != null ? facturasPendientes : 0 %></div>
                    <div class="stat-label">Facturas Pendientes</div>
                </div>
                <div class="stat-card hoy">
                    <div class="stat-icon">📅</div>
                    <div class="stat-number"><%= facturasHoy != null ? facturasHoy : 0 %></div>
                    <div class="stat-label">Facturas Hoy</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">💰</div>
                    <div class="stat-number">
                        <% 
                            double totalMonto = 0;
                            if (facturas != null) {
                                for (Factura factura : facturas) {
                                    if (factura.getTotal() != null) {
                                        totalMonto += factura.getTotal().doubleValue();
                                    }
                                }
                            }
                        %>
                        $<%= String.format("%,.2f", totalMonto) %>
                    </div>
                    <div class="stat-label">Total Facturado</div>
                </div>
            </div>

            <!-- Acciones principales -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/generar" class="btn btn-primary">
                        <span class="btn-icon">➕</span> Generar Factura
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/estadisticas" class="btn btn-info">
                        <span class="btn-icon">📈</span> Estadísticas
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/pendientes" class="btn btn-warning">
                        <span class="btn-icon">⏳</span> Pendientes
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/hoy" class="btn btn-success">
                        <span class="btn-icon">📅</span> De Hoy
                    </a>
                </div>
                <div class="actions-right">
                    <button type="button" class="btn btn-secondary" onclick="toggleFiltros()">
                        <span class="btn-icon">🔍</span> Filtros Avanzados
                    </button>
                </div>
            </div>

            <!-- Filtros Avanzados -->
            <div id="filtrosAvanzados" class="filtros-avanzados" style="display: none;">
                <h4>🔍 Filtros de Búsqueda</h4>
                <form action="${pageContext.request.contextPath}/recepcionista/facturas/buscar" method="get" class="filtros-grid">
                    <div class="form-group">
                        <label for="criterio">Criterio de Búsqueda</label>
                        <select id="criterio" name="criterio" class="form-control">
                            <option value="">Seleccionar criterio...</option>
                            <option value="numero" <%= "numero".equals(criterio) ? "selected" : "" %>>Número de Factura</option>
                            <option value="cliente" <%= "cliente".equals(criterio) ? "selected" : "" %>>Cliente</option>
                            <option value="orden" <%= "orden".equals(criterio) ? "selected" : "" %>>Orden de Servicio</option>
                            <option value="estado" <%= "estado".equals(criterio) ? "selected" : "" %>>Estado</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="valor">Valor</label>
                        <input type="text" id="valor" name="valor" value="<%= valor != null ? valor : "" %>" 
                               class="form-control" placeholder="Ingrese valor...">
                    </div>
                    <div class="form-group">
                        <label for="fechaInicio">Fecha Inicio</label>
                        <input type="date" id="fechaInicio" name="fechaInicio" 
                               value="<%= fechaInicio != null ? fechaInicio : "" %>" class="form-control">
                    </div>
                    <div class="form-group">
                        <label for="fechaFin">Fecha Fin</label>
                        <input type="date" id="fechaFin" name="fechaFin" 
                               value="<%= fechaFin != null ? fechaFin : "" %>" class="form-control">
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Buscar</button>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-secondary">Limpiar</a>
                    </div>
                </form>
            </div>

            <!-- Tabla de facturas -->
            <div class="table-container">
                <% if (facturas == null || facturas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🧾</div>
                        <h3>No hay facturas registradas</h3>
                        <p>No se encontraron facturas con los criterios especificados.</p>
                        <a href="${pageContext.request.contextPath}/recepcionista/facturas/generar" class="btn btn-primary">
                            Generar Primera Factura
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>N° Factura</th>
                                <th>Orden Servicio</th>
                                <th>Cliente</th>
                                <th>Vehículo</th>
                                <th>Fecha Emisión</th>
                                <th>Subtotal</th>
                                <th>IVA</th>
                                <th>Total</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                double subtotalGeneral = 0;
                                double ivaGeneral = 0;
                                double totalGeneral = 0;
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                            %>
                            <% for (Factura factura : facturas) { 
                                if (factura.getSubtotal() != null) subtotalGeneral += factura.getSubtotal().doubleValue();
                                if (factura.getIva() != null) ivaGeneral += factura.getIva().doubleValue();
                                if (factura.getTotal() != null) totalGeneral += factura.getTotal().doubleValue();
                            %>
                                <tr>
                                    <td><strong><%= factura.getNumeroFactura() != null ? factura.getNumeroFactura() : "N/A" %></strong></td>
                                    <td>#<%= factura.getIDOrdenServicio() != null ? factura.getIDOrdenServicio().getIDOrdenServicio() : "N/A" %></td>
                                    <td>
                                        <% if (factura.getIDOrdenServicio() != null && 
                                               factura.getIDOrdenServicio().getIDVehiculo() != null &&
                                               factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) { 
                                               String nombreCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getNombre();
                                               String apellidoCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getApellido();
                                        %>
                                            <%= nombreCliente != null ? nombreCliente : "" %> <%= apellidoCliente != null ? apellidoCliente : "" %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (factura.getIDOrdenServicio() != null && 
                                               factura.getIDOrdenServicio().getIDVehiculo() != null) { %>
                                            <strong><%= factura.getIDOrdenServicio().getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= factura.getIDOrdenServicio().getIDVehiculo().getIDMarca() != null ? 
                                                    factura.getIDOrdenServicio().getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= factura.getIDOrdenServicio().getIDVehiculo().getIDModelo() != null ? 
                                                    factura.getIDOrdenServicio().getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td><%= factura.getFechaEmision() != null ? sdf.format(factura.getFechaEmision()) : "N/A" %></td>
                                    <td class="monto">$<%= factura.getSubtotal() != null ? String.format("%,.2f", factura.getSubtotal()) : "0.00" %></td>
                                    <td class="monto">$<%= factura.getIva() != null ? String.format("%,.2f", factura.getIva()) : "0.00" %></td>
                                    <td class="monto"><strong>$<%= factura.getTotal() != null ? String.format("%,.2f", factura.getTotal()) : "0.00" %></strong></td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-pendiente";
                                            String estadoTexto = "PENDIENTE";
                                            
                                            if (factura.getIDEstadoFactura() != null) {
                                                estadoTexto = factura.getIDEstadoFactura().getNombreEstado();
                                                if ("PAGADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-pagada";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-cancelada";
                                                } else if ("ANULADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-anulada";
                                                }
                                            }
                                        %>
                                        <span class="badge-estado <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/ver?id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/editar?id=<%= factura.getIDFactura() %>" 
                                               class="btn btn-sm btn-warning" title="Editar factura">
                                                ✏️ Editar
                                            </a>
                                            <% if (!"PAGADA".equals(estadoTexto) && !"CANCELADA".equals(estadoTexto)) { %>
                                                <form action="${pageContext.request.contextPath}/recepcionista/facturas/cambiar-estado" 
                                                      method="post" style="display: inline;">
                                                    <input type="hidden" name="idFactura" value="<%= factura.getIDFactura() %>">
                                                    <input type="hidden" name="idEstadoFactura" value="2"> <!-- Asumiendo 2 = PAGADA -->
                                                    <button type="submit" class="btn btn-sm btn-success" 
                                                            title="Marcar como pagada"
                                                            onclick="return confirm('¿Está seguro de marcar esta factura como PAGADA?')">
                                                        💰 Pagar
                                                    </button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            <!-- Fila de totales -->
                            <tr class="total-row">
                                <td colspan="5"><strong>TOTALES GENERALES</strong></td>
                                <td class="monto"><strong>$<%= String.format("%,.2f", subtotalGeneral) %></strong></td>
                                <td class="monto"><strong>$<%= String.format("%,.2f", ivaGeneral) %></strong></td>
                                <td class="monto"><strong>$<%= String.format("%,.2f", totalGeneral) %></strong></td>
                                <td colspan="2"></td>
                            </tr>
                        </tbody>
                    </table>
                    
                    <!-- Información adicional -->
                    <div class="table-info">
                        <p>Total de facturas: <strong><%= facturas.size() %></strong></p>
                        <p>
                            <% 
                                long pendientesCount = facturas.stream()
                                    .filter(f -> f.getIDEstadoFactura() != null && "PENDIENTE".equals(f.getIDEstadoFactura().getNombreEstado()))
                                    .count();
                                long pagadasCount = facturas.stream()
                                    .filter(f -> f.getIDEstadoFactura() != null && "PAGADA".equals(f.getIDEstadoFactura().getNombreEstado()))
                                    .count();
                            %>
                            <span class="badge badge-warning">Pendientes: <%= pendientesCount %></span>
                            <span class="badge badge-success">Pagadas: <%= pagadasCount %></span>
                            <span class="badge badge-danger">Canceladas: <%= facturas.size() - pendientesCount - pagadasCount %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function toggleFiltros() {
            const filtros = document.getElementById('filtrosAvanzados');
            filtros.style.display = filtros.style.display === 'none' ? 'block' : 'none';
        }
        
        // Mostrar filtros si hay criterios activos
        window.addEventListener('load', function() {
            const criterio = '<%= criterio != null ? criterio : "" %>';
            const fechaInicio = '<%= fechaInicio != null ? fechaInicio : "" %>';
            const fechaFin = '<%= fechaFin != null ? fechaFin : "" %>';
            
            if (criterio || fechaInicio || fechaFin) {
                document.getElementById('filtrosAvanzados').style.display = 'block';
            }
        });
    </script>
</body>
</html>