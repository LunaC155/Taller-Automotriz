<%@page import="java.util.Calendar"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión de recepcionista
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"recepcionista".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> citas = (List<OrdenServicio>) request.getAttribute("citas");
    Date fechaSeleccionada = (Date) request.getAttribute("fechaSeleccionada");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdfDisplay = new SimpleDateFormat("EEEE, d 'de' MMMM 'de' yyyy");
    String fechaHoy = sdf.format(new Date());
    String fechaSeleccionadaStr = fechaSeleccionada != null ? sdf.format(fechaSeleccionada) : fechaHoy;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendario de Citas - Recepcionista</title>
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
                <h1>📅 Calendario de Citas</h1>
                <p>Vista calendarizada de todas las citas programadas</p>
            </div>

            <!-- Encabezado del Calendario -->
            <div class="calendar-header">
                <div class="date-navigation">
                    <form action="${pageContext.request.contextPath}/recepcionista/citas/calendario" method="get" class="date-picker-form">
                        <input type="date" name="fecha" value="<%= fechaSeleccionadaStr %>" 
                               class="form-control" onchange="this.form.submit()">
                        <button type="submit" class="btn btn-primary">Ir</button>
                    </form>
                    <div class="date-display">
                        <%= fechaSeleccionada != null ? sdfDisplay.format(fechaSeleccionada) : sdfDisplay.format(new Date()) %>
                        <% if (fechaSeleccionadaStr.equals(fechaHoy)) { %>
                            <span class="current-time">Hoy</span>
                        <% } %>
                    </div>
                </div>
                
                <div class="calendar-controls">
                    <a href="${pageContext.request.contextPath}/recepcionista/citas/calendario?fecha=<%= 
                        new SimpleDateFormat("yyyy-MM-dd").format(new Date(new Date().getTime() - 86400000)) %>" 
                       class="btn btn-outline-secondary">← Ayer</a>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas/calendario?fecha=<%= fechaHoy %>" 
                       class="btn btn-outline-primary">Hoy</a>
                    <a href="${pageContext.request.contextPath}/recepcionista/citas/calendario?fecha=<%= 
                        new SimpleDateFormat("yyyy-MM-dd").format(new Date(new Date().getTime() + 86400000)) %>" 
                       class="btn btn-outline-secondary">Mañana →</a>
                </div>
            </div>

            <!-- Estadísticas del Día -->
            <div class="calendar-stats">
                <div class="stat-item">
                    <span class="stat-count"><%= citas != null ? citas.size() : 0 %></span>
                    <span class="stat-label">Total Citas</span>
                </div>
                <div class="stat-item">
                    <span class="stat-count">
                        <%= citas != null ? citas.stream().filter(c -> c.getFechaRealSalida() == null && 
                               (c.getIDEstadoTrabajo() == null || "PENDIENTE".equals(c.getIDEstadoTrabajo().getNombreEstado()))).count() : 0 %>
                    </span>
                    <span class="stat-label">Pendientes</span>
                </div>
                <div class="stat-item">
                    <span class="stat-count">
                        <%= citas != null ? citas.stream().filter(c -> c.getFechaRealSalida() == null && 
                               c.getIDEstadoTrabajo() != null && "EN PROCESO".equals(c.getIDEstadoTrabajo().getNombreEstado())).count() : 0 %>
                    </span>
                    <span class="stat-label">En Proceso</span>
                </div>
                <div class="stat-item">
                    <span class="stat-count">
                        <%= citas != null ? citas.stream().filter(c -> c.getFechaRealSalida() != null).count() : 0 %>
                    </span>
                    <span class="stat-label">Completadas</span>
                </div>
            </div>

            <!-- Calendario por Horas -->
            <div class="calendar-view">
                <div class="time-slots">
                    <!-- Horas -->
                    <div class="time-column">
                        <% for (int hora = 8; hora <= 17; hora++) { %>
                            <div class="time-slot"><%= String.format("%02d:00", hora) %></div>
                        <% } %>
                    </div>
                    
                    <!-- Citas -->
                    <div class="appointment-slots">
                        <% for (int hora = 8; hora <= 17; hora++) { %>
                            <div class="appointment-slot" id="slot-<%= hora %>">
                                <% 
                                    if (citas != null) {
                                        for (OrdenServicio cita : citas) {
                                            if (cita.getFechaEntrada() != null) {
                                                Calendar cal = Calendar.getInstance();
                                                cal.setTime(cita.getFechaEntrada());
                                                int citaHora = cal.get(Calendar.HOUR_OF_DAY);
                                                
                                                if (citaHora == hora) {
                                                    String estadoClase = "pending";
                                                    if (cita.getFechaRealSalida() != null) {
                                                        estadoClase = "completed";
                                                    } else if (cita.getIDEstadoTrabajo() != null && "EN PROCESO".equals(cita.getIDEstadoTrabajo().getNombreEstado())) {
                                                        estadoClase = "in-progress";
                                                    } else if (cita.getIDEstadoTrabajo() != null && "CANCELADA".equals(cita.getIDEstadoTrabajo().getNombreEstado())) {
                                                        estadoClase = "cancelled";
                                                    }
                                                    
                                                    String clienteNombre = "Cliente no disponible";
                                                    String vehiculoPlaca = "Vehículo no disponible";
                                                    
                                                    if (cita.getIDVehiculo() != null && cita.getIDVehiculo().getIDCliente() != null) {
                                                        clienteNombre = cita.getIDVehiculo().getIDCliente().getNombre() + " " + 
                                                                        cita.getIDVehiculo().getIDCliente().getApellido();
                                                        vehiculoPlaca = cita.getIDVehiculo().getPlaca();
                                                    }
                                %>
                                                    <div class="appointment-item <%= estadoClase %>" 
                                                         onclick="window.location.href='${pageContext.request.contextPath}/recepcionista/citas/ver?id=<%= cita.getIDOrdenServicio() %>'"
                                                         title="Clic para ver detalles">
                                                        <div class="appointment-time">
                                                            <%= String.format("%02d:%02d", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE)) %>
                                                            - #<%= cita.getIDOrdenServicio() %>
                                                        </div>
                                                        <div class="appointment-client"><%= clienteNombre %></div>
                                                        <div class="appointment-vehicle"><%= vehiculoPlaca %></div>
                                                    </div>
                                <% 
                                                }
                                            }
                                        }
                                    }
                                %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Leyenda -->
            <div class="legend" style="margin-top: 30px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
                <h4>Leyenda de Estados:</h4>
                <div style="display: flex; gap: 15px; flex-wrap: wrap;">
                    <div style="display: flex; align-items: center; gap: 5px;">
                        <div style="width: 15px; height: 15px; background: #fff3cd; border-left: 4px solid #ffc107;"></div>
                        <span>Pendiente</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 5px;">
                        <div style="width: 15px; height: 15px; background: #d1ecf1; border-left: 4px solid #17a2b8;"></div>
                        <span>En Proceso</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 5px;">
                        <div style="width: 15px; height: 15px; background: #d4edda; border-left: 4px solid #28a745;"></div>
                        <span>Completada</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 5px;">
                        <div style="width: 15px; height: 15px; background: #f8d7da; border-left: 4px solid #dc3545;"></div>
                        <span>Cancelada</span>
                    </div>
                </div>
            </div>

            <!-- Acciones Rápidas -->
            <div class="quick-actions" style="margin-top: 25px; display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/recepcionista/citas/crear" class="btn btn-primary">
                    ➕ Agendar Nueva Cita
                </a>
                <a href="${pageContext.request.contextPath}/recepcionista/citas" class="btn btn-secondary">
                    📋 Vista de Lista
                </a>
                <a href="${pageContext.request.contextPath}/recepcionista/citas/buscar" class="btn btn-info">
                    🔍 Búsqueda Avanzada
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Resaltar la hora actual
        function resaltarHoraActual() {
            const ahora = new Date();
            const horaActual = ahora.getHours();
            const minutoActual = ahora.getMinutes();
            
            // Solo resaltar si estamos viendo el día de hoy
            if ('<%= fechaSeleccionadaStr %>' === '<%= fechaHoy %>') {
                for (let hora = 8; hora <= 17; hora++) {
                    const slot = document.getElementById('slot-' + hora);
                    if (slot) {
                        if (hora === horaActual) {
                            slot.style.backgroundColor = '#f8f9fa';
                            slot.style.borderLeft = '3px solid #007bff';
                        }
                    }
                }
            }
        }

        // Inicializar
        document.addEventListener('DOMContentLoaded', function() {
            resaltarHoraActual();
            
            // Auto-recargar cada 5 minutos para ver citas en tiempo real
            setInterval(function() {
                // Solo recargar si estamos en la vista de hoy
                if ('<%= fechaSeleccionadaStr %>' === '<%= fechaHoy %>') {
                    window.location.reload();
                }
            }, 300000); // 5 minutos
        });

        // Atajos de teclado
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 'n':
                        e.preventDefault();
                        window.location.href = '${pageContext.request.contextPath}/recepcionista/citas/crear';
                        break;
                    case 'l':
                        e.preventDefault();
                        window.location.href = '${pageContext.request.contextPath}/recepcionista/citas';
                        break;
                    case 'h':
                        e.preventDefault();
                        window.location.href = '${pageContext.request.contextPath}/recepcionista/citas/calendario?fecha=<%= fechaHoy %>';
                        break;
                }
            }
        });
    </script>
</body>
</html>