package com.upec.servlet.inventario;

import com.upec.dao.RepuestoDAO;
import com.upec.model.Repuesto;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "InventarioServlet", urlPatterns = {
    "/InventarioServlet",
    "/mecanico/inventario",
    "/mecanico/inventario/consultar",
    "/mecanico/inventario/ver",
    "/mecanico/inventario/buscar",
    "/mecanico/inventario/solicitar",
    "/mecanico/inventario/alertas",
    "/mecanico/inventario/disponibilidad"
})
public class InventarioServlet extends HttpServlet {

    private RepuestoDAO repuestoDAO;
    private EntityManagerFactory emf;

    @Override
    public void init() throws ServletException {
        try {
            // Crear EntityManagerFactory manualmente
            emf = Persistence.createEntityManagerFactory("taller_automotrizPU");
            EntityManager em = emf.createEntityManager();
            
            // Crear el DAO y pasarle el EntityManager
            this.repuestoDAO = new RepuestoDAO();
            // Usar reflexión para establecer el EntityManager si es necesario
            // O modificar el DAO para aceptar EntityManager en el constructor
            setEntityManagerInDAO(em);
            
        } catch (Exception e) {
            throw new ServletException("Error inicializando InventarioServlet", e);
        }
    }

    // Método auxiliar para establecer el EntityManager en el DAO
    private void setEntityManagerInDAO(EntityManager em) {
        try {
            java.lang.reflect.Field emField = RepuestoDAO.class.getDeclaredField("em");
            emField.setAccessible(true);
            emField.set(repuestoDAO, em);
        } catch (Exception e) {
            throw new RuntimeException("No se pudo establecer EntityManager en RepuestoDAO", e);
        }
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
                    handleListarInventario(request, response);
                    break;
                case "consultar":
                    handleConsultarRepuesto(request, response);
                    break;
                case "ver":
                    handleVerRepuesto(request, response);
                    break;
                case "buscar":
                    handleBuscarRepuestos(request, response);
                    break;
                case "solicitar":
                    handleFormularioSolicitud(request, response);
                    break;
                case "alertas":
                    handleAlertasStock(request, response);
                    break;
                case "disponibilidad":
                    handleVerificarDisponibilidad(request, response);
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
                case "solicitar":
                    handleProcesarSolicitud(request, response);
                    break;
                case "disponibilidad":
                    handleVerificarDisponibilidadPost(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET

    private void handleListarInventario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            List<Repuesto> todosRepuestos = repuestoDAO.findAll();
            List<Repuesto> repuestosActivos = todosRepuestos.stream()
                .filter(r -> r.getEstado() != null && r.getEstado())
                .collect(Collectors.toList());
            
            List<Repuesto> repuestosBajoStock = repuestosActivos.stream()
                .filter(r -> r.getStock() != null && r.getStockMinimo() != null && r.getStock() <= r.getStockMinimo())
                .collect(Collectors.toList());
                
            List<Repuesto> repuestosStockCritico = repuestosActivos.stream()
                .filter(r -> r.getStock() != null && r.getStockMinimo() != null && r.getStock() <= r.getStockMinimo() / 2)
                .collect(Collectors.toList());

            // Calcular estadísticas del inventario
            Long totalRepuestosActivos = (long) repuestosActivos.size();
            Long repuestosConStockBajo = (long) repuestosBajoStock.size();
            Double valorTotalInventario = calcularValorTotalInventario(repuestosActivos);

            request.setAttribute("repuestosDisponibles", repuestosActivos);
            request.setAttribute("repuestosBajoStock", repuestosBajoStock);
            request.setAttribute("repuestosStockCritico", repuestosStockCritico);
            request.setAttribute("totalRepuestosActivos", totalRepuestosActivos);
            request.setAttribute("repuestosConStockBajo", repuestosConStockBajo);
            request.setAttribute("valorTotalInventario", valorTotalInventario);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/list.jsp").forward(request, response);
            
        } catch (Exception e) {
            throw new ServletException("Error listando inventario", e);
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private void handleConsultarRepuesto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de repuesto no especificado");
            return;
        }

        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            int id = Integer.parseInt(idParam);
            Repuesto repuesto = repuestoDAO.findById(id);
            
            if (repuesto == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Repuesto no encontrado");
                return;
            }

            // Verificar disponibilidad inmediata
            String estadoStock;
            if (repuesto.getStock() == null || repuesto.getStock() == 0) {
                estadoStock = "AGOTADO";
            } else if (repuesto.getStockMinimo() != null && repuesto.getStock() <= repuesto.getStockMinimo()) {
                estadoStock = "STOCK BAJO";
            } else {
                estadoStock = "DISPONIBLE";
            }

            request.setAttribute("repuesto", repuesto);
            request.setAttribute("estadoStock", estadoStock);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/consultar.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de repuesto inválido");
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private void handleVerRepuesto(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de repuesto no especificado");
            return;
        }

        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            int id = Integer.parseInt(idParam);
            Repuesto repuesto = repuestoDAO.findById(id);
            
            if (repuesto == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Repuesto no encontrado");
                return;
            }

            request.setAttribute("repuesto", repuesto);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID de repuesto inválido");
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private void handleBuscarRepuestos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String criterio = request.getParameter("criterio");
        String valor = request.getParameter("valor");
        
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            List<Repuesto> repuestos;

            if (criterio != null && valor != null && !valor.trim().isEmpty()) {
                List<Repuesto> todosRepuestos = repuestoDAO.findAll();
                switch (criterio) {
                    case "nombre":
                        repuestos = todosRepuestos.stream()
                            .filter(r -> r.getNombreRepuesto() != null && 
                                       r.getNombreRepuesto().toLowerCase().contains(valor.toLowerCase()))
                            .collect(Collectors.toList());
                        break;
                    case "descripcion":
                        repuestos = todosRepuestos.stream()
                            .filter(r -> r.getDescripcion() != null && 
                                       r.getDescripcion().toLowerCase().contains(valor.toLowerCase()))
                            .collect(Collectors.toList());
                        break;
                    case "stock_bajo":
                        repuestos = todosRepuestos.stream()
                            .filter(r -> r.getEstado() != null && r.getEstado() &&
                                       r.getStock() != null && r.getStockMinimo() != null && 
                                       r.getStock() <= r.getStockMinimo())
                            .collect(Collectors.toList());
                        break;
                    case "disponibles":
                        repuestos = todosRepuestos.stream()
                            .filter(r -> r.getEstado() != null && r.getEstado())
                            .collect(Collectors.toList());
                        break;
                    default:
                        repuestos = todosRepuestos.stream()
                            .filter(r -> r.getEstado() != null && r.getEstado())
                            .collect(Collectors.toList());
                }
            } else {
                repuestos = repuestoDAO.findAll().stream()
                    .filter(r -> r.getEstado() != null && r.getEstado())
                    .collect(Collectors.toList());
            }

            request.setAttribute("repuestos", repuestos);
            request.setAttribute("criterio", criterio);
            request.setAttribute("valor", valor);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/list.jsp").forward(request, response);
            
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private void handleFormularioSolicitud(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idRepuestoParam = request.getParameter("idRepuesto");
        
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            List<Repuesto> repuestosDisponibles = repuestoDAO.findAll().stream()
                .filter(r -> r.getEstado() != null && r.getEstado())
                .collect(Collectors.toList());

            // Si se especifica un repuesto específico, cargarlo
            if (idRepuestoParam != null && !idRepuestoParam.isEmpty()) {
                try {
                    int idRepuesto = Integer.parseInt(idRepuestoParam);
                    Repuesto repuesto = repuestoDAO.findById(idRepuesto);
                    if (repuesto != null) {
                        request.setAttribute("repuestoSeleccionado", repuesto);
                    }
                } catch (NumberFormatException e) {
                    // Ignorar error y continuar sin repuesto seleccionado
                }
            }

            request.setAttribute("repuestosDisponibles", repuestosDisponibles);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/solicitar.jsp").forward(request, response);
            
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private void handleAlertasStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            List<Repuesto> todosRepuestos = repuestoDAO.findAll();
            List<Repuesto> repuestosBajoStock = todosRepuestos.stream()
                .filter(r -> r.getEstado() != null && r.getEstado() &&
                           r.getStock() != null && r.getStockMinimo() != null && 
                           r.getStock() <= r.getStockMinimo())
                .collect(Collectors.toList());
                
            List<Repuesto> repuestosStockCritico = todosRepuestos.stream()
                .filter(r -> r.getEstado() != null && r.getEstado() &&
                           r.getStock() != null && r.getStockMinimo() != null && 
                           r.getStock() <= r.getStockMinimo() / 2)
                .collect(Collectors.toList());
                
            List<Repuesto> repuestosAgotados = todosRepuestos.stream()
                .filter(r -> r.getEstado() != null && r.getEstado() &&
                           r.getStock() != null && r.getStock() == 0)
                .collect(Collectors.toList());

            request.setAttribute("repuestosBajoStock", repuestosBajoStock);
            request.setAttribute("repuestosStockCritico", repuestosStockCritico);
            request.setAttribute("repuestosAgotados", repuestosAgotados);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/alertas.jsp").forward(request, response);
            
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    private void handleVerificarDisponibilidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idRepuestoParam = request.getParameter("idRepuesto");
        String cantidadParam = request.getParameter("cantidad");
        
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            if (idRepuestoParam != null && !idRepuestoParam.isEmpty()) {
                try {
                    int idRepuesto = Integer.parseInt(idRepuestoParam);
                    int cantidadRequerida = cantidadParam != null && !cantidadParam.isEmpty() ? 
                        Integer.parseInt(cantidadParam) : 1;
                    
                    Repuesto repuesto = repuestoDAO.findById(idRepuesto);
                    boolean disponible = verificarStockDisponible(repuesto, cantidadRequerida);
                    int stockActual = repuesto != null && repuesto.getStock() != null ? repuesto.getStock() : 0;
                    
                    request.setAttribute("repuesto", repuesto);
                    request.setAttribute("cantidadRequerida", cantidadRequerida);
                    request.setAttribute("stockActual", stockActual);
                    request.setAttribute("disponible", disponible);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Parámetros inválidos");
                }
            }

            List<Repuesto> repuestosDisponibles = repuestoDAO.findAll().stream()
                .filter(r -> r.getEstado() != null && r.getEstado())
                .collect(Collectors.toList());
            request.setAttribute("repuestosDisponibles", repuestosDisponibles);
            
            request.getRequestDispatcher("/WEB-INF/pages/mecanico/inventario/disponibilidad.jsp").forward(request, response);
            
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    // Métodos para manejar las operaciones POST

    private void handleProcesarSolicitud(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idRepuestoParam = request.getParameter("idRepuesto");
        String cantidadParam = request.getParameter("cantidad");
        String justificacion = request.getParameter("justificacion");
        String urgencia = request.getParameter("urgencia");
        
        if (idRepuestoParam == null || cantidadParam == null) {
            request.getSession().setAttribute("error", "Datos incompletos");
            response.sendRedirect(request.getContextPath() + "/mecanico/inventario/solicitar");
            return;
        }

        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            em.getTransaction().begin();
            
            try {
                int idRepuesto = Integer.parseInt(idRepuestoParam);
                int cantidad = Integer.parseInt(cantidadParam);
                
                // Obtener información del mecánico
                Integer idMecanico = (Integer) request.getSession().getAttribute("idEmpleado");
                String nombreMecanico = (String) request.getSession().getAttribute("nombreUsuario");

                // Verificar disponibilidad
                Repuesto repuesto = repuestoDAO.findById(idRepuesto);
                if (repuesto == null) {
                    request.getSession().setAttribute("error", "Repuesto no encontrado");
                    response.sendRedirect(request.getContextPath() + "/mecanico/inventario/solicitar");
                    em.getTransaction().rollback();
                    return;
                }

                boolean disponible = verificarStockDisponible(repuesto, cantidad);
                int stockActual = repuesto.getStock() != null ? repuesto.getStock() : 0;
                
                if (disponible) {
                    // Stock disponible - procesar solicitud inmediatamente
                    repuesto.setStock(stockActual - cantidad);
                    repuestoDAO.saveOrUpdate(repuesto);
                    
                    String mensaje = String.format(
                        "Solicitud procesada exitosamente. Se han asignado %d unidades de %s. Stock restante: %d",
                        cantidad, repuesto.getNombreRepuesto(), stockActual - cantidad
                    );
                    request.getSession().setAttribute("mensaje", mensaje);
                    
                    em.getTransaction().commit();
                } else {
                    // Stock insuficiente - crear solicitud pendiente
                    String mensajeSolicitud = String.format(
                        "SOLICITUD DE MATERIALES - PENDIENTE%n" +
                        "Repuesto: %s%n" +
                        "Cantidad Solicitada: %d%n" +
                        "Stock Actual: %d%n" +
                        "Mecánico: %s (ID: %d)%n" +
                        "Urgencia: %s%n" +
                        "Justificación: %s",
                        repuesto.getNombreRepuesto(), cantidad, 
                        stockActual,
                        nombreMecanico != null ? nombreMecanico : "No especificado", 
                        idMecanico != null ? idMecanico : 0, 
                        urgencia != null ? urgencia : "Normal", 
                        justificacion != null ? justificacion : "Sin justificación"
                    );
                    
                    request.getSession().setAttribute("mensaje", 
                        "Solicitud creada exitosamente. Será procesada por el administrador de inventario.");
                    request.getSession().setAttribute("detalleSolicitud", mensajeSolicitud);
                    
                    em.getTransaction().commit();
                }
            } catch (NumberFormatException e) {
                em.getTransaction().rollback();
                request.getSession().setAttribute("error", "Datos inválidos");
            } catch (Exception e) {
                em.getTransaction().rollback();
                request.getSession().setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            }
            
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/mecanico/inventario");
    }

    private void handleVerificarDisponibilidadPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idRepuestoParam = request.getParameter("idRepuesto");
        String cantidadParam = request.getParameter("cantidad");
        
        if (idRepuestoParam == null || cantidadParam == null) {
            request.getSession().setAttribute("error", "Datos incompletos");
            response.sendRedirect(request.getContextPath() + "/mecanico/inventario/disponibilidad");
            return;
        }

        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            setEntityManagerInDAO(em);
            
            try {
                int idRepuesto = Integer.parseInt(idRepuestoParam);
                int cantidadRequerida = Integer.parseInt(cantidadParam);
                
                Repuesto repuesto = repuestoDAO.findById(idRepuesto);
                boolean disponible = verificarStockDisponible(repuesto, cantidadRequerida);
                int stockActual = repuesto != null && repuesto.getStock() != null ? repuesto.getStock() : 0;
                
                if (repuesto != null) {
                    if (disponible) {
                        request.getSession().setAttribute("mensaje", 
                            String.format("Stock disponible: %d unidades. Puede proceder con la solicitud.", 
                                stockActual));
                    } else {
                        request.getSession().setAttribute("error", 
                            String.format("Stock insuficiente. Disponible: %d unidades, Requerido: %d unidades", 
                                stockActual, cantidadRequerida));
                    }
                } else {
                    request.getSession().setAttribute("error", "Repuesto no encontrado");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("error", "Datos inválidos");
            }
            
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/mecanico/inventario/disponibilidad?idRepuesto=" + idRepuestoParam + "&cantidad=" + cantidadParam);
    }

    // Métodos auxiliares

    private String getActionFromPath(String path) {
        if (path.endsWith("/consultar")) return "consultar";
        if (path.endsWith("/ver")) return "ver";
        if (path.endsWith("/buscar")) return "buscar";
        if (path.endsWith("/solicitar")) return "solicitar";
        if (path.endsWith("/alertas")) return "alertas";
        if (path.endsWith("/disponibilidad")) return "disponibilidad";
        
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
            response.sendRedirect(request.getContextPath() + "/mecanico/inventario");
        }
    }

    // Métodos de utilidad

    private Double calcularValorTotalInventario(List<Repuesto> repuestos) {
        return repuestos.stream()
            .filter(r -> r.getPrecioCompra() != null && r.getStock() != null)
            .mapToDouble(r -> r.getPrecioCompra().doubleValue() * r.getStock())
            .sum();
    }

    private boolean verificarStockDisponible(Repuesto repuesto, int cantidadRequerida) {
        if (repuesto == null || repuesto.getStock() == null) {
            return false;
        }
        return repuesto.getStock() >= cantidadRequerida;
    }

    @Override
    public void destroy() {
        // Cleanup resources
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}