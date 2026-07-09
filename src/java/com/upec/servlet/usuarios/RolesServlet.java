package com.upec.servlet.usuarios;

import com.upec.dao.RolesDAO;
import com.upec.dao.UsuariosDAO;
import com.upec.model.Roles;
import com.upec.model.Usuarios;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "RolesServlet", urlPatterns = {
    "/RolesServlet",  // URL principal con parámetro action
    "/admin/roles",
    "/admin/roles/crear",
    "/admin/roles/editar",
    "/admin/roles/ver",
    "/admin/roles/eliminar",
    "/admin/roles/buscar",
    "/admin/roles/asignar-permisos",
    "/admin/roles/usuarios",
    "/admin/roles/cambiar-estado"
})
public class RolesServlet extends HttpServlet {

    // SOLUCIÓN: Inyectar los DAOs en lugar de instanciarlos
    @EJB
    private RolesDAO rolesDAO;
    
    @EJB
    private UsuariosDAO usuariosDAO;

    @Override
    public void init() throws ServletException {
        // Los DAOs se inyectan automáticamente, no es necesario instanciarlos
        // Si la inyección falla, verifica que los DAOs sean EJBs
        if (rolesDAO == null) {
            System.err.println("ERROR: RolesDAO no fue inyectado correctamente");
        }
        if (usuariosDAO == null) {
            System.err.println("ERROR: UsuariosDAO no fue inyectado correctamente");
        }
    }

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
        String action = getActionFromPath(path, request);

        try {
            switch (action) {
                case "listar":
                    handleListarRoles(request, response);
                    break;
                case "formulario":
                case "crear":
                    handleFormularioRol(request, response);
                    break;
                case "editar":
                    handleFormularioRol(request, response);
                    break;
                case "ver":
                    handleVerRol(request, response);
                    break;
                case "buscar":
                    handleBuscarRoles(request, response);
                    break;
                case "asignar-permisos":
                    handleAsignarPermisosForm(request, response);
                    break;
                case "usuarios":
                    handleUsuariosPorRol(request, response);
                    break;
                default:
                    handleListarRoles(request, response);
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
        String action = getActionFromPath(path, request);

        try {
            switch (action) {
                case "crear":
                    handleCrearRol(request, response);
                    break;
                case "editar":
                    handleEditarRol(request, response);
                    break;
                case "eliminar":
                    handleEliminarRol(request, response);
                    break;
                case "asignar-permisos":
                    handleAsignarPermisos(request, response);
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

    private void handleListarRoles(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Roles> roles = rolesDAO.listarRoles();

            Long totalRoles = rolesDAO.countTotalRoles();
            Long rolesActivos = rolesDAO.countRolesActivos();
            List<Object[]> usuariosPorRol = rolesDAO.countUsuariosPorRol();
            List<Object[]> estadisticas = rolesDAO.getEstadisticasRoles();

            request.setAttribute("roles", roles);
            request.setAttribute("totalRoles", totalRoles != null ? totalRoles : 0);
            request.setAttribute("rolesActivos", rolesActivos);
            request.setAttribute("usuariosPorRol", usuariosPorRol);
            request.setAttribute("estadisticas", estadisticas);

            request.getRequestDispatcher("/WEB-INF/pages/admin/roles/list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al listar roles: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/pages/admin/roles/list.jsp").forward(request, response);
        }
    }

    private void handleFormularioRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<String> permisosDisponibles = Arrays.asList(
                "admin", "gestion_usuarios", "gestion_roles", "gestion_clientes",
                "gestion_vehiculos", "gestion_empleados", "gestion_ordenes",
                "gestion_diagnosticos", "gestion_facturas", "gestion_inventario",
                "ver_reportes", "generar_reportes", "configuracion_sistema"
        );

        request.setAttribute("permisosDisponibles", permisosDisponibles);

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            int id = Integer.parseInt(idParam);
            Roles rol = rolesDAO.obtenerRolPorId(id);
            if (rol != null) {
                request.setAttribute("rol", rol);
                List<String> permisosActuales = rolesDAO.obtenerPermisosPorRol(id);
                request.setAttribute("permisosActuales", permisosActuales);
            }
        }

        request.getRequestDispatcher("/WEB-INF/pages/admin/roles/form.jsp").forward(request, response);
    }

    private void handleVerRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de rol no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Roles rol = rolesDAO.obtenerRolConUsuarios(id);

        if (rol == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Rol no encontrado");
            return;
        }

        List<String> permisos = rolesDAO.obtenerPermisosPorRol(id);
        List<Usuarios> usuarios = rolesDAO.obtenerUsuariosPorRol(id);

        request.setAttribute("rol", rol);
        request.setAttribute("permisos", permisos);
        request.setAttribute("usuarios", usuarios);

        request.getRequestDispatcher("/WEB-INF/pages/admin/roles/view.jsp").forward(request, response);
    }

