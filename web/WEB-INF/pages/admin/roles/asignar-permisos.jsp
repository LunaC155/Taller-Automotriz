<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.upec.model.Roles" %>
<%@page import="java.util.List" %>
<%
    Roles rol = (Roles) request.getAttribute("rol");
    List<String> permisosDisponibles = (List<String>) request.getAttribute("permisosDisponibles");
    List<String> permisosActuales = (List<String>) request.getAttribute("permisosActuales");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Asignar Permisos</title>
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
                <h1>Asignar Permisos</h1>
                <p>Gestiona los permisos del rol: <strong><%= rol != null ? rol.getNombreRol() : "N/A" %></strong></p>
            </div>

            <% if (rol != null) { %>
                <div class="form-container">
                    <!-- Información del rol -->
                    <div class="info-card">
                        <h3>🔐 Rol: <%= rol.getNombreRol() %></h3>
                        <p><%= rol.getDescripcion() != null ? rol.getDescripcion() : "Sin descripción" %></p>
                        <div class="role-meta">
                            <span class="badge <%= rol.getEstado() != null && rol.getEstado() ? "badge-success" : "badge-danger" %>">
                                <%= rol.getEstado() != null && rol.getEstado() ? "Activo" : "Inactivo" %>
                            </span>
                            <span>Permisos actuales: <%= permisosActuales != null ? permisosActuales.size() : 0 %></span>
                        </div>
                    </div>

                    <!-- Formulario de permisos -->
                    <form action="${pageContext.request.contextPath}/admin/roles/asignar-permisos" method="post" class="permissions-form">
                        <input type="hidden" name="idRol" value="<%= rol.getIDRol() %>">
                        
                        <div class="permissions-section">
                            <h3>🔧 Permisos Disponibles</h3>
                            <p class="form-help">Selecciona los permisos que tendrán los usuarios con este rol:</p>
                            
                            <div class="permissions-grid">
                                <% if (permisosDisponibles != null && !permisosDisponibles.isEmpty()) { %>
                                    <% for (String permiso : permisosDisponibles) { %>
                                        <div class="permission-item">
                                            <label class="permission-checkbox">
                                                <input type="checkbox" name="permisos" value="<%= permiso %>"
                                                       <%= permisosActuales != null && permisosActuales.contains(permiso) ? "checked" : "" %>>
                                                <span class="checkmark"></span>
                                                <div class="permission-info">
                                                    <span class="permission-name"><%= permiso %></span>
                                                    <span class="permission-description">
                                                        <% 
                                                            String descripcion = "";
                                                            switch(permiso) {
                                                                case "admin":
                                                                    descripcion = "Acceso completo al sistema";
                                                                    break;
                                                                case "gestion_usuarios":
                                                                    descripcion = "Crear, editar y eliminar usuarios";
                                                                    break;
                                                                case "gestion_roles":
                                                                    descripcion = "Administrar roles y permisos";
                                                                    break;
                                                                case "gestion_clientes":
                                                                    descripcion = "Gestionar información de clientes";
                                                                    break;
                                                                case "gestion_vehiculos":
                                                                    descripcion = "Administrar vehículos y propietarios";
                                                                    break;
                                                                case "gestion_empleados":
                                                                    descripcion = "Gestionar empleados y salarios";
                                                                    break;
                                                                case "gestion_ordenes":
                                                                    descripcion = "Crear y modificar órdenes de servicio";
                                                                    break;
                                                                case "gestion_diagnosticos":
                                                                    descripcion = "Realizar y ver diagnósticos";
                                                                    break;
                                                                case "gestion_facturas":
                                                                    descripcion = "Emitir y gestionar facturas";
                                                                    break;
                                                                case "gestion_inventario":
                                                                    descripcion = "Controlar stock de repuestos";
                                                                    break;
                                                                case "ver_reportes":
                                                                    descripcion = "Acceder a reportes del sistema";
                                                                    break;
                                                                case "generar_reportes":
                                                                    descripcion = "Crear y exportar reportes";
                                                                    break;
                                                                case "configuracion_sistema":
                                                                    descripcion = "Modificar configuraciones del sistema";
                                                                    break;
                                                                default:
                                                                    descripcion = "Permiso del sistema";
                                                            }
                                                        %>
                                                        <%= descripcion %>
                                                    </span>
                                                </div>
                                            </label>
                                        </div>
                                    <% } %>
                                <% } else { %>
                                    <p class="no-data">No hay permisos disponibles para asignar.</p>
                                <% } %>
                            </div>
                        </div>

                        <!-- Acciones rápidas -->
                        <div class="quick-actions">
                            <h4>⚡ Acciones Rápidas</h4>
                            <div class="action-buttons">
                                <button type="button" class="btn btn-secondary" onclick="seleccionarTodos()">
                                    ✅ Seleccionar Todos
                                </button>
                                <button type="button" class="btn btn-secondary" onclick="deseleccionarTodos()">
                                    ❌ Deseleccionar Todos
                                </button>
                                <button type="button" class="btn btn-info" onclick="seleccionarBasicos()">
                                    🔰 Permisos Básicos
                                </button>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">💾 Guardar Permisos</button>
                            <a href="${pageContext.request.contextPath}/admin/roles/ver?id=<%= rol.getIDRol() %>" 
                               class="btn btn-secondary">↩️ Cancelar</a>
                        </div>
                    </form>
                </div>

                <!-- Información sobre permisos -->
                <div class="info-grid">
                    <div class="info-card">
                        <h3>💡 Tipos de Permisos</h3>
                        <div class="permission-types">
                            <div class="permission-type">
                                <strong>Administrativos:</strong>
                                <span>Control total del sistema</span>
                            </div>
                            <div class="permission-type">
                                <strong>Gestión:</strong>
                                <span>Operaciones CRUD en módulos</span>
                            </div>
                            <div class="permission-type">
                                <strong>Consulta:</strong>
                                <span>Visualización de información</span>
                            </div>
                            <div class="permission-type">
                                <strong>Reportes:</strong>
                                <span>Generación y visualización</span>
                            </div>
                        </div>
                    </div>

                    <div class="info-card">
                        <h3>⚠️ Consideraciones de Seguridad</h3>
                        <ul>
                            <li>Asigne solo los permisos necesarios para cada rol</li>
                            <li>Revise periódicamente los permisos asignados</li>
                            <li>El permiso "admin" otorga acceso completo</li>
                            <li>Los cambios afectan a todos los usuarios con este rol</li>
                        </ul>
                    </div>
                </div>

            <% } else { %>
                <div class="error-message">
                    <p>❌ No se encontró el rol solicitado.</p>
                    <a href="${pageContext.request.contextPath}/admin/roles" class="btn btn-secondary">Volver al Listado</a>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        function seleccionarTodos() {
            document.querySelectorAll('input[name="permisos"]').forEach(checkbox => {
                checkbox.checked = true;
            });
        }

        function deseleccionarTodos() {
            document.querySelectorAll('input[name="permisos"]').forEach(checkbox => {
                checkbox.checked = false;
            });
        }

        function seleccionarBasicos() {
            const permisosBasicos = ['gestion_clientes', 'gestion_vehiculos', 'ver_reportes'];
            document.querySelectorAll('input[name="permisos"]').forEach(checkbox => {
                checkbox.checked = permisosBasicos.includes(checkbox.value);
            });
        }
    </script>

    <%@include file="/WEB-INF/pages/shared/footer.jsp" %>
</body>
</html>