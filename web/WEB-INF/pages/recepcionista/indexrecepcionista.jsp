<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Usuarios" %>
<%
    Usuarios usuario = (Usuarios) session.getAttribute("usuario");
    Integer idRol = (Integer) session.getAttribute("idRol");
    
    if (usuario == null || idRol == null || idRol != 3) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Obtener estadísticas para recepcionista
    Integer citasHoy = (Integer) request.getAttribute("citasHoy");
    Integer recepcionesPendientes = (Integer) request.getAttribute("recepcionesPendientes");
    Integer facturasPendientes = (Integer) request.getAttribute("facturasPendientes");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taller Automotriz - Panel de Recepción</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles-recepcionista.css">
</head>
<body class="recepcionista">
    <div class="page-wrapper">
        <%@include file="../shared/header.jsp" %>
        <div class="layout-container">
            <%@include file="../shared/sidebar-recepcionista.jsp" %>
            <main class="main-content-with-sidebar">
                <div class="container">
                    <%@include file="../shared/messages.jsp" %>
                    
                    <div class="welcome-section">
                        <h2>Panel de Recepción</h2>
                        <p>Bienvenido/a, <%= usuario.getUsuario() %> - Gestiona recepciones y atención al cliente</p>
                    </div>

                    <!-- Métricas de Recepción -->
                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-icon">📅</div>
                            <div class="metric-info">
                                <h3><%= citasHoy != null ? citasHoy : "0" %></h3>
                                <p>Citas para Hoy</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">🚗</div>
                            <div class="metric-info">
                                <h3><%= recepcionesPendientes != null ? recepcionesPendientes : "0" %></h3>
                                <p>Recepciones Pendientes</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">💰</div>
                            <div class="metric-info">
                                <h3><%= facturasPendientes != null ? facturasPendientes : "0" %></h3>
                                <p>Facturas Pendientes</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">👤</div>
                            <div class="metric-info">
                                <h3 id="clientes-espera">0</h3>
                                <p>Clientes en Espera</p>
                            </div>
                        </div>
                    </div>

                    <!-- Funciones de Recepción -->
                    <section class="services">
                        <h2 class="section-title">Funciones de Recepción</h2>
                        <div class="services-grid">
                            <div class="service-card">
                                <div class="service-icon">🚗</div>
                                <h3>Recepción de Vehículos</h3>
                                <p>Registra la entrada de un vehículo al taller.</p>
                                <a href="${pageContext.request.contextPath}/RecepcionServlet?action=listar" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">📅</div>
                                <h3>Gestión de Citas</h3>
                                <p>Administra las citas programadas de clientes.</p>
                                <a href="${pageContext.request.contextPath}/CitaServlet?action=listar" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">👤</div>
                                <h3>Gestión de Clientes</h3>
                                <p>Administra la información de los clientes del taller.</p>
                                <a href="${pageContext.request.contextPath}/ClienteServlet?action=listar" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">📋</div>
                                <h3>Órdenes de Servicio</h3>
                                <p>Crea y gestiona órdenes de servicio para clientes.</p>
                                <a href="${pageContext.request.contextPath}/OrdenServlet?action=listar" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">💰</div>
                                <h3>Facturación</h3>
                                <p>Gestiona facturas y pagos de los servicios.</p>
                                <a href="${pageContext.request.contextPath}/FacturaServlet?action=listar" class="btn">Acceder</a>
                            </div>

                            <div class="service-card">
                                <div class="service-icon">📞</div>
                                <h3>Atención al Cliente</h3>
                                <p>Gestiona consultas y seguimiento a clientes.</p>
                                <a href="${pageContext.request.contextPath}/AtencionServlet?action=listar" class="btn">Acceder</a>
                            </div>
                        </div>
                    </section>
                </div>
            </main>
        </div>
        <%@include file="../shared/footer.jsp" %>
    </div>
</body>
</html>