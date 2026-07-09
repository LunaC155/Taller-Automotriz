<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buscar Órdenes - Recepcionista</title>
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
                <h1>🔍 Buscar Órdenes de Servicio</h1>
                <p>Encuentra órdenes específicas utilizando diferentes criterios de búsqueda</p>
            </div>

            <!-- Formulario de Búsqueda -->
            <div class="search-container">
                <form action="${pageContext.request.contextPath}/recepcionista/ordenes/buscar" method="get" class="crud-form">
                    <div class="form-group">
                        <label for="valor">Término de Búsqueda</label>
                        <input type="text" id="valor" name="valor" 
                               value="<%= valor != null ? valor : "" %>" 
                               class="form-control" 
                               placeholder="Ingrese placa, nombre del cliente, problema, etc...">
                        <small class="form-text">Buscar por placa, cliente, problema reportado, marca, modelo, etc.</small>
                    </div>

                    <div class="form-group">
                        <label for="criterio">Criterio de Búsqueda</label>
                        <select id="criterio" name="criterio" class="form-control">
                            <option value="todo" <%= "todo".equals(criterio) ? "selected" : "" %>>Todo (Búsqueda general)</option>
                            <option value="placa" <%= "placa".equals(criterio) ? "selected" : "" %>>Por Placa del Vehículo</option>
                            <option value="cliente" <%= "cliente".equals(criterio) ? "selected" : "" %>>Por Nombre del Cliente</option>
                            <option value="problema" <%= "problema".equals(criterio) ? "selected" : "" %>>Por Problema Reportado</option>
                            <option value="marca" <%= "marca".equals(criterio) ? "selected" : "" %>>Por Marca del Vehículo</option>
                            <option value="estado" <%= "estado".equals(criterio) ? "selected" : "" %>>Por Estado de la Orden</option>
                        </select>
                    </div>

                    <!-- Filtros Adicionales -->
                    <div class="search-form-advanced">
                        <div class="form-group">
                            <label for="fechaInicio">Fecha de Entrada (Desde)</label>
                            <input type="date" id="fechaInicio" name="fechaInicio" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="fechaFin">Fecha de Entrada (Hasta)</label>
                            <input type="date" id="fechaFin" name="fechaFin" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="estadoTrabajo">Estado del Trabajo</label>
                            <select id="estadoTrabajo" name="estadoTrabajo" class="form-control">
                                <option value="">Todos los estados</option>
                                <option value="CITA PROGRAMADA">Cita Programada</option>
                                <option value="PENDIENTE">Pendiente</option>
                                <option value="EN PROCESO">En Proceso</option>
                                <option value="COMPLETADO">Completado</option>
                                <option value="CANCELADO">Cancelado</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            🔍 Buscar Órdenes
                        </button>
                        <button type="reset" class="btn btn-secondary">
                            🗑️ Limpiar
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-info">
                            ↩️ Ver Todas las Órdenes
                        </a>
                    </div>
                </form>
            </div>

            <!-- Filtros Rápidos -->
            <div class="quick-filters">
                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/buscar?criterio=estado&valor=PENDIENTE" 
                   class="quick-filter <%= "PENDIENTE".equals(valor) ? "active" : "" %>">
                    ⏳ Pendientes
                </a>
                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/buscar?criterio=estado&valor=EN PROCESO" 
                   class="quick-filter <%= "EN PROCESO".equals(valor) ? "active" : "" %>">
                    🔧 En Proceso
                </a>
                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/buscar?criterio=estado&valor=COMPLETADO" 
                   class="quick-filter <%= "COMPLETADO".equals(valor) ? "active" : "" %>">
                    ✅ Completadas
                </a>
                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/buscar?criterio=estado&valor=CITA PROGRAMADA" 
                   class="quick-filter <%= "CITA PROGRAMADA".equals(valor) ? "active" : "" %>">
                    📅 Citas Programadas
                </a>
                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/buscar?criterio=estado&valor=CANCELADO" 
                   class="quick-filter <%= "CANCELADO".equals(valor) ? "active" : "" %>">
                    ❌ Canceladas
                </a>
            </div>

            <!-- Resultados de Búsqueda -->
            <% if (criterio != null && valor != null) { %>
                <div class="search-results-info">
                    <div>
                        <h3>Resultados de Búsqueda</h3>
                        <p>
                            Criterio: <strong><%= criterio %></strong> | 
                            Valor: <strong>"<%= valor %>"</strong> | 
                            Encontrados: <strong><%= ordenes != null ? ordenes.size() : 0 %></strong> órdenes
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">
                        ↩️ Ver todas
                    </a>
                </div>
            <% } %>

            <!-- Tabla de Resultados -->
            <div class="table-container">
                <% if (ordenes == null || ordenes.isEmpty()) { 
                    if (criterio != null && valor != null) { %>
                        <div class="empty-state">
                            <div class="empty-icon">🔍</div>
                            <h3>No se encontraron órdenes</h3>
                            <p>No hay órdenes que coincidan con tu búsqueda: "<strong><%= valor %></strong>"</p>
                            <div class="suggestions">
                                <p>Sugerencias:</p>
                                <ul>
                                    <li>Verifica la ortografía</li>
                                    <li>Utiliza términos más generales</li>
                                    <li>Prueba con otro criterio de búsqueda</li>
                                </ul>
                            </div>
                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-primary">
                                Ver Todas las Órdenes
                            </a>
                        </div>
                    <% } %>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Vehículo</th>
                                <th>Cliente</th>
                                <th>Problema</th>
                                <th>Fecha Entrada</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio orden : ordenes) { %>
                                <tr>
                                    <td>#<%= orden.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (orden.getIDVehiculo() != null) { %>
                                            <strong><%= orden.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            <span class="badge badge-warning">Por asignar</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null) { %>
                                            <%= orden.getIDVehiculo().getIDCliente().getNombre() %> 
                                            <%= orden.getIDVehiculo().getIDCliente().getApellido() %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= orden.getProblemaReportado() != null ? 
                                               (orden.getProblemaReportado().length() > 50 ? 
                                                orden.getProblemaReportado().substring(0, 50) + "..." : 
                                                orden.getProblemaReportado()) : "N/A" %>
                                    </td>
                                    <td><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "PENDIENTE";
                                            
                                            if (orden.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "COMPLETADA";
                                            } else if (orden.getIDEstadoTrabajo() != null) {
                                                estadoTexto = orden.getIDEstadoTrabajo().getNombreEstado();
                                                if ("EN PROCESO".equals(estadoTexto)) {
                                                    estadoClase = "badge-info";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-danger";
                                                } else if ("CITA PROGRAMADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-primary";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️ Ver
                                            </a>
                                            
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/editar?id=<%= orden.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-warning" title="Editar orden">
                                                ✏️ Editar
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Información de resultados -->
                    <div class="table-info">
                        <p>Órdenes encontradas: <strong><%= ordenes.size() %></strong></p>
                        <% if (criterio != null && valor != null) { %>
                            <p class="search-context">
                                Búsqueda: <em>"<%= valor %>"</em> en <strong><%= criterio %></strong>
                            </p>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <!-- Opciones de Exportación -->
            <% if (ordenes != null && !ordenes.isEmpty()) { %>
                <div class="export-options">
                    <h4>📊 Exportar Resultados</h4>
                    <div class="export-buttons">
                        <button class="btn btn-outline-primary" onclick="exportToPDF()">📄 Exportar a PDF</button>
                        <button class="btn btn-outline-success" onclick="exportToExcel()">📊 Exportar a Excel</button>
                        <button class="btn btn-outline-info" onclick="printResults()">🖨️ Imprimir Resultados</button>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Funciones de exportación (placeholder)
        function exportToPDF() {
            alert('Funcionalidad de exportación a PDF en desarrollo');
        }
        
        function exportToExcel() {
            alert('Funcionalidad de exportación a Excel en desarrollo');
        }
        
        function printResults() {
            window.print();
        }
        
        // Mejorar la experiencia de búsqueda
        document.getElementById('valor').addEventListener('input', function() {
            const searchTerm = this.value.trim();
            if (searchTerm.length >= 2) {
                // Aquí podrías implementar búsqueda en tiempo real
                console.log('Buscando:', searchTerm);
            }
        });
        
        // Establecer fechas por defecto para búsqueda del último mes
        window.addEventListener('load', function() {
            const today = new Date();
            const lastMonth = new Date();
            lastMonth.setMonth(today.getMonth() - 1);
            
            document.getElementById('fechaInicio').value = lastMonth.toISOString().split('T')[0];
            document.getElementById('fechaFin').value = today.toISOString().split('T')[0];
        });
    </script>
</body>
</html>