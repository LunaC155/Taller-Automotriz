<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Estadísticas del Historial</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
 
</head>
<body class="cliente">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-cliente.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>📈 Estadísticas del Historial</h1>
                <p>Métricas y análisis de tus servicios y facturación</p>
            </div>

            <div class="stats-overview">
                <div class="stats-grid">
                    <div class="stat-card primary">
                        <div class="stat-icon">🔧</div>
                        <div class="stat-info">
                            <h3><c:out value="${totalServicios}" default="0"/></h3>
                            <p>Total Servicios</p>
                        </div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-icon">✅</div>
                        <div class="stat-info">
                            <h3><c:out value="${serviciosCompletados}" default="0"/></h3>
                            <p>Completados</p>
                        </div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-icon">⏳</div>
                        <div class="stat-info">
                            <h3><c:out value="${serviciosPendientes}" default="0"/></h3>
                            <p>Pendientes</p>
                        </div>
                    </div>
                    <div class="stat-card info">
                        <div class="stat-icon">🚗</div>
                        <div class="stat-info">
                            <h3><c:out value="${totalVehiculos}" default="0"/></h3>
                            <p>Vehículos</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="stats-content">
                <div class="stats-row">
                    <div class="stats-column">
                        <div class="stats-card">
                            <h3>📊 Distribución de Servicios</h3>
                            <div class="stats-chart">
                                <%-- SE CORRIGE: Cálculo de porcentajes con JSTL/EL --%>
                                <c:set var="pCompletados" value="${totalServicios > 0 ? (serviciosCompletados * 100) / totalServicios : 0}" />
                                <div class="chart-container">
                                    <div class="chart-pie" style="--p-completed: ${pCompletados}%;"></div>
                                    <div class="chart-legend">
                                        <div class="legend-item">
                                            <span class="legend-color completed"></span>
                                            <span>Completados: ${serviciosCompletados} (<fmt:formatNumber value="${pCompletados/100}" type="percent" minFractionDigits="1"/>)</span>
                                        </div>
                                        <div class="legend-item">
                                            <span class="legend-color pending"></span>
                                            <span>Pendientes: ${serviciosPendientes} (<fmt:formatNumber value="${(totalServicios > 0 ? (serviciosPendientes * 100) / totalServicios : 0)/100}" type="percent" minFractionDigits="1"/>)</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <c:if test="${not empty serviciosPorVehiculo}">
                            <div class="stats-card">
                                <h3>🚗 Servicios por Vehículo</h3>
                                <div class="vehicle-stats">
                                    <c:forEach var="stats" items="${serviciosPorVehiculo}">
                                        <c:set var="placa" value="${stats[0]}"/>
                                        <c:set var="cantidad" value="${stats[1]}"/>
                                        <c:set var="porcentaje" value="${totalServicios > 0 ? (cantidad * 100) / totalServicios : 0}"/>
                                        <div class="vehicle-stat-item">
                                            <div class="vehicle-info">
                                                <strong>${placa}</strong>
                                                <span>${cantidad} servicios</span>
                                            </div>
                                            <div class="stat-bar">
                                                <div class="bar-fill" style="width: ${porcentaje}%;">
                                                    <fmt:formatNumber value="${porcentaje}" maxFractionDigits="0"/>%
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <div class="stats-column">
                        <div class="stats-card">
                            <h3>💰 Resumen Financiero</h3>
                            <div class="financial-stats">
                                <div class="financial-item">
                                    <strong>Total Facturado</strong>
                                    <span class="amount"><fmt:formatNumber value="${totalFacturado}" type="currency"/></span>
                                </div>
                                <div class="financial-item">
                                    <strong>Promedio por Factura</strong>
                                    <span class="amount"><fmt:formatNumber value="${promedioFactura}" type="currency"/></span>
                                </div>
                                <div class="financial-item">
                                    <strong>Total Facturas</strong>
                                    <span class="count"><c:out value="${totalFacturas}" default="0"/></span>
                                </div>
                                <div class="financial-item">
                                    <strong>Tiempo Promedio Reparación</strong>
                                    <span class="time"><fmt:formatNumber value="${tiempoPromedioReparacion}" maxFractionDigits="1"/> días</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="navigation-buttons">
                 <%-- SE CORRIGEN: Rutas de los botones de navegación --%>
                <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-secondary">
                    ↩️ Volver al Historial
                </a>
                <a href="${pageContext.request.contextPath}/HistorialServlet?action=facturas" class="btn btn-info">
                    🧾 Ver Facturas
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>