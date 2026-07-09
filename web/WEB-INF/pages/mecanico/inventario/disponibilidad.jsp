<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Repuesto, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Repuesto repuesto = (Repuesto) request.getAttribute("repuesto");
    List<Repuesto> repuestosDisponibles = (List<Repuesto>) request.getAttribute("repuestosDisponibles");
    Integer cantidadRequerida = (Integer) request.getAttribute("cantidadRequerida");
    Integer stockActual = (Integer) request.getAttribute("stockActual");
    Boolean disponible = (Boolean) request.getAttribute("disponible");
    String error = (String) request.getAttribute("error");
    
    // Valores por defecto
    if (cantidadRequerida == null) cantidadRequerida = 1;
    if (stockActual == null) stockActual = 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificar Disponibilidad - Taller Automotriz</title>
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
                <h1>🔍 Verificar Disponibilidad</h1>
                <p>Consulta la disponibilidad de repuestos en tiempo real</p>
            </div>

            <div class="verification-container">
                <!-- Formulario de Verificación -->
                <div class="verification-form">
                    <h3>📋 Verificar Stock</h3>
                    <form action="${pageContext.request.contextPath}/mecanico/inventario/disponibilidad" method="get" class="crud-form">
                        <div class="form-row">
                            <div class="form-group">
                                <label for="idRepuesto">Repuesto a Verificar</label>
                                <select id="idRepuesto" name="idRepuesto" class="form-control">
                                    <option value="">Seleccione un repuesto</option>
                                    <% if (repuestosDisponibles != null) { 
                                        for (Repuesto rep : repuestosDisponibles) { %>
                                        <option value="<%= rep.getIDRepuesto() %>"
                                                <%= (repuesto != null && repuesto.getIDRepuesto().equals(rep.getIDRepuesto())) ? "selected" : "" %>>
                                            <%= rep.getNombreRepuesto() %> 
                                            (Stock: <%= rep.getStock() != null ? rep.getStock() : 0 %>)
                                        </option>
                                    <% } } %>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="cantidad">Cantidad Requerida</label>
                                <input type="number" id="cantidad" name="cantidad" 
                                       value="<%= cantidadRequerida %>" min="1" max="1000" 
                                       class="form-control">
                            </div>
                            
                            <div class="form-group">
                                <button type="submit" class="btn btn-primary" style="white-space: nowrap;">
                                    🔍 Verificar Disponibilidad
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Resultados de la Verificación -->
                <% if (error != null) { %>
                    <div class="result-container result-pending">
                        <div class="result-icon">❓</div>
                        <div class="result-title">Error en la Verificación</div>
                        <div class="result-details">
                            <p><%= error %></p>
                        </div>
                    </div>
                <% } else if (repuesto != null) { %>
                    <div class="result-container <%= disponible ? "result-available" : "result-unavailable" %>">
                        <div class="result-icon">
                            <%= disponible ? "✅" : "❌" %>
                        </div>
                        <div class="result-title">
                            <%= disponible ? "STOCK DISPONIBLE" : "STOCK INSUFICIENTE" %>
                        </div>
                        
                        <div class="result-details">
                            <p>
                                <strong><%= repuesto.getNombreRepuesto() %></strong><br>
                                <%= repuesto.getDescripcion() != null ? repuesto.getDescripcion() : "" %>
                            </p>
                        </div>

                        <!-- Comparación de Stock -->
                        <div class="stock-comparison">
                            <div class="stock-card required">
                                <div class="stock-number" style="color: #dc3545;">
                                    <%= cantidadRequerida %>
                                </div>
                                <div class="stock-label">Cantidad Requerida</div>
                            </div>
                            
                            <div class="stock-card available">
                                <div class="stock-number" style="color: #28a745;">
                                    <%= stockActual %>
                                </div>
                                <div class="stock-label">Stock Disponible</div>
                            </div>
                            
                            <div class="stock-card difference">
                                <div class="stock-number" style="color: #ffc107;">
                                    <%= disponible ? (stockActual - cantidadRequerida) : (cantidadRequerida - stockActual) %>
                                </div>
                                <div class="stock-label">
                                    <%= disponible ? "Excedente" : "Faltante" %>
                                </div>
                            </div>
                        </div>

                        <!-- Mensaje Detallado -->
                        <div class="result-details">
                            <% if (disponible) { %>
                                <p>
                                    <strong>✅ Puede proceder con la solicitud.</strong><br>
                                    Hay suficiente stock para satisfacer su requerimiento.
                                </p>
                                <% if (stockActual - cantidadRequerida <= (repuesto.getStockMinimo() != null ? repuesto.getStockMinimo() : 0)) { %>
                                    <p style="color: #856404;">
                                        ⚠️ <strong>Nota:</strong> Después de esta solicitud, el stock quedará cerca del nivel mínimo.
                                    </p>
                                <% } %>
                            <% } else { %>
                                <p>
                                    <strong>❌ No hay suficiente stock disponible.</strong><br>
                                    Faltan <%= cantidadRequerida - stockActual %> unidades para completar su requerimiento.
                                </p>
                                <% if (stockActual > 0) { %>
                                    <p>
                                        Puede solicitar hasta <strong><%= stockActual %></strong> unidades disponibles.
                                    </p>
                                <% } %>
                            <% } %>
                        </div>

                        <!-- Acciones -->
                        <div class="action-buttons">
                            <% if (disponible) { %>
                                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>&cantidad=<%= cantidadRequerida %>" 
                                   class="btn btn-success">
                                    📋 Solicitar Ahora
                                </a>
                            <% } else if (stockActual > 0) { %>
                                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>&cantidad=<%= stockActual %>" 
                                   class="btn btn-warning">
                                    📋 Solicitar Disponible (<%= stockActual %>)
                                </a>
                            <% } else { %>
                                <a href="${pageContext.request.contextPath}/mecanico/inventario/solicitar?idRepuesto=<%= repuesto.getIDRepuesto() %>" 
                                   class="btn btn-secondary">
                                    📋 Solicitar (Sin Stock)
                                </a>
                            <% } %>
                            
                            <a href="${pageContext.request.contextPath}/mecanico/inventario/consultar?id=<%= repuesto.getIDRepuesto() %>" 
                               class="btn btn-info">
                                🔍 Ver Detalles
                            </a>
                            
                            <a href="${pageContext.request.contextPath}/mecanico/inventario" 
                               class="btn btn-secondary">
                                ↩️ Volver al Inventario
                            </a>
                        </div>
                    </div>

                    <!-- Sugerencias -->
                    <div class="suggestions">
                        <h3>💡 Sugerencias</h3>
                        <div class="suggestion-list">
                            <% if (disponible) { %>
                                <div class="suggestion-item">
                                    <strong>Proceda con la solicitud:</strong> El stock está disponible para su requerimiento inmediato.
                                </div>
                                <% if (repuesto.getStockMinimo() != null && (stockActual - cantidadRequerida) <= repuesto.getStockMinimo()) { %>
                                    <div class="suggestion-item">
                                        <strong>Considere solicitar más:</strong> Después de esta solicitud, el stock estará cerca del nivel mínimo.
                                        Es recomendable informar al administrador de inventario.
                                    </div>
                                <% } %>
                            <% } else { %>
                                <div class="suggestion-item">
                                    <strong>Solicite el stock disponible:</strong> Puede solicitar las <%= stockActual %> unidades disponibles 
                                    y el resto quedará en lista de espera.
                                </div>
                                <div class="suggestion-item">
                                    <strong>Contacte al administrador:</strong> Para requerimientos urgentes, contacte al administrador 
                                    de inventario para gestionar un reabastecimiento prioritario.
                                </div>
                                <div class="suggestion-item">
                                    <strong>Considere alternativas:</strong> Explore si existen repuestos similares o equivalentes 
                                    que puedan satisfacer su necesidad.
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } else { %>
                    <div class="result-container result-pending">
                        <div class="result-icon">🔍</div>
                        <div class="result-title">Verificación de Disponibilidad</div>
                        <div class="result-details">
                            <p>Seleccione un repuesto y la cantidad requerida para verificar la disponibilidad.</p>
                        </div>
                    </div>
                <% } %>
            </div>

            <!-- Lista Rápida de Repuestos -->
            <% if (repuestosDisponibles != null && !repuestosDisponibles.isEmpty()) { %>
                <div class="additional-info" style="margin-top: 30px;">
                    <h3>📦 Repuestos Disponibles para Verificación</h3>
                    <div class="table-container">
                        <table class="crud-table">
                            <thead>
                                <tr>
                                    <th>Repuesto</th>
                                    <th>Stock Actual</th>
                                    <th>Stock Mínimo</th>
                                    <th>Estado</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Repuesto rep : repuestosDisponibles) { 
                                    String estado = "DISPONIBLE";
                                    String estadoClase = "badge-success";
                                    
                                    if (rep.getStock() == null || rep.getStock() == 0) {
                                        estado = "AGOTADO";
                                        estadoClase = "badge-danger";
                                    } else if (rep.getStockMinimo() != null && rep.getStock() <= rep.getStockMinimo() / 2) {
                                        estado = "CRÍTICO";
                                        estadoClase = "badge-danger";
                                    } else if (rep.getStockMinimo() != null && rep.getStock() <= rep.getStockMinimo()) {
                                        estado = "BAJO";
                                        estadoClase = "badge-warning";
                                    }
                                %>
                                    <tr>
                                        <td>
                                            <strong><%= rep.getNombreRepuesto() %></strong><br>
                                            <small style="color: #6c757d;">
                                                <%= rep.getDescripcion() != null ? 
                                                    (rep.getDescripcion().length() > 50 ? 
                                                     rep.getDescripcion().substring(0, 50) + "..." : 
                                                     rep.getDescripcion()) : "Sin descripción" %>
                                            </small>
                                        </td>
                                        <td><%= rep.getStock() != null ? rep.getStock() : 0 %></td>
                                        <td><%= rep.getStockMinimo() != null ? rep.getStockMinimo() : "N/A" %></td>
                                        <td>
                                            <span class="badge <%= estadoClase %>"><%= estado %></span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/mecanico/inventario/disponibilidad?idRepuesto=<%= rep.getIDRepuesto() %>&cantidad=1" 
                                               class="btn btn-sm btn-info">
                                                🔍 Verificar
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Auto-enfoque en el campo de repuesto
        document.addEventListener('DOMContentLoaded', function() {
            const repuestoSelect = document.getElementById('idRepuesto');
            if (repuestoSelect) {
                repuestoSelect.focus();
            }
        });

        // Validación del formulario de verificación
        document.querySelector('form').addEventListener('submit', function(e) {
            const repuesto = document.getElementById('idRepuesto').value;
            const cantidad = document.getElementById('cantidad').value;
            
            if (!repuesto) {
                e.preventDefault();
                alert('Por favor seleccione un repuesto para verificar');
                document.getElementById('idRepuesto').focus();
                return false;
            }
            
            if (!cantidad || cantidad < 1) {
                e.preventDefault();
                alert('Por favor ingrese una cantidad válida');
                document.getElementById('cantidad').focus();
                return false;
            }
        });
    </script>
</body>
</html>