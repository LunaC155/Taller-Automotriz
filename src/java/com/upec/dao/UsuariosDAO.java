package com.upec.dao;

import com.upec.model.Usuarios;
import com.upec.model.Roles;
import com.upec.model.Empleado;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@Stateless
public class UsuariosDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // ===== MÉTODOS DE AUTENTICACIÓN =====
    public Usuarios validarCredenciales(String usuario, String contrasena) {
        try {
            List<Usuarios> usuarios = em.createQuery(
                "SELECT u FROM Usuarios u JOIN FETCH u.iDRol WHERE u.usuario = :usuario AND u.contrasena = :contrasena AND u.estado = true", 
                Usuarios.class)
                .setParameter("usuario", usuario)
                .setParameter("contrasena", contrasena)
                .getResultList();

            return usuarios.isEmpty() ? null : usuarios.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error validando credenciales", e);
        }
    }

    public Usuarios obtenerUsuarioPorId(int id) {
        try {
            List<Usuarios> usuarios = em.createQuery(
                "SELECT u FROM Usuarios u JOIN FETCH u.iDRol WHERE u.iDUsuario = :id", 
                Usuarios.class)
                .setParameter("id", id)
                .getResultList();
            return usuarios.isEmpty() ? null : usuarios.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo usuario por ID", e);
        }
    }

    // ===== MÉTODOS DE GESTIÓN DE USUARIOS =====
    public List<Usuarios> listarUsuarios() {
        try {
            return em.createQuery("SELECT u FROM Usuarios u JOIN FETCH u.iDRol", Usuarios.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando usuarios", e);
        }
    }

    public boolean crearUsuario(Usuarios usuario) {
        try {
            em.persist(usuario);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando usuario", e);
        }
    }

    public boolean actualizarUsuario(Usuarios usuario) {
        try {
            em.merge(usuario);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando usuario", e);
        }
    }

    public boolean eliminarUsuario(int id) {
        try {
            Usuarios usuario = em.find(Usuarios.class, id);
            if (usuario != null) {
                // Verificar si hay empleados asociados
                Long count = em.createQuery(
                    "SELECT COUNT(e) FROM Empleado e WHERE e.iDUsuario.iDUsuario = :idUsuario", 
                    Long.class)
                    .setParameter("idUsuario", id)
                    .getSingleResult();
                
                if (count > 0) {
                    return false;
                }
                em.remove(usuario);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando usuario", e);
        }
    }

    public boolean cambiarEstadoUsuario(int id, boolean estado) {
        try {
            Usuarios usuario = em.find(Usuarios.class, id);
            if (usuario != null) {
                usuario.setEstado(estado);
                em.merge(usuario);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error cambiando estado del usuario", e);
        }
    }

    // ===== MÉTODOS PARA ROLES =====
    public List<Usuarios> listarUsuariosPorRol(int idRol) {
        try {
            return em.createQuery("SELECT u FROM Usuarios u JOIN FETCH u.iDRol WHERE u.iDRol.iDRol = :idRol", Usuarios.class)
                     .setParameter("idRol", idRol)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando usuarios por rol", e);
        }
    }

    public boolean asignarRolUsuario(int idUsuario, int idRol) {
        try {
            Usuarios usuario = em.find(Usuarios.class, idUsuario);
            Roles rol = em.find(Roles.class, idRol);
            
            if (usuario != null && rol != null) {
                usuario.setIDRol(rol);
                em.merge(usuario);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error asignando rol al usuario", e);
        }
    }

    // ===== MÉTODOS PARA EMPLEADOS =====
    public Usuarios obtenerUsuarioPorEmpleado(int idEmpleado) {
        try {
            List<Usuarios> usuarios = em.createQuery(
                "SELECT u FROM Usuarios u JOIN FETCH u.iDRol JOIN u.empleadoList e WHERE e.iDEmpleado = :idEmpleado", 
                Usuarios.class)
                .setParameter("idEmpleado", idEmpleado)
                .getResultList();
            return usuarios.isEmpty() ? null : usuarios.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo usuario por empleado", e);
        }
    }

    // ===== MÉTODOS DE SEGURIDAD =====
    public boolean actualizarContrasena(int idUsuario, String nuevaContrasena) {
        try {
            Usuarios usuario = em.find(Usuarios.class, idUsuario);
            if (usuario != null) {
                usuario.setContrasena(nuevaContrasena);
                em.merge(usuario);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando contraseña", e);
        }
    }

    public boolean verificarUsuarioExistente(String usuario) {
        try {
            Long count = em.createQuery("SELECT COUNT(u) FROM Usuarios u WHERE u.usuario = :usuario", Long.class)
                           .setParameter("usuario", usuario)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando usuario existente", e);
        }
    }

    // ===== MÉTODOS ADICIONALES (COMPATIBILIDAD) =====
    public Usuarios findByUsuarioAndPassword(String usuario, String contrasena) {
        return validarCredenciales(usuario, contrasena);
    }

    public Usuarios findByUsuario(String usuario) {
        try {
            List<Usuarios> usuarios = em.createQuery(
                "SELECT u FROM Usuarios u WHERE u.usuario = :usuario", 
                Usuarios.class)
                .setParameter("usuario", usuario)
                .getResultList();
            return usuarios.isEmpty() ? null : usuarios.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando usuario por nombre", e);
        }
    }

    public Usuarios findByUsuarioWithRole(String usuario) {
        try {
            List<Usuarios> usuarios = em.createQuery(
                "SELECT u FROM Usuarios u JOIN FETCH u.iDRol WHERE u.usuario = :usuario", 
                Usuarios.class)
                .setParameter("usuario", usuario)
                .getResultList();
            return usuarios.isEmpty() ? null : usuarios.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando usuario con rol", e);
        }
    }

    public boolean emailExists(String email) {
        try {
            Long count = em.createQuery("SELECT COUNT(u) FROM Usuarios u WHERE u.email = :email", Long.class)
                           .setParameter("email", email)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de email", e);
        }
    }

    public List<Usuarios> findByEstado(Boolean estado) {
        try {
            return em.createQuery("SELECT u FROM Usuarios u JOIN FETCH u.iDRol WHERE u.estado = :estado", Usuarios.class)
                     .setParameter("estado", estado)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando usuarios por estado", e);
        }
    }

    public Long countUsuariosActivos() {
        try {
            return em.createQuery("SELECT COUNT(u) FROM Usuarios u WHERE u.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando usuarios activos", e);
        }
    }

    public Long countUsuariosPorRol(Integer idRol) {
        try {
            return em.createQuery("SELECT COUNT(u) FROM Usuarios u WHERE u.iDRol.iDRol = :idRol AND u.estado = true", Long.class)
                     .setParameter("idRol", idRol)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando usuarios por rol", e);
        }
    }

    public Roles findRolById(Integer id) {
        try {
            return em.find(Roles.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo rol por ID", e);
        }
    }

    // ===== MÉTODOS DE TRANSACCIÓN =====
    public void create(Usuarios usuario) {
        try {
            em.persist(usuario);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear usuario", e);
        }
    }

    public void saveOrUpdate(Usuarios usuario) {
        try {
            if (usuario.getIDUsuario() == null) {
                em.persist(usuario);
            } else {
                em.merge(usuario);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando usuario", e);
        }
    }

    public void delete(Integer id) {
        try {
            Usuarios usuario = em.find(Usuarios.class, id);
            if (usuario != null) {
                em.remove(usuario);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando usuario", e);
        }
    }

    public void updateEstado(Integer id, Boolean estado) {
        try {
            Usuarios usuario = em.find(Usuarios.class, id);
            if (usuario != null) {
                usuario.setEstado(estado);
                em.merge(usuario);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado del usuario", e);
        }
    }

    // ===== MÉTODOS ADICIONALES MEJORADOS =====
    public List<Usuarios> listarUsuariosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT u FROM Usuarios u " +
                "LEFT JOIN FETCH u.iDRol " +
                "LEFT JOIN FETCH u.empleadoList " +
                "ORDER BY u.usuario", 
                Usuarios.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando usuarios con detalles completos", e);
        }
    }

    public List<Usuarios> buscarUsuariosPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT u FROM Usuarios u " +
                "JOIN FETCH u.iDRol " +
                "WHERE u.usuario LIKE :criterio " +
                "OR u.email LIKE :criterio " +
                "OR u.iDRol.nombreRol LIKE :criterio " +
                "ORDER BY u.usuario", 
                Usuarios.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando usuarios por criterio", e);
        }
    }

    public List<Object[]> obtenerEstadisticasUsuarios() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(u) as totalUsuarios, " +
                "SUM(CASE WHEN u.estado = true THEN 1 ELSE 0 END) as usuariosActivos, " +
                "SUM(CASE WHEN u.estado = false THEN 1 ELSE 0 END) as usuariosInactivos, " +
                "COUNT(DISTINCT u.iDRol) as rolesUtilizados, " +
                "(SELECT COUNT(*) FROM Usuarios u2 WHERE u2.empleadoList IS EMPTY) as usuariosSinEmpleado " +
                "FROM Usuarios u", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de usuarios", e);
        }
    }

    public List<Object[]> obtenerUsuariosPorRol() {
        try {
            return em.createQuery(
                "SELECT r.nombreRol, COUNT(u) " +
                "FROM Usuarios u " +
                "JOIN u.iDRol r " +
                "WHERE u.estado = true " +
                "GROUP BY r.nombreRol " +
                "ORDER BY COUNT(u) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo usuarios por rol", e);
        }
    }

    public boolean puedeEliminarUsuario(int idUsuario) {
        try {
            // Verificar si tiene empleados asociados
            Long countEmpleados = em.createQuery(
                "SELECT COUNT(e) FROM Empleado e WHERE e.iDUsuario.iDUsuario = :idUsuario", 
                Long.class)
                .setParameter("idUsuario", idUsuario)
                .getSingleResult();
            
            // Verificar si es el último administrador
            Usuarios usuario = em.find(Usuarios.class, idUsuario);
            boolean esAdministrador = usuario != null && 
                                    usuario.getIDRol() != null && 
                                    "ADMIN".equalsIgnoreCase(usuario.getIDRol().getNombreRol());
            
            if (esAdministrador) {
                Long countAdmins = em.createQuery(
                    "SELECT COUNT(u) FROM Usuarios u WHERE u.iDRol.nombreRol = 'ADMIN' AND u.estado = true", 
                    Long.class)
                    .getSingleResult();
                if (countAdmins <= 1) {
                    return false;
                }
            }
            
            return countEmpleados == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar usuario", e);
        }
    }

    public boolean resetearContrasena(int idUsuario, String nuevaContrasena) {
        try {
            Usuarios usuario = em.find(Usuarios.class, idUsuario);
            if (usuario != null) {
                usuario.setContrasena(nuevaContrasena);
                em.merge(usuario);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error reseteando contraseña", e);
        }
    }

    public List<Usuarios> obtenerUsuariosSinEmpleado() {
        try {
            return em.createQuery(
                "SELECT u FROM Usuarios u " +
                "WHERE u.empleadoList IS EMPTY " +
                "AND u.estado = true " +
                "ORDER BY u.usuario", 
                Usuarios.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo usuarios sin empleado", e);
        }
    }

    public boolean desactivarUsuariosInactivos() {
        try {
            int updated = em.createQuery(
                "UPDATE Usuarios u SET u.estado = false " +
                "WHERE u.estado = true " +
                "AND u.empleadoList IS EMPTY " +
                "AND u.fechaCreacion < CURRENT_DATE - 30")
                .executeUpdate();
            return updated > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error desactivando usuarios inactivos", e);
        }
    }
}