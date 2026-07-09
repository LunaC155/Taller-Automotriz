<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Cliente" %>
<%
    Cliente cliente = (Cliente) request.getAttribute("cliente");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Cliente</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/stylescrudadmin.css">
</head>
<body class="admin">
    <%@include file="/WEB-INF/pages/shared/header.jsp" %>
    <%@include file="/WEB-INF/pages/shared/sidebar-admin.jsp" %>
    <%@include file="/WEB-INF/pages/shared/messages.jsp" %>

    <div class="main-content-with-sidebar">
        <div class="container">
            <div class="page-header">
                <h1>Detalle del Cliente</h1>
                <p>Información completa del cliente</p>
            </div>

            <% if (cliente != null) { %>
                <div class="detail-section">
                    <div class="detail-card">
                        <h2>👤 Información Personal</h2>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <strong>ID:</strong>
                                <span><%= cliente.getIDCliente() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Nombre:</strong>
                                <span><%= cliente.getNombre() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Apellido:</strong>
                                <span><%= cliente.getApellido() %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Email:</strong>
                                <span><%= cliente.getEmail() != null ? cliente.getEmail() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Teléfono:</strong>
                                <span><%= cliente.getTelefono() != null ? cliente.getTelefono() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Dirección:</strong>
                                <span><%= cliente.getDireccion() != null ? cliente.getDireccion() : "N/A" %></span>
                            </div>
                            <div class="detail-item">
                                <strong>Fecha de Registro:</strong>
                                <span><%= cliente.getFechaRegistro() != null ? cliente.getFechaRegistro() : "N/A" %></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/admin/clientes/editar?id=<%= cliente.getIDCliente() %>" 
                       class="btn btn-primary">✏️ Editar Cliente</a>
                    <a href="${pageContext.request.contextPath}/admin/clientes" class="btn btn-secondary">↩️ Volver al Listado</a>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el cliente solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/clientes" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>