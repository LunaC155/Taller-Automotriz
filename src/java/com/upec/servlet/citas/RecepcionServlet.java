package com.upec.servlet.citas;

import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.VehiculoDAO;
import com.upec.dao.EmpleadoDAO;
import com.upec.model.OrdenServicio;
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

@WebServlet(name = "RecepcionServlet", urlPatterns = {
    "/RecepcionServlet",
    "/recepcionista/recepcion",
    "/recepcionista/recepcion/registrar",
    "/recepcionista/recepcion/ver",
    "/recepcionista/recepcion/editar",
    "/recepcionista/recepcion/buscar",
    "/recepcionista/recepcion/hoy",
    "/recepcionista/recepcion/pendientes"
})
public class RecepcionServlet extends HttpServlet {

    @Inject
    private OrdenServicioDAO ordenServicioDAO;
    
    @Inject
    private VehiculoDAO vehiculoDAO;
    
    @Inject
    private EmpleadoDAO empleadoDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("rol");
        if (!"recepcionista".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "listar":
                    handleListarRecepciones(request, response);
                    break;
                case "registrar":
                    handleRegistrarRecepcionForm(request, response);
                    break;
                case "ver":
                    handleVerRecepcion(request, response);
                    break;
                case "editar":
                    handleEditarRecepcionForm(request, response);
                    break;
                case "buscar":
                    handleBuscarRecepciones(request, response);
                    break;
                case "hoy":
                    handleRecepcionesHoy(request, response);
                    break;
                case "pendientes":
                    handleRecepcionesPendientes(request, response);
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
        if (!"recepcionista".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "registrar":
                    handleRegistrarRecepcion(request, response);
                    break;
                case "editar":
                    handleEditarRecepcion(request, response);
                    break;
                case "buscar":
                    handleBuscarRecepciones(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarRecepciones(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<OrdenServicio> recepciones = ordenServicioDAO.listarOrdenes();
        
        // Obtener estadísticas para el dashboard
        int totalRecepciones = recepciones.size();
        int recepcionesPendientes = ordenServicioDAO.listarOrdenesPendientes().size();
        int recepcionesHoy = ordenServicioDAO.listarOrdenesPorFecha(new Date()).size();

        request.setAttribute("recepciones", recepciones);
        request.setAttribute("totalRecepciones", totalRecepciones);
        request.setAttribute("recepcionesPendientes", recepcionesPendientes);
        request.setAttribute("recepcionesHoy", recepcionesHoy);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/list.jsp").forward(request, response);
    }

    private void handleRegistrarRecepcionForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Cargar datos necesarios para el formulario
        List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos();
        List<Empleado> mecanicosDisponibles = empleadoDAO.listarMecanicosDisponibles();

        request.setAttribute("vehiculos", vehiculosDisponibles);
        request.setAttribute("mecanicos", mecanicosDisponibles);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/form.jsp").forward(request, response);
    }

    private void handleVerRecepcion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de recepción no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        OrdenServicio recepcion = ordenServicioDAO.obtenerOrdenCompleta(id);
        
        if (recepcion == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Recepción no encontrada");
            return;
        }

        request.setAttribute("recepcion", recepcion);
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/view.jsp").forward(request, response);
    }

    private void handleEditarRecepcionForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de recepción no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        OrdenServicio recepcion = ordenServicioDAO.obtenerOrdenPorId(id);
        
        if (recepcion == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Recepción no encontrada");
            return;
        }

        // Cargar datos necesarios para el formulario
        List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos();
        List<Empleado> mecanicosDisponibles = empleadoDAO.listarMecanicosDisponibles();

        request.setAttribute("recepcion", recepcion);
        request.setAttribute("vehiculos", vehiculosDisponibles);
        request.setAttribute("mecanicos", mecanicosDisponibles);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/form.jsp").forward(request, response);
    }

