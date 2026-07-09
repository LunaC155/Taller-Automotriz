package com.upec.servlet.services;

import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.FacturaDAO;
import com.upec.dao.VehiculoDAO;
import com.upec.model.OrdenServicio;
import com.upec.model.Factura;
import com.upec.model.Vehiculo;
import jakarta.inject.Inject;
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
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@WebServlet(name = "HistorialServlet", urlPatterns = {
    "/HistorialServlet",
    "/cliente/historial",
    "/cliente/historial/*"
})
public class HistorialServlet extends HttpServlet {

    @Inject
    private OrdenServicioDAO ordenServicioDAO;

    @Inject
    private FacturaDAO facturaDAO;

    @Inject
    private VehiculoDAO vehiculoDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!validarSesion(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "listar";
        }

        System.out.println("DEBUG - HistorialServlet GET - action: " + action);

        try {
            switch (action) {
                case "listar":
                    handleListarHistorial(request, response);
                    break;
                case "ver":
                    handleVerDetalleHistorial(request, response);
                    break;
                case "filtrar":
                    handleFiltrarHistorial(request, response);
                    break;
                case "vehiculo":
                    handleHistorialPorVehiculo(request, response);
                    break;
                case "facturas":
                    handleHistorialFacturas(request, response);
                    break;
                case "estadisticas":
                    handleEstadisticasHistorial(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Acción no válida");
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!validarSesion(request, response)) {
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("filtrar".equals(action)) {
                handleFiltrarHistorial(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Acción no permitida por POST");
            }
        } catch (Exception e) {
            handleError(request, response, e);
        }
    }

    private boolean validarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }

        // Validación mejorada del rol - acepta tanto String como Integer
        String userRole = (String) session.getAttribute("rol");
        Integer idRol = (Integer) session.getAttribute("idRol");
        
        boolean esCliente = ("cliente".equals(userRole)) || (idRol != null && idRol == 4);
        
        if (!esCliente) {
            System.out.println("DEBUG - Acceso denegado. rol: " + userRole + ", idRol: " + idRol);
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return false;
        }

        // Verificar que idCliente esté en la sesión
        Integer idCliente = (Integer) session.getAttribute("idCliente");
        if (idCliente == null) {
            System.out.println("DEBUG - idCliente es null en la sesión");
            request.setAttribute("error", "No se encontró información del cliente en la sesión");
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return false;
        }

        return true;
    }

    private void handleListarHistorial(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");

        List<OrdenServicio> historialOrdenes = ordenServicioDAO.listarOrdenesPorCliente(idCliente);
        List<Factura> historialFacturas = facturaDAO.listarFacturasPorCliente(idCliente);
        List<Vehiculo> vehiculosCliente = vehiculoDAO.listarVehiculosPorCliente(idCliente);

        long totalServicios = historialOrdenes.size();
        long serviciosCompletados = historialOrdenes.stream()
                .filter(orden -> orden.getFechaRealSalida() != null)
                .count();
        long serviciosPendientes = totalServicios - serviciosCompletados;

        request.setAttribute("historialOrdenes", historialOrdenes);
        request.setAttribute("historialFacturas", historialFacturas);
        request.setAttribute("vehiculos", vehiculosCliente);
        request.setAttribute("totalServicios", totalServicios);
        request.setAttribute("serviciosCompletados", serviciosCompletados);
        request.setAttribute("serviciosPendientes", serviciosPendientes);
        request.setAttribute("tipoVista", "completo");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/historial/list.jsp")
                .forward(request, response);
    }

