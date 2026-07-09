<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Usuarios" %>
<%
    Usuarios usuario = (Usuarios) session.getAttribute("usuario");
    Integer idRol = (Integer) session.getAttribute("idRol");
    
    if (usuario == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Obtener estadísticas para el dashboard del mecánico
    Integer tareasPendientes = (Integer) request.getAttribute("tareasPendientes");
    Integer diagnosticosHoy = (Integer) request.getAttribute("diagnosticosHoy");
    Integer horasTrabajadas = (Integer) request.getAttribute("horasTrabajadas");
    
    // Valores por defecto si son null
    tareasPendientes = tareasPendientes != null ? tareasPendientes : 0;
    diagnosticosHoy = diagnosticosHoy != null ? diagnosticosHoy : 0;
    horasTrabajadas = horasTrabajadas != null ? horasTrabajadas : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Taller Automotriz - Panel de Mecánico</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/styles-mecanico.css">
</head>
<body class="mecanico">
    <%@include file="../shared/header.jsp" %>
    
    <div class="main-layout">
        <%@include file="../shared/sidebar-mecanico.jsp" %>
        
        <div class="main-content-with-sidebar">
            <%@include file="../shared/messages.jsp" %>
            
            <div class="container">
                <div class="welcome-section">
                    <h2>Panel de Mecánico</h2>
                    <p>Bienvenido, <%= usuario.getUsuario() %> - Gestiona tus tareas y órdenes de trabajo</p>
                </div>

                <!-- Métricas del Mecánico -->
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-icon">📋</div>
                        <div class="metric-info">
                            <h3><%= tareasPendientes %></h3>
                            <p>Tareas Pendientes</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">🔍</div>
                        <div class="metric-info">
                            <h3><%= diagnosticosHoy %></h3>
                            <p>Diagnósticos Hoy</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">⏱️</div>
                        <div class="metric-info">
                            <h3><%= horasTrabajadas %></h3>
                            <p>Horas Trabajadas</p>
                        </div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-icon">🚗</div>
                        <div class="metric-info">
                            <h3 id="vehiculos-trabajo">0</h3>
                            <p>Vehículos en Trabajo</p>
                        </div>
                    </div>
                </div>

                <!-- Funciones del Mecánico -->
                <section class="services">
                    <h2 class="section-title">Mis Funciones</h2>
                    <div class="services-grid">
                        <div class="service-card">
                            <div class="service-icon">🔍</div>
                            <h3>Diagnósticos</h3>
                            <p>Realiza diagnósticos y reporta problemas en vehículos.</p>
                            <a href="${pageContext.request.contextPath}/DiagnosticoServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">🔧</div>
                            <h3>Órdenes de Trabajo</h3>
                            <p>Consulta y actualiza el estado de las órdenes de trabajo asignadas.</p>
                            <a href="${pageContext.request.contextPath}/OrdenServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">📋</div>
                            <h3>Mis Tareas</h3>
                            <p>Gestiona las tareas específicas asignadas a tu perfil.</p>
                            <a href="${pageContext.request.contextPath}/TareaServlet?action=listar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">⏱️</div>
                            <h3>Registro de Horas</h3>
                            <p>Registra el tiempo dedicado a cada orden de trabajo.</p>
                            <a href="${pageContext.request.contextPath}/HorasServlet?action=registrar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">📦</div>
                            <h3>Inventario</h3>
                            <p>Consulta disponibilidad de repuestos y materiales.</p>
                            <a href="${pageContext.request.contextPath}/InventarioServlet?action=consultar" class="btn">Acceder</a>
                        </div>

                        <div class="service-card">
                            <div class="service-icon">📝</div>
                            <h3>Reportes Técnicos</h3>
                            <p>Genera reportes técnicos de los trabajos realizados.</p>
                            <a href="${pageContext.request.contextPath}/ReporteTecnicoServlet?action=generar" class="btn">Acceder</a>
                        </div>
                    </div>
                </section>

            </div>
        </div>
    </div>

    <%@include file="../shared/footer.jsp" %>
    
    <script>
        // Cargar órdenes recientes via AJAX
        document.addEventListener('DOMContentLoaded', function() {
            fetch('${pageContext.request.contextPath}/OrdenServlet?action=recientes')
                .then(response => response.text())
                .then(html => {
                    document.getElementById('ordenes-recientes').innerHTML = html;
                })
                .catch(error => {
                    console.error('Error cargando órdenes:', error);
                    document.getElementById('ordenes-recientes').innerHTML = 
                        '<div class="no-data"><p>No se pudieron cargar las órdenes recientes</p></div>';
                });
        });
    </script>
</body>
</html>