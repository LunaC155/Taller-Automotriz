<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String queryString = request.getQueryString();
    String fullURL = currentPage + (queryString != null ? "?" + queryString : "");
%>
<aside class="sidebar recepcion-theme">
    <div class="sidebar-header">
        <h3>📋 Panel Recepción</h3>
    </div>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/recepcionista/index" 
               class="<%= currentPage.contains("indexrecepcionista.jsp") || currentPage.contains("RecepcionistaIndexServlet") ? "active" : "" %>">
               <span class="icon">🏠</span> Inicio
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/RecepcionServlet?action=nuevo"
               class="<%= fullURL.contains("RecepcionServlet") && fullURL.contains("action=nuevo") ? "active" : "" %>">
               <span class="icon">🚗</span> Nueva Recepción
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/CitaServlet?action=listar"
               class="<%= fullURL.contains("CitaServlet") && fullURL.contains("action=listar") ? "active" : "" %>">
               <span class="icon">📅</span> Gestión de Citas
               <span class="badge badge-warning">${citasPendientesCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/ClienteServlet?action=listar"
               class="<%= fullURL.contains("ClienteServlet") && fullURL.contains("action=listar") ? "active" : "" %>">
               <span class="icon">👤</span> Gestión de Clientes
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/OrdenServlet?action=nueva"
               class="<%= fullURL.contains("OrdenServlet") && fullURL.contains("action=nueva") ? "active" : "" %>">
               <span class="icon">📋</span> Órdenes de Servicio
               <span class="badge badge-primary">${ordenesCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/FacturaServlet?action=listar"
               class="<%= fullURL.contains("FacturaServlet") && fullURL.contains("action=listar") ? "active" : "" %>">
               <span class="icon">💰</span> Facturación
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/AtencionServlet?action=listar"
               class="<%= fullURL.contains("AtencionServlet") && fullURL.contains("action=listar") ? "active" : "" %>">
               <span class="icon">📞</span> Atención al Cliente
               <span class="badge badge-info">${solicitudesCount}</span>
            </a>
        </li>
    </ul>
</aside>