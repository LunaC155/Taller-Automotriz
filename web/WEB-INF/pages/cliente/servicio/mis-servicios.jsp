<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mis Servicios</title>
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
                <h1>🔧 Mis Servicios</h1>
                <p>Gestiona y consulta el estado de tus servicios</p>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon">📋</div>
                    <div class="metric-info">
                        <h3><c:out value="${not empty ordenes ? ordenes.size() : 0}"/></h3>
                        <p>Total Servicios</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">⏳</div>
                    <div class="metric-info">
                        <h3><c:out value="${not empty ordenesPendientes ? ordenesPendientes.size() : 0}"/></h3>
                        <p>Pendientes</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">✅</div>
                    <div class="metric-info">
                        <h3><c:out value="${not empty ordenesCompletadas ? ordenesCompletadas.size() : 0}"/></h3>
                        <p>Completados</p>
                    </div>
                </div>
            </div>

            <div class="quick-actions">
                <div class="actions-grid">
                    <a href="${pageContext.request.contextPath}/cliente/citas?action=crear" class="action-card">
                        <div class="action-icon">📅</div>
                        <h3>Nueva Cita</h3>
                        <p>Agenda un nuevo servicio</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="action-card">
                        <div class="action-icon">🔍</div>
                        <h3>Ver Catálogo</h3>
                        <p>Explora nuestros servicios</p>
                    </a>
                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=estado-reparacion" class="action-card">
                        <div class="action-icon">📊</div>
                        <h3>Estado Reparación</h3>
                        <p>Consulta el progreso</p>
                    </a>
                </div>
            </div>

            <c:if test="${not empty ordenesPendientes}">
                <div class="services-section">
                    <h2 class="section-title">⏳ Servicios Pendientes</h2>
                    <div class="services-grid">
                        <c:forEach var="orden" items="${ordenesPendientes}">
                            <div class="service-card pending">
                                <div class="service-header">
                                    <h3>Orden #${orden.IDOrdenServicio}</h3>
                                    <span class="status-badge pending">En Proceso</span>
                                </div>
                                <div class="service-body">
                                    <p><strong>Vehículo:</strong> ${orden.IDVehiculo.placa}</p>
                                    <p><strong>Problema:</strong> ${orden.problemaReportado}</p>
                                    <p><strong>Fecha Entrada:</strong> <fmt:formatDate value="${orden.fechaEntrada}" pattern="dd/MM/yyyy"/></p>
                                    <p><strong>Fecha Estimada:</strong> <fmt:formatDate value="${orden.fechaEstimadaSalida}" pattern="dd/MM/yyyy"/></p>
                                    <c:if test="${orden.IDEstadoTrabajo != null}">
                                        <p><strong>Estado:</strong> ${orden.IDEstadoTrabajo.nombreEstado}</p>
                                    </c:if>
                                </div>
                                <div class="service-actions">
                                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=estado-reparacion&id=${orden.IDOrdenServicio}" class="btn btn-sm btn-info">Ver Estado</a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty ordenesCompletadas}">
                <div class="services-section">
                    <h2 class="section-title">✅ Servicios Completados</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Orden #</th>
                                    <th>Vehículo</th>
                                    <th>Problema</th>
                                    <th>Fecha Entrada</th>
                                    <th>Fecha Salida</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="orden" items="${ordenesCompletadas}">
                                    <tr>
                                        <td><strong>#${orden.IDOrdenServicio}</strong></td>
                                        <td>${orden.IDVehiculo.placa}</td>
                                        <td>${orden.problemaReportado}</td>
                                        <td><fmt:formatDate value="${orden.fechaEntrada}" pattern="dd/MM/yyyy"/></td>
                                        <td><fmt:formatDate value="${orden.fechaRealSalida}" pattern="dd/MM/yyyy"/></td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=estado-reparacion&id=${orden.IDOrdenServicio}" class="btn btn-sm btn-info">Ver Detalle</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty ordenes}">
                <div class="no-data">
                    <p>📋 No tienes servicios registrados aún.</p>
                    <a href="${pageContext.request.contextPath}/cliente/citas?action=crear" class="btn btn-primary">📅 Agendar Primer Servicio</a>
                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="btn btn-secondary">🔍 Ver Catálogo</a>
                </div>
            </c:if>

            <c:if test="${not empty serviciosPopulares}">
                <div class="services-section">
                    <h2 class="section-title">⭐ Servicios Recomendados</h2>
                    <div class="services-grid">
                        <c:forEach var="servicio" items="${serviciosPopulares}">
                            <div class="service-card mini">
                                <div class="service-header">
                                    <h4>${servicio.nombreServicio}</h4>
                                </div>
                                <div class="service-body">
                                    <p class="price"><strong><fmt:formatNumber value="${servicio.precioBase}" type="currency"/></strong></p>
                                </div>
                                <div class="service-actions">
                                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=ver&id=${servicio.IDServicio}" class="btn btn-sm btn-info">Ver</a>
                                    <a href="${pageContext.request.contextPath}/cliente/citas?action=crear&servicioId=${servicio.IDServicio}" class="btn btn-sm btn-primary">Solicitar</a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>