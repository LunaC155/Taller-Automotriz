package com.upec.servlet.services;

import com.upec.dao.ServicioDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.model.Servicio;
import com.upec.model.OrdenServicio;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "ServicioServlet", urlPatterns = {"/cliente/servicios/*",
    "/ServicioServlet"})
public class ServicioServlet extends HttpServlet {

    @Inject
private ServicioDAO servicioDAO;

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

        Integer idRol = (Integer) session.getAttribute("idRol");
        if (idRol == null || idRol != 4) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "listar";
        }

        try {
            switch (action) {
                case "listar":
                    handleListarServicios(request, response);
                    break;
                case "misservicios":
                    handleMisServicios(request, response);
                    break;
                case "ver":
                    handleVerServicio(request, response);
                    break;
                case "catalogo":
                    handleCatalogoServicios(request, response);
                    break;
                case "buscar":
                    handleBuscarServicios(request, response);
                    break;
                case "estado-reparacion":
                    handleEstadoReparacion(request, response);
                    break;
                default:
                    handleListarServicios(request, response);
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

        Integer idRol = (Integer) session.getAttribute("idRol");
        if (idRol == null || idRol != 4) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("buscar".equals(action)) {
                handleBuscarServicios(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET
    private void handleListarServicios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Servicio> servicios = servicioDAO.findAll();
        servicios = servicios.stream()
                .filter(Servicio::getEstado)
                .collect(Collectors.toList());

        request.setAttribute("servicios", servicios);
        request.setAttribute("tipoVista", "todos");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/servicio/list.jsp").forward(request, response);
    }

    private void handleMisServicios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
        if (idCliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<OrdenServicio> misOrdenes = ordenServicioDAO.listarOrdenesPorCliente(idCliente);

        List<OrdenServicio> ordenesPendientes = misOrdenes.stream()
                .filter(orden -> orden.getFechaRealSalida() == null)
                .collect(Collectors.toList());

        List<OrdenServicio> ordenesCompletadas = misOrdenes.stream()
                .filter(orden -> orden.getFechaRealSalida() != null)
                .collect(Collectors.toList());

        List<Servicio> serviciosPopulares = servicioDAO.findAll().stream()
                .filter(Servicio::getEstado)
                .limit(5)
                .collect(Collectors.toList());

        request.setAttribute("ordenes", misOrdenes);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("ordenesCompletadas", ordenesCompletadas);
        request.setAttribute("serviciosPopulares", serviciosPopulares);
        request.setAttribute("tipoVista", "mis-servicios");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/servicio/mis-servicios.jsp").forward(request, response);
    }

    private void handleVerServicio(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de servicio no especificado");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            Servicio servicio = servicioDAO.findById(id);

            if (servicio == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Servicio no encontrado");
                return;
            }

            if (!servicio.getEstado()) {
                request.setAttribute("error", "Este servicio no está disponible actualmente");
                handleListarServicios(request, response);
                return;
            }

            List<Servicio> serviciosRelacionados = servicioDAO.findAll().stream()
                    .filter(s -> s.getEstado() && !s.getIDServicio().equals(servicio.getIDServicio()))
                    .filter(s -> s.getPrecioBase() != null && servicio.getPrecioBase() != null)
                    .filter(s -> Math.abs(s.getPrecioBase().doubleValue() - servicio.getPrecioBase().doubleValue()) <= 50)
                    .limit(4)
                    .collect(Collectors.toList());

            request.setAttribute("servicio", servicio);
            request.setAttribute("serviciosRelacionados", serviciosRelacionados);

            request.getRequestDispatcher("/WEB-INF/pages/cliente/servicio/view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de servicio inválido");
        }
    }

    private void handleCatalogoServicios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Servicio> servicios = servicioDAO.findAll().stream()
                .filter(Servicio::getEstado)
                .collect(Collectors.toList());

        List<Servicio> serviciosPopulares = servicios.stream()
                .limit(5)
                .collect(Collectors.toList());

        List<Servicio> serviciosEconomicos = servicios.stream()
                .filter(s -> s.getPrecioBase() != null && s.getPrecioBase().doubleValue() <= 100)
                .collect(Collectors.toList());
        List<Servicio> serviciosMedios = servicios.stream()
                .filter(s -> s.getPrecioBase() != null && s.getPrecioBase().doubleValue() > 100 && s.getPrecioBase().doubleValue() <= 300)
                .collect(Collectors.toList());
        List<Servicio> serviciosPremium = servicios.stream()
                .filter(s -> s.getPrecioBase() != null && s.getPrecioBase().doubleValue() > 300)
                .collect(Collectors.toList());

        request.setAttribute("servicios", servicios);
        request.setAttribute("serviciosPopulares", serviciosPopulares);
        request.setAttribute("serviciosEconomicos", serviciosEconomicos);
        request.setAttribute("serviciosMedios", serviciosMedios);
        request.setAttribute("serviciosPremium", serviciosPremium);
        request.setAttribute("tipoVista", "catalogo");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/servicio/catalogo.jsp").forward(request, response);
    }

    private void handleBuscarServicios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        String precioMinStr = request.getParameter("precioMin");
        String precioMaxStr = request.getParameter("precioMax");

        List<Servicio> serviciosFiltrados = servicioDAO.findAll().stream()
                .filter(Servicio::getEstado)
                .collect(Collectors.toList());

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            final String searchValue = valor.toLowerCase();
            switch (criterio) {
                case "nombre":
                    serviciosFiltrados = serviciosFiltrados.stream()
                            .filter(s -> s.getNombreServicio().toLowerCase().contains(searchValue))
                            .collect(Collectors.toList());
                    break;
                case "descripcion":
                    serviciosFiltrados = serviciosFiltrados.stream()
                            .filter(s -> s.getDescripcion() != null && s.getDescripcion().toLowerCase().contains(searchValue))
                            .collect(Collectors.toList());
                    break;
            }
        } else if (precioMinStr != null && precioMaxStr != null
                && !precioMinStr.isEmpty() && !precioMaxStr.isEmpty()) {
            try {
                double precioMin = Double.parseDouble(precioMinStr);
                double precioMax = Double.parseDouble(precioMaxStr);
                serviciosFiltrados = serviciosFiltrados.stream()
                        .filter(s -> s.getPrecioBase() != null)
                        .filter(s -> s.getPrecioBase().doubleValue() >= precioMin && s.getPrecioBase().doubleValue() <= precioMax)
                        .collect(Collectors.toList());
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Rango de precios inválido");
            }
        }

        request.setAttribute("servicios", serviciosFiltrados);
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        request.setAttribute("precioMin", precioMinStr);
        request.setAttribute("precioMax", precioMaxStr);
        request.setAttribute("tipoVista", "busqueda");

        request.getRequestDispatcher("/WEB-INF/pages/cliente/servicio/list.jsp").forward(request, response);
    }

    private void handleEstadoReparacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idCliente = (Integer) request.getSession().getAttribute("idCliente");
        if (idCliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String idOrdenParam = request.getParameter("id");

        if (idOrdenParam != null && !idOrdenParam.isEmpty()) {
            try {
                int idOrden = Integer.parseInt(idOrdenParam);
                OrdenServicio orden = ordenServicioDAO.obtenerOrdenPorId(idOrden);

                if (orden != null && validarAccesoClienteOrden(orden, idCliente)) {
                    List<Servicio> serviciosOrden = servicioDAO.findAll().stream()
                            .filter(Servicio::getEstado)
                            .limit(3)
                            .collect(Collectors.toList());

                    request.setAttribute("orden", orden);
                    request.setAttribute("servicios", serviciosOrden);
                    request.setAttribute("tipoVista", "detalle-orden");
                } else {
                    request.setAttribute("error", "No tiene acceso a esta orden de servicio");
                    handleMisServicios(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "ID de orden inválido");
                handleMisServicios(request, response);
                return;
            }
        } else {
            List<OrdenServicio> misOrdenes = ordenServicioDAO.listarOrdenesPorCliente(idCliente);

            long totalOrdenes = misOrdenes.size();
            long ordenesPendientes = misOrdenes.stream()
                    .filter(orden -> orden.getFechaRealSalida() == null)
                    .count();
            long ordenesCompletadas = misOrdenes.stream()
                    .filter(orden -> orden.getFechaRealSalida() != null)
                    .count();
            long ordenesAtrasadas = misOrdenes.stream()
                    .filter(orden -> orden.getFechaRealSalida() == null
                    && orden.getFechaEstimadaSalida() != null
                    && orden.getFechaEstimadaSalida().before(new java.util.Date()))
                    .count();

            request.setAttribute("ordenes", misOrdenes);
            request.setAttribute("totalOrdenes", totalOrdenes);
            request.setAttribute("ordenesPendientes", ordenesPendientes);
            request.setAttribute("ordenesCompletadas", ordenesCompletadas);
            request.setAttribute("ordenesAtrasadas", ordenesAtrasadas);
            request.setAttribute("tipoVista", "estado-general");
        }

        request.getRequestDispatcher("/WEB-INF/pages/cliente/servicio/estado-reparacion.jsp").forward(request, response);
    }

    private boolean validarAccesoClienteOrden(OrdenServicio orden, Integer idCliente) {
        return orden.getIDVehiculo() != null
                && orden.getIDVehiculo().getIDCliente() != null
                && orden.getIDVehiculo().getIDCliente().getIDCliente().equals(idCliente);
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response,
            Exception e, String errorMessage) throws ServletException, IOException {

        e.printStackTrace();
        request.setAttribute("error", errorMessage);

        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/cliente/servicios?action=listar");
        }
    }

    @Override
    public void destroy() {
        // Cleanup resources if needed
    }
}
