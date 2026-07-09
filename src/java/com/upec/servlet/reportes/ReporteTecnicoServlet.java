package com.upec.servlet.reportes;

import com.upec.dao.DiagnosticoDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.EmpleadoDAO;
import com.upec.model.Diagnostico;
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

@WebServlet(name = "ReporteTecnicoServlet", urlPatterns = {
    "/servlet/mecanico/reportetecnico",
    "/servlet/mecanico/reportetecnico/mis-reportes", 
    "/servlet/mecanico/reportetecnico/generar",
    "/servlet/mecanico/reportetecnico/estadisticas",
    "/servlet/mecanico/reportetecnico/detalle",
    "/servlet/mecanico/reportetecnico/filtrar",
    "/ReporteTecnicoServlet",
    "/mecanico/reportetecnico",
    "/mecanico/reportetecnico/mis-reportes",
    "/mecanico/reportetecnico/generar", 
    "/mecanico/reportetecnico/estadisticas",
    "/mecanico/reportetecnico/detalle",
    "/mecanico/reportetecnico/filtrar"
})
public class ReporteTecnicoServlet extends HttpServlet {

    @Inject
    private DiagnosticoDAO diagnosticoDAO;
    
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

        // CORRECCIÓN: Usar idRol en lugar de userRole como en HorasServlet
        Integer idRol = (Integer) session.getAttribute("idRol");
        if (idRol == null || idRol != 2) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "listar":
                    handleListarReportes(request, response);
                    break;
                case "mis-reportes":
                    handleMisReportes(request, response);
                    break;
                case "generar":
                    handleGenerarReporteForm(request, response);
                    break;
                case "estadisticas":
                    handleEstadisticas(request, response);
                    break;
                case "detalle":
                    handleVerDetalleReporte(request, response);
                    break;
                case "filtrar":
                    handleFiltrarReportes(request, response);
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

        // CORRECCIÓN: Usar idRol en lugar de userRole como en HorasServlet
        Integer idRol = (Integer) session.getAttribute("idRol");
        if (idRol == null || idRol != 2) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "generar":
                    handleGenerarReporte(request, response);
                    break;
                case "filtrar":
                    handleFiltrarReportes(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarReportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Diagnostico> diagnosticos = diagnosticoDAO.listarDiagnosticos();
        
        request.setAttribute("diagnosticos", diagnosticos);
        request.setAttribute("tipoVista", "todos");
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/reportetecnico/list.jsp").forward(request, response);
    }

    private void handleMisReportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Diagnostico> misDiagnosticos = diagnosticoDAO.listarDiagnosticosPorMecanico(idMecanico);
        
        int totalDiagnosticos = misDiagnosticos.size();
        int diagnosticosPendientes = diagnosticoDAO.contarDiagnosticosPendientes(idMecanico);
        
