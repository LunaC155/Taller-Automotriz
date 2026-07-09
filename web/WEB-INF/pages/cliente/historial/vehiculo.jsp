<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.Vehiculo, com.upec.model.OrdenServicio" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Historial por Vehículo</title>
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
                <h1>🚗 Historial por Vehículo</h1>
                <p>Consulta el historial de servicios por cada uno de tus vehículos</p>
            </div>

            <div class="vehicle-selector">
                <%-- SE CORRIGE: El action del formulario apunta al servlet --%>
                <form action="${pageContext.request.contextPath}/HistorialServlet" method="get" class="selector-form">
                    <input type="hidden" name="action" value="vehiculo">
                    <div class="form-group">
                        <label for="idVehiculo">Seleccionar Vehículo:</label>
                        <select id="idVehiculo" name="idVehiculo" onchange="this.form.submit()" class="form-control">
                            <option value="">Seleccione un vehículo</option>
                            <c:forEach var="veh" items="${vehiculos}">
                                <option value="${veh.IDVehiculo}" ${vehiculoSeleccionado.IDVehiculo == veh.IDVehiculo ? 'selected' : ''}>
                                    ${veh.placa} - ${veh.IDMarca.nombreMarca} ${veh.IDModelo.nombreModelo}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </form>
            </div>

            <c:choose>
                <c:when test="${not empty vehiculoSeleccionado}">
                    <div class="vehicle-info-card">
                        <h2>${vehiculoSeleccionado.placa}</h2>
                        <p><strong>Marca/Modelo:</strong> ${vehiculoSeleccionado.IDMarca.nombreMarca} / ${vehiculoSeleccionado.IDModelo.nombreModelo}</p>
                    </div>

                    <div class="metrics-grid">
                        <div class="metric-card">
                            <div class="metric-icon">🔧</div>
                            <div class="metric-info">
                                <h3>${totalServiciosVehiculo}</h3>
                                <p>Total Servicios</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">✅</div>
                            <div class="metric-info">
                                <h3>${serviciosCompletadosVehiculo}</h3>
                                <p>Completados</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">💰</div>
                            <div class="metric-info">
                                <%-- SE CORRIGE: Se usa el atributo calculado en el servlet --%>
                                <h3><fmt:formatNumber value="${totalInvertido}" type="currency"/></h3>
                                <p>Total Invertido</p>
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-icon">📅</div>
                            <div class="metric-info">
                                <%-- SE CORRIGE: Se usa el atributo calculado en el servlet --%>
                                <h3>
                                    <c:choose>
                                        <c:when test="${not empty ultimoServicio}">
                                            <fmt:formatDate value="${ultimoServicio}" pattern="dd/MM/yyyy"/>
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </h3>
                                <p>Último Servicio</p>
                            </div>
                        </div>
                    </div>

                    <div class="history-section">
                        <h2 class="section-title">📊 Historial de Servicios</h2>
                        <c:choose>
                            <c:when test="${not empty historialOrdenes}">
                                <div class="table-container">
                                    <table class="data-table">
                                       <thead>
                                            <tr>
                                                <th>Orden #</th>
                                                <th>Problema Reportado</th>
                                                <th>Fecha Entrada</th>
                                                <th>Estado</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="orden" items="${historialOrdenes}">
                                                <tr>
                                                    <td><strong>#${orden.IDOrdenServicio}</strong></td>
                                                    <td>${orden.problemaReportado}</td>
                                                    <td><fmt:formatDate value="${orden.fechaEntrada}" pattern="dd/MM/yyyy"/></td>
                                                    <td>
                                                        <span class="status-badge ${not empty orden.fechaRealSalida ? 'completed' : 'pending'}">
                                                            ${not empty orden.fechaRealSalida ? 'Completado' : 'Pendiente'}
                                                        </span>
                                                    </td>
                                                    <td class="actions">
                                                        <%-- SE CORRIGE: Enlace para ver el detalle --%>
                                                        <a href="${pageContext.request.contextPath}/HistorialServlet?action=ver&id=${orden.IDOrdenServicio}" 
                                                           class="btn btn-sm btn-info" title="Ver detalles">👁️</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="no-data">
                                    <p>📋 Este vehículo no tiene servicios registrados en el historial.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:otherwise>
                     <div class="info-message">
                        <p>👆 Por favor, selecciona un vehículo de la lista para ver su historial.</p>
                    </div>
                </c:otherwise>
            </c:choose>

            <div class="navigation-buttons">
                <%-- SE CORRIGE: Enlace para volver al historial general --%>
                <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-secondary">
                    ↩️ Volver al Historial General
                </a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>