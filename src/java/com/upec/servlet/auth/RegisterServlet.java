package com.upec.servlet.auth;

import com.upec.dao.UsuariosDAO;
import com.upec.dao.ClienteDAO;
import com.upec.model.Usuarios;
import com.upec.model.Roles;
import com.upec.model.Cliente;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Inject
    private UsuariosDAO usuariosDAO;
    
    @Inject
    private ClienteDAO clienteDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String usuario = request.getParameter("usuario");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        try {
            if (usuario == null || usuario.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                nombre == null || nombre.trim().isEmpty() ||
                apellido == null || apellido.trim().isEmpty()) {
                
                request.setAttribute("error", "Todos los campos obligatorios deben ser completados");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Las contraseñas no coinciden");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (password.length() < 6) {
                request.setAttribute("error", "La contraseña debe tener al menos 6 caracteres");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (usuariosDAO.verificarUsuarioExistente(usuario)) {
                request.setAttribute("error", "El nombre de usuario ya existe");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (usuariosDAO.emailExists(email)) {
                request.setAttribute("error", "El correo electrónico ya está registrado");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            if (clienteDAO.existeClienteConEmail(email)) {
                request.setAttribute("error", "El correo electrónico ya está registrado");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            Roles rolCliente = usuariosDAO.findRolById(4);
            if (rolCliente == null) {
                request.setAttribute("error", "Error en la configuración del sistema");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            Cliente cliente = new Cliente();
            cliente.setNombre(nombre);
            cliente.setApellido(apellido);
            cliente.setTelefono(telefono);
            cliente.setEmail(email);
            cliente.setDireccion(direccion);
            cliente.setFechaRegistro(new Date());

            clienteDAO.crearCliente(cliente);

            Usuarios nuevoUsuario = new Usuarios();
            nuevoUsuario.setUsuario(usuario);
            nuevoUsuario.setContrasena(password);
            nuevoUsuario.setEmail(email);
            nuevoUsuario.setEstado(true);
            nuevoUsuario.setFechaCreacion(new Date());
            nuevoUsuario.setIDRol(rolCliente);

            usuariosDAO.crearUsuario(nuevoUsuario);

            request.getSession().setAttribute("success", 
                "¡Registro exitoso! Ahora puedes iniciar sesión con tus credenciales.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");

        } catch (Exception e) {
            request.setAttribute("error", "Error en el proceso de registro: " + e.getMessage());
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}