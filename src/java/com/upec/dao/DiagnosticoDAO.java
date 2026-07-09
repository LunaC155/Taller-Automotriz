package com.upec.dao;

import com.upec.model.Diagnostico;
import com.upec.model.OrdenServicio;
import com.upec.model.Empleado;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Stateless
public class DiagnosticoDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico (Mecánico)
    public List<Diagnostico> listarDiagnosticos() {
        try {
            return em.createQuery("SELECT d FROM Diagnostico d", Diagnostico.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos", e);
        }
    }

    public Diagnostico obtenerDiagnosticoPorId(int id) {
        try {
            return em.find(Diagnostico.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo diagnóstico por ID", e);
        }
    }

    @Transactional
    public boolean crearDiagnostico(Diagnostico diagnostico) {
        try {
            em.persist(diagnostico);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando diagnóstico", e);
        }
    }

    @Transactional
    public boolean actualizarDiagnostico(Diagnostico diagnostico) {
        try {
            em.merge(diagnostico);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando diagnóstico", e);
        }
    }

    // Para Mecánico
    public List<Diagnostico> listarDiagnosticosPorMecanico(int idMecanico) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d WHERE d.iDEmpleadoMecanico.iDEmpleado = :idMecanico", 
                Diagnostico.class)
                .setParameter("idMecanico", idMecanico)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos por mecánico", e);
        }
    }

    public List<Diagnostico> listarDiagnosticosPorOrden(int idOrden) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d WHERE d.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Diagnostico.class)
                .setParameter("idOrden", idOrden)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos por orden", e);
        }
    }

    public Diagnostico obtenerDiagnosticoCompleto(int idDiagnostico) {
        try {
            List<Diagnostico> diagnosticos = em.createQuery(
                "SELECT d FROM Diagnostico d " +
                "LEFT JOIN FETCH d.iDOrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente " +
                "LEFT JOIN FETCH d.iDEmpleadoMecanico " +
                "WHERE d.iDDiagnostico = :id", 
                Diagnostico.class)
                .setParameter("id", idDiagnostico)
                .getResultList();
            return diagnosticos.isEmpty() ? null : diagnosticos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo diagnóstico completo", e);
        }
    }

    // Para Reportes Técnicos
    public List<Diagnostico> listarDiagnosticosPorFecha(Date fecha) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d WHERE FUNCTION('DATE', d.fechaDiagnostico) = FUNCTION('DATE', :fecha)", 
                Diagnostico.class)
                .setParameter("fecha", fecha)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos por fecha", e);
        }
    }

    public List<Object[]> obtenerEstadisticasDiagnosticos() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(d) as totalDiagnosticos, " +
                "COUNT(DISTINCT d.iDEmpleadoMecanico) as mecanicosActivos, " +
                "COUNT(DISTINCT d.iDOrdenServicio) as ordenesConDiagnostico, " +
                "AVG(LENGTH(d.descripcionDiagnostico)) as longitudPromedioDescripcion " +
                "FROM Diagnostico d", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de diagnósticos", e);
        }
    }

    public List<String> obtenerProblemasComunes() {
    try {
        // CORRECCIÓN: Usar COUNT(d) en lugar de COUNT(*)
        return em.createQuery(
            "SELECT DISTINCT SUBSTRING(d.descripcionDiagnostico, 1, 50) " +
            "FROM Diagnostico d " +
            "WHERE LENGTH(d.descripcionDiagnostico) > 10 " +
            "GROUP BY SUBSTRING(d.descripcionDiagnostico, 1, 50) " +
            "HAVING COUNT(d) > 1 " +  // ← Cambiado COUNT(*) por COUNT(d)
            "ORDER BY COUNT(d) DESC", // ← Cambiado COUNT(*) por COUNT(d)
            String.class)
            .setMaxResults(10) // Top 10 problemas más comunes
            .getResultList();
    } catch (Exception e) {
        // En caso de error, retornar lista vacía para no bloquear la aplicación
        System.err.println("Error en obtenerProblemasComunes: " + e.getMessage());
        return new ArrayList<>();
    }
}

    // Para Dashboard Mecánico
    public int contarDiagnosticosPendientes(int idMecanico) {
        try {
            // Consideramos diagnósticos pendientes aquellos sin fecha de diagnóstico
            Long count = em.createQuery(
                "SELECT COUNT(d) FROM Diagnostico d " +
                "WHERE d.iDEmpleadoMecanico.iDEmpleado = :idMecanico " +
                "AND d.fechaDiagnostico IS NULL", 
                Long.class)
                .setParameter("idMecanico", idMecanico)
                .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos pendientes", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Diagnostico diagnostico) {
        try {
            em.persist(diagnostico);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear diagnóstico", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Diagnostico diagnostico) {
        try {
            if (diagnostico.getIDDiagnostico() == null) {
                em.persist(diagnostico);
            } else {
                em.merge(diagnostico);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando diagnóstico", e);
        }
    }

    public Diagnostico findById(Integer id) {
        return obtenerDiagnosticoPorId(id);
    }

    public Diagnostico findByIdWithDetails(Integer id) {
        return obtenerDiagnosticoCompleto(id);
    }

    public List<Diagnostico> findAll() {
        return listarDiagnosticos();
    }

    public List<Diagnostico> findAllWithDetails() {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d " +
                "LEFT JOIN FETCH d.iDOrdenServicio " +
                "LEFT JOIN FETCH d.iDEmpleadoMecanico", 
                Diagnostico.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando todos los diagnósticos con detalles", e);
        }
    }

    public List<Diagnostico> findByOrdenServicio(Integer idOrdenServicio) {
        return listarDiagnosticosPorOrden(idOrdenServicio);
    }

    public List<Diagnostico> findByEmpleadoMecanico(Integer idEmpleado) {
        return listarDiagnosticosPorMecanico(idEmpleado);
    }

    public List<Diagnostico> findByFechaDiagnosticoBetween(Date fechaInicio, Date fechaFin) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d WHERE d.fechaDiagnostico BETWEEN :fechaInicio AND :fechaFin", 
                Diagnostico.class)
                .setParameter("fechaInicio", fechaInicio)
                .setParameter("fechaFin", fechaFin)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando diagnósticos por rango de fechas", e);
        }
    }

    public List<Diagnostico> findByFechaDiagnosticoAfter(Date fecha) {
        try {
            return em.createQuery("SELECT d FROM Diagnostico d WHERE d.fechaDiagnostico > :fecha", Diagnostico.class)
                     .setParameter("fecha", fecha)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando diagnósticos después de fecha", e);
        }
    }

    public List<Diagnostico> findByFechaDiagnosticoBefore(Date fecha) {
        try {
            return em.createQuery("SELECT d FROM Diagnostico d WHERE d.fechaDiagnostico < :fecha", Diagnostico.class)
                     .setParameter("fecha", fecha)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando diagnósticos antes de fecha", e);
        }
    }

    public Diagnostico findLatestByOrdenServicio(Integer idOrdenServicio) {
        try {
            List<Diagnostico> diagnosticos = em.createQuery(
                "SELECT d FROM Diagnostico d WHERE d.iDOrdenServicio.iDOrdenServicio = :idOrdenServicio ORDER BY d.fechaDiagnostico DESC", 
                Diagnostico.class)
                .setParameter("idOrdenServicio", idOrdenServicio)
                .setMaxResults(1)
                .getResultList();
            return diagnosticos.isEmpty() ? null : diagnosticos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando último diagnóstico por orden", e);
        }
    }

    public List<Diagnostico> findByDescripcionContaining(String texto) {
        try {
            return em.createQuery("SELECT d FROM Diagnostico d WHERE d.descripcionDiagnostico LIKE :texto", Diagnostico.class)
                     .setParameter("texto", "%" + texto + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando diagnósticos por descripción", e);
        }
    }

    public List<Diagnostico> findByRecomendacionesContaining(String texto) {
        try {
            return em.createQuery("SELECT d FROM Diagnostico d WHERE d.recomendaciones LIKE :texto", Diagnostico.class)
                     .setParameter("texto", "%" + texto + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando diagnósticos por recomendaciones", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Diagnostico diagnostico = em.find(Diagnostico.class, id);
            if (diagnostico != null) {
                em.remove(diagnostico);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando diagnóstico", e);
        }
    }

    public Long countDiagnosticos() {
        try {
            return em.createQuery("SELECT COUNT(d) FROM Diagnostico d", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos", e);
        }
    }

    public Long countDiagnosticosByEmpleado(Integer idEmpleado) {
        try {
            return em.createQuery("SELECT COUNT(d) FROM Diagnostico d WHERE d.iDEmpleadoMecanico.iDEmpleado = :idEmpleado", Long.class)
                     .setParameter("idEmpleado", idEmpleado)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos por empleado", e);
        }
    }

    public Long countDiagnosticosByOrdenServicio(Integer idOrdenServicio) {
        try {
            return em.createQuery("SELECT COUNT(d) FROM Diagnostico d WHERE d.iDOrdenServicio.iDOrdenServicio = :idOrdenServicio", Long.class)
                     .setParameter("idOrdenServicio", idOrdenServicio)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos por orden de servicio", e);
        }
    }

    public List<Object[]> getDiagnosticosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT d, o, v, c, e FROM Diagnostico d " +
                "JOIN d.iDOrdenServicio o " +
                "JOIN o.iDVehiculo v " +
                "JOIN v.iDCliente c " +
                "JOIN d.iDEmpleadoMecanico e", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo diagnósticos con detalles completos", e);
        }
    }

    public List<Object[]> countDiagnosticosPorEmpleado() {
        try {
            return em.createQuery(
                "SELECT e.nombre, e.apellido, COUNT(d) FROM Diagnostico d " +
                "JOIN d.iDEmpleadoMecanico e " +
                "GROUP BY e.nombre, e.apellido " +
                "ORDER BY COUNT(d) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos por empleado", e);
        }
    }

    public List<Object[]> countDiagnosticosPorMes() {
        try {
            return em.createQuery(
                "SELECT YEAR(d.fechaDiagnostico), MONTH(d.fechaDiagnostico), COUNT(d) FROM Diagnostico d " +
                "WHERE d.fechaDiagnostico IS NOT NULL " +
                "GROUP BY YEAR(d.fechaDiagnostico), MONTH(d.fechaDiagnostico) " +
                "ORDER BY YEAR(d.fechaDiagnostico) DESC, MONTH(d.fechaDiagnostico) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos por mes", e);
        }
    }

    // Métodos adicionales útiles
    
    public List<Diagnostico> listarDiagnosticosPendientes() {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d WHERE d.fechaDiagnostico IS NULL", 
                Diagnostico.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos pendientes", e);
        }
    }

    public List<Diagnostico> listarDiagnosticosRecientes(int limite) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d WHERE d.fechaDiagnostico IS NOT NULL ORDER BY d.fechaDiagnostico DESC", 
                Diagnostico.class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos recientes", e);
        }
    }

    public boolean existeDiagnosticoParaOrden(int idOrden) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(d) FROM Diagnostico d WHERE d.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Long.class)
                .setParameter("idOrden", idOrden)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de diagnóstico para orden", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Diagnostico> listarDiagnosticosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d " +
                "LEFT JOIN FETCH d.iDOrdenServicio o " +
                "LEFT JOIN FETCH o.iDVehiculo v " +
                "LEFT JOIN FETCH v.iDCliente c " +
                "LEFT JOIN FETCH d.iDEmpleadoMecanico e " +
                "ORDER BY d.fechaDiagnostico DESC", 
                Diagnostico.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos con detalles completos", e);
        }
    }

    public List<Diagnostico> listarDiagnosticosPorRangoFechas(Date fechaInicio, Date fechaFin) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d " +
                "WHERE d.fechaDiagnostico BETWEEN :fechaInicio AND :fechaFin " +
                "ORDER BY d.fechaDiagnostico ASC", 
                Diagnostico.class)
                .setParameter("fechaInicio", fechaInicio)
                .setParameter("fechaFin", fechaFin)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando diagnósticos por rango de fechas", e);
        }
    }

    public int contarDiagnosticosHoy() {
        try {
            Date hoy = new Date();
            Long count = em.createQuery(
                "SELECT COUNT(d) FROM Diagnostico d " +
                "WHERE FUNCTION('DATE', d.fechaDiagnostico) = FUNCTION('DATE', :hoy)", 
                Long.class)
                .setParameter("hoy", hoy)
                .getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            throw new RuntimeException("Error contando diagnósticos de hoy", e);
        }
    }

    // CORRECCIÓN: Método para obtener diagnósticos con problemas específicos
    public List<Diagnostico> buscarDiagnosticosPorProblema(String problema) {
        try {
            return em.createQuery(
                "SELECT d FROM Diagnostico d " +
                "WHERE LOWER(d.descripcionDiagnostico) LIKE LOWER(:problema) " +
                "OR LOWER(d.recomendaciones) LIKE LOWER(:problema)", 
                Diagnostico.class)
                .setParameter("problema", "%" + problema + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando diagnósticos por problema", e);
        }
    }

    // CORRECCIÓN: Método para obtener el último diagnóstico de una orden
    public Diagnostico obtenerUltimoDiagnosticoOrden(int idOrden) {
        try {
            List<Diagnostico> diagnosticos = em.createQuery(
                "SELECT d FROM Diagnostico d " +
                "WHERE d.iDOrdenServicio.iDOrdenServicio = :idOrden " +
                "ORDER BY d.fechaDiagnostico DESC", 
                Diagnostico.class)
                .setParameter("idOrden", idOrden)
                .setMaxResults(1)
                .getResultList();
            return diagnosticos.isEmpty() ? null : diagnosticos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo último diagnóstico de orden", e);
        }
    }
}