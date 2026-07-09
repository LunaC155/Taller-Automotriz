<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Empleado" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    Empleado empleado = (Empleado) request.getAttribute("empleado");
    boolean isEdit = empleado != null && empleado.getIDEmpleado() != null;
    String title = isEdit ? "Editar Empleado" : "Nuevo Empleado";
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
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
                <h1><%= title %></h1>
                <p><%= isEdit ? "Modifica la información del empleado" : "Registra un nuevo empleado en el sistema" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/admin/empleados/<%= isEdit ? "editar" : "crear" %>" 
                      method="post" class="admin-form">
                    
                    <% if (isEdit) { %>
                        <input type="hidden" name="idEmpleado" value="<%= empleado.getIDEmpleado() %>">
                    <% } %>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="nombre">Nombre *</label>
                            <input type="text" id="nombre" name="nombre" 
                                   value="<%= empleado != null ? empleado.getNombre() : "" %>" 
                                   class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label for="apellido">Apellido *</label>
                            <input type="text" id="apellido" name="apellido" 
                                   value="<%= empleado != null ? empleado.getApellido() : "" %>" 
                                   class="form-control" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="telefono">Teléfono</label>
                            <input type="tel" id="telefono" name="telefono" 
                                   value="<%= empleado != null && empleado.getTelefono() != null ? empleado.getTelefono() : "" %>" 
                                   class="form-control">
                        </div>

                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" 
                                   value="<%= empleado != null && empleado.getEmail() != null ? empleado.getEmail() : "" %>" 
                                   class="form-control">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="direccion">Dirección</label>
                        <textarea id="direccion" name="direccion" class="form-control" 
                                  rows="3"><%= empleado != null && empleado.getDireccion() != null ? empleado.getDireccion() : "" %></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="fechaContratacion">Fecha de Contratación</label>
                            <input type="date" id="fechaContratacion" name="fechaContratacion" 
                                   value="<%= empleado != null && empleado.getFechaContratacion() != null ? sdf.format(empleado.getFechaContratacion()) : "" %>" 
                                   class="form-control">
                        </div>

                        <div class="form-group">
                            <label for="salario">Salario</label>
                            <input type="number" id="salario" name="salario" step="0.01" 
                                   value="<%= empleado != null && empleado.getSalario() != null ? empleado.getSalario() : "" %>" 
                                   class="form-control">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="estado">Estado</label>
                        <select id="estado" name="estado" class="form-control">
                            <option value="true" <%= empleado != null && empleado.getEstado() != null && empleado.getEstado() ? "selected" : "" %>>Activo</option>
                            <option value="false" <%= empleado != null && empleado.getEstado() != null && !empleado.getEstado() ? "selected" : "" %>>Inactivo</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Actualizar Empleado" : "👨‍💼 Crear Empleado" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/empleados" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>