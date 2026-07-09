package com.upec.dao;

import com.upec.model.Roles;
import com.upec.model.Usuarios;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;

@Stateless
public class RolesDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Completo (Admin)
    public List<Roles> listarRoles() {
        try {
            return em.createQuery("SELECT r FROM Roles r", Roles.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando roles", e);
        }
    }

    public Roles obtenerRolPorId(int id) {
        try {
            return em.find(Roles.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo rol por ID", e);
        }
    }

    @Transactional
    public boolean crearRol(Roles rol) {
        try {
            em.persist(rol);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando rol", e);
        }
    }

    @Transactional
    public boolean actualizarRol(Roles rol) {
        try {
            em.merge(rol);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando rol", e);
        }
    }

    @Transactional
    public boolean eliminarRol(int id) {
        try {
            Roles rol = em.find(Roles.class, id);
            if (rol != null) {
                // Verificar si el rol está en uso
                if (verificarRolEnUso(id)) {
                    return false;
                }
                em.remove(rol);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando rol", e);
        }
    }

    // Para Login
    public Roles obtenerRolPorUsuario(int idUsuario) {
        try {
            List<Roles> roles = em.createQuery(
                "SELECT u.iDRol FROM Usuarios u WHERE u.iDUsuario = :idUsuario", 
                Roles.class)
                .setParameter("idUsuario", idUsuario)
                .getResultList();
            return roles.isEmpty() ? null : roles.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo rol por usuario", e);
        }
    }

    // Permisos
    public List<String> obtenerPermisosPorRol(int idRol) {
        try {
            // Nota: Esta implementación asume que tienes una tabla de permisos
            // Si no tienes una estructura de permisos, puedes retornar permisos basados en el nombre del rol
            Roles rol = em.find(Roles.class, idRol);
            if (rol != null) {
                // Ejemplo básico - ajustar según tu estructura de permisos real
                return switch (rol.getNombreRol().toLowerCase()) {
                    case "administrador" -> List.of("admin", "gestion_usuarios", "gestion_roles", "reportes");
                    case "mecánico" -> List.of("diagnosticos", "reparaciones", "ver_ordenes");
                    case "recepcionista" -> List.of("gestion_clientes", "gestion_vehiculos", "crear_ordenes");
                    case "cliente" -> List.of("ver_ordenes", "ver_vehiculos");
                    default -> List.of("usuario_basico");
                };
            }
            return List.of();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo permisos por rol", e);
        }
    }

    @Transactional
    public boolean asignarPermisosRol(int idRol, List<String> permisos) {
        try {
            // Nota: Esta implementación es básica y asume que guardas permisos en la descripción
            // En una implementación real, necesitarías una tabla de permisos separada
            Roles rol = em.find(Roles.class, idRol);
            if (rol != null) {
                // Guardar permisos como string separado por comas en la descripción
                String permisosStr = String.join(",", permisos);
                rol.setDescripcion("Permisos: " + permisosStr);
                em.merge(rol);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error asignando permisos al rol", e);
        }
    }

    // Validaciones
    public boolean verificarRolEnUso(int idRol) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(u) FROM Usuarios u WHERE u.iDRol.iDRol = :idRol", 
                Long.class)
                .setParameter("idRol", idRol)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si el rol está en uso", e);
        }
    }

    public List<Usuarios> obtenerUsuariosPorRol(int idRol) {
        try {
            return em.createQuery(
                "SELECT u FROM Usuarios u WHERE u.iDRol.iDRol = :idRol", 
                Usuarios.class)
                .setParameter("idRol", idRol)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo usuarios por rol", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Roles rol) {
        try {
            em.persist(rol);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear rol", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Roles rol) {
        try {
            if (rol.getIDRol() == null) {
                em.persist(rol);
            } else {
                em.merge(rol);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando rol", e);
        }
    }

    public Roles findById(Integer id) {
        return obtenerRolPorId(id);
    }

    public List<Roles> findAll() {
        return listarRoles();
    }

    public List<Roles> findByEstado(Boolean estado) {
        try {
            return em.createQuery("SELECT r FROM Roles r WHERE r.estado = :estado", Roles.class)
                     .setParameter("estado", estado)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando roles por estado", e);
        }
    }

    public Roles findByNombreRol(String nombreRol) {
        try {
            List<Roles> roles = em.createQuery(
                "SELECT r FROM Roles r WHERE r.nombreRol = :nombreRol", 
                Roles.class)
                .setParameter("nombreRol", nombreRol)
                .getResultList();
            return roles.isEmpty() ? null : roles.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando rol por nombre", e);
        }
    }

    public boolean nombreRolExists(String nombreRol) {
        try {
            Long count = em.createQuery("SELECT COUNT(r) FROM Roles r WHERE r.nombreRol = :nombreRol", Long.class)
                           .setParameter("nombreRol", nombreRol)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de nombre de rol", e);
        }
    }

    public boolean nombreRolExistsExcludingId(String nombreRol, Integer idExcluir) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(r) FROM Roles r WHERE r.nombreRol = :nombreRol AND r.iDRol != :idExcluir", 
                Long.class)
                .setParameter("nombreRol", nombreRol)
                .setParameter("idExcluir", idExcluir)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de nombre de rol excluyendo ID", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Roles rol = em.find(Roles.class, id);
            if (rol != null) {
                em.remove(rol);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando rol", e);
        }
    }

    @Transactional
    public void updateEstado(Integer id, Boolean estado) {
        try {
            Roles rol = em.find(Roles.class, id);
            if (rol != null) {
                rol.setEstado(estado);
                em.merge(rol);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado del rol", e);
        }
    }

    public List<Roles> findRolesActivos() {
        try {
            return em.createQuery("SELECT r FROM Roles r WHERE r.estado = true", Roles.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando roles activos", e);
        }
    }

    public Long countRolesActivos() {
        try {
            return em.createQuery("SELECT COUNT(r) FROM Roles r WHERE r.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando roles activos", e);
        }
    }

    public List<Roles> findByDescripcionContaining(String texto) {
        try {
            return em.createQuery("SELECT r FROM Roles r WHERE r.descripcion LIKE :texto", Roles.class)
                     .setParameter("texto", "%" + texto + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando roles por descripción", e);
        }
    }

    public List<Object[]> countUsuariosPorRol() {
        try {
            return em.createQuery(
                "SELECT r.nombreRol, COUNT(u) FROM Roles r LEFT JOIN r.usuariosList u WHERE r.estado = true GROUP BY r.nombreRol", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando usuarios por rol", e);
        }
    }

    public boolean tieneUsuariosAsociados(Integer idRol) {
        return verificarRolEnUso(idRol);
    }

    public Long countUsuariosByRol(Integer idRol) {
        try {
            return em.createQuery(
                "SELECT COUNT(u) FROM Usuarios u WHERE u.iDRol.iDRol = :idRol", 
                Long.class)
                .setParameter("idRol", idRol)
                .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando usuarios por rol", e);
        }
    }

    public List<Roles> findByNombreContaining(String nombre) {
        try {
            return em.createQuery("SELECT r FROM Roles r WHERE r.nombreRol LIKE :nombre", Roles.class)
                     .setParameter("nombre", "%" + nombre + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando roles por nombre", e);
        }
    }

    public Long countTotalRoles() {
        try {
            return em.createQuery("SELECT COUNT(r) FROM Roles r", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando total de roles", e);
        }
    }

    public Roles findByIdWithUsuarios(Integer id) {
        try {
            List<Roles> roles = em.createQuery(
                "SELECT r FROM Roles r LEFT JOIN FETCH r.usuariosList WHERE r.iDRol = :id", 
                Roles.class)
                .setParameter("id", id)
                .getResultList();
            return roles.isEmpty() ? null : roles.get(0);
        } catch (Exception e) {
            return null;
        }
    }

    public List<Roles> findRolesConUsuarios() {
        try {
            return em.createQuery(
                "SELECT DISTINCT r FROM Roles r LEFT JOIN FETCH r.usuariosList WHERE r.estado = true", 
                Roles.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando roles con usuarios", e);
        }
    }

    public List<Object[]> getEstadisticasRoles() {
        try {
            return em.createQuery(
                "SELECT r.nombreRol, r.estado, COUNT(u) " +
                "FROM Roles r LEFT JOIN r.usuariosList u " +
                "GROUP BY r.nombreRol, r.estado " +
                "ORDER BY COUNT(u) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de roles", e);
        }
    }

    public boolean puedeEliminarRol(Integer idRol) {
        try {
            // Verificar si el rol tiene usuarios asociados
            if (verificarRolEnUso(idRol)) {
                return false;
            }
            
            // Verificar si es un rol del sistema (no se pueden eliminar)
            Roles rol = em.find(Roles.class, idRol);
            if (rol != null) {
                String nombreRol = rol.getNombreRol().toLowerCase();
                return !nombreRol.equals("administrador") && 
                       !nombreRol.equals("cliente") &&
                       !nombreRol.equals("mecánico") &&
                       !nombreRol.equals("recepcionista");
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar rol", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Roles> listarRolesConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT r FROM Roles r " +
                "LEFT JOIN FETCH r.usuariosList u " +
                "ORDER BY r.nombreRol", 
                Roles.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando roles con detalles completos", e);
        }
    }

    public Roles obtenerRolConUsuarios(int idRol) {
        try {
            List<Roles> roles = em.createQuery(
                "SELECT r FROM Roles r " +
                "LEFT JOIN FETCH r.usuariosList u " +
                "LEFT JOIN FETCH u.empleadoList " +
                "WHERE r.iDRol = :id", 
                Roles.class)
                .setParameter("id", idRol)
                .getResultList();
            return roles.isEmpty() ? null : roles.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo rol con usuarios", e);
        }
    }

    public List<Roles> buscarRolesPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT r FROM Roles r " +
                "WHERE r.nombreRol LIKE :criterio " +
                "OR r.descripcion LIKE :criterio " +
                "ORDER BY r.nombreRol", 
                Roles.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando roles por criterio", e);
        }
    }

    @Transactional
    public boolean activarRol(int idRol) {
        try {
            Roles rol = em.find(Roles.class, idRol);
            if (rol != null) {
                rol.setEstado(true);
                em.merge(rol);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error activando rol", e);
        }
    }

    @Transactional
    public boolean desactivarRol(int idRol) {
        try {
            Roles rol = em.find(Roles.class, idRol);
            if (rol != null) {
                rol.setEstado(false);
                em.merge(rol);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error desactivando rol", e);
        }
    }

    public List<Object[]> obtenerEstadisticasDetalladasRoles() {
        try {
            return em.createQuery(
                "SELECT r.nombreRol, " +
                "COUNT(u) as totalUsuarios, " +
                "SUM(CASE WHEN u.estado = true THEN 1 ELSE 0 END) as usuariosActivos, " +
                "SUM(CASE WHEN u.estado = false THEN 1 ELSE 0 END) as usuariosInactivos, " +
                "CASE WHEN r.estado = true THEN 'Activo' ELSE 'Inactivo' END as estadoRol " +
                "FROM Roles r " +
                "LEFT JOIN r.usuariosList u " +
                "GROUP BY r.nombreRol, r.estado " +
                "ORDER BY totalUsuarios DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas detalladas de roles", e);
        }
    }

    public boolean esRolSistema(int idRol) {
        try {
            Roles rol = em.find(Roles.class, idRol);
            if (rol != null) {
                String nombreRol = rol.getNombreRol().toLowerCase();
                return nombreRol.equals("administrador") || 
                       nombreRol.equals("cliente") ||
                       nombreRol.equals("mecánico") ||
                       nombreRol.equals("recepcionista");
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si es rol del sistema", e);
        }
    }

    @Transactional
    public Roles crearRolSiNoExiste(String nombreRol, String descripcion, Boolean estado) {
        try {
            // Verificar si ya existe el rol
            Roles rolExistente = findByNombreRol(nombreRol);
            if (rolExistente != null) {
                return rolExistente;
            }

            // Crear nuevo rol
            Roles nuevoRol = new Roles();
            nuevoRol.setNombreRol(nombreRol);
            nuevoRol.setDescripcion(descripcion);
            nuevoRol.setEstado(estado);
            
            em.persist(nuevoRol);
            return nuevoRol;
        } catch (Exception e) {
            throw new RuntimeException("Error creando rol si no existe", e);
        }
    }

    public List<Roles> obtenerRolesParaAsignacion() {
        try {
            return em.createQuery(
                "SELECT r FROM Roles r " +
                "WHERE r.estado = true " +
                "AND r.nombreRol NOT IN ('Administrador', 'Cliente') " +
                "ORDER BY r.nombreRol", 
                Roles.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo roles para asignación", e);
        }
    }
}