        List<OrdenServicio> misOrdenes = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);

        request.setAttribute("diagnosticos", misDiagnosticos);
        request.setAttribute("ordenes", misOrdenes);
        request.setAttribute("totalDiagnosticos", totalDiagnosticos);
        request.setAttribute("diagnosticosPendientes", diagnosticosPendientes);
        request.setAttribute("tipoVista", "mis-reportes");
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/reportetecnico/list.jsp").forward(request, response);
    }

    private void handleGenerarReporteForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<OrdenServicio> misOrdenes = ordenServicioDAO.listarOrdenesPorMecanico(idMecanico);
        
        request.setAttribute("ordenes", misOrdenes);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/reportetecnico/form.jsp").forward(request, response);
    }

    private void handleEstadisticas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Object[]> estadisticasGenerales = diagnosticoDAO.obtenerEstadisticasDiagnosticos();
        List<Object[]> estadisticasOrdenes = ordenServicioDAO.obtenerEstadisticasOrdenes();
        List<String> problemasComunes = diagnosticoDAO.obtenerProblemasComunes();
        
        List<Diagnostico> misDiagnosticos = diagnosticoDAO.listarDiagnosticosPorMecanico(idMecanico);
        int totalMisDiagnosticos = misDiagnosticos.size();
        int diagnosticosPendientes = diagnosticoDAO.contarDiagnosticosPendientes(idMecanico);
        
        // Obtener estados por nombre en lugar de IDs fijos
        int ordenesPendientes = ordenServicioDAO.contarOrdenesPorEstado(obtenerIdEstado("PENDIENTE"));
        int ordenesEnProceso = ordenServicioDAO.contarOrdenesPorEstado(obtenerIdEstado("EN PROCESO"));
        int ordenesCompletadas = ordenServicioDAO.contarOrdenesPorEstado(obtenerIdEstado("COMPLETADO"));

        request.setAttribute("estadisticasGenerales", estadisticasGenerales);
        request.setAttribute("estadisticasOrdenes", estadisticasOrdenes);
        request.setAttribute("problemasComunes", problemasComunes);
        request.setAttribute("totalMisDiagnosticos", totalMisDiagnosticos);
        request.setAttribute("diagnosticosPendientes", diagnosticosPendientes);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("ordenesEnProceso", ordenesEnProceso);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/reportetecnico/estadisticas.jsp").forward(request, response);
    }

    private void handleVerDetalleReporte(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de diagnóstico no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Diagnostico diagnostico = diagnosticoDAO.obtenerDiagnosticoCompleto(id);
        
        if (diagnostico == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Diagnóstico no encontrado");
            return;
        }

        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico != null && 
            diagnostico.getIDEmpleadoMecanico() != null &&
            !diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        request.setAttribute("diagnostico", diagnostico);
        
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/reportetecnico/view.jsp").forward(request, response);
    }

    private void handleFiltrarReportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tipoFiltro = request.getParameter("tipoFiltro");
        String valorFiltro = request.getParameter("valorFiltro");
        String fechaInicioStr = request.getParameter("fechaInicio");
        String fechaFinStr = request.getParameter("fechaFin");
        
        List<Diagnostico> diagnosticosFiltrados;
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");

        try {
            if (tipoFiltro != null && valorFiltro != null && !valorFiltro.trim().isEmpty()) {
                switch (tipoFiltro) {
                    case "orden":
                        int idOrden = Integer.parseInt(valorFiltro);
                        diagnosticosFiltrados = diagnosticoDAO.listarDiagnosticosPorOrden(idOrden);
                        break;
                    case "descripcion":
                        diagnosticosFiltrados = diagnosticoDAO.findByDescripcionContaining(valorFiltro);
                        break;
                    case "recomendaciones":
                        diagnosticosFiltrados = diagnosticoDAO.findByRecomendacionesContaining(valorFiltro);
                        break;
                    case "fecha":
                        Date fecha = new SimpleDateFormat("yyyy-MM-dd").parse(valorFiltro);
                        diagnosticosFiltrados = diagnosticoDAO.listarDiagnosticosPorFecha(fecha);
                        break;
                    default:
                        diagnosticosFiltrados = diagnosticoDAO.listarDiagnosticos();
                }
            } else if (fechaInicioStr != null && fechaFinStr != null && 
                      !fechaInicioStr.isEmpty() && !fechaFinStr.isEmpty()) {
                Date fechaInicio = new SimpleDateFormat("yyyy-MM-dd").parse(fechaInicioStr);
                Date fechaFin = new SimpleDateFormat("yyyy-MM-dd").parse(fechaFinStr);
                diagnosticosFiltrados = diagnosticoDAO.findByFechaDiagnosticoBetween(fechaInicio, fechaFin);
            } else {
                diagnosticosFiltrados = diagnosticoDAO.listarDiagnosticos();
            }

            if (idMecanico != null && "mis-reportes".equals(request.getParameter("vista"))) {
                diagnosticosFiltrados = diagnosticosFiltrados.stream()
                    .filter(d -> d.getIDEmpleadoMecanico() != null && 
                                d.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico))
                    .toList();
            }

            request.setAttribute("diagnosticos", diagnosticosFiltrados);
            request.setAttribute("tipoFiltro", tipoFiltro);
            request.setAttribute("valorFiltro", valorFiltro);
            request.setAttribute("fechaInicio", fechaInicioStr);
            request.setAttribute("fechaFin", fechaFinStr);
            request.setAttribute("tipoVista", request.getParameter("vista"));
            
        } catch (ParseException e) {
            request.setAttribute("error", "Formato de fecha inválido");
            diagnosticosFiltrados = diagnosticoDAO.listarDiagnosticos();
        }

        request.getRequestDispatcher("/WEB-INF/pages/mecanico/reportetecnico/list.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST

    private void handleGenerarReporte(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String idOrdenParam = request.getParameter("idOrdenServicio");
        String descripcion = request.getParameter("descripcionDiagnostico");
        String recomendaciones = request.getParameter("recomendaciones");
        
        if (idOrdenParam == null || descripcion == null || descripcion.trim().isEmpty()) {
            request.setAttribute("error", "Datos incompletos para generar el reporte");
            handleGenerarReporteForm(request, response);
            return;
        }

        int idOrden = Integer.parseInt(idOrdenParam);
        
        OrdenServicio orden = ordenServicioDAO.obtenerOrdenPorId(idOrden);
        if (orden == null) {
            request.setAttribute("error", "Orden de servicio no encontrada");
            handleGenerarReporteForm(request, response);
            return;
        }

        // Obtener el objeto Empleado completo para asignarlo al diagnóstico
        Empleado mecanico = empleadoDAO.obtenerEmpleadoPorId(idMecanico);
        if (mecanico == null) {
            request.setAttribute("error", "Empleado no encontrado");
            handleGenerarReporteForm(request, response);
            return;
        }

        Diagnostico diagnostico = new Diagnostico();
        diagnostico.setDescripcionDiagnostico(descripcion);
        diagnostico.setRecomendaciones(recomendaciones);
        diagnostico.setFechaDiagnostico(new Date());
        diagnostico.setIDOrdenServicio(orden);
        diagnostico.setIDEmpleadoMecanico(mecanico);
        
        if (diagnosticoDAO.crearDiagnostico(diagnostico)) {
            request.getSession().setAttribute("mensaje", "Reporte técnico generado exitosamente");
            // CORRECCIÓN: Usar la URL con /servlet/ en las redirecciones
            response.sendRedirect(request.getContextPath() + "/servlet/mecanico/reportetecnico/mis-reportes");
        } else {
            request.setAttribute("error", "Error al generar el reporte técnico");
            handleGenerarReporteForm(request, response);
        }
    }

    // Métodos auxiliares

    private int obtenerIdEstado(String nombreEstado) {
        // Este método debería obtener el ID del estado por nombre
        // Por ahora retorna valores por defecto
        switch (nombreEstado) {
            case "PENDIENTE": return 1;
            case "EN PROCESO": return 2;
            case "COMPLETADO": return 3;
            default: return 1;
        }
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/mis-reportes")) return "mis-reportes";
        if (path.endsWith("/generar")) return "generar";
        if (path.endsWith("/estadisticas")) return "estadisticas";
        if (path.endsWith("/detalle")) return "detalle";
        if (path.endsWith("/filtrar")) return "filtrar";
        
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
            // CORRECCIÓN: Usar la URL con /servlet/ en las redirecciones
            response.sendRedirect(request.getContextPath() + "/servlet/mecanico/reportetecnico");
        }
    }
}