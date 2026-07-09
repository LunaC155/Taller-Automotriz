<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    String tipoReporte = (String) request.getAttribute("tipoReporte");
    if (tipoReporte == null) tipoReporte = "financiero";
    
    Date fechaInicio = (Date) request.getAttribute("fechaInicio");
    Date fechaFin = (Date) request.getAttribute("fechaFin");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String fechaInicioStr = fechaInicio != null ? sdf.format(fechaInicio) : "";
    String fechaFinStr = fechaFin != null ? sdf.format(fechaFin) : "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Generar Reportes</title>
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
                <h1>Generar Reportes</h1>
                <p>Genera reportes detallados del funcionamiento del taller</p>
            </div>

            <div class="form-container">
                <form action="${pageContext.request.contextPath}/ReporteServlet" method="post" class="admin-form">
                    <input type="hidden" name="action" value="generarReporte">
                    
                    <!-- Selección de tipo de reporte -->
                    <div class="form-group">
                        <label for="tipoReporte">Tipo de Reporte *</label>
                        <select id="tipoReporte" name="tipoReporte" class="form-control" required
                                onchange="mostrarFiltros(this.value)">
                            <option value="financiero" <%= "financiero".equals(tipoReporte) ? "selected" : "" %>>📊 Reportes Financieros</option>
                            <option value="productividad" <%= "productividad".equals(tipoReporte) ? "selected" : "" %>>⚙️ Reportes de Productividad</option>
                            <option value="vehiculos" <%= "vehiculos".equals(tipoReporte) ? "selected" : "" %>>🚗 Reportes de Vehículos</option>
                            <option value="inventario" <%= "inventario".equals(tipoReporte) ? "selected" : "" %>>📦 Reportes de Inventario</option>
                        </select>
                    </div>

                    <!-- Filtros por fecha (para reportes financieros y productividad) -->
                    <div id="filtrosFecha" class="form-row" 
                         style="display: <%= "financiero".equals(tipoReporte) || "productividad".equals(tipoReporte) ? "flex" : "none" %>">
                        <div class="form-group">
                            <label for="fechaInicio">Fecha Inicio</label>
                            <input type="date" id="fechaInicio" name="fechaInicio" 
                                   value="<%= fechaInicioStr %>" class="form-control">
                        </div>
                        <div class="form-group">
                            <label for="fechaFin">Fecha Fin</label>
                            <input type="date" id="fechaFin" name="fechaFin" 
                                   value="<%= fechaFinStr %>" class="form-control">
                        </div>
                    </div>

                    <!-- Filtros adicionales para vehículos -->
                    <div id="filtrosVehiculos" class="form-group" 
                         style="display: <%= "vehiculos".equals(tipoReporte) ? "block" : "none" %>">
                        <label for="filtroMarca">Filtrar por Marca</label>
                        <select id="filtroMarca" name="filtroMarca" class="form-control">
                            <option value="">Todas las marcas</option>
                            <!-- Las marcas se cargarían dinámicamente -->
                        </select>
                    </div>

                    <!-- Formato de salida -->
                    <div class="form-group">
                        <label for="formato">Formato de Salida</label>
                        <select id="formato" name="formato" class="form-control">
                            <option value="pantalla">📱 Ver en Pantalla</option>
                            <option value="pdf">📄 PDF</option>
                            <option value="excel">📊 Excel</option>
                        </select>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            📈 Generar Reporte
                        </button>
                        <button type="reset" class="btn btn-secondary">
                            🗑️ Limpiar
                        </button>
                    </div>
                </form>
            </div>

            <!-- Accesos rápidos -->
            <div class="quick-actions">
                <h3>📊 Accesos Rápidos</h3>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/ReporteServlet?action=financieros" class="btn btn-outline">
                        💰 Reportes Financieros
                    </a>
                    <a href="${pageContext.request.contextPath}/ReporteServlet?action=productividad" class="btn btn-outline">
                        ⚙️ Reportes de Productividad
                    </a>
                    <a href="${pageContext.request.contextPath}/ReporteServlet?action=vehiculos" class="btn btn-outline">
                        🚗 Reportes de Vehículos
                    </a>
                    <a href="${pageContext.request.contextPath}/ReporteServlet?action=inventarios" class="btn btn-outline">
                        📦 Reportes de Inventario
                    </a>
                </div>
            </div>

            <!-- Descripción de reportes -->
            <div class="info-grid">
                <div class="info-card">
                    <h3>📊 Reportes Financieros</h3>
                    <ul>
                        <li>Facturación total por período</li>
                        <li>Facturas pendientes vs pagadas</li>
                        <li>Ingresos mensuales</li>
                        <li>Top clientes por facturación</li>
                    </ul>
                </div>

                <div class="info-card">
                    <h3>⚙️ Reportes de Productividad</h3>
                    <ul>
                        <li>Órdenes de servicio completadas</li>
                        <li>Tiempo promedio de reparación</li>
                        <li>Eficiencia de mecánicos</li>
                        <li>Órdenes pendientes y atrasadas</li>
                    </ul>
                </div>

                <div class="info-card">
                    <h3>🚗 Reportes de Vehículos</h3>
                    <ul>
                        <li>Vehículos por marca y modelo</li>
                        <li>Kilometraje promedio</li>
                        <li>Vehículos más frecuentes</li>
                        <li>Estadísticas de antigüedad</li>
                    </ul>
                </div>

                <div class="info-card">
                    <h3>📦 Reportes de Inventario</h3>
                    <ul>
                        <li>Stock de repuestos</li>
                        <li>Repuestos más utilizados</li>
                        <li>Niveles de inventario</li>
                        <li>Repuestos por agotarse</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <script>
        function mostrarFiltros(tipo) {
            const filtrosFecha = document.getElementById('filtrosFecha');
            const filtrosVehiculos = document.getElementById('filtrosVehiculos');
            
            if (tipo === 'financiero' || tipo === 'productividad') {
                filtrosFecha.style.display = 'flex';
                filtrosVehiculos.style.display = 'none';
            } else if (tipo === 'vehiculos') {
                filtrosFecha.style.display = 'none';
                filtrosVehiculos.style.display = 'block';
            } else {
                filtrosFecha.style.display = 'none';
                filtrosVehiculos.style.display = 'none';
            }
        }
    </script>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>