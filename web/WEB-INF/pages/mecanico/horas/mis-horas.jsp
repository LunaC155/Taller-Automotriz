<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Empleado, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    Empleado mecanico = (Empleado) request.getAttribute("mecanico");
    List<OrdenServicio> ordenesAsignadas = (List<OrdenServicio>) request.getAttribute("ordenesAsignadas");
    Double horasTotales = (Double) request.getAttribute("horasTotales");
    Double horasEsteMes = (Double) request.getAttribute("horasEsteMes");
    Double horasEstaSemana = (Double) request.getAttribute("horasEstaSemana");
    Integer ordenesCompletadas = (Integer) request.getAttribute("ordenesCompletadas");
    Integer ordenesPendientes = (Integer) request.getAttribute("ordenesPendientes");
    Double eficiencia = (Double) request.getAttribute("eficiencia");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Horas - Mecánico</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
     <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudmecanico.css">
   
</head>
<body class="mecanico">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-mecanico.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <!-- Encabezado del Perfil -->
            <div class="profile-header">
                <div class="profile-content">
                    <div class="profile-avatar">
                        👨‍🔧
                    </div>
                    <div class="profile-info">
                        <div class="profile-name">
                            <%= mecanico != null ? mecanico.getNombre() + " " + mecanico.getApellido() : "Mecánico" %>
                        </div>
                        <div class="profile-role">
                            🔧 Mecánico Especializado
                        </div>
                        <div class="profile-stats">
                            <div class="profile-stat">
                                <span class="stat-number"><%= ordenesAsignadas != null ? ordenesAsignadas.size() : 0 %></span>
                                <span class="stat-label">Órdenes Totales</span>
                            </div>
                            <div class="profile-stat">
                                <span class="stat-number"><%= String.format("%.0f", eficiencia != null ? eficiencia : 0.0) %>%</span>
                                <span class="stat-label">Eficiencia</span>
                            </div>
                            <div class="profile-stat">
                                <span class="stat-number"><%= String.format("%.0f", horasTotales != null ? horasTotales : 0.0) %></span>
                                <span class="stat-label">Horas Totales</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Métricas Principales -->
            <div class="main-metrics">
                <div class="metric-card">
                    <span class="metric-icon">⏱️</span>
                    <span class="metric-value"><%= String.format("%.1f", horasEstaSemana != null ? horasEstaSemana : 0.0) %></span>
                    <span class="metric-label">Horas Esta Semana</span>
                    <div class="metric-trend trend-up">+2.5h vs semana anterior</div>
                </div>
                <div class="metric-card">
                    <span class="metric-icon">📅</span>
                    <span class="metric-value"><%= String.format("%.1f", horasEsteMes != null ? horasEsteMes : 0.0) %></span>
                    <span class="metric-label">Horas Este Mes</span>
                    <div class="metric-trend trend-up">+15h vs mes anterior</div>
                </div>
                <div class="metric-card">
                    <span class="metric-icon">✅</span>
                    <span class="metric-value"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></span>
                    <span class="metric-label">Órdenes Completadas</span>
                    <div class="metric-trend trend-up">+5 vs mes anterior</div>
                </div>
                <div class="metric-card">
                    <span class="metric-icon">🎯</span>
                    <span class="metric-value"><%= String.format("%.1f%%", eficiencia != null ? eficiencia : 0.0) %></span>
                    <span class="metric-label">Tasa de Eficiencia</span>
                    <div class="metric-trend trend-up">+3.2% este mes</div>
                </div>
            </div>

            <!-- Gráficos y Visualizaciones -->
            <div class="charts-section">
                <div class="chart-card">
                    <h3>📈 Distribución de Horas por Semana</h3>
                    <div class="chart-placeholder">
                        <p>📊 Gráfico de horas trabajadas por semana</p>
                        <p><small>Mostrando tendencia de las últimas 8 semanas</small></p>
                    </div>
                </div>
                <div class="chart-card">
                    <h3>🔧 Tipos de Trabajo Realizados</h3>
                    <div class="chart-placeholder">
                        <p>📋 Distribución por categoría de trabajo</p>
                        <p><small>Mantenimiento, reparaciones, diagnósticos, etc.</small></p>
                    </div>
                </div>
            </div>

            <!-- Actividad Reciente -->
            <div class="recent-activity">
                <h3>🕒 Actividad Reciente</h3>
                <div class="activity-list">
                    <div class="activity-item">
                        <div class="activity-icon">⏱️</div>
                        <div class="activity-content">
                            <div class="activity-title">Horas registradas en Orden #<%= ordenesAsignadas != null && !ordenesAsignadas.isEmpty() ? ordenesAsignadas.get(0).getIDOrdenServicio() : "0" %></div>
                            <div class="activity-desc">3.5 horas - Reparación de sistema de frenos</div>
                        </div>
                        <div class="activity-time">Hace 2 horas</div>
                    </div>
                    <div class="activity-item">
                        <div class="activity-icon">✅</div>
                        <div class="activity-content">
                            <div class="activity-title">Orden completada #<%= ordenesAsignadas != null && ordenesAsignadas.size() > 1 ? ordenesAsignadas.get(1).getIDOrdenServicio() : "0" %></div>
                            <div class="activity-desc">Mantenimiento preventivo completado</div>
                        </div>
                        <div class="activity-time">Ayer</div>
                    </div>
                    <div class="activity-item">
                        <div class="activity-icon">📝</div>
                        <div class="activity-content">
                            <div class="activity-title">Justificación de horas enviada</div>
                            <div class="activity-desc">2 horas extra - Complicación técnica</div>
                        </div>
                        <div class="activity-time">Hace 2 días</div>
                    </div>
                    <div class="activity-item">
                        <div class="activity-icon">🎯</div>
                        <div class="activity-content">
                            <div class="activity-title">Meta de eficiencia superada</div>
                            <div class="activity-desc">85% de eficiencia este mes</div>
                        </div>
                        <div class="activity-time">Hace 3 días</div>
                    </div>
                </div>
            </div>

            <!-- Metas y Objetivos -->
            <div class="goals-section">
                <h3>🎯 Mis Metas y Objetivos</h3>
                <div class="goals-grid">
                    <div class="goal-card achieved">
                        <div class="goal-header">
                            <span class="goal-title">Eficiencia Mensual</span>
                            <span class="goal-status">✅ Logrado</span>
                        </div>
                        <p>Mantener eficiencia por encima del 80%</p>
                        <div class="goal-progress">
                            <div class="progress-info">
                                <span>Progreso</span>
                                <span><%= String.format("%.0f", eficiencia != null ? eficiencia : 0.0) %>%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: <%= eficiencia != null ? eficiencia : 0.0 %>%"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="goal-card">
                        <div class="goal-header">
                            <span class="goal-title">Horas Semanales</span>
                            <span class="goal-status">🔄 En Progreso</span>
                        </div>
                        <p>Alcanzar 40 horas semanales consistentemente</p>
                        <div class="goal-progress">
                            <div class="progress-info">
                                <span>Progreso</span>
                                <span><%= String.format("%.0f", horasEstaSemana != null ? (horasEstaSemana / 40 * 100) : 0.0) %>%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: <%= horasEstaSemana != null ? (horasEstaSemana / 40 * 100) : 0.0 %>%"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="goal-card pending">
                        <div class="goal-header">
                            <span class="goal-title">Certificación</span>
                            <span class="goal-status">📚 Pendiente</span>
                        </div>
                        <p>Completar certificación en sistemas híbridos</p>
                        <div class="goal-progress">
                            <div class="progress-info">
                                <span>Progreso</span>
                                <span>25%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Acciones Rápidas -->
            <div style="margin-top: 40px; text-align: center;">
                <div style="display: inline-flex; gap: 15px; flex-wrap: wrap;">
                    <a href="${pageContext.request.contextPath}/mecanico/horas/registrar" class="btn btn-primary">
                        ⏱️ Registrar Horas
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/horas/reportar" class="btn btn-info">
                        📊 Reporte de Productividad
                    </a>
                    <a href="${pageContext.request.contextPath}/mecanico/horas" class="btn btn-secondary">
                        📋 Ver Todas las Horas
                    </a>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>