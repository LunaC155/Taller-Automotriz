package com.upec.servlet.usuarios;

import com.upec.dao.ClienteDAO;
import com.upec.model.Cliente;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "ClienteServlet", urlPatterns = {
    "/ClienteServlet",
    "/admin/clientes",
    "/admin/clientes/crear",
    "/admin/clientes/editar",
    "/admin/clientes/ver",
    "/admin/clientes/eliminar",
    "/admin/clientes/buscar",
    "/admin/clientes/reportes",
    "/recepcionista/clientes",
    "/recepcionista/clientes/crear",
    "/recepcionista/clientes/editar",
    "/recepcionista/clientes/ver",
    "/recepcionista/clientes/buscar"
})
public class ClienteServlet extends HttpServlet {

    @EJB
    private ClienteDAO clienteDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("rol");
        String path = request.getServletPath();
        String action = getActionFromPath(path, request);

        try {
            switch (action) {
                case "listar":
                    handleListarClientes(request, response, userRole, path);
                    break;
                case "crear":
                case "formulario":
                    handleFormularioCliente(request, response, userRole, path);
                    break;
                case "editar":
                    handleFormularioCliente(request, response, userRole, path);
                    break;
                case "ver":
                    handleVerCliente(request, response, userRole, path);
                    break;
                case "eliminar":
                    if ("administrador".equals(userRole)) {
                        handleEliminarCliente(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                case "buscar":
                    handleBuscarClientes(request, response, userRole, path);
                    break;
                case "reportes":
                    if ("administrador".equals(userRole)) {
                        handleReportesClientes(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("rol");
        String path = request.getServletPath();
        String action = getActionFromPath(path, request);

        try {
            switch (action) {
                case "crear":
                case "formulario":
                    handleCrearCliente(request, response, userRole);
                    break;
                case "editar":
                    handleEditarCliente(request, response, userRole);
                    break;
                case "eliminar":
                    if ("administrador".equals(userRole)) {
                        handleEliminarCliente(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET
    private void handleListarClientes(HttpServletRequest request, HttpServletResponse response,
            String userRole, String path) throws ServletException, IOException {

        List<Cliente> clientes = clienteDAO.listarClientes();
        request.setAttribute("clientes", clientes);

        String jspPage = determineJspPage(userRole, path, "list");
        
        // DEBUG: Descomentar para ver qué ruta está usando
        System.out.println("=== DEBUG LISTAR ===");
        System.out.println("UserRole: " + userRole);
        System.out.println("Path: " + path);
        System.out.println("JSP Page: " + jspPage);
        System.out.println("===================");
        
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleFormularioCliente(HttpServletRequest request, HttpServletResponse response,
            String userRole, String path) throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            idParam = request.getParameter("idCliente");
        }

        if (idParam != null && !idParam.isEmpty()) {
            int id = Integer.parseInt(idParam);
            Cliente cliente = clienteDAO.obtenerClientePorId(id);
            if (cliente != null) {
                request.setAttribute("cliente", cliente);
            }
        }

        String jspPage = determineJspPage(userRole, path, "form");
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleVerCliente(HttpServletRequest request, HttpServletResponse response,
            String userRole, String path) throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cliente no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Cliente cliente;

        if ("recepcionista".equals(userRole)) {
            cliente = clienteDAO.obtenerClienteConVehiculos(id);
        } else {
            cliente = clienteDAO.obtenerClientePorId(id);
        }

        if (cliente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cliente no encontrado");
            return;
        }

        request.setAttribute("cliente", cliente);
        String jspPage = determineJspPage(userRole, path, "view");
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleBuscarClientes(HttpServletRequest request, HttpServletResponse response,
            String userRole, String path) throws ServletException, IOException {

        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");

        List<Cliente> clientes;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            switch (criterio) {
                case "nombre":
                    clientes = clienteDAO.buscarClientesPorNombre(valor);
                    break;
                case "email":
                    clientes = clienteDAO.buscarClientesPorEmail(valor);
                    break;
                case "telefono":
                    clientes = clienteDAO.buscarClientesPorTelefono(valor);
                    break;
                default:
                    clientes = clienteDAO.listarClientes();
            }
        } else {
            clientes = clienteDAO.listarClientes();
        }

        request.setAttribute("clientes", clientes);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);

        String jspPage = determineJspPage(userRole, path, "list");
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleReportesClientes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int totalClientes = clienteDAO.contarTotalClientes();
        int clientesNuevosMes = clienteDAO.contarClientesNuevosEsteMes();
        List<Object[]> estadisticas = clienteDAO.obtenerEstadisticasClientes();

        request.setAttribute("totalClientes", totalClientes);
        request.setAttribute("clientesNuevosMes", clientesNuevosMes);
        request.setAttribute("estadisticas", estadisticas);

        request.getRequestDispatcher("/WEB-INF/pages/admin/clientes/reportes.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST
    private void handleCrearCliente(HttpServletRequest request, HttpServletResponse response, String userRole)
            throws ServletException, IOException {

        Cliente cliente = extractClienteFromRequest(request);
        cliente.setFechaRegistro(new Date());

        if (clienteDAO.crearCliente(cliente)) {
            request.getSession().setAttribute("mensaje", "Cliente creado exitosamente");

            if ("administrador".equals(userRole)) {
                response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=listar");
            } else if ("recepcionista".equals(userRole)) {
                response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=listar");
            } else {
                response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=listar");
            }
        } else {
            request.setAttribute("error", "Error al crear el cliente");
            request.setAttribute("cliente", cliente);

            String jspPage = determineJspPage(userRole, request.getServletPath(), "form");
            request.getRequestDispatcher(jspPage).forward(request, response);
        }
    }

    private void handleEditarCliente(HttpServletRequest request, HttpServletResponse response, String userRole)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            idParam = request.getParameter("idCliente");
        }

        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cliente no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Cliente clienteExistente = clienteDAO.obtenerClientePorId(id);

        if (clienteExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cliente no encontrado");
            return;
        }

        Cliente clienteActualizado = extractClienteFromRequest(request);
        clienteExistente.setNombre(clienteActualizado.getNombre());
        clienteExistente.setApellido(clienteActualizado.getApellido());
        clienteExistente.setTelefono(clienteActualizado.getTelefono());
        clienteExistente.setDireccion(clienteActualizado.getDireccion());

        if ("administrador".equals(userRole)) {
            clienteExistente.setEmail(clienteActualizado.getEmail());
        }

        if (clienteDAO.actualizarCliente(clienteExistente)) {
            request.getSession().setAttribute("mensaje", "Cliente actualizado exitosamente");
            response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=listar");
        } else {
            request.setAttribute("error", "Error al actualizar el cliente");
            request.setAttribute("cliente", clienteExistente);

            String jspPage = determineJspPage(userRole, request.getServletPath(), "form");
            request.getRequestDispatcher(jspPage).forward(request, response);
        }
    }

    private void handleEliminarCliente(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cliente no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);

        if (clienteDAO.eliminarCliente(id)) {
            request.getSession().setAttribute("mensaje", "Cliente eliminado exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al eliminar el cliente. Verifique que no tenga vehículos u órdenes asociadas.");
        }

        response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=listar");
    }

    // Métodos auxiliares
    private Cliente extractClienteFromRequest(HttpServletRequest request) {
        Cliente cliente = new Cliente();

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            idParam = request.getParameter("idCliente");
        }

        if (idParam != null && !idParam.isEmpty()) {
            cliente.setIDCliente(Integer.parseInt(idParam));
        }

        cliente.setNombre(request.getParameter("nombre"));
        cliente.setApellido(request.getParameter("apellido"));
        cliente.setTelefono(request.getParameter("telefono"));
        cliente.setEmail(request.getParameter("email"));
        cliente.setDireccion(request.getParameter("direccion"));

        String fechaRegistroStr = request.getParameter("fechaRegistro");
        if (fechaRegistroStr != null && !fechaRegistroStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaRegistro = sdf.parse(fechaRegistroStr);
                cliente.setFechaRegistro(fechaRegistro);
            } catch (ParseException e) {
                cliente.setFechaRegistro(new Date());
            }
        }

        return cliente;
    }

    private String getActionFromPath(String path, HttpServletRequest request) {
        String actionParam = request.getParameter("action");
        if (actionParam != null && !actionParam.isEmpty()) {
            return actionParam;
        }

        if (path.endsWith("/crear")) {
            return "formulario";
        }
        if (path.endsWith("/editar")) {
            return "editar";
        }
        if (path.endsWith("/ver")) {
            return "ver";
        }
        if (path.endsWith("/eliminar")) {
            return "eliminar";
        }
        if (path.endsWith("/buscar")) {
            return "buscar";
        }
        if (path.endsWith("/reportes")) {
            return "reportes";
        }

        return "listar";
    }

    private String determineJspPage(String userRole, String path, String action) {
        String basePath = "/WEB-INF/pages/";

        // CORREGIDO: Usar "clientes" (plural) en la ruta
        if (path.contains("/admin/")) {
            return basePath + "admin/clientes/" + action + ".jsp";
        } else if (path.contains("/recepcionista/")) {
            return basePath + "recepcionista/clientes/" + action + ".jsp";
        }

        // Si viene por /ClienteServlet?action=..., usar el rol del usuario
        if ("administrador".equals(userRole)) {
            return basePath + "admin/clientes/" + action + ".jsp";
        } else if ("recepcionista".equals(userRole)) {
            return basePath + "recepcionista/clientes/" + action + ".jsp";
        }

        // Por defecto, usar admin
        return basePath + "admin/clientes/" + action + ".jsp";
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=listar");
        }
    }
}