<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List" %>
<%@page import="com.upec.servlet.config.ContactoServlet" %>
<%
 // CORRECCIÓN: Usar la variable session implícita de JSP
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
    
    String tipoVista = (String) request.getAttribute("tipoVista");
    if (tipoVista == null) tipoVista = "informacion";
    
    String telefonoTaller = (String) request.getAttribute("telefonoTaller");
    String emailTaller = (String) request.getAttribute("emailTaller");
    String direccionTaller = (String) request.getAttribute("direccionTaller");
    String horarioAtencion = (String) request.getAttribute("horarioAtencion");
    List<ContactoServlet.DepartamentoContacto> departamentos = (List<ContactoServlet.DepartamentoContacto>) request.getAttribute("departamentos");
    List<ContactoServlet.PreguntaFrecuente> preguntasFrecuentes = (List<ContactoServlet.PreguntaFrecuente>) request.getAttribute("preguntasFrecuentes");
    
    // CORRECCIÓN: Inicializar para evitar nulls
    if (telefonoTaller == null) telefonoTaller = "(04) 234-5678";
    if (emailTaller == null) emailTaller = "contacto@tallerautomotriz.com";
    if (direccionTaller == null) direccionTaller = "Av. Principal #123, Ciudad, Estado";
    if (horarioAtencion == null) horarioAtencion = "Lunes a Viernes: 8:00 AM - 6:00 PM\nSábados: 8:00 AM - 2:00 PM";
    if (departamentos == null) departamentos = java.util.Collections.emptyList();
    if (preguntasFrecuentes == null) preguntasFrecuentes = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Información de Contacto - Taller Automotriz</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudcliente.css">
