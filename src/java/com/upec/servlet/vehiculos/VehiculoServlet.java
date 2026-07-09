package com.upec.servlet.vehiculos;

import com.upec.dao.VehiculoDAO;
import com.upec.dao.MarcaDAO;
import com.upec.dao.ModeloDAO;
import com.upec.dao.ClienteDAO;
import com.upec.model.Vehiculo;
import com.upec.model.Marca;
import com.upec.model.Modelo;
import com.upec.model.Cliente;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "VehiculoServlet", urlPatterns = {
    "/VehiculoServlet",
    "/admin/vehiculos",
    "/admin/vehiculos/crear",
    "/admin/vehiculos/editar",
    "/admin/vehiculos/ver",
    "/admin/vehiculos/eliminar",
    "/admin/vehiculos/buscar",
    "/admin/vehiculos/asignar-cliente",
    "/admin/vehiculos/actualizar-estado",
    "/admin/vehiculos/actualizar-kilometraje",
    "/admin/vehiculos/historial"
})
public class VehiculoServlet extends HttpServlet {

    @Inject
    private VehiculoDAO vehiculoDAO;

    @Inject
    private MarcaDAO marcaDAO;

    @Inject
    private ModeloDAO modeloDAO;

    @Inject
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
        if (!"administrador".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Determinar la acción
        String action = request.getParameter("action");
        String path = request.getServletPath();

        // Si viene por parámetro action, usarlo; si no, obtenerlo de la ruta
        if (action == null || action.isEmpty()) {
            action = getActionFromPath(path);
        }

        try {
            switch (action) {
                case "listar":
                    handleListarVehiculos(request, response);
                    break;
                case "formulario":
                case "crear":
                    handleFormularioVehiculo(request, response);
                    break;
                case "editar":  // ← AGREGAR ESTE CASO
                    handleFormularioVehiculo(request, response);
                    break;
                case "ver":
                    handleVerVehiculo(request, response);
                    break;
                case "eliminar":  // ← AGREGAR ESTE CASO
                    handleEliminarVehiculo(request, response);
                    break;
                case "buscar":
                    handleBuscarVehiculos(request, response);
                    break;
                case "asignar-cliente":
                    handleAsignarClienteForm(request, response);
                    break;
                case "actualizar-estado":
                    handleActualizarEstadoForm(request, response);
                    break;
                case "actualizar-kilometraje":
                    handleActualizarKilometrajeForm(request, response);
                    break;
                case "historial":
                    handleHistorialVehiculo(request, response);
                    break;
                default:
                    handleListarVehiculos(request, response);
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

        // Determinar la acción
        String action = request.getParameter("action");
        String path = request.getServletPath();

        // Si viene por parámetro action, usarlo; si no, obtenerlo de la ruta
        if (action == null || action.isEmpty()) {
            action = getActionFromPath(path);
        }

        try {
            switch (action) {
                case "crear":
                    handleCrearVehiculo(request, response);
                    break;
                case "editar":
                    handleEditarVehiculo(request, response);
                    break;
                case "eliminar":
                    handleEliminarVehiculo(request, response);
                    break;
                case "asignar-cliente":
                    handleAsignarCliente(request, response);
                    break;
                case "actualizar-estado":
                    handleActualizarEstado(request, response);
                    break;
                case "actualizar-kilometraje":
                    handleActualizarKilometraje(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET
    private void handleListarVehiculos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculos();

        // Obtener estadísticas para el dashboard
        int totalVehiculos = vehiculoDAO.contarTotalVehiculos();
        Long vehiculosActivos = vehiculoDAO.countVehiculosActivos();
        List<Object[]> vehiculosPorMarca = vehiculoDAO.obtenerVehiculosPorMarca();

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("totalVehiculos", totalVehiculos);
        request.setAttribute("vehiculosActivos", vehiculosActivos);
        request.setAttribute("vehiculosPorMarca", vehiculosPorMarca);

        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/list.jsp").forward(request, response);
    }

    private void handleFormularioVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cargar datos necesarios para el formulario
        List<Marca> marcas = marcaDAO.listarMarcasActivas();
        List<Cliente> clientes = clienteDAO.listarClientes();

        request.setAttribute("marcas", marcas);
        request.setAttribute("clientes", clientes);

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            // Modo edición
            int id = Integer.parseInt(idParam);
            Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(id);
            if (vehiculo != null) {
                request.setAttribute("vehiculo", vehiculo);
                // Cargar modelos de la marca seleccionada
                if (vehiculo.getIDMarca() != null) {
                    List<Modelo> modelos = modeloDAO.listarModelosActivosPorMarca(vehiculo.getIDMarca().getIDMarca());
                    request.setAttribute("modelos", modelos);
                }
            }
        } else {
            // Modo creación - cargar modelos si se seleccionó una marca
            String idMarcaParam = request.getParameter("idMarca");
            if (idMarcaParam != null && !idMarcaParam.isEmpty()) {
                int idMarca = Integer.parseInt(idMarcaParam);
                List<Modelo> modelos = modeloDAO.listarModelosActivosPorMarca(idMarca);
                request.setAttribute("modelos", modelos);
                request.setAttribute("marcaSeleccionada", idMarca);
            }
        }

        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/form.jsp").forward(request, response);
    }

    private void handleVerVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoCompleto(id);

        if (vehiculo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo no encontrado");
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/view.jsp").forward(request, response);
    }

    private void handleBuscarVehiculos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");

        List<Vehiculo> vehiculos;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            if ("placa".equals(criterio)) {
                vehiculos = vehiculoDAO.buscarVehiculosPorPlaca(valor);
            } else if ("marca".equals(criterio)) {
                try {
                    int idMarca = Integer.parseInt(valor);
                    vehiculos = vehiculoDAO.filtrarVehiculosPorMarca(idMarca);
                } catch (NumberFormatException e) {
                    vehiculos = vehiculoDAO.listarVehiculos();
                }
            } else if ("cliente".equals(criterio)) {
                try {
                    int idCliente = Integer.parseInt(valor);
                    vehiculos = vehiculoDAO.listarVehiculosPorCliente(idCliente);
                } catch (NumberFormatException e) {
                    vehiculos = vehiculoDAO.listarVehiculos();
                }
            } else {
                vehiculos = vehiculoDAO.listarVehiculos();
            }
        } else {
            vehiculos = vehiculoDAO.listarVehiculos();
        }

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);

        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/list.jsp").forward(request, response);
    }

