package com.upec.servlet.vehiculos;

import com.upec.dao.VehiculoDAO;
import com.upec.dao.MarcaDAO;
import com.upec.dao.ModeloDAO;
import com.upec.dao.ClienteDAO;
import com.upec.model.Vehiculo;
import com.upec.model.Marca;
import com.upec.model.Modelo;
import com.upec.model.Cliente;
import com.upec.model.Usuarios;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "VehiculoClienteServlet", urlPatterns = {
    "/VehiculoClienteServlet",
    "/cliente/vehiculos",
    "/cliente/vehiculos/dashboard",
    "/cliente/vehiculos/misvehiculos",
    "/cliente/vehiculos/ver",
    "/cliente/vehiculos/historial",
    "/cliente/vehiculos/registrar",
    "/cliente/vehiculos/editar"
})
public class VehiculoClienteServlet extends HttpServlet {

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
        if (!"cliente".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // CORRECCIÓN: Obtener idCliente de la sesión o buscar por usuario
        Integer idCliente = obtenerIdCliente(session);

        if (idCliente == null) {
            request.setAttribute("error", "No se encontró información del cliente en la sesión");
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String actionParam = request.getParameter("action");
        String action;

        if (actionParam != null && !actionParam.isEmpty()) {
            action = actionParam;
        } else {
            action = getActionFromPath(path);
        }

        try {
            switch (action) {
                case "dashboard":
                    handleDashboardVehiculos(request, response);
                    break;
                case "misvehiculos":
                    handleMisVehiculos(request, response);
                    break;
                case "ver":
                    handleVerVehiculo(request, response);
                    break;
                case "historial":
                    handleHistorialVehiculo(request, response);
                    break;
                case "registrar":
                case "nuevo":
                case "formulario":
                    handleRegistrarVehiculoForm(request, response);
                    break;
                case "editar":
                    handleEditarVehiculoForm(request, response);
                    break;
                default:
                    handleDashboardVehiculos(request, response);
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
        if (!"cliente".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // CORRECCIÓN: Obtener idCliente de la sesión o buscar por usuario
        Integer idCliente = obtenerIdCliente(session);

        if (idCliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String actionParam = request.getParameter("action");
        String action;

        if (actionParam != null && !actionParam.isEmpty()) {
            action = actionParam;
        } else {
            action = getActionFromPath(path);
        }

        try {
            switch (action) {
                case "registrar":
                case "guardar":
                case "crear":
                    handleRegistrarVehiculo(request, response);
                    break;
                case "editar":
                case "actualizar":
                    handleEditarVehiculo(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    /**
     * MÉTODO AUXILIAR CRÍTICO: Obtiene el idCliente de la sesión o lo busca por
     * usuario
     */
    private Integer obtenerIdCliente(HttpSession session) {
        // Primero intentar obtener idCliente directamente de la sesión
        Integer idCliente = (Integer) session.getAttribute("idCliente");

        if (idCliente != null) {
            return idCliente;
        }

        // Si no existe, intentar obtenerlo del usuario
        Usuarios usuario = (Usuarios) session.getAttribute("usuario");

        if (usuario != null) {
            try {
                // Buscar el cliente por email (método que ya existe en tu DAO)
                if (usuario.getEmail() != null && !usuario.getEmail().isEmpty()) {
                    List<Cliente> clientes = clienteDAO.buscarClientesPorEmail(usuario.getEmail());

                    if (clientes != null && !clientes.isEmpty()) {
                        Cliente cliente = clientes.get(0);
                        idCliente = cliente.getIDCliente();
                        // Guardar en sesión para futuras consultas
                        session.setAttribute("idCliente", idCliente);
                        return idCliente;
                    }
                }

                // Si no se encuentra por email, intentar buscar por nombre de usuario
                if (usuario.getUsuario() != null && !usuario.getUsuario().isEmpty()) {
                    List<Cliente> clientes = clienteDAO.buscarClientesPorNombre(usuario.getUsuario());

                    if (clientes != null && !clientes.isEmpty()) {
                        Cliente cliente = clientes.get(0);
                        idCliente = cliente.getIDCliente();
                        // Guardar en sesión para futuras consultas
                        session.setAttribute("idCliente", idCliente);
                        return idCliente;
                    }
                }

            } catch (Exception e) {
                System.err.println("Error obteniendo cliente: " + e.getMessage());
                e.printStackTrace();
            }
        }

        return null;
    }

    // Métodos para manejar las operaciones GET
    private void handleDashboardVehiculos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = obtenerIdCliente(request.getSession());
        List<Vehiculo> misVehiculos = vehiculoDAO.listarVehiculosPorCliente(idCliente);

        // Estadísticas para el dashboard
        int totalVehiculos = misVehiculos.size();
        int vehiculosActivos = 0;
        int vehiculosConServiciosActivos = 0;

        for (Vehiculo vehiculo : misVehiculos) {
            if (vehiculo.getEstado() != null && vehiculo.getEstado()) {
                vehiculosActivos++;
            }
            if (!vehiculoDAO.verificarDisponibilidadVehiculo(vehiculo.getIDVehiculo())) {
                vehiculosConServiciosActivos++;
            }
        }

        request.setAttribute("vehiculos", misVehiculos);
        request.setAttribute("totalVehiculos", totalVehiculos);
        request.setAttribute("vehiculosActivos", vehiculosActivos);
        request.setAttribute("vehiculosConServiciosActivos", vehiculosConServiciosActivos);

        request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/dashboard.jsp").forward(request, response);
    }

    private void handleMisVehiculos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = obtenerIdCliente(request.getSession());
        List<Vehiculo> misVehiculos = vehiculoDAO.listarVehiculosPorCliente(idCliente);

        // Separar vehículos activos e inactivos
        List<Vehiculo> vehiculosActivos = misVehiculos.stream()
                .filter(v -> v.getEstado() != null && v.getEstado())
                .toList();

        List<Vehiculo> vehiculosInactivos = misVehiculos.stream()
                .filter(v -> v.getEstado() == null || !v.getEstado())
                .toList();

        request.setAttribute("vehiculos", misVehiculos);
        request.setAttribute("vehiculosActivos", vehiculosActivos);
        request.setAttribute("vehiculosInactivos", vehiculosInactivos);

        request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/list.jsp").forward(request, response);
    }

    private void handleVerVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int idVehiculo = Integer.parseInt(idParam);
        Integer idCliente = obtenerIdCliente(request.getSession());

        // Verificar que el vehículo pertenece al cliente
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(idVehiculo);
        if (vehiculo == null || !vehiculo.getIDCliente().getIDCliente().equals(idCliente)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/view.jsp").forward(request, response);
    }

    private void handleHistorialVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int idVehiculo = Integer.parseInt(idParam);
        Integer idCliente = obtenerIdCliente(request.getSession());

        // Verificar que el vehículo pertenece al cliente y obtener historial completo
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoCompleto(idVehiculo);
        if (vehiculo == null || !vehiculo.getIDCliente().getIDCliente().equals(idCliente)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        request.setAttribute("vehiculo", vehiculo);
        request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/historial.jsp").forward(request, response);
    }

    private void handleRegistrarVehiculoForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cargar marcas y modelos para el formulario
        List<Marca> marcas = marcaDAO.listarMarcasActivas();
        List<Modelo> modelos = modeloDAO.listarModelosActivos();

        request.setAttribute("marcas", marcas);
        request.setAttribute("modelos", modelos);

        request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/form.jsp").forward(request, response);
    }

    private void handleEditarVehiculoForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int idVehiculo = Integer.parseInt(idParam);
        Integer idCliente = obtenerIdCliente(request.getSession());

        // Verificar que el vehículo pertenece al cliente
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(idVehiculo);
        if (vehiculo == null || !vehiculo.getIDCliente().getIDCliente().equals(idCliente)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Cargar marcas y modelos para el formulario
        List<Marca> marcas = marcaDAO.listarMarcasActivas();
        List<Modelo> modelos = modeloDAO.listarModelosActivos();

        request.setAttribute("vehiculo", vehiculo);
        request.setAttribute("marcas", marcas);
        request.setAttribute("modelos", modelos);

        request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/form.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST
    private void handleRegistrarVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = obtenerIdCliente(request.getSession());
        Vehiculo vehiculo = extractVehiculoFromRequest(request);

        // Asignar cliente al vehículo
        Cliente cliente = clienteDAO.obtenerClientePorId(idCliente);
        if (cliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }
        vehiculo.setIDCliente(cliente);

        // Validaciones
        if (vehiculo.getPlaca() != null && !vehiculo.getPlaca().isEmpty()) {
            if (vehiculoDAO.placaExists(vehiculo.getPlaca())) {
                request.setAttribute("error", "La placa ya está registrada en el sistema");
                request.setAttribute("vehiculo", vehiculo);
                handleRegistrarVehiculoForm(request, response);
                return;
            }
        }

        if (vehiculo.getNumeroChasis() != null && !vehiculo.getNumeroChasis().isEmpty()) {
            if (vehiculoDAO.numeroChasisExists(vehiculo.getNumeroChasis())) {
                request.setAttribute("error", "El número de chasis ya está registrado en el sistema");
                request.setAttribute("vehiculo", vehiculo);
                handleRegistrarVehiculoForm(request, response);
                return;
            }
        }

        // Estado activo por defecto
        if (vehiculo.getEstado() == null) {
            vehiculo.setEstado(true);
        }

        if (vehiculoDAO.crearVehiculo(vehiculo)) {
            request.getSession().setAttribute("mensaje", "Vehículo registrado exitosamente");
            response.sendRedirect(request.getContextPath() + "/cliente/vehiculos/misvehiculos");
        } else {
            request.setAttribute("error", "Error al registrar el vehículo");
            request.setAttribute("vehiculo", vehiculo);

            List<Marca> marcas = marcaDAO.listarMarcasActivas();
            List<Modelo> modelos = modeloDAO.listarModelosActivos();
            request.setAttribute("marcas", marcas);
            request.setAttribute("modelos", modelos);

            request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/form.jsp").forward(request, response);
        }
    }

    private void handleEditarVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("idVehiculo");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de vehículo no especificado");
            return;
        }

        int idVehiculo = Integer.parseInt(idParam);
        Integer idCliente = obtenerIdCliente(request.getSession());

        // Verificar que el vehículo pertenece al cliente
        Vehiculo vehiculoExistente = vehiculoDAO.obtenerVehiculoPorId(idVehiculo);
        if (vehiculoExistente == null || !vehiculoExistente.getIDCliente().getIDCliente().equals(idCliente)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Actualizar campos editables
        Vehiculo vehiculoActualizado = extractVehiculoFromRequest(request);
        vehiculoExistente.setPlaca(vehiculoActualizado.getPlaca());
        vehiculoExistente.setColor(vehiculoActualizado.getColor());
        vehiculoExistente.setAnioVehiculo(vehiculoActualizado.getAnioVehiculo());
        vehiculoExistente.setNumeroChasis(vehiculoActualizado.getNumeroChasis());
        vehiculoExistente.setKilometraje(vehiculoActualizado.getKilometraje());
        vehiculoExistente.setEstado(vehiculoActualizado.getEstado());
        vehiculoExistente.setIDMarca(vehiculoActualizado.getIDMarca());
        vehiculoExistente.setIDModelo(vehiculoActualizado.getIDModelo());

        // Validaciones de unicidad (excluyendo el propio vehículo)
        if (vehiculoExistente.getPlaca() != null && !vehiculoExistente.getPlaca().isEmpty()) {
            Vehiculo vehiculoConMismaPlaca = vehiculoDAO.findByPlaca(vehiculoExistente.getPlaca());
            if (vehiculoConMismaPlaca != null
                    && !vehiculoConMismaPlaca.getIDVehiculo().equals(vehiculoExistente.getIDVehiculo())) {
                request.setAttribute("error", "La placa ya está registrada por otro vehículo");
                request.setAttribute("vehiculo", vehiculoExistente);

                List<Marca> marcas = marcaDAO.listarMarcasActivas();
                List<Modelo> modelos = modeloDAO.listarModelosActivos();
                request.setAttribute("marcas", marcas);
                request.setAttribute("modelos", modelos);

                request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/form.jsp").forward(request, response);
                return;
            }
        }

        if (vehiculoExistente.getNumeroChasis() != null && !vehiculoExistente.getNumeroChasis().isEmpty()) {
            if (vehiculoDAO.numeroChasisExists(vehiculoExistente.getNumeroChasis())) {
                Vehiculo vehiculoConMismoChasis = vehiculoDAO.listarVehiculos().stream()
                        .filter(v -> vehiculoExistente.getNumeroChasis().equals(v.getNumeroChasis()))
                        .findFirst()
                        .orElse(null);

                if (vehiculoConMismoChasis != null
                        && !vehiculoConMismoChasis.getIDVehiculo().equals(vehiculoExistente.getIDVehiculo())) {
                    request.setAttribute("error", "El número de chasis ya está registrado por otro vehículo");
                    request.setAttribute("vehiculo", vehiculoExistente);

                    List<Marca> marcas = marcaDAO.listarMarcasActivas();
                    List<Modelo> modelos = modeloDAO.listarModelosActivos();
                    request.setAttribute("marcas", marcas);
                    request.setAttribute("modelos", modelos);

                    request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/form.jsp").forward(request, response);
                    return;
                }
            }
        }

        if (vehiculoDAO.actualizarVehiculo(vehiculoExistente)) {
            request.getSession().setAttribute("mensaje", "Vehículo actualizado exitosamente");
            response.sendRedirect(request.getContextPath() + "/cliente/vehiculos/misvehiculos");
        } else {
            request.setAttribute("error", "Error al actualizar el vehículo");
            request.setAttribute("vehiculo", vehiculoExistente);

            List<Marca> marcas = marcaDAO.listarMarcasActivas();
            List<Modelo> modelos = modeloDAO.listarModelosActivos();
            request.setAttribute("marcas", marcas);
            request.setAttribute("modelos", modelos);

            request.getRequestDispatcher("/WEB-INF/pages/cliente/vehiculocliente/form.jsp").forward(request, response);
        }
    }

    // Métodos auxiliares
    private Vehiculo extractVehiculoFromRequest(HttpServletRequest request) {
        Vehiculo vehiculo = new Vehiculo();

        String idParam = request.getParameter("idVehiculo");
        if (idParam != null && !idParam.isEmpty()) {
            vehiculo.setIDVehiculo(Integer.parseInt(idParam));
        }

        vehiculo.setPlaca(request.getParameter("placa"));
        vehiculo.setColor(request.getParameter("color"));

        String anioParam = request.getParameter("anioVehiculo");
        if (anioParam != null && !anioParam.isEmpty()) {
            vehiculo.setAnioVehiculo(Integer.parseInt(anioParam));
        }

        vehiculo.setNumeroChasis(request.getParameter("numeroChasis"));

        String kilometrajeParam = request.getParameter("kilometraje");
        if (kilometrajeParam != null && !kilometrajeParam.isEmpty()) {
            vehiculo.setKilometraje(Integer.parseInt(kilometrajeParam));
        }

        String estadoParam = request.getParameter("estado");
        if (estadoParam != null && !estadoParam.isEmpty()) {
            vehiculo.setEstado(Boolean.parseBoolean(estadoParam));
        }

        String idMarcaParam = request.getParameter("idMarca");
        if (idMarcaParam != null && !idMarcaParam.isEmpty()) {
            Marca marca = marcaDAO.obtenerMarcaPorId(Integer.parseInt(idMarcaParam));
            vehiculo.setIDMarca(marca);
        }

        String idModeloParam = request.getParameter("idModelo");
        if (idModeloParam != null && !idModeloParam.isEmpty()) {
            Modelo modelo = modeloDAO.obtenerModeloPorId(Integer.parseInt(idModeloParam));
            vehiculo.setIDModelo(modelo);
        }

        return vehiculo;
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/misvehiculos")) {
            return "misvehiculos";
        }
        if (path.endsWith("/registrar")) {
            return "registrar";
        }
        if (path.endsWith("/editar")) {
            return "editar";
        }
        if (path.endsWith("/ver")) {
            return "ver";
        }
        if (path.endsWith("/historial")) {
            return "historial";
        }
        if (path.endsWith("/dashboard")) {
            return "dashboard";
        }

        return "dashboard";
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/cliente/vehiculos/dashboard");
        }
    }
}
