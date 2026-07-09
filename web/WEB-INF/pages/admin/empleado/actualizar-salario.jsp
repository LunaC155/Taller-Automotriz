<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Empleado" %>
<%
    Empleado empleado = (Empleado) request.getAttribute("empleado");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Actualizar Salario</title>
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
                <h1>Actualizar Salario</h1>
                <p>Modifica el salario del empleado</p>
            </div>

            <% if (empleado != null) { %>
                <div class="form-container">
                    <!-- Información del empleado -->
                    <div class="info-card">
                        <h3>👨‍💼 Información del Empleado</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>Nombre:</strong>
                                <span><%= empleado.getNombre() %> <%= empleado.getApellido() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Salario Actual:</strong>
                                <span class="salary-amount">$<%= empleado.getSalario() != null ? empleado.getSalario() : "0.00" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha de Contratación:</strong>
                                <span><%= empleado.getFechaContratacion() != null ? empleado.getFechaContratacion() : "N/A" %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Formulario de actualización -->
                    <form action="${pageContext.request.contextPath}/admin/empleados/actualizar-salario" method="post" class="admin-form">
                        <input type="hidden" name="idEmpleado" value="<%= empleado.getIDEmpleado() %>">
                        
                        <div class="form-group">
                            <label for="salario">Nuevo Salario *</label>
                            <input type="number" id="salario" name="salario" 
                                   step="0.01" min="0" 
                                   value="<%= empleado.getSalario() != null ? empleado.getSalario() : "" %>" 
                                   class="form-control" required
                                   placeholder="0.00">
                            <small class="form-text">Ingrese el nuevo monto del salario</small>
                        </div>

                        <div class="form-group">
                            <label for="motivo">Motivo del Cambio (Opcional)</label>
                            <textarea id="motivo" name="motivo" class="form-control" 
                                      rows="3" placeholder="Ej: Ajuste por desempeño, aumento general, etc."></textarea>
                        </div>

                        <div class="salary-comparison">
                            <h4>📊 Comparación</h4>
                            <div class="comparison-grid">
                                <div class="comparison-item old">
                                    <strong>Salario Actual:</strong>
                                    <span>$<%= empleado.getSalario() != null ? empleado.getSalario() : "0.00" %></span>
                                </div>
                                <div class="comparison-item new">
                                    <strong>Nuevo Salario:</strong>
                                    <span id="nuevoSalarioDisplay">$0.00</span>
                                </div>
                                <div class="comparison-item difference">
                                    <strong>Diferencia:</strong>
                                    <span id="diferenciaDisplay">$0.00</span>
                                </div>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">💰 Actualizar Salario</button>
                            <a href="${pageContext.request.contextPath}/admin/empleados/ver?id=<%= empleado.getIDEmpleado() %>" 
                               class="btn btn-secondary">↩️ Cancelar</a>
                        </div>
                    </form>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el empleado solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/empleados" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // Actualizar comparación en tiempo real
        document.getElementById('salario').addEventListener('input', function() {
            const nuevoSalario = parseFloat(this.value) || 0;
            const salarioActual = parseFloat('<%= empleado.getSalario() != null ? empleado.getSalario() : 0 %>') || 0;
            
            document.getElementById('nuevoSalarioDisplay').textContent = '$' + nuevoSalario.toFixed(2);
            
            const diferencia = nuevoSalario - salarioActual;
            const diferenciaElement = document.getElementById('diferenciaDisplay');
            diferenciaElement.textContent = '$' + Math.abs(diferencia).toFixed(2);
            
            if (diferencia > 0) {
                diferenciaElement.className = 'positive';
            } else if (diferencia < 0) {
                diferenciaElement.className = 'negative';
            } else {
                diferenciaElement.className = '';
            }
        });
    </script>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>