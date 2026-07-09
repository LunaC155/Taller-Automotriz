<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Actualizar Kilometraje</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
     <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudadmin.css">
</head>
<body class="admin">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-admin.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>Actualizar Kilometraje</h1>
                <p>Actualiza el kilometraje actual del vehículo</p>
            </div>

            <% if (vehiculo != null) { %>
                <div class="form-container">
                    <!-- Información del vehículo -->
                    <div class="info-card">
                        <h3>🚗 Información del Vehículo</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>Placa:</strong>
                                <span><%= vehiculo.getPlaca() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Marca/Modelo:</strong>
                                <span>
                                    <%= vehiculo.getIDMarca() != null ? vehiculo.getIDMarca().getNombreMarca() : "N/A" %> 
                                    <%= vehiculo.getIDModelo() != null ? vehiculo.getIDModelo().getNombreModelo() : "N/A" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Kilometraje Actual:</strong>
                                <span class="km-current">
                                    <%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "No registrado" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <strong>Última Actualización:</strong>
                                <span>Por definir</span>
                            </div>
                        </div>
                    </div>

                    <!-- Formulario de actualización -->
                    <form action="${pageContext.request.contextPath}/admin/vehiculos/actualizar-kilometraje" method="post" class="admin-form">
                        <input type="hidden" name="idVehiculo" value="<%= vehiculo.getIDVehiculo() %>">
                        
                        <div class="form-group">
                            <label for="kilometraje">Nuevo Kilometraje *</label>
                            <input type="number" id="kilometraje" name="kilometraje" 
                                   min="0" 
                                   value="<%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : "" %>" 
                                   class="form-control" required
                                   placeholder="Ingrese el kilometraje actual">
                            <small class="form-text">El kilometraje debe ser mayor o igual al actual</small>
                        </div>

                        <div class="form-group">
                            <label for="fechaActualizacion">Fecha de Lectura</label>
                            <input type="date" id="fechaActualizacion" name="fechaActualizacion" 
                                   class="form-control"
                                   value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                        </div>

                        <div class="form-group">
                            <label for="observaciones">Observaciones</label>
                            <textarea id="observaciones" name="observaciones" class="form-control" 
                                      rows="3" placeholder="Ej: Lectura durante servicio de mantenimiento, revisión periódica, etc."></textarea>
                        </div>

                        <!-- Resumen del cambio -->
                        <div class="change-summary">
                            <h4>📊 Resumen del Cambio</h4>
                            <div class="summary-grid">
                                <div class="summary-item">
                                    <strong>Kilometraje Anterior:</strong>
                                    <span id="kmAnterior"><%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() + " km" : "0 km" %></span>
                                </div>
                                <div class="summary-item">
                                    <strong>Nuevo Kilometraje:</strong>
                                    <span id="kmNuevo">0 km</span>
                                </div>
                                <div class="summary-item">
                                    <strong>Diferencia:</strong>
                                    <span id="kmDiferencia">0 km</span>
                                </div>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">📊 Actualizar Kilometraje</button>
                            <a href="${pageContext.request.contextPath}/admin/vehiculos/ver?id=<%= vehiculo.getIDVehiculo() %>" 
                               class="btn btn-secondary">↩️ Cancelar</a>
                        </div>
                    </form>
                </div>

                <!-- Información adicional -->
                <div class="info-card">
                    <h3>💡 Importancia del Kilometraje</h3>
                    <p>El kilometraje es fundamental para:</p>
                    <ul>
                        <li>Programar mantenimientos preventivos</li>
                        <li>Determinar el desgaste normal del vehículo</li>
                        <li>Estimar el valor comercial del vehículo</li>
                        <li>Planificar reemplazos de componentes</li>
                        <li>Generar historiales de servicio precisos</li>
                    </ul>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el vehículo solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/vehiculos" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // Actualizar resumen en tiempo real
        document.getElementById('kilometraje').addEventListener('input', function() {
            const nuevoKm = parseInt(this.value) || 0;
            const kmAnterior = parseInt('<%= vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : 0 %>') || 0;
            
            document.getElementById('kmNuevo').textContent = nuevoKm + ' km';
            
            const diferencia = nuevoKm - kmAnterior;
            const diferenciaElement = document.getElementById('kmDiferencia');
            diferenciaElement.textContent = diferencia + ' km';
            
            if (diferencia < 0) {
                diferenciaElement.className = 'negative';
                document.querySelector('.form-text').textContent = '❌ El kilometraje no puede ser menor al actual';
                document.querySelector('.form-text').style.color = 'var(--admin-danger)';
            } else {
                diferenciaElement.className = 'positive';
                document.querySelector('.form-text').textContent = '✅ Kilometraje válido';
                document.querySelector('.form-text').style.color = 'var(--admin-success)';
            }
        });
    </script>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>