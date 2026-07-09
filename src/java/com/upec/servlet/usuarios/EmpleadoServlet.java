package com.upec.servlet.usuarios;

import com.upec.dao.EmpleadoDAO;
import com.upec.dao.UsuariosDAO;
import com.upec.model.Empleado;
import com.upec.model.Usuarios;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "EmpleadoServlet", urlPatterns = {
    "/EmpleadoServlet",
    "/admin/empleados",
    "/admin/empleados/crear",
    "/admin/empleados/editar",
    "/admin/empleados/ver",
    "/admin/empleados/eliminar",
    "/admin/empleados/buscar",
    "/admin/empleados/asignar-usuario",
    "/admin/empleados/actualizar-salario",
    "/admin/empleados/cambiar-estado"
})
public class EmpleadoServlet extends HttpServlet {

    @EJB
    private EmpleadoDAO empleadoDAO;

    @EJB
    private UsuariosDAO usuariosDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("rol");
        if (!"administrador".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "listar":
                    handleListarEmpleados(request, response);
                    break;
                case "crear":
                case "formulario":
                    handleFormularioEmpleado(request, response);
                    break;
                case "editar":  // AGREGADO: Manejar GET de editar
                    handleFormularioEmpleado(request, response);
                    break;
                case "ver":
                    handleVerEmpleado(request, response);
                    break;
                case "eliminar":  // AGREGADO: Permitir eliminar por GET
                    handleEliminarEmpleado(request, response);
                    break;
                case "buscar":
                    handleBuscarEmpleados(request, response);
                    break;
                case "asignar-usuario":
                    handleAsignarUsuarioForm(request, response);
                    break;
                case "actualizar-salario":
                    handleActualizarSalarioForm(request, response);
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
        if (!"administrador".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "crear":
                case "formulario":
                    handleCrearEmpleado(request, response);
                    break;
                case "editar":
                    handleEditarEmpleado(request, response);
                    break;
                case "eliminar":
                    handleEliminarEmpleado(request, response);
                    break;
                case "asignar-usuario":
                    handleAsignarUsuario(request, response);
                    break;
                case "actualizar-salario":
                    handleActualizarSalario(request, response);
                    break;
                case "cambiar-estado":
                    handleCambiarEstado(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET
    private void handleListarEmpleados(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Empleado> empleados = empleadoDAO.listarEmpleados();

        // Obtener estadísticas para el dashboard
        int totalEmpleados = empleadoDAO.contarTotalEmpleados();
        int empleadosActivos = empleadoDAO.contarEmpleadosActivos();
        List<Object[]> estadisticas = empleadoDAO.obtenerEstadisticasEmpleados();

        request.setAttribute("empleados", empleados);
        request.setAttribute("totalEmpleados", totalEmpleados);
        request.setAttribute("empleadosActivos", empleadosActivos);
        request.setAttribute("estadisticas", estadisticas);

        request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/list.jsp").forward(request, response);
    }

    private void handleFormularioEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cargar usuarios disponibles para asignar
        List<Usuarios> usuariosDisponibles = usuariosDAO.obtenerUsuariosSinEmpleado();

        request.setAttribute("usuariosDisponibles", usuariosDisponibles);

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            // Modo edición
            int id = Integer.parseInt(idParam);
            Empleado empleado = empleadoDAO.obtenerEmpleadoPorId(id);
            if (empleado != null) {
                request.setAttribute("empleado", empleado);
            }
        }
        // Si no hay ID, es modo creación

        request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/form.jsp").forward(request, response);
    }

    private void handleVerEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de empleado no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Empleado empleado = empleadoDAO.obtenerEmpleadoPorId(id);

        if (empleado == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Empleado no encontrado");
            return;
        }

        request.setAttribute("empleado", empleado);
        request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/view.jsp").forward(request, response);
    }

    private void handleBuscarEmpleados(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");

        List<Empleado> empleados;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            if ("nombre".equals(criterio)) {
                empleados = empleadoDAO.buscarEmpleadosPorNombre(valor);
            } else if ("cargo".equals(criterio)) {
                empleados = empleadoDAO.filtrarEmpleadosPorCargo(valor);
            } else {
                empleados = empleadoDAO.listarEmpleados();
            }
        } else {
            empleados = empleadoDAO.listarEmpleados();
        }

