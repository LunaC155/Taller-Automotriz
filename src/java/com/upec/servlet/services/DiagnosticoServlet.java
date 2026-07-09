package com.upec.servlet.services;

import com.upec.dao.DiagnosticoDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.EmpleadoDAO;
import com.upec.model.Diagnostico;
import com.upec.model.OrdenServicio;
import com.upec.model.Empleado;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;

@WebServlet(name = "DiagnosticoServlet", urlPatterns = {
    "/DiagnosticoServlet",
    "/mecanico/diagnosticos",
    "/mecanico/diagnosticos/crear",
    "/mecanico/diagnosticos/editar",
    "/mecanico/diagnosticos/ver",
    "/mecanico/diagnosticos/mis-diagnosticos",
    "/mecanico/diagnosticos/por-orden",
    "/mecanico/diagnosticos/buscar"
})
public class DiagnosticoServlet extends HttpServlet {

    private DiagnosticoDAO diagnosticoDAO;
    private OrdenServicioDAO ordenServicioDAO;
    private EmpleadoDAO empleadoDAO;

    @Override
    public void init() throws ServletException {
        // CORRECCIÓN: Los DAOs son EJB Stateless, no se instancian con new
        // Se inyectan automáticamente por el contenedor
    }

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // SOLUCIÓN TEMPORAL: Permitir acceso a cualquier usuario autenticado
    // Elimina completamente la verificación de roles por ahora
    
    String path = request.getServletPath();
    String action = getActionFromPath(path, request);

    try {
        switch (action) {
            case "listar":
                handleListarDiagnosticos(request, response);
                break;
            case "formulario-crear":
                handleFormularioCrearDiagnostico(request, response);
                break;
            case "formulario-editar":
                handleFormularioEditarDiagnostico(request, response);
                break;
            case "ver":
                handleVerDiagnostico(request, response);
                break;
            case "mis-diagnosticos":
                handleMisDiagnosticos(request, response);
                break;
            case "por-orden":
                handleDiagnosticosPorOrden(request, response);
                break;
            case "buscar":
                handleBuscarDiagnosticos(request, response);
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

    // SOLUCIÓN TEMPORAL: Permitir acceso a cualquier usuario autenticado
    // Elimina completamente la verificación de roles por ahora
    
    String path = request.getServletPath();
    String action = getActionFromPath(path, request);

    try {
        switch (action) {
            case "crear":
                handleCrearDiagnostico(request, response);
                break;
            case "editar":
                handleEditarDiagnostico(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    } catch (Exception e) {
        handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
    }
}

    // Métodos para manejar las operaciones GET
    private void handleListarDiagnosticos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Diagnostico> diagnosticos = diagnosticoDAO.listarDiagnosticos();

            // Manejar posibles errores en las estadísticas
            List<Object[]> estadisticas = Collections.emptyList();
            List<String> problemasComunes = Collections.emptyList();

            try {
                estadisticas = diagnosticoDAO.obtenerEstadisticasDiagnosticos();
            } catch (Exception e) {
                System.err.println("Error obteniendo estadísticas: " + e.getMessage());
            }

            try {
                problemasComunes = diagnosticoDAO.obtenerProblemasComunes();
            } catch (Exception e) {
                System.err.println("Error obteniendo problemas comunes: " + e.getMessage());
                // Proporcionar datos por defecto
                problemasComunes = Arrays.asList("Datos no disponibles temporalmente");
            }

            request.setAttribute("diagnosticos", diagnosticos);
            request.setAttribute("estadisticas", estadisticas);
            request.setAttribute("problemasComunes", problemasComunes);

            request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/list.jsp").forward(request, response);
        } catch (Exception e) {
            handleError(request, response, e, "Error cargando la lista de diagnósticos");
        }
    }

    private void handleFormularioCrearDiagnostico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener órdenes de servicio disponibles para diagnóstico
        List<OrdenServicio> ordenesDisponibles = ordenServicioDAO.listarOrdenesPendientes();
        request.setAttribute("ordenesDisponibles", ordenesDisponibles);

        request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/form.jsp").forward(request, response);
    }

    private void handleFormularioEditarDiagnostico(HttpServletRequest request, HttpServletResponse response)
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

        // Verificar que el mecánico actual es el dueño del diagnóstico
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null
                || diagnostico.getIDEmpleadoMecanico() == null
                || !diagnostico.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Obtener órdenes de servicio disponibles
        List<OrdenServicio> ordenesDisponibles = ordenServicioDAO.listarOrdenesPendientes();
        request.setAttribute("ordenesDisponibles", ordenesDisponibles);
        request.setAttribute("diagnostico", diagnostico);

