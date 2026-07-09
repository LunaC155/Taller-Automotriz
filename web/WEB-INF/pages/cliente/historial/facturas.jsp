<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.Factura" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Historial de Facturas</title>
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
                <h1>🧾 Historial de Facturas</h1>
                <p>Consulta y gestiona todas tus facturas</p>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon">🧾</div>
                    <div class="metric-info">
                        <h3>${not empty historialFacturas ? historialFacturas.size() : 0}</h3>
                        <p>Total Facturas</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">✅</div>
                    <div class="metric-info">
                        <h3>${facturasPagadas}</h3>
                        <p>Pagadas</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">⏳</div>
                    <div class="metric-info">
                        <h3>${facturasPendientes}</h3>
                        <p>Pendientes</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">💰</div>
                    <div class="metric-info">
                        <h3><fmt:formatNumber value="${totalFacturado}" type="currency"/></h3>
                        <p>Total Facturado</p>
                    </div>
                </div>
            </div>

            <div class="invoices-section">
                <h2 class="section-title">📋 Lista de Facturas</h2>
                
                <c:choose>
                    <c:when test="${not empty historialFacturas}">
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Factura #</th>
                                        <th>Orden #</th>
                                        <th>Vehículo</th>
                                        <th>Fecha Emisión</th>
                                        <th>Total</th>
                                        <th>Estado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="factura" items="${historialFacturas}">
                                        <tr>
                                            <td><strong>#${factura.numeroFactura}</strong></td>
                                            <td>#${factura.IDOrdenServicio.IDOrdenServicio}</td>
                                            <td>${factura.IDOrdenServicio.IDVehiculo.placa}</td>
                                            <td><fmt:formatDate value="${factura.fechaEmision}" pattern="dd/MM/yyyy"/></td>
                                            <td><strong><fmt:formatNumber value="${factura.total}" type="currency"/></strong></td>
                                            <td>
                                                <span class="status-badge ${factura.IDEstadoFactura.nombreEstado == 'PAGADA' ? 'completed' : 'pending'}">
                                                    ${factura.IDEstadoFactura.nombreEstado}
                                                </span>
                                            </td>
                                            <td class="actions">
                                                <%-- SE CORRIGE: Enlace para ver el detalle de la orden --%>
                                                <a href="${pageContext.request.contextPath}/HistorialServlet?action=ver&id=${factura.IDOrdenServicio.IDOrdenServicio}" 
                                                   class="btn btn-sm btn-secondary" title="Ver servicio">🔧</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div class="status-summary">
                            <h3>📈 Resumen por Estado</h3>
                            <div class="status-cards">
                                <div class="status-card paid">
                                    <h4>Pagadas</h4>
                                    <p class="count">${facturasPagadas}</p>
                                    <%-- SE CORRIGE: Se usa el atributo calculado en el servlet --%>
                                    <p class="amount"><fmt:formatNumber value="${totalPagado}" type="currency"/></p>
                                </div>
                                <div class="status-card pending">
                                    <h4>Pendientes</h4>
                                    <p class="count">${facturasPendientes}</p>
                                    <%-- SE CORRIGE: Se usa el atributo calculado en el servlet --%>
                                    <p class="amount"><fmt:formatNumber value="${totalPendiente}" type="currency"/></p>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-data">
                            <p>🧾 No hay facturas en tu historial.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="navigation-buttons">
                <%-- SE CORRIGE: Enlace para volver al historial --%>
                <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-secondary">
                    ↩️ Volver al Historial General
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>