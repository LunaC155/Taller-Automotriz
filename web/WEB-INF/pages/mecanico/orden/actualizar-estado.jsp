<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.EstadoTrabajo" %>
<%@page import="java.util.List" %>
<%
    // Verificar sesión por ID de rol numérico
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
    List<EstadoTrabajo> estados = (List<EstadoTrabajo>) request.getAttribute("estados");
    
    if (orden == null) {
        response.sendRedirect(request.getContextPath() + "/mecanico/ordenes");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actualizar Estado - Orden #<%= orden.getIDOrdenServicio() %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
      <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudmecanico.css">
    
</head>
<body class="mecanico">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-mecanico.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>🔄 Actualizar Estado de Orden</h1>
                <p>Actualiza el progreso de la orden de servicio</p>
            </div>


            <div class="status-update-form">
                <!-- Información de la Orden -->
                <div class="order-preview">
                    <h4>Orden #<%= orden.getIDOrdenServicio() %></h4>
                    <div class="preview-item">
                        <strong>Vehículo:</strong>
                        <span>
                            <%= orden.getIDVehiculo() != null ? 
                                orden.getIDVehiculo().getPlaca() + " - " + 
                                (orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                (orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "N/A" %>
                        </span>
                    </div>
                    <div class="preview-item">
                        <strong>Problema:</strong>
                        <span><%= orden.getProblemaReportado() != null ? 
                                (orden.getProblemaReportado().length() > 100 ? 
                                 orden.getProblemaReportado().substring(0, 100) + "..." : 
                                 orden.getProblemaReportado()) : "No especificado" %></span>
                    </div>
                    <div class="preview-item">
                        <strong>Cliente:</strong>
                        <span><%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null ? 
                                orden.getIDVehiculo().getIDCliente().getNombre() + " " + orden.getIDVehiculo().getIDCliente().getApellido() : "N/A" %></span>
                    </div>
                </div>

                <!-- Estado Actual -->
                <div class="current-status">
                    <h3>Estado Actual</h3>
                    <%
                        String estadoActual = orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "PENDIENTE";
                        String estadoActualClase = "badge-warning";
                        switch(estadoActual) {
                            case "EN PROCESO":
                                estadoActualClase = "badge-info";
                                break;
                            case "COMPLETADO":
                                estadoActualClase = "badge-success";
                                break;
                            case "CANCELADO":
                                estadoActualClase = "badge-danger";
                                break;
                        }
                    %>
                    <span class="status-badge-large <%= estadoActualClase %>"><%= estadoActual %></span>
                </div>

                <!-- Formulario de Actualización -->
                <form action="${pageContext.request.contextPath}/mecanico/ordenes/actualizar-estado" method="post">
                    <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                    
                    <h3 style="text-align: center; margin-bottom: 20px;">Selecciona el Nuevo Estado</h3>
                    
                    <div class="status-options">
                        <% if (estados != null) { 
                            for (EstadoTrabajo estado : estados) { 
                                String icon = "⏳";
                                String descripcion = "Estado de trabajo";
                                
                                switch(estado.getNombreEstado()) {
                                    case "EN PROCESO":
                                        icon = "🔧";
                                        descripcion = "El vehículo está siendo reparado activamente";
                                        break;
                                    case "COMPLETADO":
                                        icon = "✅";
                                        descripcion = "La reparación ha sido completada exitosamente";
                                        break;
                                    case "CANCELADO":
                                        icon = "❌";
                                        descripcion = "La orden ha sido cancelada";
                                        break;
                                    case "EN DIAGNOSTICO":
                                        icon = "🔍";
                                        descripcion = "El vehículo está en proceso de diagnóstico";
                                        break;
                                    case "EN REPARACION":
                                        icon = "⚙️";
                                        descripcion = "El vehículo está en proceso de reparación";
                                        break;
                                }
                        %>
                            <label class="status-option">
                                <input type="radio" name="idEstadoTrabajo" value="<%= estado.getIDEstadoTrabajo() %>" required>
                                <div class="status-icon"><%= icon %></div>
                                <div class="status-info">
                                    <h4><%= estado.getNombreEstado() %></h4>
                                    <p><%= descripcion %></p>
                                    <% if (estado.getDescripcion() != null && !estado.getDescripcion().trim().isEmpty()) { %>
                                        <p><small><%= estado.getDescripcion() %></small></p>
                                    <% } %>
                                </div>
                            </label>
                        <% } 
                        } else { %>
                            <p class="text-center">No hay estados disponibles para actualizar.</p>
                        <% } %>
                    </div>

                    <!-- Observaciones Adicionales -->
                    <div class="form-group" style="margin-top: 25px;">
                        <label for="observaciones"><strong>Observaciones (Opcional):</strong></label>
                        <textarea id="observaciones" name="observaciones" rows="3" 
                                  class="form-control" 
                                  placeholder="Agrega cualquier observación relevante sobre el cambio de estado..."></textarea>
                        <small class="form-text">Estas observaciones se agregarán al historial de la orden.</small>
                    </div>

                    <!-- Acciones -->
                    <div class="form-actions">
                        <button type="submit" class="btn btn-success" 
                                onclick="return confirm('¿Está seguro de actualizar el estado de esta orden?')">
                            💾 Actualizar Estado
                        </button>
                        <a href="${pageContext.request.contextPath}/mecanico/ordenes/ver?id=<%= orden.getIDOrdenServicio() %>" 
                           class="btn btn-secondary">↩️ Cancelar</a>
                    </div>
                </form>
            </div>

            <!-- Información Adicional -->
            <div style="max-width: 600px; margin: 30px auto 0; text-align: center;">
                <h4>💡 Información Importante</h4>
                <p style="color: #6c757d; font-size: 0.9em;">
                    Al actualizar el estado de la orden, el sistema notificará automáticamente al recepcionista 
                    y el cliente podrá ver el progreso de su vehículo.
                </p>
            </div>
        </div>
    </div>

       <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // El JavaScript se mantiene igual
        document.querySelectorAll('.status-option').forEach(option => {
            option.addEventListener('click', function() {
                document.querySelectorAll('.status-option').forEach(opt => {
                    opt.classList.remove('selected');
                });
                this.classList.add('selected');
                this.querySelector('input[type="radio"]').checked = true;
            });
        });

        document.querySelector('form').addEventListener('submit', function(e) {
            const estadoSeleccionado = document.querySelector('input[name="idEstadoTrabajo"]:checked');
            if (!estadoSeleccionado) {
                e.preventDefault();
                alert('Por favor selecciona un estado para continuar.');
                return false;
            }
            return true;
        });
    </script>
</body>
</html>
