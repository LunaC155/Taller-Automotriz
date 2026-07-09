<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, java.util.List" %>
<%
    // Verificar sesión
    String userRole = (String) session.getAttribute("rol");
    if (session.getAttribute("usuario") == null || userRole == null || !"mecanico".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<OrdenServicio> ordenesAsignadas = (List<OrdenServicio>) request.getAttribute("ordenesAsignadas");
    Double horasTotales = (Double) request.getAttribute("horasTotales");
    Double eficiencia = (Double) request.getAttribute("eficiencia");
    Integer ordenesCompletadas = (Integer) request.getAttribute("ordenesCompletadas");
    Double tiempoPromedioReparacion = (Double) request.getAttribute("tiempoPromedioReparacion");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportar Productividad - Mecánico</title>
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
                <h1>📊 Reporte de Productividad</h1>
                <p>Analiza y reporta tu desempeño y productividad en el taller</p>
            </div>

            <!-- Métricas Principales -->
            <div class="metrics-grid">
                <div class="metric-card horas">
                    <span class="metric-value"><%= String.format("%.1f", horasTotales != null ? horasTotales : 0.0) %></span>
                    <span class="metric-label">Horas Totales Trabajadas</span>
                    <div class="metric-trend trend-up">↗️ Este mes</div>
                </div>
                <div class="metric-card eficiencia">
                    <span class="metric-value"><%= String.format("%.1f", eficiencia != null ? eficiencia : 0.0) %>%</span>
                    <span class="metric-label">Eficiencia General</span>
                    <div class="metric-trend trend-up">↗️ +5.2% vs mes anterior</div>
                </div>
                <div class="metric-card completadas">
                    <span class="metric-value"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></span>
                    <span class="metric-label">Órdenes Completadas</span>
                    <div class="metric-trend trend-up">↗️ +3 este mes</div>
                </div>
                <div class="metric-card tiempo">
                    <span class="metric-value"><%= String.format("%.1f", tiempoPromedioReparacion != null ? tiempoPromedioReparacion : 0.0) %></span>
                    <span class="metric-label">Horas Promedio/Orden</span>
                    <div class="metric-trend trend-down">↘️ -0.3h vs promedio</div>
                </div>
            </div>

            <!-- Formulario de Reporte -->
            <div class="report-form">
                <h3>📈 Generar Reporte de Productividad</h3>
                <form action="${pageContext.request.contextPath}/mecanico/horas/reportar" method="post" class="form-grid">
                    <div class="form-group">
                        <label for="periodo">Período del Reporte</label>
                        <select id="periodo" name="periodo" class="form-control">
                            <option value="semana">Última Semana</option>
                            <option value="mes" selected>Último Mes</option>
                            <option value="trimestre">Último Trimestre</option>
                            <option value="personalizado">Personalizado</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="tipoReporte">Tipo de Reporte</label>
                        <select id="tipoReporte" name="tipoReporte" class="form-control">
                            <option value="general">Reporte General</option>
                            <option value="detallado">Reporte Detallado</option>
                            <option value="comparativo">Reporte Comparativo</option>
                            <option value="eficiencia">Análisis de Eficiencia</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="formato">Formato de Salida</label>
                        <select id="formato" name="formato" class="form-control">
                            <option value="web">Vista Web</option>
                            <option value="pdf">PDF</option>
                            <option value="excel">Excel</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">📊 Generar Reporte</button>
                    </div>
                </form>
            </div>

            <!-- Gráficos y Visualizaciones -->
            <div class="chart-container">
                <h3>📈 Tendencia de Productividad</h3>
                <div class="chart-placeholder">
                    <p>📊 Gráfico de tendencia de horas trabajadas y eficiencia</p>
                    <p><small>El gráfico se generará automáticamente al crear el reporte</small></p>
                </div>
            </div>

            <!-- Indicadores de Desempeño -->
            <div class="performance-indicators">
                <div class="indicator-card">
                    <div class="indicator-header">
                        <span class="indicator-title">Eficiencia por Tipo de Trabajo</span>
                        <span class="indicator-value">85%</span>
                    </div>
                    <div>
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Mantenimiento</span>
                            <span>92%</span>
                        </div>
                        <div class="progress-bar-metric">
                            <div class="progress-fill efficiency-high" style="width: 92%;"></div>
                        </div>
                    </div>
                    <div style="margin-top: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Reparaciones</span>
                            <span>78%</span>
                        </div>
                        <div class="progress-bar-metric">
                            <div class="progress-fill efficiency-medium" style="width: 78%;"></div>
                        </div>
                    </div>
                    <div style="margin-top: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Diagnósticos</span>
                            <span>88%</span>
                        </div>
                        <div class="progress-bar-metric">
                            <div class="progress-fill efficiency-high" style="width: 88%;"></div>
                        </div>
                    </div>
                </div>

                <div class="indicator-card">
                    <div class="indicator-header">
                        <span class="indicator-title">Distribución de Horas</span>
                        <span class="indicator-value"><%= String.format("%.1f", horasTotales != null ? horasTotales : 0.0) %>h</span>
                    </div>
                    <div style="margin-top: 15px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Trabajo Productivo</span>
                            <span>78%</span>
                        </div>
                        <div class="progress-bar-metric">
                            <div class="progress-fill" style="width: 78%; background: #28a745;"></div>
                        </div>
                    </div>
                    <div style="margin-top: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Espera/Logística</span>
                            <span>12%</span>
                        </div>
                        <div class="progress-bar-metric">
                            <div class="progress-fill" style="width: 12%; background: #ffc107;"></div>
                        </div>
                    </div>
                    <div style="margin-top: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Administrativo</span>
                            <span>10%</span>
                        </div>
                        <div class="progress-bar-metric">
                            <div class="progress-fill" style="width: 10%; background: #17a2b8;"></div>
                        </div>
                    </div>
                </div>

                <div class="indicator-card">
                    <div class="indicator-header">
                        <span class="indicator-title">Comparativa con Promedio</span>
                        <span class="indicator-value">+7.5%</span>
                    </div>
                    <table class="comparison-table">
                        <tr>
                            <td>Horas/Orden</td>
                            <td>3.2h</td>
                            <td class="positive-diff">-0.4h</td>
                        </tr>
                        <tr>
                            <td>Órdenes/Día</td>
                            <td>2.5</td>
                            <td class="positive-diff">+0.3</td>
                        </tr>
                        <tr>
                            <td>Eficiencia</td>
                            <td>85%</td>
                            <td class="positive-diff">+5%</td>
                        </tr>
                        <tr>
                            <td>Retrabajos</td>
                            <td>2%</td>
                            <td class="positive-diff">-1%</td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- Información Adicional -->
            <div class="additional-info" style="margin-top: 30px;">
                <h3>🎯 Metas y Objetivos</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                    <div>
                        <h4>✅ Metas Cumplidas</h4>
                        <ul>
                            <li>📈 Eficiencia > 80% ✅</li>
                            <li>⏱️ Promedio < 4h/orden ✅</li>
                            <li>🔧 Retrabajos < 5% ✅</li>
                            <li>👥 Satisfacción > 90% ✅</li>
                        </ul>
                    </div>
                    <div>
                        <h4>🎯 Próximos Objetivos</h4>
                        <ul>
                            <li>🚀 Eficiencia > 85%</li>
                            <li>⚡ Tiempo promedio < 3.5h</li>
                            <li>💡 Certificación especializada</li>
                            <li>🌟 Líder en productividad</li>
                        </ul>
                    </div>
                    <div>
                        <h4>📋 Recomendaciones</h4>
                        <ul>
                            <li>Optimizar tiempos de diagnóstico</li>
                            <li>Mejorar organización de herramientas</li>
                            <li>Capacitación en nuevas tecnologías</li>
                            <li>Estandarizar procedimientos</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>