package com.upec.servlet.citas;

import com.upec.dao.ClienteDAO;
import com.upec.dao.OrdenServicioDAO;
import com.upec.model.Cliente;
import com.upec.model.OrdenServicio;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.List;

@WebServlet(name = "AtencionServlet", urlPatterns = {
    "/AtencionServlet",
    "/recepcionista/atencion",
    "/recepcionista/atencion/clientes",
    "/recepcionista/atencion/consultas",
    "/recepcionista/atencion/quejas",
    "/recepcionista/atencion/seguimiento",
    "/recepcionista/atencion/historial",
    "/recepcionista/atencion/buscar"
})
public class AtencionServlet extends HttpServlet {

    @Inject
    private ClienteDAO clienteDAO;
    
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

        String userRole = (String) session.getAttribute("rol");
        if (!"recepcionista".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String path = request.getServletPath();
        String action = getActionFromPath(path);

        try {
            switch (action) {
                case "dashboard":
                    handleDashboardAtencion(request, response);
                    break;
                case "clientes":
                    handleGestionClientes(request, response);
                    break;
                case "consultas":
                    handleGestionConsultas(request, response);
                    break;
                case "quejas":
                    handleGestionQuejas(request, response);
                    break;
                case "seguimiento":
                    handleSeguimientoClientes(request, response);
                    break;
                case "historial":
                    handleHistorialCliente(request, response);
                    break;
                case "buscar":
                    handleBuscarAtencion(request, response);
                    break;
                default:
                    handleDashboardAtencion(request, response);
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
                case "buscar":
                    handleBuscarAtencion(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleDashboardAtencion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Obtener estadísticas para el dashboard de atención al cliente
        int totalClientes = clienteDAO.contarTotalClientes();
        int clientesNuevosMes = clienteDAO.contarClientesNuevosEsteMes();
        
        // Usar métodos existentes del DAO
        List<OrdenServicio> ordenesPendientesList = ordenServicioDAO.listarOrdenesPendientes();
        int ordenesPendientes = ordenesPendientesList.size();
        
        List<OrdenServicio> ordenesHoyList = ordenServicioDAO.listarOrdenesPorFecha(new Date());
        int ordenesHoy = ordenesHoyList.size();
        
        // Usar método existente para clientes recientes
        List<Cliente> clientesRecientes = clienteDAO.findClientesRecientes(5);

        request.setAttribute("totalClientes", totalClientes);
        request.setAttribute("clientesNuevosMes", clientesNuevosMes);
        request.setAttribute("ordenesPendientes", ordenesPendientes);
        request.setAttribute("ordenesHoy", ordenesHoy);
        request.setAttribute("clientesRecientes", clientesRecientes);
        request.setAttribute("ordenesPendientesList", ordenesPendientesList);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/form.jsp").forward(request, response);
    }

    private void handleGestionClientes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<Cliente> clientes = clienteDAO.listarClientes();
        
        // Usar método existente para clientes activos
        List<Cliente> clientesActivos = clienteDAO.listarClientesActivos();
        
        // Usar método existente para estadísticas
        List<Object[]> estadisticasClientes = clienteDAO.obtenerEstadisticasClientes();

        request.setAttribute("clientes", clientes);
        request.setAttribute("clientesActivos", clientesActivos);
        request.setAttribute("estadisticasClientes", estadisticasClientes);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/list.jsp").forward(request, response);
    }

    private void handleGestionConsultas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Buscar órdenes con observaciones (consultas) - usar listarOrdenes()
        List<OrdenServicio> todasLasOrdenes = ordenServicioDAO.listarOrdenes();
        List<OrdenServicio> ordenesConConsultas = todasLasOrdenes.stream()
            .filter(orden -> orden.getObservaciones() != null && !orden.getObservaciones().trim().isEmpty())
            .toList();

        request.setAttribute("consultas", ordenesConConsultas);
        request.setAttribute("tipo", "consultas");
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/consultas.jsp").forward(request, response);
    }

    private void handleGestionQuejas(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
        // Buscar órdenes con problemas que contengan términos de queja - usar listarOrdenes()
        List<OrdenServicio> todasLasOrdenes = ordenServicioDAO.listarOrdenes();
        List<OrdenServicio> ordenesConQuejas = todasLasOrdenes.stream()
            .filter(orden -> {
                if (orden.getProblemaReportado() == null) return false;
                String problema = orden.getProblemaReportado().toLowerCase();
                return problema.contains("queja") || problema.contains("reclamo") || 
                       problema.contains("insatisfecho") || problema.contains("problema") ||
                       problema.contains("mal") || problema.contains("error");
            })
            .toList();

        request.setAttribute("quejas", ordenesConQuejas);
        request.setAttribute("tipo", "quejas");
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/quejas.jsp").forward(request, response);
    }

    private void handleSeguimientoClientes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Clientes con órdenes pendientes requieren seguimiento
        List<Cliente> clientesConSeguimiento = clienteDAO.listarClientesActivos().stream()
            .filter(cliente -> {
                List<OrdenServicio> ordenesCliente = ordenServicioDAO.listarOrdenesPorCliente(cliente.getIDCliente());
                return ordenesCliente.stream()
                    .anyMatch(orden -> orden.getFechaRealSalida() == null);
            })
            .toList();

        request.setAttribute("clientesSeguimiento", clientesConSeguimiento);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/seguimiento.jsp").forward(request, response);
    }