    private void handleVerDetalleHistorial(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        
        System.out.println("DEBUG - handleVerDetalleHistorial - id parameter: " + idParam);
        
        if (idParam == null || idParam.isEmpty()) {
            request.setAttribute("error", "Debe especificar el ID de la orden a visualizar");
            handleListarHistorial(request, response);
            return;
        }

        try {
            int idOrden = Integer.parseInt(idParam);
            Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");

            OrdenServicio orden = ordenServicioDAO.obtenerOrdenCompleta(idOrden);

            if (orden == null) {
                request.setAttribute("error", "Orden #" + idOrden + " no encontrada");
                handleListarHistorial(request, response);
                return;
            }

            if (!validarAccesoClienteOrden(orden, idCliente)) {
                request.setAttribute("error", "No tiene acceso a esta orden de servicio");
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            Factura factura = facturaDAO.obtenerFacturaPorOrden(idOrden);

            request.setAttribute("orden", orden);
            request.setAttribute("factura", factura);

            request.getRequestDispatcher("/WEB-INF/pages/cliente/historial/view.jsp")
                    .forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de orden inválido: " + idParam);
            handleListarHistorial(request, response);
        }
    }

    private void handleFiltrarHistorial(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");

        String tipoFiltro = request.getParameter("tipoFiltro");
        String valorFiltro = request.getParameter("valorFiltro");
        String fechaInicioStr = request.getParameter("fechaInicio");
        String fechaFinStr = request.getParameter("fechaFin");
        String estadoFiltro = request.getParameter("estado");

        List<OrdenServicio> historialBase = ordenServicioDAO.listarOrdenesPorCliente(idCliente);
        List<OrdenServicio> historialFiltrado = historialBase;

        try {
            // Filtrar por tipo (vehículo o problema)
            if (tipoFiltro != null && !tipoFiltro.isEmpty() && valorFiltro != null && !valorFiltro.trim().isEmpty()) {
                switch (tipoFiltro) {
                    case "vehiculo":
                        int idVehiculo = Integer.parseInt(valorFiltro);
                        historialFiltrado = historialFiltrado.stream()
                                .filter(o -> o.getIDVehiculo() != null && o.getIDVehiculo().getIDVehiculo().equals(idVehiculo))
                                .collect(Collectors.toList());
                        break;
                    case "problema":
                        historialFiltrado = historialFiltrado.stream()
                                .filter(o -> o.getProblemaReportado() != null && o.getProblemaReportado().toLowerCase().contains(valorFiltro.toLowerCase()))
                                .collect(Collectors.toList());
                        break;
                }
            }

            // Filtrar por rango de fechas
            if (fechaInicioStr != null && !fechaInicioStr.isEmpty() && fechaFinStr != null && !fechaFinStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaInicio = sdf.parse(fechaInicioStr);
                Date fechaFin = sdf.parse(fechaFinStr);
                historialFiltrado = historialFiltrado.stream()
                        .filter(o -> o.getFechaEntrada() != null && !o.getFechaEntrada().before(fechaInicio) && !o.getFechaEntrada().after(fechaFin))
                        .collect(Collectors.toList());
            }

            // Filtrar por estado
            if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
                if ("completado".equals(estadoFiltro)) {
                    historialFiltrado = historialFiltrado.stream()
                            .filter(orden -> orden.getFechaRealSalida() != null)
                            .collect(Collectors.toList());
                } else if ("pendiente".equals(estadoFiltro)) {
                    historialFiltrado = historialFiltrado.stream()
                            .filter(orden -> orden.getFechaRealSalida() == null)
                            .collect(Collectors.toList());
                }
            }

        } catch (ParseException | NumberFormatException e) {
            request.setAttribute("error", "Error en los parámetros de filtro: " + e.getMessage());
            historialFiltrado = historialBase;
        }

        List<Vehiculo> vehiculosCliente = vehiculoDAO.listarVehiculosPorCliente(idCliente);

        request.setAttribute("historialOrdenes", historialFiltrado);
        request.setAttribute("vehiculos", vehiculosCliente);
        request.setAttribute("tipoFiltro", tipoFiltro);
        request.setAttribute("valorFiltro", valorFiltro);
        request.setAttribute("fechaInicio", fechaInicioStr);
        request.setAttribute("fechaFin", fechaFinStr);
        request.setAttribute("estado", estadoFiltro);
        request.setAttribute("tipoVista", "filtrado");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/historial/list.jsp")
                .forward(request, response);
    }

    private void handleHistorialPorVehiculo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
        String idVehiculoParam = request.getParameter("idVehiculo");

        List<Vehiculo> vehiculosCliente = vehiculoDAO.listarVehiculosPorCliente(idCliente);
        Vehiculo vehiculoSeleccionado = null;
        List<OrdenServicio> historialVehiculo = List.of();

        if (idVehiculoParam != null && !idVehiculoParam.isEmpty()) {
            try {
                int idVehiculo = Integer.parseInt(idVehiculoParam);

                vehiculoSeleccionado = vehiculosCliente.stream()
                        .filter(v -> v.getIDVehiculo().equals(idVehiculo))
                        .findFirst()
                        .orElse(null);

                if (vehiculoSeleccionado != null) {
                    historialVehiculo = ordenServicioDAO.listarOrdenesPorVehiculo(idVehiculo);
                } else {
                    request.setAttribute("error", "Vehículo no encontrado o no tiene acceso");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "ID de vehículo inválido");
            }
        } else if (!vehiculosCliente.isEmpty()) {
            vehiculoSeleccionado = vehiculosCliente.get(0);
            historialVehiculo = ordenServicioDAO.listarOrdenesPorVehiculo(vehiculoSeleccionado.getIDVehiculo());
        }

        double totalInvertido = 0;
        Date ultimoServicio = null;
        if (!historialVehiculo.isEmpty()) {
            ultimoServicio = historialVehiculo.stream()
                    .map(OrdenServicio::getFechaEntrada)
                    .filter(Objects::nonNull)
                    .max(Comparator.naturalOrder())
                    .orElse(null);

            for (OrdenServicio orden : historialVehiculo) {
                Factura f = facturaDAO.obtenerFacturaPorOrden(orden.getIDOrdenServicio());
                if (f != null && f.getTotal() != null) {
                    totalInvertido += f.getTotal().doubleValue();
                }
            }
        }

