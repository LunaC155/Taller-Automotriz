package com.upec.servlet.facturacion;

import com.upec.dao.FacturaDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.dao.EstadoFacturaDAO;
import com.upec.model.Factura;
import com.upec.model.OrdenServicio;
import com.upec.model.EstadoFactura;
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
import java.util.Date;
import java.util.List;

@WebServlet(name = "FacturaServlet", urlPatterns = {
    "/FacturaServlet",
    "/recepcionista/facturas",
    "/recepcionista/facturas/generar",
    "/recepcionista/facturas/ver",
    "/recepcionista/facturas/editar",
    "/recepcionista/facturas/buscar",
    "/recepcionista/facturas/pendientes",
    "/recepcionista/facturas/hoy",
    "/recepcionista/facturas/cambiar-estado",
    "/recepcionista/facturas/estadisticas"
})
public class FacturaServlet extends HttpServlet {

    @Inject
    private FacturaDAO facturaDAO;

    @Inject
    private OrdenServicioDAO ordenServicioDAO;

    @Inject
    private EstadoFacturaDAO estadoFacturaDAO;

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
                    handleListarFacturas(request, response);
                    break;
                case "generar":
                    handleGenerarFacturaForm(request, response);
                    break;
                case "ver":
                    handleVerFactura(request, response);
                    break;
                case "editar":
                    handleEditarFacturaForm(request, response);
                    break;
                case "buscar":
                    handleBuscarFacturas(request, response);
                    break;
                case "pendientes":
                    handleFacturasPendientes(request, response);
                    break;
                case "hoy":
                    handleFacturasHoy(request, response);
                    break;
                case "estadisticas":
                    handleEstadisticasFacturas(request, response);
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
                case "generar":
                    handleGenerarFactura(request, response);
                    break;
                case "editar":
                    handleEditarFactura(request, response);
                    break;
                case "cambiar-estado":
                    handleCambiarEstadoFactura(request, response);
                    break;
                case "buscar":
                    handleBuscarFacturas(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarFacturas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Factura> facturas = facturaDAO.listarFacturas();
        
        // Obtener estadísticas para el dashboard
        int totalFacturas = facturas.size();
        int facturasPendientes = facturaDAO.listarFacturasPendientes().size();
        int facturasHoy = facturaDAO.listarFacturasPorFecha(new Date()).size();
        List<Object[]> estadisticas = facturaDAO.obtenerEstadisticasFacturacion();

        request.setAttribute("facturas", facturas);
        request.setAttribute("totalFacturas", totalFacturas);
        request.setAttribute("facturasPendientes", facturasPendientes);
        request.setAttribute("facturasHoy", facturasHoy);
        request.setAttribute("estadisticas", estadisticas);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/list.jsp").forward(request, response);
    }

    private void handleGenerarFacturaForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Cargar datos necesarios para el formulario
        List<OrdenServicio> ordenesSinFactura = obtenerOrdenesSinFactura();
        List<EstadoFactura> estadosFactura = estadoFacturaDAO.listarEstadosFactura();
        
        // Generar número de factura automático
        String numeroFactura = facturaDAO.generarNumeroFactura();

