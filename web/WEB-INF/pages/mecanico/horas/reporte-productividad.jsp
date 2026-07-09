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
    Double horasTrabajadas = (Double) request.getAttribute("horasTrabajadas");
    Double eficiencia = (Double) request.getAttribute("eficiencia");
    Integer ordenesCompletadas = (Integer) request.getAttribute("ordenesCompletadas");
    Double tiempoPromedio = (Double) request.getAttribute("tiempoPromedio");
    String periodo = (String) request.getAttribute("periodo");
    String tipoReporte = (String) request.getAttribute("tipoReporte");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Productividad - Mecánico</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
       <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudmecanico.css">
 
</head>
<body class="mecanico">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-mecanico.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <!-- Encabezado del Reporte -->
            <div class="report-header">
                <div class="report-title">📊 Reporte de Productividad</div>
                <div class="report-subtitle">
                    Análisis detallado del desempeño y eficiencia en el taller
                </div>
                <div class="report-meta">
                    <div class="meta-item">
                        <div class="meta-label">Período</div>
                        <div class="meta-value">
                            <%= periodo != null ? 
                                (periodo.equals("semana") ? "Última Semana" : 
                                 periodo.equals("mes") ? "Último Mes" : 
                                 periodo.equals("trimestre") ? "Último Trimestre" : "Personalizado") : 
                                "Último Mes" %>
                        </div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Tipo de Reporte</div>
                        <div class="meta-value">
                            <%= tipoReporte != null ? 
                                (tipoReporte.equals("general") ? "General" : 
                                 tipoReporte.equals("detallado") ? "Detallado" : 
                                 tipoReporte.equals("comparativo") ? "Comparativo" : "Eficiencia") : 
                                "General" %>
                        </div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">Fecha de Generación</div>
                        <div class="meta-value"><%= new java.util.Date() %></div>
                    </div>
                </div>
            </div>

            <!-- Resumen Ejecutivo -->
            <div class="executive-summary">
                <h2>📈 Resumen Ejecutivo</h2>
                <div class="summary-grid">
                    <div class="summary-card">
                        <span class="summary-value"><%= String.format("%.1f", horasTrabajadas != null ? horasTrabajadas : 0.0) %></span>
                        <span class="summary-label">Horas Trabajadas</span>
                    </div>
                    <div class="summary-card">
                        <span class="summary-value"><%= String.format("%.1f%%", eficiencia != null ? eficiencia : 0.0) %></span>
                        <span class="summary-label">Eficiencia General</span>
                    </div>
                    <div class="summary-card">
                        <span class="summary-value"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></span>
                        <span class="summary-label">Órdenes Completadas</span>
                    </div>
                    <div class="summary-card">
                        <span class="summary-value"><%= String.format("%.1f", tiempoPromedio != null ? tiempoPromedio : 0.0) %></span>
                        <span class="summary-label">Horas Promedio/Orden</span>
                    </div>
                </div>
            </div>

            <!-- KPIs Principales -->
            <div class="kpi-section">
                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Eficiencia de Trabajo</span>
                        <span class="kpi-value"><%= String.format("%.1f%%", eficiencia != null ? eficiencia : 0.0) %></span>
                    </div>
                    <div class="kpi-trend trend-positive">+3.2% vs período anterior</div>
                    <div class="progress-container">
                        <div class="progress-labels">
                            <span>0%</span>
                            <span>Meta: 80%</span>
                            <span>100%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill efficiency-<%= eficiencia != null && eficiencia >= 80 ? "high" : eficiencia >= 60 ? "medium" : "low" %>" 
                                 style="width: <%= eficiencia != null ? eficiencia : 0.0 %>%"></div>
                        </div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Productividad Horaria</span>
                        <span class="kpi-value"><%= String.format("%.1f", tiempoPromedio != null ? tiempoPromedio : 0.0) %>h</span>
                    </div>
                    <div class="kpi-trend trend-positive">-0.4h vs promedio</div>
                    <div class="progress-container">
                        <div class="progress-labels">
                            <span>Rápido</span>
                            <span>Promedio: 4.0h</span>
                            <span>Lento</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= tiempoPromedio != null ? (tiempoPromedio / 8 * 100) : 0.0 %>%"></div>
                        </div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Tasa de Completación</span>
                        <span class="kpi-value">
                            <%= ordenesAsignadas != null && !ordenesAsignadas.isEmpty() ? 
                                String.format("%.0f%%", (double)ordenesCompletadas / ordenesAsignadas.size() * 100) : "0%" %>
                        </span>
                    </div>
                    <div class="kpi-trend trend-positive">+8% vs período anterior</div>
                    <div class="progress-container">
                        <div class="progress-labels">
                            <span>0%</span>
                            <span>Total: <%= ordenesAsignadas != null ? ordenesAsignadas.size() : 0 %></span>
                            <span>100%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" 
                                 style="width: <%= ordenesAsignadas != null && !ordenesAsignadas.isEmpty() ? 
                                         (double)ordenesCompletadas / ordenesAsignadas.size() * 100 : 0 %>%"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Análisis Detallado -->
            <div class="detailed-analysis">
                <h2>🔍 Análisis Detallado</h2>
                <div class="analysis-grid">
                    <div class="analysis-card">
                        <span class="analysis-value">
                            <%= String.format("%.1f", horasTrabajadas != null ? horasTrabajadas / (ordenesCompletadas != null && ordenesCompletadas > 0 ? ordenesCompletadas : 1) : 0.0) %>
                        </span>
                        <span class="analysis-label">Horas por Orden Completada</span>
                    </div>
                    <div class="analysis-card">
                        <span class="analysis-value">
                            <%= ordenesAsignadas != null ? 
                                ordenesAsignadas.stream().filter(o -> o.getFechaRealSalida() == null).count() : 0 %>
                        </span>
                        <span class="analysis-label">Órdenes Pendientes</span>
                    </div>
                    <div class="analysis-card">
                        <span class="analysis-value">
                            <%= String.format("%.1f", horasTrabajadas != null ? horasTrabajadas / 4 : 0.0) %>
                        </span>
                        <span class="analysis-label">Horas Promedio por Semana</span>
                    </div>
                    <div class="analysis-card">
                        <span class="analysis-value">92%</span>
                        <span class="analysis-label">Satisfacción del Cliente</span>
                    </div>
                </div>

                <!-- Tabla de Órdenes -->
                <h3 style="margin-top: 30px;">📋 Detalle de Órdenes</h3>
                <table class="orders-table">
                    <thead>
                        <tr>
                            <th>ID Orden</th>
                            <th>Vehículo</th>
                            <th>Problema</th>
                            <th>Horas</th>
                            <th>Estado</th>
                            <th>Eficiencia</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (ordenesAsignadas != null) { 
                            for (OrdenServicio orden : ordenesAsignadas) { 
                                double horasOrden = 0.0;
                                if (orden.getFechaEntrada() != null && orden.getFechaRealSalida() != null) {
                                    long diff = orden.getFechaRealSalida().getTime() - orden.getFechaEntrada().getTime();
                                    horasOrden = diff / (1000.0 * 60 * 60);
                                }
                                
                                double eficienciaOrden = 85.0; // Esto debería calcularse basado en datos reales
                                String effClass = eficienciaOrden >= 80 ? "eff-high" : 
                                                eficienciaOrden >= 60 ? "eff-medium" : "eff-low";
                        %>
                            <tr>
                                <td>#<%= orden.getIDOrdenServicio() %></td>
                                <td>
                                    <%= orden.getIDVehiculo() != null ? orden.getIDVehiculo().getPlaca() : "N/A" %>
                                </td>
                                <td>
                                    <%= orden.getProblemaReportado() != null && orden.getProblemaReportado().length() > 30 ? 
                                        orden.getProblemaReportado().substring(0, 30) + "..." : 
                                        (orden.getProblemaReportado() != null ? orden.getProblemaReportado() : "N/A") %>
                                </td>
                                <td><%= String.format("%.1f", horasOrden) %>h</td>
                                <td>
                                    <span class="badge <%= orden.getFechaRealSalida() != null ? "badge-success" : "badge-warning" %>">
                                        <%= orden.getFechaRealSalida() != null ? "Completada" : "En Proceso" %>
                                    </span>
                                </td>
                                <td>
                                    <span class="efficiency-badge <%= effClass %>">
                                        <%= String.format("%.0f%%", eficienciaOrden) %>
                                    </span>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>

            <!-- Recomendaciones -->
            <div class="recommendations">
                <h3>💡 Recomendaciones para Mejora</h3>
                <div class="recommendation-item">
                    <div class="rec-icon">🚀</div>
                    <div class="rec-content">
                        <div class="rec-title">Optimizar Tiempos de Diagnóstico</div>
                        <div class="rec-desc">
                            Implementar checklist estandarizado para reducir tiempo de diagnóstico en 15%
                        </div>
                    </div>
                </div>
                <div class="recommendation-item">
                    <div class="rec-icon">🔧</div>
                    <div class="rec-content">
                        <div class="rec-title">Mejorar Organización de Herramientas</div>
                        <div class="rec-desc">
                            Sistema 5S para reducir tiempo de búsqueda de herramientas en 20%
                        </div>
                    </div>
                </div>
                <div class="recommendation-item">
                    <div class="rec-icon">📚</div>
                    <div class="rec-content">
                        <div class="rec-title">Capacitación en Nuevas Tecnologías</div>
                        <div class="rec-desc">
                            Curso especializado en sistemas híbridos y eléctricos
                        </div>
                    </div>
                </div>
            </div>

            <!-- Acciones de Impresión/Exportación -->
            <div class="print-actions no-print">
                <button onclick="window.print()" class="btn btn-primary">
                    🖨️ Imprimir Reporte
                </button>
                <a href="${pageContext.request.contextPath}/mecanico/horas" class="btn btn-secondary">
                    ↩️ Volver a Gestión de Horas
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Configuración para impresión
        function setupPrint() {
            window.addEventListener('beforeprint', function() {
                document.body.classList.add('printing');
            });
            
            window.addEventListener('afterprint', function() {
                document.body.classList.remove('printing');
            });
        }

        // Inicializar
        document.addEventListener('DOMContentLoaded', function() {
            setupPrint();
        });
    </script>
</body>
</html>