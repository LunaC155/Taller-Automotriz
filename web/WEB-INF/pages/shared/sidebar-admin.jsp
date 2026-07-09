<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String queryString = request.getQueryString();
    String fullURL = currentPage + (queryString != null ? "?" + queryString : "");
%>
<aside class="sidebar admin-theme">
    <div class="sidebar-header">
        <h3>🛠️ Panel Administración</h3>
    </div>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/admin/index" 
               class="<%= currentPage.contains("indexadmin.jsp") || currentPage.contains("AdminIndexServlet") ? "active" : "" %>">
               <span class="icon">🏠</span> Inicio
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/EmpleadoServlet?action=listar"
               class="<%= fullURL.contains("EmpleadoServlet") ? "active" : "" %>">
               <span class="icon">👥</span> Empleados
               <span class="badge badge-info">${empleadosCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/ClienteServlet?action=listar"
               class="<%= fullURL.contains("ClienteServlet") ? "active" : "" %>">
               <span class="icon">👤</span> Clientes
               <span class="badge badge-primary">${clientesCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/VehiculoServlet?action=listar"
               class="<%= fullURL.contains("VehiculoServlet") ? "active" : "" %>">
               <span class="icon">🚗</span> Vehículos
               <span class="badge badge-success">${vehiculosCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/RolesServlet?action=listar"
               class="<%= fullURL.contains("RolesServlet") ? "active" : "" %>">
               <span class="icon">🔐</span> Roles
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/ReporteServlet?action=listar"
               class="<%= fullURL.contains("ReporteServlet") ? "active" : "" %>">
               <span class="icon">📊</span> Reportes
            </a>
        </li>
    </ul>
</aside>