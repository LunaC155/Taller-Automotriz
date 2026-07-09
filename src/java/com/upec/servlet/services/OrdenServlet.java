package com.upec.servlet.services;

import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.VehiculoDAO;
import com.upec.dao.EstadoTrabajoDAO;
import com.upec.dao.EmpleadoDAO;
import com.upec.model.OrdenServicio;
import com.upec.model.Vehiculo;
import com.upec.model.EstadoTrabajo;
import com.upec.model.Empleado;
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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "OrdenServlet", urlPatterns = {
    "/OrdenServlet",
    "/recepcionista/ordenes",
    "/recepcionista/ordenes/crear",
    "/recepcionista/ordenes/editar",
    "/recepcionista/ordenes/ver",
    "/recepcionista/ordenes/buscar",
    "/recepcionista/ordenes/asignar-vehiculo",
    "/mecanico/ordenes",
    "/mecanico/ordenes/ver",
    "/mecanico/ordenes/actualizar-estado",
    "/mecanico/ordenes/registrar-avance"
})
public class OrdenServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrdenServlet.class.getName());
    private static final String ATTR_ORDENES = "ordenes";
    private static final String ATTR_ORDEN = "orden";
    private static final String ATTR_ERROR = "error";
    private static final String ATTR_MENSAJE = "mensaje";
    private static final String PARAM_ID = "id";
    private static final String PARAM_ID_ORDEN = "idOrdenServicio";
    
    @Inject
    private OrdenServicioDAO ordenServicioDAO;

    @Inject
    private VehiculoDAO vehiculoDAO;

    @Inject
    private EstadoTrabajoDAO estadoTrabajoDAO;

    @Inject
    private EmpleadoDAO empleadoDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!validarSesion(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);
        Integer idRol = (Integer) session.getAttribute("idRol");
        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "listar":
                    handleListarOrdenes(request, response, idRol, path);
                    break;
                case "formulario":
                    handleFormularioOrden(request, response, idRol, path);
                    break;
                case "ver":
                    handleVerOrden(request, response, idRol, path);
                    break;
                case "buscar":
                    handleBuscarOrdenes(request, response, idRol, path);
                    break;
                case "asignar-vehiculo":
                    if (validarRol(idRol, 3, request, response)) {
                        handleAsignarVehiculoForm(request, response);
                    }
                    break;
                case "actualizar-estado":
                    if (validarRol(idRol, 2, request, response)) {
                        handleActualizarEstadoForm(request, response);
                    }
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!validarSesion(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);
        Integer idRol = (Integer) session.getAttribute("idRol");
        String action = getActionFromPath(request.getServletPath());

        try {
            switch (action) {
                case "crear":
                    if (validarRol(idRol, 3, request, response)) {
                        handleCrearOrden(request, response);
                    }
                    break;
                case "editar":
                    if (validarRol(idRol, 3, request, response)) {
                        handleEditarOrden(request, response);
                    }
                    break;
                case "asignar-vehiculo":
                    if (validarRol(idRol, 3, request, response)) {
                        handleAsignarVehiculo(request, response);
                    }
                    break;
                case "actualizar-estado":
                    if (validarRol(idRol, 2, request, response)) {
                        handleActualizarEstado(request, response);
                    }
                    break;
                case "registrar-avance":
                    if (validarRol(idRol, 2, request, response)) {
                        handleRegistrarAvance(request, response);
                    }
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud");
        }
    }

    // ==================== MÉTODOS GET ====================

    private void handleListarOrdenes(HttpServletRequest request, HttpServletResponse response, 
                                   Integer idRol, String path) throws ServletException, IOException {
        try {
            List<OrdenServicio> ordenes;
            
            if (idRol != null && idRol == 2) { // Mecánico
                Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
                ordenes = idMecanico != null ? 
                    ordenServicioDAO.listarOrdenesPorMecanico(idMecanico) : 
                    List.of();
            } else if (idRol != null && idRol == 3) { // Recepcionista
                ordenes = ordenServicioDAO.listarOrdenesConDetallesCompletos();
            } else {
                // Rol no reconocido, redirigir a acceso denegado
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            request.setAttribute(ATTR_ORDENES, ordenes);
            forwardToJsp(request, response, idRol, path, "list");
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error listando órdenes", e);
            throw new ServletException("Error al listar órdenes", e);
        }
    }

    private void handleFormularioOrden(HttpServletRequest request, HttpServletResponse response,
                                     Integer idRol, String path) throws ServletException, IOException {
        try {
            // Solo recepcionista puede acceder a formularios
            if (!validarRol(idRol, 3, request, response)) {
                return;
            }

            List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculosConDetallesCompletos();
            List<EstadoTrabajo> estados = estadoTrabajoDAO.listarEstadosParaOrdenes();
            
            request.setAttribute("vehiculos", vehiculos);
            request.setAttribute("estados", estados);

            String idParam = request.getParameter(PARAM_ID);
            if (idParam != null && !idParam.trim().isEmpty()) {
                int id = Integer.parseInt(idParam);
                OrdenServicio orden = ordenServicioDAO.obtenerOrdenCompleta(id);
                if (orden != null) {
                    request.setAttribute(ATTR_ORDEN, orden);
                } else {
                    request.setAttribute(ATTR_ERROR, "Orden no encontrada");
                }
            }
            
            forwardToJsp(request, response, idRol, path, "form");
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ID de orden inválido", e);
            request.setAttribute(ATTR_ERROR, "ID de orden inválido");
            forwardToJsp(request, response, idRol, path, "form");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error cargando formulario", e);
            throw new ServletException("Error al cargar formulario", e);
        }
    }

    private void handleVerOrden(HttpServletRequest request, HttpServletResponse response,
                              Integer idRol, String path) throws ServletException, IOException {
        try {
            String idParam = request.getParameter(PARAM_ID);
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
                return;
            }

            int id = Integer.parseInt(idParam);
            OrdenServicio orden;
            
            if (idRol != null && idRol == 2) { // Mecánico
                Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
                orden = verificarAccesoMecanicoOrden(id, idMecanico);
                if (orden == null) {
                    response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                    return;
                }
            } else if (idRol != null && idRol == 3) { // Recepcionista
                orden = ordenServicioDAO.obtenerOrdenCompleta(id);
            } else {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            if (orden == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Orden no encontrada");
                return;
            }

            request.setAttribute(ATTR_ORDEN, orden);
            forwardToJsp(request, response, idRol, path, "view");
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ID de orden inválido", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden inválido");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error obteniendo orden", e);
            throw new ServletException("Error al obtener orden", e);
        }
    }

    private void handleBuscarOrdenes(HttpServletRequest request, HttpServletResponse response,
                                   Integer idRol, String path) throws ServletException, IOException {
        try {
            String criterio = request.getParameter("criterio");
            String valor = request.getParameter("valor");
            
            List<OrdenServicio> ordenes;

            if (criterio != null && valor != null && !valor.trim().isEmpty()) {
                ordenes = ordenServicioDAO.buscarOrdenesPorCriterio(valor);
            } else {
                ordenes = ordenServicioDAO.listarOrdenesConDetallesCompletos();
            }

            // Filtrar por mecánico si es necesario
            if (idRol != null && idRol == 2) { // Mecánico
                Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
                if (idMecanico != null) {
                    final Integer finalIdMecanico = idMecanico;
                    ordenes = ordenes.stream()
                        .filter(orden -> orden.getDiagnosticoList() != null && 
                            orden.getDiagnosticoList().stream()
                                .anyMatch(diagnostico -> 
                                    diagnostico.getIDEmpleadoMecanico() != null &&
                                    diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(finalIdMecanico)))
                        .toList();
                }
            } else if (idRol != null && idRol != 3) { // No es recepcionista
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            request.setAttribute(ATTR_ORDENES, ordenes);
            request.setAttribute("criterio", criterio);
            request.setAttribute("valor", valor);
            
            forwardToJsp(request, response, idRol, path, "list");
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error buscando órdenes", e);
            throw new ServletException("Error al buscar órdenes", e);
        }
    }

    private void handleAsignarVehiculoForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter(PARAM_ID);
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
                return;
            }

            int id = Integer.parseInt(idParam);
            OrdenServicio orden = ordenServicioDAO.obtenerOrdenCompleta(id);
            
            if (orden == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Orden no encontrada");
                return;
            }

            List<Vehiculo> vehiculosDisponibles = vehiculoDAO.listarVehiculosActivos().stream()
                .filter(vehiculo -> vehiculoDAO.verificarDisponibilidadVehiculo(vehiculo.getIDVehiculo()))
                .toList();

            request.setAttribute(ATTR_ORDEN, orden);
            request.setAttribute("vehiculos", vehiculosDisponibles);
            
            forwardToJsp(request, response, 3, request.getServletPath(), "asignar-vehiculo");
                   
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ID inválido", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error cargando formulario de asignación", e);
            throw new ServletException("Error al cargar formulario", e);
        }
    }

    private void handleActualizarEstadoForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter(PARAM_ID);
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
                return;
            }

            int id = Integer.parseInt(idParam);
            Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
            
            OrdenServicio orden = verificarAccesoMecanicoOrden(id, idMecanico);
            if (orden == null) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            List<EstadoTrabajo> estados = estadoTrabajoDAO.obtenerSiguientesEstados(
                orden.getIDEstadoTrabajo() != null ? orden.getIDEstadoTrabajo().getIDEstadoTrabajo() : 0
            );

            request.setAttribute(ATTR_ORDEN, orden);
            request.setAttribute("estados", estados);
            
            forwardToJsp(request, response, 2, request.getServletPath(), "actualizar-estado");
                   
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ID inválido", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error cargando formulario de actualización", e);
            throw new ServletException("Error al cargar formulario", e);
        }
    }

    // ==================== MÉTODOS POST ====================

    private void handleCrearOrden(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            OrdenServicio orden = extractOrdenFromRequest(request);
            
            // Asignar empleado de recepción
            Integer idRecepcionista = (Integer) request.getSession().getAttribute("idEmpleado");
            if (idRecepcionista != null) {
                Empleado recepcionista = empleadoDAO.obtenerEmpleadoPorId(idRecepcionista);
                orden.setIDEmpleadoRecepcion(recepcionista);
            }

            // Asignar estado PENDIENTE por defecto
            if (orden.getIDEstadoTrabajo() == null) {
                EstadoTrabajo estadoPendiente = estadoTrabajoDAO.obtenerEstadoPendiente();
                orden.setIDEstadoTrabajo(estadoPendiente);
            }

            orden.setFechaEntrada(new Date());

            if (ordenServicioDAO.crearOrden(orden)) {
                request.getSession().setAttribute(ATTR_MENSAJE, "Orden creada exitosamente");
                response.sendRedirect(request.getContextPath() + "/recepcionista/ordenes");
            } else {
                mostrarFormularioConError(request, response, "Error al crear la orden", orden);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creando orden", e);
            mostrarFormularioConError(request, response, "Error al procesar la orden: " + e.getMessage(), null);
        }
    }

    private void handleEditarOrden(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter(PARAM_ID_ORDEN);
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
                return;
            }

            int id = Integer.parseInt(idParam);
            OrdenServicio ordenExistente = ordenServicioDAO.obtenerOrdenCompleta(id);
            
            if (ordenExistente == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Orden no encontrada");
                return;
            }

            // Actualizar solo campos editables
            OrdenServicio ordenActualizada = extractOrdenFromRequest(request);
            ordenExistente.setIDVehiculo(ordenActualizada.getIDVehiculo());
            ordenExistente.setFechaEstimadaSalida(ordenActualizada.getFechaEstimadaSalida());
            ordenExistente.setProblemaReportado(ordenActualizada.getProblemaReportado());
            ordenExistente.setObservaciones(ordenActualizada.getObservaciones());

            if (ordenServicioDAO.actualizarOrden(ordenExistente)) {
                request.getSession().setAttribute(ATTR_MENSAJE, "Orden actualizada exitosamente");
                response.sendRedirect(request.getContextPath() + "/recepcionista/ordenes");
            } else {
                mostrarFormularioConError(request, response, "Error al actualizar la orden", ordenExistente);
            }
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ID inválido", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error actualizando orden", e);
            mostrarFormularioConError(request, response, "Error al procesar la actualización", null);
        }
    }

    private void handleAsignarVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idOrdenParam = request.getParameter(PARAM_ID_ORDEN);
            String idVehiculoParam = request.getParameter("idVehiculo");
            
            if (idOrdenParam == null || idVehiculoParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
                return;
            }

            int idOrden = Integer.parseInt(idOrdenParam);
            int idVehiculo = Integer.parseInt(idVehiculoParam);

            if (ordenServicioDAO.asignarVehiculoAOrden(idOrden, idVehiculo)) {
                request.getSession().setAttribute(ATTR_MENSAJE, "Vehículo asignado exitosamente");
            } else {
                request.getSession().setAttribute(ATTR_ERROR, "Error al asignar el vehículo");
            }
            
            response.sendRedirect(request.getContextPath() + "/recepcionista/ordenes");
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "IDs inválidos", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "IDs inválidos");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error asignando vehículo", e);
            request.getSession().setAttribute(ATTR_ERROR, "Error al asignar vehículo");
            response.sendRedirect(request.getContextPath() + "/recepcionista/ordenes");
        }
    }

    private void handleActualizarEstado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idOrdenParam = request.getParameter(PARAM_ID_ORDEN);
            String idEstadoParam = request.getParameter("idEstadoTrabajo");
            
            if (idOrdenParam == null || idEstadoParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
                return;
            }

            int idOrden = Integer.parseInt(idOrdenParam);
            int idEstado = Integer.parseInt(idEstadoParam);
            
            // Verificar acceso
            Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
            if (verificarAccesoMecanicoOrden(idOrden, idMecanico) == null) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            if (ordenServicioDAO.actualizarEstadoOrden(idOrden, idEstado)) {
                request.getSession().setAttribute(ATTR_MENSAJE, "Estado actualizado exitosamente");
            } else {
                request.getSession().setAttribute(ATTR_ERROR, "Error al actualizar el estado");
            }
            
            response.sendRedirect(request.getContextPath() + "/mecanico/ordenes");
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "IDs inválidos", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "IDs inválidos");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error actualizando estado", e);
            request.getSession().setAttribute(ATTR_ERROR, "Error al actualizar estado");
            response.sendRedirect(request.getContextPath() + "/mecanico/ordenes");
        }
    }

    private void handleRegistrarAvance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idOrdenParam = request.getParameter(PARAM_ID_ORDEN);
            String observaciones = request.getParameter("observaciones");
            
            if (idOrdenParam == null || idOrdenParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
                return;
            }

            int idOrden = Integer.parseInt(idOrdenParam);
            
            // Verificar acceso
            Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
            OrdenServicio orden = verificarAccesoMecanicoOrden(idOrden, idMecanico);
            if (orden == null) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            // Actualizar observaciones
            if (observaciones != null && !observaciones.trim().isEmpty()) {
                String observacionesActuales = orden.getObservaciones();
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                String timestamp = sdf.format(new Date());
                
                String nuevasObservaciones = observacionesActuales != null && !observacionesActuales.trim().isEmpty() ? 
                    observacionesActuales + "\n--- " + timestamp + " ---\n" + observaciones : 
                    "--- " + timestamp + " ---\n" + observaciones;
                    
                orden.setObservaciones(nuevasObservaciones);
                
                if (ordenServicioDAO.actualizarOrden(orden)) {
                    request.getSession().setAttribute(ATTR_MENSAJE, "Avance registrado exitosamente");
                } else {
                    request.getSession().setAttribute(ATTR_ERROR, "Error al registrar el avance");
                }
            } else {
                request.getSession().setAttribute(ATTR_ERROR, "Las observaciones no pueden estar vacías");
            }
            
            response.sendRedirect(request.getContextPath() + "/mecanico/ordenes/ver?id=" + idOrden);
            
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "ID inválido", e);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error registrando avance", e);
            request.getSession().setAttribute(ATTR_ERROR, "Error al registrar avance");
            response.sendRedirect(request.getContextPath() + "/mecanico/ordenes");
        }
    }

    // ==================== MÉTODOS AUXILIARES ====================

    private boolean validarSesion(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null || session.getAttribute("idRol") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private boolean validarRol(Integer idRol, Integer rolRequerido, 
                              HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        if (idRol == null || !rolRequerido.equals(idRol)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return false;
        }
        return true;
    }

    private OrdenServicio extractOrdenFromRequest(HttpServletRequest request) {
        OrdenServicio orden = new OrdenServicio();
        
        String idParam = request.getParameter(PARAM_ID_ORDEN);
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                orden.setIDOrdenServicio(Integer.parseInt(idParam));
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "ID de orden inválido: " + idParam, e);
            }
        }
        
        // Vehículo
        String idVehiculoParam = request.getParameter("idVehiculo");
        if (idVehiculoParam != null && !idVehiculoParam.trim().isEmpty()) {
            try {
                Vehiculo vehiculo = vehiculoDAO.obtenerVehiculoPorId(Integer.parseInt(idVehiculoParam));
                orden.setIDVehiculo(vehiculo);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "ID de vehículo inválido: " + idVehiculoParam, e);
            }
        }
        
        // Estado de trabajo
        String idEstadoParam = request.getParameter("idEstadoTrabajo");
        if (idEstadoParam != null && !idEstadoParam.trim().isEmpty()) {
            try {
                EstadoTrabajo estado = estadoTrabajoDAO.obtenerEstadoPorId(Integer.parseInt(idEstadoParam));
                orden.setIDEstadoTrabajo(estado);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "ID de estado inválido: " + idEstadoParam, e);
            }
        }
        
        // Fechas
        String fechaEstimadaStr = request.getParameter("fechaEstimadaSalida");
        if (fechaEstimadaStr != null && !fechaEstimadaStr.trim().isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaEstimada = sdf.parse(fechaEstimadaStr);
                orden.setFechaEstimadaSalida(fechaEstimada);
            } catch (ParseException e) {
                LOGGER.log(Level.WARNING, "Fecha inválida: " + fechaEstimadaStr, e);
            }
        }
        
        // Campos de texto
        orden.setProblemaReportado(request.getParameter("problemaReportado"));
        orden.setObservaciones(request.getParameter("observaciones"));

        return orden;
    }

    private OrdenServicio verificarAccesoMecanicoOrden(int idOrden, Integer idMecanico) {
        if (idMecanico == null) {
            return null;
        }
        
        OrdenServicio orden = ordenServicioDAO.obtenerOrdenCompleta(idOrden);
        if (orden == null || orden.getDiagnosticoList() == null) {
            return null;
        }
        
        boolean tieneAcceso = orden.getDiagnosticoList().stream()
            .anyMatch(diagnostico -> 
                diagnostico.getIDEmpleadoMecanico() != null &&
                diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico));
        
        return tieneAcceso ? orden : null;
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/crear")) return "crear";
        if (path.endsWith("/editar")) return "editar";
        if (path.endsWith("/ver")) return "ver";
        if (path.endsWith("/buscar")) return "buscar";
        if (path.endsWith("/asignar-vehiculo")) return "asignar-vehiculo";
        if (path.endsWith("/actualizar-estado")) return "actualizar-estado";
        if (path.endsWith("/registrar-avance")) return "registrar-avance";
        
        return "listar";
    }

    private void forwardToJsp(HttpServletRequest request, HttpServletResponse response, 
                            Integer idRol, String path, String action) 
            throws ServletException, IOException {
        String jspPath = determineJspPage(idRol, path, action);
        request.getRequestDispatcher(jspPath).forward(request, response);
    }

    private String determineJspPage(Integer idRol, String path, String action) {
        String basePath = "/WEB-INF/pages/";
        
        // Usar idRol numérico para determinar la carpeta
        if (idRol != null) {
            if (idRol == 2) { // Mecánico
                return basePath + "mecanico/orden/" + action + ".jsp";
            } else if (idRol == 3) { // Recepcionista
                return basePath + "recepcionista/orden/" + action + ".jsp";
            }
        }
        
        // Fallback basado en la ruta del servlet
        if (path.contains("/recepcionista/")) {
            return basePath + "recepcionista/orden/" + action + ".jsp";
        } else if (path.contains("/mecanico/")) {
            return basePath + "mecanico/orden/" + action + ".jsp";
        }
        
        // Default a recepcionista
        return basePath + "recepcionista/orden/" + action + ".jsp";
    }

    private void mostrarFormularioConError(HttpServletRequest request, HttpServletResponse response,
                                          String errorMsg, OrdenServicio orden) 
            throws ServletException, IOException {
        request.setAttribute(ATTR_ERROR, errorMsg);
        if (orden != null) {
            request.setAttribute(ATTR_ORDEN, orden);
        }
        
        List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculosConDetallesCompletos();
        List<EstadoTrabajo> estados = estadoTrabajoDAO.listarEstadosParaOrdenes();
        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("estados", estados);
        
        forwardToJsp(request, response, 3, request.getServletPath(), "form");
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, 
                           Exception e, String errorMessage) throws ServletException, IOException {
        LOGGER.log(Level.SEVERE, errorMessage, e);
        request.setAttribute(ATTR_ERROR, errorMessage + ": " + e.getMessage());
        
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            // Redirigir según el rol
            HttpSession session = request.getSession(false);
            Integer idRol = (Integer) session.getAttribute("idRol");
            if (idRol != null && idRol == 2) {
                response.sendRedirect(request.getContextPath() + "/mecanico/ordenes");
            } else {
                response.sendRedirect(request.getContextPath() + "/recepcionista/ordenes");
            }
        }
    }
}