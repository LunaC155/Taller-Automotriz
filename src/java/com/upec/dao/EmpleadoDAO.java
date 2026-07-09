package com.upec.dao;

import com.upec.model.Empleado;
import com.upec.model.Usuarios;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Stateless
public class EmpleadoDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Completo (Admin)
    public List<Empleado> listarEmpleados() {
        try {
            return em.createQuery("SELECT e FROM Empleado e LEFT JOIN FETCH e.iDUsuario", Empleado.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando empleados", e);
        }
    }

    public Empleado obtenerEmpleadoPorId(int id) {
        try {
            List<Empleado> empleados = em.createQuery(
                "SELECT e FROM Empleado e LEFT JOIN FETCH e.iDUsuario WHERE e.iDEmpleado = :id", 
                Empleado.class)
                .setParameter("id", id)
                .getResultList();
            return empleados.isEmpty() ? null : empleados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo empleado por ID", e);
        }
    }

    @Transactional
    public boolean crearEmpleado(Empleado empleado) {
        try {
            em.persist(empleado);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando empleado", e);
        }
    }

    @Transactional
    public boolean actualizarEmpleado(Empleado empleado) {
        try {
            em.merge(empleado);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando empleado", e);
        }
    }

    @Transactional
    public boolean eliminarEmpleado(int id) {
        try {
            Empleado empleado = em.find(Empleado.class, id);
            if (empleado != null) {
                // Verificar si hay órdenes de servicio o diagnósticos asociados
                Long countOrdenes = em.createQuery(
                    "SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDEmpleadoRecepcion.iDEmpleado = :id", 
                    Long.class)
                    .setParameter("id", id)
                    .getSingleResult();
                
                Long countDiagnosticos = em.createQuery(
                    "SELECT COUNT(d) FROM Diagnostico d WHERE d.iDEmpleadoMecanico.iDEmpleado = :id", 
                    Long.class)
                    .setParameter("id", id)
                    .getSingleResult();

                if (countOrdenes > 0 || countDiagnosticos > 0) {
                    return false;
                }
                
                em.remove(empleado);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando empleado", e);
        }
    }

    // Para Recepcionista
    public List<Empleado> listarEmpleadosActivos() {
        try {
            return em.createQuery("SELECT e FROM Empleado e WHERE e.estado = true", Empleado.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando empleados activos", e);
        }
    }

    public List<Empleado> listarMecanicosDisponibles() {
        try {
            // Mecánicos disponibles son aquellos que están activos y tienen rol de mecánico
            // Asumiendo que el rol de mecánico tiene ID 2 (ajustar según tu base de datos)
            return em.createQuery(
                "SELECT e FROM Empleado e JOIN e.iDUsuario u JOIN u.iDRol r " +
                "WHERE e.estado = true AND r.iDRol = 2", 
                Empleado.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando mecánicos disponibles", e);
        }
    }

    // Para Diagnósticos
    public Empleado obtenerMecanicoPorUsuario(int idUsuario) {
        try {
            List<Empleado> empleados = em.createQuery(
                "SELECT e FROM Empleado e WHERE e.iDUsuario.iDUsuario = :idUsuario", 
                Empleado.class)
                .setParameter("idUsuario", idUsuario)
                .getResultList();
            return empleados.isEmpty() ? null : empleados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo mecánico por usuario", e);
        }
    }

    // Búsquedas
    public List<Empleado> buscarEmpleadosPorNombre(String nombre) {
        try {
            return em.createQuery("SELECT e FROM Empleado e WHERE e.nombre LIKE :nombre OR e.apellido LIKE :nombre", Empleado.class)
                     .setParameter("nombre", "%" + nombre + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleados por nombre", e);
        }
    }

    public List<Empleado> filtrarEmpleadosPorCargo(String cargo) {
        try {
            // Asumiendo que el cargo está relacionado con el rol del usuario
            return em.createQuery(
                "SELECT e FROM Empleado e JOIN e.iDUsuario u JOIN u.iDRol r " +
                "WHERE r.nombreRol LIKE :cargo", 
                Empleado.class)
                .setParameter("cargo", "%" + cargo + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando empleados por cargo", e);
        }
    }

    // Reportes Admin
    public int contarTotalEmpleados() {
        try {
            Long count = em.createQuery("SELECT COUNT(e) FROM Empleado e", Long.class)
                     .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando total de empleados", e);
        }
    }

    public int contarEmpleadosActivos() {
        try {
            Long count = em.createQuery("SELECT COUNT(e) FROM Empleado e WHERE e.estado = true", Long.class)
                     .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando empleados activos", e);
        }
    }

    public List<Object[]> obtenerEstadisticasEmpleados() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(e) as totalEmpleados, " +
                "SUM(CASE WHEN e.estado = true THEN 1 ELSE 0 END) as empleadosActivos, " +
                "SUM(CASE WHEN e.estado = false THEN 1 ELSE 0 END) as empleadosInactivos, " +
                "AVG(e.salario) as salarioPromedio, " +
                "MIN(e.fechaContratacion) as fechaContratacionMasAntigua " +
                "FROM Empleado e", Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de empleados", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Empleado empleado) {
        try {
            em.persist(empleado);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear empleado", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Empleado empleado) {
        try {
            if (empleado.getIDEmpleado() == null) {
                em.persist(empleado);
            } else {
                em.merge(empleado);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando empleado", e);
        }
    }

    public Empleado findById(Integer id) {
        return obtenerEmpleadoPorId(id);
    }

    public List<Empleado> findAll() {
        return listarEmpleados();
    }

    public List<Empleado> findByEstado(Boolean estado) {
        try {
            return em.createQuery("SELECT e FROM Empleado e WHERE e.estado = :estado", Empleado.class)
                     .setParameter("estado", estado)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleados por estado", e);
        }
    }

    public List<Empleado> findByNombreContaining(String texto) {
        return buscarEmpleadosPorNombre(texto);
    }

    public List<Empleado> findByEmail(String email) {
        try {
            return em.createQuery("SELECT e FROM Empleado e WHERE e.email = :email", Empleado.class)
                     .setParameter("email", email)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleados por email", e);
        }
    }

    public boolean emailExists(String email) {
        try {
            Long count = em.createQuery("SELECT COUNT(e) FROM Empleado e WHERE e.email = :email", Long.class)
                           .setParameter("email", email)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de email", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Empleado empleado = em.find(Empleado.class, id);
            if (empleado != null) {
                em.remove(empleado);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando empleado", e);
        }
    }

    @Transactional
    public void updateEstado(Integer id, Boolean estado) {
        try {
            Empleado empleado = em.find(Empleado.class, id);
            if (empleado != null) {
                empleado.setEstado(estado);
                em.merge(empleado);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado del empleado", e);
        }
    }

    @Transactional
    public void updateSalario(Integer id, BigDecimal nuevoSalario) {
        try {
            Empleado empleado = em.find(Empleado.class, id);
            if (empleado != null) {
                empleado.setSalario(nuevoSalario);
                em.merge(empleado);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando salario del empleado", e);
        }
    }

    public List<Empleado> findEmpleadosActivos() {
        return listarEmpleadosActivos();
    }

    public Long countEmpleadosActivos() {
        return (long) contarEmpleadosActivos();
    }

    public BigDecimal getSalarioPromedio() {
        try {
            BigDecimal result = em.createQuery("SELECT AVG(e.salario) FROM Empleado e WHERE e.estado = true", BigDecimal.class)
                     .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo salario promedio", e);
        }
    }

    public List<Empleado> findEmpleadosSinUsuario() {
        try {
            return em.createQuery("SELECT e FROM Empleado e WHERE e.iDUsuario IS NULL", Empleado.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleados sin usuario", e);
        }
    }

    public Empleado findByUsuario(Usuarios usuario) {
        try {
            List<Empleado> empleados = em.createQuery(
                "SELECT e FROM Empleado e WHERE e.iDUsuario = :usuario", 
                Empleado.class)
                .setParameter("usuario", usuario)
                .getResultList();
            return empleados.isEmpty() ? null : empleados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleado por usuario", e);
        }
    }

    public List<Object[]> getEmpleadosConUsuario() {
        try {
            return em.createQuery(
                "SELECT e, u FROM Empleado e JOIN e.iDUsuario u WHERE e.estado = true", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo empleados con usuario", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Empleado> listarEmpleadosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e " +
                "LEFT JOIN FETCH e.iDUsuario u " +
                "LEFT JOIN FETCH u.iDRol r " +
                "ORDER BY e.nombre, e.apellido", 
                Empleado.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando empleados con detalles completos", e);
        }
    }

    public List<Empleado> listarMecanicosConEspecialidad() {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e " +
                "JOIN e.iDUsuario u " +
                "JOIN u.iDRol r " +
                "WHERE r.iDRol = 2 AND e.estado = true " +
                "ORDER BY e.nombre, e.apellido", 
                Empleado.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando mecánicos con especialidad", e);
        }
    }

    public boolean verificarEmpleadoConUsuario(int idUsuario) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(e) FROM Empleado e WHERE e.iDUsuario.iDUsuario = :idUsuario", 
                Long.class)
                .setParameter("idUsuario", idUsuario)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando empleado con usuario", e);
        }
    }

    public List<Object[]> obtenerEmpleadosPorRol() {
        try {
            return em.createQuery(
                "SELECT r.nombreRol, COUNT(e) FROM Empleado e " +
                "JOIN e.iDUsuario u " +
                "JOIN u.iDRol r " +
                "WHERE e.estado = true " +
                "GROUP BY r.nombreRol " +
                "ORDER BY COUNT(e) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo empleados por rol", e);
        }
    }

    public List<Empleado> buscarEmpleadosPorRol(int idRol) {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e " +
                "JOIN e.iDUsuario u " +
                "WHERE u.iDRol.iDRol = :idRol AND e.estado = true", 
                Empleado.class)
                .setParameter("idRol", idRol)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleados por rol", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales para gestión de empleados
    
    public List<Empleado> buscarEmpleadosPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e " +
                "LEFT JOIN e.iDUsuario u " +
                "LEFT JOIN u.iDRol r " +
                "WHERE e.nombre LIKE :criterio " +
                "OR e.apellido LIKE :criterio " +
                "OR e.email LIKE :criterio " +
                "OR e.telefono LIKE :criterio " +
                "OR r.nombreRol LIKE :criterio", 
                Empleado.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando empleados por criterio", e);
        }
    }

    public List<Empleado> listarEmpleadosPorFechaContratacion(Date fechaInicio, Date fechaFin) {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e " +
                "WHERE e.fechaContratacion BETWEEN :fechaInicio AND :fechaFin " +
                "ORDER BY e.fechaContratacion ASC", 
                Empleado.class)
                .setParameter("fechaInicio", fechaInicio)
                .setParameter("fechaFin", fechaFin)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando empleados por fecha de contratación", e);
        }
    }

    public BigDecimal obtenerSalarioTotal() {
        try {
            BigDecimal result = em.createQuery(
                "SELECT SUM(e.salario) FROM Empleado e WHERE e.estado = true", 
                BigDecimal.class)
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo salario total", e);
        }
    }

    public List<Object[]> obtenerTopEmpleadosPorSalario(int limite) {
        try {
            return em.createQuery(
                "SELECT e.nombre, e.apellido, e.salario, r.nombreRol " +
                "FROM Empleado e " +
                "JOIN e.iDUsuario u " +
                "JOIN u.iDRol r " +
                "WHERE e.estado = true " +
                "ORDER BY e.salario DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo top empleados por salario", e);
        }
    }
}