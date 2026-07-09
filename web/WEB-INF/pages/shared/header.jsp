<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Usuarios" %>
<%
    Usuarios usuarioHeader = (Usuarios) session.getAttribute("usuario");
    Integer idRolHeader = (Integer) session.getAttribute("idRol");
    String nombreRol = "";
    String temaClase = "";
    
    if (idRolHeader != null) {
        switch (idRolHeader) {
            case 1: 
                nombreRol = "Administrador"; 
                temaClase = "admin-theme";
                break;
            case 2: 
                nombreRol = "Mecánico"; 
                temaClase = "mecanico-theme";
                break;
            case 3: 
                nombreRol = "Recepcionista"; 
                temaClase = "recepcion-theme";
                break;
            case 4: 
                nombreRol = "Cliente"; 
                temaClase = "cliente-theme";
                break;
        }
    }
%>
<header class="main-header <%= temaClase %>">
    <div class="header-container">
        <div class="logo-section">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <span class="logo-icon">🚗</span>
                <h1>Taller Automotriz Rápido</h1>
            </a>
        </div>
        
        <div class="user-section">
            <% if (usuarioHeader != null) { %>
                <div class="user-info hide-mobile">
                    <span class="user-welcome">Bienvenido, <strong><%= usuarioHeader.getUsuario() %></strong></span>
                    <span class="user-role"><%= nombreRol %></span>
                </div>
                <div class="header-actions">
                    <a href="${pageContext.request.contextPath}/logout " class="logout-btn">
                        <span class="logout-icon">🚪</span>
                        <span class="hide-mobile">Cerrar Sesión</span>
                    </a>
                </div>
            <% } else { %>
                <div class="auth-buttons">
                    <a href="${pageContext.request.contextPath}/login.jsp" class="btn-login">
                        <span class="hide-mobile">Iniciar Sesión</span>
                        <span class="show-mobile">🚪</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="btn-register">
                        <span class="hide-mobile">Registrarse</span>
                        <span class="show-mobile">👤</span>
                    </a>
                </div>
            <% } %>
        </div>
    </div>
    
    <!-- Mobile Menu Toggle -->
    <div class="mobile-menu-toggle show-mobile" id="mobileMenuToggle">
        <span></span>
        <span></span>
        <span></span>
    </div>
</header>