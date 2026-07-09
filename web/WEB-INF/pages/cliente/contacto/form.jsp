<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente" %>
<%@page import="java.util.List" %>
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

    Cliente cliente = (Cliente) request.getAttribute("cliente");
    List<String> tiposConsulta = (List<String>) request.getAttribute("tiposConsulta");
    List<String> areasSoporte = (List<String>) request.getAttribute("areasSoporte");
    List<String> tiposProblema = (List<String>) request.getAttribute("tiposProblema");
    List<String> nivelesUrgencia = (List<String>) request.getAttribute("nivelesUrgencia");
    String tipoVista = (String) request.getAttribute("tipoVista");
    
    // CORRECCIÓN: Inicializar para evitar nulls
    if (cliente == null) {
        // Crear cliente temporal para evitar errores
        cliente = new Cliente();
        cliente.setNombre("Cliente");
        cliente.setApellido("No identificado");
    }
    if (tiposConsulta == null) tiposConsulta = java.util.Collections.emptyList();
    if (areasSoporte == null) areasSoporte = java.util.Collections.emptyList();
    if (tiposProblema == null) tiposProblema = java.util.Collections.emptyList();
    if (nivelesUrgencia == null) nivelesUrgencia = java.util.Collections.emptyList();
    if (tipoVista == null) tipoVista = "contacto-general";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Contacto</title>
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
                <h1>📞 Contacto</h1>
                <p>Estamos aquí para ayudarte. Contáctanos para cualquier consulta o asistencia.</p>
            </div>

            <div class="contact-container">
                <!-- Información de Contacto -->
                <div class="contact-info">
                    <h2>📞 Información de Contacto</h2>
                    <div class="contact-methods">
                        <div class="contact-method">
                            <div class="method-icon">📞</div>
                            <div class="method-info">
                                <h3>Teléfono</h3>
                                <p>(04) 234-5678</p>
                                <small>Lunes a Viernes: 8:00 AM - 6:00 PM</small>
                            </div>
                        </div>
                        
                        <div class="contact-method">
                            <div class="method-icon">📧</div>
                            <div class="method-info">
                                <h3>Email</h3>
                                <p>contacto@tallerautomotriz.com</p>
                                <small>Respondemos en menos de 24 horas</small>
                            </div>
                        </div>
                        
                        <div class="contact-method">
                            <div class="method-icon">📍</div>
                            <div class="method-info">
                                <h3>Dirección</h3>
                                <p>Av. Principal #123</p>
                                <p>Ciudad, Estado 12345</p>
                                <small>Estacionamiento gratuito disponible</small>
                            </div>
                        </div>
                        
                        <div class="contact-method">
                            <div class="method-icon">🕒</div>
                            <div class="method-info">
                                <h3>Horario de Atención</h3>
                                <p>Lunes a Viernes: 8:00 AM - 6:00 PM</p>
                                <p>Sábados: 8:00 AM - 2:00 PM</p>
                                <small>Domingos: Cerrado</small>
                            </div>
                        </div>
                    </div>

                    <!-- Departamentos -->
                    <div class="departments-section">
                        <h3>🏢 Departamentos de Contacto</h3>
                        <div class="departments-grid">
                            <div class="department-card">
                                <h4>Servicio al Cliente</h4>
                                <p>Consultas generales y atención al cliente</p>
                                <p class="contact-detail">📧 clientes@taller.com</p>
                                <p class="contact-detail">📞 (04) 234-5000</p>
                            </div>
                            
                            <div class="department-card">
                                <h4>Soporte Técnico</h4>
                                <p>Asistencia técnica y diagnósticos</p>
                                <p class="contact-detail">📧 soporte@taller.com</p>
                                <p class="contact-detail">📞 (04) 234-5001</p>
                            </div>
                            
                            <div class="department-card">
                                <h4>Facturación</h4>
                                <p>Facturas y estados de cuenta</p>
                                <p class="contact-detail">📧 facturacion@taller.com</p>
                                <p class="contact-detail">📞 (04) 234-5002</p>
                            </div>
                            
                            <div class="department-card">
                                <h4>Citas y Agenda</h4>
                                <p>Programación de servicios</p>
                                <p class="contact-detail">📧 citas@taller.com</p>
                                <p class="contact-detail">📞 (04) 234-5003</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Formulario de Contacto -->
                <div class="contact-form-section">
                    <h2>✉️ Envíanos un Mensaje</h2>
                    
                    <% if ("soporte-tecnico".equals(tipoVista)) { %>
                        <!-- Formulario de Soporte Técnico -->
                        <form action="${pageContext.request.contextPath}/ContactoServlet" method="post" class="contact-form">
                            <input type="hidden" name="action" value="enviarSoporte">
                            
                            <div class="form-group">
                                <label for="tipoProblema">Tipo de Problema *</label>
                                <select id="tipoProblema" name="tipoProblema" required class="form-control">
                                    <option value="">Seleccione el tipo de problema</option>
                                    <% for (String tipo : tiposProblema) { %>
                                        <option value="<%= tipo %>"><%= tipo %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="urgencia">Nivel de Urgencia *</label>
                                <select id="urgencia" name="urgencia" required class="form-control">
                                    <option value="">Seleccione la urgencia</option>
                                    <% for (String nivel : nivelesUrgencia) { %>
                                        <option value="<%= nivel %>"><%= nivel %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="descripcionProblema">Descripción del Problema *</label>
                                <textarea id="descripcionProblema" name="descripcionProblema" 
                                          rows="5" required class="form-control" 
                                          placeholder="Describe detalladamente el problema técnico que estás experimentando..."></textarea>
                            </div>

                            <div class="form-group">
                                <label for="pasosReproducir">Pasos para Reproducir el Problema</label>
                                <textarea id="pasosReproducir" name="pasosReproducir" 
                                          rows="3" class="form-control" 
                                          placeholder="Describe los pasos específicos que llevan al problema..."></textarea>
                            </div>

                            <div class="form-group">
                                <label for="resultadoEsperado">Resultado Esperado</label>
                                <textarea id="resultadoEsperado" name="resultadoEsperado" 
                                          rows="3" class="form-control" 
                                          placeholder="¿Qué resultado esperabas obtener?"></textarea>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">🚨 Enviar Solicitud de Soporte</button>
                                <a href="${pageContext.request.contextPath}/ContactoServlet?action=formulario" class="btn btn-secondary">↩️ Volver</a>
                            </div>
                        </form>

                    <% } else { %>
                        <!-- Formulario de Contacto General -->
                        <form action="${pageContext.request.contextPath}/ContactoServlet" method="post" class="contact-form">
                            <input type="hidden" name="action" value="enviar">
                            
                            <!-- Información del Cliente -->
                            <div class="client-info-card">
                                <h4>👤 Información del Cliente</h4>
                                <div class="client-details">
                                    <p><strong>Nombre:</strong> <%= cliente.getNombre() + " " + cliente.getApellido() %></p>
                                    <p><strong>Email:</strong> <%= cliente.getEmail() != null ? cliente.getEmail() : "No registrado" %></p>
                                    <p><strong>Teléfono:</strong> <%= cliente.getTelefono() != null ? cliente.getTelefono() : "No registrado" %></p>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="tipoConsulta">Tipo de Consulta *</label>
                                <select id="tipoConsulta" name="tipoConsulta" required class="form-control">
                                    <option value="">Seleccione el tipo de consulta</option>
                                    <% for (String tipo : tiposConsulta) { %>
                                        <option value="<%= tipo %>"><%= tipo %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="asunto">Asunto *</label>
                                <input type="text" id="asunto" name="asunto" 
                                       required class="form-control" 
                                       placeholder="Ingrese el asunto de su consulta...">
                            </div>

                            <div class="form-group">
                                <label for="mensaje">Mensaje *</label>
                                <textarea id="mensaje" name="mensaje" 
                                          rows="6" required class="form-control" 
                                          placeholder="Escriba su mensaje detallado aquí..."></textarea>
                            </div>

                            <div class="form-group">
                                <label for="prioridad">Prioridad</label>
                                <select id="prioridad" name="prioridad" class="form-control">
                                    <option value="baja">Baja</option>
                                    <option value="normal" selected>Normal</option>
                                    <option value="alta">Alta</option>
                                    <option value="urgente">Urgente</option>
                                </select>
                                <small class="form-text">Seleccione la urgencia de su consulta</small>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">📤 Enviar Mensaje</button>
                                <a href="${pageContext.request.contextPath}/ContactoServlet?action=soporte" class="btn btn-warning">🚨 Soporte Técnico</a>
                                <button type="reset" class="btn btn-secondary">🔄 Limpiar</button>
                            </div>
                        </form>
                    <% } %>
                </div>
            </div>

            <!-- Preguntas Frecuentes -->
            <div class="faq-section">
                <h2>❓ Preguntas Frecuentes</h2>
                <div class="faq-grid">
                    <div class="faq-item">
                        <h4>¿Cuál es el horario de atención?</h4>
                        <p>Atendemos de lunes a viernes de 8:00 AM a 6:00 PM y sábados de 8:00 AM a 2:00 PM.</p>
                    </div>
                    
                    <div class="faq-item">
                        <h4>¿Aceptan tarjetas de crédito?</h4>
                        <p>Sí, aceptamos todas las tarjetas de crédito y débito principales.</p>
                    </div>
                    
                    <div class="faq-item">
                        <h4>¿Ofrecen servicio a domicilio?</h4>
                        <p>Sí, ofrecemos servicio de grúa y diagnóstico a domicilio para clientes registrados.</p>
                    </div>
                    
                    <div class="faq-item">
                        <h4>¿Cuánto tiempo toma una revisión general?</h4>
                        <p>Una revisión general completa toma aproximadamente 2-3 horas.</p>
                    </div>
                    
                    <div class="faq-item">
                        <h4>¿Tienen garantía en sus servicios?</h4>
                        <p>Sí, todos nuestros servicios tienen garantía de 90 días o 5,000 km.</p>
                    </div>
                    
                    <div class="faq-item">
                        <h4>¿Puedo programar cita en línea?</h4>
                        <p>Sí, puede programar citas a través de nuestro portal web o aplicación móvil.</p>
                    </div>
                </div>
                
                <div class="faq-actions">
                    <a href="${pageContext.request.contextPath}/ContactoServlet?action=informacion" class="btn btn-info">
                        ℹ️ Más Información de Contacto
                    </a>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>


    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Validación del formulario de contacto general
            const contactForm = document.querySelector('form[action*="ContactoServlet"]');
            if (contactForm) {
                contactForm.addEventListener('submit', function(e) {
                    const action = contactForm.querySelector('input[name="action"]').value;
                    
                    if (action === 'enviar') {
                        const tipoConsulta = document.getElementById('tipoConsulta');
                        const asunto = document.getElementById('asunto');
                        const mensaje = document.getElementById('mensaje');
                        
                        if (tipoConsulta && !tipoConsulta.value) {
                            e.preventDefault();
                            alert('Por favor seleccione el tipo de consulta');
                            tipoConsulta.focus();
                            return false;
                        }
                        
                        if (asunto && !asunto.value.trim()) {
                            e.preventDefault();
                            alert('Por favor ingrese el asunto');
                            asunto.focus();
                            return false;
                        }
                        
                        if (mensaje && mensaje.value.trim().length < 10) {
                            e.preventDefault();
                            alert('Por favor proporcione un mensaje más detallado (mínimo 10 caracteres)');
                            mensaje.focus();
                            return false;
                        }
                    } else if (action === 'enviarSoporte') {
                        const tipoProblema = document.getElementById('tipoProblema');
                        const urgencia = document.getElementById('urgencia');
                        const descripcion = document.getElementById('descripcionProblema');
                        
                        if (tipoProblema && !tipoProblema.value) {
                            e.preventDefault();
                            alert('Por favor seleccione el tipo de problema');
                            tipoProblema.focus();
                            return false;
                        }
                        
                        if (urgencia && !urgencia.value) {
                            e.preventDefault();
                            alert('Por favor seleccione el nivel de urgencia');
                            urgencia.focus();
                            return false;
                        }
                        
                        if (descripcion && descripcion.value.trim().length < 20) {
                            e.preventDefault();
                            alert('Por favor describa el problema con más detalle (mínimo 20 caracteres)');
                            descripcion.focus();
                            return false;
                        }
                    }
                });
            }
            
            // Contador de caracteres para textareas
            const textareas = document.querySelectorAll('textarea[required]');
            textareas.forEach(textarea => {
                const counter = document.createElement('div');
                counter.className = 'char-counter';
                counter.style.fontSize = '0.8rem';
                counter.style.color = '#666';
                counter.style.textAlign = 'right';
                counter.style.marginTop = '0.5rem';
                textarea.parentNode.appendChild(counter);
                
                function updateCounter() {
                    const count = textarea.value.length;
                    const minLength = textarea.id === 'descripcionProblema' ? 20 : 10;
                    counter.textContent = count + ' caracteres (mínimo ' + minLength + ')';
                    
                    if (count < minLength) {
                        counter.style.color = '#dc3545';
                    } else if (count < minLength * 2) {
                        counter.style.color = '#ffc107';
                    } else {
                        counter.style.color = '#28a745';
                    }
                }
                
                textarea.addEventListener('input', updateCounter);
                updateCounter();
            });
        });
    </script>
</body>
</html>