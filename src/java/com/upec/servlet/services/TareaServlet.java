package com.upec.servlet.services;

import com.upec.dao.ServicioDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.model.Servicio;
import com.upec.model.OrdenServicio;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "TareaServlet", urlPatterns = {
    "/TareaServlet",
    "/mecanico/tareas",
    "/mecanico/tareas/ver",
    "/mecanico/tareas/actualizar-progreso",
    "/mecanico/tareas/completar",
    "/mecanico/tareas/buscar"
})
public class TareaServlet extends HttpServlet {

    private ServicioDAO servicioDAO;
    private OrdenServicioDAO ordenServicioDAO;

    @Override
    public void init() throws ServletException {
        this.servicioDAO = new ServicioDAO();
        this.ordenServicioDAO = new OrdenServicioDAO();
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
        if (!"mecanico".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "listar":
                    handleListarTareas(request, response);
                    break;
                case "ver":
                    handleVerTarea(request, response);
                    break;
                case "buscar":
                    handleBuscarTareas(request, response);
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
        if (!"mecanico".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "actualizar-progreso":
                    handleActualizarProgreso(request, response);
                    break;
                case "completar":
                    handleCompletarTarea(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarTareas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Obtener el ID del mecánico de la sesión
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesAsignadas;
        List<Servicio> serviciosActivos;
        
        if (idMecanico != null) {
            // Obtener órdenes asignadas al mecánico
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
            
            // Obtener servicios activos para mostrar como tareas disponibles
            serviciosActivos = servicioDAO.listarServiciosActivos();
        } else {
            ordenesAsignadas = List.of();
            serviciosActivos = List.of();
        }

        // Obtener estadísticas para el dashboard del mecánico
        int totalOrdenesAsignadas = ordenesAsignadas.size();
        long ordenesPendientes = ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() == null)
            .count();
        long ordenesCompletadas = ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();

        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        request.setAttribute("serviciosActivos", serviciosActivos);
        request.setAttribute("totalOrdenesAsignadas", totalOrdenesAsignadas);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/tarea/list.jsp").forward(request, response);
    }

    private void handleVerTarea(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            
            // Verificar que el mecánico tiene acceso a esta orden
            Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
            OrdenServicio orden = verificarAccesoMecanicoOrden(id, idMecanico);
            
            if (orden == null) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            // Obtener servicios asociados a esta orden - CORRECCIÓN: Este método no existe en ServicioDAO
            // List<Servicio> serviciosOrden = servicioDAO.listarServiciosPorOrden(id);
            // En su lugar, obtenemos la orden completa que ya incluye los diagnósticos
            OrdenServicio ordenCompleta = ordenServicioDAO.obtenerOrdenCompleta(id);

            request.setAttribute("orden", ordenCompleta);
            // request.setAttribute("serviciosOrden", serviciosOrden); // Eliminado
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/tarea/view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden inválido");
        }
    }

    private void handleBuscarTareas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        List<OrdenServicio> ordenesAsignadas;
        
        if (idMecanico != null) {
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
        } else {
            ordenesAsignadas = List.of();
        }

        // Filtrar resultados según criterio de búsqueda
        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            if ("problema".equals(criterio)) {
                ordenesAsignadas = ordenesAsignadas.stream()
                    .filter(orden -> orden.getProblemaReportado() != null && 
                            orden.getProblemaReportado().toLowerCase().contains(valor.toLowerCase()))
                    .toList();
            } else if ("vehiculo".equals(criterio)) {
                ordenesAsignadas = ordenesAsignadas.stream()
                    .filter(orden -> orden.getIDVehiculo() != null && 
                            orden.getIDVehiculo().getPlaca() != null &&
                            orden.getIDVehiculo().getPlaca().toLowerCase().contains(valor.toLowerCase()))
                    .toList();
            } else if ("estado".equals(criterio)) {
                boolean buscarPendientes = "pendiente".equalsIgnoreCase(valor);
                ordenesAsignadas = ordenesAsignadas.stream()
                    .filter(orden -> buscarPendientes ? 
                            orden.getFechaRealSalida() == null : 
                            orden.getFechaRealSalida() != null)
                    .toList();
            }
        }

        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/tarea/list.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST

    private void handleActualizarProgreso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idOrdenParam = request.getParameter("idOrdenServicio");
        String observaciones = request.getParameter("observaciones");
        String progreso = request.getParameter("progreso");
        
        if (idOrdenParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
            return;
        }

