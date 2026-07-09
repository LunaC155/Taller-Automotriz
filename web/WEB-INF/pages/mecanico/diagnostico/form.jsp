<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Diagnostico, com.upec.model.OrdenServicio" %>
<%@page import="java.util.List" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Diagnostico diagnostico = (Diagnostico) request.getAttribute("diagnostico");
    List<OrdenServicio> ordenesDisponibles = (List<OrdenServicio>) request.getAttribute("ordenesDisponibles");
    
    boolean esNuevo = diagnostico == null || diagnostico.getIDDiagnostico() == null;
    String titulo = esNuevo ? "Crear Nuevo Diagnóstico" : "Editar Diagnóstico";
    String action = esNuevo ? "crear" : "editar";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> - Taller Automotriz</title>
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
                <h1><%= titulo %></h1>
                <p><%= esNuevo ? "Registra un nuevo diagnóstico para una orden de servicio" : "Actualiza la información del diagnóstico" %></p>
            </div>

            <div class="diagnostic-form">
                <form action="${pageContext.request.contextPath}/mecanico/diagnosticos/<%= action %>" method="post" class="crud-form" id="diagnosticoForm">
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idDiagnostico" value="<%= diagnostico.getIDDiagnostico() %>">
                    <% } %>

                    <!-- Selección de Orden de Servicio -->
                    <div class="form-section">
                        <h3>📋 Orden de Servicio</h3>
                        
                        <div class="form-group">
                            <label for="idOrdenServicio" class="required-field">Orden de Servicio *</label>
                            <select id="idOrdenServicio" name="idOrdenServicio" required class="form-control" <%= !esNuevo ? "disabled" : "" %>>
                                <option value="">Seleccione una orden de servicio</option>
                                <% if (ordenesDisponibles != null) { 
                                    for (OrdenServicio orden : ordenesDisponibles) { 
                                        boolean selected = diagnostico != null && diagnostico.getIDOrdenServicio() != null && 
                                                          diagnostico.getIDOrdenServicio().getIDOrdenServicio().equals(orden.getIDOrdenServicio());
                                %>
                                    <option value="<%= orden.getIDOrdenServicio() %>" 
                                            data-problema="<%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "" %>"
                                            data-vehiculo="<%= orden.getIDVehiculo() != null ? 
                                                orden.getIDVehiculo().getPlaca() + " - " + 
                                                (orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "") + " " +
                                                (orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "") : "" %>"
                                            data-cliente="<%= orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null ? 
                                                orden.getIDVehiculo().getIDCliente().getNombre() + " " + orden.getIDVehiculo().getIDCliente().getApellido() : "" %>"
                                            <%= selected ? "selected" : "" %>>
                                        Orden #<%= orden.getIDOrdenServicio() %> - 
                                        <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %> - 
                                        <%= orden.getProblemaReportado() != null && orden.getProblemaReportado().length() > 50 ? 
                                             orden.getProblemaReportado().substring(0, 50) + "..." : 
                                             (orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "Sin descripción") %>
                                    </option>
                                <% } } %>
                            </select>
                            <small class="form-text">Selecciona la orden de servicio para la cual realizarás el diagnóstico</small>
                        </div>

                        <!-- Información de la Orden Seleccionada -->
                        <div id="orderInfo" class="order-info-card" style="display: none;">
                            <h4>Información de la Orden</h4>
                            <div class="order-details">
                                <div class="detail-item">
                                    <strong>Vehículo:</strong>
                                    <span id="infoVehiculo">-</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Cliente:</strong>
                                    <span id="infoCliente">-</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Problema Reportado:</strong>
                                    <span id="infoProblema">-</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Descripción del Diagnóstico -->
                    <div class="form-section">
                        <h3>🔍 Diagnóstico Técnico</h3>
                        
                        <div class="textarea-group">
                            <label for="descripcionDiagnostico" class="required-field">Descripción del Diagnóstico *</label>
                            <textarea id="descripcionDiagnostico" name="descripcionDiagnostico" required 
                                      placeholder="Describe detalladamente los hallazgos del diagnóstico, problemas identificados, causas raíz, etc..."
                                      oninput="updateCharacterCount(this, 'descCount')"><%= diagnostico != null && diagnostico.getDescripcionDiagnostico() != null ? diagnostico.getDescripcionDiagnostico() : "" %></textarea>
                            <div class="character-count">
                                <span id="descCount">0</span> caracteres
                            </div>
                        </div>

                        <!-- Sugerencias para diagnóstico -->
                        <div class="suggestions-box">
                            <h4>💡 Plantillas de Diagnóstico Comunes</h4>
                            <div class="suggestion-item" onclick="applySuggestion('Se identificó desgaste en las pastillas de freno. Se recomienda cambio inmediato por seguridad.')">
                                <strong>Frenos Desgastados</strong><br>
                                <small>Pastillas de freno con desgaste excesivo</small>
                            </div>
                            <div class="suggestion-item" onclick="applySuggestion('Batería presenta voltaje bajo y no mantiene carga. Sistema de carga funcionando correctamente.')">
                                <strong>Batería Defectuosa</strong><br>
                                <small>Problemas eléctricos y de carga</small>
                            </div>
                            <div class="suggestion-item" onclick="applySuggestion('Aceite del motor contaminado y con partículas metálicas. Filtro de aceite obstruido.')">
                                <strong>Cambio de Aceite</strong><br>
                                <small>Mantenimiento preventivo requerido</small>
                            </div>
                        </div>
                    </div>

                    <!-- Recomendaciones -->
                    <div class="form-section">
                        <h3>💡 Recomendaciones y Reparaciones</h3>
                        
                        <div class="textarea-group">
                            <label for="recomendaciones">Recomendaciones</label>
                            <textarea id="recomendaciones" name="recomendaciones" 
                                      placeholder="Incluye recomendaciones de reparación, repuestos necesarios, tiempo estimado, costos aproximados..."
                                      oninput="updateCharacterCount(this, 'recCount')"><%= diagnostico != null && diagnostico.getRecomendaciones() != null ? diagnostico.getRecomendaciones() : "" %></textarea>
                            <div class="character-count">
                                <span id="recCount">0</span> caracteres
                            </div>
                        </div>

                        <!-- Checklist de Reparaciones -->
                        <div class="suggestions-box">
                            <h4>🔧 Reparaciones Recomendadas</h4>
                            <div class="suggestion-item" onclick="addRecommendation('Cambio de aceite y filtro.')">
                                <strong>Cambio de Aceite</strong><br>
                                <small>Aceite sintético y filtro nuevo</small>
                            </div>
                            <div class="suggestion-item" onclick="addRecommendation('Alineación y balanceo de ruedas.')">
                                <strong>Alineación y Balanceo</strong><br>
                                <small>Corrección de dirección y balance</small>
                            </div>
                            <div class="suggestion-item" onclick="addRecommendation('Cambio de pastillas y discos de freno.')">
                                <strong>Reparación de Frenos</strong><br>
                                <small>Sistema de frenos completo</small>
                            </div>
                        </div>
                    </div>

                    <!-- Resumen del Diagnóstico -->
                    <div class="form-section">
                        <h3>📊 Resumen del Diagnóstico</h3>
                        <div class="order-info-card">
                            <div class="order-details">
                                <div class="detail-item">
                                    <strong>Orden:</strong>
                                    <span id="resumenOrden">No seleccionada</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Vehículo:</strong>
                                    <span id="resumenVehiculo">-</span>
                                </div>
                                <div class="detail-item">
                                    <strong>Fecha:</strong>
                                    <span><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></span>
                                </div>
                                <div class="detail-item">
                                    <strong>Mecánico:</strong>
                                    <span><%= session.getAttribute("nombreUsuario") != null ? session.getAttribute("nombreUsuario") : "Usuario Actual" %></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "💾 Guardar Diagnóstico" : "💾 Actualizar Diagnóstico" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/mecanico/diagnosticos" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Actualizar información de la orden cuando se selecciona
        document.getElementById('idOrdenServicio').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const orderInfo = document.getElementById('orderInfo');
            
            if (this.value) {
                orderInfo.style.display = 'block';
                document.getElementById('infoVehiculo').textContent = selectedOption.dataset.vehiculo || '-';
                document.getElementById('infoCliente').textContent = selectedOption.dataset.cliente || '-';
                document.getElementById('infoProblema').textContent = selectedOption.dataset.problema || '-';
                
                // Actualizar resumen
                document.getElementById('resumenOrden').textContent = '#' + this.value;
                document.getElementById('resumenVehiculo').textContent = selectedOption.dataset.vehiculo || '-';
                
                // Si hay problema reportado, puede ayudar con el diagnóstico
                if (selectedOption.dataset.problema) {
                    document.getElementById('descripcionDiagnostico').placeholder = 
                        "Problema reportado: " + selectedOption.dataset.problema + "\n\nDescribe los hallazgos del diagnóstico...";
                }
            } else {
                orderInfo.style.display = 'none';
                document.getElementById('resumenOrden').textContent = 'No seleccionada';
                document.getElementById('resumenVehiculo').textContent = '-';
            }
        });

        // Contador de caracteres
        function updateCharacterCount(textarea, countElementId) {
            const count = textarea.value.length;
            document.getElementById(countElementId).textContent = count;
        }

        // Aplicar sugerencia de diagnóstico
        function applySuggestion(suggestion) {
            document.getElementById('descripcionDiagnostico').value = suggestion;
            updateCharacterCount(document.getElementById('descripcionDiagnostico'), 'descCount');
        }

        // Agregar recomendación
        function addRecommendation(recommendation) {
            const textarea = document.getElementById('recomendaciones');
            const currentValue = textarea.value.trim();
            
            if (currentValue) {
                textarea.value = currentValue + '\n• ' + recommendation;
            } else {
                textarea.value = '• ' + recommendation;
            }
            
            updateCharacterCount(textarea, 'recCount');
        }

        // Validación del formulario
        document.getElementById('diagnosticoForm').addEventListener('submit', function(e) {
            const orden = document.getElementById('idOrdenServicio').value;
            const descripcion = document.getElementById('descripcionDiagnostico').value.trim();

            if (!orden) {
                e.preventDefault();
                alert('Por favor seleccione una orden de servicio');
                document.getElementById('idOrdenServicio').focus();
                return false;
            }

            if (!descripcion) {
                e.preventDefault();
                alert('Por favor ingrese la descripción del diagnóstico');
                document.getElementById('descripcionDiagnostico').focus();
                return false;
            }

            if (descripcion.length < 10) {
                e.preventDefault();
                alert('La descripción del diagnóstico debe tener al menos 10 caracteres');
                document.getElementById('descripcionDiagnostico').focus();
                return false;
            }

            return confirm('¿Está seguro de que desea <%= esNuevo ? "guardar" : "actualizar" %> este diagnóstico?');
        });

        // Inicializar contadores
        window.addEventListener('load', function() {
            updateCharacterCount(document.getElementById('descripcionDiagnostico'), 'descCount');
            updateCharacterCount(document.getElementById('recomendaciones'), 'recCount');
            
            // Si hay orden seleccionada, mostrar información
            const ordenSelect = document.getElementById('idOrdenServicio');
            if (ordenSelect.value) {
                ordenSelect.dispatchEvent(new Event('change'));
            }
        });
    </script>
</body>
</html>