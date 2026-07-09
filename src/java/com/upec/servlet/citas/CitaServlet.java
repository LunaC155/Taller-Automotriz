package com.upec.servlet.citas;

import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.ClienteDAO;
import com.upec.dao.VehiculoDAO;
import com.upec.model.OrdenServicio;
import com.upec.model.Cliente;
import com.upec.model.Vehiculo;
import com.upec.model.Empleado;
import com.upec.model.EstadoTrabajo;
import jakarta.inject.Inject;
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

@WebServlet(name = "CitaServlet", urlPatterns = {
    "/CitaServlet",
    "/recepcionista/citas",
    "/recepcionista/citas/crear",
    "/recepcionista/citas/editar", 
    "/recepcionista/citas/ver",
    "/recepcionista/citas/cancelar",
    "/recepcionista/citas/calendario",
    "/recepcionista/citas/buscar",
    "/cliente/citas",
    "/cliente/citas/crear", 
    "/cliente/citas/ver",
    "/cliente/citas/cancelar",
    "/cliente/citas/mis-citas"
})
public class CitaServlet extends HttpServlet {

    @Inject
    private OrdenServicioDAO ordenServicioDAO;
    
    @Inject
    private ClienteDAO clienteDAO;
    
    @Inject 
    private VehiculoDAO vehiculoDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // CORRECCIÓN: Obtener idRol como Integer en lugar de rol como String
        Integer idRol = (Integer) session.getAttribute("idRol");
        String path = request.getServletPath();
        
        // Primero verificar si hay parámetro action
        String actionParam = request.getParameter("action");
        String action;
        
        if (actionParam != null && !actionParam.isEmpty()) {
            // Si hay parámetro action, usarlo
            action = actionParam;
        } else {
            // Si no, usar la ruta
            action = getActionFromPath(path);
        }

