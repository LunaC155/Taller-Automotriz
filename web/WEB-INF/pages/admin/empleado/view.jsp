<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Empleado, com.upec.model.Usuarios" %>
<%
    Empleado empleado = (Empleado) request.getAttribute("empleado");
    if (empleado == null) {
        response.sendRedirect(request.getContextPath() + "/admin/empleados");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalles de Empleado - Taller Automotriz</title>
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
                <div class="header-content">
                    <div>
                        <h1>Detalles del Empleado</h1>
                        <p>Información completa de <%= empleado.getNombre() %> <%= empleado.getApellido() %></p>
                    </div>
                    <div class="header-actions">
                        <a href="${pageContext.request.contextPath}/admin/empleados/editar?id=<%= empleado.getIDEmpleado() %>" 
                           class="btn btn-primary">
                            <span class="btn-icon">✏️</span>
                            Editar
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/empleados" class="btn btn-secondary">
                            <span class="btn-icon">↩️</span>
                            Volver
                        </a>
                    </div>
                </div>
                <nav class="breadcrumbs">
                    <a href="${pageContext.request.contextPath}/AdminIndexServlet">Inicio</a>
                    <span class="separator">/</span>
                    <a href="${pageContext.request.contextPath}/admin/empleados">Empleados</a>
                    <span class="separator">/</span>
                    <span class="active">Detalles</span>
                </nav>
            </div>

            <div class="employee-details">
                <!-- Tarjeta de Información Principal -->
                <div class="detail-card primary">
                    <div class="card-header">
                        <div class="employee-avatar">
                            <span class="avatar-icon">👤</span>
                        </div>
                        <div class="employee-basic-info">
                            <h2><%= empleado.getNombre() %> <%= empleado.getApellido() %></h2>
                            <p class="employee-id">ID: #<%= empleado.getIDEmpleado() %></p>
                            <div class="status-badge <%= empleado.getEstado() ? "active" : "inactive" %>">
                                <%= empleado.getEstado() ? "🟢 Activo" : "🔴 Inactivo" %>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="details-grid">
                    <!-- Información Personal -->
                    <div class="detail-section">
                        <h3 class="section-title">
                            <span class="section-icon">📋</span>
                            Información Personal
                        </h3>
                        <div class="detail-list">
                            <div class="detail-item">
                                <span class="detail-label">Nombre Completo:</span>
                                <span class="detail-value"><%= empleado.getNombre() %> <%= empleado.getApellido() %></span>
                            </div>
                            <% if (empleado.getEmail() != null && !empleado.getEmail().isEmpty()) { %>
                                <div class="detail-item">
                                    <span class="detail-label">Email:</span>
                                    <span class="detail-value">
                                        <a href="mailto:<%= empleado.getEmail() %>" class="email-link">
                                            <%= empleado.getEmail() %>
                                        </a>
                                    </span>
                                </div>
                            <% } %>
                            <% if (empleado.getTelefono() != null && !empleado.getTelefono().isEmpty()) { %>
                                <div class="detail-item">
                                    <span class="detail-label">Teléfono:</span>
                                    <span class="detail-value"><%= empleado.getTelefono() %></span>
                                </div>
                            <% } %>
                            <% if (empleado.getDireccion() != null && !empleado.getDireccion().isEmpty()) { %>
                                <div class="detail-item">
                                    <span class="detail-label">Dirección:</span>
                                    <span class="detail-value"><%= empleado.getDireccion() %></span>
                                </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- Información Laboral -->
                    <div class="detail-section">
                        <h3 class="section-title">
                            <span class="section-icon">💼</span>
                            Información Laboral
                        </h3>
                        <div class="detail-list">
                            <% if (empleado.getFechaContratacion() != null) { %>
                                <div class="detail-item">
                                    <span class="detail-label">Fecha de Contratación:</span>
                                    <span class="detail-value">
                                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(empleado.getFechaContratacion()) %>
                                    </span>
                                </div>
                            <% } %>
                            <div class="detail-item">
                                <span class="detail-label">Salario:</span>
                                <span class="detail-value salary">
                                    $<%= empleado.getSalario() != null ? 
                                        String.format("%,.2f", empleado.getSalario()) : "0.00" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Estado Laboral:</span>
                                <span class="detail-value">
                                    <span class="badge <%= empleado.getEstado() ? "badge-success" : "badge-warning" %>">
                                        <%= empleado.getEstado() ? "Activo" : "Inactivo" %>
                                    </span>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Información del Usuario -->
                    <div class="detail-section">
                        <h3 class="section-title">
                            <span class="section-icon">🔐</span>
                            Acceso al Sistema
                        </h3>
                        <% if (empleado.getIDUsuario() != null) { %>
                            <div class="user-info-card">
                                <div class="user-header">
                                    <span class="user-icon">👤</span>
                                    <div class="user-details">
                                        <h4><%= empleado.getIDUsuario().getUsuario() %></h4>
                                        <p class="user-email">
                                            <%= empleado.getIDUsuario().getEmail() != null ? 
                                                empleado.getIDUsuario().getEmail() : "Sin email" %>
                                        </p>
                                    </div>
                                </div>
                                <div class="user-detail-list">
                                    <div class="detail-item">
                                        <span class="detail-label">Rol:</span>
                                        <span class="detail-value">
                                            <span class="badge badge-primary">
                                                <%= empleado.getIDUsuario().getIDRol().getNombreRol() %>
                                            </span>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Estado del Usuario:</span>
                                        <span class="detail-value">
                                            <span class="badge <%= empleado.getIDUsuario().getEstado() ? "badge-success" : "badge-warning" %>">
                                                <%= empleado.getIDUsuario().getEstado() ? "Activo" : "Inactivo" %>
                                            </span>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Fecha de Creación:</span>
                                        <span class="detail-value">
                                            <%= empleado.getIDUsuario().getFechaCreacion() != null ? 
                                                new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(empleado.getIDUsuario().getFechaCreacion()) : 
                                                "No especificada" %>
                                        </span>
                                    </div>
                                </div>
                                <div class="user-actions">
                                    <a href="${pageContext.request.contextPath}/admin/empleados/asignar-usuario?id=<%= empleado.getIDEmpleado() %>" 
                                       class="btn btn-sm btn-outline">
                                        <span class="btn-icon">🔄</span>
                                        Cambiar Usuario
                                    </a>
                                </div>
                            </div>
                        <% } else { %>
                            <div class="no-user-message">
                                <div class="no-user-icon">❌</div>
                                <h4>Sin Usuario Asignado</h4>
                                <p>Este empleado no tiene acceso al sistema.</p>
                                <a href="${pageContext.request.contextPath}/admin/empleados/asignar-usuario?id=<%= empleado.getIDEmpleado() %>" 
                                   class="btn btn-primary btn-sm">
                                    <span class="btn-icon">👤</span>
                                    Asignar Usuario
                                </a>
                            </div>
                        <% } %>
                    </div>

                    <!-- Acciones Rápidas -->
                    <div class="detail-section">
                        <h3 class="section-title">
                            <span class="section-icon">⚡</span>
                            Acciones Rápidas
                        </h3>
                        <div class="quick-actions-grid">
                            <a href="${pageContext.request.contextPath}/admin/empleados/editar?id=<%= empleado.getIDEmpleado() %>" 
                               class="quick-action">
                                <span class="action-icon">✏️</span>
                                <span class="action-text">Editar Información</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/empleados/actualizar-salario?id=<%= empleado.getIDEmpleado() %>" 
                               class="quick-action">
                                <span class="action-icon">💰</span>
                                <span class="action-text">Actualizar Salario</span>
                            </a>
                            <% if (empleado.getIDUsuario() == null) { %>
                                <a href="${pageContext.request.contextPath}/admin/empleados/asignar-usuario?id=<%= empleado.getIDEmpleado() %>" 
                                   class="quick-action">
                                    <span class="action-icon">👤</span>
                                    <span class="action-text">Asignar Usuario</span>
                                </a>
                            <% } %>
                            <form action="${pageContext.request.contextPath}/admin/empleados/cambiar-estado" 
                                  method="post" 
                                  class="quick-action-form">
                                <input type="hidden" name="id" value="<%= empleado.getIDEmpleado() %>">
                                <input type="hidden" name="estado" value="<%= !empleado.getEstado() %>">
                                <button type="submit" 
                                        class="quick-action <%= empleado.getEstado() ? "action-warning" : "action-success" %>"
                                        onclick="return confirm('¿Estás seguro de que quieres <%= empleado.getEstado() ? "desactivar" : "activar" %> este empleado?')">
                                    <span class="action-icon"><%= empleado.getEstado() ? "⏸️" : "▶️" %></span>
                                    <span class="action-text"><%= empleado.getEstado() ? "Desactivar" : "Activar" %></span>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <style>
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: var(--spacing);
        }

        .header-actions {
            display: flex;
            gap: var(--spacing);
        }

        .employee-details {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-xl);
        }

        .detail-card.primary {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: var(--white);
            border-radius: var(--border-radius-xl);
            padding: var(--spacing-2xl);
            box-shadow: var(--shadow-lg);
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: var(--spacing-lg);
        }

        .employee-avatar {
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            backdrop-filter: blur(10px);
        }

        .employee-basic-info h2 {
            margin: 0 0 var(--spacing-xs) 0;
            font-size: var(--font-size-3xl);
            font-weight: 700;
        }

        .employee-id {
            opacity: 0.9;
            margin-bottom: var(--spacing);
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: var(--spacing-xs);
            padding: 6px 12px;
            border-radius: var(--border-radius-full);
            font-size: var(--font-size-sm);
            font-weight: 600;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
        }

        .details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: var(--spacing-xl);
        }

        .detail-section {
            background: var(--white);
            border-radius: var(--border-radius-lg);
            padding: var(--spacing-xl);
            box-shadow: var(--shadow);
            border: 1px solid var(--border-light);
        }

        .section-title {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
            margin-bottom: var(--spacing-lg);
            color: var(--text-primary);
            font-size: var(--font-size-lg);
            font-weight: 600;
            padding-bottom: var(--spacing);
            border-bottom: 2px solid var(--border-light);
        }

        .section-icon {
            font-size: var(--font-size-xl);
        }

        .detail-list {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-md);
        }

        .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: var(--spacing);
            padding: var(--spacing-sm) 0;
            border-bottom: 1px solid var(--border-light);
        }

        .detail-item:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: var(--text-secondary);
            min-width: 120px;
        }

        .detail-value {
            text-align: right;
            flex: 1;
            color: var(--text-primary);
        }

        .salary {
            font-size: var(--font-size-lg);
            font-weight: 700;
            color: var(--success-color);
        }

        .email-link {
            color: var(--primary-color);
            text-decoration: none;
        }

        .email-link:hover {
            text-decoration: underline;
        }

        .user-info-card {
            background: var(--light-color);
            border-radius: var(--border-radius);
            padding: var(--spacing-lg);
            border-left: 4px solid var(--primary-color);
        }

        .user-header {
            display: flex;
            align-items: center;
            gap: var(--spacing);
            margin-bottom: var(--spacing);
        }

        .user-icon {
            font-size: 2rem;
        }

        .user-details h4 {
            margin: 0 0 var(--spacing-xs) 0;
            color: var(--text-primary);
        }

        .user-email {
            margin: 0;
            color: var(--text-secondary);
            font-size: var(--font-size-sm);
        }

        .user-detail-list {
            margin-bottom: var(--spacing);
        }

        .user-actions {
            text-align: right;
        }

        .no-user-message {
            text-align: center;
            padding: var(--spacing-xl);
            color: var(--text-secondary);
        }

        .no-user-icon {
            font-size: 3rem;
            margin-bottom: var(--spacing);
        }

        .no-user-message h4 {
            margin-bottom: var(--spacing-sm);
            color: var(--text-primary);
        }

        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: var(--spacing);
        }

        .quick-action {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: var(--spacing-sm);
            padding: var(--spacing);
            background: var(--light-color);
            border-radius: var(--border-radius);
            text-decoration: none;
            color: var(--text-primary);
            transition: var(--transition);
            border: 1px solid var(--border-light);
            text-align: center;
        }

        .quick-action:hover {
            background: var(--primary-light);
            color: var(--white);
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .quick-action-form {
            margin: 0;
        }

        .quick-action-form .quick-action {
            width: 100%;
            border: none;
            cursor: pointer;
            font-family: inherit;
        }

        .action-success:hover {
            background: var(--success-color);
        }

        .action-warning:hover {
            background: var(--warning-color);
            color: var(--dark-color);
        }

        .action-icon {
            font-size: var(--font-size-2xl);
        }

        .action-text {
            font-size: var(--font-size-sm);
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: var(--spacing);
            }

            .header-actions {
                width: 100%;
                justify-content: stretch;
            }

            .header-actions .btn {
                flex: 1;
            }

            .card-header {
                flex-direction: column;
                text-align: center;
                gap: var(--spacing);
            }

            .details-grid {
                grid-template-columns: 1fr;
            }

            .detail-item {
                flex-direction: column;
                gap: var(--spacing-xs);
                text-align: left;
            }

            .detail-label {
                min-width: unset;
            }

            .detail-value {
                text-align: left;
            }

            .quick-actions-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</body>
</html>