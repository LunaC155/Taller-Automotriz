<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Usuarios" %>
<%
    Usuarios usuario = (Usuarios) session.getAttribute("usuario");
    Integer idRol = (Integer) session.getAttribute("idRol");
    
    if (usuario == null || idRol == null || idRol != 4) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Obtener datos del cliente con valores por defecto si son null
    Integer totalVehiculos = (Integer) request.getAttribute("totalVehiculos");
    Integer serviciosActivos = (Integer) request.getAttribute("serviciosActivos");
    Integer facturasPendientes = (Integer) request.getAttribute("facturasPendientes");
    
    // Valores por defecto si son null
    totalVehiculos = totalVehiculos != null ? totalVehiculos : 0;
    serviciosActivos = serviciosActivos != null ? serviciosActivos : 0;
    facturasPendientes = facturasPendientes != null ? facturasPendientes : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taller Automotriz - Área de Cliente</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles-cliente.css">
</head>
<body class="cliente">
    <div class="page-wrapper">
        <%@include file="../shared/header.jsp" %>
        <div class="layout-container">
            <%@include file="../shared/sidebar-cliente.jsp" %>
            <main class="main-content-with-sidebar">
                <div class="container">
                    <%@include file="../shared/messages.jsp" %>
                    
                    <div class="welcome-section">
                        <h2>Área de Cliente</h2>
                        <p>Bienvenido, <%= usuario.getUsuario() %> - Consulta información sobre tus vehículos y servicios</p>
                    </div>

                    <!-- Resumen del Cliente -->
                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-icon">🚗</div>
                            <div class="metric-info">
                                <h3><%= totalVehiculos %></h3>
                                <p>Mis Vehículos</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">🔧</div>
                            <div class="metric-info">
                                <h3><%= serviciosActivos %></h3>
                                <p>Servicios Activos</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">🧾</div>
                            <div class="metric-info">
                                <h3><%= facturasPendientes %></h3>
                                <p>Facturas Pendientes</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">⭐</div>
                            <div class="metric-info">
                                <h3 id="proximo-servicio">--</h3>
                                <p>Días Próximo Servicio</p>
                            </div>
                        </div>
                    </div>

                    <!-- Mis Opciones -->
                    <section class="services">
                        <h2 class="section-title">Mis Opciones</h2>
                        <div class="services-grid">
                            <div class="service-card">
                                <div class="service-icon">🚗</div>
                                <h3>Mis Vehículos</h3>
                                <p>Consulta información de tus vehículos registrados.</p>
                                <a href="${pageContext.request.contextPath}/cliente/vehiculos/misvehiculos" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">🔧</div>
                                <h3>Mis Servicios</h3>
                                <p>Sigue el estado de los servicios de tus vehículos.</p>
                                <a href="${pageContext.request.contextPath}/ServicioServlet?action=misservicios" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">📋</div>
                                <h3>Historial de Servicios</h3>
                                <p>Consulta el historial completo de servicios realizados.</p>
                                <a href="${pageContext.request.contextPath}/HistorialServlet?action=ver" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">📅</div>
                                <h3>Agendar Cita</h3>
                                <p>Solicita una nueva cita para servicio o mantenimiento.</p>
                                <a href="${pageContext.request.contextPath}/CitaServlet?action=nueva" class="btn">Agendar</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">🧾</div>
                                <h3>Mis Facturas</h3>
                                <p>Consulta y descarga tus facturas y estados de cuenta.</p>
                                <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">📞</div>
                                <h3>Contacto</h3>
                                <p>Comunícate con nuestro equipo de atención al cliente.</p>
                                <a href="${pageContext.request.contextPath}/ContactoServlet?action=formulario" class="btn">Contactar</a>
                            </div>
                        </div>
                    </section>

                </div>
            </main>
        </div>
        <%@include file="../shared/footer.jsp" %>
    </div>
    
    <script>
        // Cargar servicios activos via AJAX
        document.addEventListener('DOMContentLoaded', function() {
            fetch('${pageContext.request.contextPath}/ServicioServlet?action=activos')
                .then(response => response.text())
                .then(html => {
                    document.getElementById('servicios-activos').innerHTML = html;
                })
                .catch(error => {
                    console.error('Error cargando servicios:', error);
                    document.getElementById('servicios-activos').innerHTML = 
                        '<div class="no-data"><p>No se pudieron cargar los servicios activos</p></div>';
                });
        });
    </script>
</body>
</html>