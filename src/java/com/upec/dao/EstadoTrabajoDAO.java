package com.upec.dao;

import com.upec.model.EstadoTrabajo;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;

@Stateless
public class EstadoTrabajoDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    public List<EstadoTrabajo> listarEstadosTrabajo() {
        try {
            return em.createQuery("SELECT e FROM EstadoTrabajo e ORDER BY e.nombreEstado", EstadoTrabajo.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando estados de trabajo", e);
        }
    }

    public EstadoTrabajo obtenerEstadoPorId(int id) {
        try {
            return em.find(EstadoTrabajo.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado por ID", e);
        }
    }

    public EstadoTrabajo obtenerEstadoPorNombre(String nombre) {
        try {
            List<EstadoTrabajo> estados = em.createQuery(
                "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado = :nombre", 
                EstadoTrabajo.class)
                .setParameter("nombre", nombre)
                .getResultList();
            return estados.isEmpty() ? null : estados.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estado por nombre", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(EstadoTrabajo estadoTrabajo) {
        try {
            em.persist(estadoTrabajo);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear estado de trabajo", e);
        }
    }

    @Transactional
    public void saveOrUpdate(EstadoTrabajo estadoTrabajo) {
        try {
            if (estadoTrabajo.getIDEstadoTrabajo() == null) {
                em.persist(estadoTrabajo);
            } else {
                em.merge(estadoTrabajo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando estado de trabajo", e);
        }
    }

    public EstadoTrabajo findById(Integer id) {
        return obtenerEstadoPorId(id);
    }

    public List<EstadoTrabajo> findAll() {
        return listarEstadosTrabajo();
    }

    public EstadoTrabajo findByNombreEstado(String nombreEstado) {
        return obtenerEstadoPorNombre(nombreEstado);
    }

    public boolean nombreEstadoExists(String nombreEstado) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(e) FROM EstadoTrabajo e WHERE e.nombreEstado = :nombreEstado", 
                Long.class)
                .setParameter("nombreEstado", nombreEstado)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de nombre de estado", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            EstadoTrabajo estadoTrabajo = em.find(EstadoTrabajo.class, id);
            if (estadoTrabajo != null) {
                em.remove(estadoTrabajo);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando estado de trabajo", e);
        }
    }

    public List<EstadoTrabajo> findEstadosActivos() {
        try {
            // Como no hay campo 'estado' en EstadoTrabajo, retornamos todos
            return em.createQuery("SELECT e FROM EstadoTrabajo e ORDER BY e.nombreEstado", EstadoTrabajo.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando estados activos", e);
        }
    }

    public Long countOrdenesPorEstado(Integer idEstado) {
        try {
            return em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDEstadoTrabajo.iDEstadoTrabajo = :idEstado", 
                Long.class)
                .setParameter("idEstado", idEstado)
                .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando órdenes por estado", e);
        }
    }

    public List<Object[]> countOrdenesPorEstado() {
        try {
            return em.createQuery(
                "SELECT e.nombreEstado, COUNT(o) FROM EstadoTrabajo e LEFT JOIN e.ordenServicioList o GROUP BY e.nombreEstado ORDER BY COUNT(o) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando órdenes por estado", e);
        }
    }

    // Métodos adicionales útiles
    
    public boolean puedeEliminarEstado(int idEstado) {
        try {
            // Verificar si hay órdenes de servicio usando este estado
            Long count = em.createQuery(
                "SELECT COUNT(o) FROM OrdenServicio o WHERE o.iDEstadoTrabajo.iDEstadoTrabajo = :idEstado", 
                Long.class)
                .setParameter("idEstado", idEstado)
                .getSingleResult();
            
            // Verificar si es un estado del sistema (no se pueden eliminar)
            EstadoTrabajo estado = em.find(EstadoTrabajo.class, idEstado);
            boolean esEstadoSistema = estado != null && 
                                    (estado.getNombreEstado().equals("PENDIENTE") || 
                                     estado.getNombreEstado().equals("EN PROCESO") ||
                                     estado.getNombreEstado().equals("COMPLETADO") ||
                                     estado.getNombreEstado().equals("CANCELADO") ||
                                     estado.getNombreEstado().equals("CITA PROGRAMADA"));
            
            return count == 0 && !esEstadoSistema;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar estado", e);
        }
    }

    public List<EstadoTrabajo> buscarEstadosPorDescripcion(String descripcion) {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e WHERE e.descripcion LIKE :descripcion ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .setParameter("descripcion", "%" + descripcion + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando estados por descripción", e);
        }
    }

    public Long contarTotalEstados() {
        try {
            return em.createQuery("SELECT COUNT(e) FROM EstadoTrabajo e", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando total de estados", e);
        }
    }

    public List<EstadoTrabajo> listarEstadosParaOrdenes() {
        try {
            // Estados comúnmente usados para órdenes de servicio
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado IN ('PENDIENTE', 'EN PROCESO', 'COMPLETADO', 'CANCELADO', 'CITA PROGRAMADA') ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando estados para órdenes", e);
        }
    }

    public EstadoTrabajo obtenerEstadoPendiente() {
        return obtenerEstadoPorNombre("PENDIENTE");
    }

    public EstadoTrabajo obtenerEstadoEnProceso() {
        return obtenerEstadoPorNombre("EN PROCESO");
    }

    public EstadoTrabajo obtenerEstadoCompletado() {
        return obtenerEstadoPorNombre("COMPLETADO");
    }

    public EstadoTrabajo obtenerEstadoCancelado() {
        return obtenerEstadoPorNombre("CANCELADO");
    }

    public EstadoTrabajo obtenerEstadoCitaProgramada() {
        return obtenerEstadoPorNombre("CITA PROGRAMADA");
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<EstadoTrabajo> obtenerEstadosProgreso() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e " +
                "WHERE e.nombreEstado IN ('PENDIENTE', 'EN PROCESO', 'EN DIAGNOSTICO', 'EN REPARACION') " +
                "ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados de progreso", e);
        }
    }

    public List<EstadoTrabajo> obtenerEstadosFinalizados() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e " +
                "WHERE e.nombreEstado IN ('COMPLETADO', 'CANCELADO', 'ENTREGADO') " +
                "ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados finalizados", e);
        }
    }

    @Transactional
    public boolean actualizarDescripcionEstado(int idEstado, String nuevaDescripcion) {
        try {
            EstadoTrabajo estado = em.find(EstadoTrabajo.class, idEstado);
            if (estado != null) {
                estado.setDescripcion(nuevaDescripcion);
                em.merge(estado);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando descripción del estado", e);
        }
    }

    public List<EstadoTrabajo> buscarEstadosPorPatron(String patron) {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e " +
                "WHERE e.nombreEstado LIKE :patron OR e.descripcion LIKE :patron " +
                "ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .setParameter("patron", "%" + patron + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando estados por patrón", e);
        }
    }

    public List<Object[]> obtenerEstadisticasUsoEstados() {
        try {
            return em.createQuery(
                "SELECT e.nombreEstado, COUNT(o), " +
                "SUM(CASE WHEN o.fechaRealSalida IS NOT NULL THEN 1 ELSE 0 END) as completadas, " +
                "SUM(CASE WHEN o.fechaRealSalida IS NULL THEN 1 ELSE 0 END) as pendientes " +
                "FROM EstadoTrabajo e LEFT JOIN e.ordenServicioList o " +
                "GROUP BY e.nombreEstado " +
                "ORDER BY COUNT(o) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de uso de estados", e);
        }
    }

    public boolean esEstadoFinal(int idEstado) {
        try {
            EstadoTrabajo estado = em.find(EstadoTrabajo.class, idEstado);
            return estado != null && 
                   (estado.getNombreEstado().equals("COMPLETADO") || 
                    estado.getNombreEstado().equals("CANCELADO") ||
                    estado.getNombreEstado().equals("ENTREGADO"));
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si es estado final", e);
        }
    }

    public List<EstadoTrabajo> obtenerSiguientesEstados(int idEstadoActual) {
        try {
            // Lógica para determinar los estados posibles siguientes
            // Esto puede ser configurable o basado en reglas de negocio
            EstadoTrabajo estadoActual = em.find(EstadoTrabajo.class, idEstadoActual);
            if (estadoActual == null) {
                return listarEstadosParaOrdenes();
            }
            
            String nombreEstado = estadoActual.getNombreEstado();
            switch (nombreEstado) {
                case "CITA PROGRAMADA":
                    return em.createQuery(
                        "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado IN ('PENDIENTE', 'CANCELADO')", 
                        EstadoTrabajo.class).getResultList();
                case "PENDIENTE":
                    return em.createQuery(
                        "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado IN ('EN PROCESO', 'CANCELADO')", 
                        EstadoTrabajo.class).getResultList();
                case "EN PROCESO":
                    return em.createQuery(
                        "SELECT e FROM EstadoTrabajo e WHERE e.nombreEstado IN ('COMPLETADO', 'CANCELADO')", 
                        EstadoTrabajo.class).getResultList();
                default:
                    return listarEstadosParaOrdenes();
            }
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo siguientes estados", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales para gestión de estados
    
    public List<EstadoTrabajo> obtenerEstadosSistema() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e " +
                "WHERE e.nombreEstado IN ('PENDIENTE', 'EN PROCESO', 'COMPLETADO', 'CANCELADO', 'CITA PROGRAMADA') " +
                "ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados del sistema", e);
        }
    }

    public List<EstadoTrabajo> obtenerEstadosPersonalizados() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e " +
                "WHERE e.nombreEstado NOT IN ('PENDIENTE', 'EN PROCESO', 'COMPLETADO', 'CANCELADO', 'CITA PROGRAMADA') " +
                "ORDER BY e.nombreEstado", 
                EstadoTrabajo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados personalizados", e);
        }
    }

    public boolean esEstadoSistema(int idEstado) {
        try {
            EstadoTrabajo estado = em.find(EstadoTrabajo.class, idEstado);
            return estado != null && 
                   (estado.getNombreEstado().equals("PENDIENTE") || 
                    estado.getNombreEstado().equals("EN PROCESO") ||
                    estado.getNombreEstado().equals("COMPLETADO") ||
                    estado.getNombreEstado().equals("CANCELADO") ||
                    estado.getNombreEstado().equals("CITA PROGRAMADA"));
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si es estado del sistema", e);
        }
    }

    @Transactional
    public EstadoTrabajo crearEstadoPersonalizado(String nombre, String descripcion) {
        try {
            // Verificar si ya existe un estado con ese nombre
            if (nombreEstadoExists(nombre)) {
                throw new RuntimeException("Ya existe un estado con el nombre: " + nombre);
            }

            EstadoTrabajo nuevoEstado = new EstadoTrabajo();
            nuevoEstado.setNombreEstado(nombre);
            nuevoEstado.setDescripcion(descripcion);
            
            em.persist(nuevoEstado);
            return nuevoEstado;
        } catch (Exception e) {
            throw new RuntimeException("Error creando estado personalizado", e);
        }
    }

    public List<EstadoTrabajo> obtenerEstadosParaFiltro() {
        try {
            return em.createQuery(
                "SELECT e FROM EstadoTrabajo e " +
                "ORDER BY CASE " +
                "WHEN e.nombreEstado = 'CITA PROGRAMADA' THEN 1 " +
                "WHEN e.nombreEstado = 'PENDIENTE' THEN 2 " +
                "WHEN e.nombreEstado = 'EN PROCESO' THEN 3 " +
                "WHEN e.nombreEstado = 'COMPLETADO' THEN 4 " +
                "WHEN e.nombreEstado = 'CANCELADO' THEN 5 " +
                "ELSE 6 END, e.nombreEstado", 
                EstadoTrabajo.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estados para filtro", e);
        }
    }

    public List<Object[]> obtenerTiempoPromedioPorEstado() {
        try {
            return em.createQuery(
                "SELECT e.nombreEstado, " +
                "AVG(TIMESTAMPDIFF(HOUR, o.fechaEntrada, o.fechaRealSalida)) as horasPromedio " +
                "FROM EstadoTrabajo e " +
                "JOIN e.ordenServicioList o " +
                "WHERE o.fechaRealSalida IS NOT NULL " +
                "GROUP BY e.nombreEstado " +
                "ORDER BY horasPromedio DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo tiempo promedio por estado", e);
        }
    }
}