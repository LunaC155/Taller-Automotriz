package com.upec.servlet.config;

import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.EmpleadoDAO;
import com.upec.model.OrdenServicio;
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

@WebServlet(name = "HorasServlet", urlPatterns = {
    "/HorasServlet",
    "/mecanico/horas",
    "/mecanico/horas/registrar",
    "/mecanico/horas/justificar",
    "/mecanico/horas/reportar",
    "/mecanico/horas/buscar",
    "/mecanico/horas/mis-horas"
})
public class HorasServlet extends HttpServlet {

    @Inject
    private OrdenServicioDAO ordenServicioDAO;
    
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
        if (!"mecanico".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "listar":
                    handleListarHoras(request, response);
                    break;
                case "formulario":
                    handleFormularioRegistroHoras(request, response);
                    break;
                case "justificar":
                    handleFormularioJustificarHoras(request, response);
                    break;
                case "reportar":
                    handleReportarProductividad(request, response);
                    break;
                case "buscar":
                    handleBuscarHoras(request, response);
                    break;
                case "mis-horas":
                    handleMisHoras(request, response);
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
                case "registrar":
                    handleRegistrarHoras(request, response);
                    break;
                case "justificar":
                    handleJustificarHoras(request, response);
                    break;
                case "reportar":
                    handleGenerarReporteProductividad(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesAsignadas;
        
        if (idMecanico != null) {
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
        } else {
            ordenesAsignadas = List.of();
        }

        double horasTrabajadas = calcularHorasTrabajadas(ordenesAsignadas);
        double horasPromedioPorOrden = ordenesAsignadas.isEmpty() ? 0 : horasTrabajadas / ordenesAsignadas.size();
        long ordenesCompletadas = ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();
        long ordenesPendientes = ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() == null)
            .count();

        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        request.setAttribute("horasTrabajadas", horasTrabajadas);
        request.setAttribute("horasPromedioPorOrden", horasPromedioPorOrden);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/list.jsp").forward(request, response);
    }

    private void handleFormularioRegistroHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesAsignadas;
        