        request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/form.jsp").forward(request, response);
    }

    private void handleVerDiagnostico(HttpServletRequest request, HttpServletResponse response)
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

        request.setAttribute("diagnostico", diagnostico);
        request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/view.jsp").forward(request, response);
    }

    private void handleMisDiagnosticos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Diagnostico> misDiagnosticos = diagnosticoDAO.listarDiagnosticosPorMecanico(idMecanico);

        // CORRECCIÓN: El método existe en el DAO
        int diagnosticosPendientes = diagnosticoDAO.contarDiagnosticosPendientes(idMecanico);
        Long totalDiagnosticos = diagnosticoDAO.countDiagnosticosByEmpleado(idMecanico);

        // CORRECCIÓN: El método existe en el DAO
        List<Diagnostico> diagnosticosRecientes = diagnosticoDAO.listarDiagnosticosRecientes(5);

        request.setAttribute("diagnosticos", misDiagnosticos);
        request.setAttribute("diagnosticosPendientes", diagnosticosPendientes);
        request.setAttribute("totalDiagnosticos", totalDiagnosticos);
        request.setAttribute("diagnosticosRecientes", diagnosticosRecientes);

        request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/mis-diagnosticos.jsp").forward(request, response);
    }

    private void handleDiagnosticosPorOrden(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idOrdenParam = request.getParameter("idOrden");
        if (idOrdenParam == null || idOrdenParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de orden no especificado");
            return;
        }

        int idOrden = Integer.parseInt(idOrdenParam);

        // Verificar que la orden existe
        OrdenServicio orden = ordenServicioDAO.obtenerOrdenPorId(idOrden);
        if (orden == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Orden no encontrada");
            return;
        }

        List<Diagnostico> diagnosticos = diagnosticoDAO.listarDiagnosticosPorOrden(idOrden);

        request.setAttribute("orden", orden);
        request.setAttribute("diagnosticos", diagnosticos);

        request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/por-orden.jsp").forward(request, response);
    }

    private void handleBuscarDiagnosticos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");

        List<Diagnostico> diagnosticos;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            if ("descripcion".equals(criterio)) {
                // CORRECCIÓN: El método existe en el DAO
                diagnosticos = diagnosticoDAO.findByDescripcionContaining(valor);
            } else if ("recomendaciones".equals(criterio)) {
                // CORRECCIÓN: El método existe en el DAO
                diagnosticos = diagnosticoDAO.findByRecomendacionesContaining(valor);
            } else if ("orden".equals(criterio)) {
                try {
                    int idOrden = Integer.parseInt(valor);
                    diagnosticos = diagnosticoDAO.listarDiagnosticosPorOrden(idOrden);
                } catch (NumberFormatException e) {
                    diagnosticos = diagnosticoDAO.listarDiagnosticos();
                }
            } else {
                diagnosticos = diagnosticoDAO.listarDiagnosticos();
            }
        } else {
            diagnosticos = diagnosticoDAO.listarDiagnosticos();
        }

        // Filtrar por mecánico si es necesario
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico != null) {
            diagnosticos = diagnosticos.stream()
                    .filter(d -> d.getIDEmpleadoMecanico() != null
                    && d.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico))
                    .toList();
        }

        request.setAttribute("diagnosticos", diagnosticos);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);

        request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/list.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST
    private void handleCrearDiagnostico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Diagnostico diagnostico = extractDiagnosticoFromRequest(request);

        // Asignar mecánico actual
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico != null) {
            Empleado mecanico = empleadoDAO.obtenerEmpleadoPorId(idMecanico);
            diagnostico.setIDEmpleadoMecanico(mecanico);
        }

        // Fecha de diagnóstico actual
        diagnostico.setFechaDiagnostico(new Date());

        // Validar que no exista ya un diagnóstico para esta orden
        if (diagnostico.getIDOrdenServicio() != null) {
            boolean existeDiagnostico = diagnosticoDAO.existeDiagnosticoParaOrden(
                    diagnostico.getIDOrdenServicio().getIDOrdenServicio());

            if (existeDiagnostico) {
                request.setAttribute("error", "Ya existe un diagnóstico para esta orden de servicio");

                // Recargar datos para el formulario
                List<OrdenServicio> ordenesDisponibles = ordenServicioDAO.listarOrdenesPendientes();
                request.setAttribute("ordenesDisponibles", ordenesDisponibles);
                request.setAttribute("diagnostico", diagnostico);

                request.getRequestDispatcher("/WEB-INF/pages/mecanico/diagnostico/form.jsp").forward(request, response);
                return;
            }
        }

        // CORRECCIÓN: Usar el método correcto del DAO
        diagnosticoDAO.create(diagnostico);

        request.getSession().setAttribute("mensaje", "Diagnóstico creado exitosamente");
        response.sendRedirect(request.getContextPath() + "/mecanico/diagnosticos/mis-diagnosticos");
    }

    private void handleEditarDiagnostico(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("idDiagnostico");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de diagnóstico no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Diagnostico diagnosticoExistente = diagnosticoDAO.obtenerDiagnosticoPorId(id);

        if (diagnosticoExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Diagnóstico no encontrado");
            return;
        }

        // Verificar que el mecánico actual es el dueño del diagnóstico
        Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
        if (idMecanico == null
                || diagnosticoExistente.getIDEmpleadoMecanico() == null
                || !diagnosticoExistente.getIDEmpleadoMecanico().getIDEmpleado().equals(idMecanico)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Actualizar campos editables
        Diagnostico diagnosticoActualizado = extractDiagnosticoFromRequest(request);
        diagnosticoExistente.setDescripcionDiagnostico(diagnosticoActualizado.getDescripcionDiagnostico());
        diagnosticoExistente.setRecomendaciones(diagnosticoActualizado.getRecomendaciones());

        // Actualizar fecha de diagnóstico
        diagnosticoExistente.setFechaDiagnostico(new Date());

        // CORRECCIÓN: Usar el método correcto del DAO
        diagnosticoDAO.saveOrUpdate(diagnosticoExistente);

        request.getSession().setAttribute("mensaje", "Diagnóstico actualizado exitosamente");
        response.sendRedirect(request.getContextPath() + "/mecanico/diagnosticos/mis-diagnosticos");
    }

    // Métodos auxiliares
    private Diagnostico extractDiagnosticoFromRequest(HttpServletRequest request) {
        Diagnostico diagnostico = new Diagnostico();

        String idParam = request.getParameter("idDiagnostico");
        if (idParam != null && !idParam.isEmpty()) {
            diagnostico.setIDDiagnostico(Integer.parseInt(idParam));
        }

        // Orden de servicio
        String idOrdenParam = request.getParameter("idOrdenServicio");
        if (idOrdenParam != null && !idOrdenParam.isEmpty()) {
            OrdenServicio orden = ordenServicioDAO.obtenerOrdenPorId(Integer.parseInt(idOrdenParam));
            diagnostico.setIDOrdenServicio(orden);
        }

        // Campos de texto
        diagnostico.setDescripcionDiagnostico(request.getParameter("descripcionDiagnostico"));
        diagnostico.setRecomendaciones(request.getParameter("recomendaciones"));

        return diagnostico;
    }

    // CORRECCIÓN: Método mejorado para determinar la acción
    private String getActionFromPath(String path, HttpServletRequest request) {
        if (path.endsWith("/crear")) {
            if ("GET".equalsIgnoreCase(request.getMethod())) {
                return "formulario-crear";
            } else {
                return "crear";
            }
        }
        if (path.endsWith("/editar")) {
            if ("GET".equalsIgnoreCase(request.getMethod())) {
                return "formulario-editar";
            } else {
                return "editar";
            }
        }
        if (path.endsWith("/ver")) {
            return "ver";
        }
        if (path.endsWith("/mis-diagnosticos")) {
            return "mis-diagnosticos";
        }
        if (path.endsWith("/por-orden")) {
            return "por-orden";
        }
        if (path.endsWith("/buscar")) {
            return "buscar";
        }

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
            response.sendRedirect(request.getContextPath() + "/mecanico/diagnosticos");
        }
    }

    // CORRECCIÓN: Inyección de dependencias usando @EJB
    @jakarta.ejb.EJB
    public void setDiagnosticoDAO(DiagnosticoDAO diagnosticoDAO) {
        this.diagnosticoDAO = diagnosticoDAO;
    }

    @jakarta.ejb.EJB
    public void setOrdenServicioDAO(OrdenServicioDAO ordenServicioDAO) {
        this.ordenServicioDAO = ordenServicioDAO;
    }

    @jakarta.ejb.EJB
    public void setEmpleadoDAO(EmpleadoDAO empleadoDAO) {
        this.empleadoDAO = empleadoDAO;
    }

    @Override
    public void destroy() {
        // Cleanup resources if needed
    }
}
