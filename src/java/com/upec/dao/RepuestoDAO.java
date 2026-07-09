package com.upec.dao;

import com.upec.model.Repuesto;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.List;

@Stateless
public class RepuestoDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    // CRUD Básico
    public List<Repuesto> listarRepuestos() {
        try {
            return em.createQuery("SELECT r FROM Repuesto r ORDER BY r.nombreRepuesto", Repuesto.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando repuestos", e);
        }
    }

    public Repuesto obtenerRepuestoPorId(int id) {
        try {
            return em.find(Repuesto.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo repuesto por ID", e);
        }
    }

    @Transactional
    public boolean crearRepuesto(Repuesto repuesto) {
        try {
            em.persist(repuesto);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error creando repuesto", e);
        }
    }

    @Transactional
    public boolean actualizarRepuesto(Repuesto repuesto) {
        try {
            em.merge(repuesto);
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando repuesto", e);
        }
    }

    @Transactional
    public boolean eliminarRepuesto(int id) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, id);
            if (repuesto != null) {
                // Verificar si hay detalles de factura asociados
                if (!puedeEliminarRepuesto(id)) {
                    return false;
                }
                em.remove(repuesto);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando repuesto", e);
        }
    }

    // Para Mecánico (Inventario)
    public List<Repuesto> listarRepuestosDisponibles() {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r WHERE r.estado = true AND r.stock > 0 ORDER BY r.nombreRepuesto", 
                Repuesto.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando repuestos disponibles", e);
        }
    }

    public List<Repuesto> listarRepuestosBajoStock() {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r WHERE r.stock <= r.stockMinimo AND r.estado = true ORDER BY r.stock ASC", 
                Repuesto.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando repuestos bajo stock", e);
        }
    }

    @Transactional
    public boolean actualizarStock(int idRepuesto, int cantidad) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null) {
                repuesto.setStock(cantidad);
                em.merge(repuesto);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando stock", e);
        }
    }

    // Búsquedas
    public List<Repuesto> buscarRepuestosPorNombre(String nombre) {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r WHERE r.nombreRepuesto LIKE :nombre AND r.estado = true ORDER BY r.nombreRepuesto", 
                Repuesto.class)
                .setParameter("nombre", "%" + nombre + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando repuestos por nombre", e);
        }
    }

    public List<Repuesto> filtrarRepuestosPorPrecio(double precioMin, double precioMax) {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r WHERE r.precioVenta BETWEEN :precioMin AND :precioMax AND r.estado = true ORDER BY r.precioVenta", 
                Repuesto.class)
                .setParameter("precioMin", BigDecimal.valueOf(precioMin))
                .setParameter("precioMax", BigDecimal.valueOf(precioMax))
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error filtrando repuestos por precio", e);
        }
    }

    // Alertas
    public List<Repuesto> obtenerRepuestosStockCritico() {
        try {
            // Stock crítico: stock menor o igual al 20% del stock mínimo
            return em.createQuery(
                "SELECT r FROM Repuesto r WHERE r.stock <= (r.stockMinimo * 0.2) AND r.estado = true ORDER BY r.stock ASC", 
                Repuesto.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo repuestos con stock crítico", e);
        }
    }

    public int verificarStockDisponible(int idRepuesto, int cantidadRequerida) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null && repuesto.getEstado() && repuesto.getStock() != null) {
                return repuesto.getStock() - cantidadRequerida;
            }
            return -1; // Indica que el repuesto no existe o no está activo
        } catch (Exception e) {
            throw new RuntimeException("Error verificando stock disponible", e);
        }
    }

    // Métodos adicionales útiles (mantenidos para compatibilidad)
    
    @Transactional
    public void create(Repuesto repuesto) {
        try {
            em.persist(repuesto);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear repuesto", e);
        }
    }

    @Transactional
    public void saveOrUpdate(Repuesto repuesto) {
        try {
            if (repuesto.getIDRepuesto() == null) {
                em.persist(repuesto);
            } else {
                em.merge(repuesto);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando repuesto", e);
        }
    }

    public Repuesto findById(Integer id) {
        return obtenerRepuestoPorId(id);
    }

    public List<Repuesto> findAll() {
        return listarRepuestos();
    }

    public List<Repuesto> findActivos() {
        try {
            return em.createQuery("SELECT r FROM Repuesto r WHERE r.estado = true ORDER BY r.nombreRepuesto", Repuesto.class).getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando repuestos activos", e);
        }
    }

    public List<Repuesto> findByNombre(String nombre) {
        return buscarRepuestosPorNombre(nombre);
    }

    public List<Repuesto> findByDescripcion(String descripcion) {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r WHERE r.descripcion LIKE :descripcion AND r.estado = true ORDER BY r.nombreRepuesto", 
                Repuesto.class)
                .setParameter("descripcion", "%" + descripcion + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando repuestos por descripción", e);
        }
    }

    public List<Repuesto> findByStockBajo() {
        return listarRepuestosBajoStock();
    }

    public List<Repuesto> findByRangoPrecioVenta(BigDecimal precioMin, BigDecimal precioMax) {
        return filtrarRepuestosPorPrecio(precioMin.doubleValue(), precioMax.doubleValue());
    }

    public List<Repuesto> findByEstado(Boolean estado) {
        try {
            return em.createQuery("SELECT r FROM Repuesto r WHERE r.estado = :estado ORDER BY r.nombreRepuesto", Repuesto.class)
                     .setParameter("estado", estado)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando repuestos por estado", e);
        }
    }

    @Transactional
    public void updateStock(Integer id, Integer nuevoStock) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, id);
            if (repuesto != null) {
                repuesto.setStock(nuevoStock);
                em.merge(repuesto);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando stock del repuesto", e);
        }
    }

    @Transactional
    public void updatePrecios(Integer id, BigDecimal precioCompra, BigDecimal precioVenta) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, id);
            if (repuesto != null) {
                repuesto.setPrecioCompra(precioCompra);
                repuesto.setPrecioVenta(precioVenta);
                em.merge(repuesto);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando precios del repuesto", e);
        }
    }

    @Transactional
    public void cambiarEstado(Integer id, Boolean estado) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, id);
            if (repuesto != null) {
                repuesto.setEstado(estado);
                em.merge(repuesto);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error cambiando estado del repuesto", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, id);
            if (repuesto != null) {
                em.remove(repuesto);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando repuesto", e);
        }
    }

    public Long countRepuestosActivos() {
        try {
            return em.createQuery("SELECT COUNT(r) FROM Repuesto r WHERE r.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando repuestos activos", e);
        }
    }

    public Long countRepuestosStockBajo() {
        try {
            return em.createQuery("SELECT COUNT(r) FROM Repuesto r WHERE r.stock <= r.stockMinimo AND r.estado = true", Long.class)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando repuestos con stock bajo", e);
        }
    }

    public BigDecimal getValorTotalInventario() {
        try {
            BigDecimal result = em.createQuery("SELECT SUM(r.precioCompra * r.stock) FROM Repuesto r WHERE r.estado = true", BigDecimal.class)
                     .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo valor total del inventario", e);
        }
    }

    public List<Object[]> getRepuestosMasVendidos(int limite) {
        try {
            return em.createQuery(
                "SELECT r, COUNT(df) as cantidadVendida FROM Repuesto r " +
                "LEFT JOIN r.detalleFacturaList df " +
                "WHERE r.estado = true " +
                "GROUP BY r " +
                "ORDER BY cantidadVendida DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo repuestos más vendidos", e);
        }
    }

    // Métodos adicionales útiles
    
    @Transactional
    public boolean reducirStock(int idRepuesto, int cantidad) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null && repuesto.getStock() != null && repuesto.getStock() >= cantidad) {
                repuesto.setStock(repuesto.getStock() - cantidad);
                em.merge(repuesto);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error reduciendo stock", e);
        }
    }

    @Transactional
    public boolean aumentarStock(int idRepuesto, int cantidad) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null && repuesto.getStock() != null) {
                repuesto.setStock(repuesto.getStock() + cantidad);
                em.merge(repuesto);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error aumentando stock", e);
        }
    }

    public List<Repuesto> buscarRepuestosPorDescripcion(String descripcion) {
        return findByDescripcion(descripcion);
    }

    public boolean existeRepuestoConNombre(String nombre) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(r) FROM Repuesto r WHERE r.nombreRepuesto = :nombre", 
                Long.class)
                .setParameter("nombre", nombre)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de repuesto con nombre", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales mejorados
    
    public boolean puedeEliminarRepuesto(int idRepuesto) {
        try {
            // Verificar si hay detalles de factura asociados
            Long count = em.createQuery(
                "SELECT COUNT(df) FROM DetalleFactura df WHERE df.iDRepuesto.iDRepuesto = :idRepuesto", 
                Long.class)
                .setParameter("idRepuesto", idRepuesto)
                .getSingleResult();
            
            return count == 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando si se puede eliminar repuesto", e);
        }
    }

    public List<Repuesto> listarRepuestosConDetallesCompletos() {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r " +
                "LEFT JOIN FETCH r.detalleFacturaList df " +
                "WHERE r.estado = true " +
                "ORDER BY r.nombreRepuesto", 
                Repuesto.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error listando repuestos con detalles completos", e);
        }
    }

    public Repuesto obtenerRepuestoConDetallesFactura(int idRepuesto) {
        try {
            List<Repuesto> repuestos = em.createQuery(
                "SELECT r FROM Repuesto r " +
                "LEFT JOIN FETCH r.detalleFacturaList df " +
                "LEFT JOIN FETCH df.iDFactura f " +
                "WHERE r.iDRepuesto = :id", 
                Repuesto.class)
                .setParameter("id", idRepuesto)
                .getResultList();
            return repuestos.isEmpty() ? null : repuestos.get(0);
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo repuesto con detalles de factura", e);
        }
    }

    public List<Repuesto> buscarRepuestosPorCriterio(String criterio) {
        try {
            return em.createQuery(
                "SELECT r FROM Repuesto r " +
                "WHERE (r.nombreRepuesto LIKE :criterio " +
                "OR r.descripcion LIKE :criterio) " +
                "AND r.estado = true " +
                "ORDER BY r.nombreRepuesto", 
                Repuesto.class)
                .setParameter("criterio", "%" + criterio + "%")
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando repuestos por criterio", e);
        }
    }

    @Transactional
    public boolean activarRepuesto(int idRepuesto) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null) {
                repuesto.setEstado(true);
                em.merge(repuesto);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error activando repuesto", e);
        }
    }

    @Transactional
    public boolean desactivarRepuesto(int idRepuesto) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null) {
                repuesto.setEstado(false);
                em.merge(repuesto);
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Error desactivando repuesto", e);
        }
    }

    public List<Object[]> obtenerEstadisticasRepuestos() {
        try {
            return em.createQuery(
                "SELECT r.nombreRepuesto, " +
                "r.stock, " +
                "r.stockMinimo, " +
                "r.precioCompra, " +
                "r.precioVenta, " +
                "COUNT(df) as vecesVendido, " +
                "CASE WHEN r.estado = true THEN 'Activo' ELSE 'Inactivo' END as estado " +
                "FROM Repuesto r " +
                "LEFT JOIN r.detalleFacturaList df " +
                "GROUP BY r.nombreRepuesto, r.stock, r.stockMinimo, r.precioCompra, r.precioVenta, r.estado " +
                "ORDER BY vecesVendido DESC", 
                Object[].class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo estadísticas de repuestos", e);
        }
    }

    public BigDecimal calcularMargenGanancia(int idRepuesto) {
        try {
            Repuesto repuesto = em.find(Repuesto.class, idRepuesto);
            if (repuesto != null && repuesto.getPrecioCompra() != null && repuesto.getPrecioVenta() != null) {
                if (repuesto.getPrecioCompra().compareTo(BigDecimal.ZERO) > 0) {
                    return repuesto.getPrecioVenta().subtract(repuesto.getPrecioCompra());
                }
            }
            return BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando margen de ganancia", e);
        }
    }

    @Transactional
    public Repuesto crearRepuestoSiNoExiste(String nombreRepuesto, String descripcion, BigDecimal precioCompra, BigDecimal precioVenta, Integer stock, Integer stockMinimo) {
        try {
            // Verificar si ya existe el repuesto
            Repuesto repuestoExistente = findByNombre(nombreRepuesto).stream().findFirst().orElse(null);
            if (repuestoExistente != null) {
                return repuestoExistente;
            }

            // Crear nuevo repuesto
            Repuesto nuevoRepuesto = new Repuesto();
            nuevoRepuesto.setNombreRepuesto(nombreRepuesto);
            nuevoRepuesto.setDescripcion(descripcion);
            nuevoRepuesto.setPrecioCompra(precioCompra);
            nuevoRepuesto.setPrecioVenta(precioVenta);
            nuevoRepuesto.setStock(stock);
            nuevoRepuesto.setStockMinimo(stockMinimo);
            nuevoRepuesto.setEstado(true);
            
            em.persist(nuevoRepuesto);
            return nuevoRepuesto;
        } catch (Exception e) {
            throw new RuntimeException("Error creando repuesto si no existe", e);
        }
    }
}