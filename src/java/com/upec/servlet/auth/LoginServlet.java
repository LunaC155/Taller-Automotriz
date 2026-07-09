package com.upec.servlet.auth;

import com.upec.dao.UsuariosDAO;
import com.upec.model.Usuarios;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Inject
    private UsuariosDAO usuariosDAO;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String usuario = request.getParameter("usuario");
        String password = request.getParameter("password");

        if (usuario == null || usuario.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Usuario y contraseña son requeridos");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            Usuarios usuarioAutenticado = usuariosDAO.validarCredenciales(usuario, password);
            
            if (usuarioAutenticado != null) {
                if (!usuarioAutenticado.getEstado()) {
                    request.setAttribute("error", "Tu cuenta está desactivada. Contacta al administrador.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession();
                session.setAttribute("usuario", usuarioAutenticado);
                session.setAttribute("rol", usuarioAutenticado.getIDRol().getNombreRol());
                session.setAttribute("idRol", usuarioAutenticado.getIDRol().getIDRol());
                session.setAttribute("nombreUsuario", usuarioAutenticado.getUsuario());
                session.setAttribute("email", usuarioAutenticado.getEmail());
                session.setAttribute("idUsuario", usuarioAutenticado.getIDUsuario());
                
                session.setMaxInactiveInterval(30 * 60);
                
                // Redirección directa a los servlets específicos por rol
                String redirectUrl = determinarRedireccionPorRol(usuarioAutenticado.getIDRol().getIDRol());
                response.sendRedirect(request.getContextPath() + redirectUrl);
                
            } else {
                request.setAttribute("error", "Usuario o contraseña incorrectos");
                request.setAttribute("usuarioIntentado", usuario);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error en el sistema. Por favor, intenta nuevamente.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private String determinarRedireccionPorRol(Integer idRol) {
        switch (idRol) {
            case 1: // Administrador
                return "/admin/index";
            case 2: // Mecánico
                return "/mecanico/index";
            case 3: // Recepcionista
                return "/recepcionista/index";
            case 4: // Cliente
                return "/cliente/index";
            default:
                return "/login.jsp";
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (request.getParameter("logout") != null) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp?success=Sesión cerrada correctamente");
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Integer idRol = (Integer) session.getAttribute("idRol");
            String redirectUrl = determinarRedireccionPorRol(idRol);
            response.sendRedirect(request.getContextPath() + redirectUrl);
            return;
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}