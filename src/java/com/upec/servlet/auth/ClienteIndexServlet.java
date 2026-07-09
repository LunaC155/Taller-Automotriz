package com.upec.servlet.auth;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
@WebServlet(name = "ClienteIndexServlet", urlPatterns = {"/cliente/index", "/cliente/dashboard"})
public class ClienteIndexServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // Verificar si el usuario está autenticado
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        // Verificar rol de cliente
        Integer idRol = (Integer) session.getAttribute("idRol");
        if (idRol == null || idRol != 4) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }
        // Forward directo al indexcliente.jsp
        request.getRequestDispatcher("/WEB-INF/pages/cliente/indexcliente.jsp").forward(request, response);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}