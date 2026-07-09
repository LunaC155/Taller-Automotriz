<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Diagnostico, com.upec.model.Factura" %>
<%@page import="java.util.List" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    OrdenServicio orden = (OrdenServicio) request.getAttribute("orden");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalles Completos de Orden - Recepcionista</title>
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
                <h1>📋 Detalles Completos de Orden</h1>
                <p>Información exhaustiva de la orden de servicio</p>
            </div>

            <% if (orden != null) { %>
                <div class="details-container">
                    <!-- Encabezado -->
                    <div class="details-header">
                        <div>
                            <h2>Orden #<%= orden.getIDOrdenServicio() %></h2>
                            <p class="text-muted">Creada el <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "Fecha no disponible" %></p>
                        </div>
                        <div class="order-meta">
                            <span class="meta-item">
                                Estado: 
                                <span class="status-badge 
                                    <%= orden.getFechaRealSalida() != null ? "badge-completed" : 
                                       (orden.getIDEstadoTrabajo() != null && "EN PROCESO".equals(orden.getIDEstadoTrabajo().getNombreEstado()) ? "badge-in-progress" : 
                                       (orden.getIDEstadoTrabajo() != null && "CANCELADO".equals(orden.getIDEstadoTrabajo().getNombreEstado()) ? "badge-cancelled" : "badge-pending")) %>">
                                    <%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "PENDIENTE" %>
                                </span>
                            </span>
                            <span class="meta-item">
                                Vehículo: <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "Por asignar" %>
                            </span>
                            <span class="meta-item">
                                Recepcionista: <%= orden.getIDEmpleadoRecepcion() != null ? 
                                    orden.getIDEmpleadoRecepcion().getNombre() + " " + orden.getIDEmpleadoRecepcion().getApellido() : "N/A" %>
                            </span>
                        </div>
                    </div>

                    <!-- Pestañas -->
                    <div class="details-tabs">
                        <div class="tab-buttons">
                            <button class="tab-button active" onclick="openTab('tab-info')">📋 Información General</button>
                            <button class="tab-button" onclick="openTab('tab-diagnosticos')">🔍 Diagnósticos</button>
                            <button class="tab-button" onclick="openTab('tab-facturacion')">🧾 Facturación</button>
                            <button class="tab-button" onclick="openTab('tab-historial')">📊 Historial</button>
                        </div>

                        <!-- Pestaña: Información General -->
                        <div id="tab-info" class="tab-content active">
                            <div class="info-grid">
                                <!-- Información del Vehículo -->
                                <div class="info-card">
                                    <h3>🚗 Información del Vehículo</h3>
                                    <% if (orden.getIDVehiculo() != null) { %>
                                        <div class="info-item">
                                            <strong>Placa:</strong>
                                            <span><%= orden.getIDVehiculo().getPlaca() %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Marca:</strong>
                                            <span><%= orden.getIDVehiculo().getIDMarca() != null ? orden.getIDVehiculo().getIDMarca().getNombreMarca() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Modelo:</strong>
                                            <span><%= orden.getIDVehiculo().getIDModelo() != null ? orden.getIDVehiculo().getIDModelo().getNombreModelo() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Color:</strong>
                                            <span><%= orden.getIDVehiculo().getColor() != null ? orden.getIDVehiculo().getColor() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Año:</strong>
                                            <span><%= orden.getIDVehiculo().getAnioVehiculo() != null ? orden.getIDVehiculo().getAnioVehiculo() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Kilometraje:</strong>
                                            <span><%= orden.getIDVehiculo().getKilometraje() != null ? orden.getIDVehiculo().getKilometraje() + " km" : "N/A" %></span>
                                        </div>
                                    <% } else { %>
                                        <div class="empty-state">
                                            <p>🚗 Vehículo no asignado</p>
                                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/asignar-vehiculo?id=<%= orden.getIDOrdenServicio() %>" 
                                               class="btn btn-primary">Asignar Vehículo</a>
                                        </div>
                                    <% } %>
                                </div>

                                <!-- Información del Cliente -->
                                <div class="info-card">
                                    <h3>👤 Información del Cliente</h3>
                                    <% if (orden.getIDVehiculo() != null && orden.getIDVehiculo().getIDCliente() != null) { 
                                        com.upec.model.Cliente cliente = orden.getIDVehiculo().getIDCliente();
                                    %>
                                        <div class="info-item">
                                            <strong>Nombre:</strong>
                                            <span><%= cliente.getNombre() %> <%= cliente.getApellido() %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Teléfono:</strong>
                                            <span><%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Email:</strong>
                                            <span><%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Dirección:</strong>
                                            <span><%= cliente.getDireccion() != null ? cliente.getDireccion() : "N/A" %></span>
                                        </div>
                                        <div class="info-item">
                                            <strong>Documento:</strong>
                                            <span>
                                                <% 
                                                    // Intentar diferentes métodos comunes para documento
                                                    String documento = "N/A";
                                                    try {
                                                        // Método más común en entidades Cliente
                                                        if (cliente.getClass().getMethod("getCedula") != null) {
                                                            documento = cliente.getCedula() != null ? cliente.getCedula() : "N/A";
                                                        }
                                                    } catch (Exception e1) {
                                                        try {
                                                            if (cliente.getClass().getMethod("getDocumento") != null) {
                                                                documento = cliente.getDocumento() != null ? cliente.getDocumento() : "N/A";
                                                            }
                                                        } catch (Exception e2) {
                                                            try {
                                                                if (cliente.getClass().getMethod("getRuc") != null) {
                                                                    documento = cliente.getRuc() != null ? cliente.getRuc() : "N/A";
                                                                }
                                                            } catch (Exception e3) {
                                                                documento = "No disponible";
                                                            }
                                                        }
                                                    }
                                                %>
                                                <%= documento %>
                                            </span>
                                        </div>
                                    <% } else { %>
                                        <div class="empty-state">
                                            <p>👤 Información del cliente no disponible</p>
                                        </div>
                                    <% } %>
                                </div>

                                <!-- Información de la Orden -->
                                <div class="info-card">
                                    <h3>📅 Información de la Orden</h3>
                                    <div class="info-item">
                                        <strong>Fecha Entrada:</strong>
                                        <span><%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %></span>
                                    </div>
                                    <div class="info-item">
                                        <strong>Fecha Estimada Salida:</strong>
                                        <span><%= orden.getFechaEstimadaSalida() != null ? orden.getFechaEstimadaSalida() : "Por definir" %></span>
                                    </div>
                                    <div class="info-item">
                                        <strong>Fecha Real Salida:</strong>
                                        <span><%= orden.getFechaRealSalida() != null ? orden.getFechaRealSalida() : "Pendiente" %></span>
                                    </div>
                                    <div class="info-item">
                                        <strong>Estado:</strong>
                                        <span><%= orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></span>
                                    </div>
                                    <div class="info-item">
                                        <strong>Recepcionista:</strong>
                                        <span>
                                            <% if (orden.getIDEmpleadoRecepcion() != null) { %>
                                                <%= orden.getIDEmpleadoRecepcion().getNombre() %> 
                                                <%= orden.getIDEmpleadoRecepcion().getApellido() %>
                                            <% } else { %>
                                                Por asignar
                                            <% } %>
                                        </span>
                                    </div>
                                </div>

                                <!-- Descripción del Servicio -->
                                <div class="info-card" style="grid-column: 1 / -1;">
                                    <h3>🔧 Descripción del Servicio</h3>
                                    <div class="info-item" style="grid-template-columns: 1fr;">
                                        <strong>Problema Reportado:</strong>
                                        <span style="white-space: pre-wrap;"><%= orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "N/A" %></span>
                                    </div>
                                    <div class="info-item" style="grid-template-columns: 1fr;">
                                        <strong>Observaciones Internas:</strong>
                                        <span style="white-space: pre-wrap;"><%= orden.getObservaciones() != null ? orden.getObservaciones() : "Ninguna" %></span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Pestaña: Diagnósticos -->
                        <div id="tab-diagnosticos" class="tab-content">
                            <h3>🔍 Diagnósticos Realizados</h3>
                            
                            <% if (orden.getDiagnosticoList() != null && !orden.getDiagnosticoList().isEmpty()) { %>
                                <div class="diagnostic-list">
                                    <% for (Diagnostico diagnostico : orden.getDiagnosticoList()) { %>
                                        <div class="diagnostic-item">
                                            <div class="diagnostic-header">
                                                <strong>Diagnóstico #<%= diagnostico.getIDDiagnostico() %></strong>
                                                <span class="diagnostic-mecanico">
                                                    <% if (diagnostico.getIDEmpleadoMecanico() != null) { %>
                                                        Por: <%= diagnostico.getIDEmpleadoMecanico().getNombre() %> 
                                                        <%= diagnostico.getIDEmpleadoMecanico().getApellido() %>
                                                    <% } else { %>
                                                        Mecánico no asignado
                                                    <% } %>
                                                </span>
                                            </div>
                                            <div class="diagnostic-descripcion">
                                                <strong>Descripción:</strong><br>
                                                <%= diagnostico.getDescripcionDiagnostico() != null ? 
                                                    diagnostico.getDescripcionDiagnostico() : "Descripción no disponible" %>
                                            </div>
                                            <% if (diagnostico.getRecomendaciones() != null) { %>
                                                <div class="diagnostic-recomendaciones" style="margin-top: 10px;">
                                                    <strong>Recomendaciones:</strong><br>
                                                    <%= diagnostico.getRecomendaciones() %>
                                                </div>
                                            <% } %>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="empty-state">
                                    <div class="empty-icon">🔍</div>
                                    <h3>No hay diagnósticos registrados</h3>
                                    <p>No se han realizado diagnósticos para esta orden.</p>
                                    <p>Los diagnósticos serán agregados por el equipo de mecánicos.</p>
                                </div>
                            <% } %>
                        </div>

                        <!-- Pestaña: Facturación -->
                        <div id="tab-facturacion" class="tab-content">
                            <h3>🧾 Información de Facturación</h3>
                            
                            <% if (orden.getFacturaList() != null && !orden.getFacturaList().isEmpty()) { %>
                                <div class="invoice-list">
                                    <% for (Factura factura : orden.getFacturaList()) { %>
                                        <div class="invoice-item">
                                            <div class="invoice-header">
                                                <strong>Factura #<%= factura.getIDFactura() %></strong>
                                                <span class="invoice-total">
                                                    Total: $<%= factura.getTotal() != null ? factura.getTotal() : "0.00" %>
                                                </span>
                                            </div>
                                            <div class="invoice-details">
                                                <div class="info-item">
                                                    <strong>Fecha:</strong>
                                                    <span>
                                                        <% 
                                                            // Usar fechaEntrada como alternativa si no hay fechaFactura
                                                            String fechaFactura = "N/A";
                                                            try {
                                                                if (factura.getFechaFactura() != null) {
                                                                    fechaFactura = factura.getFechaFactura().toString();
                                                                } else if (factura.getFechaEntrada() != null) {
                                                                    fechaFactura = factura.getFechaEntrada().toString();
                                                                }
                                                            } catch (Exception e) {
                                                                fechaFactura = "N/A";
                                                            }
                                                        %>
                                                        <%= fechaFactura %>
                                                    </span>
                                                </div>
                                                <div class="info-item">
                                                    <strong>Estado:</strong>
                                                    <span>
                                                        <% 
                                                            // Intentar diferentes métodos para estado
                                                            String estadoFactura = "N/A";
                                                            try {
                                                                if (factura.getEstado() != null) {
                                                                    estadoFactura = factura.getEstado();
                                                                }
                                                            } catch (Exception e) {
                                                                estadoFactura = "Activa"; // Valor por defecto
                                                            }
                                                        %>
                                                        <%= estadoFactura %>
                                                    </span>
                                                </div>
                                                <div class="info-item">
                                                    <strong>Subtotal:</strong>
                                                    <span>$<%= factura.getSubtotal() != null ? factura.getSubtotal() : "0.00" %></span>
                                                </div>
                                                <div class="info-item">
                                                    <strong>IVA:</strong>
                                                    <span>$<%= factura.getIva() != null ? factura.getIva() : "0.00" %></span>
                                                </div>
                                            </div>
                                            <div style="margin-top: 10px;">
                                                <a href="${pageContext.request.contextPath}/recepcionista/facturas/ver?id=<%= factura.getIDFactura() %>" 
                                                   class="btn btn-sm btn-success">Ver Factura Completa</a>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else if (orden.getFechaRealSalida() != null) { %>
                                <div class="empty-state">
                                    <div class="empty-icon">🧾</div>
                                    <h3>No hay facturas generadas</h3>
                                    <p>Esta orden está completada pero no tiene factura asociada.</p>
                                    <a href="${pageContext.request.contextPath}/recepcionista/facturas/crear?orden=<%= orden.getIDOrdenServicio() %>" 
                                       class="btn btn-success">Generar Factura</a>
                                </div>
                            <% } else { %>
                                <div class="empty-state">
                                    <div class="empty-icon">⏳</div>
                                    <h3>Orden en proceso</h3>
                                    <p>La facturación estará disponible cuando la orden sea completada.</p>
                                    <p>Estado actual: <strong><%= orden.getIDEstadoTrabajo() != null ? 
                                        orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %></strong></p>
                                </div>
                            <% } %>
                        </div>

                        <!-- Pestaña: Historial -->
                        <div id="tab-historial" class="tab-content">
                            <h3>📊 Historial de la Orden</h3>
                            
                            <div class="timeline">
                                <div class="timeline-item">
                                    <div class="timeline-date">Creación de la Orden</div>
                                    <div class="timeline-content">
                                        <strong>Orden creada</strong><br>
                                        Fecha: <%= orden.getFechaEntrada() != null ? orden.getFechaEntrada() : "N/A" %><br>
                                        Recepcionista: <%= orden.getIDEmpleadoRecepcion() != null ? 
                                            orden.getIDEmpleadoRecepcion().getNombre() + " " + orden.getIDEmpleadoRecepcion().getApellido() : "N/A" %>
                                    </div>
                                </div>
                                
                                <% if (orden.getIDVehiculo() != null) { %>
                                    <div class="timeline-item">
                                        <div class="timeline-date">Vehículo Asignado</div>
                                        <div class="timeline-content">
                                            <strong>Vehículo asignado a la orden</strong><br>
                                            Placa: <%= orden.getIDVehiculo().getPlaca() %><br>
                                            Cliente: <%= orden.getIDVehiculo().getIDCliente() != null ? 
                                                orden.getIDVehiculo().getIDCliente().getNombre() + " " + orden.getIDVehiculo().getIDCliente().getApellido() : "N/A" %>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <% if (orden.getDiagnosticoList() != null && !orden.getDiagnosticoList().isEmpty()) { %>
                                    <div class="timeline-item">
                                        <div class="timeline-date">Diagnósticos Realizados</div>
                                        <div class="timeline-content">
                                            <strong><%= orden.getDiagnosticoList().size() %> diagnóstico(s) realizado(s)</strong><br>
                                            Último diagnóstico por: 
                                            <%= orden.getDiagnosticoList().get(orden.getDiagnosticoList().size() - 1).getIDEmpleadoMecanico() != null ? 
                                                orden.getDiagnosticoList().get(orden.getDiagnosticoList().size() - 1).getIDEmpleadoMecanico().getNombre() + " " + 
                                                orden.getDiagnosticoList().get(orden.getDiagnosticoList().size() - 1).getIDEmpleadoMecanico().getApellido() : "Mecánico no asignado" %>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <% if (orden.getFechaRealSalida() != null) { %>
                                    <div class="timeline-item">
                                        <div class="timeline-date">Orden Completada</div>
                                        <div class="timeline-content">
                                            <strong>Orden marcada como completada</strong><br>
                                            Fecha de salida real: <%= orden.getFechaRealSalida() %><br>
                                            Tiempo total: 
                                            <% if (orden.getFechaEntrada() != null) { 
                                                long diff = orden.getFechaRealSalida().getTime() - orden.getFechaEntrada().getTime();
                                                long days = diff / (1000 * 60 * 60 * 24);
                                                long hours = (diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60);
                                            %>
                                                <%= days %> días, <%= hours %> horas
                                            <% } %>
                                        </div>
                                    </div>
                                <% } else if (orden.getFechaEstimadaSalida() != null) { %>
                                    <div class="timeline-item">
                                        <div class="timeline-date">Próxima Actualización</div>
                                        <div class="timeline-content">
                                            <strong>Fecha estimada de entrega</strong><br>
                                            <%= orden.getFechaEstimadaSalida() %><br>
                                            Estado actual: <%= orden.getIDEstadoTrabajo() != null ? 
                                                orden.getIDEstadoTrabajo().getNombreEstado() : "Pendiente" %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Acciones -->
                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes/editar?id=<%= orden.getIDOrdenServicio() %>" 
                           class="btn btn-warning">✏️ Editar Orden</a>
                        
                        <% if (orden.getIDVehiculo() == null) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/ordenes/asignar-vehiculo?id=<%= orden.getIDOrdenServicio() %>" 
                               class="btn btn-primary">🚗 Asignar Vehículo</a>
                        <% } %>
                        
                        <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">↩️ Volver a Órdenes</a>
                        
                        <% if (orden.getFechaRealSalida() == null) { %>
                            <form action="${pageContext.request.contextPath}/recepcionista/ordenes/completar" method="post" style="display: inline;">
                                <input type="hidden" name="id" value="<%= orden.getIDOrdenServicio() %>">
                                <button type="submit" class="btn btn-success"
                                   onclick="return confirm('¿Marcar esta orden como completada?')">✅ Completar Orden</button>
                            </form>
                        <% } else if (orden.getFacturaList() == null || orden.getFacturaList().isEmpty()) { %>
                            <a href="${pageContext.request.contextPath}/recepcionista/facturas/crear?orden=<%= orden.getIDOrdenServicio() %>" 
                               class="btn btn-success">🧾 Generar Factura</a>
                        <% } %>
                        
                        <button onclick="window.print()" class="btn btn-info">🖨️ Imprimir</button>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró la orden solicitada.</p>
                    <a href="${pageContext.request.contextPath}/recepcionista/ordenes" class="btn btn-secondary">Volver a Órdenes</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Funcionalidad de pestañas
        function openTab(tabName) {
            // Ocultar todos los contenidos de pestañas
            const tabContents = document.getElementsByClassName('tab-content');
            for (let i = 0; i < tabContents.length; i++) {
                tabContents[i].classList.remove('active');
            }
            
            // Desactivar todos los botones de pestañas
            const tabButtons = document.getElementsByClassName('tab-button');
            for (let i = 0; i < tabButtons.length; i++) {
                tabButtons[i].classList.remove('active');
            }
            
            // Mostrar la pestaña específica y activar el botón
            document.getElementById(tabName).classList.add('active');
            event.currentTarget.classList.add('active');
        }
        
        // Inicializar primera pestaña
        document.addEventListener('DOMContentLoaded', function() {
            openTab('tab-info');
        });
    </script>
</body>
</html>