        request.setAttribute("empleados", empleados);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);

        request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/list.jsp").forward(request, response);
    }

    private void handleAsignarUsuarioForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de empleado no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Empleado empleado = empleadoDAO.obtenerEmpleadoPorId(id);

        if (empleado == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Empleado no encontrado");
            return;
        }

        List<Usuarios> usuariosDisponibles = usuariosDAO.obtenerUsuariosSinEmpleado();

        request.setAttribute("empleado", empleado);
        request.setAttribute("usuariosDisponibles", usuariosDisponibles);

        request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/asignar-usuario.jsp").forward(request, response);
    }

    private void handleActualizarSalarioForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de empleado no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Empleado empleado = empleadoDAO.obtenerEmpleadoPorId(id);

        if (empleado == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Empleado no encontrado");
            return;
        }

        request.setAttribute("empleado", empleado);
        request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/actualizar-salario.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST
    private void handleCrearEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Empleado empleado = extractEmpleadoFromRequest(request);

        // Validar email único
        if (empleado.getEmail() != null && !empleado.getEmail().isEmpty()) {
            if (empleadoDAO.emailExists(empleado.getEmail())) {
                request.setAttribute("error", "El email ya está registrado en el sistema");
                handleFormularioEmpleado(request, response);
                return;
            }
        }

        // Asignar fecha de contratación actual si no se proporciona
        if (empleado.getFechaContratacion() == null) {
            empleado.setFechaContratacion(new Date());
        }

        // Estado activo por defecto
        if (empleado.getEstado() == null) {
            empleado.setEstado(true);
        }

        if (empleadoDAO.crearEmpleado(empleado)) {
            request.getSession().setAttribute("mensaje", "Empleado creado exitosamente");
            response.sendRedirect(request.getContextPath() + "/admin/empleados");
        } else {
            request.setAttribute("error", "Error al crear el empleado");
            request.setAttribute("empleado", empleado);

            // Recargar datos para el formulario
            List<Usuarios> usuariosDisponibles = usuariosDAO.obtenerUsuariosSinEmpleado();
            request.setAttribute("usuariosDisponibles", usuariosDisponibles);

            request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/form.jsp").forward(request, response);
        }
    }

    private void handleEditarEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // CORREGIDO: Buscar primero por 'id', luego por 'idEmpleado'
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            idParam = request.getParameter("idEmpleado");
        }
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de empleado no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Empleado empleadoExistente = empleadoDAO.obtenerEmpleadoPorId(id);

        if (empleadoExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Empleado no encontrado");
            return;
        }

        // Actualizar campos editables
        Empleado empleadoActualizado = extractEmpleadoFromRequest(request);
        empleadoExistente.setNombre(empleadoActualizado.getNombre());
        empleadoExistente.setApellido(empleadoActualizado.getApellido());
        empleadoExistente.setTelefono(empleadoActualizado.getTelefono());
        empleadoExistente.setEmail(empleadoActualizado.getEmail());
        empleadoExistente.setDireccion(empleadoActualizado.getDireccion());
        empleadoExistente.setFechaContratacion(empleadoActualizado.getFechaContratacion());
        empleadoExistente.setSalario(empleadoActualizado.getSalario());

        // Validar email único (excluyendo el propio empleado)
        if (empleadoExistente.getEmail() != null && !empleadoExistente.getEmail().isEmpty()) {
            List<Empleado> empleadosConEmail = empleadoDAO.findByEmail(empleadoExistente.getEmail());
            if (!empleadosConEmail.isEmpty()
                    && !empleadosConEmail.get(0).getIDEmpleado().equals(empleadoExistente.getIDEmpleado())) {
                request.setAttribute("error", "El email ya está registrado por otro empleado");
                request.setAttribute("empleado", empleadoExistente);

                List<Usuarios> usuariosDisponibles = usuariosDAO.obtenerUsuariosSinEmpleado();
                request.setAttribute("usuariosDisponibles", usuariosDisponibles);

                request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/form.jsp").forward(request, response);
                return;
            }
        }

        if (empleadoDAO.actualizarEmpleado(empleadoExistente)) {
            request.getSession().setAttribute("mensaje", "Empleado actualizado exitosamente");
            response.sendRedirect(request.getContextPath() + "/admin/empleados");
        } else {
            request.setAttribute("error", "Error al actualizar el empleado");
            request.setAttribute("empleado", empleadoExistente);

            // Recargar datos para el formulario
            List<Usuarios> usuariosDisponibles = usuariosDAO.obtenerUsuariosSinEmpleado();
            request.setAttribute("usuariosDisponibles", usuariosDisponibles);

            request.getRequestDispatcher("/WEB-INF/pages/admin/empleado/form.jsp").forward(request, response);
        }
    }

    private void handleEliminarEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de empleado no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);

        if (empleadoDAO.eliminarEmpleado(id)) {
            request.getSession().setAttribute("mensaje", "Empleado eliminado exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al eliminar el empleado. Verifique que no tenga órdenes o diagnósticos asociados.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/empleados");
    }

    private void handleAsignarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idEmpleadoParam = request.getParameter("idEmpleado");
        String idUsuarioParam = request.getParameter("idUsuario");

        if (idEmpleadoParam == null || idUsuarioParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int idEmpleado = Integer.parseInt(idEmpleadoParam);
        int idUsuario = Integer.parseInt(idUsuarioParam);

        Empleado empleado = empleadoDAO.obtenerEmpleadoPorId(idEmpleado);
        Usuarios usuario = usuariosDAO.obtenerUsuarioPorId(idUsuario);

        if (empleado == null || usuario == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Empleado o usuario no encontrado");
            return;
        }

        // Asignar usuario al empleado
        empleado.setIDUsuario(usuario);

        if (empleadoDAO.actualizarEmpleado(empleado)) {
            request.getSession().setAttribute("mensaje", "Usuario asignado exitosamente al empleado");
        } else {
            request.getSession().setAttribute("error", "Error al asignar el usuario al empleado");
        }

        response.sendRedirect(request.getContextPath() + "/admin/empleados");
    }

    private void handleActualizarSalario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idEmpleadoParam = request.getParameter("idEmpleado");
        String salarioParam = request.getParameter("salario");

        if (idEmpleadoParam == null || salarioParam == null || salarioParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int idEmpleado = Integer.parseInt(idEmpleadoParam);
        BigDecimal nuevoSalario = new BigDecimal(salarioParam);

        // Usar el método updateSalario del DAO
        empleadoDAO.updateSalario(idEmpleado, nuevoSalario);

        request.getSession().setAttribute("mensaje", "Salario actualizado exitosamente");
        response.sendRedirect(request.getContextPath() + "/admin/empleados");
    }

    private void handleCambiarEstado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String estadoParam = request.getParameter("estado");

        if (idParam == null || estadoParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int id = Integer.parseInt(idParam);
        boolean nuevoEstado = Boolean.parseBoolean(estadoParam);

        // Usar el método updateEstado del DAO
        empleadoDAO.updateEstado(id, nuevoEstado);

        String mensaje = nuevoEstado ? "Empleado activado exitosamente" : "Empleado desactivado exitosamente";
        request.getSession().setAttribute("mensaje", mensaje);
        response.sendRedirect(request.getContextPath() + "/admin/empleados");
    }

    // Métodos auxiliares
    private Empleado extractEmpleadoFromRequest(HttpServletRequest request) {
        Empleado empleado = new Empleado();

        // CORREGIDO: Buscar primero por 'id', luego por 'idEmpleado'
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            idParam = request.getParameter("idEmpleado");
        }
        
        if (idParam != null && !idParam.isEmpty()) {
            empleado.setIDEmpleado(Integer.parseInt(idParam));
        }

        // Campos básicos
        empleado.setNombre(request.getParameter("nombre"));
        empleado.setApellido(request.getParameter("apellido"));
        empleado.setTelefono(request.getParameter("telefono"));
        empleado.setEmail(request.getParameter("email"));
        empleado.setDireccion(request.getParameter("direccion"));

        // Salario
        String salarioParam = request.getParameter("salario");
        if (salarioParam != null && !salarioParam.isEmpty()) {
            empleado.setSalario(new BigDecimal(salarioParam));
        }

        // Fecha de contratación
        String fechaContratacionStr = request.getParameter("fechaContratacion");
        if (fechaContratacionStr != null && !fechaContratacionStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaContratacion = sdf.parse(fechaContratacionStr);
                empleado.setFechaContratacion(fechaContratacion);
            } catch (ParseException e) {
                // Si hay error, no se asigna fecha
            }
        }

        // Estado
        String estadoParam = request.getParameter("estado");
        if (estadoParam != null && !estadoParam.isEmpty()) {
            empleado.setEstado(Boolean.parseBoolean(estadoParam));
        }

        // Usuario (si se está asignando)
        String idUsuarioParam = request.getParameter("idUsuario");
        if (idUsuarioParam != null && !idUsuarioParam.isEmpty()) {
            Usuarios usuario = usuariosDAO.obtenerUsuarioPorId(Integer.parseInt(idUsuarioParam));
            empleado.setIDUsuario(usuario);
        }

        return empleado;
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/crear")) {
            return "formulario";
        }
        if (path.endsWith("/editar")) {
            return "editar";  // CORREGIDO: Devuelve "editar"
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
        if (path.endsWith("/asignar-usuario")) {
            return "asignar-usuario";
        }
        if (path.endsWith("/actualizar-salario")) {
            return "actualizar-salario";
        }
        if (path.endsWith("/cambiar-estado")) {
            return "cambiar-estado";
        }

        return "listar";
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/empleados");
        }
    }
}