    private void handleBuscarRecepciones(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        
        List<OrdenServicio> recepciones;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            switch (criterio) {
                case "placa":
                    List<Vehiculo> vehiculos = vehiculoDAO.buscarVehiculosPorPlaca(valor);
                    if (!vehiculos.isEmpty()) {
                        recepciones = ordenServicioDAO.listarOrdenesPorVehiculo(vehiculos.get(0).getIDVehiculo());
                    } else {
                        recepciones = List.of();
                    }
                    break;
                case "problema":
                    recepciones = ordenServicioDAO.findByProblemaReportadoContaining(valor);
                    break;
                case "cliente":
                    // Buscar por nombre de cliente
                    recepciones = ordenServicioDAO.buscarOrdenesPorCriterio(valor);
                    break;
                default:
                    recepciones = ordenServicioDAO.listarOrdenes();
            }
        } else {
            recepciones = ordenServicioDAO.listarOrdenes();
        }

        request.setAttribute("recepciones", recepciones);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/list.jsp").forward(request, response);
    }

    private void handleRecepcionesHoy(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<OrdenServicio> recepcionesHoy = ordenServicioDAO.listarOrdenesPorFecha(new Date());
        
        request.setAttribute("recepciones", recepcionesHoy);
        request.setAttribute("filtro", "hoy");
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/list.jsp").forward(request, response);
    }

    private void handleRecepcionesPendientes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<OrdenServicio> recepcionesPendientes = ordenServicioDAO.listarOrdenesPendientes();
        
        request.setAttribute("recepciones", recepcionesPendientes);
        request.setAttribute("filtro", "pendientes");
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/list.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST

    private void handleRegistrarRecepcion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        OrdenServicio recepcion = extractRecepcionFromRequest(request);
        
        // Asignar empleado de recepción (usuario actual)
        Integer idRecepcionista = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idRecepcionista != null) {
            Empleado recepcionista = empleadoDAO.obtenerEmpleadoPorId(idRecepcionista);
            recepcion.setIDEmpleadoRecepcion(recepcionista);
        }

        // Fecha de entrada actual
        recepcion.setFechaEntrada(new Date());

        // Asignar estado inicial (PENDIENTE)
        EstadoTrabajo estadoPendiente = new EstadoTrabajo();
        estadoPendiente.setIDEstadoTrabajo(1); // Asumiendo que 1 es PENDIENTE
        recepcion.setIDEstadoTrabajo(estadoPendiente);

        // Validar que el vehículo esté disponible
        if (recepcion.getIDVehiculo() != null) {
            boolean disponible = vehiculoDAO.verificarDisponibilidadVehiculo(recepcion.getIDVehiculo().getIDVehiculo());
            if (!disponible) {
                request.setAttribute("error", "El vehículo seleccionado ya tiene una recepción activa");
                
                // Recargar datos para el formulario
                List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos();
                List<Empleado> mecanicosDisponibles = empleadoDAO.listarMecanicosDisponibles();
                request.setAttribute("vehiculos", vehiculosDisponibles);
                request.setAttribute("mecanicos", mecanicosDisponibles);
                request.setAttribute("recepcion", recepcion);
                
                request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/form.jsp").forward(request, response);
                return;
            }
        }

        if (ordenServicioDAO.crearOrden(recepcion)) {
            request.getSession().setAttribute("mensaje", "Recepción registrada exitosamente");
            response.sendRedirect(request.getContextPath() + "/recepcionista/recepcion");
        } else {
            request.setAttribute("error", "Error al registrar la recepción");
            request.setAttribute("recepcion", recepcion);
            
            // Recargar datos para el formulario
            List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos();
            List<Empleado> mecanicosDisponibles = empleadoDAO.listarMecanicosDisponibles();
            request.setAttribute("vehiculos", vehiculosDisponibles);
            request.setAttribute("mecanicos", mecanicosDisponibles);
            
            request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/form.jsp").forward(request, response);
        }
    }

    private void handleEditarRecepcion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("idOrdenServicio");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de recepción no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        OrdenServicio recepcionExistente = ordenServicioDAO.obtenerOrdenPorId(id);
        
        if (recepcionExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Recepción no encontrada");
            return;
        }

        // Actualizar campos editables
        OrdenServicio recepcionActualizada = extractRecepcionFromRequest(request);
        
        // Obtener el vehículo actualizado
        String idVehiculoParam = request.getParameter("idVehiculo");
        if (idVehiculoParam != null && !idVehiculoParam.isEmpty()) {
            Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(Integer.parseInt(idVehiculoParam));
            recepcionExistente.setIDVehiculo(vehiculo);
        }
        
        // Actualizar otros campos
        recepcionExistente.setFechaEstimadaSalida(recepcionActualizada.getFechaEstimadaSalida());
        recepcionExistente.setProblemaReportado(recepcionActualizada.getProblemaReportado());
        recepcionExistente.setObservaciones(recepcionActualizada.getObservaciones());

        // Validar disponibilidad del vehículo (si se cambió)
        if (recepcionExistente.getIDVehiculo() != null) {
            boolean disponible = vehiculoDAO.verificarDisponibilidadVehiculo(recepcionExistente.getIDVehiculo().getIDVehiculo());
            if (!disponible) {
                // Verificar si es el mismo vehículo (entonces está bien)
                if (recepcionActualizada.getIDVehiculo() == null || 
                    !recepcionExistente.getIDVehiculo().getIDVehiculo().equals(recepcionActualizada.getIDVehiculo().getIDVehiculo())) {
                    
                    request.setAttribute("error", "El vehículo seleccionado ya tiene una recepción activa");
                    request.setAttribute("recepcion", recepcionExistente);
                    
                    List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos();
                    List<Empleado> mecanicosDisponibles = empleadoDAO.listarMecanicosDisponibles();
                    request.setAttribute("vehiculos", vehiculosDisponibles);
                    request.setAttribute("mecanicos", mecanicosDisponibles);
                    
                    request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/form.jsp").forward(request, response);
                    return;
                }
            }
        }

        if (ordenServicioDAO.actualizarOrden(recepcionExistente)) {
            request.getSession().setAttribute("mensaje", "Recepción actualizada exitosamente");
            response.sendRedirect(request.getContextPath() + "/recepcionista/recepcion");
        } else {
            request.setAttribute("error", "Error al actualizar la recepción");
            request.setAttribute("recepcion", recepcionExistente);
            
            // Recargar datos para el formulario
            List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos();
            List<Empleado> mecanicosDisponibles = empleadoDAO.listarMecanicosDisponibles();
            request.setAttribute("vehiculos", vehiculosDisponibles);
            request.setAttribute("mecanicos", mecanicosDisponibles);
            
            request.getRequestDispatcher("/WEB-INF/pages/recepcionista/recepcion/form.jsp").forward(request, response);
        }
    }

    // Métodos auxiliares

    private OrdenServicio extractRecepcionFromRequest(HttpServletRequest request) {
        OrdenServicio recepcion = new OrdenServicio();
        
        String idParam = request.getParameter("idOrdenServicio");
        if (idParam != null && !idParam.isEmpty()) {
            recepcion.setIDOrdenServicio(Integer.parseInt(idParam));
        }
        
        // Vehículo
        String idVehiculoParam = request.getParameter("idVehiculo");
        if (idVehiculoParam != null && !idVehiculoParam.isEmpty()) {
            Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(Integer.parseInt(idVehiculoParam));
            recepcion.setIDVehiculo(vehiculo);
        }
        
        // Fecha estimada de salida
        String fechaEstimadaStr = request.getParameter("fechaEstimadaSalida");
        if (fechaEstimadaStr != null && !fechaEstimadaStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaEstimada = sdf.parse(fechaEstimadaStr);
                recepcion.setFechaEstimadaSalida(fechaEstimada);
            } catch (ParseException e) {
                // Si hay error, no se asigna fecha
            }
        }
        
        // Campos de texto
        recepcion.setProblemaReportado(request.getParameter("problemaReportado"));
        recepcion.setObservaciones(request.getParameter("observaciones"));

        return recepcion;
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/registrar")) return "registrar";
        if (path.endsWith("/ver")) return "ver";
        if (path.endsWith("/editar")) return "editar";
        if (path.endsWith("/buscar")) return "buscar";
        if (path.endsWith("/hoy")) return "hoy";
        if (path.endsWith("/pendientes")) return "pendientes";
        
        return "listar"; // Por defecto para GET en URLs base
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, 
                           Exception e, String errorMessage) throws ServletException, IOException {
        
        e.printStackTrace();
        request.setAttribute("error", errorMessage);
        
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/recepcionista/recepcion");
        }
    }
}