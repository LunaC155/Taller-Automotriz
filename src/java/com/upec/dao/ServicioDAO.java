package com.upec.dao;

import com.upec.model.Servicio;
import com.upec.model.DetalleFactura;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.List;

@Stateless
public class ServicioDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico
    public List<Servicio> listarServicios() {
        try {
            return em.createQuery("SELECT s FROM Servicio s", Servicio.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando servicios", e);
        }
    }

    public Servicio obtenerServicioPorId(int id) {
        try {
            return em.find(Servicio.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo servicio por ID", e);
        }
    }

    @Transactional
    public boolean crearServicio(Servicio servicio) {
        try {
            em.persist(servicio);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando servicio", e);
        }
    }

    @Transactional
    public boolean actualizarServicio(Servicio servicio) {
        try {
            em.merge(servicio);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando servicio", e);
        }
    }

    @Transactional
    public boolean eliminarServicio(int id) {
        try {
            Servicio servicio = em.find(Servicio.class, id);
            if (servicio != null) {
                // Verificar si hay detalles de factura usando este servicio
                Long count = em.createQuery(
                    "SELECT COUNT(df) FROM DetalleFactura df WHERE df.iDServicio.iDServicio = :idServicio", 
                    Long.class)
                    .setParameter("idServicio", id)
                    .getSingleResult();
                
                if (count > 0) {
                    return false;
                }
                em.remove(servicio);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando servicio", e);
        }
    }

    // Para Mecánico (Tareas)
    public List<Servicio> listarServiciosActivos() {
        try {
            return em.createQuery("SELECT s FROM Servicio s WHERE s.estado = true", Servicio.class)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando servicios activos", e);
        }
    }

    public List<Servicio> listarServiciosPorOrden(int idOrden) {
        try {
            return em.createQuery(
                "SELECT DISTINCT s FROM Servicio s " +
                "JOIN s.detalleFacturaList df " +
                "JOIN df.iDFactura f " +
                "WHERE f.iDOrdenServicio.iDOrdenServicio = :idOrden", 
                Servicio.class)
                .setParameter("idOrden", idOrden)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando servicios por orden", e);
        }
    }

    // Para Cliente
    public List<Servicio> listarServiciosPopulares() {
        try {
            return em.createQuery(
                "SELECT s FROM Servicio s " +
                "LEFT JOIN s.detalleFacturaList df " +
                "WHERE s.estado = true " +
                "GROUP BY s " +
                "ORDER BY COUNT(df) DESC", 
                Servicio.class)
                .setMaxResults(10) // Top 10 servicios más populares
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando servicios populares", e);
        }
    }

    // Búsquedas y Filtros
    public List<Servicio> buscarServiciosPorNombre(String nombre) {
        try {
            return em.createQuery("SELECT s FROM Servicio s WHERE s.nombreServicio LIKE :nombre", Servicio.class)
                     .setParameter("nombre", "%" + nombre + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicios por nombre", e);
        }
    }

    public List<Servicio> filtrarServiciosPorPrecio(double precioMin, double precioMax) {
        try {
            return em.createQuery(
                "SELECT s FROM Servicio s WHERE s.precioBase BETWEEN :precioMin AND :precioMax AND s.estado = true", 
                Servicio.class)
                .setParameter("precioMin", BigDecimal.valueOf(precioMin))
                .setParameter("precioMax", BigDecimal.valueOf(precioMax))
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando servicios por precio", e);
        }
    }

    // Para Facturación
    public double obtenerPrecioServicio(int idServicio) {
        try {
            Servicio servicio = em.find(Servicio.class, idServicio);
            return servicio != null && servicio.getPrecioBase() != null ? 
                   servicio.getPrecioBase().doubleValue() : 0.0;
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo precio del servicio", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Servicio servicio) {
        try {
            em.persist(servicio);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear servicio", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Servicio servicio) {
        try {
            if (servicio.getIDServicio() == null) {
                em.persist(servicio);
            } else {
                em.merge(servicio);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando servicio", e);
        }
    }

    public Servicio findById(Integer id) {
        return obtenerServicioPorId(id);
    }

    public List<Servicio> findAll() {
        return listarServicios();
    }

    public List<Servicio> findByEstado(Boolean estado) {
        try {
            return em.createQuery("SELECT s FROM Servicio s WHERE s.estado = :estado", Servicio.class)
                     .setParameter("estado", estado)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicios por estado", e);
        }
    }

    public Servicio findByNombreServicio(String nombreServicio) {
        try {
            List<Servicio> servicios = em.createQuery(
                "SELECT s FROM Servicio s WHERE s.nombreServicio = :nombreServicio", 
                Servicio.class)
                .setParameter("nombreServicio", nombreServicio)
                .getResultList();
            return servicios.isEmpty() ? null : servicios.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicio por nombre", e);
        }
    }

    public boolean nombreServicioExists(String nombreServicio) {
        try {
            Long count = em.createQuery("SELECT COUNT(s) FROM Servicio s WHERE s.nombreServicio = :nombreServicio", Long.class)
                           .setParameter("nombreServicio", nombreServicio)
                           .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de nombre de servicio", e);
        }
    }

    public List<Servicio> findByPrecioBaseBetween(BigDecimal min, BigDecimal max) {
        return filtrarServiciosPorPrecio(min.doubleValue(), max.doubleValue());
    }

    public List<Servicio> findByDuracionEstimadaLessThan(Integer duracion) {
        try {
            return em.createQuery("SELECT s FROM Servicio s WHERE s.duracionEstimada < :duracion AND s.estado = true", Servicio.class)
                     .setParameter("duracion", duracion)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicios por duración menor", e);
        }
    }

    public List<Servicio> findByDuracionEstimadaGreaterThan(Integer duracion) {
        try {
            return em.createQuery("SELECT s FROM Servicio s WHERE s.duracionEstimada > :duracion AND s.estado = true", Servicio.class)
                     .setParameter("duracion", duracion)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicios por duración mayor", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Servicio servicio = em.find(Servicio.class, id);
            if (servicio != null) {
                em.remove(servicio);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando servicio", e);
        }
    }

    @Transactional
    public void updateEstado(Integer id, Boolean estado) {
        try {
            Servicio servicio = em.find(Servicio.class, id);
            if (servicio != null) {
                servicio.setEstado(estado);
                em.merge(servicio);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando estado del servicio", e);
        }
    }

    @Transactional
    public void updatePrecioBase(Integer id, BigDecimal nuevoPrecio) {
        try {
            Servicio servicio = em.find(Servicio.class, id);
            if (servicio != null) {
                servicio.setPrecioBase(nuevoPrecio);
                em.merge(servicio);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando precio base del servicio", e);
        }
    }

    public List<Servicio> findServiciosActivos() {
        return listarServiciosActivos();
    }

    public Long countServiciosActivos() {
        try {
            return em.createQuery("SELECT COUNT(s) FROM Servicio s WHERE s.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando servicios activos", e);
        }
    }

    public BigDecimal getPrecioPromedio() {
        try {
            BigDecimal result = em.createQuery("SELECT AVG(s.precioBase) FROM Servicio s WHERE s.estado = true", BigDecimal.class)
                     .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo precio promedio", e);
        }
    }

    public List<Servicio> findByDescripcionContaining(String texto) {
        try {
            return em.createQuery("SELECT s FROM Servicio s WHERE s.descripcion LIKE :texto AND s.estado = true", Servicio.class)
                     .setParameter("texto", "%" + texto + "%")
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicios por descripción", e);
        }
    }

    public List<Object[]> countUsosPorServicio() {
        try {
            return em.createQuery(
                "SELECT s.nombreServicio, COUNT(df) FROM Servicio s LEFT JOIN s.detalleFacturaList df GROUP BY s.nombreServicio ORDER BY COUNT(df) DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error contando usos por servicio", e);
        }
    }

    // Métodos adicionales útiles
    
    public List<Servicio> buscarServiciosPorDescripcion(String descripcion) {
        return findByDescripcionContaining(descripcion);
    }

    public List<Servicio> filtrarServiciosPorDuracion(int duracionMin, int duracionMax) {
        try {
            return em.createQuery(
                "SELECT s FROM Servicio s WHERE s.duracionEstimada BETWEEN :duracionMin AND :duracionMax AND s.estado = true", 
                Servicio.class)
                .setParameter("duracionMin", duracionMin)
                .setParameter("duracionMax", duracionMax)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando servicios por duración", e);
        }
    }

    public boolean servicioTieneFacturas(int idServicio) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(df) FROM DetalleFactura df WHERE df.iDServicio.iDServicio = :idServicio", 
                Long.class)
                .setParameter("idServicio", idServicio)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si servicio tiene facturas", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public List<Servicio> listarServiciosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT s FROM Servicio s " +
                "LEFT JOIN FETCH s.detalleFacturaList " +
                "WHERE s.estado = true " +
                "ORDER BY s.nombreServicio", 
                Servicio.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando servicios con detalles completos", e);
        }
    }

    public List<Servicio> buscarServiciosPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT s FROM Servicio s " +
                "WHERE (s.nombreServicio LIKE :criterio OR s.descripcion LIKE :criterio) " +
                "AND s.estado = true " +
                "ORDER BY s.nombreServicio", 
                Servicio.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando servicios por criterio", e);
        }
    }

    public List<Object[]> obtenerEstadisticasServicios() {
        try {
            return em.createQuery(
                "SELECT " +
                "COUNT(s) as totalServicios, " +
                "SUM(CASE WHEN s.estado = true THEN 1 ELSE 0 END) as serviciosActivos, " +
                "AVG(s.precioBase) as precioPromedio, " +
                "AVG(s.duracionEstimada) as duracionPromedio, " +
                "SUM(CASE WHEN s.detalleFacturaList IS EMPTY THEN 1 ELSE 0 END) as serviciosNoUsados " +
                "FROM Servicio s", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de servicios", e);
        }
    }

    public List<Servicio> obtenerServiciosRecomendados(int idServicioActual) {
        try {
            // Servicios recomendados basados en servicios que suelen usarse juntos
            return em.createQuery(
                "SELECT s2 FROM Servicio s1 " +
                "JOIN s1.detalleFacturaList df1 " +
                "JOIN df1.iDFactura f " +
                "JOIN f.detalleFacturaList df2 " +
                "JOIN df2.iDServicio s2 " +
                "WHERE s1.iDServicio = :idServicio " +
                "AND s2.iDServicio != :idServicio " +
                "AND s2.estado = true " +
                "GROUP BY s2 " +
                "ORDER BY COUNT(s2) DESC", 
                Servicio.class)
                .setParameter("idServicio", idServicioActual)
                .setMaxResults(5)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo servicios recomendados", e);
        }
    }

    public BigDecimal obtenerIngresosTotalesPorServicio(int idServicio) {
        try {
            BigDecimal result = em.createQuery(
                "SELECT SUM(df.subtotal) FROM DetalleFactura df " +
                "WHERE df.iDServicio.iDServicio = :idServicio", 
                BigDecimal.class)
                .setParameter("idServicio", idServicio)
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo ingresos totales por servicio", e);
        }
    }

    @Transactional
    public boolean duplicarServicio(int idServicio, String nuevoNombre) {
        try {
            Servicio servicioOriginal = em.find(Servicio.class, idServicio);
            if (servicioOriginal == null || nombreServicioExists(nuevoNombre)) {
                return false;
            }

            Servicio servicioDuplicado = new Servicio();
            servicioDuplicado.setNombreServicio(nuevoNombre);
            servicioDuplicado.setDescripcion(servicioOriginal.getDescripcion());
            servicioDuplicado.setPrecioBase(servicioOriginal.getPrecioBase());
            servicioDuplicado.setDuracionEstimada(servicioOriginal.getDuracionEstimada());
            servicioDuplicado.setEstado(true);

            em.persist(servicioDuplicado);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error duplicando servicio", e);
        }
    }
}