        try {
            switch (action) {
                case "nueva":
                case "formulario":
                case "crear":
                    handleFormularioCita(request, response, idRol, path);
                    break;
                case "listar":
                    handleListarCitas(request, response, idRol, path);
                    break;
                case "ver":
                    handleVerCita(request, response, idRol, path);
                    break;
                case "calendario":
                    // CORRECCIÓN: Verificar por idRol 3 (recepcionista) en lugar de String
                    if (idRol != null && idRol == 3) {
                        handleCalendarioCitas(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                case "buscar":
                    // CORRECCIÓN: Verificar por idRol 3 (recepcionista)
                    if (idRol != null && idRol == 3) {
                        handleBuscarCitas(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                case "mis-citas":
                    // CORRECCIÓN: Verificar por idRol 4 (cliente)
                    if (idRol != null && idRol == 4) {
                        handleMisCitas(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                default:
                    handleListarCitas(request, response, idRol, path);
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

        // CORRECCIÓN: Usar idRol como Integer
        Integer idRol = (Integer) session.getAttribute("idRol");
        String path = request.getServletPath();
        
        // Primero verificar si hay parámetro action
        String actionParam = request.getParameter("action");
        String action;
        
        if (actionParam != null && !actionParam.isEmpty()) {
            action = actionParam;
        } else {
            action = getActionFromPath(path);
        }

        try {
            switch (action) {
                case "crear":
                case "guardar":
                    handleCrearCita(request, response, idRol);
                    break;
                case "editar":
                case "actualizar":
                    // CORRECCIÓN: Verificar por idRol 3 (recepcionista)
                    if (idRol != null && idRol == 3) {
                        handleEditarCita(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    }
                    break;
                case "cancelar":
                    handleCancelarCita(request, response, idRol);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarCitas(HttpServletRequest request, HttpServletResponse response, 
                                 Integer idRol, String path) throws ServletException, IOException {
        
        List<OrdenServicio> citas;
        
        // CORRECCIÓN: Verificar por idRol en lugar de String
        if (idRol != null && idRol == 3) {
            // Recepcionista - ve todas las citas
            citas = ordenServicioDAO.listarOrdenes();
        } else {
            // Cliente - ve solo sus citas
            citas = obtenerCitasCliente(request);
        }

        request.setAttribute("citas", citas);
        
        String jspPage = determineJspPage(idRol, path, "list");
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleFormularioCita(HttpServletRequest request, HttpServletResponse response,
                                    Integer idRol, String path) throws ServletException, IOException {
        
        List<Vehiculo> vehiculos;
        
        // CORRECCIÓN: Verificar por idRol
        if (idRol != null && idRol == 3) {
            // Recepcionista - ve todos los vehículos activos y clientes
            vehiculos = vehiculoDAO.listarVehiculosActivos();
            List<Cliente> clientes = clienteDAO.listarClientes();
            request.setAttribute("clientes", clientes);
        } else {
            // Cliente - ve solo sus vehículos
            Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
            if (idCliente != null) {
                vehiculos = vehiculoDAO.listarVehiculosPorCliente(idCliente);
            } else {
                vehiculos = List.of();
            }
        }

        request.setAttribute("vehiculos", vehiculos);

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            int id = Integer.parseInt(idParam);
            OrdenServicio cita = ordenServicioDAO.obtenerOrdenPorId(id);
            if (cita != null && tieneAccesoCita(cita, idRol, request)) {
                request.setAttribute("cita", cita);
            }
        }
        
        String jspPage = determineJspPage(idRol, path, "form");
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleVerCita(HttpServletRequest request, HttpServletResponse response,
                             Integer idRol, String path) throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cita no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        OrdenServicio cita = ordenServicioDAO.obtenerOrdenCompleta(id);
        
        if (cita == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cita no encontrada");
            return;
        }

        if (!tieneAccesoCita(cita, idRol, request)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        request.setAttribute("cita", cita);
        String jspPage = determineJspPage(idRol, path, "view");
        request.getRequestDispatcher(jspPage).forward(request, response);
    }

    private void handleCalendarioCitas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fechaParam = request.getParameter("fecha");
        Date fecha = new Date();
        
        if (fechaParam != null && !fechaParam.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                fecha = sdf.parse(fechaParam);
            } catch (ParseException e) {
                // Usar fecha actual si hay error
            }
        }

        List<OrdenServicio> citasDelDia = ordenServicioDAO.listarOrdenesPorFecha(fecha);
        
        request.setAttribute("fechaSeleccionada", fecha);
        request.setAttribute("citas", citasDelDia);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/cita/calendario.jsp").forward(request, response);
    }

    private void handleBuscarCitas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        
        List<OrdenServicio> citas;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            switch (criterio) {
                case "cliente":
                    List<Cliente> clientes = clienteDAO.buscarClientesPorNombre(valor);
                    if (!clientes.isEmpty()) {
                        citas = ordenServicioDAO.listarOrdenesPorCliente(clientes.get(0).getIDCliente());
                    } else {
                        citas = List.of();
                    }
                    break;
                case "vehiculo":
                    List<Vehiculo> vehiculos = vehiculoDAO.buscarVehiculosPorPlaca(valor);
                    if (!vehiculos.isEmpty()) {
                        citas = ordenServicioDAO.listarOrdenesPorVehiculo(vehiculos.get(0).getIDVehiculo());
                    } else {
                        citas = List.of();
                    }
                    break;
                case "problema":
                    citas = ordenServicioDAO.findByProblemaReportadoContaining(valor);
                    break;
                case "todo":
                    // Búsqueda en todos los campos
                    citas = ordenServicioDAO.buscarOrdenesPorCriterio(valor);
                    break;
                default:
                    citas = ordenServicioDAO.listarOrdenes();
            }
        } else {
            citas = ordenServicioDAO.listarOrdenes();
        }

        request.setAttribute("citas", citas);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/cita/list.jsp").forward(request, response);
    }

    private void handleMisCitas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<OrdenServicio> misCitas = obtenerCitasCliente(request);
        
        request.setAttribute("citas", misCitas);
        
        request.getRequestDispatcher("/WEB-INF/pages/cliente/cita/mis-citas.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST

    private void handleCrearCita(HttpServletRequest request, HttpServletResponse response, Integer idRol)
            throws ServletException, IOException {
        
        OrdenServicio cita = extractCitaFromRequest(request, idRol, request.getSession());
        
        // CORRECCIÓN: Verificar por idRol 4 (cliente)
        if (idRol != null && idRol == 4) {
            Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
            if (idCliente != null && !validarVehiculoCliente(cita.getIDVehiculo().getIDVehiculo(), idCliente)) {
                request.setAttribute("error", "No tiene permisos para agendar citas para este vehículo");
                handleFormularioCita(request, response, idRol, request.getServletPath());
                return;
            }
        }

        cita.setFechaEntrada(new Date());

        if (ordenServicioDAO.crearOrden(cita)) {
            request.getSession().setAttribute("mensaje", "Cita agendada exitosamente");
            
            // CORRECCIÓN: Redirigir según idRol
            if (idRol != null && idRol == 3) {
                response.sendRedirect(request.getContextPath() + "/recepcionista/citas");
            } else {
                response.sendRedirect(request.getContextPath() + "/cliente/citas/mis-citas");
            }
        } else {
            request.setAttribute("error", "Error al agendar la cita");
            request.setAttribute("cita", cita);
            handleFormularioCita(request, response, idRol, request.getServletPath());
        }
    }

    private void handleEditarCita(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("idOrdenServicio");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cita no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        OrdenServicio citaExistente = ordenServicioDAO.obtenerOrdenPorId(id);
        
        if (citaExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cita no encontrada");
            return;
        }

        OrdenServicio citaActualizada = extractCitaFromRequest(request, 3, request.getSession()); // 3 = recepcionista
        citaExistente.setIDVehiculo(citaActualizada.getIDVehiculo());
        citaExistente.setFechaEstimadaSalida(citaActualizada.getFechaEstimadaSalida());
        citaExistente.setProblemaReportado(citaActualizada.getProblemaReportado());
        citaExistente.setObservaciones(citaActualizada.getObservaciones());

        if (ordenServicioDAO.actualizarOrden(citaExistente)) {
            request.getSession().setAttribute("mensaje", "Cita actualizada exitosamente");
            response.sendRedirect(request.getContextPath() + "/recepcionista/citas");
        } else {
            request.setAttribute("error", "Error al actualizar la cita");
            request.setAttribute("cita", citaExistente);
            
            List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculosActivos();
            List<Cliente> clientes = clienteDAO.listarClientes();
            request.setAttribute("vehiculos", vehiculos);
            request.setAttribute("clientes", clientes);
            
            request.getRequestDispatcher("/WEB-INF/pages/recepcionista/cita/form.jsp").forward(request, response);
        }
    }

    private void handleCancelarCita(HttpServletRequest request, HttpServletResponse response, Integer idRol)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cita no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        OrdenServicio cita = ordenServicioDAO.obtenerOrdenPorId(id);
        
        if (cita == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cita no encontrada");
            return;
        }

        if (!tieneAccesoCita(cita, idRol, request)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        boolean resultado = ordenServicioDAO.actualizarEstadoOrden(id, obtenerIdEstadoCancelado());

        if (resultado) {
            request.getSession().setAttribute("mensaje", "Cita cancelada exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al cancelar la cita");
        }
        
        // CORRECCIÓN: Redirigir según idRol
        if (idRol != null && idRol == 3) {
            response.sendRedirect(request.getContextPath() + "/recepcionista/citas");
        } else {
            response.sendRedirect(request.getContextPath() + "/cliente/citas/mis-citas");
        }
    }

    // Métodos auxiliares

    private OrdenServicio extractCitaFromRequest(HttpServletRequest request, Integer idRol, HttpSession session) {
        OrdenServicio cita = new OrdenServicio();
        
        String idParam = request.getParameter("idOrdenServicio");
        if (idParam != null && !idParam.isEmpty()) {
            cita.setIDOrdenServicio(Integer.parseInt(idParam));
        }
        
        String idVehiculoParam = request.getParameter("idVehiculo");
        if (idVehiculoParam != null && !idVehiculoParam.isEmpty()) {
            Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(Integer.parseInt(idVehiculoParam));
            cita.setIDVehiculo(vehiculo);
        }
        
        // CORRECCIÓN: Asignar empleado recepcionista según el rol
        if (idRol != null && idRol == 3) {
            // Recepcionista - puede asignarse a sí mismo u otro recepcionista
            String idEmpleadoParam = request.getParameter("idEmpleadoRecepcion");
            if (idEmpleadoParam != null && !idEmpleadoParam.isEmpty()) {
                Empleado empleado = new Empleado();
                empleado.setIDEmpleado(Integer.parseInt(idEmpleadoParam));
                cita.setIDEmpleadoRecepcion(empleado);
            } else {
                // Si no se especifica, usar el recepcionista actual
                Integer idEmpleado = (Integer) session.getAttribute("idEmpleado");
                if (idEmpleado != null) {
                    Empleado empleado = new Empleado();
                    empleado.setIDEmpleado(idEmpleado);
                    cita.setIDEmpleadoRecepcion(empleado);
                }
            }
        } else {
            // Cliente - se asigna automáticamente un recepcionista
            Integer idEmpleado = (Integer) session.getAttribute("idEmpleado");
            if (idEmpleado != null) {
                Empleado empleado = new Empleado();
                empleado.setIDEmpleado(idEmpleado);
                cita.setIDEmpleadoRecepcion(empleado);
            }
        }
        
        EstadoTrabajo estado = new EstadoTrabajo();
        estado.setIDEstadoTrabajo(obtenerIdEstadoPendiente());
        cita.setIDEstadoTrabajo(estado);
        
        String fechaEstimadaStr = request.getParameter("fechaEstimadaSalida");
        if (fechaEstimadaStr != null && !fechaEstimadaStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaEstimada = sdf.parse(fechaEstimadaStr);
                cita.setFechaEstimadaSalida(fechaEstimada);
            } catch (ParseException e) {
                // Si hay error, no se asigna fecha
            }
        }
        
        cita.setProblemaReportado(request.getParameter("problemaReportado"));
        cita.setObservaciones(request.getParameter("observaciones"));

        return cita;
    }

    private List<OrdenServicio> obtenerCitasCliente(HttpServletRequest request) {
        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
        if (idCliente != null) {
            return ordenServicioDAO.listarOrdenesPorCliente(idCliente);
        }
        return List.of();
    }

    private boolean tieneAccesoCita(OrdenServicio cita, Integer idRol, HttpServletRequest request) {
        // CORRECCIÓN: Verificar por idRol
        if (idRol != null && idRol == 3) {
            return true; // Recepcionista tiene acceso a todas las citas
        } else if (idRol != null && idRol == 4) {
            // Cliente - solo acceso a sus citas
            Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
            return idCliente != null && 
                   cita.getIDVehiculo() != null && 
                   cita.getIDVehiculo().getIDCliente() != null &&
                   cita.getIDVehiculo().getIDCliente().getIDCliente().equals(idCliente);
        }
        return false;
    }

    private boolean validarVehiculoCliente(Integer idVehiculo, Integer idCliente) {
        if (idVehiculo == null || idCliente == null) {
            return false;
        }
        
        Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(idVehiculo);
        return vehiculo != null && 
               vehiculo.getIDCliente() != null && 
               vehiculo.getIDCliente().getIDCliente().equals(idCliente);
    }

    private int obtenerIdEstadoPendiente() {
        return 1; // Asumiendo que 1 es el ID para estado "PENDIENTE"
    }

    private int obtenerIdEstadoCancelado() {
        return 4; // Asumiendo que 4 es el ID para estado "CANCELADO"
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/crear")) return "formulario";
        if (path.endsWith("/editar")) return "formulario";
        if (path.endsWith("/ver")) return "ver";
        if (path.endsWith("/cancelar")) return "cancelar";
        if (path.endsWith("/calendario")) return "calendario";
        if (path.endsWith("/buscar")) return "buscar";
        if (path.endsWith("/mis-citas")) return "mis-citas";
        
        return "listar";
    }

    private String determineJspPage(Integer idRol, String path, String action) {
        String basePath = "/WEB-INF/pages/";
        
        // CORRECCIÓN: Determinar según idRol y path
        if ((idRol != null && idRol == 3) || path.contains("/recepcionista/")) {
            return basePath + "recepcionista/cita/" + action + ".jsp";
        } else if ((idRol != null && idRol == 4) || path.contains("/cliente/")) {
            return basePath + "cliente/cita/" + action + ".jsp";
        }
        
        // Por defecto usar recepcionista si no hay ruta específica y el rol es recepcionista
        if (idRol != null && idRol == 3) {
            return basePath + "recepcionista/cita/" + action + ".jsp";
        } else {
            return basePath + "cliente/cita/" + action + ".jsp";
        }
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, 
                           Exception e, String errorMessage) throws ServletException, IOException {
        
        e.printStackTrace();
        request.setAttribute("error", errorMessage);
        
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        }
    }
}