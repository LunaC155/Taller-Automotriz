<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Vehiculo, com.upec.model.Marca, com.upec.model.Modelo" %>
<%@page import="java.util.List" %>
<%
    Vehiculo vehiculo = (Vehiculo) request.getAttribute("vehiculo");
    List<Marca> marcas = (List<Marca>) request.getAttribute("marcas");
    List<Modelo> modelos = (List<Modelo>) request.getAttribute("modelos");
    
    boolean esNuevo = vehiculo == null || vehiculo.getIDVehiculo() == null;
    String titulo = esNuevo ? "Registrar Nuevo Vehículo" : "Editar Vehículo";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= titulo %></title>
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
                <h1><%= titulo %></h1>
                <p><%= esNuevo ? "Registra un nuevo vehículo en tu cuenta" : "Modifica la información de tu vehículo" %></p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/VehiculoClienteServlet" 
                      method="post" class="crud-form">
                      
                    <input type="hidden" name="action" value="<%= esNuevo ? "registrar" : "editar" %>">
                    
                    <% if (!esNuevo) { %>
                        <input type="hidden" name="idVehiculo" value="<%= vehiculo.getIDVehiculo() %>">
                    <% } %>

                    <div class="form-grid">
                        <div class="form-section">
                            <h3>Información Básica</h3>
                            
                            <div class="form-group">
                                <label for="placa">Placa *</label>
                                <input type="text" id="placa" name="placa" 
                                       value="<%= vehiculo != null && vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "" %>" 
                                       required maxlength="10" placeholder="ABC-123">
                            </div>

                            <div class="form-group">
                                <label for="color">Color *</label>
                                <input type="text" id="color" name="color" 
                                       value="<%= vehiculo != null && vehiculo.getColor() != null ? vehiculo.getColor() : "" %>" 
                                       required maxlength="30" placeholder="Rojo, Azul, Negro...">
                            </div>

                            <div class="form-group">
                                <label for="anioVehiculo">Año del Vehículo *</label>
                                <input type="number" id="anioVehiculo" name="anioVehiculo" 
                                       value="<%= vehiculo != null && vehiculo.getAnioVehiculo() != null ? vehiculo.getAnioVehiculo() : "" %>" 
                                       required min="1900" max="2030" placeholder="2023">
                            </div>
                        </div>

                        <div class="form-section">
                            <h3>Especificaciones Técnicas</h3>
                            
                            <div class="form-group">
                                <label for="idMarca">Marca *</label>
                                <select id="idMarca" name="idMarca" required>
                                    <option value="">Seleccione una marca</option>
                                    <% if (marcas != null) { 
                                        for (Marca marca : marcas) { %>
                                        <option value="<%= marca.getIDMarca() %>" 
                                                <%= (vehiculo != null && vehiculo.getIDMarca() != null && vehiculo.getIDMarca().getIDMarca().equals(marca.getIDMarca())) ? "selected" : "" %>>
                                            <%= marca.getNombreMarca() %>
                                        </option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="idModelo">Modelo *</label>
                                <select id="idModelo" name="idModelo" required>
                                    <option value="">Seleccione un modelo</option>
                                    <% if (modelos != null) { 
                                        for (Modelo modelo : modelos) { %>
                                        <option value="<%= modelo.getIDModelo() %>" 
                                                data-marca="<%= modelo.getIDMarca() != null ? modelo.getIDMarca().getIDMarca() : "" %>"
                                                <%= (vehiculo != null && vehiculo.getIDModelo() != null && vehiculo.getIDModelo().getIDModelo().equals(modelo.getIDModelo())) ? "selected" : "" %>>
                                            <%= modelo.getNombreModelo() %>
                                        </option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="kilometraje">Kilometraje</label>
                                <input type="number" id="kilometraje" name="kilometraje" 
                                       value="<%= vehiculo != null && vehiculo.getKilometraje() != null ? vehiculo.getKilometraje() : "" %>" 
                                       min="0" placeholder="15000">
                                <small class="form-text">Kilometraje actual del vehículo</small>
                            </div>
                        </div>

                        <div class="form-section">
                            <h3>Información Adicional</h3>
                            
                            <div class="form-group">
                                <label for="numeroChasis">Número de Chasis</label>
                                <input type="text" id="numeroChasis" name="numeroChasis" 
                                       value="<%= vehiculo != null && vehiculo.getNumeroChasis() != null ? vehiculo.getNumeroChasis() : "" %>" 
                                       maxlength="50" placeholder="Número único de chasis">
                                <small class="form-text">Opcional: número de identificación del chasis</small>
                            </div>

                            <div class="form-group">
                                <label for="estado">Estado del Vehículo</label>
                                <select id="estado" name="estado">
                                    <option value="true" <%= (vehiculo == null || vehiculo.getEstado() == null || vehiculo.getEstado()) ? "selected" : "" %>>Activo</option>
                                    <option value="false" <%= (vehiculo != null && vehiculo.getEstado() != null && !vehiculo.getEstado()) ? "selected" : "" %>>Inactivo</option>
                                </select>
                                <small class="form-text">Los vehículos inactivos no podrán recibir servicios</small>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <%= esNuevo ? "Registrar Vehículo" : "Actualizar Vehículo" %>
                        </button>
                        <a href="${pageContext.request.contextPath}/VehiculoClienteServlet?action=misvehiculos" class="btn btn-secondary">
                            Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('.crud-form');
            const marcaSelect = document.getElementById('idMarca');
            const modeloSelect = document.getElementById('idModelo');
            
            // Filtrar modelos por marca seleccionada
            function filtrarModelos() {
                const marcaId = marcaSelect.value;
                const modeloOptions = modeloSelect.querySelectorAll('option');
                
                modeloOptions.forEach(option => {
                    if (option.value === '') {
                        option.style.display = '';
                        return;
                    }
                    
                    const modeloMarca = option.getAttribute('data-marca');
                    if (!marcaId || modeloMarca === marcaId) {
                        option.style.display = '';
                    } else {
                        option.style.display = 'none';
                    }
                });
                
                // Si el modelo seleccionado no corresponde a la marca, resetear
                const selectedOption = modeloSelect.querySelector('option:checked');
                if (selectedOption && selectedOption.getAttribute('data-marca') !== marcaId && marcaId !== '') {
                    modeloSelect.value = '';
                }
            }
            
            marcaSelect.addEventListener('change', filtrarModelos);
            
            // Filtrar modelos al cargar la página
            if (marcaSelect.value) {
                filtrarModelos();
            }
            
            form.addEventListener('submit', function(e) {
                const placa = document.getElementById('placa').value.trim();
                const color = document.getElementById('color').value.trim();
                const anio = document.getElementById('anioVehiculo').value.trim();
                const marca = document.getElementById('idMarca').value;
                const modelo = document.getElementById('idModelo').value;
                
                if (!placa || !color || !anio || !marca || !modelo) {
                    e.preventDefault();
                    alert('Por favor complete todos los campos obligatorios (*)');
                    return false;
                }
                
                // Validar año
                const anioNum = parseInt(anio);
                const currentYear = new Date().getFullYear();
                if (anioNum < 1900 || anioNum > currentYear + 1) {
                    e.preventDefault();
                    alert('Por favor ingrese un año válido (1900-' + (currentYear + 1) + ')');
                    return false;
                }
            });
        });
    </script>
</body>
</html>