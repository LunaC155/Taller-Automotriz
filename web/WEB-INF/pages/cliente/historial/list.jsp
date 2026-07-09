<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.model.OrdenServicio, com.upec.model.Factura, com.upec.model.Vehiculo" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    // Se mantiene por compatibilidad, pero es mejor usar JSTL/EL
    List<OrdenServicio> historialOrdenes = (List<OrdenServicio>) request.getAttribute("historialOrdenes");
    List<Factura> historialFacturas = (List<Factura>) request.getAttribute("historialFacturas");
    List<Vehiculo> vehiculos = (List<Vehiculo>) request.getAttribute("vehiculos");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Historial de Servicios</title>
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
                <h1>📋 Historial de Servicios</h1>
                <p>Consulta el historial completo de servicios y facturas</p>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon">📋</div>
                    <div class="metric-info">
                        <h3>${totalServicios != null ? totalServicios : 0}</h3>
                        <p>Total Servicios</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">✅</div>
                    <div class="metric-info">
                        <h3>${serviciosCompletados != null ? serviciosCompletados : 0}</h3>
                        <p>Completados</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">⏳</div>
                    <div class="metric-info">
                        <h3>${serviciosPendientes != null ? serviciosPendientes : 0}</h3>
                        <p>Pendientes</p>
                    </div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon">🧾</div>
                    <div class="metric-info">
                        <h3>${not empty historialFacturas ? historialFacturas.size() : 0}</h3>
                        <p>Facturas</p>
                    </div>
                </div>
            </div>

            <div class="filter-section">
                <h3>Filtrar Historial</h3>
                <%-- SE CORRIGE: El action del formulario apunta al servlet con el parámetro correcto --%>
                <form action="${pageContext.request.contextPath}/HistorialServlet?action=filtrar" method="post" class="filter-form">
                    <div class="filter-grid">
                        <div class="form-group">
                            <label for="tipoFiltro">Tipo de Filtro</label>
                            <select id="tipoFiltro" name="tipoFiltro" class="form-control">
                                <option value="">Seleccionar filtro</option>
                                <option value="vehiculo" ${tipoFiltro == 'vehiculo' ? 'selected' : ''}>Por Vehículo</option>
                                <option value="problema" ${tipoFiltro == 'problema' ? 'selected' : ''}>Por Problema</option>
                            </select>
                        </div>
                        
                        <div class="form-group" id="valorFiltroContainer">
                            <label for="valorFiltro">Valor</label>
                            <c:choose>
                                <c:when test="${tipoFiltro == 'vehiculo'}">
                                    <select id="valorFiltro" name="valorFiltro" class="form-control">
                                        <option value="">Seleccionar vehículo</option>
                                        <c:forEach var="vehiculo" items="${vehiculos}">
                                            <option value="${vehiculo.IDVehiculo}" ${vehiculo.IDVehiculo == valorFiltro ? 'selected' : ''}>
                                                ${vehiculo.placa} - ${vehiculo.IDMarca.nombreMarca}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <input type="text" id="valorFiltro" name="valorFiltro" 
                                           value="${valorFiltro}" 
                                           class="form-control" placeholder="Buscar...">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="form-group">
                            <label for="fechaInicio">Fecha Inicio</label>
                            <input type="date" id="fechaInicio" name="fechaInicio" value="${fechaInicio}" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="fechaFin">Fecha Fin</label>
                            <input type="date" id="fechaFin" name="fechaFin" value="${fechaFin}" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="estado">Estado</label>
                            <select id="estado" name="estado" class="form-control">
                                <option value="">Todos los estados</option>
                                <option value="completado" ${estado == 'completado' ? 'selected' : ''}>Completados</option>
                                <option value="pendiente" ${estado == 'pendiente' ? 'selected' : ''}>Pendientes</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">🔍 Aplicar Filtros</button>
                        <%-- SE CORRIGE: El enlace para limpiar filtros apunta a la acción por defecto --%>
                        <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-secondary">🔄 Limpiar Filtros</a>
                    </div>
                </form>
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
                                        <th>Vehículo</th>
                                        <th>Problema Reportado</th>
                                        <th>Fecha Entrada</th>
                                        <th>Fecha Salida</th>
                                        <th>Estado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="orden" items="${historialOrdenes}">
                                        <tr>
                                            <td><strong>#${orden.IDOrdenServicio}</strong></td>
                                            <td>${orden.IDVehiculo.placa}</td>
                                            <td>
                                                <c:set var="problema" value="${orden.problemaReportado}" />
                                                ${problema.length() > 50 ? problema.substring(0, 50).concat('...') : problema}
                                            </td>
                                            <td><fmt:formatDate value="${orden.fechaEntrada}" pattern="dd/MM/yyyy"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty orden.fechaRealSalida}">
                                                        <fmt:formatDate value="${orden.fechaRealSalida}" pattern="dd/MM/yyyy"/>
                                                    </c:when>
                                                    <c:otherwise>Pendiente</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="status-badge ${not empty orden.fechaRealSalida ? 'completed' : 'pending'}">
                                                    ${not empty orden.fechaRealSalida ? 'Completado' : 'Pendiente'}
                                                </span>
                                            </td>
                                            <td class="actions">
                                                <%-- SE CORRIGEN: Rutas de los botones de acción --%>
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
                            <p>📋 No hay servicios que coincidan con tu búsqueda.</p>
                            <c:if test="${tipoVista == 'filtrado'}">
                                <a href="${pageContext.request.contextPath}/HistorialServlet" class="btn btn-primary">Ver Historial Completo</a>
                            </c:if>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="navigation-buttons">
                <%-- SE CORRIGEN: Rutas de los botones de navegación --%>
                <a href="${pageContext.request.contextPath}/HistorialServlet?action=estadisticas" class="btn btn-info">📈 Ver Estadísticas</a>
                <a href="${pageContext.request.contextPath}/HistorialServlet?action=facturas" class="btn btn-warning">🧾 Ver Facturas</a>
                <a href="${pageContext.request.contextPath}/HistorialServlet?action=vehiculo" class="btn btn-secondary">🚗 Historial por Vehículo</a>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>