<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getRequestURI();
    String queryString = request.getQueryString();
    String fullURL = currentPage + (queryString != null ? "?" + queryString : "");
%>
<aside class="sidebar mecanico-theme">
    <div class="sidebar-header">
        <h3>🔧 Panel Mecánico</h3>
    </div>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/mecanico/index" 
               class="<%= currentPage.contains("indexmecanico.jsp") || currentPage.contains("MecanicoIndexServlet") ? "active" : "" %>">
               <span class="icon">🏠</span> Inicio
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/DiagnosticoServlet?action=listar"
               class="<%= fullURL.contains("DiagnosticoServlet") ? "active" : "" %>">
               <span class="icon">🔍</span> Diagnósticos
               <span class="badge badge-warning">${diagnosticosCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/OrdenServlet?action=listar"
               class="<%= fullURL.contains("OrdenServlet") && fullURL.contains("action=listar") ? "active" : "" %>">
               <span class="icon">🔧</span> Órdenes de Trabajo
               <span class="badge badge-primary">${ordenesCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/TareaServlet?action=listar"
               class="<%= fullURL.contains("TareaServlet") ? "active" : "" %>">
               <span class="icon">📋</span> Mis Tareas
               <span class="badge badge-success">${tareasCount}</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/HorasServlet?action=registrar"
               class="<%= fullURL.contains("HorasServlet") ? "active" : "" %>">
               <span class="icon">⏱️</span> Registro de Horas
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/InventarioServlet?action=consultar"
               class="<%= fullURL.contains("InventarioServlet") ? "active" : "" %>">
               <span class="icon">📦</span> Inventario
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/servlet/mecanico/reportetecnico"
               class="<%= fullURL.contains("ReporteTecnicoServlet") ? "active" : "" %>">
               <span class="icon">📝</span> Reportes Técnicos
            </a>
        </li>
    </ul>
</aside>