</head>
<body class="cliente">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-cliente.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>ℹ️ Información de Contacto</h1>
                <p>Encuentra todas las formas de contactarnos y obtener soporte</p>
            </div>

            <div class="contact-info-grid">
                <!-- Información Principal -->
                <div class="contact-main-info">
                    <div class="info-card primary">
                        <div class="info-icon">🏢</div>
                        <div class="info-content">
                            <h2>Taller Automotriz</h2>
                            <p class="info-description">
                                Servicios profesionales de reparación y mantenimiento automotriz 
                                con los más altos estándares de calidad y atención al cliente.
                            </p>
                        </div>
                    </div>

                    <div class="contact-details">
                        <div class="detail-item">
                            <div class="detail-icon">📍</div>
                            <div class="detail-info">
                                <h3>Dirección</h3>
                                <p><%= direccionTaller %></p>
                                <a href="#" class="map-link" onclick="alert('Funcionalidad de mapa en desarrollo'); return false;">Ver en mapa →</a>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">📞</div>
                            <div class="detail-info">
                                <h3>Teléfono</h3>
                                <p><a href="tel:<%= telefonoTaller.replaceAll("[^0-9+]", "") %>"><%= telefonoTaller %></a></p>
                                <small>Disponible para emergencias 24/7</small>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">✉️</div>
                            <div class="detail-info">
                                <h3>Email</h3>
                                <p><a href="mailto:<%= emailTaller %>"><%= emailTaller %></a></p>
                                <small>Respuesta en menos de 24 horas</small>
                            </div>
                        </div>
                        
                        <div class="detail-item">
                            <div class="detail-icon">🕒</div>
                            <div class="detail-info">
                                <h3>Horario de Atención</h3>
                                <p><%= horarioAtencion.replace("\n", "<br>") %></p>
                                <small>Horario extendido con cita previa</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Departamentos de Contacto -->
                <div class="departments-section">
                    <h2>🏢 Departamentos de Contacto</h2>
                    <div class="departments-grid">
                        <% for (ContactoServlet.DepartamentoContacto dept : departamentos) { %>
                        <div class="department-card">
                            <div class="dept-icon">👥</div>
                            <h3><%= dept.getNombre() %></h3>
                            <p class="dept-description"><%= dept.getDescripcion() %></p>
                            <div class="dept-contact">
                                <div class="dept-email">
                                    <a href="mailto:<%= dept.getEmail() %>"><%= dept.getEmail() %></a>
                                </div>
                                <div class="dept-phone">
                                    <a href="tel:<%= dept.getTelefono().replaceAll("[^0-9+]", "") %>"><%= dept.getTelefono() %></a>
                                </div>
                            </div>
                        </div>
                        <% } %>
                        
                        <!-- CORRECCIÓN: Departamentos por defecto si la lista está vacía -->
                        <% if (departamentos.isEmpty()) { %>
                        <div class="department-card">
                            <div class="dept-icon">👥</div>
                            <h3>Servicio al Cliente</h3>
                            <p class="dept-description">Atención general y consultas</p>
                            <div class="dept-contact">
                                <div class="dept-email">
                                    <a href="mailto:clientes@taller.com">clientes@taller.com</a>
                                </div>
                                <div class="dept-phone">
                                    <a href="tel:042345000">(04) 234-5000</a>
                                </div>
                            </div>
                        </div>
                        <div class="department-card">
                            <div class="dept-icon">🔧</div>
                            <h3>Soporte Técnico</h3>
                            <p class="dept-description">Asistencia técnica y diagnósticos</p>
                            <div class="dept-contact">
                                <div class="dept-email">
                                    <a href="mailto:soporte@taller.com">soporte@taller.com</a>
                                </div>
                                <div class="dept-phone">
                                    <a href="tel:042345001">(04) 234-5001</a>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Preguntas Frecuentes -->
                <div class="faq-section">
                    <h2>❓ Preguntas Frecuentes</h2>
                    <div class="faq-list">
                        <% for (ContactoServlet.PreguntaFrecuente faq : preguntasFrecuentes) { %>
                        <div class="faq-item">
                            <div class="faq-question">
                                <span class="faq-icon">❓</span>
                                <h3><%= faq.getPregunta() %></h3>
                                <span class="faq-toggle">+</span>
                            </div>
                            <div class="faq-answer">
                                <p><%= faq.getRespuesta() %></p>
                            </div>
                        </div>
                        <% } %>
                        
                        <!-- CORRECCIÓN: Preguntas por defecto si la lista está vacía -->
                        <% if (preguntasFrecuentes.isEmpty()) { %>
                        <div class="faq-item">
                            <div class="faq-question">
                                <span class="faq-icon">❓</span>
                                <h3>¿Cuál es el horario de atención?</h3>
                                <span class="faq-toggle">+</span>
                            </div>
                            <div class="faq-answer">
                                <p>Atendemos de lunes a viernes de 8:00 AM a 6:00 PM y sábados de 8:00 AM a 2:00 PM.</p>
                            </div>
                        </div>
                        <div class="faq-item">
                            <div class="faq-question">
                                <span class="faq-icon">❓</span>
                                <h3>¿Aceptan tarjetas de crédito?</h3>
                                <span class="faq-toggle">+</span>
                            </div>
                            <div class="faq-answer">
                                <p>Sí, aceptamos todas las tarjetas de crédito y débito principales.</p>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Acciones Rápidas -->
                <div class="quick-actions">
                    <h2>⚡ Acciones Rápidas</h2>
                    <div class="actions-grid">
                        <a href="${pageContext.request.contextPath}/ContactoServlet?action=formulario" class="action-card">
                            <div class="action-icon">📞</div>
                            <h3>Contacto General</h3>
                            <p>Consulta general o solicitud de información</p>
                            <span class="action-link">Enviar mensaje →</span>
                        </a>
                        
                        <a href="${pageContext.request.contextPath}/ContactoServlet?action=soporte" class="action-card">
                            <div class="action-icon">🔧</div>
                            <h3>Soporte Técnico</h3>
                            <p>Reporte de problemas técnicos específicos</p>
                            <span class="action-link">Solicitar soporte →</span>
                        </a>
                        
                        <a href="${pageContext.request.contextPath}/ContactoServlet?action=historial" class="action-card">
                            <div class="action-icon">📋</div>
                            <h3>Historial</h3>
                            <p>Ver tus consultas y solicitudes anteriores</p>
                            <span class="action-link">Ver historial →</span>
                        </a>
                        
                        <a href="tel:<%= telefonoTaller.replaceAll("[^0-9+]", "") %>" class="action-card emergency">
                            <div class="action-icon">🚨</div>
                            <h3>Emergencia</h3>
                            <p>Servicio de grúa y emergencias 24/7</p>
                            <span class="action-link">Llamar ahora →</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>


    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // FAQ toggle functionality
            document.querySelectorAll('.faq-question').forEach(question => {
                question.addEventListener('click', function() {
                    const faqItem = this.parentElement;
                    faqItem.classList.toggle('active');
                });
            });
            
            // Smooth animations
            const sections = document.querySelectorAll('.contact-main-info, .departments-section, .faq-section, .quick-actions');
            sections.forEach((section, index) => {
                section.style.opacity = '0';
                section.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    section.style.transition = 'all 0.5s ease';
                    section.style.opacity = '1';
                    section.style.transform = 'translateY(0)';
                }, index * 200);
            });
        });
    </script>

</body>
</html>