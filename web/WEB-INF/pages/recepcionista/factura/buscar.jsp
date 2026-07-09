<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Factura, java.util.List, java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Factura> facturasFiltradas = (List<Factura>) request.getAttribute("facturas");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
    String fechaInicio = (String) request.getAttribute("fechaInicio");
    String fechaFin = (String) request.getAttribute("fechaFin");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buscar Facturas - Taller Automotriz</title>
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
                <h1>🔍 Buscar Facturas</h1>
                <p>Encuentra facturas específicas usando criterios de búsqueda avanzados</p>
            </div>

            <!-- Contenedor de Búsqueda -->
            <div class="search-container">
                <div class="search-header">
                    <h2>Criterios de Búsqueda</h2>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas" class="btn btn-secondary">
                        ↩️ Volver a Todas
                    </a>
                </div>

                <!-- Formulario de Búsqueda -->
                <form action="${pageContext.request.contextPath}/recepcionista/facturas/buscar" method="get" class="search-form-grid">
                    <!-- Criterios de Búsqueda -->
                    <div class="search-criteria">
                        <div class="form-group">
                            <label for="criterio">Buscar por</label>
                            <select id="criterio" name="criterio" class="form-control">
                                <option value="">Seleccionar criterio...</option>
                                <option value="numero" <%= "numero".equals(criterio) ? "selected" : "" %>>Número de Factura</option>
                                <option value="cliente" <%= "cliente".equals(criterio) ? "selected" : "" %>>Cliente</option>
                                <option value="orden" <%= "orden".equals(criterio) ? "selected" : "" %>>Orden de Servicio</option>
                                <option value="estado" <%= "estado".equals(criterio) ? "selected" : "" %>>Estado</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="valor">Valor de Búsqueda</label>
                            <input type="text" id="valor" name="valor" value="<%= valor != null ? valor : "" %>" 
                                   class="form-control" placeholder="Ingrese el valor a buscar...">
                        </div>
                    </div>

                    <!-- Rango de Fechas -->
                    <div class="date-range">
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
                    </div>

                    <!-- Botones de Acción -->
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">
                            🔍 Buscar Facturas
                        </button>
                        <button type="reset" class="btn btn-secondary" onclick="limpiarBusqueda()">
                            🗑️ Limpiar
                        </button>
                    </div>
                </form>

                <!-- Filtros Rápidos -->
                <div class="quick-filters">
                    <strong>Filtros rápidos:</strong>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/pendientes" class="quick-filter">
                        ⏳ Pendientes
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/hoy" class="quick-filter">
                        📅 De Hoy
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas?estado=PAGADA" class="quick-filter">
                        💰 Pagadas
                    </a>
                    <a href="${pageContext.request.contextPath}/recepcionista/facturas?estado=CANCELADA" class="quick-filter">
                        ❌ Canceladas
                    </a>
                </div>

                <!-- Sugerencias de Búsqueda -->
                <div class="search-suggestions">
                    <strong>💡 Sugerencias de búsqueda:</strong>
                    <div class="suggestions-list">
                        <div class="suggestion-item" onclick="aplicarSugerencia('numero', 'FACT-')">
                            Facturas que empiezan con "FACT-"
                        </div>
                        <div class="suggestion-item" onclick="aplicarSugerencia('estado', '1')">
                            Facturas Pendientes
                        </div>
                        <div class="suggestion-item" onclick="aplicarSugerencia('orden', '')">
                            Buscar por N° de Orden
                        </div>
                        <div class="suggestion-item" onclick="establecerRangoMensual()">
                            Facturas de este mes
                        </div>
                    </div>
                </div>
            </div>

            <!-- Resultados de Búsqueda -->
            <% if (error != null) { %>
                <div class="alert alert-danger">
                    ❌ <%= error %>
                </div>
            <% } %>

            <% if (facturasFiltradas != null) { %>
                <div class="search-results-info">
                    <h4>📊 Resultados de la Búsqueda</h4>
                    <div class="results-stats">
                        <div class="stat-item">
                            <span>Facturas encontradas:</span>
                            <span class="stat-number"><%= facturasFiltradas.size() %></span>
                        </div>
                        <div class="stat-item">
                            <span>Total facturado:</span>
                            <span class="stat-number">
                                <% 
                                    double totalMonto = 0;
                                    for (Factura factura : facturasFiltradas) {
                                        if (factura.getTotal() != null) {
                                            totalMonto += factura.getTotal().doubleValue();
                                        }
                                    }
                                %>
                                $<%= String.format("%,.2f", totalMonto) %>
                            </span>
                        </div>
                        <div class="stat-item">
                            <span>Promedio por factura:</span>
                            <span class="stat-number">
                                $<%= facturasFiltradas.size() > 0 ? 
                                    String.format("%,.2f", totalMonto / facturasFiltradas.size()) : "0.00" %>
                            </span>
                        </div>
                    </div>

                    <!-- Opciones de Exportación -->
                    <div class="export-options">
                        <button class="btn btn-sm btn-success" onclick="exportarResultados()">
                            📄 Exportar a PDF
                        </button>
                        <button class="btn btn-sm btn-info" onclick="exportarExcel()">
                            📊 Exportar a Excel
                        </button>
                    </div>
                </div>
            <% } %>

            <!-- Tabla de Resultados -->
            <div class="table-container">
                <% if (facturasFiltradas == null) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔍</div>
                        <h3>Realiza una búsqueda</h3>
                        <p>Utiliza los criterios de búsqueda para encontrar facturas específicas</p>
                    </div>
                <% } else if (facturasFiltradas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">😔</div>
                        <h3>No se encontraron resultados</h3>
                        <p>No hay facturas que coincidan con tus criterios de búsqueda</p>
                        <p>Intenta con otros términos o ajusta los filtros</p>
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
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                double subtotalGeneral = 0;
                                double ivaGeneral = 0;
                                double totalGeneral = 0;
                            %>
                            <% for (Factura factura : facturasFiltradas) { 
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
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            <!-- Fila de totales -->
                            <% if (!facturasFiltradas.isEmpty()) { %>
                                <tr style="background: #f8f9fa; font-weight: bold;">
                                    <td colspan="5"><strong>TOTALES</strong></td>
                                    <td class="monto"><strong>$<%= String.format("%,.2f", subtotalGeneral) %></strong></td>
                                    <td class="monto"><strong>$<%= String.format("%,.2f", ivaGeneral) %></strong></td>
                                    <td class="monto"><strong>$<%= String.format("%,.2f", totalGeneral) %></strong></td>
                                    <td colspan="2"></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function limpiarBusqueda() {
            document.getElementById('criterio').value = '';
            document.getElementById('valor').value = '';
            document.getElementById('fechaInicio').value = '';
            document.getElementById('fechaFin').value = '';
        }
        
        function aplicarSugerencia(criterio, valor) {
            document.getElementById('criterio').value = criterio;
            document.getElementById('valor').value = valor;
            document.getElementById('valor').focus();
        }
        
        function establecerRangoMensual() {
            const hoy = new Date();
            const primerDia = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
            const ultimoDia = new Date(hoy.getFullYear(), hoy.getMonth() + 1, 0);
            
            document.getElementById('fechaInicio').value = formatDate(primerDia);
            document.getElementById('fechaFin').value = formatDate(ultimoDia);
        }
        
        function formatDate(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }
        
        function exportarResultados() {
            alert('Función de exportación a PDF será implementada');
            // Aquí se implementaría la lógica para exportar a PDF
        }
        
        function exportarExcel() {
            alert('Función de exportación a Excel será implementada');
            // Aquí se implementaría la lógica para exportar a Excel
        }
        
        // Configurar fecha por defecto para búsquedas recientes
        window.addEventListener('load', function() {
            const hoy = new Date();
            const haceUnaSemana = new Date();
            haceUnaSemana.setDate(hoy.getDate() - 7);
            
            // Si no hay fechas establecidas, sugerir última semana
            if (!document.getElementById('fechaInicio').value) {
                document.getElementById('fechaInicio').value = formatDate(haceUnaSemana);
                document.getElementById('fechaFin').value = formatDate(hoy);
            }
        });
    </script>
</body>
</html>