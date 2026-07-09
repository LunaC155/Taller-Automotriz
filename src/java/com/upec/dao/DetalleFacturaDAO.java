package com.upec.dao;

import com.upec.model.DetalleFactura;
import com.upec.model.Factura;
import com.upec.model.Servicio;
import com.upec.model.Repuesto;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.util.List;

@Stateless
public class DetalleFacturaDAO {

    @PersistenceContext(unitName = "taller_automotrizPU")
    private EntityManager em;

    @Transactional
    public void create(DetalleFactura detalleFactura) {
        try {
            em.persist(detalleFactura);
        } catch (Exception e) {
            throw new RuntimeException("Error al crear detalle de factura", e);
        }
    }

    @Transactional
    public void saveOrUpdate(DetalleFactura detalleFactura) {
        try {
            if (detalleFactura.getIDDetalleFactura() == null) {
                em.persist(detalleFactura);
            } else {
                em.merge(detalleFactura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error guardando detalle de factura", e);
        }
    }

    public DetalleFactura findById(Integer id) {
        try {
            return em.find(DetalleFactura.class, id);
        } catch (Exception e) {
            throw new RuntimeException("Error buscando detalle de factura por ID", e);
        }
    }

    public List<DetalleFactura> findByFactura(Integer idFactura) {
        try {
            return em.createQuery("SELECT d FROM DetalleFactura d WHERE d.iDFactura.iDFactura = :idFactura ORDER BY d.iDDetalleFactura", DetalleFactura.class)
                     .setParameter("idFactura", idFactura)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando detalles por factura", e);
        }
    }

    public List<DetalleFactura> findByServicio(Integer idServicio) {
        try {
            return em.createQuery("SELECT d FROM DetalleFactura d WHERE d.iDServicio.iDServicio = :idServicio", DetalleFactura.class)
                     .setParameter("idServicio", idServicio)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando detalles por servicio", e);
        }
    }

    public List<DetalleFactura> findByRepuesto(Integer idRepuesto) {
        try {
            return em.createQuery("SELECT d FROM DetalleFactura d WHERE d.iDRepuesto.iDRepuesto = :idRepuesto", DetalleFactura.class)
                     .setParameter("idRepuesto", idRepuesto)
                     .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando detalles por repuesto", e);
        }
    }

    @Transactional
    public void delete(Integer id) {
        try {
            DetalleFactura detalleFactura = em.find(DetalleFactura.class, id);
            if (detalleFactura != null) {
                em.remove(detalleFactura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando detalle de factura", e);
        }
    }

    @Transactional
    public void deleteByFactura(Integer idFactura) {
        try {
            em.createQuery("DELETE FROM DetalleFactura d WHERE d.iDFactura.iDFactura = :idFactura")
              .setParameter("idFactura", idFactura)
              .executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException("Error eliminando detalles de factura", e);
        }
    }

    @Transactional
    public void updateCantidadPrecio(Integer id, Integer cantidad, BigDecimal precioUnitario) {
        try {
            DetalleFactura detalleFactura = em.find(DetalleFactura.class, id);
            if (detalleFactura != null) {
                detalleFactura.setCantidad(cantidad);
                detalleFactura.setPrecioUnitario(precioUnitario);
                detalleFactura.setSubtotal(precioUnitario.multiply(BigDecimal.valueOf(cantidad)));
                em.merge(detalleFactura);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando detalle de factura", e);
        }
    }

    public BigDecimal getTotalFactura(Integer idFactura) {
        try {
            BigDecimal result = em.createQuery("SELECT SUM(d.subtotal) FROM DetalleFactura d WHERE d.iDFactura.iDFactura = :idFactura", BigDecimal.class)
                     .setParameter("idFactura", idFactura)
                     .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando total de factura", e);
        }
    }

    public Long countByServicio(Integer idServicio) {
        try {
            return em.createQuery("SELECT COUNT(d) FROM DetalleFactura d WHERE d.iDServicio.iDServicio = :idServicio", Long.class)
                     .setParameter("idServicio", idServicio)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando detalles por servicio", e);
        }
    }

    public Long countByRepuesto(Integer idRepuesto) {
        try {
            return em.createQuery("SELECT COUNT(d) FROM DetalleFactura d WHERE d.iDRepuesto.iDRepuesto = :idRepuesto", Long.class)
                     .setParameter("idRepuesto", idRepuesto)
                     .getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error contando detalles por repuesto", e);
        }
    }

    public List<Object[]> getServiciosMasVendidos(int limite) {
        try {
            return em.createQuery(
                "SELECT s, COUNT(d) as cantidad FROM DetalleFactura d " +
                "JOIN d.iDServicio s " +
                "GROUP BY s " +
                "ORDER BY cantidad DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo servicios más vendidos", e);
        }
    }

    public List<Object[]> getRepuestosMasVendidos(int limite) {
        try {
            return em.createQuery(
                "SELECT r, COUNT(d) as cantidad FROM DetalleFactura d " +
                "JOIN d.iDRepuesto r " +
                "GROUP BY r " +
                "ORDER BY cantidad DESC", 
                Object[].class)
                .setMaxResults(limite)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo repuestos más vendidos", e);
        }
    }

    // CORRECCIÓN: Métodos adicionales útiles

    public List<DetalleFactura> findByFacturaConDetalles(Integer idFactura) {
        try {
            return em.createQuery(
                "SELECT d FROM DetalleFactura d " +
                "LEFT JOIN FETCH d.iDServicio " +
                "LEFT JOIN FETCH d.iDRepuesto " +
                "WHERE d.iDFactura.iDFactura = :idFactura " +
                "ORDER BY d.iDDetalleFactura", 
                DetalleFactura.class)
                .setParameter("idFactura", idFactura)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error buscando detalles de factura con información completa", e);
        }
    }

    public BigDecimal getTotalServiciosFactura(Integer idFactura) {
        try {
            BigDecimal result = em.createQuery(
                "SELECT SUM(d.subtotal) FROM DetalleFactura d " +
                "WHERE d.iDFactura.iDFactura = :idFactura " +
                "AND d.iDServicio IS NOT NULL", 
                BigDecimal.class)
                .setParameter("idFactura", idFactura)
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando total de servicios", e);
        }
    }

    public BigDecimal getTotalRepuestosFactura(Integer idFactura) {
        try {
            BigDecimal result = em.createQuery(
                "SELECT SUM(d.subtotal) FROM DetalleFactura d " +
                "WHERE d.iDFactura.iDFactura = :idFactura " +
                "AND d.iDRepuesto IS NOT NULL", 
                BigDecimal.class)
                .setParameter("idFactura", idFactura)
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) {
            throw new RuntimeException("Error calculando total de repuestos", e);
        }
    }

    public boolean existeDetalleParaServicioEnFactura(Integer idFactura, Integer idServicio) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(d) FROM DetalleFactura d " +
                "WHERE d.iDFactura.iDFactura = :idFactura " +
                "AND d.iDServicio.iDServicio = :idServicio", 
                Long.class)
                .setParameter("idFactura", idFactura)
                .setParameter("idServicio", idServicio)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de servicio en factura", e);
        }
    }

    public boolean existeDetalleParaRepuestoEnFactura(Integer idFactura, Integer idRepuesto) {
        try {
            Long count = em.createQuery(
                "SELECT COUNT(d) FROM DetalleFactura d " +
                "WHERE d.iDFactura.iDFactura = :idFactura " +
                "AND d.iDRepuesto.iDRepuesto = :idRepuesto", 
                Long.class)
                .setParameter("idFactura", idFactura)
                .setParameter("idRepuesto", idRepuesto)
                .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error verificando existencia de repuesto en factura", e);
        }
    }

    // CORRECCIÓN: Método para calcular subtotal automáticamente
    @Transactional
    public void actualizarSubtotal(Integer idDetalle) {
        try {
            DetalleFactura detalle = em.find(DetalleFactura.class, idDetalle);
            if (detalle != null && detalle.getCantidad() != null && detalle.getPrecioUnitario() != null) {
                BigDecimal subtotal = detalle.getPrecioUnitario().multiply(BigDecimal.valueOf(detalle.getCantidad()));
                detalle.setSubtotal(subtotal);
                em.merge(detalle);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error actualizando subtotal", e);
        }
    }

    // CORRECCIÓN: Método para obtener detalles con información completa de servicios y repuestos
    public List<DetalleFactura> findAllWithDetails() {
        try {
            return em.createQuery(
                "SELECT d FROM DetalleFactura d " +
                "LEFT JOIN FETCH d.iDServicio " +
                "LEFT JOIN FETCH d.iDRepuesto " +
                "LEFT JOIN FETCH d.iDFactura f " +
                "ORDER BY d.iDFactura.iDFactura, d.iDDetalleFactura", 
                DetalleFactura.class)
                .getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error obteniendo todos los detalles con información completa", e);
        }
    }
}