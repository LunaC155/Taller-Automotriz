<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Factura" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Historial</title>
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
                <h1>📋 Detalle del Servicio</h1>
                <p>Información completa de la orden de servicio</p>
            </div>

            <c:choose>
                <c:when test="${not empty orden}">
                    <div class="detail-section">
                        <div class="detail-card">
                            <div class="detail-header">
                                <h2>Orden #${orden.IDOrdenServicio}</h2>
                                <span class="status-badge ${not empty orden.fechaRealSalida ? 'completed' : 'pending'}">
                                    ${not empty orden.fechaRealSalida ? 'Completado' : 'Pendiente'}
                                </span>
                            </div>
                            
                            <div class="detail-grid">
                                <div class="detail-group">
                                    <h3>Información del Vehículo</h3>
                                    <p><strong>Placa:</strong> ${orden.IDVehiculo.placa}</p>
                                    <p><strong>Marca/Modelo:</strong> ${orden.IDVehiculo.IDMarca.nombreMarca} ${orden.IDVehiculo.IDModelo.nombreModelo}</p>
                                    <p><strong>Kilometraje:</strong> ${orden.IDVehiculo.kilometraje} km</p>
                                </div>
                                
                                <div class="detail-group">
                                    <h3>Información del Servicio</h3>
                                    <p><strong>Problema Reportado:</strong> ${orden.problemaReportado}</p>
                                    <p><strong>Estado:</strong> ${orden.IDEstadoTrabajo.nombreEstado}</p>
                                </div>
                                
                                <div class="detail-group">
                                    <h3>Fechas</h3>
                                    <p><strong>Entrada:</strong> <fmt:formatDate value="${orden.fechaEntrada}" pattern="dd/MM/yyyy HH:mm"/></p>
                                    <p><strong>Salida Estimada:</strong> <fmt:formatDate value="${orden.fechaEstimadaSalida}" pattern="dd/MM/yyyy"/></p>
                                    <p><strong>Salida Real:</strong> 
                                        <c:if test="${not empty orden.fechaRealSalida}">
                                            <fmt:formatDate value="${orden.fechaRealSalida}" pattern="dd/MM/yyyy HH:mm"/>
                                        </c:if>
                                        <c:if test="${empty orden.fechaRealSalida}">Pendiente</c:if>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <c:if test="${not empty factura}">
                            <div class="detail-card">
                                <div class="detail-header">
                                    <h2>Factura #${factura.numeroFactura}</h2>
                                    <span class="status-badge ${factura.IDEstadoFactura.nombreEstado == 'PAGADA' ? 'completed' : 'pending'}">
                                        ${factura.IDEstadoFactura.nombreEstado}
                                    </span>
                                </div>
                                <div class="detail-grid">
                                    <p><strong>Fecha Emisión:</strong> <fmt:formatDate value="${factura.fechaEmision}" pattern="dd/MM/yyyy"/></p>
                                    <p><strong>Subtotal:</strong> <fmt:formatNumber value="${factura.subtotal}" type="currency"/></p>
                                    <p><strong>IVA:</strong> <fmt:formatNumber value="${factura.iva}" type="currency"/></p>
                                    <p><strong>Total:</strong> <strong><fmt:formatNumber value="${factura.total}" type="currency"/></strong></p>
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <div class="action-buttons">
                        <%-- SE CORRIGE: El enlace para volver apunta al servlet --%>
                        <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-secondary">
                            ↩️ Volver al Historial
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="error-message">
                        <p>❌ No se encontró la orden de servicio solicitada.</p>
                        <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-secondary">Volver al Historial</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>