        request.setAttribute("historialOrdenes", historialVehiculo);
        request.setAttribute("vehiculos", vehiculosCliente);
        request.setAttribute("vehiculoSeleccionado", vehiculoSeleccionado);
        request.setAttribute("totalServiciosVehiculo", (long) historialVehiculo.size());
        request.setAttribute("serviciosCompletadosVehiculo", historialVehiculo.stream().filter(o -> o.getFechaRealSalida() != null).count());
        request.setAttribute("totalInvertido", totalInvertido);
        request.setAttribute("ultimoServicio", ultimoServicio);
        request.setAttribute("tipoVista", "por-vehiculo");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/historial/vehiculo.jsp")
                .forward(request, response);
    }

    private void handleHistorialFacturas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");

        List<Factura> historialFacturas = facturaDAO.listarFacturasPorCliente(idCliente);

        double totalFacturado = historialFacturas.stream()
                .map(Factura::getTotal)
                .filter(Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();

        long facturasPagadasCount = historialFacturas.stream()
                .filter(f -> f.getIDEstadoFactura() != null && "PAGADA".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .count();

        long facturasPendientesCount = historialFacturas.stream()
                .filter(f -> f.getIDEstadoFactura() != null && "PENDIENTE".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .count();

        double totalPagado = historialFacturas.stream()
                .filter(f -> f.getIDEstadoFactura() != null && "PAGADA".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .map(Factura::getTotal)
                .filter(Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();

        double totalPendiente = historialFacturas.stream()
                .filter(f -> f.getIDEstadoFactura() != null && "PENDIENTE".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .map(Factura::getTotal)
                .filter(Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();

        request.setAttribute("historialFacturas", historialFacturas);
        request.setAttribute("totalFacturado", totalFacturado);
        request.setAttribute("facturasPagadas", facturasPagadasCount);
        request.setAttribute("facturasPendientes", facturasPendientesCount);
        request.setAttribute("totalPagado", totalPagado);
        request.setAttribute("totalPendiente", totalPendiente);
        request.setAttribute("tipoVista", "facturas");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/historial/facturas.jsp")
                .forward(request, response);
    }

    private void handleEstadisticasHistorial(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");

        List<OrdenServicio> historialOrdenes = ordenServicioDAO.listarOrdenesPorCliente(idCliente);
        List<Factura> historialFacturas = facturaDAO.listarFacturasPorCliente(idCliente);
        List<Vehiculo> vehiculosCliente = vehiculoDAO.listarVehiculosPorCliente(idCliente);

        long totalServicios = historialOrdenes.size();
        long serviciosCompletados = historialOrdenes.stream()
                .filter(orden -> orden.getFechaRealSalida() != null)
                .count();
        long serviciosPendientes = totalServicios - serviciosCompletados;

        double tiempoPromedioReparacion = ordenServicioDAO.calcularTiempoPromedioReparacion();

        List<Object[]> serviciosPorVehiculo = vehiculosCliente.stream()
                .map(vehiculo -> {
                    long count = historialOrdenes.stream()
                            .filter(o -> o.getIDVehiculo() != null && o.getIDVehiculo().getIDVehiculo().equals(vehiculo.getIDVehiculo()))
                            .count();
                    return new Object[]{vehiculo.getPlaca(), count};
                })
                .collect(Collectors.toList());

        double totalFacturado = historialFacturas.stream()
                .map(Factura::getTotal)
                .filter(Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();

        double promedioFactura = historialFacturas.isEmpty() ? 0 : totalFacturado / historialFacturas.size();

        request.setAttribute("totalServicios", totalServicios);
        request.setAttribute("serviciosCompletados", serviciosCompletados);
        request.setAttribute("serviciosPendientes", serviciosPendientes);
        request.setAttribute("tiempoPromedioReparacion", tiempoPromedioReparacion);
        request.setAttribute("serviciosPorVehiculo", serviciosPorVehiculo);
        request.setAttribute("totalFacturado", totalFacturado);
        request.setAttribute("promedioFactura", promedioFactura);
        request.setAttribute("totalVehiculos", vehiculosCliente.size());
        request.setAttribute("totalFacturas", historialFacturas.size());

        request.getRequestDispatcher("/WEB-INF/pages/cliente/historial/estadisticas.jsp")
                .forward(request, response);
    }

    private boolean validarAccesoClienteOrden(OrdenServicio orden, Integer idCliente) {
        return orden.getIDVehiculo() != null
                && orden.getIDVehiculo().getIDCliente() != null
                && orden.getIDVehiculo().getIDCliente().getIDCliente().equals(idCliente);
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, Exception e)
            throws ServletException, IOException {
        e.printStackTrace();
        request.setAttribute("error", "Ha ocurrido un error inesperado: " + e.getMessage());
        
        try {
            handleListarHistorial(request, response);
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/cliente/dashboard");
        }
    }
}