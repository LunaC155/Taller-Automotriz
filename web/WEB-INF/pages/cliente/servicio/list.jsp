<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lista de Servicios</title>
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
                <h1>🔧 Lista de Servicios</h1>
                <p><c:out value="${tipoVista == 'busqueda' ? 'Resultados de búsqueda' : 'Todos nuestros servicios'}"/></p>
            </div>
            
            <div class="search-section">
                <form action="${pageContext.request.contextPath}/cliente/servicios" method="get" class="search-form">
                    <input type="hidden" name="action" value="buscar">
                    <div class="search-group">
                        <select name="criterio" class="form-control">
                            <option value="nombre" ${criterio == 'nombre' ? 'selected' : ''}>Nombre</option>
                            <option value="descripcion" ${criterio == 'descripcion' ? 'selected' : ''}>Descripción</option>
                        </select>
                        <input type="text" name="valor" value="${valor}" placeholder="Buscar..." class="form-control">
                        <button type="submit" class="btn btn-secondary">🔍 Buscar</button>
                        <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="btn btn-secondary">🔄 Limpiar</a>
                    </div>
                </form>
            </div>
            
            <div class="services-container">
                <c:choose>
                    <c:when test="${not empty servicios}">
                        <div class="services-grid">
                            <c:forEach var="servicio" items="${servicios}">
                                <div class="service-card">
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
                    </c:when>
                    <c:otherwise>
                        <div class="no-data">
                            <p>🔍 No se encontraron servicios que coincidan con tu búsqueda.</p>
                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="btn btn-secondary">Ver Catálogo Completo</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    
    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>