<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Servicio</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
</head>
<body class="cliente">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-cliente.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>
    
    <div class="main-content-with-sidebar">
        <div class="container">
            <c:choose>
                <c:when test="${not empty servicio}">
                    <div class="service-detail">
                        <div class="service-header">
                            <h1>${servicio.nombreServicio}</h1>
                            <div class="service-price">
                                <span class="price-tag"><fmt:formatNumber value="${servicio.precioBase}" type="currency"/></span>
                            </div>
                        </div>
                        
                        <div class="service-content">
                            <div class="service-main">
                                <div class="service-description">
                                    <h3>Descripción del Servicio</h3>
                                    <p>${servicio.descripcion}</p>
                                </div>
                                
                                <c:if test="${servicio.duracionEstimada != null}">
                                    <div class="service-info">
                                        <h3>Información Adicional</h3>
                                        <p><strong>⏱️ Duración estimada:</strong> ${servicio.duracionEstimada} minutos</p>
                                    </div>
                                </c:if>
                                
                                <c:if test="${not empty serviciosRelacionados}">
                                    <div class="related-services">
                                        <h3>Servicios Relacionados</h3>
                                        <div class="services-grid">
                                            <c:forEach var="relacionado" items="${serviciosRelacionados}">
                                                <div class="service-card mini">
                                                    <h4>${relacionado.nombreServicio}</h4>
                                                    <p class="price"><fmt:formatNumber value="${relacionado.precioBase}" type="currency"/></p>
                                                    <a href="${pageContext.request.contextPath}/cliente/servicios?action=ver&id=${relacionado.IDServicio}" class="btn btn-sm btn-info">Ver</a>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                            
                            <div class="service-sidebar">
                                <div class="booking-card">
                                    <h3>Solicitar este Servicio</h3>
                                    <div class="booking-info">
                                        <p>💰 <strong>Precio base:</strong> <fmt:formatNumber value="${servicio.precioBase}" type="currency"/></p>
                                        <c:if test="${servicio.duracionEstimada != null}">
                                            <p>⏱️ <strong>Duración:</strong> ${servicio.duracionEstimada} min</p>
                                        </c:if>
                                    </div>
                                    <div class="booking-actions">
                                        <a href="${pageContext.request.contextPath}/cliente/citas?action=crear&servicioId=${servicio.IDServicio}" class="btn btn-primary btn-block">
                                            📅 Agendar Cita
                                        </a>
                                        <a href="${pageContext.request.contextPath}/cliente/servicios?action=misservicios" class="btn btn-secondary btn-block">
                                            📋 Mis Servicios
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="btn btn-secondary">
                                ↩️ Volver al Catálogo
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="error-message">
                        <p>❌ No se encontró el servicio solicitado.</p>
                        <a href="${pageContext.request.contextPath}/cliente/servicios?action=catalogo" class="btn btn-secondary">Volver al Catálogo</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>