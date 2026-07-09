<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String tipoBusqueda = (String) request.getAttribute("tipoBusqueda");
    String criterio = (String) request.getAttribute("criterio");
    String valor = (String) request.getAttribute("valor");
    
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    List<OrdenServicio> ordenes = (List<OrdenServicio>) request.getAttribute("ordenes");
    List<OrdenServicio> consultas = (List<OrdenServicio>) request.getAttribute("consultas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Búsqueda - Atención al Cliente</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudrecepcion.css">
   
</head>
<body class="recepcionista">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-recepcionista.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <!-- Encabezado de Búsqueda -->
            <div class="search-header">
                <h1>🔍 Búsqueda Avanzada</h1>
                <p>Encuentra clientes, órdenes y consultas rápidamente</p>
            </div>

            <!-- Formulario de Búsqueda Avanzada -->
            <div class="search-form-advanced">
                <form action="${pageContext.request.contextPath}/recepcionista/atencion/buscar" method="post" class="crud-form">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="tipoBusqueda">Tipo de Búsqueda</label>
                            <select id="tipoBusqueda" name="tipo" class="form-control" required>
                                <option value="cliente" <%= "cliente".equals(tipoBusqueda) ? "selected" : "" %>>Clientes</option>
                                <option value="orden" <%= "orden".equals(tipoBusqueda) ? "selected" : "" %>>Órdenes de Servicio</option>
                                <option value="consulta" <%= "consulta".equals(tipoBusqueda) ? "selected" : "" %>>Consultas y Quejas</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="criterio">Criterio de Búsqueda</label>
                            <select id="criterio" name="criterio" class="form-control">
                                <option value="">Todos los campos</option>
                                <option value="nombre" <%= "nombre".equals(criterio) ? "selected" : "" %>>Nombre</option>
                                <option value="email" <%= "email".equals(criterio) ? "selected" : "" %>>Email</option>
                                <option value="telefono" <%= "telefono".equals(criterio) ? "selected" : "" %>>Teléfono</option>
                                <option value="problema" <%= "problema".equals(criterio) ? "selected" : "" %>>Problema Reportado</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="valor">Término de Búsqueda</label>
                            <input type="text" id="valor" name="valor" 
                                   value="<%= valor != null ? valor : "" %>" 
                                   class="form-control" 
                                   placeholder="Ingrese el término a buscar...">
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            🔍 Buscar
                        </button>
                        <a href="${pageContext.request.contextPath}/recepcionista/atencion" class="btn btn-secondary">
                            ↩️ Volver al Dashboard
                        </a>
                    </div>
                </form>
            </div>

            <!-- Pestañas de Búsqueda Rápida -->
            <div class="search-tabs">
                <div class="search-tab <%= "cliente".equals(tipoBusqueda) ? "active" : "" %>" 
                     onclick="setSearchType('cliente')">
                    👥 Buscar Clientes
                </div>
                <div class="search-tab <%= "orden".equals(tipoBusqueda) ? "active" : "" %>" 
                     onclick="setSearchType('orden')">
                    🔧 Buscar Órdenes
                </div>
                <div class="search-tab <%= "consulta".equals(tipoBusqueda) ? "active" : "" %>" 
                     onclick="setSearchType('consulta')">
                    💬 Buscar Consultas
                </div>
            </div>

            <!-- Acciones Rápidas -->
            <div class="quick-actions">
                <div class="quick-action-card" onclick="quickSearch('cliente', 'nombre', '')">
                    <span class="quick-action-icon">👥</span>
                    <strong>Ver Todos los Clientes</strong>
                    <p>Lista completa de clientes registrados</p>
                </div>
                <div class="quick-action-card" onclick="quickSearch('orden', 'problema', 'pendiente')">
                    <span class="quick-action-icon">⏳</span>
                    <strong>Órdenes Pendientes</strong>
                    <p>Órdenes que requieren atención</p>
                </div>
                <div class="quick-action-card" onclick="quickSearch('consulta', '', 'queja')">
                    <span class="quick-action-icon">📝</span>
                    <strong>Consultas Recientes</strong>
                    <p>Últimas consultas y quejas</p>
                </div>
                <div class="quick-action-card" onclick="location.href='${pageContext.request.contextPath}/recepcionista/atencion/clientes'">
                    <span class="quick-action-icon">📊</span>
                    <strong>Gestión de Clientes</strong>
                    <p>Administrar información de clientes</p>
                </div>
            </div>

            <!-- Resultados de Búsqueda -->
            <% if (tipoBusqueda != null) { %>
                <div class="search-results-info">
                    <div>
                        <span class="result-count">
                            <% 
                                int totalResultados = 0;
                                if ("cliente".equals(tipoBusqueda) && clientes != null) {
                                    totalResultados = clientes.size();
                                } else if ("orden".equals(tipoBusqueda) && ordenes != null) {
                                    totalResultados = ordenes.size();
                                } else if ("consulta".equals(tipoBusqueda) && consultas != null) {
                                    totalResultados = consultas.size();
                                }
                            %>
                            <%= totalResultados %> resultado(s) encontrado(s)
                        </span>
                        <div class="search-criteria">
                            Tipo: <strong><%= tipoBusqueda %></strong>
                            <% if (criterio != null && !criterio.isEmpty()) { %>
                                | Criterio: <strong><%= criterio %></strong>
                            <% } %>
                            <% if (valor != null && !valor.isEmpty()) { %>
                                | Término: "<strong><%= valor %></strong>"
                            <% } %>
                        </div>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/buscar" class="btn btn-outline-secondary btn-sm">
                            🗑️ Limpiar Búsqueda
                        </a>
                    </div>
                </div>

                <!-- Resultados de Clientes -->
                <% if ("cliente".equals(tipoBusqueda) && clientes != null) { %>
                    <div class="result-section">
                        <h3>👥 Clientes Encontrados</h3>
                        
                        <% if (clientes.isEmpty()) { %>
                            <div class="empty-search">
                                <div class="icon">🔍</div>
                                <h4>No se encontraron clientes</h4>
                                <p>Intenta con otros términos de búsqueda</p>
                            </div>
                        <% } else { %>
                            <div class="table-container">
                                <table class="crud-table">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Nombre Completo</th>
                                            <th>Email</th>
                                            <th>Teléfono</th>
                                            <th>Fecha Registro</th>
                                            <th>Vehículos</th>
                                            <th class="actions-column">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Cliente cliente : clientes) { %>
                                            <tr>
                                                <td>#<%= cliente.getIDCliente() %></td>
                                                <td>
                                                    <strong><%= cliente.getNombre() %> <%= cliente.getApellido() %></strong>
                                                    <% if (valor != null && !valor.isEmpty() && 
                                                          (cliente.getNombre().toLowerCase().contains(valor.toLowerCase()) || 
                                                           cliente.getApellido().toLowerCase().contains(valor.toLowerCase()))) { %>
                                                        <span class="badge badge-info">Coincidencia</span>
                                                    <% } %>
                                                </td>
                                                <td><%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></td>
                                                <td><%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></td>
                                                <td><%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %></td>
                                                <td>
                                                    <span class="badge <%= (cliente.getVehiculoList() != null && !cliente.getVehiculoList().isEmpty()) ? "badge-success" : "badge-secondary" %>">
                                                        <%= (cliente.getVehiculoList() != null ? cliente.getVehiculoList().size() : 0) %> vehículos
                                                    </span>
                                                </td>
                                                <td class="actions-column">
                                                    <div class="action-buttons">
                                                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= cliente.getIDCliente() %>" 
                                                           class="btn btn-sm btn-info" title="Ver historial">
                                                            📋 Historial
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/recepcionista/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                                                           class="btn btn-sm btn-warning" title="Editar cliente">
                                                            ✏️ Editar
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                <% } %>

                <!-- Resultados de Órdenes -->
                <% if ("orden".equals(tipoBusqueda) && ordenes != null) { %>
                    <div class="result-section">
                        <h3>🔧 Órdenes de Servicio Encontradas</h3>
                        
                        <% if (ordenes.isEmpty()) { %>
                            <div class="empty-search">
                                <div class="icon">🔧</div>
                                <h4>No se encontraron órdenes</h4>
                                <p>Intenta con otros términos de búsqueda</p>
                            </div>
                        <% } else { %>
                            <div class="table-container">
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
                                                        N/A
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
                                                    <% if (valor != null && !valor.isEmpty() && 
                                                          orden.getProblemaReportado() != null && 
                                                          orden.getProblemaReportado().toLowerCase().contains(valor.toLowerCase())) { %>
                                                        <span class="badge badge-info">Coincidencia</span>
                                                    <% } %>
                                                </td>
                                                <td><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></td>
                                                <td>
                                                    <% 
                                                        String estadoClase = "badge-warning";
                                                        String estadoTexto = "Pendiente";
                                                        
                                                        if (orden.getFechaRealSalida() != null) {
                                                            estadoClase = "badge-success";
                                                            estadoTexto = "Completada";
                                                        } else if (orden.getIDEstadoTrabajo() != null) {
                                                            estadoTexto = orden.getIDEstadoTrabajo().getNombreEstado();
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
                            </div>
                        <% } %>
                    </div>
                <% } %>

                <!-- Resultados de Consultas -->
                <% if ("consulta".equals(tipoBusqueda) && consultas != null) { %>
                    <div class="result-section">
                        <h3>💬 Consultas y Quejas Encontradas</h3>
                        
                        <% if (consultas.isEmpty()) { %>
                            <div class="empty-search">
                                <div class="icon">💬</div>
                                <h4>No se encontraron consultas</h4>
                                <p>Intenta con otros términos de búsqueda</p>
                            </div>
                        <% } else { %>
                            <div class="table-container">
                                <table class="crud-table">
                                    <thead>
                                        <tr>
                                            <th>ID Orden</th>
                                            <th>Cliente</th>
                                            <th>Problema Reportado</th>
                                            <th>Observaciones</th>
                                            <th>Fecha</th>
                                            <th>Estado</th>
                                            <th class="actions-column">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (OrdenServicio consulta : consultas) { %>
                                            <tr>
                                                <td>#<%= consulta.getIDOrdenServicio() %></td>
                                                <td>
                                                    <% if (consulta.getIDVehiculo() != null && consulta.getIDVehiculo().getIDCliente() != null) { %>
                                                        <%= consulta.getIDVehiculo().getIDCliente().getNombre() %> 
                                                        <%= consulta.getIDVehiculo().getIDCliente().getApellido() %>
                                                    <% } else { %>
                                                        N/A
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <%= consulta.getProblemaReportado() != null ? 
                                                           (consulta.getProblemaReportado().length() > 60 ? 
                                                            consulta.getProblemaReportado().substring(0, 60) + "..." : 
                                                            consulta.getProblemaReportado()) : "N/A" %>
                                                    <% if (valor != null && !valor.isEmpty() && 
                                                          consulta.getProblemaReportado() != null && 
                                                          consulta.getProblemaReportado().toLowerCase().contains(valor.toLowerCase())) { %>
                                                        <span class="badge badge-warning">Coincidencia</span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <%= consulta.getObservaciones() != null ? 
                                                           (consulta.getObservaciones().length() > 60 ? 
                                                            consulta.getObservaciones().substring(0, 60) + "..." : 
                                                            consulta.getObservaciones()) : "Sin observaciones" %>
                                                    <% if (valor != null && !valor.isEmpty() && 
                                                          consulta.getObservaciones() != null && 
                                                          consulta.getObservaciones().toLowerCase().contains(valor.toLowerCase())) { %>
                                                        <span class="badge badge-warning">Coincidencia</span>
                                                    <% } %>
                                                </td>
                                                <td><%= consulta.getFechaEntrada() != null ? consulta.getFechaEntrada() : "N/A" %></td>
                                                <td>
                                                    <% 
                                                        String estadoClase = "badge-warning";
                                                        String estadoTexto = "Pendiente";
                                                        
                                                        if (consulta.getFechaRealSalida() != null) {
                                                            estadoClase = "badge-success";
                                                            estadoTexto = "Completada";
                                                        } else if (consulta.getIDEstadoTrabajo() != null) {
                                                            estadoTexto = consulta.getIDEstadoTrabajo().getNombreEstado();
                                                            if ("EN PROCESO".equals(estadoTexto)) {
                                                                estadoClase = "badge-info";
                                                            }
                                                        }
                                                    %>
                                                    <span class="badge <%= estadoClase %>"><%= estadoTexto %></span>
                                                </td>
                                                <td class="actions-column">
                                                    <div class="action-buttons">
                                                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes/ver?id=<%= consulta.getIDOrdenServicio() %>" 
                                                           class="btn btn-sm btn-info" title="Ver detalles">
                                                            👁️ Ver
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= 
                                                           consulta.getIDVehiculo() != null && consulta.getIDVehiculo().getIDCliente() != null ? 
                                                           consulta.getIDVehiculo().getIDCliente().getIDCliente() : "" %>" 
                                                           class="btn btn-sm btn-secondary" title="Historial cliente">
                                                            📋 Historial
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            <% } else { %>
                <!-- Estado inicial - Sin búsqueda -->
                <div class="empty-search">
                    <div class="icon">🔍</div>
                    <h4>Realiza una búsqueda</h4>
                    <p>Utiliza el formulario superior para buscar clientes, órdenes o consultas</p>
                    <div class="quick-actions" style="margin-top: 30px; max-width: 600px; margin-left: auto; margin-right: auto;">
                        <div class="quick-action-card" onclick="quickSearch('cliente', 'nombre', '')">
                            <span class="quick-action-icon">👥</span>
                            <strong>Explorar Clientes</strong>
                            <p>Ver todos los clientes registrados</p>
                        </div>
                        <div class="quick-action-card" onclick="quickSearch('orden', '', '')">
                            <span class="quick-action-icon">🔧</span>
                            <strong>Explorar Órdenes</strong>
                            <p>Ver todas las órdenes de servicio</p>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function setSearchType(tipo) {
            document.getElementById('tipoBusqueda').value = tipo;
            // Actualizar pestañas activas
            document.querySelectorAll('.search-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            event.target.classList.add('active');
        }
        
        function quickSearch(tipo, criterio, valor) {
            document.getElementById('tipoBusqueda').value = tipo;
            document.getElementById('criterio').value = criterio;
            document.getElementById('valor').value = valor;
            document.querySelector('form').submit();
        }
        
        // Actualizar pestañas cuando cambie el select
        document.getElementById('tipoBusqueda').addEventListener('change', function() {
            const tipo = this.value;
            document.querySelectorAll('.search-tab').forEach(tab => {
                tab.classList.remove('active');
                if (tab.textContent.toLowerCase().includes(tipo)) {
                    tab.classList.add('active');
                }
            });
        });
        
        // Inicializar pestañas activas
        window.addEventListener('load', function() {
            const tipoBusqueda = '<%= tipoBusqueda != null ? tipoBusqueda : "cliente" %>';
            document.querySelectorAll('.search-tab').forEach(tab => {
                if (tab.textContent.toLowerCase().includes(tipoBusqueda)) {
                    tab.classList.add('active');
                }
            });
        });
    </script>
</body>
</html>