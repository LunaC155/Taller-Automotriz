<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Cliente> clientesSeguimiento = (List<Cliente>) request.getAttribute("clientesSeguimiento");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seguimiento de Clientes - Atención al Cliente</title>
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
                <h1>📊 Seguimiento de Clientes</h1>
                <p>Realiza seguimiento a clientes con órdenes pendientes y necesidades de atención</p>
            </div>

            <!-- Estadísticas Rápidas -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-info">
                        <h3><%= clientesSeguimiento != null ? clientesSeguimiento.size() : 0 %></h3>
                        <p>Clientes con Seguimiento</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-info">
                        <h3><%= clientesSeguimiento != null ? 
                              clientesSeguimiento.stream().filter(c -> 
                                  c.getVehiculoList() != null && 
                                  c.getVehiculoList().stream().anyMatch(v -> 
                                      v.getOrdenServicioList() != null &&
                                      v.getOrdenServicioList().stream().anyMatch(o -> 
                                          o.getFechaRealSalida() == null &&
                                          o.getFechaEstimadaSalida() != null &&
                                          o.getFechaEstimadaSalida().before(new java.util.Date())
                                      )
                                  )
                              ).count() : 0 %>
                        </h3>
                        <p>Con Retrasos</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">📞</div>
                    <div class="stat-info">
                        <h3><%= clientesSeguimiento != null ? 
                              clientesSeguimiento.stream().filter(c -> 
                                  c.getVehiculoList() != null && 
                                  c.getVehiculoList().size() > 2
                              ).count() : 0 %>
                        </h3>
                        <p>Clientes Frecuentes</p>
                    </div>
                </div>
            </div>

            <!-- Filtros -->
            <div class="crud-actions">
                <div class="actions-left">
                    <a href="${pageContext.request.contextPath}/recepcionista/atencion" class="btn btn-secondary">
                        <span class="btn-icon">↩️</span> Volver al Dashboard
                    </a>
                    <div class="filter-buttons">
                        <button class="btn btn-outline-danger btn-sm" onclick="filtrarSeguimiento('urgente')">🔴 Urgente</button>
                        <button class="btn btn-outline-warning btn-sm" onclick="filtrarSeguimiento('medio')">🟡 Medio</button>
                        <button class="btn btn-outline-success btn-sm" onclick="filtrarSeguimiento('bajo')">🟢 Bajo</button>
                        <button class="btn btn-outline-secondary btn-sm" onclick="filtrarSeguimiento('todos')">Todos</button>
                    </div>
                </div>
                <div class="actions-right">
                    <form action="${pageContext.request.contextPath}/recepcionista/atencion/buscar" method="get" class="search-form">
                        <input type="hidden" name="tipo" value="cliente">
                        <input type="hidden" name="criterio" value="nombre">
                        <input type="text" name="valor" placeholder="Buscar cliente..." class="form-control">
                        <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                    </form>
                </div>
            </div>

            <!-- Lista de Clientes para Seguimiento -->
            <div class="table-container">
                <% if (clientesSeguimiento == null || clientesSeguimiento.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📊</div>
                        <h3>No hay clientes para seguimiento</h3>
                        <p>Todos los clientes están al día o no tienen órdenes pendientes que requieran seguimiento.</p>
                    </div>
                <% } else { %>
                    <div class="followup-list">
                        <% for (Cliente cliente : clientesSeguimiento) { 
                            String prioridad = determinarPrioridadSeguimiento(cliente);
                            String prioridadClase = prioridad + "-followup";
                        %>
                            <div class="followup-card <%= prioridadClase %>">
                                <div class="followup-header">
                                    <div class="client-info">
                                        <h3><%= cliente.getNombre() %> <%= cliente.getApellido() %></h3>
                                        <div class="client-contact">
                                            📞 <%= cliente.getTelefono() != null ? cliente.getTelefono() : "Sin teléfono" %> | 
                                            📧 <%= cliente.getEmail() != null ? cliente.getEmail() : "Sin email" %>
                                        </div>
                                        <div class="client-stats">
                                            <small>
                                                🚗 Vehículos: <%= cliente.getVehiculoList() != null ? cliente.getVehiculoList().size() : 0 %> | 
                                                📋 Órdenes activas: <%= contarOrdenesPendientes(cliente) %>
                                            </small>
                                        </div>
                                    </div>
                                    <div class="followup-status">
                                        <span class="badge badge-<%= obtenerClaseBadgePrioridad(prioridad) %>">
                                            Prioridad <%= prioridad.substring(0, 1).toUpperCase() + prioridad.substring(1) %>
                                        </span>
                                        <div class="last-contact">
                                            <small>Último contacto: <%= obtenerUltimoContacto(cliente) %></small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Órdenes Pendientes -->
                                <% if (cliente.getVehiculoList() != null && !cliente.getVehiculoList().isEmpty()) { %>
                                    <div class="pending-orders">
                                        <h4>🔄 Órdenes Pendientes</h4>
                                        <% for (com.upec.model.Vehiculo vehiculo : cliente.getVehiculoList()) { 
                                            if (vehiculo.getOrdenServicioList() != null) {
                                                for (com.upec.model.OrdenServicio orden : vehiculo.getOrdenServicioList()) {
                                                    if (orden.getFechaRealSalida() == null) { %>
                                                        <div class="order-item">
                                                            <div class="order-info">
                                                                <h4>Orden #<%= orden.getIDOrdenServicio() %> - <%= vehiculo.getPlaca() %></h4>
                                                                <div class="order-details">
                                                                    <strong>Problema:</strong> 
                                                                    <%= orden.getProblemaReportado() != null ? 
                                                                        (orden.getProblemaReportado().length() > 60 ? 
                                                                         orden.getProblemaReportado().substring(0, 60) + "..." : 
                                                                         orden.getProblemaReportado()) : "Sin descripción" %>
                                                                    <br>
                                                                    <strong>Entrada:</strong> <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %> | 
                                                                    <strong>Estimada salida:</strong> <%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %>
                                                                    <% if (orden.getFechaEstimadaSalida() != null && orden.getFechaEstimadaSalida().before(new java.util.Date())) { %>
                                                                        <span class="badge badge-danger">Retrasada</span>
                                                                    <% } %>
                                                                </div>
                                                            </div>
                                                            <div class="order-actions">
                                                                <a href="${pageContext.request.contextPath}/recepcionista/ordenes/detalle?id=<%= orden.getIDOrdenServicio() %>" 
                                                                   class="btn btn-sm btn-primary">Ver Orden</a>
                                                            </div>
                                                        </div>
                                                    <% }
                                                }
                                            }
                                        } %>
                                    </div>
                                <% } %>

                                <!-- Historial de Contacto (simulado) -->
                                <div class="contact-history">
                                    <h5>📞 Historial de Contacto</h5>
                                    <div class="history-item">
                                        <span>Llamada de seguimiento</span>
                                        <small>Hace 2 días</small>
                                    </div>
                                    <div class="history-item">
                                        <span>Email con actualización</span>
                                        <small>Hace 5 días</small>
                                    </div>
                                    <div class="history-item">
                                        <span>Recepción del vehículo</span>
                                        <small>Hace 1 semana</small>
                                    </div>
                                </div>

                                <!-- Acciones de Seguimiento -->
                                <div class="followup-actions">
                                    <button class="btn btn-sm btn-success" 
                                            onclick="registrarContacto(<%= cliente.getIDCliente() %>, 'llamada')">
                                        📞 Llamar al Cliente
                                    </button>
                                    <button class="btn btn-sm btn-info" 
                                            onclick="registrarContacto(<%= cliente.getIDCliente() %>, 'email')">
                                        📧 Enviar Email
                                    </button>
                                    <button class="btn btn-sm btn-warning" 
                                            onclick="registrarContacto(<%= cliente.getIDCliente() %>, 'sms')">
                                        💬 Enviar SMS
                                    </button>
                                    <a href="${pageContext.request.contextPath}/recepcionista/atencion/historial?idCliente=<%= cliente.getIDCliente() %>" 
                                       class="btn btn-sm btn-secondary">
                                        📊 Ver Historial Completo
                                    </a>
                                    <a href="${pageContext.request.contextPath}/recepcionista/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                                       class="btn btn-sm btn-outline-primary">
                                        ✏️ Editar Cliente
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    
                    <!-- Resumen -->
                    <div class="table-info">
                        <p>Total de clientes en seguimiento: <strong><%= clientesSeguimiento.size() %></strong></p>
                        <p>
                            <span class="badge badge-danger">Urgente: <%= clientesSeguimiento.stream().filter(c -> "urgente".equals(determinarPrioridadSeguimiento(c))).count() %></span>
                            <span class="badge badge-warning">Medio: <%= clientesSeguimiento.stream().filter(c -> "medio".equals(determinarPrioridadSeguimiento(c))).count() %></span>
                            <span class="badge badge-success">Bajo: <%= clientesSeguimiento.stream().filter(c -> "bajo".equals(determinarPrioridadSeguimiento(c))).count() %></span>
                        </p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function registrarContacto(idCliente, tipo) {
            let mensaje = '';
            switch(tipo) {
                case 'llamada':
                    mensaje = '¿Registrar llamada de seguimiento para este cliente?';
                    break;
                case 'email':
                    mensaje = '¿Enviar email de actualización al cliente?';
                    break;
                case 'sms':
                    mensaje = '¿Enviar SMS de recordatorio al cliente?';
                    break;
            }
            
            if (confirm(mensaje)) {
                // Aquí implementarías la lógica para registrar el contacto
                alert('Contacto registrado para el cliente #' + idCliente);
            }
        }
        
        function filtrarSeguimiento(prioridad) {
            const cards = document.querySelectorAll('.followup-card');
            cards.forEach(card => {
                if (prioridad === 'todos') {
                    card.style.display = '';
                } else {
                    const tienePrioridad = card.className.includes(prioridad + '-followup');
                    card.style.display = tienePrioridad ? '' : 'none';
                }
            });
        }
    </script>
</body>
</html>

<%!
    // Método helper para determinar prioridad de seguimiento
    private String determinarPrioridadSeguimiento(Cliente cliente) {
        int ordenesPendientes = contarOrdenesPendientes(cliente);
        int ordenesRetrasadas = contarOrdenesRetrasadas(cliente);
        
        if (ordenesRetrasadas > 0 || ordenesPendientes >= 3) {
            return "urgente";
        } else if (ordenesPendientes == 2) {
            return "medio";
        } else {
            return "bajo";
        }
    }
    
    // Método helper para contar órdenes pendientes
    private int contarOrdenesPendientes(Cliente cliente) {
        int count = 0;
        if (cliente.getVehiculoList() != null) {
            for (com.upec.model.Vehiculo vehiculo : cliente.getVehiculoList()) {
                if (vehiculo.getOrdenServicioList() != null) {
                    for (com.upec.model.OrdenServicio orden : vehiculo.getOrdenServicioList()) {
                        if (orden.getFechaRealSalida() == null) {
                            count++;
                        }
                    }
                }
            }
        }
        return count;
    }
    
    // Método helper para contar órdenes retrasadas
    private int contarOrdenesRetrasadas(Cliente cliente) {
        int count = 0;
        if (cliente.getVehiculoList() != null) {
            for (com.upec.model.Vehiculo vehiculo : cliente.getVehiculoList()) {
                if (vehiculo.getOrdenServicioList() != null) {
                    for (com.upec.model.OrdenServicio orden : vehiculo.getOrdenServicioList()) {
                        if (orden.getFechaRealSalida() == null && 
                            orden.getFechaEstimadaSalida() != null && 
                            orden.getFechaEstimadaSalida().before(new java.util.Date())) {
                            count++;
                        }
                    }
                }
            }
        }
        return count;
    }
    
    // Método helper para obtener clase de badge
    private String obtenerClaseBadgePrioridad(String prioridad) {
        switch(prioridad) {
            case "urgente": return "danger";
            case "medio": return "warning";
            case "bajo": return "success";
            default: return "secondary";
        }
    }
    
    // Método helper para obtener último contacto (simulado)
    private String obtenerUltimoContacto(Cliente cliente) {
        // En una implementación real, esto vendría de la base de datos
        java.util.Random rand = new java.util.Random();
        int dias = rand.nextInt(7) + 1;
        return "Hace " + dias + " día" + (dias > 1 ? "s" : "");
    }
%>