    private void handleBuscarRoles(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");

        List<Roles> roles;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            roles = rolesDAO.buscarRolesPorCriterio(valor);
        } else {
            roles = rolesDAO.listarRoles();
        }

        request.setAttribute("roles", roles);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);

        request.getRequestDispatcher("/WEB-INF/pages/admin/roles/list.jsp").forward(request, response);
    }

    private void handleAsignarPermisosForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de rol no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Roles rol = rolesDAO.obtenerRolPorId(id);

        if (rol == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Rol no encontrado");
            return;
        }

        List<String> permisosDisponibles = Arrays.asList(
                "admin", "gestion_usuarios", "gestion_roles", "gestion_clientes",
                "gestion_vehiculos", "gestion_empleados", "gestion_ordenes",
                "gestion_diagnosticos", "gestion_facturas", "gestion_inventario",
                "ver_reportes", "generar_reportes", "configuracion_sistema"
        );

        List<String> permisosActuales = rolesDAO.obtenerPermisosPorRol(id);

        request.setAttribute("rol", rol);
        request.setAttribute("permisosDisponibles", permisosDisponibles);
        request.setAttribute("permisosActuales", permisosActuales);

        request.getRequestDispatcher("/WEB-INF/pages/admin/roles/asignar-permisos.jsp").forward(request, response);
    }

    private void handleUsuariosPorRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de rol no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Roles rol = rolesDAO.obtenerRolPorId(id);

        if (rol == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Rol no encontrado");
            return;
        }

        List<Usuarios> usuarios = rolesDAO.obtenerUsuariosPorRol(id);
        Long totalUsuarios = rolesDAO.countUsuariosByRol(id);

        request.setAttribute("rol", rol);
        request.setAttribute("usuarios", usuarios);
        request.setAttribute("totalUsuarios", totalUsuarios);

        request.getRequestDispatcher("/WEB-INF/pages/admin/roles/usuarios.jsp").forward(request, response);
    }

    private void handleCrearRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Roles rol = extractRolFromRequest(request);

        if (rol.getNombreRol() != null && !rol.getNombreRol().isEmpty()) {
            if (rolesDAO.nombreRolExists(rol.getNombreRol())) {
                request.setAttribute("error", "El nombre del rol ya está registrado en el sistema");
                request.setAttribute("rol", rol);
                handleFormularioRol(request, response);
                return;
            }
        }

        if (rol.getEstado() == null) {
            rol.setEstado(true);
        }

        try {
            rolesDAO.create(rol);
            request.getSession().setAttribute("mensaje", "Rol creado exitosamente");
            response.sendRedirect(request.getContextPath() + "/admin/roles");
        } catch (Exception e) {
            request.setAttribute("error", "Error al crear el rol: " + e.getMessage());
            request.setAttribute("rol", rol);
            handleFormularioRol(request, response);
        }
    }

    private void handleEditarRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("idRol");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de rol no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Roles rolExistente = rolesDAO.obtenerRolPorId(id);

        if (rolExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Rol no encontrado");
            return;
        }

        Roles rolActualizado = extractRolFromRequest(request);
        rolExistente.setNombreRol(rolActualizado.getNombreRol());
        rolExistente.setDescripcion(rolActualizado.getDescripcion());

        if (rolExistente.getNombreRol() != null && !rolExistente.getNombreRol().isEmpty()) {
            if (rolesDAO.nombreRolExistsExcludingId(rolExistente.getNombreRol(), rolExistente.getIDRol())) {
                request.setAttribute("error", "El nombre del rol ya está registrado por otro rol");
                request.setAttribute("rol", rolExistente);
                handleFormularioRol(request, response);
                return;
            }
        }

        try {
            rolesDAO.saveOrUpdate(rolExistente);
            request.getSession().setAttribute("mensaje", "Rol actualizado exitosamente");
            response.sendRedirect(request.getContextPath() + "/admin/roles");
        } catch (Exception e) {
            request.setAttribute("error", "Error al actualizar el rol: " + e.getMessage());
            request.setAttribute("rol", rolExistente);
            handleFormularioRol(request, response);
        }
    }

    private void handleEliminarRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de rol no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);

        if (!rolesDAO.puedeEliminarRol(id)) {
            request.getSession().setAttribute("error",
                    "No se puede eliminar el rol. Puede que tenga usuarios asociados o sea un rol del sistema.");
            response.sendRedirect(request.getContextPath() + "/admin/roles");
            return;
        }

        try {
            rolesDAO.delete(id);
            request.getSession().setAttribute("mensaje", "Rol eliminado exitosamente");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error al eliminar el rol: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/roles");
    }

    private void handleAsignarPermisos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRolParam = request.getParameter("idRol");
        String[] permisosArray = request.getParameterValues("permisos");

        if (idRolParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de rol no especificado");
            return;
        }

        int idRol = Integer.parseInt(idRolParam);
        List<String> permisos = permisosArray != null ? Arrays.asList(permisosArray) : List.of();

        if (rolesDAO.asignarPermisosRol(idRol, permisos)) {
            request.getSession().setAttribute("mensaje", "Permisos asignados exitosamente al rol");
        } else {
            request.getSession().setAttribute("error", "Error al asignar los permisos al rol");
        }

        response.sendRedirect(request.getContextPath() + "/admin/roles/ver?id=" + idRol);
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

        try {
            rolesDAO.updateEstado(id, nuevoEstado);
            String mensaje = nuevoEstado ? "Rol activado exitosamente" : "Rol desactivado exitosamente";
            request.getSession().setAttribute("mensaje", mensaje);
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error al cambiar el estado del rol: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/roles");
    }

    private Roles extractRolFromRequest(HttpServletRequest request) {
        Roles rol = new Roles();

        String idParam = request.getParameter("idRol");
        if (idParam != null && !idParam.isEmpty()) {
            rol.setIDRol(Integer.parseInt(idParam));
        }

        rol.setNombreRol(request.getParameter("nombreRol"));
        rol.setDescripcion(request.getParameter("descripcion"));

        String estadoParam = request.getParameter("estado");
        if (estadoParam != null && !estadoParam.isEmpty()) {
            rol.setEstado(Boolean.parseBoolean(estadoParam));
        }

        return rol;
    }

    private String getActionFromPath(String path, HttpServletRequest request) {
        // Primero verificar si viene el parámetro action (para compatibilidad)
        String actionParam = request.getParameter("action");
        if (actionParam != null && !actionParam.isEmpty()) {
            return actionParam;
        }

        // Luego verificar la URL pattern
        if (path.endsWith("/crear")) {
            return "crear";
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
        if (path.endsWith("/asignar-permisos")) {
            return "asignar-permisos";
        }
        if (path.endsWith("/usuarios")) {
            return "usuarios";
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
        if (referer != null && !referer.isEmpty()) {
            request.getSession().setAttribute("error", errorMessage);
            response.sendRedirect(referer);
        } else {
            request.getSession().setAttribute("error", errorMessage);
            response.sendRedirect(request.getContextPath() + "/admin/roles");
        }
    }

    @Override
    public void destroy() {
        // Cleanup resources if needed
    }
}