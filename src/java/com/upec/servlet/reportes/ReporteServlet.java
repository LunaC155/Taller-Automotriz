package com.upec.servlet.reportes;

import com.upec.dao.FacturaDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.VehiculoDAO;
import com.upec.model.Factura;
import com.upec.model.OrdenServicio;
import com.upec.model.Vehiculo;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "ReporteServlet", urlPatterns = {"/ReporteServlet"})
public class ReporteServlet extends HttpServlet {

    @EJB
    private FacturaDAO facturaDAO;

    @EJB
    private OrdenServicioDAO ordenServicioDAO;

    @EJB
    private VehiculoDAO vehiculoDAO;

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

        String action = request.getParameter("action");
        if (action == null) {
            action = "listar";
        }

        try {
            switch (action) {
                case "listar":
                    handleDashboardReportes(request, response);
                    break;
                case "financieros":
                    handleReportesFinancieros(request, response);
                    break;
                case "productividad":
                    handleReportesProductividad(request, response);
                    break;
                case "inventarios":
                    handleReportesInventarios(request, response);
                    break;
                case "vehiculos":
                    handleReportesVehiculos(request, response);
                    break;
                case "generar":
                    handleGenerarReporte(request, response);
                    break;
                default:
                    handleDashboardReportes(request, response);
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

        String action = request.getParameter("action");

        try {
            if ("generarReporte".equals(action)) {
                handleGenerarReporteFiltrado(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET
    private void handleDashboardReportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener estadísticas generales para el dashboard
        List<Object[]> estadisticasFacturas = facturaDAO.obtenerEstadisticasFacturacion();
        List<Object[]> estadisticasOrdenes = ordenServicioDAO.obtenerEstadisticasOrdenes();
        int totalVehiculos = vehiculoDAO.contarTotalVehiculos();
        Long vehiculosActivos = vehiculoDAO.countVehiculosActivos();

        // Facturas recientes
        List<Factura> facturasRecientes = facturaDAO.listarFacturasRecientes(10);

        // Órdenes pendientes
        List<OrdenServicio> ordenesPendientes = ordenServicioDAO.listarOrdenesPendientes();

        request.setAttribute("estadisticasFacturas", estadisticasFacturas);
        request.setAttribute("estadisticasOrdenes", estadisticasOrdenes);
        request.setAttribute("totalVehiculos", totalVehiculos);
        request.setAttribute("vehiculosActivos", vehiculosActivos);
        request.setAttribute("facturasRecientes", facturasRecientes);
        request.setAttribute("ordenesPendientes", ordenesPendientes);

        request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/form.jsp").forward(request, response);
    }

    private void handleReportesFinancieros(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros de fecha
        Date fechaInicio = obtenerFechaDesdeRequest(request, "fechaInicio", obtenerPrimerDiaMes());
        Date fechaFin = obtenerFechaDesdeRequest(request, "fechaFin", new Date());

        // Obtener datos financieros
        List<Factura> facturasPeriodo = facturaDAO.listarFacturasPorRangoFechas(fechaInicio, fechaFin);
        BigDecimal totalFacturado = facturaDAO.calcularTotalFacturadoPeriodo(fechaInicio, fechaFin);
        List<Object[]> estadisticas = facturaDAO.obtenerEstadisticasFacturacion();

        // Facturas por estado
        List<Factura> facturasPagadas = facturaDAO.findFacturasPagadas();
        List<Factura> facturasPendientes = facturaDAO.listarFacturasPendientes();

        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("facturasPeriodo", facturasPeriodo);
        request.setAttribute("totalFacturado", totalFacturado);
        request.setAttribute("estadisticas", estadisticas);
        request.setAttribute("facturasPagadas", facturasPagadas);
        request.setAttribute("facturasPendientes", facturasPendientes);

        request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/form.jsp").forward(request, response);
    }

    private void handleReportesProductividad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros de fecha
        Date fechaInicio = obtenerFechaDesdeRequest(request, "fechaInicio", obtenerPrimerDiaMes());
        Date fechaFin = obtenerFechaDesdeRequest(request, "fechaFin", new Date());

        // Obtener datos de productividad
        List<OrdenServicio> ordenesPeriodo = ordenServicioDAO.listarOrdenesPorRangoFechas(fechaInicio, fechaFin);
        List<Object[]> estadisticasOrdenes = ordenServicioDAO.obtenerEstadisticasOrdenes();
        double tiempoPromedio = ordenServicioDAO.calcularTiempoPromedioReparacion();

        // Órdenes por estado
        List<OrdenServicio> ordenesCompletadas = ordenServicioDAO.findOrdenesCompletadas();
        List<OrdenServicio> ordenesPendientes = ordenServicioDAO.listarOrdenesPendientes();
        List<OrdenServicio> ordenesAtrasadas = ordenServicioDAO.findOrdenesAtrasadas();

        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("ordenesPeriodo", ordenesPeriodo);
        request.setAttribute("estadisticasOrdenes", estadisticasOrdenes);
        request.setAttribute("tiempoPromedio", tiempoPromedio);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("ordenesAtrasadas", ordenesAtrasadas);

        request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/form.jsp").forward(request, response);
    }

    private void handleReportesInventarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener datos de vehículos
        int totalVehiculos = vehiculoDAO.contarTotalVehiculos();
        Long vehiculosActivos = vehiculoDAO.countVehiculosActivos();
        List<Object[]> vehiculosPorMarca = vehiculoDAO.obtenerVehiculosPorMarca();
        List<Vehiculo> vehiculosConServicios = vehiculoDAO.listarVehiculosConServiciosActivos();
        List<Vehiculo> todosVehiculos = vehiculoDAO.listarVehiculos();

        request.setAttribute("totalVehiculos", totalVehiculos);
        request.setAttribute("vehiculosActivos", vehiculosActivos);
        request.setAttribute("vehiculosPorMarca", vehiculosPorMarca);
        request.setAttribute("vehiculosConServicios", vehiculosConServicios);
        request.setAttribute("todosVehiculos", todosVehiculos);

        request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/form.jsp").forward(request, response);
    }

    private void handleReportesVehiculos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros de filtro
        String filtroMarca = request.getParameter("marca");
        String filtroEstado = request.getParameter("estado");

        List<Vehiculo> vehiculos;

        if (filtroMarca != null && !filtroMarca.isEmpty()) {
            try {
                int idMarca = Integer.parseInt(filtroMarca);
                vehiculos = vehiculoDAO.filtrarVehiculosPorMarca(idMarca);
            } catch (NumberFormatException e) {
                vehiculos = vehiculoDAO.listarVehiculos();
            }
        } else if (filtroEstado != null && !filtroEstado.isEmpty()) {
            boolean estado = Boolean.parseBoolean(filtroEstado);
            // Filtrar manualmente ya que no existe findByEstado
            List<Vehiculo> todosVehiculos = vehiculoDAO.listarVehiculos();
            vehiculos = todosVehiculos.stream()
                    .filter(v -> v.getEstado() != null && v.getEstado() == estado)
                    .collect(java.util.stream.Collectors.toList());
        } else {
            vehiculos = vehiculoDAO.listarVehiculos();
        }

        List<Object[]> estadisticasMarcas = vehiculoDAO.obtenerVehiculosPorMarca();

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("estadisticasMarcas", estadisticasMarcas);
        request.setAttribute("filtroMarca", filtroMarca);
        request.setAttribute("filtroEstado", filtroEstado);

        request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/form.jsp").forward(request, response);
    }

    private void handleGenerarReporte(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipoReporte = request.getParameter("tipo");
        if (tipoReporte == null) {
            tipoReporte = "financiero";
        }

        // Obtener parámetros de fecha por defecto
        Date fechaInicio = obtenerPrimerDiaMes();
        Date fechaFin = new Date();

        request.setAttribute("tipoReporte", tipoReporte);
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);

        request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/form.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST
    private void handleGenerarReporteFiltrado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipoReporte = request.getParameter("tipoReporte");
        String formato = request.getParameter("formato");
        Date fechaInicio = obtenerFechaDesdeRequest(request, "fechaInicio", obtenerPrimerDiaMes());
        Date fechaFin = obtenerFechaDesdeRequest(request, "fechaFin", new Date());

        try {
            switch (tipoReporte) {
                case "financiero":
                    generarReporteFinanciero(request, response, fechaInicio, fechaFin, formato);
                    break;
                case "productividad":
                    generarReporteProductividad(request, response, fechaInicio, fechaFin, formato);
                    break;
                case "vehiculos":
                    generarReporteVehiculos(request, response, formato);
                    break;
                case "inventario":
                    generarReporteInventario(request, response, formato);
                    break;
                default:
                    request.setAttribute("error", "Tipo de reporte no válido");
                    handleGenerarReporte(request, response);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error generando el reporte: " + e.getMessage());
        }
    }

    private void generarReporteFinanciero(HttpServletRequest request, HttpServletResponse response,
            Date fechaInicio, Date fechaFin, String formato)
            throws ServletException, IOException {

        List<Factura> facturas = facturaDAO.listarFacturasPorRangoFechas(fechaInicio, fechaFin);
        BigDecimal totalFacturado = facturaDAO.calcularTotalFacturadoPeriodo(fechaInicio, fechaFin);
        List<Object[]> estadisticas = facturaDAO.obtenerEstadisticasFacturacion();

        request.setAttribute("facturas", facturas);
        request.setAttribute("totalFacturado", totalFacturado);
        request.setAttribute("estadisticas", estadisticas);
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("tipoReporte", "financiero");

        if ("pdf".equalsIgnoreCase(formato)) {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        }
    }

    private void generarReporteProductividad(HttpServletRequest request, HttpServletResponse response,
            Date fechaInicio, Date fechaFin, String formato)
            throws ServletException, IOException {

        List<OrdenServicio> ordenes = ordenServicioDAO.listarOrdenesPorRangoFechas(fechaInicio, fechaFin);
        List<Object[]> estadisticas = ordenServicioDAO.obtenerEstadisticasOrdenes();
        double tiempoPromedio = ordenServicioDAO.calcularTiempoPromedioReparacion();
        Long ordenesPendientes = ordenServicioDAO.countOrdenesPendientes();

        request.setAttribute("ordenes", ordenes);
        request.setAttribute("estadisticas", estadisticas);
        request.setAttribute("tiempoPromedio", tiempoPromedio);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("fechaInicio", fechaInicio);
        request.setAttribute("fechaFin", fechaFin);
        request.setAttribute("tipoReporte", "productividad");

        if ("pdf".equalsIgnoreCase(formato)) {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        }
    }

    private void generarReporteVehiculos(HttpServletRequest request, HttpServletResponse response, String formato)
            throws ServletException, IOException {

        List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculos();
        List<Object[]> vehiculosPorMarca = vehiculoDAO.obtenerVehiculosPorMarca();
        int totalVehiculos = vehiculoDAO.contarTotalVehiculos();
        Long vehiculosActivos = vehiculoDAO.countVehiculosActivos();

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("vehiculosPorMarca", vehiculosPorMarca);
        request.setAttribute("totalVehiculos", totalVehiculos);
        request.setAttribute("vehiculosActivos", vehiculosActivos);
        request.setAttribute("tipoReporte", "vehiculos");

        if ("pdf".equalsIgnoreCase(formato)) {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        }
    }

    private void generarReporteInventario(HttpServletRequest request, HttpServletResponse response, String formato)
            throws ServletException, IOException {

        List<Vehiculo> vehiculos = vehiculoDAO.listarVehiculos();
        List<Object[]> vehiculosPorMarca = vehiculoDAO.obtenerVehiculosPorMarca();
        List<Vehiculo> vehiculosConServicios = vehiculoDAO.listarVehiculosConServiciosActivos();

        request.setAttribute("vehiculos", vehiculos);
        request.setAttribute("vehiculosPorMarca", vehiculosPorMarca);
        request.setAttribute("vehiculosConServicios", vehiculosConServicios);
        request.setAttribute("tipoReporte", "inventario");

        if ("pdf".equalsIgnoreCase(formato)) {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/pages/admin/reportes/view.jsp").forward(request, response);
        }
    }

    // Métodos auxiliares
    private Date obtenerFechaDesdeRequest(HttpServletRequest request, String paramName, Date defaultValue) {
        String fechaStr = request.getParameter(paramName);
        if (fechaStr != null && !fechaStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                return sdf.parse(fechaStr);
            } catch (ParseException e) {
                return defaultValue;
            }
        }
        return defaultValue;
    }

    private Date obtenerPrimerDiaMes() {
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_MONTH, 1);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/ReporteServlet?action=listar");
        }
    }
}