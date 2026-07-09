<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    String tipoReporte = (String) request.getAttribute("tipoReporte");
    Date fechaInicio = (Date) request.getAttribute("fechaInicio");
    Date fechaFin = (Date) request.getAttribute("fechaFin");
    List<Object[]> estadisticas = (List<Object[]>) request.getAttribute("estadisticas");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String fechaInicioStr = fechaInicio != null ? sdf.format(fechaInicio) : "";
    String fechaFinStr = fechaFin != null ? sdf.format(fechaFin) : "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte Generado</title>
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
                <h1>Reporte Generado</h1>
                <p>Resultados del reporte solicitado</p>
            </div>

            <!-- Información del reporte -->
            <div class="report-header">
                <div class="report-info">
                    <h2>
                        <% 
                            String tituloReporte = "";
                            switch(tipoReporte != null ? tipoReporte : "") {
                                case "financiero":
                                    tituloReporte = "📊 Reporte Financiero";
                                    break;
                                case "productividad":
                                    tituloReporte = "⚙️ Reporte de Productividad";
                                    break;
                                case "vehiculos":
                                    tituloReporte = "🚗 Reporte de Vehículos";
                                    break;
                                case "inventario":
                                    tituloReporte = "📦 Reporte de Inventario";
                                    break;
                                default:
                                    tituloReporte = "📈 Reporte General";
                            }
                        %>
                        <%= tituloReporte %>
                    </h2>
                    <div class="report-meta">
                        <p><strong>Fecha de generación:</strong> <%= new Date() %></p>
                        <% if (fechaInicio != null && fechaFin != null) { %>
                            <p><strong>Período:</strong> <%= fechaInicioStr %> al <%= fechaFinStr %></p>
                        <% } %>
                    </div>
                </div>
                
                <div class="report-actions">
                    <button onclick="window.print()" class="btn btn-secondary">🖨️ Imprimir</button>
                    <a href="${pageContext.request.contextPath}/ReporteServlet?action=listar" class="btn btn-primary">📊 Nuevo Reporte</a>
                </div>
            </div>

            <!-- Contenido del reporte según el tipo -->
            <div class="report-content">
                <% if ("financiero".equals(tipoReporte)) { %>
                    <!-- Reporte Financiero -->
                    <div class="report-section">
                        <h3>💰 Resumen Financiero</h3>
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { %>
                            <div class="stats-grid">
                                <% for (Object[] stat : estadisticas) { %>
                                    <div class="stat-card large">
                                        <h4><%= stat[0] != null ? stat[0].toString() : "N/A" %></h4>
                                        <p class="stat-number">$<%= stat[1] != null ? stat[1].toString() : "0.00" %></p>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <p class="no-data">No hay datos financieros para el período seleccionado.</p>
                        <% } %>
                    </div>
                    
                <% } else if ("productividad".equals(tipoReporte)) { %>
                    <!-- Reporte de Productividad -->
                    <div class="report-section">
                        <h3>⚙️ Métricas de Productividad</h3>
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { %>
                            <div class="table-container">
                                <table class="data-table">
                                    <thead>
                                        <tr>
                                            <th>Métrica</th>
                                            <th>Valor</th>
                                            <th>Unidad</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Object[] stat : estadisticas) { %>
                                            <tr>
                                                <td><%= stat[0] != null ? stat[0].toString() : "N/A" %></td>
                                                <td><%= stat[1] != null ? stat[1].toString() : "N/A" %></td>
                                                <td><%= stat[2] != null ? stat[2].toString() : "N/A" %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } else { %>
                            <p class="no-data">No hay datos de productividad para el período seleccionado.</p>
                        <% } %>
                    </div>
                    
                <% } else if ("vehiculos".equals(tipoReporte)) { %>
                    <!-- Reporte de Vehículos -->
                    <div class="report-section">
                        <h3>🚗 Estadísticas de Vehículos</h3>
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { %>
                            <div class="stats-section">
                                <% for (Object[] stat : estadisticas) { %>
                                    <div class="stat-card">
                                        <h4><%= stat[0] != null ? stat[0].toString() : "N/A" %></h4>
                                        <p class="stat-number"><%= stat[1] != null ? stat[1].toString() : "0" %></p>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <p class="no-data">No hay datos de vehículos disponibles.</p>
                        <% } %>
                    </div>
                    
                <% } else if ("inventario".equals(tipoReporte)) { %>
                    <!-- Reporte de Inventario -->
                    <div class="report-section">
                        <h3>📦 Estado del Inventario</h3>
                        <% if (estadisticas != null && !estadisticas.isEmpty()) { %>
                            <div class="table-container">
                                <table class="data-table">
                                    <thead>
                                        <tr>
                                            <th>Producto</th>
                                            <th>Stock Actual</th>
                                            <th>Stock Mínimo</th>
                                            <th>Estado</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Object[] stat : estadisticas) { %>
                                            <tr>
                                                <td><%= stat[0] != null ? stat[0].toString() : "N/A" %></td>
                                                <td><%= stat[1] != null ? stat[1].toString() : "0" %></td>
                                                <td><%= stat[2] != null ? stat[2].toString() : "0" %></td>
                                                <td>
                                                    <span class="badge badge-success">Disponible</span>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } else { %>
                            <p class="no-data">No hay datos de inventario disponibles.</p>
                        <% } %>
                    </div>
                    
                <% } else { %>
                    <div class="error-message">
                        <p>❌ Tipo de reporte no válido.</p>
                    </div>
                <% } %>
            </div>

            <!-- Resumen ejecutivo -->
            <div class="executive-summary">
                <h3>📋 Resumen Ejecutivo</h3>
                <div class="summary-content">
                    <p>El reporte generado muestra la información solicitada para el período seleccionado. 
                    <% if ("financiero".equals(tipoReporte)) { %>
                        Se observa el comportamiento financiero del taller durante el período analizado.
                    <% } else if ("productividad".equals(tipoReporte)) { %>
                        Se presentan las métricas de productividad y eficiencia operacional.
                    <% } else if ("vehiculos".equals(tipoReporte)) { %>
                        Se detallan las estadísticas del parque vehicular atendido.
                    <% } else if ("inventario".equals(tipoReporte)) { %>
                        Se muestra el estado actual del inventario de repuestos.
                    <% } %>
                    </p>
                    
                    <div class="key-findings">
                        <h4>🔍 Hallazgos Clave</h4>
                        <ul>
                            <li>Los datos presentados reflejan la operación normal del taller</li>
                            <li>Se recomienda revisar periódicamente estos indicadores</li>
                            <li>Considere ajustar los filtros para análisis más específicos</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Acciones finales -->
            <div class="report-footer">
                <div class="action-buttons">
                   <a href="${pageContext.request.contextPath}/ReporteServlet?action=listar" class="btn btn-primary">📊 Nuevo Reporte</a>
                    <a href="${pageContext.request.contextPath}/admin/index" class="btn btn-secondary">🏠 Ir al Inicio</a>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>