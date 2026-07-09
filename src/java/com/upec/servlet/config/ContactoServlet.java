package com.upec.servlet.config;

import com.upec.dao.ClienteDAO;
import com.upec.model.Cliente;
import com.upec.model.Usuarios;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ContactoServlet", urlPatterns = {
    "/ContactoServlet",
    "/cliente/contacto",
    "/cliente/contacto/*"
})
public class ContactoServlet extends HttpServlet {

    @Inject
    private ClienteDAO clienteDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Validación del rol - CORREGIDO: Usar misma lógica que FacturaClientesServlet
        String userRole = (String) session.getAttribute("rol");
        Integer idRol = (Integer) session.getAttribute("idRol");
        
        boolean esCliente = ("cliente".equalsIgnoreCase(userRole)) || (idRol != null && idRol == 4);
        
        if (!esCliente) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "formulario";

        try {
            switch (action) {
                case "formulario":
                    mostrarFormularioContacto(request, response, session);
                    break;
                case "historial":
                    mostrarHistorialContactos(request, response, session);
                    break;
                case "soporte":
                    mostrarSoporteTecnico(request, response, session);
                    break;
                case "informacion":
                    mostrarInformacionContacto(request, response, session);
                    break;
                default:
                    mostrarFormularioContacto(request, response, session);
            }
        } catch (Exception e) {
            manejarError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
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
        if (action == null) action = "enviar";

        try {
            switch (action) {
                case "enviar":
                    procesarEnvioConsulta(request, response, session);
                    break;
                case "enviarSoporte":
                    procesarSolicitudSoporte(request, response, session);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            manejarError(request, response, e, "Error procesando la solicitud: " + e.getMessage());
        }
    }

    // Métodos para manejar las operaciones GET - CORREGIDOS: agregar session como parámetro

    private void mostrarFormularioContacto(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        // CORRECCIÓN: Obtener cliente desde el usuario de la sesión
        Cliente cliente = obtenerClienteDesdeSession(session);
        if (cliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<String> tiposConsulta = List.of(
            "Consulta General",
            "Solicitud de Información",
            "Reporte de Problema",
            "Sugerencia",
            "Reclamo",
            "Felicitación",
            "Solicitud de Servicio",
            "Consulta de Facturación"
        );

        List<String> areasSoporte = List.of(
            "Servicios Mecánicos",
            "Facturación y Pagos",
            "Citas y Agenda",
            "Garantías",
            "Repuestos",
            "Otros"
        );

        request.setAttribute("cliente", cliente);
        request.setAttribute("tiposConsulta", tiposConsulta);
        request.setAttribute("areasSoporte", areasSoporte);
        request.setAttribute("tipoVista", "contacto-general");
        
        // CORRECCIÓN: Ruta corregida según estructura real
        request.getRequestDispatcher("/WEB-INF/pages/cliente/contacto/form.jsp").forward(request, response);
    }

    private void mostrarHistorialContactos(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        Cliente cliente = obtenerClienteDesdeSession(session);
        if (cliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Simulación de datos - en producción vendría de la base de datos
        List<Object[]> historialContactos = List.of();
        
        request.setAttribute("historialContactos", historialContactos);
        request.setAttribute("totalContactos", historialContactos.size());
        request.setAttribute("tipoVista", "historial");
        
        // CORRECCIÓN: Ruta corregida según estructura real
        request.getRequestDispatcher("/WEB-INF/pages/cliente/contacto/list.jsp").forward(request, response);
    }

    private void mostrarSoporteTecnico(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        Cliente cliente = obtenerClienteDesdeSession(session);
        if (cliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<String> tiposProblema = List.of(
            "Problema con cita programada",
            "Error en facturación",
            "Problema con diagnóstico",
            "Falla en repuesto instalado",
            "Problema de garantía",
            "Consulta técnica sobre vehículo",
            "Otro problema técnico"
        );

        List<String> nivelesUrgencia = List.of(
            "Baja - Consulta general",
            "Media - Necesita respuesta pronto",
            "Alta - Requiere atención inmediata",
            "Crítica - Servicio no funciona"
        );

        request.setAttribute("cliente", cliente);
        request.setAttribute("tiposProblema", tiposProblema);
        request.setAttribute("nivelesUrgencia", nivelesUrgencia);
        request.setAttribute("tipoVista", "soporte-tecnico");
        
        // CORRECCIÓN: Ruta corregida según estructura real
        request.getRequestDispatcher("/WEB-INF/pages/cliente/contacto/form.jsp").forward(request, response);
    }

    private void mostrarInformacionContacto(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String telefonoTaller = "+1 (555) 123-4567";
        String emailTaller = "contacto@tallerautomotriz.com";
        String direccionTaller = "Av. Principal #123, Ciudad, Estado";
        String horarioAtencion = "Lunes a Viernes: 8:00 AM - 6:00 PM\nSábados: 8:00 AM - 2:00 PM";
        
        List<DepartamentoContacto> departamentos = List.of(
            new DepartamentoContacto("Servicio al Cliente", "clientes@taller.com", "+1 (555) 111-1111", "Atención general y consultas"),
            new DepartamentoContacto("Soporte Técnico", "soporte@taller.com", "+1 (555) 222-2222", "Problemas técnicos y diagnósticos"),
            new DepartamentoContacto("Facturación", "facturacion@taller.com", "+1 (555) 333-3333", "Facturas y pagos"),
            new DepartamentoContacto("Citas y Agenda", "citas@taller.com", "+1 (555) 444-4444", "Programación de servicios"),
            new DepartamentoContacto("Gerencia", "gerencia@taller.com", "+1 (555) 555-5555", "Consultas administrativas")
        );

        List<PreguntaFrecuente> preguntasFrecuentes = List.of(
            new PreguntaFrecuente("¿Cuál es el horario de atención?", "Atendemos de lunes a viernes de 8:00 AM a 6:00 PM y sábados de 8:00 AM a 2:00 PM."),
            new PreguntaFrecuente("¿Aceptan tarjetas de crédito?", "Sí, aceptamos todas las tarjetas de crédito y débito principales."),
            new PreguntaFrecuente("¿Ofrecen servicio a domicilio?", "Sí, ofrecemos servicio de grúa y diagnóstico a domicilio para clientes registrados."),
            new PreguntaFrecuente("¿Cuánto tiempo toma una revisión general?", "Una revisión general completa toma aproximadamente 2-3 horas."),
            new PreguntaFrecuente("¿Tienen garantía en sus servicios?", "Sí, todos nuestros servicios tienen garantía de 90 días o 5,000 km."),
            new PreguntaFrecuente("¿Puedo programar cita en línea?", "Sí, puede programar citas a través de nuestro portal web o aplicación móvil.")
        );

        request.setAttribute("telefonoTaller", telefonoTaller);
        request.setAttribute("emailTaller", emailTaller);
        request.setAttribute("direccionTaller", direccionTaller);
        request.setAttribute("horarioAtencion", horarioAtencion);
        request.setAttribute("departamentos", departamentos);
        request.setAttribute("preguntasFrecuentes", preguntasFrecuentes);
        request.setAttribute("tipoVista", "informacion");
        
        // CORRECCIÓN: Ruta corregida según estructura real
        request.getRequestDispatcher("/WEB-INF/pages/cliente/contacto/view.jsp").forward(request, response);
    }

    // Métodos para manejar las operaciones POST - CORREGIDOS: agregar session como parámetro

    private void procesarEnvioConsulta(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        Cliente cliente = obtenerClienteDesdeSession(session);
        if (cliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String tipoConsulta = request.getParameter("tipoConsulta");
        String asunto = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");
        String prioridad = request.getParameter("prioridad");
        
        if (asunto == null || asunto.trim().isEmpty() || mensaje == null || mensaje.trim().isEmpty()) {
            request.setAttribute("error", "El asunto y el mensaje son obligatorios");
            mostrarFormularioContacto(request, response, session);
            return;
        }

        try {
            boolean emailEnviado = enviarEmailConsulta(cliente, tipoConsulta, asunto, mensaje, prioridad);
            
            if (emailEnviado) {
                guardarRegistroConsulta(cliente, tipoConsulta, asunto, mensaje, prioridad);
                
                request.getSession().setAttribute("successMessage", 
                    "Su consulta ha sido enviada exitosamente. Nos pondremos en contacto pronto.");
                response.sendRedirect(request.getContextPath() + "/ContactoServlet?action=formulario");
            } else {
                request.setAttribute("error", 
                    "Error al enviar la consulta. Por favor, intente nuevamente o contacte por teléfono.");
                mostrarFormularioContacto(request, response, session);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al procesar la consulta: " + e.getMessage());
            mostrarFormularioContacto(request, response, session);
        }
    }

    private void procesarSolicitudSoporte(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        Cliente cliente = obtenerClienteDesdeSession(session);
        if (cliente == null) {
            response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String tipoProblema = request.getParameter("tipoProblema");
        String urgencia = request.getParameter("urgencia");
        String descripcionProblema = request.getParameter("descripcionProblema");
        String pasosReproducir = request.getParameter("pasosReproducir");
        String resultadoEsperado = request.getParameter("resultadoEsperado");
        
        if (descripcionProblema == null || descripcionProblema.trim().isEmpty()) {
            request.setAttribute("error", "La descripción del problema es obligatoria");
            mostrarSoporteTecnico(request, response, session);
            return;
        }

        try {
            boolean emailEnviado = enviarEmailSoporte(cliente, tipoProblema, urgencia, descripcionProblema, 
                                                     pasosReproducir, resultadoEsperado);
            
            if (emailEnviado) {
                guardarRegistroSoporte(cliente, tipoProblema, urgencia, descripcionProblema, 
                                      pasosReproducir, resultadoEsperado);
                
                request.getSession().setAttribute("successMessage", 
                    "Su solicitud de soporte técnico ha sido enviada. " +
                    "Nuestro equipo técnico se contactará con usted pronto.");
                response.sendRedirect(request.getContextPath() + "/ContactoServlet?action=soporte");
            } else {
                request.setAttribute("error", 
                    "Error al enviar la solicitud de soporte. Por favor, intente nuevamente.");
                mostrarSoporteTecnico(request, response, session);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al procesar la solicitud de soporte: " + e.getMessage());
            mostrarSoporteTecnico(request, response, session);
        }
    }

    // CORRECCIÓN: Método para obtener cliente desde la sesión
    private Cliente obtenerClienteDesdeSession(HttpSession session) {
        Usuarios usuario = (Usuarios) session.getAttribute("usuario");
        if (usuario == null || usuario.getEmail() == null) {
            return null;
        }
        
        // Buscar cliente por email (asumiendo que el email del usuario coincide con el del cliente)
        List<Cliente> clientes = clienteDAO.buscarClientesPorEmail(usuario.getEmail());
        return clientes.isEmpty() ? null : clientes.get(0);
    }

    // Métodos auxiliares para envío de emails (sin cambios)

    private boolean enviarEmailConsulta(Cliente cliente, String tipoConsulta, String asunto, 
                                      String mensaje, String prioridad) {
        try {
            System.out.println("Email de consulta simulado para: " + cliente.getEmail());
            System.out.println("Tipo: " + tipoConsulta + " - Asunto: " + asunto);
            return true;
            
        } catch (Exception e) {
            System.err.println("Error simulando envío de email: " + e.getMessage());
            return false;
        }
    }

    private boolean enviarEmailSoporte(Cliente cliente, String tipoProblema, String urgencia,
                                     String descripcionProblema, String pasosReproducir, 
                                     String resultadoEsperado) {
        try {
            System.out.println("Email de soporte simulado para: " + cliente.getEmail());
            System.out.println("Problema: " + tipoProblema + " - Urgencia: " + urgencia);
            return true;
            
        } catch (Exception e) {
            System.err.println("Error simulando envío de email de soporte: " + e.getMessage());
            return false;
        }
    }

    private void guardarRegistroConsulta(Cliente cliente, String tipoConsulta, String asunto, 
                                       String mensaje, String prioridad) {
        System.out.println("Registro de consulta guardado para cliente: " + cliente.getIDCliente());
    }

    private void guardarRegistroSoporte(Cliente cliente, String tipoProblema, String urgencia,
                                      String descripcionProblema, String pasosReproducir, 
                                      String resultadoEsperado) {
        System.out.println("Registro de soporte guardado para cliente: " + cliente.getIDCliente());
    }

    // Clases auxiliares para datos estáticos (deben estar dentro del servlet)

    public static class DepartamentoContacto {
        private String nombre;
        private String email;
        private String telefono;
        private String descripcion;
        
        public DepartamentoContacto(String nombre, String email, String telefono, String descripcion) {
            this.nombre = nombre;
            this.email = email;
            this.telefono = telefono;
            this.descripcion = descripcion;
        }
        
        public String getNombre() { return nombre; }
        public String getEmail() { return email; }
        public String getTelefono() { return telefono; }
        public String getDescripcion() { return descripcion; }
    }

    public static class PreguntaFrecuente {
        private String pregunta;
        private String respuesta;
        
        public PreguntaFrecuente(String pregunta, String respuesta) {
            this.pregunta = pregunta;
            this.respuesta = respuesta;
        }
        
        public String getPregunta() { return pregunta; }
        public String getRespuesta() { return respuesta; }
    }

    private void manejarError(HttpServletRequest request, HttpServletResponse response, 
                           Exception e, String errorMessage) throws ServletException, IOException {
        
        e.printStackTrace();
        request.setAttribute("error", errorMessage);
        response.sendRedirect(request.getContextPath() + "/ContactoServlet?action=formulario");
    }
}