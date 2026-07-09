package com.upec.servlet.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/acceso-denegado")
public class AccesoDenegadoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Agregar algún mensaje o lógica adicional si es necesario
        String mensaje = request.getParameter("mensaje");
        if (mensaje != null) {
            request.setAttribute("mensajeError", mensaje);
        } else {
            request.setAttribute("mensajeError", "No tiene permisos para acceder a esta página.");
        }
        
        // CORRECCIÓN: La ruta correcta según tu estructura de proyecto
        request.getRequestDispatcher("/acceso-denegado.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}