        request.setAttribute("ordenes", ordenesSinFactura);
        request.setAttribute("estados", estadosFactura);
        request.setAttribute("numeroFactura", numeroFactura);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/form.jsp").forward(request, response);
    }

    private void handleVerFactura(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de factura no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Factura factura = facturaDAO.obtenerFacturaCompleta(id);
        
        if (factura == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Factura no encontrada");
            return;
        }

        request.setAttribute("factura", factura);
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/view.jsp").forward(request, response);
    }

    private void handleEditarFacturaForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de factura no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Factura factura = facturaDAO.obtenerFacturaPorId(id);
        
        if (factura == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Factura no encontrada");
            return;
        }

        // Cargar datos necesarios para el formulario
        List<EstadoFactura> estadosFactura = estadoFacturaDAO.listarEstadosFactura();

        request.setAttribute("factura", factura);
        request.setAttribute("estados", estadosFactura);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/form.jsp").forward(request, response);
    }

    private void handleBuscarFacturas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        String fechaInicioStr = request.getParameter("fechaInicio");
        String fechaFinStr = request.getParameter("fechaFin");
        
        List<Factura> facturasFiltradas;

        try {
            if (criterio != null && valor != null && !valor.trim().isEmpty()) {
                switch (criterio) {
                    case "numero":
                        facturasFiltradas = facturaDAO.findByNumeroFacturaContaining(valor);
                        break;
                    case "cliente":
                        // Buscar facturas por cliente
                        int idCliente = Integer.parseInt(valor);
                        facturasFiltradas = facturaDAO.listarFacturasPorCliente(idCliente);
                        break;
                    case "orden":
                        int idOrden = Integer.parseInt(valor);
                        facturasFiltradas = facturaDAO.findByOrdenServicio(idOrden);
                        break;
                    case "estado":
                        int idEstado = Integer.parseInt(valor);
                        facturasFiltradas = facturaDAO.findByEstadoFactura(idEstado);
                        break;
                    default:
                        facturasFiltradas = facturaDAO.listarFacturas();
                }
            } else if (fechaInicioStr != null && fechaFinStr != null && 
                      !fechaInicioStr.isEmpty() && !fechaFinStr.isEmpty()) {
                // Filtrar por rango de fechas
                Date fechaInicio = new SimpleDateFormat("yyyy-MM-dd").parse(fechaInicioStr);
                Date fechaFin = new SimpleDateFormat("yyyy-MM-dd").parse(fechaFinStr);
                facturasFiltradas = facturaDAO.listarFacturasPorRangoFechas(fechaInicio, fechaFin);
            } else {
                facturasFiltradas = facturaDAO.listarFacturas();
            }

            request.setAttribute("facturas", facturasFiltradas);
            request.setAttribute("criterio", criterio);
            request.setAttribute("valor", valor);
            request.setAttribute("fechaInicio", fechaInicioStr);
            request.setAttribute("fechaFin", fechaFinStr);
            
        } catch (ParseException e) {
            request.setAttribute("error", "Formato de fecha inválido");
            facturasFiltradas = facturaDAO.listarFacturas();
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Valor numérico inválido");
            facturasFiltradas = facturaDAO.listarFacturas();
        }

        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/list.jsp").forward(request, response);
    }

    private void handleFacturasPendientes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Factura> facturasPendientes = facturaDAO.listarFacturasPendientes();
        
        request.setAttribute("facturas", facturasPendientes);
        request.setAttribute("filtro", "pendientes");
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/list.jsp").forward(request, response);
    }

    private void handleFacturasHoy(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Factura> facturasHoy = facturaDAO.listarFacturasPorFecha(new Date());
        
        request.setAttribute("facturas", facturasHoy);
        request.setAttribute("filtro", "hoy");
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/list.jsp").forward(request, response);
    }

    private void handleEstadisticasFacturas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Obtener estadísticas detalladas
        List<Object[]> estadisticas = facturaDAO.obtenerEstadisticasFacturacion();
        List<Object[]> facturasPorEstado = estadoFacturaDAO.contarFacturasPorEstado();
        
        // Calcular totales del mes actual
        Date primerDiaMes = obtenerPrimerDiaMes();
        Date ultimoDiaMes = obtenerUltimoDiaMes();
        BigDecimal totalFacturadoMes = facturaDAO.calcularTotalFacturadoPeriodo(primerDiaMes, ultimoDiaMes);
        
        // Facturas recientes
        List<Factura> facturasRecientes = facturaDAO.listarFacturasRecientes(10);

        request.setAttribute("estadisticas", estadisticas);
        request.setAttribute("facturasPorEstado", facturasPorEstado);
        request.setAttribute("totalFacturadoMes", totalFacturadoMes);
        request.setAttribute("facturasRecientes", facturasRecientes);
        request.setAttribute("mesActual", new SimpleDateFormat("MMMM yyyy").format(new Date()));
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/estadisticas.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST

    private void handleGenerarFactura(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Factura factura = extractFacturaFromRequest(request);
        
        // Validar que la orden no tenga ya una factura
        if (factura.getIDOrdenServicio() != null) {
            boolean existeFactura = facturaDAO.existeFacturaParaOrden(factura.getIDOrdenServicio().getIDOrdenServicio());
            if (existeFactura) {
                request.setAttribute("error", "La orden de servicio ya tiene una factura asociada");
                handleGenerarFacturaForm(request, response);
                return;
            }
        }

        // Validar número de factura único
        if (factura.getNumeroFactura() != null && !factura.getNumeroFactura().isEmpty()) {
            boolean numeroExiste = facturaDAO.numeroFacturaExists(factura.getNumeroFactura());
            if (numeroExiste) {
                request.setAttribute("error", "El número de factura ya existe");
                handleGenerarFacturaForm(request, response);
                return;
            }
        }

        // Fecha de emisión actual
        factura.setFechaEmision(new Date());

        // Calcular totales si no se proporcionan
        if (factura.getSubtotal() == null) {
            factura.setSubtotal(BigDecimal.ZERO);
        }
        if (factura.getIva() == null) {
            // Calcular IVA (19% por defecto)
            BigDecimal iva = factura.getSubtotal().multiply(new BigDecimal("0.19"));
            factura.setIva(iva);
        }
        if (factura.getTotal() == null) {
            // Calcular total
            BigDecimal total = factura.getSubtotal().add(factura.getIva());
            factura.setTotal(total);
        }

        facturaDAO.crearFactura(factura);
        request.getSession().setAttribute("mensaje", "Factura generada exitosamente");
        response.sendRedirect(request.getContextPath() + "/recepcionista/facturas");
    }

    private void handleEditarFactura(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("idFactura");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de factura no especificado");
            return;
        }

        int id = Integer.parseInt(idParam);
        Factura facturaExistente = facturaDAO.obtenerFacturaPorId(id);
        
        if (facturaExistente == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Factura no encontrada");
            return;
        }

        // Actualizar campos editables
        Factura facturaActualizada = extractFacturaFromRequest(request);
        facturaExistente.setNumeroFactura(facturaActualizada.getNumeroFactura());
        facturaExistente.setIDEstadoFactura(facturaActualizada.getIDEstadoFactura());
        facturaExistente.setSubtotal(facturaActualizada.getSubtotal());
        facturaExistente.setIva(facturaActualizada.getIva());
        facturaExistente.setTotal(facturaActualizada.getTotal());

        // Validar número de factura único (excluyendo la propia factura)
        if (facturaExistente.getNumeroFactura() != null && !facturaExistente.getNumeroFactura().isEmpty()) {
            Factura facturaConMismoNumero = facturaDAO.findByNumeroFactura(facturaExistente.getNumeroFactura());
            if (facturaConMismoNumero != null && 
                !facturaConMismoNumero.getIDFactura().equals(facturaExistente.getIDFactura())) {
                request.setAttribute("error", "El número de factura ya está en uso por otra factura");
                request.setAttribute("factura", facturaExistente);
                
                List<EstadoFactura> estadosFactura = estadoFacturaDAO.listarEstadosFactura();
                request.setAttribute("estados", estadosFactura);
                
                request.getRequestDispatcher("/WEB-INF/pages/recepcionista/factura/form.jsp").forward(request, response);
                return;
            }
        }

        facturaDAO.actualizarFactura(facturaExistente);
        request.getSession().setAttribute("mensaje", "Factura actualizada exitosamente");
        response.sendRedirect(request.getContextPath() + "/recepcionista/facturas");
    }

    private void handleCambiarEstadoFactura(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idFacturaParam = request.getParameter("idFactura");
        String idEstadoParam = request.getParameter("idEstadoFactura");
        
        if (idFacturaParam == null || idEstadoParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Datos incompletos");
            return;
        }

        int idFactura = Integer.parseInt(idFacturaParam);
        int idEstado = Integer.parseInt(idEstadoParam);

        if (facturaDAO.cambiarEstadoFactura(idFactura, idEstado)) {
            request.getSession().setAttribute("mensaje", "Estado de factura actualizado exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al actualizar el estado de la factura");
        }
        
        response.sendRedirect(request.getContextPath() + "/recepcionista/facturas");
    }

    // Métodos auxiliares

    private Factura extractFacturaFromRequest(HttpServletRequest request) {
        Factura factura = new Factura();
        
        String idParam = request.getParameter("idFactura");
        if (idParam != null && !idParam.isEmpty()) {
            factura.setIDFactura(Integer.parseInt(idParam));
        }
        
        // Número de factura
        factura.setNumeroFactura(request.getParameter("numeroFactura"));
        
        // Orden de servicio
        String idOrdenParam = request.getParameter("idOrdenServicio");
        if (idOrdenParam != null && !idOrdenParam.isEmpty()) {
            OrdenServicio orden = ordenServicioDAO.obtenerOrdenPorId(Integer.parseInt(idOrdenParam));
            factura.setIDOrdenServicio(orden);
        }
        
        // Estado de factura
        String idEstadoParam = request.getParameter("idEstadoFactura");
        if (idEstadoParam != null && !idEstadoParam.isEmpty()) {
            EstadoFactura estado = estadoFacturaDAO.obtenerEstadoPorId(Integer.parseInt(idEstadoParam));
            factura.setIDEstadoFactura(estado);
        }
        
        // Totales
        String subtotalParam = request.getParameter("subtotal");
        if (subtotalParam != null && !subtotalParam.isEmpty()) {
            factura.setSubtotal(new BigDecimal(subtotalParam));
        }
        
        String ivaParam = request.getParameter("iva");
        if (ivaParam != null && !ivaParam.isEmpty()) {
            factura.setIva(new BigDecimal(ivaParam));
        }
        
        String totalParam = request.getParameter("total");
        if (totalParam != null && !totalParam.isEmpty()) {
            factura.setTotal(new BigDecimal(totalParam));
        }

        return factura;
    }

    private List<OrdenServicio> obtenerOrdenesSinFactura() {
        List<OrdenServicio> todasLasOrdenes = ordenServicioDAO.listarOrdenes();
        
        // Filtrar órdenes que no tienen factura
        return todasLasOrdenes.stream()
            .filter(orden -> !facturaDAO.existeFacturaParaOrden(orden.getIDOrdenServicio()))
            .toList();
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

    private Date obtenerUltimoDiaMes() {
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.set(java.util.Calendar.DAY_OF_MONTH, calendar.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 23);
        calendar.set(java.util.Calendar.MINUTE, 59);
        calendar.set(java.util.Calendar.SECOND, 59);
        calendar.set(java.util.Calendar.MILLISECOND, 999);
        return calendar.getTime();
    }

    private String getActionFromPath(String path) {
        if (path.endsWith("/generar")) return "generar";
        if (path.endsWith("/ver")) return "ver";
        if (path.endsWith("/editar")) return "editar";
        if (path.endsWith("/buscar")) return "buscar";
        if (path.endsWith("/pendientes")) return "pendientes";
        if (path.endsWith("/hoy")) return "hoy";
        if (path.endsWith("/cambiar-estado")) return "cambiar-estado";
        if (path.endsWith("/estadisticas")) return "estadisticas";
        
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
            response.sendRedirect(request.getContextPath() + "/recepcionista/facturas");
        }
    }
}