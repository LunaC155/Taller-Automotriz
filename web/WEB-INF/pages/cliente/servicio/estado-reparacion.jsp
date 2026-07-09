<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Estado de Reparación</title>
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
                <h1>📊 Estado de Reparación</h1>
                <p>Sigue el progreso de tus servicios en tiempo real</p>
            </div>

            <c:choose>
                <c:when test="${tipoVista == 'detalle-orden' && not empty orden}">
                    <div class="repair-detail">
                        <div class="repair-header">
                            <h2>Orden #${orden.IDOrdenServicio}</h2>
                            <span class="status-badge ${not empty orden.fechaRealSalida ? 'completed' : 'pending'}">
                                ${not empty orden.fechaRealSalida ? 'Completado' : 'En Proceso'}
                            </span>
                        </div>
                        
                        <div class="repair-details">
                            <div class="detail-card">
                                <h3>Información del Vehículo</h3>
                                <p><strong>Placa:</strong> ${orden.IDVehiculo.placa}</p>
                                <c:if test="${orden.IDVehiculo.IDMarca != null}">
                                    <p><strong>Marca:</strong> ${orden.IDVehiculo.IDMarca.nombreMarca}</p>
                                </c:if>
                                <c:if test="${orden.IDVehiculo.IDModelo != null}">
                                    <p><strong>Modelo:</strong> ${orden.IDVehiculo.IDModelo.nombreModelo}</p>
                                </c:if>
                                <p><strong>Problema Reportado:</strong> ${orden.problemaReportado}</p>
                            </div>
                            
                            <div class="detail-card">
                                <h3>Fechas</h3>
                                <p><strong>Fecha Entrada:</strong> <fmt:formatDate value="${orden.fechaEntrada}" pattern="dd/MM/yyyy HH:mm"/></p>
                                <p><strong>Fecha Estimada Salida:</strong> <fmt:formatDate value="${orden.fechaEstimadaSalida}" pattern="dd/MM/yyyy"/></p>
                                <c:if test="${not empty orden.fechaRealSalida}">
                                    <p><strong>Fecha Real Salida:</strong> <fmt:formatDate value="${orden.fechaRealSalida}" pattern="dd/MM/yyyy HH:mm"/></p>
                                </c:if>
                            </div>
                            
                            <div class="detail-card">
                                <h3>Estado Actual</h3>
                                <c:if test="${orden.IDEstadoTrabajo != null}">
                                    <p><strong>Estado:</strong> <span class="status-badge">${orden.IDEstadoTrabajo.nombreEstado}</span></p>
                                </c:if>
                                <c:if test="${orden.IDEmpleadoRecepcion != null}">
                                    <p><strong>Recepcionista:</strong> ${orden.IDEmpleadoRecepcion.nombre} ${orden.IDEmpleadoRecepcion.apellido}</p>
                                </c:if>
                                <p><strong>Mecánico:</strong> ${not empty orden.IDEmpleadoMecanico ? orden.IDEmpleadoMecanico.nombre : 'Pendiente de asignación'}</p>
                            </div>
                            
                            <c:if test="${not empty servicios}">
                                <div class="detail-card">
                                    <h3>Servicios Relacionados</h3>
                                    <div class="services-mini-list">
                                        <c:forEach var="servicio" items="${servicios}">
                                            <div class="service-mini-item">
                                                <span>${servicio.nombreServicio}</span>
                                                <span class="price"><fmt:formatNumber value="${servicio.precioBase}" type="currency"/></span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                        
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=misservicios" class="btn btn-secondary">↩️ Volver a Mis Servicios</a>
                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=estado-reparacion" class="btn btn-info">📊 Ver Todas las Órdenes</a>
                        </div>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <c:if test="${tipoVista == 'estado-general'}">
                        <div class="metrics-grid">
                            <div class="metric-card">
                                <div class="metric-icon">📋</div>
                                <div class="metric-info">
                                    <h3>${totalOrdenes}</h3>
                                    <p>Total Órdenes</p>
                                </div>
                            </div>
                            <div class="metric-card">
                                <div class="metric-icon">⏳</div>
                                <div class="metric-info">
                                    <h3>${ordenesPendientes}</h3>
                                    <p>Pendientes</p>
                                </div>
                            </div>
                            <div class="metric-card">
                                <div class="metric-icon">✅</div>
                                <div class="metric-info">
                                    <h3>${ordenesCompletadas}</h3>
                                    <p>Completadas</p>
                                </div>
                            </div>
                            <c:if test="${ordenesAtrasadas > 0}">
                                <div class="metric-card warning">
                                    <div class="metric-icon">⚠️</div>
                                    <div class="metric-info">
                                        <h3>${ordenesAtrasadas}</h3>
                                        <p>Atrasadas</p>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </c:if>
                    
                    <div class="repair-overview">
                        <c:if test="${not empty ordenes}">
                            <div class="orders-list">
                                <h2 class="section-title">📋 Órdenes de Servicio</h2>
                                <c:forEach var="ord" items="${ordenes}">
                                    <div class="order-card ${not empty ord.fechaRealSalida ? 'completed' : 'active'}">
                                        <div class="order-header">
                                            <h3>Orden #${ord.IDOrdenServicio} - ${ord.IDVehiculo.placa}</h3>
                                            <span class="status-badge ${not empty ord.fechaRealSalida ? 'completed' : 'pending'}">
                                                ${not empty ord.fechaRealSalida ? 'Completado' : 'En Proceso'}
                                            </span>
                                        </div>
                                        <div class="order-body">
                                            <p><strong>Problema:</strong> ${ord.problemaReportado}</p>
                                            <p><strong>Fecha Entrada:</strong> <fmt:formatDate value="${ord.fechaEntrada}" pattern="dd/MM/yyyy"/></p>
                                            <c:if test="${ord.IDEstadoTrabajo != null}">
                                                <p><strong>Estado:</strong> ${ord.IDEstadoTrabajo.nombreEstado}</p>
                                            </c:if>
                                            <c:choose>
                                                <c:when test="${not empty ord.fechaRealSalida}">
                                                    <p><strong>Fecha Salida:</strong> <fmt:formatDate value="${ord.fechaRealSalida}" pattern="dd/MM/yyyy"/></p>
                                                </c:when>
                                                <c:otherwise>
                                                    <p><strong>Fecha Estimada:</strong> <fmt:formatDate value="${ord.fechaEstimadaSalida}" pattern="dd/MM/yyyy"/></p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="order-actions">
                                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=estado-reparacion&id=${ord.IDOrdenServicio}" class="btn btn-sm btn-info">Ver Detalles</a>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                        
                        <c:if test="${empty ordenes}">
                            <div class="no-data">
                                <p>📋 No tienes órdenes de servicio activas.</p>
                                <a href="${pageContext.request.contextPath}/cliente/citas?action=crear" class="btn btn-primary">📅 Agendar Primer Servicio</a>
                                <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="btn btn-secondary">🔍 Ver Catálogo</a>
                            </div>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>