<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.OrdenServicio" %>
<%@page import="java.util.Date" %>
<%@page import="java.util.Calendar" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 4) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<OrdenServicio> citas = (List<OrdenServicio>) request.getAttribute("citas");
%>
<%!
    // Método para verificar si una fecha es hoy
    public boolean esHoy(Date fecha) {
        if (fecha == null) return false;
        Calendar calFecha = Calendar.getInstance();
        calFecha.setTime(fecha);
        Calendar calHoy = Calendar.getInstance();
        return calFecha.get(Calendar.YEAR) == calHoy.get(Calendar.YEAR) &&
               calFecha.get(Calendar.DAY_OF_YEAR) == calHoy.get(Calendar.DAY_OF_YEAR);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Citas - Taller Automotriz</title>
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
                <h1>📅 Mis Citas</h1>
                <p>Gestiona y consulta todas tus citas programadas</p>
            </div>

            <!-- Barra de acciones -->
            <div class="action-bar">
                <a href="${pageContext.request.contextPath}/CitaServlet?action=nueva" class="btn btn-primary">
                    ➕ Nueva Cita
                </a>
                <a href="${pageContext.request.contextPath}/cliente/servicios/mis-servicios" class="btn btn-info">
                    🔧 Mis Servicios
                </a>
            </div>

            <!-- Estadísticas de Citas -->
            <div class="metrics-grid">
                <%
                    long totalCitas = citas != null ? citas.size() : 0;
                    long citasPendientes = citas != null ? citas.stream()
                        .filter(c -> c.getFechaRealSalida() == null)
                        .count() : 0;
                    long citasCompletadas = citas != null ? citas.stream()
                        .filter(c -> c.getFechaRealSalida() != null)
                        .count() : 0;
                    long citasHoy = citas != null ? citas.stream()
                        .filter(c -> esHoy(c.getFechaEntrada()))
                        .count() : 0;
                %>
                <div class="metric-card">
                    <div class="metric-icon">📅</div>
                    <div class="metric-info">
                        <h3><%= totalCitas %></h3>
                        <p>Total Citas</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">⏳</div>
                    <div class="metric-info">
                        <h3><%= citasPendientes %></h3>
                        <p>Pendientes</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">✅</div>
                    <div class="metric-info">
                        <h3><%= citasCompletadas %></h3>
                        <p>Completadas</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">📌</div>
                    <div class="metric-info">
                        <h3><%= citasHoy %></h3>
                        <p>Para Hoy</p>
                    </div>
                </div>
            </div>

            <!-- Lista de Citas -->
            <div class="appointments-section">
                <h2 class="section-title">📋 Lista de Citas Programadas</h2>
                
                <% if (citas != null && !citas.isEmpty()) { %>
                    <div class="appointments-list">
                        <% for (OrdenServicio cita : citas) { 
                            String estadoClase = "upcoming";
                            String estadoTexto = "Próxima";
                            
                            if (cita.getFechaRealSalida() != null) {
                                estadoClase = "completed";
                                estadoTexto = "Completada";
                            } else if (esHoy(cita.getFechaEntrada())) {
                                estadoClase = "today";
                                estadoTexto = "Hoy";
                            } else if (cita.getFechaEntrada() != null && cita.getFechaEntrada().before(new Date())) {
                                estadoClase = "past";
                                estadoTexto = "Pasada";
                            }
                        %>
                            <div class="appointment-card <%= estadoClase %>" data-status="<%= estadoClase %>">
                                <div class="appointment-header">
                                    <h3>Cita #<%= cita.getIDOrdenServicio() %></h3>
                                    <span class="status-badge <%= estadoClase %>">
                                        <%= estadoTexto %>
                                    </span>
                                </div>
                                
                                <div class="appointment-body">
                                    <div class="appointment-info">
                                        <div class="info-item">
                                            <strong>Vehículo:</strong>
                                            <span>
                                                <%= cita.getIDVehiculo() != null ? 
                                                    cita.getIDVehiculo().getPlaca() + " - " + 
                                                    (cita.getIDVehiculo().getIDMarca() != null ? cita.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                                    (cita.getIDVehiculo().getIDModelo() != null ? cita.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "N/A" %>
                                            </span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Problema Reportado:</strong>
                                            <span><%= cita.getProblemaReportado() != null ? cita.getProblemaReportado() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Fecha de Entrada:</strong>
                                            <span><%= cita.getFechaEntrada() != null ? cita.getFechaEntrada() : "N/A" %></span>
                                        </div>
                                        <% if (cita.getFechaEstimadaSalida() != null) { %>
                                            <div class="info-item">
                                                <strong>Fecha Estimada Salida:</strong>
                                                <span><%= cita.getFechaEstimadaSalida() %></span>
                                            </div>
                                        <% } %>
                                        <% if (cita.getFechaRealSalida() != null) { %>
                                            <div class="info-item">
                                                <strong>Fecha Real Salida:</strong>
                                                <span><%= cita.getFechaRealSalida() %></span>
                                            </div>
                                        <% } %>
                                        <div class="info-item">
                                            <strong>Estado del Trabajo:</strong>
                                            <span><%= cita.getIDEstadoTrabajo() != null ? cita.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                                        </div>
                                    </div>
                                    
                                    <% if (cita.getObservaciones() != null && !cita.getObservaciones().trim().isEmpty()) { %>
                                        <div class="appointment-notes">
                                            <strong>Observaciones:</strong>
                                            <p><%= cita.getObservaciones() %></p>
                                        </div>
                                    <% } %>
                                </div>
                                
                                <div class="appointment-actions">
                                    <a href="${pageContext.request.contextPath}/CitaServlet?action=ver&id=<%= cita.getIDOrdenServicio() %>" 
                                       class="btn btn-sm btn-info">Ver Detalles</a>
                                    
                                    <% if (cita.getFechaRealSalida() == null) { %>
                                        <a href="${pageContext.request.contextPath}/cliente/servicios/estado-reparacion?idOrden=<%= cita.getIDOrdenServicio() %>" 
                                           class="btn btn-sm btn-warning">Estado Reparación</a>
                                        
                                        <!-- Solo permitir cancelar citas futuras -->
                                        <% if (cita.getFechaEntrada() != null && cita.getFechaEntrada().after(new Date())) { %>
                                            <form action="${pageContext.request.contextPath}/CitaServlet?action=cancelar" method="post" style="display: inline;">
                                                <input type="hidden" name="id" value="<%= cita.getIDOrdenServicio() %>">
                                                <button type="submit" class="btn btn-sm btn-danger"
                                                   onclick="return confirm('¿Está seguro de cancelar esta cita?')">Cancelar</button>
                                            </form>
                                        <% } %>
                                    <% } else { %>
                                        <a href="${pageContext.request.contextPath}/cliente/facturaclientes/ver?orden=<%= cita.getIDOrdenServicio() %>" 
                                           class="btn btn-sm btn-success">Ver Factura</a>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    
                    <!-- Filtros de Citas -->
                    <div class="appointment-filters">
                        <h3>Filtrar Citas:</h3>
                        <div class="filter-buttons">
                            <button class="filter-btn active" data-filter="all">Todas (<%= totalCitas %>)</button>
                            <button class="filter-btn" data-filter="upcoming">Próximas (<%= citasPendientes - citasHoy %>)</button>
                            <button class="filter-btn" data-filter="today">Hoy (<%= citasHoy %>)</button>
                            <button class="filter-btn" data-filter="completed">Completadas (<%= citasCompletadas %>)</button>
                            <button class="filter-btn" data-filter="past">Pasadas</button>
                        </div>
                    </div>
                    
                <% } else { %>
                    <div class="no-data">
                        <p>📅 No tienes citas programadas.</p>
                        <p>Agenda tu primera cita para dar mantenimiento a tu vehículo.</p>
                        <a href="${pageContext.request.contextPath}/CitaServlet?action=nueva" class="btn btn-primary">
                            ➕ Agendar Primera Cita
                        </a>
                    </div>
                <% } %>
            </div>

            <!-- Información Adicional -->
            <div class="info-section">
                <h3>💡 Información Importante</h3>
                <div class="info-cards">
                    <div class="info-card">
                        <h4>🕒 Horario de Atención</h4>
                        <p>Lunes a Viernes: 8:00 AM - 6:00 PM</p>
                        <p>Sábados: 8:00 AM - 2:00 PM</p>
                        <p>Domingos: Cerrado</p>
                    </div>
                    <div class="info-card">
                        <h4>📞 Contacto de Emergencia</h4>
                        <p>Para cambios o cancelaciones de última hora:</p>
                        <p><strong>Teléfono:</strong> (04) 234-5678</p>
                        <p><strong>Email:</strong> citas@tallerautomotriz.com</p>
                    </div>
                    <div class="info-card">
                        <h4>✅ Preparación para la Cita</h4>
                        <ul>
                            <li>Lleva tu vehículo limpio</li>
                            <li>Trae documentación del vehículo</li>
                            <li>Describe claramente el problema</li>
                            <li>Llega 15 minutos antes</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Funcionalidad de filtros
        document.addEventListener('DOMContentLoaded', function() {
            const filterButtons = document.querySelectorAll('.filter-btn');
            const appointmentCards = document.querySelectorAll('.appointment-card');
            
            filterButtons.forEach(button => {
                button.addEventListener('click', function() {
                    // Remover clase active de todos los botones
                    filterButtons.forEach(btn => btn.classList.remove('active'));
                    // Agregar clase active al botón clickeado
                    this.classList.add('active');
                    
                    const filter = this.dataset.filter;
                    
                    appointmentCards.forEach(card => {
                        if (filter === 'all') {
                            card.style.display = 'block';
                        } else {
                            if (card.dataset.status === filter) {
                                card.style.display = 'block';
                            } else {
                                card.style.display = 'none';
                            }
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>