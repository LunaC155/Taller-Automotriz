<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Diagnostico, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
    List<Diagnostico> diagnosticos = orden != null ? orden.getDiagnosticoList() : null;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle de Tarea - Taller Automotriz</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudmecanico.css">
   
</head>
<body class="mecanico">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-mecanico.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <% if (orden != null) { 
                boolean estaCompletada = orden.getFechaRealSalida() != null;
                String estadoClase = estaCompletada ? "status-completed" : "status-pending";
                String estadoTexto = estaCompletada ? "COMPLETADA" : "EN PROCESO";
            %>
                <div class="task-detail-container">
                    <!-- Encabezado -->
                    <div class="detail-header">
                        <div class="header-info">
                            <h1><%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "Tarea Sin Título" %></h1>
                            <div class="task-id">Orden de Servicio #<%= orden.getIDOrdenServicio() %></div>
                        </div>
                        <span class="task-status <%= estadoClase %>"><%= estadoTexto %></span>
                    </div>

                    <!-- Información Principal -->
                    <div class="detail-grid">
                        <!-- Información del Vehículo -->
                        <div class="detail-section">
                            <h3>🚗 Información del Vehículo</h3>
                            <% if (orden.getIDVehiculo() != null) { %>
                                <div class="vehicle-card">
                                    <div class="detail-item">
                                        <span class="detail-label">Placa:</span>
                                        <span class="detail-value"><strong><%= orden.getIDVehiculo().getPlaca() %></strong></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Marca:</span>
                                        <span class="detail-value"><%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "N/A" %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Modelo:</span>
                                        <span class="detail-value"><%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "N/A" %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Color:</span>
                                        <span class="detail-value"><%= orden.getIDVehiculo().getColor() != null ? orden.getIDVehiculo().getColor() : "N/A" %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Año:</span>
                                        <span class="detail-value"><%= orden.getIDVehiculo().getAnioVehiculo() != null ? orden.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Kilometraje:</span>
                                        <span class="detail-value"><%= orden.getIDVehiculo().getKilometraje() != null ? orden.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                                    </div>
                                </div>
                            <% } else { %>
                                <p style="color: #6c757d; font-style: italic;">No hay información del vehículo disponible.</p>
                            <% } %>
                        </div>

                        <!-- Información de la Orden -->
                        <div class="detail-section">
                            <h3>📅 Información de la Orden</h3>
                            <div class="detail-item">
                                <span class="detail-label">Fecha Entrada:</span>
                                <span class="detail-value"><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Fecha Estimada:</span>
                                <span class="detail-value"><%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Fecha Real Salida:</span>
                                <span class="detail-value"><%= orden.getFechaRealSalida() != null ? orden.getFechaRealSalida() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Estado:</span>
                                <span class="detail-value"><%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Recepcionista:</span>
                                <span class="detail-value"><%= orden.getIDEmpleadoRecepcion() != null ? "Asignado" : "Por asignar" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Problema Reportado -->
                    <div class="detail-section full-width">
                        <h3>🔧 Problema Reportado</h3>
                        <div class="observaciones-content">
                            <%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "No se ha reportado ningún problema específico." %>
                        </div>
                    </div>

                    <!-- Observaciones -->
                    <% if (orden.getObservaciones() != null && !orden.getObservaciones().trim().isEmpty()) { %>
                        <div class="detail-section full-width">
                            <h3>📝 Historial de Observaciones</h3>
                            <div class="observaciones-content">
                                <%= orden.getObservaciones() %>
                            </div>
                        </div>
                    <% } %>

                    <!-- Diagnósticos -->
                    <div class="diagnosticos-section">
                        <h3>🔍 Diagnósticos Realizados</h3>
                        <% if (diagnosticos != null && !diagnosticos.isEmpty()) { %>
                            <div class="timeline">
                                <% for (Diagnostico diagnostico : diagnosticos) { %>
                                    <div class="timeline-item">
                                        <div class="diagnostico-card">
                                            <div class="diagnostico-header">
                                                <div class="diagnostico-title">
                                                    Diagnóstico #<%= diagnostico.getIDDiagnostico() != null ? diagnostico.getIDDiagnostico() : "N/A" %>
                                                </div>
                                                <div class="diagnostico-date">
                                                    <%= diagnostico.getFechaDiagnostico() != null ? diagnostico.getFechaDiagnostico() : "Fecha no especificada" %>
                                                </div>
                                            </div>
                                            <div class="diagnostico-content">
                                                <% if (diagnostico.getDescripcionDiagnostico() != null) { %>
                                                    <p><strong>Descripción:</strong> <%= diagnostico.getDescripcionDiagnostico() %></p>
                                                <% } %>
                                                <% if (diagnostico.getRecomendaciones() != null) { %>
                                                    <p><strong>Recomendaciones:</strong> <%= diagnostico.getRecomendaciones() %></p>
                                                <% } %>
                                                <% if (diagnostico.getCostoEstimado() != null) { %>
                                                    <p><strong>Costo Estimado:</strong> $<%= diagnostico.getCostoEstimado() %></p>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="empty-diagnosticos">
                                <div class="icon">🔍</div>
                                <p>No se han realizado diagnósticos para esta orden.</p>
                            </div>
                        <% } %>
                    </div>

                    <!-- Actualizar Progreso (solo si no está completada) -->
                    <% if (!estaCompletada) { %>
                        <div class="progress-section">
                            <h3>📈 Actualizar Progreso</h3>
                            <form action="${pageContext.request.contextPath}/mecanico/tareas/actualizar-progreso" method="post" class="progress-form">
                                <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                                
                                <div class="form-group">
                                    <label for="progreso">Progreso Actual (%):</label>
                                    <input type="range" id="progreso" name="progreso" min="0" max="100" value="0" 
                                           class="form-control" oninput="updateProgressValue(this.value)">
                                    <div style="text-align: center; margin-top: 5px;">
                                        <span id="progressValue">0%</span>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <label for="observaciones">Observaciones del Progreso:</label>
                                    <textarea id="observaciones" name="observaciones" rows="4" 
                                              class="form-control" 
                                              placeholder="Describe el progreso del trabajo, problemas encontrados, soluciones aplicadas..."></textarea>
                                </div>
                                
                                <button type="submit" class="btn btn-primary">💾 Guardar Progreso</button>
                            </form>
                        </div>

                        <!-- Completar Tarea -->
                        <div class="progress-section" style="background: #d4edda; border-color: #c3e6cb;">
                            <h3>✅ Completar Tarea</h3>
                            <form action="${pageContext.request.contextPath}/mecanico/tareas/completar" method="post">
                                <input type="hidden" name="idOrdenServicio" value="<%= orden.getIDOrdenServicio() %>">
                                
                                <div class="form-group">
                                    <label for="observacionesFinales">Observaciones Finales:</label>
                                    <textarea id="observacionesFinales" name="observacionesFinales" rows="3" 
                                              class="form-control" 
                                              placeholder="Describe el trabajo finalizado, pruebas realizadas, recomendaciones al cliente..."></textarea>
                                </div>
                                
                                <button type="submit" class="btn btn-success"
                                        onclick="return confirm('¿Está seguro de marcar esta tarea como completada? Esta acción no se puede deshacer.')">
                                    ✅ Marcar como Completada
                                </button>
                            </form>
                        </div>
                    <% } else { %>
                        <div class="progress-section" style="background: #d4edda; border-color: #c3e6cb;">
                            <h3>✅ Tarea Completada</h3>
                            <p>Esta tarea fue marcada como completada el <%= orden.getFechaRealSalida() != null ? orden.getFechaRealSalida() : "fecha no disponible" %>.</p>
                            <p>El vehículo está listo para ser entregado al cliente.</p>
                        </div>
                    <% } %>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/mecanico/tareas" class="btn btn-secondary">
                            ↩️ Volver a Mis Tareas
                        </a>
                        
                        <% if (!estaCompletada) { %>
                            <a href="${pageContext.request.contextPath}/mecanico/diagnosticos/nuevo?orden=<%= orden.getIDOrdenServicio() %>" 
                               class="btn btn-info">🔍 Agregar Diagnóstico</a>
                        <% } %>
                        
                        <button onclick="window.print()" class="btn btn-outline-primary">🖨️ Imprimir</button>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message" style="text-align: center; padding: 60px 20px; background: #f8d7da; border-radius: 8px;">
                    <h2>❌ Tarea No Encontrada</h2>
                    <p>No se pudo encontrar la tarea solicitada.</p>
                    <a href="${pageContext.request.contextPath}/mecanico/tareas" class="btn btn-secondary">Volver a Mis Tareas</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        function updateProgressValue(value) {
            document.getElementById('progressValue').textContent = value + '%';
        }
        
        // Inicializar el valor del progreso
        document.addEventListener('DOMContentLoaded', function() {
            const progressSlider = document.getElementById('progreso');
            if (progressSlider) {
                updateProgressValue(progressSlider.value);
            }
        });
    </script>
</body>
</html>