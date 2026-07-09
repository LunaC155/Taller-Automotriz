<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%
    Integer totalClientes = (Integer) request.getAttribute("totalClientes");
    Integer clientesNuevosMes = (Integer) request.getAttribute("clientesNuevosMes");
    List<Object[]> estadisticas = (List<Object[]>) request.getAttribute("estadisticas");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reportes de Clientes</title>
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
                <h1>Reportes de Clientes</h1>
                <p>Estadísticas y análisis de la base de clientes</p>
            </div>

            <!-- Resumen ejecutivo -->
            <div class="executive-summary">
                <h2>📈 Resumen Ejecutivo</h2>
                <div class="summary-stats">
                    <div class="stat-card large">
                        <h3>Total de Clientes</h3>
                        <p class="stat-number"><%= totalClientes != null ? totalClientes : 0 %></p>
                        <p class="stat-trend">Registrados en el sistema</p>
                    </div>
                    <div class="stat-card large">
                        <h3>Clientes Nuevos</h3>
                        <p class="stat-number"><%= clientesNuevosMes != null ? clientesNuevosMes : 0 %></p>
                        <p class="stat-trend">Este mes</p>
                    </div>
                    <div class="stat-card large">
                        <h3>Tasa de Crecimiento</h3>
                        <p class="stat-number">
                            <% 
                                double tasaCrecimiento = 0;
                                if (totalClientes != null && totalClientes > 0 && clientesNuevosMes != null) {
                                    tasaCrecimiento = (clientesNuevosMes * 100.0) / totalClientes;
                                }
                            %>
                            <%= String.format("%.1f", tasaCrecimiento) %>%
                        </p>
                        <p class="stat-trend">Mensual</p>
                    </div>
                </div>
            </div>

            <!-- Estadísticas detalladas -->
            <div class="detailed-stats">
                <h3>📊 Estadísticas Detalladas</h3>
                
                <% if (estadisticas != null && !estadisticas.isEmpty()) { %>
                    <div class="stats-grid">
                        <% for (Object[] stat : estadisticas) { %>
                            <div class="stat-card">
                                <h4><%= stat[0] != null ? stat[0].toString() : "N/A" %></h4>
                                <p class="stat-number"><%= stat[1] != null ? stat[1].toString() : "0" %></p>
                                <p class="stat-description"><%= stat[2] != null ? stat[2].toString() : "" %></p>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <p class="no-data">No hay estadísticas disponibles.</p>
                <% } %>
            </div>

            <!-- Gráficos y visualizaciones -->
            <div class="charts-section">
                <h3>📈 Visualizaciones</h3>
                <div class="charts-grid">
                    <div class="chart-card">
                        <h4>Evolución de Clientes</h4>
                        <div class="chart-placeholder">
                                            <p>📊 Gráfico de evolución mensual</p>
                                            <p><em>Los gráficos se implementarán con Chart.js</em></p>
                                        </div>
                                    </div>
                                    <div class="chart-card">
                                        <h4>Distribución por Mes</h4>
                                        <div class="chart-placeholder">
                                            <p>📈 Gráfico de barras mensual</p>
                                            <p><em>Mostrando nuevos clientes por mes</em></p>
                                        </div>
                                    </div>
                                </div>
                            </div>

            <!-- Reportes descargables -->
            <div class="reports-section">
                <h3>📄 Reportes Descargables</h3>
                <div class="reports-grid">
                    <div class="report-card">
                        <h4>Listado Completo</h4>
                        <p>Exportar todos los clientes registrados</p>
                        <div class="report-actions">
                            <button class="btn btn-secondary">📄 PDF</button>
                            <button class="btn btn-secondary">📊 Excel</button>
                        </div>
                    </div>
                    <div class="report-card">
                        <h4>Clientes Nuevos</h4>
                        <p>Clientes registrados en el último mes</p>
                        <div class="report-actions">
                            <button class="btn btn-secondary">📄 PDF</button>
                            <button class="btn btn-secondary">📊 Excel</button>
                        </div>
                    </div>
                    <div class="report-card">
                        <h4>Estadísticas Anuales</h4>
                        <p>Resumen completo del año en curso</p>
                        <div class="report-actions">
                            <button class="btn btn-secondary">📄 PDF</button>
                            <button class="btn btn-secondary">📊 Excel</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Análisis y recomendaciones -->
            <div class="analysis-section">
                <h3>🔍 Análisis y Recomendaciones</h3>
                <div class="analysis-content">
                    <div class="analysis-item">
                        <h4>📈 Tendencias</h4>
                        <ul>
                            <li>La base de clientes ha crecido un <%= String.format("%.1f", tasaCrecimiento) %>% este mes</li>
                            <li>Se recomienda mantener campañas de captación</li>
                            <li>El crecimiento es consistente con los meses anteriores</li>
                        </ul>
                    </div>
                    <div class="analysis-item">
                        <h4>🎯 Oportunidades</h4>
                        <ul>
                            <li>Implementar programas de fidelización</li>
                            <li>Crear campañas para clientes inactivos</li>
                            <li>Desarrollar estrategias de retención</li>
                        </ul>
                    </div>
                    <div class="analysis-item">
                        <h4>📋 Acciones Sugeridas</h4>
                        <ul>
                            <li>Revisar el perfil de clientes nuevos</li>
                            <li>Analizar canales de adquisición más efectivos</li>
                            <li>Establecer metas de crecimiento mensual</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Acciones -->
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/admin/clientes" class="btn btn-primary">↩️ Volver a Clientes</a>
                <button onclick="window.print()" class="btn btn-secondary">🖨️ Imprimir Reporte</button>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>