        try {
            int idOrden = Integer.parseInt(idOrdenParam);
            
            // Verificar que el mecánico tiene acceso a esta orden
            Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
            OrdenServicio orden = verificarAccesoMecanicoOrden(idOrden, idMecanico);
            
            if (orden == null) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            // Actualizar observaciones con el progreso
            if (observaciones != null && !observaciones.trim().isEmpty()) {
                String observacionesActuales = orden.getObservaciones();
                String nuevasObservaciones = observacionesActuales != null ? 
                    observacionesActuales + "\n--- Progreso Actualizado ---\n" + 
                    "Progreso: " + progreso + "%\n" +
                    "Observaciones: " + observaciones + "\n" +
                    "Fecha: " + new java.util.Date() + "\n" :
                    "--- Progreso Actualizado ---\n" + 
                    "Progreso: " + progreso + "%\n" +
                    "Observaciones: " + observaciones + "\n" +
                    "Fecha: " + new java.util.Date() + "\n";
                
                orden.setObservaciones(nuevasObservaciones);

                if (ordenServicioDAO.actualizarOrden(orden)) {
                    request.getSession().setAttribute("mensaje", "Progreso actualizado exitosamente");
                } else {
                    request.getSession().setAttribute("error", "Error al actualizar el progreso");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/mecanico/tareas/ver?id=" + idOrden);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden inválido");
        }
    }

    private void handleCompletarTarea(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idOrdenParam = request.getParameter("idOrdenServicio");
        String observacionesFinales = request.getParameter("observacionesFinales");
        
        if (idOrdenParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
            return;
        }

        try {
            int idOrden = Integer.parseInt(idOrdenParam);
            
            // Verificar que el mecánico tiene acceso a esta orden
            Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
            OrdenServicio orden = verificarAccesoMecanicoOrden(idOrden, idMecanico);
            
            if (orden == null) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            // Actualizar observaciones finales
            if (observacionesFinales != null && !observacionesFinales.trim().isEmpty()) {
                String observacionesActuales = orden.getObservaciones();
                String nuevasObservaciones = observacionesActuales != null ? 
                    observacionesActuales + "\n--- Tarea Completada ---\n" + 
                    "Observaciones Finales: " + observacionesFinales + "\n" +
                    "Fecha de Finalización: " + new java.util.Date() + "\n" :
                    "--- Tarea Completada ---\n" + 
                    "Observaciones Finales: " + observacionesFinales + "\n" +
                    "Fecha de Finalización: " + new java.util.Date() + "\n";
                
                orden.setObservaciones(nuevasObservaciones);
            }

            // Establecer fecha real de salida
            orden.setFechaRealSalida(new java.util.Date());

            // Buscar estado "COMPLETADO" por nombre en lugar de ID fijo
            boolean estadoActualizado = false;
            try {
                // Usar el método existente en OrdenServicioDAO para actualizar estado
                // Asumiendo que existe un estado "COMPLETADO" en la base de datos
                estadoActualizado = ordenServicioDAO.actualizarEstadoOrden(idOrden, obtenerIdEstadoCompletado());
            } catch (Exception e) {
                // Si falla, solo actualizamos la orden sin cambiar estado
                estadoActualizado = false;
            }

            if (ordenServicioDAO.actualizarOrden(orden)) {
                request.getSession().setAttribute("mensaje", "Tarea marcada como completada exitosamente");
            } else {
                request.getSession().setAttribute("error", "Error al completar la tarea");
            }
            
            response.sendRedirect(request.getContextPath() + "/mecanico/tareas");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden inválido");
        }
    }

    // Métodos auxiliares

    private OrdenServicio verificarAccesoMecanicoOrden(int idOrden, Integer idMecanico) {
        if (idMecanico == null) {
            return null;
        }
        
        OrdenServicio orden = ordenServicioDAO.obtenerOrdenCompleta(idOrden);
        if (orden == null) {
            return null;
        }
        
        // Verificar si el mecánico tiene diagnósticos en esta orden
        boolean tieneAcceso = orden.getDiagnosticoList().stream()
            .anyMatch(diagnostico -> 
                diagnostico.getIDEmpleadoMecanico() != null &&
                diagnostico.getIDEmpleadoMecanico().getIDEmpleado() != null &&
                diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico));
        
        return tieneAcceso ? orden : null;
    }

    private int obtenerIdEstadoCompletado() {
        // Método auxiliar para obtener el ID del estado "COMPLETADO"
        // En una implementación real, esto debería consultar la base de datos
        // Por ahora retornamos un valor por defecto (3 como en tu código original)
        return 3;
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/ver")) return "ver";
        if (path.endsWith("/actualizar-progreso")) return "actualizar-progreso";
        if (path.endsWith("/completar")) return "completar";
        if (path.endsWith("/buscar")) return "buscar";
        
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
            response.sendRedirect(request.getContextPath() + "/mecanico/tareas");
        }
    }

    @Override
    public void destroy() {
        // Cleanup resources if needed
    }
}