<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Usuarios" %>
<%
    Usuarios usuario = (Usuarios) session.getAttribute("usuario");
    Integer idRol = (Integer) session.getAttribute("idRol");

    if (usuario == null || idRol == null || idRol != 1) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Obtener estadísticas para el dashboard
    Integer totalClientes = (Integer) request.getAttribute("totalClientes");
    Integer totalEmpleados = (Integer) request.getAttribute("totalEmpleados");
    Integer ordenesPendientes = (Integer) request.getAttribute("ordenesPendientes");
    Double facturacionMensual = (Double) request.getAttribute("facturacionMensual");
    
    // Valores por defecto si son null
    totalClientes = totalClientes != null ? totalClientes : 0;
    totalEmpleados = totalEmpleados != null ? totalEmpleados : 0;
    ordenesPendientes = ordenesPendientes != null ? ordenesPendientes : 0;
    facturacionMensual = facturacionMensual != null ? facturacionMensual : 0.0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taller Automotriz - Panel de Administración</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css"> 
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles-admin.css">
</head>
<body class="admin">
    <%@include file="../shared/header.jsp" %>
    
    <div class="main-layout">
        <%@include file="../shared/sidebar-admin.jsp" %>
        
        <div class="main-content-with-sidebar">
            <%@include file="../shared/messages.jsp" %>
            
            <div class="container">
                <div class="welcome-section">
                    <h2>Panel de Administración</h2>
                    <p>Bienvenido, <%= usuario.getUsuario() %> - Gestión completa del sistema</p>
                </div>

                <!-- Métricas Principales -->
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-icon">👥</div>
                        <div class="metric-info">
                            <h3><%= totalClientes %></h3>
                            <p>Clientes Registrados</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">👨‍💼</div>
                        <div class="metric-info">
                            <h3><%= totalEmpleados %></h3>
                            <p>Empleados Activos</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">🔧</div>
                        <div class="metric-info">
                            <h3><%= ordenesPendientes %></h3>
                            <p>Órdenes Pendientes</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">💰</div>
                        <div class="metric-info">
                            <h3>$<%= String.format("%,.2f", facturacionMensual) %></h3>
                            <p>Facturación Mensual</p>
                        </div>
                    </div>
                </div>

                <!-- Funciones de Administración -->
                <section class="services">
                    <h2 class="section-title">Funciones de Administración</h2>
                    <div class="services-grid">
                        <div class="service-card">
                            <div class="service-icon">👥</div>
                            <h3>Gestión de Empleados</h3>
                            <p>Administra la información de todos los empleados del taller.</p>
                            <a href="${pageContext.request.contextPath}/EmpleadoServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">👤</div>
                            <h3>Gestión de Clientes</h3>
                            <p>Administra la base de datos de clientes del taller.</p>
                            <a href="${pageContext.request.contextPath}/ClienteServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">🚗</div>
                            <h3>Vehículos</h3>
                            <p>Gestiona el registro de vehículos de los clientes.</p>
                            <a href="${pageContext.request.contextPath}/VehiculoServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">🔐</div>
                            <h3>Gestión de Roles</h3>
                            <p>Administra los roles y permisos del sistema.</p>
                            <a href="${pageContext.request.contextPath}/RolesServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">📊</div>
                            <h3>Reportes</h3>
                            <p>Genera reportes detallados del funcionamiento del taller.</p>
                            <a href="${pageContext.request.contextPath}/ReporteServlet?action=listar" class="btn">Acceder</a>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>