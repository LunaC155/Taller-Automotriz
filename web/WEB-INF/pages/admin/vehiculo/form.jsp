<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo" %>
<%@page import="com.upec.model.Marca" %>
<%@page import="com.upec.model.Modelo" %>
<%@page import="com.upec.model.Cliente" %>
<%@page import="java.util.List" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
    List<Marca> marcas = (List<Marca>) request.getAttribute("marcas");
    List<Modelo> modelos = (List<Modelo>) request.getAttribute("modelos");
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    boolean isEdit = vehiculo != null && vehiculo.getIDVehiculo() != null;
    String title = isEdit ? "Editar Vehículo" : "Nuevo Vehículo";
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
                <p><%= isEdit ? "Modifica la información del vehículo" : "Registra un nuevo vehículo en el sistema" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/admin/vehiculos/<%= isEdit ? "editar" : "crear" %>" 
                      method="post" class="admin-form">
                    
                    <% if (isEdit) { %>
                        <input type="hidden" name="idVehiculo" value="<%= vehiculo.getIDVehiculo() %>">
                    <% } %>

                    <div class="form-group">
                        <label for="placa">Placa *</label>
                        <input type="text" id="placa" name="placa" 
                               value="<%= vehiculo != null ? vehiculo.getPlaca() : "" %>" 
                               class="form-control" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="idMarca">Marca *</label>
                            <select id="idMarca" name="idMarca" class="form-control" required
                                    onchange="cargarModelos(this.value)">
                                <option value="">Seleccionar Marca</option>
                                <% if (marcas != null) { %>
                                    <% for (Marca marca : marcas) { %>
                                        <option value="<%= marca.getIDMarca() %>" 
                                                <%= vehiculo != null && vehiculo.getIDMarca() != null && vehiculo.getIDMarca().getIDMarca().equals(marca.getIDMarca()) ? "selected" : "" %>>
                                            <%= marca.getNombreMarca() %>
                                        </option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="idModelo">Modelo *</label>
                            <select id="idModelo" name="idModelo" class="form-control" required>
                                <option value="">Seleccionar Modelo</option>
                                <% if (modelos != null) { %>
                                    <% for (Modelo modelo : modelos) { %>
                                        <option value="<%= modelo.getIDModelo() %>" 
                                                <%= vehiculo != null && vehiculo.getIDModelo() != null && vehiculo.getIDModelo().getIDModelo().equals(modelo.getIDModelo()) ? "selected" : "" %>>
                                            <%= modelo.getNombreModelo() %>
                                        </option>
                                    <% } %>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="color">Color</label>
                            <input type="text" id="color" name="color" 
                                   value="<%= vehiculo != null && vehiculo.getColor() != null ? vehiculo.getColor() : "" %>" 
                                   class="form-control">
                        </div>

                        <div class="form-group">
                            <label for="anioVehiculo">Año</label>
                            <input type="number" id="anioVehiculo" name="anioVehiculo" 
                                   value="<%= vehiculo != null && vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "" %>" 
                                   class="form-control" min="1900" max="2030">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="numeroChasis">Número de Chasis</label>
                        <input type="text" id="numeroChasis" name="numeroChasis" 
                               value="<%= vehiculo != null && vehiculo.getNumeroChasis() != null ? vehiculo.getNumeroChasis() : "" %>" 
                               class="form-control">
                    </div>

                    <div class="form-group">
                        <label for="kilometraje">Kilometraje</label>
                        <input type="number" id="kilometraje" name="kilometraje" 
                               value="<%= vehiculo != null && vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : "" %>" 
                               class="form-control" min="0">
                    </div>

                    <div class="form-group">
                        <label for="idCliente">Cliente *</label>
                        <select id="idCliente" name="idCliente" class="form-control" required>
                            <option value="">Seleccionar Cliente</option>
                            <% if (clientes != null) { %>
                                <% for (Cliente cliente : clientes) { %>
                                    <option value="<%= cliente.getIDCliente() %>" 
                                            <%= vehiculo != null && vehiculo.getIDCliente() != null && vehiculo.getIDCliente().getIDCliente().equals(cliente.getIDCliente()) ? "selected" : "" %>>
                                        <%= cliente.getNombre() %> <%= cliente.getApellido() %>
                                    </option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="estado">Estado</label>
                        <select id="estado" name="estado" class="form-control">
                            <option value="true" <%= vehiculo != null && vehiculo.getEstado() != null && vehiculo.getEstado() ? "selected" : "" %>>Activo</option>
                            <option value="false" <%= vehiculo != null && vehiculo.getEstado() != null && !vehiculo.getEstado() ? "selected" : "" %>>Inactivo</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Actualizar Vehículo" : "🚗 Crear Vehículo" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/vehiculos" class="btn btn-secondary">
                            ↩️ Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function cargarModelos(idMarca) {
            if (idMarca) {
                window.location.href = '${pageContext.request.contextPath}/admin/vehiculos/crear?idMarca=' + idMarca;
            }
        }
    </script>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>