        if (idMecanico != null) {
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico).stream()
                .filter(orden -> orden.getFechaRealSalida() == null)
                .toList();
        } else {
            ordenesAsignadas = List.of();
        }

        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/registrar.jsp").forward(request, response);
    }

    private void handleFormularioJustificarHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idOrdenParam = request.getParameter("idOrden");
        if (idOrdenParam == null || idOrdenParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
            return;
        }

        int idOrden = Integer.parseInt(idOrdenParam);
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        OrdenServicio orden = verificarAccesoMecanicoOrden(idOrden, idMecanico);
        
        if (orden == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        request.setAttribute("orden", orden);
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/justificar.jsp").forward(request, response);
    }

    private void handleReportarProductividad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesAsignadas;
        
        if (idMecanico != null) {
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
        } else {
            ordenesAsignadas = List.of();
        }

        double horasTotales = calcularHorasTrabajadas(ordenesAsignadas);
        double eficiencia = calcularEficiencia(ordenesAsignadas);
        int ordenesCompletadas = (int) ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();
        double tiempoPromedioReparacion = calcularTiempoPromedioReparacion(ordenesAsignadas);

        request.setAttribute("horasTotales", horasTotales);
        request.setAttribute("eficiencia", eficiencia);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        request.setAttribute("tiempoPromedioReparacion", tiempoPromedioReparacion);
        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/reportar.jsp").forward(request, response);
    }

    private void handleBuscarHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fechaInicioStr = request.getParameter("fechaInicio");
        String fechaFinStr = request.getParameter("fechaFin");
        String criterio = request.getParameter("criterio");
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesFiltradas;
        
        if (idMecanico != null) {
            ordenesFiltradas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
        } else {
            ordenesFiltradas = List.of();
        }

        if (fechaInicioStr != null && !fechaInicioStr.isEmpty() && 
            fechaFinStr != null && !fechaFinStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaInicio = sdf.parse(fechaInicioStr);
                Date fechaFin = sdf.parse(fechaFinStr);
                
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.setTime(fechaFin);
                cal.add(java.util.Calendar.DAY_OF_MONTH, 1);
                fechaFin = cal.getTime();
                
                final Date fechaInicioFinal = fechaInicio;
                final Date fechaFinFinal = fechaFin;
                
                ordenesFiltradas = ordenesFiltradas.stream()
                    .filter(orden -> orden.getFechaEntrada() != null && 
                            !orden.getFechaEntrada().before(fechaInicioFinal) && 
                            !orden.getFechaEntrada().after(fechaFinFinal))
                    .toList();
            } catch (ParseException e) {
                // Si hay error en el parseo, no se aplica filtro de fecha
            }
        }

        if (criterio != null && !criterio.isEmpty()) {
            if ("completadas".equals(criterio)) {
                ordenesFiltradas = ordenesFiltradas.stream()
                    .filter(orden -> orden.getFechaRealSalida() != null)
                    .toList();
            } else if ("pendientes".equals(criterio)) {
                ordenesFiltradas = ordenesFiltradas.stream()
                    .filter(orden -> orden.getFechaRealSalida() == null)
                    .toList();
            }
        }

        double horasFiltradas = calcularHorasTrabajadas(ordenesFiltradas);

        request.setAttribute("ordenesAsignadas", ordenesFiltradas);
        request.setAttribute("horasTrabajadas", horasFiltradas);
        request.setAttribute("fechaInicio", fechaInicioStr);
        request.setAttribute("fechaFin", fechaFinStr);
        request.setAttribute("criterio", criterio);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/list.jsp").forward(request, response);
    }

    private void handleMisHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesAsignadas;
        Empleado mecanico = null;
        
        if (idMecanico != null) {
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
            mecanico = empleadoDAO.obtenerEmpleadoPorId(idMecanico);
        } else {
            ordenesAsignadas = List.of();
        }

        double horasTotales = calcularHorasTrabajadas(ordenesAsignadas);
        double horasEsteMes = calcularHorasEsteMes(ordenesAsignadas);
        double horasEstaSemana = calcularHorasEstaSemana(ordenesAsignadas);
        int ordenesCompletadas = (int) ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();
        int ordenesPendientes = (int) ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() == null)
            .count();
        double eficiencia = calcularEficiencia(ordenesAsignadas);

        request.setAttribute("mecanico", mecanico);
        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        request.setAttribute("horasTotales", horasTotales);
        request.setAttribute("horasEsteMes", horasEsteMes);
        request.setAttribute("horasEstaSemana", horasEstaSemana);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("eficiencia", eficiencia);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/mis-horas.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST

    private void handleRegistrarHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idOrdenParam = request.getParameter("idOrdenServicio");
        String horasTrabajadasParam = request.getParameter("horasTrabajadas");
        String descripcionTrabajo = request.getParameter("descripcionTrabajo");
        String fechaTrabajoStr = request.getParameter("fechaTrabajo");
        
        if (idOrdenParam == null || horasTrabajadasParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int idOrden = Integer.parseInt(idOrdenParam);
        double horasTrabajadas = Double.parseDouble(horasTrabajadasParam);
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        OrdenServicio orden = verificarAccesoMecanicoOrden(idOrden, idMecanico);
        
        if (orden == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String observacionesActuales = orden.getObservaciones();
        String fechaTrabajo = fechaTrabajoStr != null && !fechaTrabajoStr.isEmpty() ? 
            fechaTrabajoStr : new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        
        String nuevasObservaciones = observacionesActuales != null ? 
            observacionesActuales + "\n--- Registro de Horas ---\n" + 
            "Fecha: " + fechaTrabajo + "\n" +
            "Horas Trabajadas: " + horasTrabajadas + " horas\n" +
            "Descripción: " + (descripcionTrabajo != null ? descripcionTrabajo : "Sin descripción") + "\n" +
            "Registrado por: Mecánico ID " + idMecanico + "\n" :
            "--- Registro de Horas ---\n" + 
            "Fecha: " + fechaTrabajo + "\n" +
            "Horas Trabajadas: " + horasTrabajadas + " horas\n" +
            "Descripción: " + (descripcionTrabajo != null ? descripcionTrabajo : "Sin descripción") + "\n" +
            "Registrado por: Mecánico ID " + idMecanico + "\n";
        
        orden.setObservaciones(nuevasObservaciones);

        if (ordenServicioDAO.actualizarOrden(orden)) {
            request.getSession().setAttribute("mensaje", 
                String.format("Horas registradas exitosamente: %.2f horas en la orden #%s", 
                    horasTrabajadas, idOrden));
        } else {
            request.getSession().setAttribute("error", "Error al registrar las horas");
        }
        
        response.sendRedirect(request.getContextPath() + "/mecanico/horas");
    }

    private void handleJustificarHoras(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idOrdenParam = request.getParameter("idOrdenServicio");
        String justificacion = request.getParameter("justificacion");
        String horasExtraParam = request.getParameter("horasExtra");
        
        if (idOrdenParam == null || justificacion == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int idOrden = Integer.parseInt(idOrdenParam);
        double horasExtra = horasExtraParam != null && !horasExtraParam.isEmpty() ? 
            Double.parseDouble(horasExtraParam) : 0;
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        OrdenServicio orden = verificarAccesoMecanicoOrden(idOrden, idMecanico);
        
        if (orden == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String observacionesActuales = orden.getObservaciones();
        String nuevasObservaciones = observacionesActuales != null ? 
            observacionesActuales + "\n--- Justificación de Horas ---\n" + 
            "Fecha: " + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()) + "\n" +
            "Horas Extra Justificadas: " + horasExtra + " horas\n" +
            "Justificación: " + justificacion + "\n" +
            "Mecánico: ID " + idMecanico + "\n" :
            "--- Justificación de Horas ---\n" + 
            "Fecha: " + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()) + "\n" +
            "Horas Extra Justificadas: " + horasExtra + " horas\n" +
            "Justificación: " + justificacion + "\n" +
            "Mecánico: ID " + idMecanico + "\n";
        
        orden.setObservaciones(nuevasObservaciones);

        if (ordenServicioDAO.actualizarOrden(orden)) {
            request.getSession().setAttribute("mensaje", 
                "Justificación de horas registrada exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al registrar la justificación");
        }
        
        response.sendRedirect(request.getContextPath() + "/mecanico/horas");
    }

    private void handleGenerarReporteProductividad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String periodo = request.getParameter("periodo");
        String tipoReporte = request.getParameter("tipoReporte");
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        
        List<OrdenServicio> ordenesAsignadas;
        
        if (idMecanico != null) {
            ordenesAsignadas = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
        } else {
            ordenesAsignadas = List.of();
        }

        if (periodo != null && !periodo.isEmpty()) {
            ordenesAsignadas = filtrarPorPeriodo(ordenesAsignadas, periodo);
        }

        double horasTrabajadas = calcularHorasTrabajadas(ordenesAsignadas);
        double eficiencia = calcularEficiencia(ordenesAsignadas);
        int ordenesCompletadas = (int) ordenesAsignadas.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();
        double tiempoPromedio = ordenesCompletadas > 0 ? 
            horasTrabajadas / ordenesCompletadas : 0;

        request.setAttribute("periodo", periodo);
        request.setAttribute("tipoReporte", tipoReporte);
        request.setAttribute("ordenesAsignadas", ordenesAsignadas);
        request.setAttribute("horasTrabajadas", horasTrabajadas);
        request.setAttribute("eficiencia", eficiencia);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        request.setAttribute("tiempoPromedio", tiempoPromedio);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/horas/reporte-productividad.jsp").forward(request, response);
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
        
        boolean tieneAcceso = orden.getDiagnosticoList().stream()
            .anyMatch(diagnostico -> 
                diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico));
        
        return tieneAcceso ? orden : null;
    }

    private double calcularHorasTrabajadas(List<OrdenServicio> ordenes) {
        return ordenes.stream()
            .filter(orden -> orden.getFechaEntrada() != null && orden.getFechaRealSalida() != null)
            .mapToDouble(orden -> {
                long diff = orden.getFechaRealSalida().getTime() - orden.getFechaEntrada().getTime();
                return diff / (1000.0 * 60 * 60);
            })
            .sum();
    }

    private double calcularHorasEsteMes(List<OrdenServicio> ordenes) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        Date inicioMes = cal.getTime();
        
        return ordenes.stream()
            .filter(orden -> orden.getFechaEntrada() != null && 
                    orden.getFechaEntrada().after(inicioMes) &&
                    orden.getFechaRealSalida() != null)
            .mapToDouble(orden -> {
                long diff = orden.getFechaRealSalida().getTime() - orden.getFechaEntrada().getTime();
                return diff / (1000.0 * 60 * 60);
            })
            .sum();
    }

    private double calcularHorasEstaSemana(List<OrdenServicio> ordenes) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.DAY_OF_WEEK, cal.getFirstDayOfWeek());
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        Date inicioSemana = cal.getTime();
        
        return ordenes.stream()
            .filter(orden -> orden.getFechaEntrada() != null && 
                    orden.getFechaEntrada().after(inicioSemana) &&
                    orden.getFechaRealSalida() != null)
            .mapToDouble(orden -> {
                long diff = orden.getFechaRealSalida().getTime() - orden.getFechaEntrada().getTime();
                return diff / (1000.0 * 60 * 60);
            })
            .sum();
    }

    private double calcularEficiencia(List<OrdenServicio> ordenes) {
        long ordenesCompletadas = ordenes.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();
        
        if (ordenes.isEmpty()) return 0.0;
        
        return (double) ordenesCompletadas / ordenes.size() * 100;
    }

    private double calcularTiempoPromedioReparacion(List<OrdenServicio> ordenes) {
        long ordenesCompletadas = ordenes.stream()
            .filter(orden -> orden.getFechaRealSalida() != null)
            .count();
        
        if (ordenesCompletadas == 0) return 0.0;
        
        double horasTotales = calcularHorasTrabajadas(ordenes);
        return horasTotales / ordenesCompletadas;
    }

    private List<OrdenServicio> filtrarPorPeriodo(List<OrdenServicio> ordenes, String periodo) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        Date fechaInicio;
        
        switch (periodo.toLowerCase()) {
            case "semana":
                cal.set(java.util.Calendar.DAY_OF_WEEK, cal.getFirstDayOfWeek());
                break;
            case "mes":
                cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
                break;
            case "trimestre":
                cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
                int mesActual = cal.get(java.util.Calendar.MONTH);
                int trimestre = mesActual / 3;
                cal.set(java.util.Calendar.MONTH, trimestre * 3);
                break;
            default:
                return ordenes;
        }
        
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        fechaInicio = cal.getTime();
        
        final Date fechaInicioFinal = fechaInicio;
        return ordenes.stream()
            .filter(orden -> orden.getFechaEntrada() != null && 
                    orden.getFechaEntrada().after(fechaInicioFinal))
            .toList();
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/registrar")) return "formulario";
        if (path.endsWith("/justificar")) return "justificar";
        if (path.endsWith("/reportar")) return "reportar";
        if (path.endsWith("/buscar")) return "buscar";
        if (path.endsWith("/mis-horas")) return "mis-horas";
        
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
            response.sendRedirect(request.getContextPath() + "/mecanico/horas");
        }
    }
}