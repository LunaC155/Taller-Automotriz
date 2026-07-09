<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List, java.util.ArrayList" %>
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

    List<Object[]> historialContactos = (List<Object[]>) request.getAttribute("historialContactos");
    Integer totalContactos = (Integer) request.getAttribute("totalContactos");
    String tipoVista = (String) request.getAttribute("tipoVista");

    if (historialContactos == null) {
        historialContactos = new ArrayList<>();
    }
    if (totalContactos == null) {
        totalContactos = 0;
    }
    if (tipoVista == null)
        tipoVista = "historial";
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Historial de Contactos - Taller Automotriz</title>
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
                    <h1>📋 Historial de Contactos</h1>
                    <p>Revisa el historial de todas tus consultas y solicitudes de soporte</p>
                </div>

                <!-- Estadísticas -->
                <div class="contact-stats">
                    <div class="stat-item">
                        <div class="stat-number"><%= totalContactos%></div>
                        <div class="stat-label">Total Contactos</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <%= historialContactos.stream().filter(c -> c.length > 3 && "PENDIENTE".equals(c[3])).count()%>
                        </div>
                        <div class="stat-label">Pendientes</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">
                            <%= historialContactos.stream().filter(c -> c.length > 3 && "RESUELTO".equals(c[3])).count()%>
                        </div>
                        <div class="stat-label">Resueltos</div>
                    </div>
                </div>

                <!-- Lista de Contactos -->
                <div class="contact-history">
                    <% if (historialContactos.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">📨</div>
                        <h3>No hay contactos registrados</h3>
                        <p>No has realizado ninguna consulta o solicitud de soporte aún.</p>
                        <div class="empty-actions">
                            <a href="${pageContext.request.contextPath}/ContactoServlet?action=formulario" class="btn btn-primary">
                                📞 Realizar Primera Consulta
                            </a>
                            <a href="${pageContext.request.contextPath}/ContactoServlet?action=soporte" class="btn btn-outline">
                                🚨 Solicitar Soporte Técnico
                            </a>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="contact-list">
                        <% for (Object[] contacto : historialContactos) {
                                String id = contacto.length > 0 && contacto[0] != null ? contacto[0].toString() : "";
                                String tipo = contacto.length > 1 && contacto[1] != null ? contacto[1].toString() : "Consulta General";
                                String asunto = contacto.length > 2 && contacto[2] != null ? contacto[2].toString() : "";
                                String estado = contacto.length > 3 && contacto[3] != null ? contacto[3].toString() : "PENDIENTE";
                                String fecha = contacto.length > 4 && contacto[4] != null ? contacto[4].toString() : "";

                                String estadoClass = "pending";
                                String estadoIcon = "⏳";

                                if ("RESUELTO".equals(estado)) {
                                    estadoClass = "resolved";
                                    estadoIcon = "✅";
                                } else if ("CANCELADO".equals(estado)) {
                                    estadoClass = "cancelled";
                                    estadoIcon = "❌";
                                }
                        %>
                        <div class="contact-item <%= estadoClass%>">
                            <div class="contact-header">
                                <div class="contact-type">
                                    <span class="type-icon">
                                        <%= "SOPORTE".equals(tipo) ? "🔧" : "📞"%>
                                    </span>
                                    <span class="type-label"><%= tipo%></span>
                                </div>
                                <div class="contact-status">
                                    <span class="status-icon"><%= estadoIcon%></span>
                                    <span class="status-label <%= estadoClass%>"><%= estado%></span>
                                </div>
                            </div>

                            <div class="contact-body">
                                <h3 class="contact-subject"><%= asunto%></h3>
                                <p class="contact-date">
                                    <span class="date-icon">📅</span>
                                    <%= fecha%>
                                </p>
                            </div>

                            <div class="contact-actions">
                                <button class="btn btn-sm btn-outline view-details" 
                                        data-contacto='<%= java.net.URLEncoder.encode(id, "UTF-8")%>'>
                                    👁️ Ver Detalles
                                </button>
                                <% if ("PENDIENTE".equals(estado)) {%>
                                <button class="btn btn-sm btn-danger cancel-contact" 
                                        data-contacto='<%= java.net.URLEncoder.encode(id, "UTF-8")%>'>
                                    ❌ Cancelar
                                </button>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% }%>
                </div>

                <!-- Información de Contacto Adicional -->
                <div class="contact-info-footer">
                    <h3>¿Necesitas ayuda inmediata?</h3>
                    <div class="contact-options">
                        <div class="contact-option">
                            <div class="option-icon">📞</div>
                            <div class="option-info">
                                <h4>Teléfono de Emergencias</h4>
                                <p>+1 (555) 123-4567</p>
                                <small>Disponible 24/7 para emergencias</small>
                            </div>
                        </div>
                        <div class="contact-option">
                            <div class="option-icon">✉️</div>
                            <div class="option-info">
                                <h4>Email Principal</h4>
                                <p>soporte@tallerautomotriz.com</p>
                                <small>Respuesta en menos de 24 horas</small>
                            </div>
                        </div>
                        <div class="contact-option">
                            <div class="option-icon">💬</div>
                            <div class="option-info">
                                <h4>Chat en Vivo</h4>
                                <p>Disponible en horario comercial</p>
                                <small>Lun-Vie: 8:00 AM - 6:00 PM</small>
                            </div>
                        </div>
                    </div>
                    <div class="footer-actions">
                        <a href="${pageContext.request.contextPath}/ContactoServlet?action=formulario" class="btn btn-primary">
                            📞 Nueva Consulta
                        </a>
                        <a href="${pageContext.request.contextPath}/ContactoServlet?action=informacion" class="btn btn-outline">
                            ℹ️ Información de Contacto
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // Ver detalles del contacto
                document.querySelectorAll('.view-details').forEach(button => {
                    button.addEventListener('click', function () {
                        const contactoId = this.getAttribute('data-contacto');
                        alert('Funcionalidad de ver detalles en desarrollo.\nID del contacto: ' + contactoId);
                    });
                });

                // Cancelar contacto
                document.querySelectorAll('.cancel-contact').forEach(button => {
                    button.addEventListener('click', function () {
                        const contactoId = this.getAttribute('data-contacto');
                        if (confirm('¿Está seguro de que desea cancelar esta solicitud?\n\nEsta acción no se puede deshacer.')) {
                            alert('Funcionalidad de cancelar en desarrollo.\nID del contacto: ' + contactoId);
                        }
                    });
                });

                // Animaciones para los items
                const contactItems = document.querySelectorAll('.contact-item');
                contactItems.forEach((item, index) => {
                    item.style.opacity = '0';
                    item.style.transform = 'translateY(20px)';

                    setTimeout(() => {
                        item.style.transition = 'all 0.5s ease';
                        item.style.opacity = '1';
                        item.style.transform = 'translateY(0)';
                    }, index * 100);
                });
            });
        </script>

    </body>
</html>