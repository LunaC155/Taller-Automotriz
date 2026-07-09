<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Catálogo de Servicios</title>
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
                <h1>🔧 Catálogo de Servicios</h1>
                <p>Explora todos nuestros servicios disponibles</p>
            </div>

            <div class="search-section">
                <form action="${pageContext.request.contextPath}/cliente/servicios" method="get" class="search-form">
                    <input type="hidden" name="action" value="buscar">
                    <div class="search-group">
                        <select name="criterio" class="form-control">
                            <option value="nombre">Nombre</option>
                            <option value="descripcion">Descripción</option>
                        </select>
                        <input type="text" name="valor" placeholder="Buscar servicios..." class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                    </div>
                </form>
            </div>

            <c:if test="${not empty serviciosPopulares}">
                <div class="services-section">
                    <h2 class="section-title">⭐ Servicios Populares</h2>
                    <div class="services-grid">
                        <c:forEach var="servicio" items="${serviciosPopulares}">
                            <div class="service-card featured">
                                <div class="service-header">
                                    <h3>${servicio.nombreServicio}</h3>
                                </div>
                                <div class="service-body">
                                    <p class="service-description">${servicio.descripcion}</p>
                                    <p class="price"><strong><fmt:formatNumber value="${servicio.precioBase}" type="currency"/></strong></p>
                                </div>
                                <div class="service-actions">
                                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=ver&id=${servicio.IDServicio}" class="btn btn-sm btn-info">Ver Detalles</a>
                                    <a href="${pageContext.request.contextPath}/cliente/citas?action=crear&servicioId=${servicio.IDServicio}" class="btn btn-sm btn-primary">Solicitar</a>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty servicios}">
                <div class="services-section">
                    <h2 class="section-title">📋 Todos los Servicios</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Servicio</th>
                                    <th>Descripción</th>
                                    <th>Precio Base</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="servicio" items="${servicios}">
                                    <tr>
                                        <td><strong>${servicio.nombreServicio}</strong></td>
                                        <td>${servicio.descripcion}</td>
                                        <td><strong><fmt:formatNumber value="${servicio.precioBase}" type="currency"/></strong></td>
                                        <td class="actions">
                                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=ver&id=${servicio.IDServicio}" class="btn btn-sm btn-info">Ver</a>
                                            <a href="${pageContext.request.contextPath}/cliente/citas?action=crear&servicioId=${servicio.IDServicio}" class="btn btn-sm btn-primary">Solicitar</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty servicios && empty serviciosPopulares}">
                <div class="no-data">
                    <p>🔧 No hay servicios disponibles en este momento.</p>
                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=misservicios" class="btn btn-primary">Ver Mis Servicios</a>
                </div>
            </c:if>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>