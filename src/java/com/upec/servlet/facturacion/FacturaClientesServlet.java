package com.upec.servlet.facturacion;

import com.upec.dao.FacturaDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.model.Factura;
import com.upec.model.OrdenServicio;
import com.upec.model.Usuarios;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "FacturaClientesServlet", urlPatterns = {
    "/FacturaClientesServlet",
    "/cliente/facturaclientes",
    "/cliente/facturaclientes/*"
})
public class FacturaClientesServlet extends HttpServlet {

    @Inject
    private FacturaDAO facturaDAO;
    
    @Inject
    private OrdenServicioDAO ordenServicioDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Validación del rol
        String userRole = (String) session.getAttribute("rol");
        Integer idRol = (Integer) session.getAttribute("idRol");
        
        boolean esCliente = ("cliente".equalsIgnoreCase(userRole)) || (idRol != null && idRol == 4);
        
        if (!esCliente) {
            System.out.println("DEBUG - Acceso denegado. rol: " + userRole + ", idRol: " + idRol);
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "misfacturas";
        }

        System.out.println("DEBUG - FacturaClientesServlet GET - action: " + action);

        try {
            switch (action) {
                case "misfacturas":
                case "listar":
                    handleListarFacturas(request, response, session);
                    break;
                case "ver":
                    handleVerFactura(request, response, session);
                    break;
                case "descargar":
                    handleDescargarFactura(request, response, session);
                    break;
                case "buscar":
                    handleBuscarFacturas(request, response, session);
                    break;
                case "filtrar":
                    handleFiltrarFacturas(request, response, session);
                    break;
                case "estados-pago":
                    handleEstadosPago(request, response, session);
                    break;
                default:
                    handleListarFacturas(request, response, session);
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
        Integer idRol = (Integer) session.getAttribute("idRol");
        
        boolean esCliente = ("cliente".equalsIgnoreCase(userRole)) || (idRol != null && idRol == 4);
        
        if (!esCliente) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "listar";
        }

        try {
            switch (action) {
                case "buscar":
                    handleBuscarFacturas(request, response, session);
                    break;
                case "filtrar":
                    handleFiltrarFacturas(request, response, session);
                    break;
                default:
                    handleListarFacturas(request, response, session);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    private Usuarios obtenerUsuarioDeSession(HttpSession session) {
        return (Usuarios) session.getAttribute("usuario");
    }

    // Métodos para manejar las operaciones GET
    private void handleListarFacturas(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        Usuarios usuario = obtenerUsuarioDeSession(session);
        System.out.println("DEBUG - handleListarFacturas - usuario: " + usuario.getUsuario());

        // Obtener todas las facturas del sistema
        List<Factura> todasFacturas = facturaDAO.findAll();
        
        // Filtrar solo las facturas del usuario actual
        List<Factura> facturas = todasFacturas.stream()
                .filter(f -> perteneceAlUsuario(f, usuario))
                .toList();

        // Calcular estadísticas
        double totalFacturado = 0.0;
        long facturasPagadas = 0;
        long facturasPendientes = 0;
        long facturasVencidas = 0;

        for (Factura factura : facturas) {
            if (factura.getTotal() != null) {
                totalFacturado += factura.getTotal().doubleValue();
            }

            if (factura.getIDEstadoFactura() != null) {
                String estado = factura.getIDEstadoFactura().getNombreEstado();
                if ("PAGADA".equalsIgnoreCase(estado)) {
                    facturasPagadas++;
                } else if ("PENDIENTE".equalsIgnoreCase(estado)) {
                    facturasPendientes++;

                    if (factura.getFechaEmision() != null) {
                        long diff = new Date().getTime() - factura.getFechaEmision().getTime();
                        long dias = diff / (1000 * 60 * 60 * 24);
                        if (dias > 30) {
                            facturasVencidas++;
                        }
                    }
                }
            }
        }

        // Obtener facturas recientes
        List<Factura> facturasRecientes = todasFacturas.stream()
                .filter(f -> perteneceAlUsuario(f, usuario))
                .sorted((a, b) -> {
                    if (a.getFechaEmision() == null) return 1;
                    if (b.getFechaEmision() == null) return -1;
                    return b.getFechaEmision().compareTo(a.getFechaEmision());
                })
                .limit(5)
                .toList();

        request.setAttribute("facturas", facturas);
        request.setAttribute("facturasRecientes", facturasRecientes);
        request.setAttribute("totalFacturado", totalFacturado);
        request.setAttribute("facturasPagadas", facturasPagadas);
        request.setAttribute("facturasPendientes", facturasPendientes);
        request.setAttribute("facturasVencidas", facturasVencidas);
        request.setAttribute("tipoVista", "todas");

        // CORRECCIÓN: Ruta corregida - facturacliente (singular)
        request.getRequestDispatcher("/WEB-INF/pages/cliente/facturacliente/list.jsp").forward(request, response);
    }

    private void handleVerFactura(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Usuarios usuario = obtenerUsuarioDeSession(session);
        
        System.out.println("DEBUG - handleVerFactura - id parameter: " + idParam);
        
        if (idParam == null || idParam.isEmpty()) {
            request.setAttribute("error", "Debe especificar el ID de la factura a visualizar");
            handleListarFacturas(request, response, session);
            return;
        }

        try {
            int idFactura = Integer.parseInt(idParam);
            Factura factura = facturaDAO.obtenerFacturaCompleta(idFactura);

            if (factura == null) {
                request.setAttribute("error", "Factura #" + idFactura + " no encontrada");
                handleListarFacturas(request, response, session);
                return;
            }

            // Verificar que la factura pertenece al usuario
            if (!perteneceAlUsuario(factura, usuario)) {
                request.setAttribute("error", "No tiene acceso a esta factura");
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            // Calcular días desde la emisión
            long diasDesdeEmision = 0;
            if (factura.getFechaEmision() != null) {
                long diff = new Date().getTime() - factura.getFechaEmision().getTime();
                diasDesdeEmision = diff / (1000 * 60 * 60 * 24);
            }

            boolean esVencida = false;
            if (factura.getIDEstadoFactura() != null) {
                esVencida = diasDesdeEmision > 30
                        && "PENDIENTE".equalsIgnoreCase(factura.getIDEstadoFactura().getNombreEstado());
            }

            request.setAttribute("factura", factura);
            request.setAttribute("diasDesdeEmision", diasDesdeEmision);
            request.setAttribute("esVencida", esVencida);

            // CORRECCIÓN: Ruta corregida - facturacliente (singular)
            request.getRequestDispatcher("/WEB-INF/pages/cliente/facturacliente/view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de factura inválido: " + idParam);
            handleListarFacturas(request, response, session);
        }
    }

    private void handleDescargarFactura(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        Usuarios usuario = obtenerUsuarioDeSession(session);
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de factura no especificado");
            return;
        }

        try {
            int idFactura = Integer.parseInt(idParam);
            Factura factura = facturaDAO.obtenerFacturaCompleta(idFactura);

            if (factura == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Factura no encontrada");
                return;
            }

            // Verificar que la factura pertenece al usuario
            if (!perteneceAlUsuario(factura, usuario)) {
                response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
                return;
            }

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition",
                    "attachment; filename=\"factura-" + factura.getNumeroFactura() + ".pdf\"");

            generarPDFFactura(factura, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de factura inválido");
        } catch (Exception e) {
            response.setContentType("text/html");
            request.setAttribute("error", "Error al generar el PDF: " + e.getMessage());
            handleVerFactura(request, response, session);
        }
    }

    private void handleBuscarFacturas(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        Usuarios usuario = obtenerUsuarioDeSession(session);
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");

        List<Factura> todasFacturas = facturaDAO.findAll();
        List<Factura> facturasEncontradas;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            switch (criterio) {
                case "numero":
                    facturasEncontradas = facturaDAO.findByNumeroFacturaContaining(valor);
                    break;
                case "orden":
                    try {
                        int idOrden = Integer.parseInt(valor);
                        OrdenServicio orden = ordenServicioDAO.obtenerOrdenPorId(idOrden);
                        if (orden != null && perteneceAlUsuarioOrden(orden, usuario)) {
                            Factura factura = facturaDAO.obtenerFacturaPorOrden(idOrden);
                            facturasEncontradas = factura != null ? List.of(factura) : List.of();
                        } else {
                            facturasEncontradas = List.of();
                        }
                    } catch (NumberFormatException e) {
                        facturasEncontradas = List.of();
                    }
                    break;
                default:
                    facturasEncontradas = todasFacturas;
            }
        } else {
            facturasEncontradas = todasFacturas;
        }

        // Filtrar por usuario
        facturasEncontradas = facturasEncontradas.stream()
                .filter(f -> perteneceAlUsuario(f, usuario))
                .toList();

        request.setAttribute("facturas", facturasEncontradas);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        request.setAttribute("tipoVista", "busqueda");

        // CORRECCIÓN: Ruta corregida - facturacliente (singular)
        request.getRequestDispatcher("/WEB-INF/pages/cliente/facturacliente/list.jsp").forward(request, response);
    }

    private void handleFiltrarFacturas(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        Usuarios usuario = obtenerUsuarioDeSession(session);
        String estadoFiltro = request.getParameter("estado");
        String fechaInicioStr = request.getParameter("fechaInicio");
        String fechaFinStr = request.getParameter("fechaFin");
        String montoMinStr = request.getParameter("montoMin");
        String montoMaxStr = request.getParameter("montoMax");

        List<Factura> todasFacturas = facturaDAO.findAll();
        
        // Filtrar por usuario
        List<Factura> facturasFiltradas = todasFacturas.stream()
                .filter(f -> perteneceAlUsuario(f, usuario))
                .toList();

        try {
            if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
                facturasFiltradas = facturasFiltradas.stream()
                        .filter(f -> f.getIDEstadoFactura() != null && 
                                estadoFiltro.equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                        .toList();
            }

            if (fechaInicioStr != null && !fechaInicioStr.isEmpty()
                    && fechaFinStr != null && !fechaFinStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date fechaInicio = sdf.parse(fechaInicioStr);
                Date fechaFin = sdf.parse(fechaFinStr);

                facturasFiltradas = facturasFiltradas.stream()
                        .filter(f -> f.getFechaEmision() != null
                        && !f.getFechaEmision().before(fechaInicio)
                        && !f.getFechaEmision().after(fechaFin))
                        .toList();
            }

            if (montoMinStr != null && !montoMinStr.isEmpty()
                    && montoMaxStr != null && !montoMaxStr.isEmpty()) {
                double montoMin = Double.parseDouble(montoMinStr);
                double montoMax = Double.parseDouble(montoMaxStr);

                facturasFiltradas = facturasFiltradas.stream()
                        .filter(f -> f.getTotal() != null
                        && f.getTotal().doubleValue() >= montoMin
                        && f.getTotal().doubleValue() <= montoMax)
                        .toList();
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error en los parámetros de filtro: " + e.getMessage());
        }

        request.setAttribute("facturas", facturasFiltradas);
        request.setAttribute("estadoFiltro", estadoFiltro);
        request.setAttribute("fechaInicio", fechaInicioStr);
        request.setAttribute("fechaFin", fechaFinStr);
        request.setAttribute("montoMin", montoMinStr);
        request.setAttribute("montoMax", montoMaxStr);
        request.setAttribute("tipoVista", "filtrado");

        // CORRECCIÓN: Ruta corregida - facturacliente (singular)
        request.getRequestDispatcher("/WEB-INF/pages/cliente/facturacliente/list.jsp").forward(request, response);
    }

    private void handleEstadosPago(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {

        Usuarios usuario = obtenerUsuarioDeSession(session);
        
        List<Factura> todasFacturas = facturaDAO.findAll();
        
        // Filtrar por usuario
        List<Factura> facturasDelUsuario = todasFacturas.stream()
                .filter(f -> perteneceAlUsuario(f, usuario))
                .toList();

        // Separar por estado
        List<Factura> facturasPagadas = facturasDelUsuario.stream()
                .filter(f -> f.getIDEstadoFactura() != null && "PAGADA".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .toList();

        List<Factura> facturasPendientes = facturasDelUsuario.stream()
                .filter(f -> f.getIDEstadoFactura() != null && "PENDIENTE".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado()))
                .toList();

        List<Factura> facturasVencidas = facturasDelUsuario.stream()
                .filter(f -> {
                    if (f.getIDEstadoFactura() == null || !"PENDIENTE".equalsIgnoreCase(f.getIDEstadoFactura().getNombreEstado())) {
                        return false;
                    }
                    if (f.getFechaEmision() != null) {
                        long diff = new Date().getTime() - f.getFechaEmision().getTime();
                        long dias = diff / (1000 * 60 * 60 * 24);
                        return dias > 30;
                    }
                    return false;
                })
                .toList();

        double totalPagado = facturasPagadas.stream()
                .filter(f -> f.getTotal() != null)
                .mapToDouble(f -> f.getTotal().doubleValue())
                .sum();

        double totalPendiente = facturasPendientes.stream()
                .filter(f -> f.getTotal() != null)
                .mapToDouble(f -> f.getTotal().doubleValue())
                .sum();

        double totalVencido = facturasVencidas.stream()
                .filter(f -> f.getTotal() != null)
                .mapToDouble(f -> f.getTotal().doubleValue())
                .sum();

        double saldoPendiente = facturaDAO.calcularSaldoPendienteCliente(
                obtenerIdClienteDeFacturas(facturasDelUsuario)).doubleValue();

        request.setAttribute("facturasPagadas", facturasPagadas);
        request.setAttribute("facturasPendientes", facturasPendientes);
        request.setAttribute("facturasVencidas", facturasVencidas);
        request.setAttribute("totalPagado", totalPagado);
        request.setAttribute("totalPendiente", totalPendiente);
        request.setAttribute("totalVencido", totalVencido);
        request.setAttribute("saldoPendiente", saldoPendiente);
        request.setAttribute("totalFacturas", facturasDelUsuario.size());

        // CORRECCIÓN: Ruta corregida - facturacliente (singular)
        request.getRequestDispatcher("/WEB-INF/pages/cliente/facturacliente/estados-pago.jsp").forward(request, response);
    }

    // Métodos auxiliares
    private boolean perteneceAlUsuario(Factura factura, Usuarios usuario) {
        if (factura == null || usuario == null) {
            return false;
        }
        if (factura.getIDOrdenServicio() == null) {
            return false;
        }
        if (factura.getIDOrdenServicio().getIDVehiculo() == null) {
            return false;
        }
        if (factura.getIDOrdenServicio().getIDVehiculo().getIDCliente() == null) {
            return false;
        }
        
        // Obtener el email del cliente propietario del vehículo
        String emailCliente = factura.getIDOrdenServicio().getIDVehiculo().getIDCliente().getEmail();
        
        // Comparar con el email del usuario actual
        return emailCliente != null && emailCliente.equals(usuario.getEmail());
    }

    private boolean perteneceAlUsuarioOrden(OrdenServicio orden, Usuarios usuario) {
        if (orden == null || usuario == null) {
            return false;
        }
        if (orden.getIDVehiculo() == null) {
            return false;
        }
        if (orden.getIDVehiculo().getIDCliente() == null) {
            return false;
        }
        
        String emailCliente = orden.getIDVehiculo().getIDCliente().getEmail();
        return emailCliente != null && emailCliente.equals(usuario.getEmail());
    }

    private Integer obtenerIdClienteDeFacturas(List<Factura> facturas) {
        if (facturas != null && !facturas.isEmpty()) {
            for (Factura f : facturas) {
                if (f.getIDOrdenServicio() != null && 
                    f.getIDOrdenServicio().getIDVehiculo() != null &&
                    f.getIDOrdenServicio().getIDVehiculo().getIDCliente() != null) {
                    return f.getIDOrdenServicio().getIDVehiculo().getIDCliente().getIDCliente();
                }
            }
        }
        return 0;
    }

    private void generarPDFFactura(Factura factura, HttpServletResponse response) throws IOException {
        String pdfContent = generarContenidoPDF(factura);
        response.getOutputStream().write(pdfContent.getBytes());
        response.getOutputStream().flush();
    }

    private String generarContenidoPDF(Factura factura) {
        StringBuilder pdf = new StringBuilder();
        pdf.append("FACTURA: ").append(factura.getNumeroFactura()).append("\n\n");
        pdf.append("Fecha Emisión: ").append(factura.getFechaEmision()).append("\n");
        if (factura.getIDEstadoFactura() != null) {
            pdf.append("Estado: ").append(factura.getIDEstadoFactura().getNombreEstado()).append("\n");
        }
        pdf.append("\n");
        pdf.append("SUBTOTAL: $").append(factura.getSubtotal() != null ? factura.getSubtotal() : "0.00").append("\n");
        pdf.append("IVA: $").append(factura.getIva() != null ? factura.getIva() : "0.00").append("\n");
        pdf.append("TOTAL: $").append(factura.getTotal() != null ? factura.getTotal() : "0.00").append("\n\n");
        pdf.append("--- Taller Automotriz ---\n");
        pdf.append("Este es un documento generado automáticamente");

        return pdf.toString();
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        try {
            handleListarFacturas(request, response, request.getSession(false));
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/cliente/dashboard");
        }
    }
}