    private void handleAsignarClienteForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(id);

        if (vehiculo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo no encontrado");
            return;
        }

        List<Cliente> clientes = clienteDAO.listarClientes();

        request.setAttribute("vehiculo", vehiculo);
        request.setAttribute("clientes", clientes);

        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/asignar-cliente.jsp").forward(request, response);
    }

    private void handleActualizarEstadoForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(id);

        if (vehiculo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo no encontrado");
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/actualizar-estado.jsp").forward(request, response);
    }

    private void handleActualizarKilometrajeForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(id);

        if (vehiculo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo no encontrado");
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/actualizar-kilometraje.jsp").forward(request, response);
    }

    private void handleHistorialVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoConHistorial(id);

        if (vehiculo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo no encontrado");
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/historial.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST
    private void handleCrearVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Vehiculo vehiculo = extractVehiculoFromRequest(request);

        // Validaciones
        if (vehiculo.getPlaca() != null && !vehiculo.getPlaca().isEmpty()) {
            if (vehiculoDAO.placaExists(vehiculo.getPlaca())) {
                request.setAttribute("error", "La placa ya está registrada en el sistema");
                handleFormularioVehiculo(request, response);
                return;
            }
        }

        if (vehiculo.getNumeroChasis() != null && !vehiculo.getNumeroChasis().isEmpty()) {
            if (vehiculoDAO.numeroChasisExists(vehiculo.getNumeroChasis())) {
                request.setAttribute("error", "El número de chasis ya está registrado en el sistema");
                handleFormularioVehiculo(request, response);
                return;
            }
        }

        // Estado activo por defecto
        if (vehiculo.getEstado() == null) {
            vehiculo.setEstado(true);
        }

        try {
            vehiculoDAO.crearVehiculo(vehiculo);
            request.getSession().setAttribute("mensaje", "Vehículo creado exitosamente");
            response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
        } catch (Exception e) {
            request.setAttribute("error", "Error al crear el vehículo");
            request.setAttribute("vehiculo", vehiculo);

            // Recargar datos para el formulario
            List<Marca> marcas = marcaDAO.listarMarcasActivas();
            List<Cliente> clientes = clienteDAO.listarClientes();
            request.setAttribute("marcas", marcas);
            request.setAttribute("clientes", clientes);

            request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/form.jsp").forward(request, response);
        }
    }

    private void handleEditarVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("idVehiculo");
        if (idParam == null || idParam.isEmpty()) {
            idParam = request.getParameter("id");
        }

        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Vehiculo vehiculoExistente = vehiculoDAO.obtenerVehiculoPorId(id);

        if (vehiculoExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo no encontrado");
            return;
        }

        // Actualizar campos editables
        Vehiculo vehiculoActualizado = extractVehiculoFromRequest(request);
        vehiculoExistente.setPlaca(vehiculoActualizado.getPlaca());
        vehiculoExistente.setColor(vehiculoActualizado.getColor());
        vehiculoExistente.setAnioVehiculo(vehiculoActualizado.getAnioVehiculo());
        vehiculoExistente.setNumeroChasis(vehiculoActualizado.getNumeroChasis());
        vehiculoExistente.setKilometraje(vehiculoActualizado.getKilometraje());
        vehiculoExistente.setIDMarca(vehiculoActualizado.getIDMarca());
        vehiculoExistente.setIDModelo(vehiculoActualizado.getIDModelo());

        // Validaciones de unicidad (excluyendo el propio vehículo)
        if (vehiculoExistente.getPlaca() != null && !vehiculoExistente.getPlaca().isEmpty()) {
            Vehiculo vehiculoConPlaca = vehiculoDAO.findByPlaca(vehiculoExistente.getPlaca());
            if (vehiculoConPlaca != null
                    && !vehiculoConPlaca.getIDVehiculo().equals(vehiculoExistente.getIDVehiculo())) {
                request.setAttribute("error", "La placa ya está registrada por otro vehículo");
                request.setAttribute("vehiculo", vehiculoExistente);
                recargarDatosFormulario(request, response);
                return;
            }
        }

        if (vehiculoExistente.getNumeroChasis() != null && !vehiculoExistente.getNumeroChasis().isEmpty()) {
            // Verificar número de chasis único
            List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculos();
            boolean chasisDuplicado = vehiculos.stream()
                    .filter(v -> !v.getIDVehiculo().equals(vehiculoExistente.getIDVehiculo()))
                    .anyMatch(v -> vehiculoExistente.getNumeroChasis().equals(v.getNumeroChasis()));

            if (chasisDuplicado) {
                request.setAttribute("error", "El número de chasis ya está registrado por otro vehículo");
                request.setAttribute("vehiculo", vehiculoExistente);
                recargarDatosFormulario(request, response);
                return;
            }
        }

        try {
            vehiculoDAO.actualizarVehiculo(vehiculoExistente);
            request.getSession().setAttribute("mensaje", "Vehículo actualizado exitosamente");
            response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
        } catch (Exception e) {
            request.setAttribute("error", "Error al actualizar el vehículo");
            request.setAttribute("vehiculo", vehiculoExistente);
            recargarDatosFormulario(request, response);
        }
    }

    private void handleEliminarVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);

        try {
            boolean eliminado = vehiculoDAO.eliminarVehiculo(id);
            if (eliminado) {
                request.getSession().setAttribute("mensaje", "Vehículo eliminado exitosamente");
            } else {
                request.getSession().setAttribute("error", "Error al eliminar el vehículo. Verifique que no tenga órdenes de servicio asociadas.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error al eliminar el vehículo: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
    }

    private void handleAsignarCliente(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idVehiculoParam = request.getParameter("idVehiculo");
        String idClienteParam = request.getParameter("idCliente");

        if (idVehiculoParam == null || idClienteParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int idVehiculo = Integer.parseInt(idVehiculoParam);
        int idCliente = Integer.parseInt(idClienteParam);

        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(idVehiculo);
        Cliente cliente = clienteDAO.obtenerClientePorId(idCliente);

        if (vehiculo == null || cliente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Vehículo o cliente no encontrado");
            return;
        }

        // Asignar cliente al vehículo
        vehiculo.setIDCliente(cliente);

        try {
            vehiculoDAO.actualizarVehiculo(vehiculo);
            request.getSession().setAttribute("mensaje", "Cliente asignado exitosamente al vehículo");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error al asignar el cliente al vehículo");
        }

        response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
    }

    private void handleActualizarEstado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("idVehiculo");
        String estadoParam = request.getParameter("estado");

        if (idParam == null || estadoParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int id = Integer.parseInt(idParam);
        boolean nuevoEstado = Boolean.parseBoolean(estadoParam);

        try {
            // Usar el método updateEstado del DAO
            vehiculoDAO.updateEstado(id, nuevoEstado);
            String mensaje = nuevoEstado ? "Vehículo activado exitosamente" : "Vehículo desactivado exitosamente";
            request.getSession().setAttribute("mensaje", mensaje);
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error al actualizar el estado del vehículo");
        }

        response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
    }

    private void handleActualizarKilometraje(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("idVehiculo");
        String kilometrajeParam = request.getParameter("kilometraje");

        if (idParam == null || kilometrajeParam == null || kilometrajeParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int id = Integer.parseInt(idParam);
        int nuevoKilometraje = Integer.parseInt(kilometrajeParam);

        try {
            // Usar el método updateKilometraje del DAO
            vehiculoDAO.updateKilometraje(id, nuevoKilometraje);
            request.getSession().setAttribute("mensaje", "Kilometraje actualizado exitosamente");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error al actualizar el kilometraje del vehículo");
        }

        response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
    }

    // Métodos auxiliares
    private Vehiculo extractVehiculoFromRequest(HttpServletRequest request) {
        Vehiculo vehiculo = new Vehiculo();

        String idParam = request.getParameter("idVehiculo");
        if (idParam != null && !idParam.isEmpty()) {
            vehiculo.setIDVehiculo(Integer.parseInt(idParam));
        }

        // Campos básicos
        vehiculo.setPlaca(request.getParameter("placa"));
        vehiculo.setColor(request.getParameter("color"));

        // Año del vehículo
        String anioParam = request.getParameter("anioVehiculo");
        if (anioParam != null && !anioParam.isEmpty()) {
            vehiculo.setAnioVehiculo(Integer.parseInt(anioParam));
        }

        // Kilometraje
        String kilometrajeParam = request.getParameter("kilometraje");
        if (kilometrajeParam != null && !kilometrajeParam.isEmpty()) {
            vehiculo.setKilometraje(Integer.parseInt(kilometrajeParam));
        }

        // Número de chasis
        vehiculo.setNumeroChasis(request.getParameter("numeroChasis"));

        // Estado
        String estadoParam = request.getParameter("estado");
        if (estadoParam != null && !estadoParam.isEmpty()) {
            vehiculo.setEstado(Boolean.parseBoolean(estadoParam));
        }

        // Marca
        String idMarcaParam = request.getParameter("idMarca");
        if (idMarcaParam != null && !idMarcaParam.isEmpty()) {
            Marca marca = marcaDAO.obtenerMarcaPorId(Integer.parseInt(idMarcaParam));
            vehiculo.setIDMarca(marca);
        }

        // Modelo
        String idModeloParam = request.getParameter("idModelo");
        if (idModeloParam != null && !idModeloParam.isEmpty()) {
            Modelo modelo = modeloDAO.obtenerModeloPorId(Integer.parseInt(idModeloParam));
            vehiculo.setIDModelo(modelo);
        }

        // Cliente
        String idClienteParam = request.getParameter("idCliente");
        if (idClienteParam != null && !idClienteParam.isEmpty()) {
            Cliente cliente = clienteDAO.obtenerClientePorId(Integer.parseInt(idClienteParam));
            vehiculo.setIDCliente(cliente);
        }

        return vehiculo;
    }

    private void recargarDatosFormulario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Marca> marcas = marcaDAO.listarMarcasActivas();
        List<Cliente> clientes = clienteDAO.listarClientes();
        request.setAttribute("marcas", marcas);
        request.setAttribute("clientes", clientes);

        request.getRequestDispatcher("/WEB-INF/pages/admin/vehiculo/form.jsp").forward(request, response);
    }

    private String getActionFromPath(String path) {
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
        if (path.endsWith("/asignar-cliente")) {
            return "asignar-cliente";
        }
        if (path.endsWith("/actualizar-estado")) {
            return "actualizar-estado";
        }
        if (path.endsWith("/actualizar-kilometraje")) {
            return "actualizar-kilometraje";
        }
        if (path.endsWith("/historial")) {
            return "historial";
        }
        if (path.endsWith("/vehiculos")) {
            return "listar";
        }

        return "listar"; // Por defecto para GET en /VehiculoServlet
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/VehiculoServlet?action=listar");
        }
    }
}
