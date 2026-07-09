<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String queryString = request.getQueryString();
    String fullURL = currentPage + (queryString != null ? "?" + queryString : "");
%>
<aside class="sidebar cliente-theme">
    <div class="sidebar-header">
        <h3>👤 Mi Cuenta</h3>
    </div>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/cliente/index" 
               class="<%= currentPage.contains("indexcliente.jsp") || currentPage.contains("ClienteIndexServlet") ? "active" : ""%>">
               <span class="icon">🏠</span> Inicio
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos"
               class="<%= fullURL.contains("VehiculoClienteServlet") ? "active" : ""%>">
               <span class="icon">🚗</span> Mis Vehículos
               <span class="badge badge-primary">${vehiculosCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/ServicioServlet?action=misservicios"
               class="<%= fullURL.contains("ServicioServlet") && fullURL.contains("action=misservicios") ? "active" : ""%>">
               <span class="icon">🔧</span> Servicios Activos
               <span class="badge badge-warning">${serviciosActivosCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/HistorialServlet?action=ver"
               class="<%= fullURL.contains("HistorialServlet") ? "active" : ""%>">
               <span class="icon">📋</span> Historial
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/FacturaClientesServlet?action=misfacturas"
               class="<%= fullURL.contains("FacturaClientesServlet") ? "active" : ""%>">
               <span class="icon">🧾</span> Mis Facturas
               <span class="badge badge-info">${facturasCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/CitaServlet?action=nueva"
               class="<%= fullURL.contains("CitaServlet") && fullURL.contains("action=nueva") ? "active" : ""%>">
               <span class="icon">📅</span> Agendar Cita
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/ContactoServlet?action=formulario"
               class="<%= fullURL.contains("ContactoServlet") ? "active" : ""%>">
               <span class="icon">📞</span> Soporte
            </a>
        </li>
    </ul>
</aside>