    private void handleHistorialCliente(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idClienteParam = request.getParameter("idCliente");
        if (idClienteParam == null || idClienteParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cliente no especificado");
            return;
        }

        try {
            int idCliente = Integer.parseInt(idClienteParam);
            Cliente cliente = clienteDAO.obtenerClientePorId(idCliente);
            
            if (cliente == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cliente no encontrado");
                return;
            }

            // Obtener historial del cliente usando métodos existentes
            List<OrdenServicio> historialOrdenes = ordenServicioDAO.listarOrdenesPorCliente(idCliente);
            Cliente clienteConVehiculos = clienteDAO.obtenerClienteConVehiculos(idCliente);

            request.setAttribute("cliente", cliente);
            request.setAttribute("historialOrdenes", historialOrdenes);
            request.setAttribute("clienteConVehiculos", clienteConVehiculos);
            
            request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/historial-cliente.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de cliente inválido");
        }
    }

    private void handleBuscarAtencion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tipoBusqueda = request.getParameter("tipo");
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        
        if (tipoBusqueda == null) {
            tipoBusqueda = "cliente";
        }

        try {
            switch (tipoBusqueda) {
                case "cliente":
                    handleBuscarClientes(request, response, criterio, valor);
                    break;
                case "orden":
                    handleBuscarOrdenes(request, response, criterio, valor);
                    break;
                case "consulta":
                    handleBuscarConsultas(request, response, criterio, valor);
                    break;
                default:
                    handleBuscarClientes(request, response, criterio, valor);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error en la búsqueda: " + e.getMessage());
            handleDashboardAtencion(request, response);
        }
    }

    // Métodos auxiliares de búsqueda

    private void handleBuscarClientes(HttpServletRequest request, HttpServletResponse response, 
                                    String criterio, String valor) throws ServletException, IOException {
        
        List<Cliente> clientesEncontrados;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            switch (criterio) {
                case "nombre":
                    clientesEncontrados = clienteDAO.buscarClientesPorNombre(valor);
                    break;
                case "email":
                    clientesEncontrados = clienteDAO.buscarClientesPorEmail(valor);
                    break;
                case "telefono":
                    clientesEncontrados = clienteDAO.buscarClientesPorTelefono(valor);
                    break;
                default:
                    // Usar búsqueda por criterio general
                    clientesEncontrados = clienteDAO.buscarClientePorCriterio(valor);
            }
        } else {
            clientesEncontrados = clienteDAO.listarClientes();
        }

        request.setAttribute("clientes", clientesEncontrados);
        request.setAttribute("tipoBusqueda", "cliente");
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/buscar-atencion.jsp").forward(request, response);
    }

    private void handleBuscarOrdenes(HttpServletRequest request, HttpServletResponse response, 
                                   String criterio, String valor) throws ServletException, IOException {
        
        List<OrdenServicio> ordenesEncontradas;

        if (criterio != null && valor != null && !valor.trim().isEmpty()) {
            switch (criterio) {
                case "problema":
                    ordenesEncontradas = ordenServicioDAO.findByProblemaReportadoContaining(valor);
                    break;
                case "cliente":
                    // Buscar órdenes por cliente usando método existente
                    List<Cliente> clientes = clienteDAO.buscarClientePorCriterio(valor);
                    if (!clientes.isEmpty()) {
                        ordenesEncontradas = ordenServicioDAO.listarOrdenesPorCliente(clientes.get(0).getIDCliente());
                    } else {
                        ordenesEncontradas = List.of();
                    }
                    break;
                default:
                    ordenesEncontradas = ordenServicioDAO.listarOrdenes();
            }
        } else {
            ordenesEncontradas = ordenServicioDAO.listarOrdenes();
        }

        request.setAttribute("ordenes", ordenesEncontradas);
        request.setAttribute("tipoBusqueda", "orden");
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/buscar-atencion.jsp").forward(request, response);
    }

    private void handleBuscarConsultas(HttpServletRequest request, HttpServletResponse response, 
                                     String criterio, String valor) throws ServletException, IOException {
        
        // Buscar en todas las órdenes por observaciones - usar listarOrdenes()
        List<OrdenServicio> todasLasOrdenes = ordenServicioDAO.listarOrdenes();
        List<OrdenServicio> consultasEncontradas = todasLasOrdenes.stream()
            .filter(orden -> {
                if (orden.getObservaciones() == null && orden.getProblemaReportado() == null) return false;
                
                String busqueda = valor.toLowerCase();
                boolean enObservaciones = orden.getObservaciones() != null && 
                                        orden.getObservaciones().toLowerCase().contains(busqueda);
                boolean enProblema = orden.getProblemaReportado() != null && 
                                   orden.getProblemaReportado().toLowerCase().contains(busqueda);
                
                return enObservaciones || enProblema;
            })
            .toList();

        request.setAttribute("consultas", consultasEncontradas);
        request.setAttribute("tipoBusqueda", "consulta");
        request.setAttribute("criterio", criterio);
        request.setAttribute("valor", valor);
        
        request.getRequestDispatcher("/WEB-INF/pages/recepcionista/atencion/buscar-atencion.jsp").forward(request, response);
    }

    // Métodos auxiliares

    private String getActionFromPath(String path) {
        if (path.endsWith("/clientes")) return "clientes";
        if (path.endsWith("/consultas")) return "consultas";
        if (path.endsWith("/quejas")) return "quejas";
        if (path.endsWith("/seguimiento")) return "seguimiento";
        if (path.endsWith("/historial")) return "historial";
        if (path.endsWith("/buscar")) return "buscar";
        
        return "dashboard"; // Por defecto para la ruta base
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, 
                           Exception e, String errorMessage) throws ServletException, IOException {
        
        e.printStackTrace();
        request.setAttribute("error", errorMessage);
        
        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/recepcionista/atencion");
        }
    }
}