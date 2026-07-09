<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%@page import="java.util.Date" %>
<%
    // Verificar sesión de recepcionista
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> citas = (List<OrdenServicio>) request.getAttribute("citas");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Búsqueda Avanzada - Recepcionista</title>
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
                <h1>🔍 Búsqueda Avanzada de Citas</h1>
                <p>Encuentra citas específicas usando múltiples criterios de búsqueda</p>
            </div>

            <!-- Panel de Búsqueda -->
            <div class="search-panel">
                <div class="search-tabs">
                    <button class="search-tab active" onclick="mostrarTab('tab-basica')">Búsqueda Básica</button>
                    <button class="search-tab" onclick="mostrarTab('tab-avanzada')">Búsqueda Avanzada</button>
                    <button class="search-tab" onclick="mostrarTab('tab-fechas')">Por Fechas</button>
                    <button class="search-tab" onclick="mostrarTab('tab-estados')">Por Estados</button>
                </div>

                <!-- Búsqueda Básica -->
                <div id="tab-basica" class="tab-content active">
                    <form action="${pageContext.request.contextPath}/recepcionista/citas/buscar" method="get" class="search-form">
                        <div class="form-group">
                            <label for="criterioBasico">Buscar por:</label>
                            <select id="criterioBasico" name="criterio" class="form-control">
                                <option value="cliente" <%= "cliente".equals(criterio) ? "selected" : "" %>>Nombre del Cliente</option>
                                <option value="vehiculo" <%= "vehiculo".equals(criterio) ? "selected" : "" %>>Placa del Vehículo</option>
                                <option value="problema" <%= "problema".equals(criterio) ? "selected" : "" %>>Problema Reportado</option>
                                <option value="todo" <%= criterio == null || "todo".equals(criterio) ? "selected" : "" %>>Todos los Campos</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="valorBasico">Término de búsqueda:</label>
                            <input type="text" id="valorBasico" name="valor" 
                                   value="<%= valor != null ? valor : "" %>" 
                                   class="form-control" placeholder="Ingrese el término a buscar...">
                        </div>
                        <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                        <a href="${pageContext.request.contextPath}/recepcionista/citas/buscar" class="btn btn-secondary">Limpiar</a>
                    </form>
                </div>

                <!-- Búsqueda Avanzada -->
                <div id="tab-avanzada" class="tab-content">
                    <form action="${pageContext.request.contextPath}/recepcionista/citas/buscar" method="get" class="search-form">
                        <div class="search-form-grid">
                            <div class="form-group">
                                <label for="clienteAvanzado">Cliente:</label>
                                <input type="text" id="clienteAvanzado" name="cliente" class="form-control" placeholder="Nombre del cliente...">
                            </div>
                            <div class="form-group">
                                <label for="vehiculoAvanzado">Vehículo:</label>
                                <input type="text" id="vehiculoAvanzado" name="vehiculo" class="form-control" placeholder="Placa del vehículo...">
                            </div>
                            <div class="form-group">
                                <label for="problemaAvanzado">Problema:</label>
                                <input type="text" id="problemaAvanzado" name="problema" class="form-control" placeholder="Problema reportado...">
                            </div>
                            <div class="form-group">
                                <label for="empleadoAvanzado">Recepcionista:</label>
                                <input type="text" id="empleadoAvanzado" name="empleado" class="form-control" placeholder="ID del empleado...">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">🔍 Buscar Avanzada</button>
                        <button type="reset" class="btn btn-secondary">Limpiar Campos</button>
                    </form>
                </div>

                <!-- Búsqueda por Fechas -->
                <div id="tab-fechas" class="tab-content">
                    <form action="${pageContext.request.contextPath}/recepcionista/citas/buscar" method="get" class="search-form">
                        <div class="search-form-grid">
                            <div class="form-group">
                                <label for="fechaDesde">Fecha Desde:</label>
                                <input type="date" id="fechaDesde" name="fechaDesde" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="fechaHasta">Fecha Hasta:</label>
                                <input type="date" id="fechaHasta" name="fechaHasta" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="tipoFecha">Tipo de Fecha:</label>
                                <select id="tipoFecha" name="tipoFecha" class="form-control">
                                    <option value="entrada">Fecha de Entrada</option>
                                    <option value="estimada">Fecha Estimada Salida</option>
                                    <option value="real">Fecha Real Salida</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">📅 Buscar por Fechas</button>
                    </form>
                </div>

                <!-- Búsqueda por Estados -->
                <div id="tab-estados" class="tab-content">
                    <form action="${pageContext.request.contextPath}/recepcionista/citas/buscar" method="get" class="search-form">
                        <div class="search-form-grid">
                            <div class="form-group">
                                <label>Estado del Trabajo:</label>
                                <div>
                                    <div class="form-check">
                                        <input type="checkbox" id="estadoPendiente" name="estados" value="PENDIENTE" class="form-check-input">
                                        <label for="estadoPendiente" class="form-check-label">Pendiente</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="checkbox" id="estadoProceso" name="estados" value="EN PROCESO" class="form-check-input">
                                        <label for="estadoProceso" class="form-check-label">En Proceso</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="checkbox" id="estadoCompletado" name="estados" value="COMPLETADO" class="form-check-input">
                                        <label for="estadoCompletado" class="form-check-label">Completado</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="checkbox" id="estadoCancelado" name="estados" value="CANCELADO" class="form-check-input">
                                        <label for="estadoCancelado" class="form-check-label">Cancelado</label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Prioridad:</label>
                                <div>
                                    <div class="form-check">
                                        <input type="radio" id="prioridadTodas" name="prioridad" value="todas" class="form-check-input" checked>
                                        <label for="prioridadTodas" class="form-check-label">Todas</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="radio" id="prioridadAlta" name="prioridad" value="alta" class="form-check-input">
                                        <label for="prioridadAlta" class="form-check-label">Alta</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="radio" id="prioridadMedia" name="prioridad" value="media" class="form-check-input">
                                        <label for="prioridadMedia" class="form-check-label">Media</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="radio" id="prioridadBaja" name="prioridad" value="baja" class="form-check-input">
                                        <label for="prioridadBaja" class="form-check-label">Baja</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">📊 Buscar por Estados</button>
                    </form>
                </div>
            </div>

            <!-- Información de Resultados -->
            <% if (criterio != null || valor != null) { %>
                <div class="search-results-info">
                    <h4>Resultados de Búsqueda</h4>
                    <p>
                        Se encontraron <strong><%= citas != null ? citas.size() : 0 %></strong> citas 
                        <% if (criterio != null && valor != null) { %>
                            para <strong><%= criterio %></strong>: "<strong><%= valor %></strong>"
                        <% } %>
                    </p>
                    
                    <% if (criterio != null && valor != null) { %>
                        <div class="filter-tags">
                            <span class="filter-tag">
                                <%= criterio %>: <%= valor %>
                                <span class="remove" onclick="window.location.href='${pageContext.request.contextPath}/recepcionista/citas/buscar'">×</span>
                            </span>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Estadísticas Rápidas -->
            <% if (citas != null && !citas.isEmpty()) { %>
                <div class="search-stats">
                    <div class="stat-card">
                        <span class="stat-number"><%= citas.size() %></span>
                        <span class="stat-label">Total Encontrado</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-number">
                            <%= citas.stream().filter(c -> c.getFechaRealSalida() == null).count() %>
                        </span>
                        <span class="stat-label">Pendientes</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-number">
                            <%= citas.stream().filter(c -> c.getFechaRealSalida() != null).count() %>
                        </span>
                        <span class="stat-label">Completadas</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-number">
                            <%= citas.stream().filter(c -> c.getFechaEstimadaSalida() != null && c.getFechaEstimadaSalida().before(new Date())).count() %>
                        </span>
                        <span class="stat-label">Atrasadas</span>
                    </div>
                </div>
            <% } %>

            <!-- Resultados -->
            <div class="table-container">
                <% if (citas == null || citas.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">🔍</div>
                        <h3>No se encontraron citas</h3>
                        <p>
                            <% if (criterio != null || valor != null) { %>
                                No hay citas que coincidan con tus criterios de búsqueda.
                            <% } else { %>
                                Realiza una búsqueda para ver los resultados.
                            <% } %>
                        </p>
                        <a href="${pageContext.request.contextPath}/recepcionista/citas" class="btn btn-primary">
                            Ver Todas las Citas
                        </a>
                    </div>
                <% } else { %>
                    <table class="crud-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Cliente</th>
                                <th>Vehículo</th>
                                <th>Problema</th>
                                <th>Fecha Entrada</th>
                                <th>Fecha Est. Salida</th>
                                <th>Estado</th>
                                <th class="actions-column">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (OrdenServicio cita : citas) { %>
                                <tr>
                                    <td>#<%= cita.getIDOrdenServicio() %></td>
                                    <td>
                                        <% if (cita.getIDVehiculo() != null && cita.getIDVehiculo().getIDCliente() != null) { %>
                                            <strong><%= cita.getIDVehiculo().getIDCliente().getNombre() %> <%= cita.getIDVehiculo().getIDCliente().getApellido() %></strong>
                                            <div class="client-info">
                                                <%= cita.getIDVehiculo().getIDCliente().getTelefono() != null ? cita.getIDVehiculo().getIDCliente().getTelefono() : "Sin teléfono" %>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted">Cliente no disponible</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (cita.getIDVehiculo() != null) { %>
                                            <strong><%= cita.getIDVehiculo().getPlaca() %></strong><br>
                                            <small>
                                                <%= cita.getIDVehiculo().getIDMarca() != null ? cita.getIDVehiculo().getIDMarca().getNombreMarca() : "" %> 
                                                <%= cita.getIDVehiculo().getIDModelo() != null ? cita.getIDVehiculo().getIDModelo().getNombreModelo() : "" %>
                                            </small>
                                        <% } else { %>
                                            <span class="text-muted">Vehículo no disponible</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= cita.getProblemaReportado() != null ? 
                                           (cita.getProblemaReportado().length() > 50 ? 
                                            cita.getProblemaReportado().substring(0, 50) + "..." : 
                                            cita.getProblemaReportado()) : "N/A" %>
                                    </td>
                                    <td>
                                        <%= cita.getFechaEntrada() != null ? 
                                            new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(cita.getFechaEntrada()) : "N/A" %>
                                    </td>
                                    <td>
                                        <%= cita.getFechaEstimadaSalida() != null ? 
                                            new java.text.SimpleDateFormat("dd/MM/yyyy").format(cita.getFechaEstimadaSalida()) : "Por definir" %>
                                        <% if (cita.getFechaEstimadaSalida() != null && cita.getFechaEstimadaSalida().before(new Date())) { %>
                                            <span style="color: #dc3545; font-size: 0.8em;">⚠️ Atrasada</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% 
                                            String estadoClase = "badge-warning";
                                            String estadoTexto = "Pendiente";
                                            
                                            if (cita.getFechaRealSalida() != null) {
                                                estadoClase = "badge-success";
                                                estadoTexto = "Completada";
                                            } else if (cita.getIDEstadoTrabajo() != null) {
                                                estadoTexto = cita.getIDEstadoTrabajo().getNombreEstado();
                                                if ("EN PROCESO".equals(estadoTexto)) {
                                                    estadoClase = "badge-info";
                                                } else if ("CANCELADA".equals(estadoTexto)) {
                                                    estadoClase = "badge-danger";
                                                }
                                            }
                                        %>
                                        <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                    </td>
                                    <td class="actions-column">
                                        <div class="action-buttons">
                                            <a href="${pageContext.request.contextPath}/recepcionista/citas/ver?id=<%= cita.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-info" title="Ver detalles">
                                                👁️
                                            </a>
                                            <a href="${pageContext.request.contextPath}/recepcionista/citas/editar?id=<%= cita.getIDOrdenServicio() %>" 
                                               class="btn btn-sm btn-warning" title="Editar">
                                                ✏️
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Opciones de Exportación -->
                    <div class="export-options">
                        <button class="btn btn-outline-success" onclick="exportarPDF()">📄 Exportar a PDF</button>
                        <button class="btn btn-outline-primary" onclick="exportarExcel()">📊 Exportar a Excel</button>
                        <button class="btn btn-outline-secondary" onclick="imprimirResultados()">🖨️ Imprimir</button>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Funciones para cambiar pestañas
        function mostrarTab(tabId) {
            // Ocultar todos los tabs
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Remover active de todos los botones
            document.querySelectorAll('.search-tab').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Mostrar tab seleccionado
            document.getElementById(tabId).classList.add('active');
            
            // Activar botón
            event.target.classList.add('active');
        }

        // Funciones de exportación (placeholder)
        function exportarPDF() {
            alert('Funcionalidad de exportación PDF en desarrollo');
        }

        function exportarExcel() {
            alert('Funcionalidad de exportación Excel en desarrollo');
        }

        function imprimirResultados() {
            window.print();
        }

        // Auto-enfocar en campo de búsqueda básica
        document.addEventListener('DOMContentLoaded', function() {
            const valorBasico = document.getElementById('valorBasico');
            if (valorBasico) {
                valorBasico.focus();
            }
            
            // Resaltar términos de búsqueda en los resultados
            const searchTerm = '<%= valor != null ? valor : "" %>';
            if (searchTerm) {
                highlightSearchTerm(searchTerm);
            }
        });

        function highlightSearchTerm(term) {
            const tables = document.querySelectorAll('.crud-table');
            tables.forEach(table => {
                const cells = table.querySelectorAll('td');
                cells.forEach(cell => {
                    const originalText = cell.textContent;
                    const regex = new RegExp(term, 'gi');
                    const highlightedText = originalText.replace(regex, match => 
                        `<span class="highlight">${match}</span>`
                    );
                    if (highlightedText !== originalText) {
                        cell.innerHTML = highlightedText;
                    }
                });
            });
        }

        // Atajos de teclado para búsqueda
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.key === 'f') {
                e.preventDefault();
                document.getElementById('valorBasico').focus();
            }
        });
    </script>
</body>
</html>