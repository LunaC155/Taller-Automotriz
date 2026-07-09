<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="java.util.Object[]" %>
<%
    // Verificar sesión
    Integer idRol = (Integer) session.getAttribute("idRol");
    if (session.getAttribute("usuario") == null || idRol == null || idRol != 2) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    List<Object[]> estadisticasGenerales = (List<Object[]>) request.getAttribute("estadisticasGenerales");
    List<Object[]> estadisticasOrdenes = (List<Object[]>) request.getAttribute("estadisticasOrdenes");
    List<String> problemasComunes = (List<String>) request.getAttribute("problemasComunes");
    Integer totalMisDiagnosticos = (Integer) request.getAttribute("totalMisDiagnosticos");
    Integer diagnosticosPendientes = (Integer) request.getAttribute("diagnosticosPendientes");
    Integer ordenesPendientes = (Integer) request.getAttribute("ordenesPendientes");
    Integer ordenesEnProceso = (Integer) request.getAttribute("ordenesEnProceso");
    Integer ordenesCompletadas = (Integer) request.getAttribute("ordenesCompletadas");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas - Reportes Técnicos</title>
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
                <h1>📈 Estadísticas de Reportes Técnicos</h1>
                <p>Métricas y análisis de tu desempeño como mecánico</p>
            </div>

            <!-- Tarjetas de Estadísticas Principales -->
            <div class="stats-grid">
                <div class="stat-card total">
                    <div class="stat-icon">📄</div>
                    <div class="stat-number"><%= totalMisDiagnosticos != null ? totalMisDiagnosticos : 0 %></div>
                    <div class="stat-label">Total Reportes Generados</div>
                </div>
                
                <div class="stat-card pendientes">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-number"><%= diagnosticosPendientes != null ? diagnosticosPendientes : 0 %></div>
                    <div class="stat-label">Diagnósticos Pendientes</div>
                </div>
                
                <div class="stat-card proceso">
                    <div class="stat-icon">🔧</div>
                    <div class="stat-number"><%= ordenesEnProceso != null ? ordenesEnProceso : 0 %></div>
                    <div class="stat-label">Órdenes en Proceso</div>
                </div>
                
                <div class="stat-card completadas">
                    <div class="stat-icon">✅</div>
                    <div class="stat-number"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></div>
                    <div class="stat-label">Órdenes Completadas</div>
                </div>
            </div>

            <!-- Gráficos y Estadísticas Detalladas -->
            <div class="charts-container">
                <!-- Problemas Más Comunes -->
                <div class="chart-card">
                    <h3>🔍 Problemas Más Comunes</h3>
                    <% if (problemasComunes != null && !problemasComunes.isEmpty()) { %>
                        <ul class="problems-list">
                            <% for (int i = 0; i < problemasComunes.size(); i++) { 
                                String problema = problemasComunes.get(i);
                                String rankClass = "problem-rank";
                                if (i == 0) rankClass += " top1";
                                else if (i == 1) rankClass += " top2";
                                else if (i == 2) rankClass += " top3";
                            %>
                                <li class="problem-item">
                                    <span class="<%= rankClass %>"><%= i + 1 %></span>
                                    <span class="problem-text"><%= problema %></span>
                                </li>
                            <% } %>
                        </ul>
                    <% } else { %>
                        <div class="no-data">
                            <div class="icon">📊</div>
                            <p>No hay datos suficientes para mostrar problemas comunes</p>
                        </div>
                    <% } %>
                </div>

                <!-- Estadísticas Generales -->
                <div class="chart-card">
                    <h3>📊 Estadísticas Generales</h3>
                    <% if (estadisticasGenerales != null && !estadisticasGenerales.isEmpty()) { 
                        Object[] stats = estadisticasGenerales.get(0);
                    %>
                        <div class="stat-details">
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= stats[0] != null ? stats[0] : 0 %></span>
                                <span class="stat-detail-label">Total Diagnósticos</span>
                            </div>
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= stats[1] != null ? stats[1] : 0 %></span>
                                <span class="stat-detail-label">Mecánicos Activos</span>
                            </div>
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= stats[2] != null ? stats[2] : 0 %></span>
                                <span class="stat-detail-label">Órdenes con Diagnóstico</span>
                            </div>
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= stats[3] != null ? String.format("%.1f", stats[3]) : "0" %></span>
                                <span class="stat-detail-label">Long. Prom. Descripción</span>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="no-data">
                            <div class="icon">📈</div>
                            <p>No hay estadísticas generales disponibles</p>
                        </div>
                    <% } %>
                </div>

                <!-- Estadísticas de Órdenes -->
                <div class="chart-card">
                    <h3>🔧 Estadísticas de Órdenes</h3>
                    <% if (estadisticasOrdenes != null && !estadisticasOrdenes.isEmpty()) { 
                        Object[] ordenStats = estadisticasOrdenes.get(0);
                    %>
                        <div class="stat-details">
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= ordenStats[0] != null ? ordenStats[0] : 0 %></span>
                                <span class="stat-detail-label">Total Órdenes</span>
                            </div>
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= ordenStats[1] != null ? ordenStats[1] : 0 %></span>
                                <span class="stat-detail-label">Órdenes Pendientes</span>
                            </div>
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= ordenStats[2] != null ? ordenStats[2] : 0 %></span>
                                <span class="stat-detail-label">Órdenes Completadas</span>
                            </div>
                            <div class="stat-detail-item">
                                <span class="stat-detail-value"><%= ordenStats[3] != null ? String.format("%.1f", ordenStats[3]) : "0" %> días</span>
                                <span class="stat-detail-label">Tiempo Promedio</span>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="no-data">
                            <div class="icon">⏱️</div>
                            <p>No hay estadísticas de órdenes disponibles</p>
                        </div>
                    <% } %>
                </div>

                <!-- Distribución de Estados -->
                <div class="chart-card">
                    <h3>📋 Distribución de Estados</h3>
                    <div class="stat-details">
                        <div class="stat-detail-item">
                            <span class="stat-detail-value" style="color: #ffc107;"><%= ordenesPendientes != null ? ordenesPendientes : 0 %></span>
                            <span class="stat-detail-label">Pendientes</span>
                        </div>
                        <div class="stat-detail-item">
                            <span class="stat-detail-value" style="color: #17a2b8;"><%= ordenesEnProceso != null ? ordenesEnProceso : 0 %></span>
                            <span class="stat-detail-label">En Proceso</span>
                        </div>
                        <div class="stat-detail-item">
                            <span class="stat-detail-value" style="color: #28a745;"><%= ordenesCompletadas != null ? ordenesCompletadas : 0 %></span>
                            <span class="stat-detail-label">Completadas</span>
                        </div>
                    </div>
                    
                    <!-- Gráfico circular simple -->
                    <div class="progress-ring">
                        <svg viewBox="0 0 36 36" class="circular-chart">
                            <path class="circle-bg"
                                d="M18 2.0845
                                  a 15.9155 15.9155 0 0 1 0 31.831
                                  a 15.9155 15.9155 0 0 1 0 -31.831"
                            />
                            <% 
                                int total = (ordenesPendientes != null ? ordenesPendientes : 0) + 
                                          (ordenesEnProceso != null ? ordenesEnProceso : 0) + 
                                          (ordenesCompletadas != null ? ordenesCompletadas : 0);
                                double completadasPercent = total > 0 ? (ordenesCompletadas != null ? ordenesCompletadas : 0) * 100.0 / total : 0;
                            %>
                            <path class="circle"
                                stroke="#28a745"
                                stroke-dasharray="<%= completadasPercent %>, 100"
                                d="M18 2.0845
                                  a 15.9155 15.9155 0 0 1 0 31.831
                                  a 15.9155 15.9155 0 0 1 0 -31.831"
                            />
                            <text x="18" y="20.35" class="percentage-text">
                                <%= String.format("%.0f", completadasPercent) %>%
                            </text>
                        </svg>
                    </div>
                    <div style="text-align: center; color: #6c757d; font-size: 0.9em;">
                        Tasa de Completación
                    </div>
                </div>
            </div>

            <!-- Información Adicional -->
            <div class="additional-info" style="margin-top: 30px;">
                <h3>💡 Análisis de Desempeño</h3>
                <div class="info-cards" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
                    <div class="info-card" style="background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;">
                        <h4>📈 Métricas de Productividad</h4>
                        <ul>
                            <li><strong>Reportes por mes:</strong> <%= totalMisDiagnosticos != null ? Math.round(totalMisDiagnosticos / 12.0) : 0 %> promedio</li>
                            <li><strong>Tasa de completación:</strong> <%= totalMisDiagnosticos != null && totalMisDiagnosticos > 0 ? 
                                Math.round((ordenesCompletadas != null ? ordenesCompletadas : 0) * 100.0 / totalMisDiagnosticos) : 0 %>%</li>
                            <li><strong>Eficiencia diagnóstica:</strong> Basada en tiempo promedio</li>
                        </ul>
                    </div>
                    <div class="info-card" style="background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;">
                        <h4>🔧 Especialidades Identificadas</h4>
                        <ul>
                            <% if (problemasComunes != null && !problemasComunes.isEmpty()) { %>
                                <li>Problemas más frecuentes documentados</li>
                                <li>Patrones comunes identificados</li>
                                <li>Áreas de expertise desarrolladas</li>
                            <% } else { %>
                                <li>Continúa documentando diagnósticos</li>
                                <li>Los patrones aparecerán con más datos</li>
                            <% } %>
                        </ul>
                    </div>
                    <div class="info-card" style="background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;">
                        <h4>🎯 Objetivos de Mejora</h4>
                        <ul>
                            <li>Reducir diagnósticos pendientes</li>
                            <li>Mejorar tiempo de respuesta</li>
                            <li>Incrementar precisión diagnóstica</li>
                            <li>Documentar casos complejos</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Navegación -->
            <div class="action-buttons" style="margin-top: 30px; text-align: center;">
                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/mis-reportes" class="btn btn-primary">
                    📄 Ver Mis Reportes
                </a>
                <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico/generar" class="btn btn-success">
                    ➕ Nuevo Reporte
                </a>
                <a href="${pageContext.request.contextPath}/mecanico/dashboard" class="btn btn-secondary">
                    🏠 Volver al Dashboard
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        // Animación para los gráficos circulares
        document.addEventListener('DOMContentLoaded', function() {
            const circles = document.querySelectorAll('.circle');
            circles.forEach(circle => {
                const length = circle.getTotalLength();
                circle.style.strokeDasharray = length;
                circle.style.strokeDashoffset = length;
            });
        });
        
        // Actualizar estadísticas cada 30 segundos (opcional)
        setInterval(function() {
            // Aquí podrías agregar una actualización AJAX de las estadísticas
            console.log('Actualizando estadísticas...');
        }, 30000);
    </script>
</body>
</html>