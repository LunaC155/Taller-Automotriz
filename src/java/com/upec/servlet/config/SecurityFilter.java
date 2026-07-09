package com.upec.servlet.config;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class SecurityFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        String requestedUri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // URLs públicas que no requieren autenticación
        if (requestedUri.equals(contextPath + "/") ||
            requestedUri.equals(contextPath + "/login.jsp") ||
            requestedUri.equals(contextPath + "/login") ||
            requestedUri.equals(contextPath + "/register.jsp") ||
            requestedUri.equals(contextPath + "/register") ||
            requestedUri.equals(contextPath + "/acceso-denegado.jsp") ||
            requestedUri.startsWith(contextPath + "/resources/") ||
            requestedUri.startsWith(contextPath + "/js/") ||
            requestedUri.startsWith(contextPath + "/services/")) {
            
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);

        // Verificar si el usuario está autenticado
        if (session == null || session.getAttribute("usuario") == null) {
            httpResponse.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // Verificar acceso según rol para páginas protegidas
        Integer idRol = (Integer) session.getAttribute("idRol");

        if (!tieneAcceso(idRol, requestedUri, contextPath)) {
            httpResponse.sendRedirect(contextPath + "/acceso-denegado.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean tieneAcceso(Integer idRol, String requestedUri, String contextPath) {
        if (idRol == null) return false;

        // Permitir acceso a páginas de índice según rol
        if (requestedUri.equals(contextPath + "/indexadmin.jsp") && idRol == 1) return true;
        if (requestedUri.equals(contextPath + "/indexmecanico.jsp") && idRol == 2) return true;
        if (requestedUri.equals(contextPath + "/indexrecepcionista.jsp") && idRol == 3) return true;
        if (requestedUri.equals(contextPath + "/indexcliente.jsp") && idRol == 4) return true;

        // Permitir acceso a servlets según rol
        if (requestedUri.contains("/servlet/")) {
            switch (idRol) {
                case 1: // Administrador - acceso completo
                    return true;
                case 2: // Mecánico
                    return requestedUri.contains("/mecanico/") || 
                           requestedUri.contains("/diagnostico/") ||
                           requestedUri.contains("/orden/") ||
                           requestedUri.contains("/tarea/") ||
                           requestedUri.contains("/reportetecnico/");
                case 3: // Recepcionista
                    return requestedUri.contains("/recepcionista/") || 
                           requestedUri.contains("/cliente/") ||
                           requestedUri.contains("/vehiculo/") ||
                           requestedUri.contains("/orden/") ||
                           requestedUri.contains("/factura/") ||
                           requestedUri.contains("/cita/");
                case 4: // Cliente
                    return requestedUri.contains("/cliente/") || 
                           requestedUri.contains("/vehiculocliente/") ||
                           requestedUri.contains("/historial/") ||
                           requestedUri.contains("/facturaclientes/") ||
                           requestedUri.contains("/cita/");
                default:
                    return false;
            }
        }

        // Para URLs de WEB-INF, aplicar la lógica según estructura de carpetas
        if (requestedUri.contains("/WEB-INF/pages/")) {
            switch (idRol) {
                case 1: // Administrador - acceso completo
                    return true;
                case 2: // Mecánico
                    return requestedUri.contains("/mecanico/");
                case 3: // Recepcionista
                    return requestedUri.contains("/recepcionista/");
                case 4: // Cliente
                    return requestedUri.contains("/cliente/");
                default:
                    return false;
            }
        }

        return true;
    }

    @Override
    public void destroy() {
    }
}